# Status-Update zu `docs/nwn_bic-release-plan.md`

Stand: 23. August 2026
Bezug: P0.1–P0.5 (Runner-Image, Nim-Version, GCC-14-Workaround, veraltete
Release-Actions, fehlende `permissions`). Kein Rewrite des Plans, nur das
Delta — gleiche Konvention wie `nwn_bic-cli-plan-status.md`.

**Kurzstatus:** P0.1 ✅ · P0.2 ✅ · P0.3 ✅ · P0.4 ⚠️ (siehe unten,
übernommen aber nicht unabhängig neu verifiziert) · P0.5 ✅

---

## Umgebungs-Einschränkung (wichtig für die Einordnung aller Ergebnisse)

Dieser Container hat kein vorinstalliertes Nim und keinen Zugriff auf
`nim-lang.org` (Netzwerk-Allowlist erlaubt nur `github.com` u. a., nicht die
Nim-Downloadseite). Für eine echte Verifikation wurde deshalb:

1. `nim-lang/Nim` auf Tag `v2.0.0` von GitHub geklont und **real aus dem
   Quellcode gebootstrapt** (csources → Stage-1-Compiler → Stage-2 via
   `nim c compiler/nim.nim`, jeweils mit Timeout in Einzelschritte
   aufgeteilt, da der volle `build_all.sh`-Lauf das Tool-Zeitlimit
   überschritten hätte).
2. `nim-lang/nimble` geklont, inkl. **rekursiver** Submodule (`chronos`,
   `stew`, `bearssl` + dessen eigenes verschachteltes `csources`-Submodule
   — musste extra mit `--recursive` nachgezogen werden, `--depth 1` allein
   hatte die verschachtelte Ebene übersprungen).

Ergebnis: ein echtes, lokal gebautes Nim `2.0.0` (`nim-src/bin/nim`,
`--version` bestätigt) stand für alle folgenden Tests zur Verfügung.

**Ehrlich offen:** Nimbles eigenes `src/nimble.nim` hat sich gegen dieses
Nim-2.0.0 **nicht** selbst kompilieren lassen — Fehler `can raise an
unlisted exception: Exception` in `nimblepkg/download.nim`, ein
Effekt-Check-Konflikt zwischen dem gecloneten Nimble-HEAD und Nim 2.0.0,
unabhängig vom eigentlichen P0-Thema. Kein `--panics:off` o. ä. konnte das
umgehen (ausprobiert, half nicht — es ist ein `{.raises.}`-Fehler, keine
Panic-Option). Damit gibt es in diesem Container **kein funktionierendes
`nimble`-Binary** — P0.4 (der `nimble install --depsOnly`-Workaround) konnte
deshalb nicht 1:1 als echter `nimble install`-Lauf nachgestellt werden, s.
unten.

---

## P0.1 (Runner-Image) — als Diff umgesetzt, nicht laufend verifizierbar

`ubuntu-18.04` → `ubuntu-latest` in beiden betroffenen Jobs
(`build-linux-win`, `release`). Ein echter Beweis, dass das den Job wieder
startfähig macht, ist nur durch einen echten Tag-Push auf GitHub möglich —
das kann dieser Container nicht simulieren (kein Actions-Runner hier). Die
Änderung selbst ist mechanisch eindeutig: `ubuntu-18.04` existiert nicht
mehr als Image-Label, `ubuntu-latest` ist der etablierte Ersatz, den
`build.yml` bereits produktiv nutzt.

## P0.2 + P0.3 (Nim-Version + Installationsmethode) — real kompiliert und ausgeführt

**Kernfrage:** Kompiliert `nwn_bic` (gegen `neverwinter` 2.2.0) überhaupt
unter Nim `2.0.0` — der Version, auf die `release.yml` jetzt zeigen soll?

Statt zu raten: real getestet, End-to-End, gegen eine echte Binärdatei.

1. `neverwinter.nim` auf Tag `2.2.0` von GitHub geklont (`deps/neverwinter`).
2. Ein Compile-Probe (`src/p0_probe.nim`) geschrieben, das exakt dieselbe
   `neverwinter/gff`-API-Oberfläche anfasst wie `src/nwn_bic.nim`:
   `readGffRoot`, `GffCExoLocString`, `GffList`, indizierter Struct-Zugriff
   mit Default-Overloads (`GffByte`/`GffShort`/`GffWord`/`GffInt`), inkl.
   des seit P1 defaulteten `BaseAttackBonus`-Zugriffs.
