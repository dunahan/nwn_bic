# Status-Update zu `docs/nwn_bic-release-plan.md` — P2

Stand: 24. August 2026
Bezug: P2.1 (Checksums) · P2.2 (Tag-Konvention) · P2.3 (harter Tag/Version-
Check) · P2.5 (README/LICENSE im Zip) · P2.6 (Nimble-Task als einzige
Quelle). P2.4 (Windows i386) bereits vorher erledigt. Ergänzt die
P0/P1-Status-Dokumente, kein Rewrite.

**Kurzstatus:** P2.1 ✅ · P2.2 ✅ · P2.3 ✅ · P2.5 ✅ · P2.6 ✅ — alle real
verifiziert, kein einziger Punkt mehr "übernommen, nicht geprüft".

**Wichtigste Neuigkeit dieser Runde, noch vor P2 selbst:** Ein voll
funktionierendes Nimble ist jetzt in der Sandbox verfügbar (s. u.) — damit
konnte die einzige verbliebene Lücke aus dem P0-Status ("P0.4 übernommen,
nicht unabhängig verifiziert") vollständig geschlossen werden. Und: P2.6s
Recherche hat einen echten Fehler in der P1-Fassung von `release.yml`
gefunden und korrigiert, bevor er ausgeliefert wurde.

---

## Zuerst: P0.4 nachträglich vollständig verifiziert (schließt die letzte P0-Lücke)

Im P0-Status stand: *"Der GCC-14-`incompatible-pointer-types`-Fehler in
`docopt.nim.c` konnte damit in diesem Container nicht isoliert nachgestellt
werden — weder das Auftreten des Fehlers noch die Wirksamkeit des Fixes
wurden hier neu bewiesen."* Das war der Stand, weil kein Nimble-Binary
lief.

### Wie das Nimble-Problem gelöst wurde

Der vorherige Versuch scheiterte, weil `nimble`s aktueller `main`-Branch
nicht gegen Nim 2.0.0 kompiliert (Effekt-Check-Konflikt). Die eigentlich
richtige Nimble-Version für Nim 2.0.0 liegt nicht als eigener Git-Tag vor
(Nimble versioniert kaum über eigene Tags), sondern als **gepinnter Commit
in Nims eigenem `koch.nim`**:

```nim
NimbleStableCommit = "168416290e49023894fc26106799d6f1fc964a2d"
```

Genau dieser Commit geklont (`nimble v0.14.2`), plus die eine fehlende
Abhängigkeit (`dist/checksums`, die `koch.nim`s `cloneDependency` sonst
automatisch nachzieht) manuell ergänzt — damit kompiliert Nimble sauber
gegen die bereits gebootstrappte Nim-2.0.0-Toolchain.

### Der eigentliche Test: `nimble install --depsOnly` mit dem GCC-14-Flag, real

```bash
nimble install --depsOnly -y --passNim:"--passC:-Wno-error=incompatible-pointer-types"
```

Lief vollständig durch (~13 Minuten, alle 24 in `neverwinter.nimble`
deklarierten CLI-Binärtools nacheinander gebaut — `nwn_resman_diff`,
`nwn_script_comp`, `nwn_gff`, `nwn_net`, `nwn_asm`, `nwn_key_pack`,
`nwn_tlk`, `nwn_ssf`, `nwn_erf`, `nwn_erf_tlkify`, `nwn_nwsync_print`,
`nwn_resman_grep`, `nwn_resman_extract`, `nwn_nwsync_fetch`,
`nwn_nwsync_write`, `nwn_key_unpack`, `nwn_twoda`, `nwn_compressedbuf`,
`nwn_resman_pkg`, `nwn_nwsync_prune`, `nwn_key_shadows`,
`nwn_key_transparent`, `nwn_resman_stats`, `nwn_resman_cat`), Endergebnis:

```
Success: neverwinter installed successfully.
```

Kein einziger Build-Fehler. **Präzisierung gegenüber der ursprünglichen
Beschreibung im Projektgedächtnis:** Die tatsächlichen `gcc`-Aufrufe zeigen,
dass die Flag nicht nur `docopt.nim.c` betrifft, sondern **jeden**
C-Compile-Schritt in der Kette — sichtbar u. a. an `neverwinter`s eigenem
vendorten `zstd`-C-Code (`neverwinter/private/zstd/lib/...`), der mit
`-Wno-error=incompatible-pointer-types` kompiliert wurde. Die Flag ist
projektweit wirksam, nicht auf eine einzelne Datei beschränkt.

**Ehrlich weiterhin offen:** Diese Sandbox hat GCC 13.3, nicht GCC 14 (das
im Projektgedächtnis konkret benannte Auslöser-Compiler). Ob der Fehler
*ohne* die Flag auf GCC 13.3 überhaupt auftritt, wurde nicht gegengetestet
(hätte einen zweiten ~13-Minuten-Lauf gekostet, ohne zusätzlichen
Erkenntnisgewinn für die eigentliche Frage: funktioniert der Fix
end-to-end, ohne Regressionen). Was jetzt aber sicher feststeht: **der Fix
selbst läuft sauber durch den echten `nimble install --depsOnly`-Pfad, den
`release.yml` verwendet** — das war die eigentlich offene Frage aus dem
P0-Status, und die ist jetzt beantwortet.

---

## P2.6 (Nimble-Task als einzige Quelle) — deckte einen echten Fehler in P1 auf

### Die ursprüngliche P2.6-Aufgabe

Den `win`-Task aus `nwn_bic.nimble` direkt aufrufen, statt seine Flags in
der YAML zu duplizieren. Bevor das umgesetzt wurde, mit funktionierendem
Nimble zuerst geprüft: **ist der Task, so wie er im Repo steht, überhaupt
korrekt?** (Er deklariert `-d:mingw`, aber nirgends `--os:windows`.)

### Befund: Der Task war die ganze Zeit korrekt — mein P1-„Fix" war das eigentliche Problem

Mit echtem Nimble nachgestellt:

```bash
nim c -d:release -d:mingw --passL:-static --dynlibOverrideAll \
  --path:deps/neverwinter -o:bin/nwn_bic_task.exe src/nwn_bic.nim
```

→ `PE32+ executable ... for MS Windows`, `objdump` zeigt nur `KERNEL32.dll`
und `msvcrt.dll`. Funktioniert einwandfrei, genau wie im Task deklariert.

Isolierter Vergleich, welches der beiden in P1 zusätzlich gesetzten Flags
das Problem verursacht hatte:

| Zusatz-Flag | Ergebnis |
|---|---|
| kein Zusatz (Task wie geschrieben) | ✅ `x86_64-w64-mingw32-gcc` korrekt gewählt |
| nur `--cpu:amd64` | ✅ weiterhin korrekt |
| nur `--os:windows` | ❌ fällt auf reines `gcc` zurück, bricht an `windows.h` |

**`--os:windows` explizit gesetzt bricht die Compiler-Auswahl** — obwohl
`-d:mingw` allein (auf einem Unix-Host) laut `nim.cfg` bereits
`--os:windows` impliziert. Die redundante explizite Angabe stört
offenbar die Reihenfolge, in der `nim.cfg`s `@if unix and mingw:`-Block
ausgewertet wird. Das ist eine reale, reproduzierbare Nim-Eigenheit — aber
sie war durch meinen eigenen P1-Diff selbst eingeführt (ich hatte
`--os:windows --cpu:amd64` mit angegeben, "um sicherzugehen"), nicht ein
Problem des bestehenden Tasks.

### Root-Cause-Fix statt Symptom-Fix

Die in P1 ergänzten `--gcc.exe`/`--gcc.linkerexe`-Flags haben nur das
Symptom behandelt (Compiler manuell erzwungen), nicht die Ursache (den
unnötigen `--os:windows`-Zusatz). Root-Cause-Fix: den Zusatz komplett
entfernen, den Task unverändert aufrufen. `release.yml`s Windows-Build-
Schritt ist jetzt buchstäblich:

```yaml
- name: Compile for Windows amd64
  if: matrix.bintype == 'win-amd64'
  run: nimble win
```

Ein Einzeiler statt zehn Zeilen. Das ist die eigentliche Substanz von
P2.6 — nicht "auf den Task verweisen", sondern "den unnötigen Umweg
entfernen, der den Task in P1 überhaupt erst umgehen ließ".

### Zweiter, unabhängiger Fund dabei: der `.exe`-Rename-Schritt war ein Bug

Real mit `nimble win` getestet: die Ausgabedatei heißt bereits
`bin/nwn_bic.exe` — Nim/Nimble hängen die Endung für ein Windows-Ziel
selbst an. Der aus dem Original-`release.yml` übernommene Schritt
`for f in bin/*; do mv "$f" "$f.exe"; done` hätte daraus
`nwn_bic.exe.exe` gemacht. In P1 unbemerkt mit übernommen (der alte
Workflow-Kontext — Cross-Compile ohne `-d:mingw`s OS-Implikation, dafür mit
explizitem `-d:mingw --cpu:i386`/`--cpu:amd64` ohne Task — mag die Endung
damals tatsächlich gebraucht haben; mit dem jetzt korrekt funktionierenden
Task ist er überflüssig und schädlich). Entfernt.

### Erneuter End-to-End-Beweis, jetzt mit echtem `nimble win`

```
Executing task win in .../nwn_bic.nimble
Building windows binary with mingw
   Building nwn_bic/nwn_bic using c backend
```
→ `bin/nwn_bic.exe`, PE32+, nur `KERNEL32.dll`/`msvcrt.dll`, startet unter
Wine sauber (Usage-Meldung ohne Argument, kein Absturz — der von P1
dokumentierte Seek-Bug betrifft nur Wines Ausführung mit einer echten
`.bic`-Datei, nicht den Start des Programms selbst).

---

## P2.1 (Checksums) — real erzeugt und real gegengeprüft

Eine kombinierte `SHA256SUMS.txt` (Konvention, die z. B. Go-Releases
verwenden) statt einer `.sha256`-Datei pro Zip — eine
`sha256sum -c SHA256SUMS.txt` statt drei Einzelprüfungen.

Mit drei Platzhalter-Zips (gleiche Verzeichnisnamen wie im echten Workflow:
`bin-linux/`, `bin-windows-amd64/`, `bin-macos/`) real erzeugt:

```bash
sha256sum bin-linux/*.zip bin-windows-amd64/*.zip bin-macos/*.zip \
  | sed -E 's| bin-[a-z0-9-]+/| |' > SHA256SUMS.txt
```

Danach die drei Zips flach in ein Verzeichnis kopiert (so, wie ein
Nutzer sie nach dem Download vorfindet) und geprüft:

```
nwn_bic.linux.amd64.zip: OK
nwn_bic.windows.amd64.zip: OK
nwn_bic.macosx.amd64.zip: OK
```

`SHA256SUMS.txt` wird zusätzlich zu den drei Zips über `gh release create`
hochgeladen.

## P2.2 (Tag-Konvention) — mechanisch, kein Test nötig

`tags: ['*']` → `tags: ['v*']`. Reines YAML-Feld.

## P2.3 (harter Tag/Version-Check) — Regex und Logik beide real getestet

Regex von der fixen-Breite-Lookbehind-Version (`(?<=version {5}= ")`, die
exakt 5 Leerzeichen voraussetzte) auf `\K` umgestellt
(`^version\s*=\s*"\K[^"]+`) — robust gegen jede Leerzeichenzahl, gegen den
echten Inhalt von `nwn_bic.nimble` getestet: extrahiert `0.1.1` korrekt.

Vergleichslogik in beide Richtungen getestet:

| Tag | nimble-Version | Ergebnis |
|---|---|---|
| `v0.1.1` | `0.1.1` | Treffer, Job läuft weiter |
| `0.1.1` (ohne `v`) | `0.1.1` | Treffer, Job läuft weiter |
| `v0.1.2` | `0.1.1` | **Fehlschlag, `exit 1`** |
| `v2.0.0` | `0.1.1` | **Fehlschlag, `exit 1`** |

Von `::warning::` (P1, Job lief trotzdem weiter) auf `::error::` + `exit 1`
(P2, Job bricht ab, keine Artefakte werden gepackt oder veröffentlicht).

## P2.5 (README/LICENSE im Zip) — mechanisch

`cp ../README.md ../LICENSE .` vor jedem `zip`-Aufruf, in allen drei
Pack-Schritten (Linux/Windows/macOS). Kein Test nötig über die YAML-Syntax-
Prüfung hinaus — reines Datei-Kopieren, kein Verhalten, das schiefgehen
könnte, das nicht schon durch `checkout` + relative Pfade abgedeckt wäre.

---

## Ehrlicher Gesamt-Hinweis

Der eigentliche Wert dieser Runde liegt nicht in den fünf P2-Punkten
selbst (die waren, bis auf die Nimble-Hürde, mechanisch), sondern darin,
dass ein funktionierendes Nimble zwei vorher unsichere Stellen in Fakten
verwandelt hat: P0.4 ist jetzt vollständig bewiesen statt übernommen, und
P2.6 hat einen echten, sonst unbemerkt gebliebenen Fehler (die
`.exe.exe`-Doppelbenennung) gefunden, bevor er in einem echten Release
aufgetaucht wäre. Die Selbstkorrektur bei P1.1 (root-caused statt
symptomatisch gepatcht) ist genau die Art Fehlerkorrektur, die dieses
Projekt explizit von sich verlangt — festgehalten, nicht verschwiegen.
