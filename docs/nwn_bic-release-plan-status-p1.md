# Status-Update zu `docs/nwn_bic-release-plan.md` — P1

Stand: 23. August 2026
Bezug: P1.1 (Windows-DLL-Fix via statischem Linking) · P1.2 (macOS
`setup-nim-action`, bereits mit P0 erledigt) · P1.3 (Smoke-Tests vor dem
Packen) · P1.4 (Action-Versionen) · P1.5 (Release-Erstellung ohne
archivierte Actions). Ergänzt `nwn_bic-release-plan-status.md` (P0), kein
Rewrite.

**Kurzstatus:** P1.1 ✅ (mit einem real gefundenen, wichtigen Zusatz) · P1.2
✅ (schon in P0 erledigt) · P1.3 ✅ · P1.4 ✅ (mit einer offenen
Versions-Unsicherheit) · P1.5 ⚠️ (Syntax bekannt, in diesem Container nicht
ausführbar getestet, da kein `gh`-Binary vorhanden)

---

## P1.1 (Windows-DLL-Fix) — real kompiliert, real analysiert, ein Fund verändert den Plan

> **Nachtrag (P2, 2026-08-24):** Die hier beschriebenen zusätzlichen
> `--gcc.exe`/`--gcc.linkerexe`-Flags waren ein Symptom-Fix für ein
> Problem, das erst durch das gleichzeitig hinzugefügte `--os:windows`
> verursacht wurde — nicht durch den Task selbst. Root-Cause-Fund und
> -Fix in `docs/nwn_bic-release-plan-status-p2.md` (P2.6). Der `win`-Task
> aus `nwn_bic.nimble`, unverändert aufgerufen, war die ganze Zeit korrekt.
> Text unten bleibt als Herleitung stehen.

### Die Kernbehauptung des Plans, jetzt bewiesen statt vermutet

`nwn_bic.nimble`s `win`-Task deklariert `-d:mingw --passL:-static
--dynlibOverrideAll`. Real cross-kompiliert (mingw-w64 via `apt`, beide
Zielarchitekturen) und mit `objdump -p` die tatsächlichen DLL-Importe
geprüft:

```
amd64: DLL Name: KERNEL32.dll / DLL Name: msvcrt.dll
i386:  DLL Name: KERNEL32.dll / DLL Name: msvcrt.dll
```

Beides sind Bestandteile jeder Windows-Installation seit XP — keine der
Runtime-DLLs aus `dlls.zip` (`libwinpthread-1.dll`, `libgcc_s_seh-1.dll`,
...) wird gebraucht. Der komplette `dlls.zip`-Download- und Kopierschritt
entfällt ersatzlos, nicht nur gekürzt.

### Real gefundene Abweichung vom Task, wie er im Repo steht

`-d:mingw` allein hat in der lokal gebauten Nim-2.0.0-Toolchain den
Cross-Compiler **nicht** zuverlässig ausgewählt — der erste Versuch baute
mit reinem `gcc` und brach an `windows.h: No such file or directory` ab.
Erst explizite `--gcc.exe:x86_64-w64-mingw32-gcc
--gcc.linkerexe:x86_64-w64-mingw32-gcc` (analog für i386) haben den
Cross-Compiler zuverlässig gezogen — geprüft in `nim.cfg` der
Nim-Distribution selbst: Der Abschnitt `@if unix and mingw:` setzt
`amd64.windows.gcc.exe` korrekt, aber aus einem hier nicht abschließend
geklärten Grund griff die Bedingung beim ersten Versuch nicht.

**Ehrlich offen:** Ob das eine generelle Nim-2.0.0-Eigenheit ist oder ein
Artefakt der **selbstgebauten** Toolchain (Bootstrap aus dem Quellcode statt
der von `setup-nim-action` bereitgestellten Fertig-Distribution), konnte
hier nicht abschließend geklärt werden. Der Diff enthält die expliziten
Flags trotzdem — sie sind ein Nullkosten-Sicherheitsnetz: Falls `-d:mingw`
auf dem echten Runner (mit der echten `setup-nim-action`-Toolchain)
zuverlässig funktioniert, ändern die expliziten Flags nichts am Ergebnis;
falls nicht, verhindern sie denselben Fehlschlag, der hier auftrat.