3. Kompiliert mit `nim c -d:release --path:deps/neverwinter`, unter
   Verwendung des **echten Projekt-`nim.cfg`**
   (`--passC:"-Wno-error=incompatible-pointer-types"`) — 0 Fehler, 0
   Warnungen außer harmlosen Hints.
4. Ein zweites Hilfstool (`scripts_build_bic.nim`) gebaut, das
   `neverwinter/gffjson`s `gffRootFromJson()` + die Library-eigene
   `write(io: Stream, root: GffRoot)`-Funktion nutzt — dieselbe Technik, die
   im CLI-Plan-Status-Dokument für P0.2/P0.3/P1.1 bereits etabliert wurde.
5. Damit eine **echte binäre `test1.bic`** aus einer (gekürzten, aber realen)
   JSON-Repräsentation von `test1.bic.json` erzeugt.
6. `p0_probe` gegen diese echte Binärdatei laufen lassen:

```
OK: examples/bic/test1.bic first=23 race=6 age=0 bab=1 classes=1 feats=11 school=255
```

Race=6 (Human), BAB=1, 1 Klasse, 11 Feats — deckt sich mit den bekannten
`test1`-Referenzwerten aus dem CLI-Plan. Kein Absturz, keine Nim-2.0.0-
spezifische Inkompatibilität gefunden.

**Ergebnis:** Nim `2.0.0` + `neverwinter` 2.2.0 + das bestehende `nim.cfg`
sind zueinander kompatibel — der im Plan vermutete "Blocker" (Versions-
konflikt) betrifft **nur** die in `release.yml` fest verdrahtete
`NIMVER: "1.6.4"`-Umgebungsvariable, nicht das Projekt selbst. Die Umstellung
auf `jiro4989/setup-nim-action@v2` (wie in `build.yml`) mit
`vars.NIM_VERSION` statt eines eigenen, veralteten `NIMVER`-Werts behebt das
strukturell — ein Repository-Variable-Wert statt zweier unabhängiger,
auseinanderlaufender Versionsangaben.

## P0.4 (GCC-14-Workaround) — übernommen, aber ausdrücklich nicht unabhängig neu verifiziert

> **Nachtrag (P2, 2026-08-24):** Diese Lücke ist inzwischen geschlossen —
> ein funktionierendes Nimble stand für die P2-Runde zur Verfügung, und
> `nimble install --depsOnly` mit exakt diesem Flag lief real vollständig
> durch (alle 24 CLI-Binärtools von `neverwinter`, kein Fehler). Details:
> `docs/nwn_bic-release-plan-status-p2.md`, Abschnitt "P0.4 nachträglich
> vollständig verifiziert". Der Text unten bleibt als Herleitung stehen,
> warum die Verifikation zum Zeitpunkt von P0 noch nicht möglich war.

Das war der ehrlich offene Punkt zum P0-Zeitpunkt (s. Nachtrag oben).

**Was geprüft wurde:** `neverwinter/gff.nim` selbst zieht beim reinen
Bauen (Schritt oben) kein `docopt` und keinen problematischen C-Code — der
`p0_probe`-Compile lief sauber durch, mit **und** wäre vermutlich auch ohne
den `nim.cfg`-Flag durchgelaufen (nicht separat gegengetestet, da der Flag
im echten `nim.cfg` immer aktiv ist und ich das Projektverhalten testen
wollte, nicht künstlich den Fehler ohne Flag reproduzieren).

**Was NICHT geprüft werden konnte:** Der eigentliche, im Projektgedächtnis
dokumentierte Fehler tritt laut Beschreibung bei `nimble install --depsOnly`
auf — dabei baut Nimble die **24 CLI-Binärtools**, die `neverwinter.nim`s
eigene `.nimble`-Datei deklariert (`nwn_gff`, `nwn_tlk`, `nwn_erf`, ...),
und diese Tools hängen von `docopt >= 0.7.1` ab. Das reale, gepinnte
`docopt.nim` real zu bauen scheiterte hier **nicht** am GCC-14-Fehler
selbst, sondern schon einen Schritt vorher: `docopt.nim` deklariert seinerseits
eine `regex`-Abhängigkeit, die ohne funktionierendes Nimble (s.o.) nicht
auflösbar war. Der GCC-14-`incompatible-pointer-types`-Fehler in
`docopt.nim.c` konnte damit in diesem Container **nicht isoliert
nachgestellt** werden — weder das Auftreten des Fehlers noch die Wirksamkeit
des Fixes wurden hier neu bewiesen.

**Getroffene Entscheidung:** Der `--passNim:"--passC:-Wno-error=incompatible-
pointer-types"`-Flag wurde trotzdem 1:1 aus `build.yml` in `release.yml`
übernommen (siehe Diff), weil:

- exakt dieselbe Abhängigkeit (`neverwinter` mit `requires "docopt >= 0.7.1"`)
  betroffen ist,
- exakt derselbe Fehlerpfad (`nimble install --depsOnly` baut die
  Binärtool-Liste inkl. deren Dependencies) durchlaufen wird,
- der Fix in `build.yml` bereits real gegen echte CI-Runner verifiziert
  wurde (dokumentiert im Projektgedächtnis) und dort GCC 14 tatsächlich
  vorliegt (dieser Container hat nur GCC 13.3 — auch das ein Grund, warum
  der Fehler hier ohnehin nicht zwingend reproduzierbar gewesen wäre, selbst
  mit funktionierendem Nimble).

Das ist eine **begründete Übernahme**, keine unabhängig neu bewiesene
Tatsache — im Code-Kommentar des Diffs entsprechend als "carried over as-is
... flagged here as inherited, not independently reproduced" markiert,
damit das nicht als abgeschlossen gilt, falls ein künftiger echter
CI-Lauf etwas anderes zeigt.

## P0.5 (`permissions: contents: write`) — mechanischer Fix, kein Laufzeittest nötig

Reines YAML-Feld auf Workflow-Ebene ergänzt. Kein Compile- oder
Laufzeitverhalten zu verifizieren — GitHubs eigene Dokumentation zum
`GITHUB_TOKEN`-Berechtigungsmodell ist hier die relevante Quelle, nicht
dieser Container. Als YAML-Syntax geprüft (siehe unten).

---

## Was der Diff bewusst NICHT ändert (gehört zu P1, nicht P0)

- Windows-Build läuft weiterhin über mingw-Cross-Compile + `dlls.zip`
  (P1.1 — Umstellung auf den bereits vorhandenen `nimble win`-Task mit
  `--passL:-static` ist der nächste Schritt, nicht Teil von P0).
- macOS-Build nutzt jetzt zwar `setup-nim-action` (musste für P0.2/P0.3
  ohnehin ersetzt werden, da der alte `build.sh`/`koch boot`-Pfad ebenfalls
  die falsche `NIMVER` gezogen hätte), aber der alte, jetzt tote
  `mkdir nim / wget / tar xf / koch boot`-Block wäre in einem sauberen
  Diff eigentlich ersatzlos zu streichen — hier bereits geschehen, da er
  sonst gar nicht mehr aufgerufen würde und als Leiche im File stehen
  bliebe (kleinste sinnvolle Y-Änderung, keine Straffung darüber hinaus).
- `create-release@v1`/`upload-release-asset@v1` bleiben unverändert (P1.5).
- Kein Smoke-Test vor dem Packen (P1.3).
- Kein Tag/Version-Abgleich (P2.3).
- Windows i386 bleibt vorerst erhalten (offene Frage, siehe Hauptplan
  Abschnitt 6 — nicht eigenmächtig entschieden).

## Verifikation der YAML-Syntax

`python3 -c "import yaml; yaml.safe_load(open('release.yml'))"` — lädt ohne
Fehler. Das prüft nur Syntax, keine GitHub-Actions-Semantik (z. B. ob
`vars.NIM_VERSION` im echten Repo tatsächlich gesetzt ist — das ist laut
`build.yml`, das dieselbe Variable bereits produktiv verwendet, der Fall,
aber hier nicht erneut nachgeprüfbar).

## Ehrlicher Gesamt-Hinweis

Vier von fünf P0-Punkten sind entweder mechanisch eindeutig (0.1, 0.5) oder
real gegen eine lokal gebaute Nim-2.0.0-Toolchain + die echte
`neverwinter`-2.2.0-Library end-to-end verifiziert (0.2, 0.3, inkl. einer
real erzeugten und gelesenen `.bic`-Binärdatei). P0.4 ist eine begründete,
aber nicht in diesem Container unabhängig bewiesene Übernahme eines bereits
für `build.yml` verifizierten Fixes — das sollte beim ersten echten
Tag-Push (auf einem GitHub-Actions-Runner mit echtem GCC 14 und echtem
Nimble) als Erstes beobachtet werden, bevor P0 als vollständig
abgeschlossen gilt.

Nicht geprüft, weil außerhalb des P0-Umfangs: Windows-Cross-Compile-Läufe
(P1-Thema), macOS-nativer Build unter `setup-nim-action` (kein macOS-Runner
in diesem Container verfügbar), der komplette `release`-Job (Artefakt-
Download/Packen/Release-Erstellung — hängt an echten Artefakten aus den
Build-Jobs, die nur auf echten Runnern entstehen).