## P1.3 (Smoke-Tests) — wichtiger Fund: Wine ist kein verlässlicher Windows-Ersatz für diesen Codepfad

### Was zuerst versucht wurde

Naheliegender Plan: den cross-kompilierten Windows-Build direkt auf dem
`ubuntu-latest`-Runner unter Wine smoke-testen (kein zusätzlicher Runner
nötig). `wine64` über `apt` installiert (ein 404 im ersten Versuch war ein
veralteter Paket-Index, `apt-get update` hat es behoben — kein echtes
Problem).

### Was der Test zeigte

1. Ein minimaler Datei-Lese-Test (`openFileStream` + `readAll`) funktioniert
   unter Wine einwandfrei — 1008 von 1008 Bytes gelesen.
2. Sequentielles Lesen exakt wie am Anfang von `readGffRoot`
   (`fileType`, `fileVersion`, erster `readInt32`) funktioniert ebenfalls
   einwandfrei — `structOffset=56` korrekt gelesen.
3. **Aber:** Ein `setPosition(56)` gefolgt von `readInt32()` liefert unter
   Wine `-1` statt eines validen Werts — obwohl `getPosition()` direkt davor
   korrekt `56` meldet. Klassisches Muster einer
   gepufferte-Read-nach-Seek-Inkonsistenz in Wines `msvcrt.dll`-Emulation.
4. Damit scheitert der volle `readGffRoot`-Aufruf unter Wine an
   `Invalid parameter`, obwohl das Binary selbst korrekt lädt, startet und
   sauber über den eigenen `try/except`-Fehlerpfad (P0.4-Fix) reagiert —
   kein Absturz, kein DLL-Fehler, nur ein falscher Rückgabewert nach Seek.

### Warum das kein Hinweis auf ein echtes Problem ist — aber auch nicht einfach ignoriert werden darf

`build.yml` beweist bereits auf einem **echten** `windows-latest`-Runner,
dass exakt dieselbe `readGffRoot`-Logik (inkl. Seek über die GFF-Offset-
Tabelle) korrekt funktioniert — dort aber nativ gebaut (MSVC/native Nim-
Windows-Toolchain), nicht mingw-cross-kompiliert von Linux aus. Die
verbleibende, echte Lücke ist also nicht "funktioniert Seek+Read auf
Windows" (das ist bereits bewiesen), sondern "verhält sich ein **mingw**-
cross-kompiliertes Binary auf **echtem** Windows genauso wie ein nativ
gebautes". Das lässt sich mit Wine nicht beantworten — Wine ist eine
Emulation mit eigenen, bekannten Lücken gerade bei Datei-I/O-Edge-Cases,
kein Ersatz für echtes Windows.

### Konsequenz für den Diff

Ein neuer Job `smoke-test-windows` (läuft auf echtem `windows-latest`, kein
Zusatzaufwand an neuer Infrastruktur — nutzt dieselbe Artifact-Upload-/
Download-Mechanik, die für den `release`-Job ohnehin schon existiert) lädt
das reale, cross-kompilierte Artefakt herunter und führt es auf echter
Windows-Hardware gegen `test1.bic` aus, mit denselben Prüfungen wie
`build.yml`. Das ist stärker als jeder Wine-basierte Test und beantwortet
die eigentlich offene Frage direkt, statt sie über eine unzuverlässige
Emulationsschicht zu vermuten.

Für Linux und macOS wurden die aus `build.yml` bereits bekannten Smoke-
Test-Kommandos direkt in die jeweiligen Build-Jobs übernommen (native
Ausführung, kein Emulationsproblem, kein separater Job nötig).

## P1.4 (Action-Versionen) — teilweise verifiziert

- `actions/checkout@v7`: übernommen von `build.yml`, dort bereits
  produktiv — kein neuer Wert, sondern Versionsgleichstand.
- `actions/upload-artifact@v4` / `actions/download-artifact@v4`: **nicht**
  über die GitHub-API verifiziert — `api.github.com` hat mit "rate limit
  exceeded" (unauthentifiziert) geantwortet, bevor eine echte Versions-
  abfrage möglich war. `v4` ist eine bekannt existierende, stabile Major-
  Version dieser Actions, aber **kein** empirisch für "aktuell zum
  Umsetzungszeitpunkt" bestätigter Wert. Vor dem echten Merge sollte
  jemand mit funktionierendem GitHub-API-Zugriff (oder direkt im
  Marketplace) kurz gegenprüfen, ob es inzwischen eine neuere Major-Version
  gibt — kein Blocker, aber auch keine behauptete Tatsache.

## P1.5 (Release-Erstellung über `gh` CLI) — Syntax bekannt, hier nicht ausführbar getestet

`gh release create <tag> --draft --title "..." <dateien...>` ist eine seit
Jahren stabile, dokumentierte `gh`-CLI-Syntax. Dieser Container hat kein
`gh`-Binary (im Gegensatz zu echten GitHub-Actions-Runnern, die es
vorinstalliert mitbringen) — der Aufruf konnte hier deshalb nicht real
ausgeführt werden. Ersetzt `create-release@v1`/`upload-release-asset@v1`
(von GitHub archiviert) durch eine einzige, native Anweisung ohne neue
Drittanbieter-Abhängigkeit (Sprosse 4). Sollte beim ersten echten Tag-Push
als Erstes beobachtet werden, wie schon P0.4.

## Nicht Teil dieses Diffs (bewusst, gehört zu P2)

- SHA-256-Checksums (P2.1).
- Der Tag/Version-Abgleich ist **nur als Warnung** eingebaut (`::warning::`,
  Job läuft trotzdem weiter) — die harte Fehlschlag-Variante ist P2.3, hier
  bewusst nicht vorgezogen, um P1 nicht mit P2 zu vermischen.
- Windows i386 bleibt erhalten (offene Frage aus dem Hauptplan, weiterhin
  nicht eigenmächtig entschieden).
- Checksums, README/LICENSE im Zip, `win`/`macos`-Task-Vereinheitlichung.

## Nachtrag: offene Entscheidungen aus Abschnitt 6 des Hauptplans geklärt (2026-08-24)

Tobias: *"Ich denke als Release auf GitHub reichen die üblichen Binaries,
sollte jemand speziell etwas brauchen kann das nachher noch folgen, oder er
kann es selbst generieren."*

Damit sind beide im Hauptplan offen gelassenen Fragen entschieden:

- **Windows i386 (P2.4):** gestrichen. Aus dem Build-Matrix, dem
  `smoke-test-windows`-Job (der dadurch von einer Matrix auf ein festes
  Ziel vereinfacht wurde — eine Matrix für ein einziges Element wäre selbst
  unnötige Struktur gewesen) und dem `release`-Job entfernt. `nwn_bic.nimble`
  bleibt unverändert (der `win`-Task selbst nimmt weiterhin `--cpu` nicht
  entgegen, s. P1.1 — bei Bedarf kann i386 jederzeit durch einen manuellen
  `nimble build -d:mingw --cpu:i386 ...`-Lauf selbst erzeugt werden, exakt
  wie in der Entscheidung vorgesehen).
- **macOS arm64 (P3.1):** bleibt zurückgestellt, keine Änderung nötig — war
  ohnehin schon als P3/optional eingestuft, diese Antwort bestätigt das nur.

Diff-Umfang: acht Fundstellen in `release.yml` (Matrix-Eintrag, zwei
Build-/Upload-Steps, ein Matrix-Eintrag im Smoke-Test-Job plus dessen
komplette Vereinfachung, zwei Download-/Pack-Steps im `release`-Job, ein
Dateipfad in der `gh release create`-Liste) — real editiert, YAML-Syntax
danach erneut geprüft (`python3 -c "import yaml; yaml.safe_load(...)"`,
fehlerfrei).

## Ehrlicher Gesamt-Hinweis

Der wertvollste Fund dieser Runde ist nicht "P1.1 funktioniert" (das war
erwartet), sondern dass **Wine für diesen spezifischen Codepfad
irreführende Ergebnisse liefert** — ein Smoke-Test, der sich naiv auf Wine
verlassen hätte, wäre am Ende fälschlich rot gewesen, obwohl der eigentliche
Build in Ordnung ist. Die gewählte Lösung (echter `windows-latest`-Job)
kostet eine zusätzliche, aber kleine und mit vorhandener Infrastruktur
gebaute Stelle im Workflow, beantwortet die eigentliche Frage aber
zuverlässig statt nur scheinbar.
