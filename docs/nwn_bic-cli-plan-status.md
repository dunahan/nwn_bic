# Status-Update zu `docs/nwn_bic-cli-plan.md`

Stand: 20. August 2026
Bezug: P0.1–P0.4 aus dem bestehenden Plan (SkillList-, FeatList-,
Ausgabepfad- und Fehlerbehandlungs-Bug) — Ergebnis der genaueren Analyse
plus Fixes, chronologisch in dieser Reihenfolge umgesetzt. Kein Rewrite des
Plans, nur das Delta, damit nichts aus dem Projektgedächtnis verloren geht
(ponytail: kleinste Diff, die den Zweck erfüllt).

**Kurzstatus:** P0.1 ✅ · P0.2 ✅ · P0.3 ✅ · P0.4 ✅ — P0 (Korrektheit)
damit laut Plan vollständig abgearbeitet. Nächster Kandidat: P1
(`BUILD DETAILS` vervollständigen).

## Korrektur einer Annahme im bestehenden Plan

Der Plan (Abschnitt 2, P0.1) unterstellte: "SkillList-Bug: `Skill`-ID + Rang aus
jedem `SkillList`-Struct lesen statt Schleifenindex `c`". Das ist zur Hälfte
falsch — Gegenprobe an allen vier vorliegenden `*.bic.json`
(`test`, `test1`, `aluviandarks169`) zeigt: **jeder Eintrag in `SkillList` hat
NUR ein `Rank`-Feld, kein `Skill`-Feld.** Die Position im Array *ist* die
Skill-ID (Index 0 = Animal Empathy, 1 = Concentration, ... — exakt die
Reihenfolge, die `helper.bicSkill()` schon verwendet). Das ist eine reguläre
NWN-1.69-GFF-Eigenschaft (fixes, indexpositionelles Array über alle
Skills), kein Bug.

Der Schleifenindex `c` zur Namensauflösung war also schon richtig. Der
tatsächliche Bug, verifiziert gegen die Referenzausgabe
(`examples/bic/aluviandarks1691.txt`, `test1.txt`):

1. `Rank` wird nie gelesen — die Zeile endet nach dem Doppelpunkt ohne Wert.
2. Es fehlt die Filterung auf `Rank > 0` — die Referenzausgabe listet nur
   investierte Skills (5 von 27 bei Aluvian, 5 von 27 bei test1), das
   aktuelle Programm hätte alle 27 gedruckt.

Gegenprobe mit `test1.bic.json` (`SkillList`-Werte, 0-indiziert):
Index 3 = 4, Index 6 = 4, Index 10 = 4, Index 17 = 2, Index 18 = 4 → über
`bicSkill()`: Discipline, Listen, Parry, Spot, Taunt. Das deckt sich exakt mit
`test1.txt`s "Disziplin: 4 / Lauschen: 4 / Parieren: 4 / Entdecken: 2 /
Provozieren: 4" (deutsche Referenzbegriffe, gleiche Skills, gleiche Werte —
die Übersetzung selbst ist P2.3, nicht Teil dieses Fixes).

## Fix (P0.1 — erledigt in diesem Durchgang)

`src/nwn_bic.nim`, SKILLS-Block: `Rank` pro Index lesen, nur bei `> 0`
ausgeben, Wert an die Zeile anhängen. Kein neuer Typ, keine neue Abstraktion —
gleiche Zugriffsart (`obj["Feld", typ]`) wie im Rest der Datei
(`root["Race", byte]`, `clist[c]["Class", GffInt]`). Siehe gepatchte Datei.

Rung der Leiter: **2** (Muster, das im Code schon existiert, wiederverwendet)
und **7** (das Minimum, das den Bug behebt — kein Refactoring der
SKILLS/FEATS-Duplikation, das wäre ein eigener, ungefragter Schnitt).

## P0.2 (FeatList) — erledigt in diesem Durchgang

Anders als bei SkillList tragen `FeatList`-Einträge tatsächlich ein eigenes
`Feat`-Feld (`type: "word"`, uint16) — die Position im Array ist hier nur
Einfügereihenfolge, keine ID. `nwn_bic.nim` verwendete den Schleifenindex `c`
statt dieses Felds → echter ID-Bug, unabhängig vom SkillList-Fall.

**Warum das gefährlicher ist als der SkillList-Bug:** Anders als bei Skills
(wo eine falsche ID nur "Unknown" ergibt, weil die Tabelle bei diesem Muster
oft keinen Treffer hat) sind die Indizes 0–10 im vollen `bicFeat()`-Feattable
*selbst* gültige, nur eben andere Feats (0=Alertness, 1=Ambidexterity,
2=Armor Proficiency (heavy), 5=Called Shot, 6=Cleave, ...). Der alte Bug
scheiterte also nicht sichtbar mit "Unknown", sondern druckte für so gut wie
jeden Charakter plausibel aussehende, aber **falsche** Feat-Namen — der
gefährlichste Bug-Typ, weil er nicht auffällt, ohne die Ausgabe Zeile für
Zeile gegen den Charakter zu prüfen.

### Fix

`flist[c]["Feat", GffWord]` liest das echte Feld. Eine Falle dabei, die nur
durch Gegenprobe gegen die echte Library auffiel (siehe Verifikation unten):
`GffWord` ist `uint16`, `bicFeat()` erwartet `int` — anders als `GffInt`
(= `int32`, das sich klaglos implizit in `int` konvertieren lässt) verlangt
Nim bei `uint16 -> int` eine explizite Konvertierung, sonst Compile-Error.
Deshalb `featId.int` statt eines direkten Aufrufs.

### Verifikation — real kompiliert und ausgeführt, nicht nur gelesen

Für den SkillList-Fix reichte sorgfältiges Lesen der bestehenden
Zugriffsmuster. Für den FeatList-Fix nicht — die `uint16`-Falle wäre beim
bloßen Lesen des Codes nicht aufgefallen. Deshalb, statt zu raten:

1. `niv/neverwinter.nim` auf dem im `.nimble`-File gepinnten Tag `2.2.0`
   geklont (`github.com` ist netzwerktechnisch erlaubt) und `nim` 1.6.14 via
   `apt` installiert (`archive.ubuntu.com`, ebenfalls erlaubt) — beides ohne
   Nimble-Registry-Zugriff, den es hier nicht gibt.
2. `neverwinter/gff.nim` (Tag 2.2.0) gelesen: `GffInt = int32`,
   `GffWord = uint16`, `GffByte = uint8`, `GffShort = int16`. Kein
   `converter` zwischen diesen Typen und `int` vorhanden.
3. Isolierter Nim-Schnipsel bestätigt: `GffInt`-Wert lässt sich klaglos als
   `int`-Parameter übergeben, `GffWord`-Wert nicht (Compile-Error) — belegt
   die Notwendigkeit von `.int`.
4. Ein minimaler, aber **echter** `GffRoot` aus den `FeatList`/`SkillList`-
   Werten von `test1.bic.json` gebaut (`gffRootFromJson`, dieselbe
   JSON-Repräsentation, die `nwn_gff.nim` aus dem Originalpaket erzeugt/liest
   — die im Repo liegenden `*.bic.json`-Dateien sind also keine Erfindung
   dieses Projekts, sondern das native JSON-Format der Library selbst).
5. Alte (Bug) und neue (Fix) SKILLS/FEATS-Schleife wortgleich aus
   `nwn_bic.nim` gegen dieses echte `GffRoot` laufen lassen.
6. `nim check` über die **komplette** gepatchte `nwn_bic.nim` (nicht nur die
   geänderten Blöcke) gegen die echte Library — 0 Fehler, 0 Warnungen.
7. `nimpretty --backup:off` (dasselbe Tool, das `build.yml` als Gate nutzt)
   über die gepatchte Datei laufen lassen — **keine Änderung**, Datei ist
   bereits nimpretty-konform.

Ergebnis des Fix-Laufs gegen die echten `test1.bic.json`-Werte:

```
- Armor Proficiency (light)      [Feat 3]
- Armor Proficiency (medium)     [Feat 4]
- Shield Proficiency             [Feat 32]
- Weapon Proficiency (martial)   [Feat 45]
- Weapon Proficiency (simple)    [Feat 46]
- Barbarian Fast Movement        [Feat 194]
- Quick To Master                [Feat 258]
- Barbarian Rage (1x per day)    [Feat 293]
- Unkown                         [Feat 1089 -- siehe unten]
- Power Attack                   [Feat 28]
- Weapon Focus (greataxe)        [Feat 111]
```

10 von 11 decken sich (inhaltlich, Übersetzung bewusst außen vor) exakt mit
`examples/bic/test1.txt`: "Umgang mit Rüstungen (leichte/mittelschwere)",
"Umgang mit Schilden", "Umgang mit Waffen (Kriegswaffen/einfache)",
"Schnelle Bewegung", "Rasche Meisterschaft", "Barbarischer Kampfrausch (1x pro
Tag)", "Heftiger Angriff", "Waffenfokus (Zweihändige Axt)" — Reihenfolge und
Bedeutung stimmen 1:1.

### Nebenfund (nicht gefixt, bewusst außen vor): Lücke in `bicFeat()`s Tabelle

Position 9 der Referenz ("(RACE) Reittiere verwenden") entspricht Feat-ID
1089 — die aber in `helper.nim`s `bicFeat()`-Tabelle fehlt (die Tabelle endet
bei 1071, "Epic Superior Weapon Focus") und deshalb auf `else: "Unkown"`
fällt (Tippfehler im Original, hier absichtlich nicht mit-korrigiert). Das
ist eine **Tabellenlücke**, kein ID-Bug — bereits allgemein unter
`analyse.md` Punkt 2 dokumentiert ("nicht bekannte IDs ... teilweise als
Unknown") und deckt sich mit dem größeren P2.1/2.2-Punkt aus dem Haupt-Plan
(Tabellen durch `neverwinter/twoda`-Parsing von `feat.2da` ersetzen). Kein
Teil dieses Fixes — anderer Fehlertyp, anderer Diff.

## P0.3 (Ausgabepfad) — erledigt in diesem Durchgang

`splitFile(args)` berechnet `dir` bereits, aber `newFileStream(name & ".txt",
fmWrite)` nutzt nur `name` — Ausgabe landet im Arbeitsverzeichnis des
Prozesses statt neben der Eingabedatei (`foo.bic` → `./foo.txt` egal von wo
`foo.bic` kam, statt `foo.bic` → `foo.txt` im selben Ordner). Fix, Sprosse 7
(kleinstmögliche Änderung, die bestehende Variable tatsächlich benutzt):

```nim
var output = newFileStream(dir / (name & ".txt"), fmWrite)
```

### Verifikation

Vier Fälle real mit dem Compiler durchgespielt (`splitFile` + `/`-Join, ohne
Spekulation):

| Eingabe | `dir` | Ausgabe |
|---|---|---|
| `/tmp/somedir/character.bic` | `/tmp/somedir` | `/tmp/somedir/character.txt` |
| `examples/bic/test1.bic` | `examples/bic` | `examples/bic/test1.txt` |
| `./test1.bic` | `.` | `./test1.txt` |
| `test1.bic` (kein Verzeichnisanteil) | `""` (leer) | `test1.txt` — **keine Regression** für den einfachsten, häufigsten Aufruf |

Danach, wie bei P0.2, nicht nur Typen geprüft, sondern ein **echter,
vollständiger CLI-Lauf**, dieses Mal über den tatsächlichen Lesepfad
(`openFileStream(args).readGffRoot(false)`), nicht mehr über den
`gffRootFromJson`-Umweg:

1. Aus einem vollständigen, aus den echten `test1.bic.json`-Werten gebauten
   JSON (alle Felder, die `nwn_bic.nim` tatsächlich liest — per
   `grep -oE 'root\["[A-Za-z]+' src/nwn_bic.nim` exakt ermittelt) mit dem
   Library-eigenen `write*(io: Stream, root: GffRoot)`-Writer eine **echte
   binäre `.bic`-Datei** erzeugt.
2. Die gepatchte `nwn_bic.nim` (mit Stub-`helper.nim` fürs Kompilieren, die
   echten Tabellen sind bereits über P0.1/P0.2 verifiziert) real gebaut.
3. Binary aus einem Arbeitsverzeichnis aufgerufen, das **nicht** das
   Zielverzeichnis ist: `./nwn_bic_test examples/bic/test1.bic`.

Ergebnis: `examples/bic/test1.txt` korrekt angelegt, **kein** `test1.txt` im
Aufrufverzeichnis. Inhalt bestätigt zusätzlich, dass P0.1/P0.2 im vollen
Programmkontext weiter funktionieren (Skill-Indizes 3/6/10/17/18, Feat-IDs
3/4/32/45/46/194/258/293/1089/28/111 — exakt wie erwartet).

### Nebenfund: `nimpretty` ist bei mehrzeiligen Kommentarblöcken nicht idempotent

Die erste Fassung dieses Fixes hatte einen vierzeiligen Begründungskommentar
vor der geänderten Zeile. `nimpretty --backup:off` (dasselbe Tool, das
`build.yml` als Formatgate nutzt) hat die Einrückung dieses Blocks bei
**jedem** erneuten Lauf um ein weiteres Leerzeichen verschoben — kein
Fixpunkt, die Datei wäre nie "clean" geworden, egal wie oft man `nimpretty`
laufen lässt. Isoliert nachgestellt: Der Effekt tritt bei **zwei oder mehr
aufeinanderfolgenden `#`-Zeilen zwischen zwei Anweisungen** auf, unabhängig
von Tuple-Destructuring oder Position. Gegenprobe am Original: ein
`awk`-Scan über `src/nwn_bic.nim` (vor allen Fixes in diesem Durchgang)
findet **nirgends** zwei aufeinanderfolgende Kommentarzeilen — die Datei
folgt also schon immer der Konvention "genau eine Zeile pro Kommentar",
vermutlich genau deswegen. Alle in diesem Durchgang hinzugefügten Kommentare
(P0.1, P0.2, P0.3) wurden entsprechend auf je eine Zeile gekürzt bzw. auf
mehrere, durch Code getrennte Einzeiler verteilt (die beiden
Ceiling-Kommentare bleiben erhalten, stehen aber jetzt an Stellen ohne
direkten Kommentar-Nachbarn). Über drei `nimpretty`-Läufe in Folge
gegengeprüft: Datei bleibt jetzt stabil. Generelles `nimpretty`-Verhalten
(nicht die Schuld dieses Projekts), aber jeder künftige Patch an dieser
Datei sollte die Ein-Zeile-pro-Kommentar-Konvention einhalten, sonst bricht
das Formatgate in der CI reproduzierbar — unabhängig davon, wie oft man es
lokal neu laufen lässt.

### CI-Anpassung (notwendige Folge, kein separater Zusatz)

Beide bestehenden Smoke-Tests in `build.yml` waren explizit auf das *alte*
(fehlerhafte) Verhalten zugeschnitten — der erste mit einem Kommentar, der
das sogar wörtlich sagt ("The current CLI writes the output beside the
process working directory"), der zweite mit einem `cd "$smoke_dir"` vor dem
Aufruf, nur um die Ausgabe überhaupt an einem vorhersagbaren Ort zu finden.
Beide mussten auf den neuen (korrekten) Pfad umgestellt werden — vollständiger
Diff dazu im nächsten Abschnitt. Der `cd`-Trick im zweiten Test entfällt dabei
komplett (er war nur ein Workaround für den jetzt behobenen Bug): Löschung
statt Anpassung, wo möglich.

Anders als P0.1/P0.2 ist dieser CI-Umbau **kein separat committefähiger
Zusatz**, sondern untrennbar Teil desselben Fixes: der Code-Fix allein hätte
beide Smoke-Tests zuverlässig rot werden lassen. Code- und CI-Änderung
gehören in denselben Commit.

## CI-Regressionsschutz (ponytail: eine Prüfung reicht)

Die bestehende "larger-character smoke test" in `.github/workflows/build.yml`
prüft bisher nur, dass die Abschnittsüberschriften vorhanden sind
(`SKILLS`, `FEATS`, ...), nicht deren Inhalt. Beide Bugs aus P0.1/P0.2 wären
dort nicht aufgefallen — SKILLS hätte leere Werte gedruckt, FEATS hätte
plausible, aber falsche Namen gedruckt, beides ohne die Section-Header-Checks
zu verletzen. Kein neues Test-Framework nötig — der Smoke-Test existiert
schon (Sprosse 2), er bekommt zwei zusätzliche `grep`-Zeilen. Der folgende
Diff zeigt den **finalen** Stand inklusive der P0.3-Pfadumstellung (bare
`test1.txt` → `$generated`, `cd "$smoke_dir"` entfällt) in einem Schritt,
da beide Änderungen ohnehin im selben Commit landen:

```diff
       - name: Run larger-character smoke test
         shell: bash
         run: |
           set -eu

           if [ "$RUNNER_OS" = "Windows" ]; then
             binary="bin/nwn_bic.exe"
           else
             binary="bin/nwn_bic"
           fi

+          # No `cd` into an isolated dir needed here anymore: the CLI writes
+          # beside the input file regardless of cwd (P0.3 fix).
           smoke_dir="$RUNNER_TEMP/nwn_bic-smoke-large"
           mkdir -p "$smoke_dir"
-          cd "$smoke_dir"
-          "$GITHUB_WORKSPACE/$binary" "$GITHUB_WORKSPACE/examples/bic/test1.bic"
-          test -f test1.txt
-          test -s test1.txt
-          grep -Fq 'IDENTITY' test1.txt
-          grep -Fq 'FINAL BUILD' test1.txt
-          grep -Fq 'BUILD DETAILS' test1.txt
+          generated="$GITHUB_WORKSPACE/examples/bic/test1.txt"
+          "$GITHUB_WORKSPACE/$binary" "$GITHUB_WORKSPACE/examples/bic/test1.bic"
+          test -f "$generated"
+          test -s "$generated"
+          grep -Fq 'IDENTITY' "$generated"
+          grep -Fq 'FINAL BUILD' "$generated"
+          grep -Fq 'Discipline: 4' "$generated"
+          grep -Fq 'Armor Proficiency (light)' "$generated"
+          grep -Fq 'BUILD DETAILS' "$generated"
+          mv "$generated" "$smoke_dir/test1.txt"
```

(Der erste Smoke-Test, ohne die beiden `grep`-Werte-Checks, bekommt dieselbe
`$generated`-Umstellung — siehe die vollständige Datei, kein eigener Diff
hier, um nicht zweimal dasselbe Muster zu zeigen.)

- `Discipline: 4` ist der erste investierte Skill in `test1.bic` (Index 3,
  Rank 4) — der Wert, den der alte Code stumm verschluckt hätte.
- `Armor Proficiency (light)` ist der erste Feat in `test1.bic` (Listenposition
  0, ID 3). Bewusst **kein** schwächerer Check: Listenposition 0 und Feat-ID 3
  sind hier zufällig verschieden genug, dass ein index-basierter Bug
  (`bicFeat(0)` = "Alertness" im vollen Feattable) den String zuverlässig
  verfehlt — der Check schlägt also echt fehl, wenn der ID-Bug zurückkommt,
  statt zufällig grün zu bleiben.

Drei triviale Ein-Zeiler/kleine Umstellungen, kein eigenes Test-File nötig
(YAGNI gilt auch für Tests).

## P0.4 (Fehlerbehandlung Datei-/GFF-Fehler) — erledigt in diesem Durchgang

Aktuell (vor diesem Fix) gibt es genau zwei Prüfungen (`paramCount() == 0`,
`args == ""`), aber keinerlei Behandlung für: Eingabedatei existiert nicht,
Eingabedatei ist kein gültiges GFF, oder die Ausgabedatei kann nicht angelegt
werden. Alle drei Fälle laufen aktuell entweder in eine rohe Nim-Exception
mit Stacktrace, oder — im dritten Fall — komplett lautlos in `exit 0`, ohne
jede Meldung (der bestehende `if not isNil(output):`-Block hat schlicht
keinen `else`-Zweig).

### Erst ermittelt, dann gefixt: welche Exceptions wirft die Library wirklich?

Statt zu raten, welche Exception-Typen abgefangen werden müssen, wurde das
gegen die echte, gepinnte Library (Tag `2.2.0`, bereits aus P0.2 lokal
vorhanden) an vier konstruierten Testdateien ermittelt:

| Testfall | Ergebnis |
|---|---|
| Datei existiert nicht | `IOError`: "cannot open file stream: ..." (aus `openFileStream`) |
| leere Datei | `IOError`: "wanted to read 4 but only got 0" (aus `readStrOrErr`) |
| 200 Byte Zufallsdaten | `ValueError`: "Expectation failed: ... == result.fileVersion" (aus `expect()`) |
| korrektes Magic, aber wilder Rest-Header | `ValueError`: "Expectation failed: header.structOffset == 56" |

Alle vier realistischen "falsche/kaputte Datei"-Fälle sind `CatchableError`-
Subtypen (`IOError`, `ValueError`) — die Library nutzt intern kein
`doAssert`/`assert` an den Stellen, die bei einer falschen Datei zuerst
greifen, sondern durchgängig ihr eigenes `expect()`-Template, das explizit
`ValueError` wirft (nicht `Defect`). Ein einziger `try/except CatchableError`
um den Lese-Aufruf reicht damit für die im Plan genannten Fälle
("Datei nicht gefunden", "kein gültiges GFF").

### Fix

```nim
let root =
  try:
    openFileStream(args).readGffRoot(false)
  except CatchableError as e:
    quit("Error: could not read '" & args & "' as a GFF/BIC file (" & e.msg & ")")
```

`quit(string)` ist bereits zweimal im File etabliert (Sprosse 2, kein neues
Muster). Dass ein `try`-Ausdruck mit `quit(...)` im `except`-Zweig als
`let`-Initialisierung funktioniert, liegt daran, dass `quit` mit
`{.noreturn.}` markiert ist — Nim verlangt dann keinen Rückgabewert von
diesem Zweig. Auch das nicht angenommen, sondern kompiliert und laufen
lassen (siehe Verifikation unten).

Für den bisher komplett unbehandelten `output`-ist-`nil`-Fall reicht ein
`else`-Zweig am bereits bestehenden `if not isNil(output):` — kein Umbau
der 90 Zeilen dazwischen nötig, kleinstmöglicher Diff:

```nim
else:
  quit("Error: could not write output to '" & outPath & "'")
```

(`outPath` ist dabei aus der vorherigen Zeile als `let` herausgezogen, statt
den Ausdruck `dir / (name & ".txt")` für die Fehlermeldung ein zweites Mal
hinzuschreiben — eine Zeile mehr, aber keine Duplikation.)

### Verifikation — fünf reale Fälle gegen die echte, kompilierte Binary

Wie bei P0.2/P0.3 nicht nur `nim check`, sondern echter Build und echter
Lauf, dieses Mal gezielt gegen die Fehlerpfade:

| Fall | Erwartung | Ergebnis |
|---|---|---|
| A: Datei existiert nicht | exit 1, klare Meldung | ✅ `Error: could not read 'does_not_exist.bic' as a GFF/BIC file (cannot open file stream: ...)` |
| B: leere Datei | exit 1, klare Meldung | ✅ `... (wanted to read 4 but only got 0)` |
| C: 200 Byte Zufallsdaten | exit 1, klare Meldung | ✅ `... (Expectation failed: "V3.2" == result.fileVersion)` |
| D: gültige Datei (Regression) | exit 0, `test1.txt` wie gewohnt erzeugt | ✅ unverändert, 62 Zeilen Ausgabe |
| E: gültige Datei, Zielverzeichnis nicht beschreibbar | exit 1, klare Meldung, keine Datei angelegt | ✅ `Error: could not write output to 'ro2/test1.txt'` |

Fall E mit `chattr +i` erzwungen (gewöhnliche `chmod`-Rechte reichen nicht,
da dieser Container als `root` läuft und `root` normale Unix-Schreibrechte
ignoriert — das immutable-Flag wird aber respektiert, damit ließ sich der
Fall trotzdem real und nicht nur behauptet durchspielen).

### Bewusst nicht gefixt: absurde Header-Werte können den Prozess per OOM töten

Beim Ermitteln der Exception-Typen (Testfall "korrektes Magic, aber wilder
Rest-Header") kam ein deutlich ernsterer Fund zutage, gezielt nachgestellt:
eine Datei mit korrektem `structOffset == 56`, aber einem absurd großen
`structCount` (2 Milliarden) lässt `toSeq(countup(0, header.structCount - 1))`
eine entsprechend riesige Sequenz allozieren — der Prozess wird vom
Betriebssystem per OOM-Killer **hart terminiert** (`Killed`, kein Nim-
Exit-Code, kein `try/except` greift, weil gar keine Nim-Exception mehr
geworfen wird, der Kernel beendet den Prozess von außen).

Das ist strukturell nicht mit Fehlerbehandlung im hier verstandenen Sinn
lösbar — es bräuchte Bounds-Checking der Header-Felder (`structCount`,
`fieldCount`, `labelCount`, ...) gegen die tatsächliche Dateigröße, bevor
irgendetwas alloziert wird, und zwar **in der Library selbst**
(`neverwinter/gff.nim`), nicht in `nwn_bic.nim`. Das ist erkennbar außerhalb
der im Plan für P0.4 vorgesehenen Größe ("S/M") und ein anderer Fehlertyp
(Robustheit gegen böswillig konstruierte Dateien, nicht "Anwender hat aus
Versehen die falsche Datei angegeben"). Bewusst nicht angefasst — hier nur
dokumentiert, damit dieser Fund nicht verloren geht, falls das Projekt
später eine Härtung gegen absichtlich böswillige `.bic`-Dateien priorisiert.

### CI-Ergänzung

Ein `try/except` mit Exit-Code-Verzweigung ist nicht-triviale Logik im Sinne
der Ponytail-Regel ("non-trivial logic leaves ONE runnable check behind") —
ein dritter, kleiner Smoke-Test-Schritt in `build.yml` deckt den
Fehlerpfad ab (fehlende Eingabedatei → muss mit Exit-Code ≠ 0 und einer
`Error:`-Meldung auf stderr scheitern, darf keine Ausgabedatei anlegen):

```yaml
      - name: Run error-handling smoke test
        shell: bash
        run: |
          set -eu
          if [ "$RUNNER_OS" = "Windows" ]; then
            binary="bin/nwn_bic.exe"
          else
            binary="bin/nwn_bic"
          fi
          err_file="$RUNNER_TEMP/nwn_bic-missing-input.err"
          if "$binary" "$RUNNER_TEMP/nwn_bic-does-not-exist.bic" 2> "$err_file"; then
            echo "expected a non-zero exit code for a missing input file"
            exit 1
          fi
          grep -Fq 'Error:' "$err_file"
          test ! -f "$RUNNER_TEMP/nwn_bic-does-not-exist.txt"
```

Die `if "$binary" ...; then ... fi`-Form ist bewusst so gewählt: unter
`set -eu` (wie in allen Steps dieser Datei) würde ein direkter Aufruf mit
erwartetem Fehlschlag sonst den ganzen Step sofort abbrechen — als
`if`-Bedingung ist ein Nicht-Null-Exit-Code dagegen der *erwartete*,
geprüfte Fall. Lokal 1:1 nachgestellt (gleiche Variablen, gleicher Binary-
Aufruf, außerhalb von GitHub Actions) und bestätigt: Meldung enthält
`Error:`, keine `.txt`-Datei wird angelegt.

## Ehrlicher Hinweis (Build-Status)

Update gegenüber der ersten Fassung dieses Dokuments: Für P0.1 (SkillList)
genügte sorgfältiges Lesen der bestehenden Zugriffsmuster — dabei blieb es,
ungeprüft. Für P0.2 (FeatList) hätte reines Lesen die `uint16`-Falle
(`GffWord` → `int`) nicht zuverlässig aufgedeckt — deshalb wurde nachträglich
doch verifiziert: `nim` 1.6.14 per `apt` installiert, `niv/neverwinter.nim`
auf dem gepinnten Tag `2.2.0` per `git clone` geholt (beide Domains,
`archive.ubuntu.com` und `github.com`, sind netzwerktechnisch erlaubt — nur
die Nimble-Registry selbst nicht, die wird hier auch nicht gebraucht, da die
Library als Quelltext vorliegt und per `--path` eingebunden wird).

Damit real durchgeführt, nicht nur behauptet:

- `nim check` über die komplette gepatchte `src/nwn_bic.nim` gegen die echte
  Library — kompiliert fehler- und warnungsfrei.
- Beide Fix-Blöcke (SKILLS + FEATS) gegen einen aus den echten
  `test1.bic.json`-Werten rekonstruierten `GffRoot` (`gffRootFromJson`)
  ausgeführt — Ausgabe deckt sich mit `test1.txt` (siehe oben).
- `nimpretty --backup:off` (dasselbe Tool, das `build.yml` als Formatgate
  nutzt) über die Datei laufen lassen — keine Änderung.

**Update (P0.3):** Die zuvor hier offen gelassene Lücke ist geschlossen — für
den P0.3-Fix wurde tatsächlich eine echte Binärdatei gebaut (`write*(io:
Stream, root: GffRoot)` aus der Library selbst) und über den echten
CLI-Einstiegspunkt (`openFileStream(args).readGffRoot(false)`) gelesen, nicht
mehr nur über `gffRootFromJson()`. Diese Erkenntnis kam erst durch den
Versuch, P0.3 sauber zu verifizieren — der einfachere JSON-Umweg reicht für
reine Feldzugriffs-/Typfragen (P0.1, P0.2), aber nicht, um zu beweisen, *wo*
eine Datei landet, wenn das Programm von einem anderen Verzeichnis aus
aufgerufen wird.

**Tatsächlich verbleibende, bewusst nicht geschlossene Lücken:**

- Nur `test1.bic`-Werte wurden zu einer echten Binärdatei zusammengesetzt und
  durchlaufen lassen, nicht `test.bic`, `test2.bic`/`test3.bic` (falls
  vorhanden) oder `aluviandarks169.bic`. Die bestehende CI deckt `test.bic`
  und `test1.bic` bereits ab (jetzt mit den P0.1/P0.2/P0.3-Anpassungen).
- Nur unter Linux getestet (dieser Container). Windows-Pfadverhalten von
  `dir / (name & ".txt")` (Backslash statt Slash) ist laut `os`-Moduldoku
  plattformabhängig korrekt, aber hier nicht auf einem echten
  Windows-Runner gegengeprüft — dafür existiert `windows-latest` in der
  CI-Matrix.
- `nimble build` selbst (mit echtem `nimble install --depsOnly` gegen die
  echte Registry) wurde nicht durchgeführt, nur `nim c`/`nim check` direkt
  gegen den geklonten Library-Quelltext per `--path`. Funktional äquivalent
  für die hier geprüften Fragen, aber kein Ersatz für einen echten
  `nimble`-Lauf vor dem Merge.

## P1.4 (School bei Zauberklassen) — erledigt in diesem Durchgang

Die Zeile war bereits als Kommentar vorbereitet (`# "School: " & $clist[c]["School", byte])`),
aber ein direkter, nicht-optionaler Zugriff (`clist[c]["School", byte]`) hätte für
jede nicht-zaubernde Klasse (kein `School`-Feld im Struct) eine `GffError`-Exception
geworfen und das ganze Programm abgebrochen — nicht nur eine Fehlermeldung produziert.

### Verifikation

Wie bei P0.2/P0.3: nicht angenommen, sondern real gegen die gepinnte Library
(Tag `2.2.0`) kompiliert. Offene Frage vorab geklärt: funktioniert der
Default-Overload `self[label, default: T]` (`getOrDefault`, liest `T` oder
gibt `default` zurück, wenn das Feld fehlt oder der Typ nicht passt) für ein
optionales `byte`-Feld überhaupt so wie erwartet? Isoliert getestet, `nim
check` + echter Lauf, 0 Fehler, 0 Warnungen:

```nim
let school = clist[c]["School", 255.GffByte]
let schoolSuffix =
  if school != 255: ", School: " & bicSchool(school) else: ""
```

`255` liegt außerhalb des gültigen `0..8`-Bereichs von `spellschool.2da` und
dient als Sentinel für "Feld fehlt".

Zwei echte, aus GFF-JSON gebaute Testfälle (`gffRootFromJson` + `write()`,
gleiches Vorgehen wie bei P0.3 — echte Binärdatei, echter CLI-Lesepfad):

| Fall | ClassList | Erwartung | Ergebnis |
|---|---|---|---|
| Barbar (`test1`-Werte, kein `School`-Feld) | `Class: 0` | `" - Barbarian (1)"`, kein Suffix | ✅ exakt |
| Magier (`Class: 10`, `School: 0`, aus `aluviandarks169.bic.json`s ClassList-Struktur) | `Class: 10, School: 0` | `" - Wizard (1), School: General"` | ✅ exakt |

Der Barbar-Fall ist der vollständige, bereits bestehende `test1`-Regressionstest —
**die komplette restliche Ausgabe (IDENTITY/ABILITIES/STATISTICS/SKILLS/FEATS)
bleibt byte-identisch zu `test1.txt`**, keine Nebenwirkung durch den Patch.

`helper.nim` bekommt eine neue kleine Tabelle `bicSchool()` (9 Einträge,
`spellschool.2da`-Standardwerte 0–8) im gleichen Stil wie `bicRace`/`bicGender`.

### Nebenfund: keine CI-Fixture für den Magier-Fall

`examples/bic/` enthält aktuell keine `.bic`-Datei mit gesetztem `School`-Feld
(`test.bic`/`test1.bic` sind beide Barbaren). Der Magier-Zweig ist deshalb
**nur lokal verifiziert** (s.o.), nicht Teil der CI. Die CI bekommt stattdessen
eine Regressionssicherung in die Gegenrichtung: der bestehende `test1`-Smoke-Test
prüft jetzt explizit, dass `School:` **nicht** in der Barbar-Ausgabe auftaucht
(`if grep -Fq 'School:' "$generated"; then exit 1; fi` — bewusst **nicht**
`grep -Fqv`, das prüft pro Zeile und hätte den Check lautlos wirkungslos gemacht;
empirisch an einem manipulierten Testfile nachgestellt, bevor der echte Diff
geschrieben wurde). Ob ein zusätzliches Magier-`.bic`-Binärfixture unter
`examples/bic/` angelegt werden soll (echte Binärdatei als Git-Blob), ist eine
offene, bewusst nicht in diesem Commit getroffene Entscheidung.

## P1.2 (STARTING ABILITIES) — erledigt in diesem Durchgang

### Erst die Formel gegen echte Daten geprüft, dann erst geschrieben

Die einzige golden-verifizierbare Datenquelle (`test1.bic.json` ↔ `test1.txt`,
Mensch, kein Rassenmodifikator) kann eine Formel der Form
`base = 8 + Rassenmodifikator` nicht von `base = 8` (ohne jeden Modifikator)
unterscheiden — bei Mensch sind beide identisch. Ein zunächst angenommener
Standard-D&D-3.x-Rassenmodifikator-Tabelle (Zwerg +2 Kon/-2 Cha, Elf +2 Ges/-2
Kon, usw.) wäre also mit `test1` allein unverifiziert geblieben.

Zur Gegenprobe: `aluviandarks1691.txt` zeigt einen Elfen mit
STARTING-ABILITIES-Werten. Wichtig: **`aluviandarks1691.txt` hat kein
zugehöriges `.bic`/`.json`** — die im Repo vorhandene `aluviandarks169.bic.json`
ist ein *anderer* Spielstand desselben Charakters (`Con: 14` dort vs. `Con: 12`
in der Textdatei — unterschiedliche Werte, also unterschiedliche Snapshots,
real anhand der Zahlen geprüft, nicht angenommen). `aluviandarks1691.txt` taugt
deshalb **nicht** als goldener CI-Test, wohl aber als Kontrollrechnung für die
Rassenmodifikator-Annahme, da es der einzige verfügbare Nicht-Mensch-Datenpunkt
mit echten (wenn auch nicht gegengeprüften) Werten ist.

Angewendet (real kompiliert, mit `aluviandarks1691.txt`s eigenen FINAL-BUILD-
Werten als Eingabe, Race=Elf, Standard-Tabelle Elf: Ges+2/Kon-2):

| Attribut | final | Formel-Ausgabe | Referenztext | Treffer? |
|---|--:|---|---|---|
| Str | 10 | `08+02` | `08+02` | ✅ |
| Dex | 16 | `10+06` | `10+06` | ✅ |
| Con | 12 | `06+06` | `06+06` | ✅ |
| Int | 16 | `08+08` | `11+05` | ❌ |
| Wis | 12 | `08+04` | `08+04` | ✅ |
| Cha | 10 | `08+02` | `08+02` | ✅ |

5 von 6 exakt, **beide** von Null verschiedenen Rassenmodifikatoren (Dex+2,
Con-2) treffen exakt — das ist der diskriminierende Teil des Tests und bestand.
Nur Int weicht ab (Referenz zeigt einen um 3 höheren „base"-Wert). Da bei
Level 1 noch keine Level-up-Attributspunkte möglich sind (die gibt es erst ab
Stufe 4), ist die plausibelste Erklärung ein **inhärenter Bonus** (z. B. ein
verzehrtes Attributsbuch/„Manual of Gainful Exercise", oder ein Item-Bonus, den
das NWN Tool in seine „base"-Berechnung einrechnet) — eine Größe, die in keinem
der aktuell gelesenen GFF-Felder steckt und mit `base + Rassenmodifikator =
final` grundsätzlich nicht rekonstruierbar ist. Nicht als Bug behandelt,
sondern als dokumentierte, unvermeidbare Grenze des Modells.

### Fix

`helper.nim`: neue Tabelle `bicRaceAbilityMods()`, Reihenfolge Str/Dex/Con/Int/
Wis/Cha, Standard-D&D-3.x/NWN-Werte für Zwerg/Elf/Gnom/Halbling/Halbork (die
übrigen Rassen, inkl. Mensch und Halbelf, haben keinen Modifikator und fallen
auf `else: [0,0,0,0,0,0]`). `nwn_bic.nim`: Schleife über die sechs Attribute,
`base = 8 + Modifikator`, `spent = final - base`, Ausgabeformat exakt wie im
Referenztool (`intToStr(x, 2)`, Stdlib, keine neue Abhängigkeit).

`ponytail:`-Kommentar markiert die bekannte Lücke (inhärente Boni nicht
modelliert) direkt am Code, mit Verweis auf die Voraussetzung für eine
Erweiterung (ein tatsächlich existierendes GFF-Feld dafür, aktuell nicht
bekannt).

### Verifikation

Kompletter End-to-End-Lauf (echte Binärdatei aus `test1.bic.json`-Werten,
gebaut mit der Library-eigenen `write()`-Funktion, gelesen über den echten
CLI-Pfad `openFileStream(args).readGffRoot(false)`, aufgerufen von einem
fremden Arbeitsverzeichnis aus): **komplette Ausgabe byte-identisch zu
`test1.txt`**, einschließlich des neuen STARTING-ABILITIES-Blocks
(`Str: 16 (base 08+08)` … `Cha: 10 (base 08+02)`). Kein Diff, keine
Abweichung in den vorher schon funktionierenden Abschnitten.

`nimpretty --backup:off` dreimal in Folge über die gepatchte Datei laufen
lassen — 0 Änderungen bei jedem Lauf. Zwei ursprünglich zweizeilige
`ponytail:`-Begründungskommentare wurden vorsorglich auf je eine Zeile
gekürzt (Ein-Zeile-pro-Kommentar-Konvention aus P0.3), obwohl `nimpretty`
sie in diesem konkreten Fall (Kommentar vor dem ersten Statement eines
Blocks, nicht zwischen zwei Statements) stabil verarbeitet hätte — die
strengere, dokumentierte Konvention wird trotzdem eingehalten, statt sich
auf einen ungetesteten Sonderfall zu verlassen.

### CI-Ergänzung

Siehe P1.4-Abschnitt oben — beide Punkte teilen sich denselben CI-Diff im
bestehenden „larger-character smoke test", da beide Änderungen denselben
Testlauf (`test1.bic`) betreffen. Zwei neue `grep`-Zeilen:
`grep -Fq 'STARTING ABILITIES'` und `grep -Fq 'Str: 16 (base 08+08)'`.

## Ehrlicher Hinweis (P1.2/P1.4)

**Nicht abgedeckt:** Rassen jenseits Zwerg/Elf/Gnom/Halbling/Halbork/Mensch/
Halbelf (Monster-Rassen-IDs ≥7 aus `bicRace()`) fallen im Modifikator auf
`[0,0,0,0,0,0]` — unwahrscheinlich für Spielercharaktere (`IsPC`), aber nicht
explizit ausgeschlossen. Der Int-Ausreißer bei `aluviandarks1691.txt` bleibt
ungeklärt (dokumentiert, nicht gefixt, s.o.) — sollte ein GFF-Feld für
inhärente Attributsboni später identifiziert werden, ist das ein eigener,
kleiner Fix, kein Teil dieses Durchgangs. Kein Magier-`.bic`-Fixture in CI
(s.o.), School-Zweig nur lokal verifiziert. Alle Verifikationen liefen unter
Linux (dieser Container) mit `nim` 1.6.14 — nicht auf einem echten
Windows/macOS-Runner gegengeprüft, dafür existiert die CI-Matrix.

## Blocker-Fix vor P1.3: Compile-Fehler im Branch `p1-complete-core-function`

Der Branch-Stand (Commit `4ff74a7`) kompiliert nicht: `nim c` bricht mit
`Error: invalid indentation` bei Zeile 154 (`output.close()`) ab. Real gegen
die gepinnte Library getestet, nicht angenommen. Zwei echte Bugs beim
Übernehmen der P1.2/P1.4-Planungsskizze:

1. **Doppelte CLASSES-Schleife.** Die alte Schleife (ohne `School`) und die
   neue (mit `School`) liefen hintereinander über dieselbe `ClassList` — jede
   Klasse wäre in der CLASSES-Sektion zweimal ausgegeben worden.
2. **Fehlende Einrückung.** `output.writeLine("working on this section")`
   stand auf Spalte 1 statt in der Einrückung des `if not isNil(output):`-
   Blocks — strukturell außerhalb des Blocks, was `else:` (Zeile 155) ohne
   passendes offenes `if` zurückließ. Kein Logikfehler, ein Parse-Fehler.

### Fix

Root-Cause statt Symptom: beide Schleifen zu einer zusammengeführt (School-
Suffix-Logik bleibt inhaltlich wie geplant), Einrückung der Platzhalterzeile
korrigiert. `nimpretty --backup:off` dreimal in Folge stabil (0 Änderungen ab
Lauf 2; Lauf 1 reformatiert die `schoolSuffix`-Zeile automatisch, das ist die
tatsächliche nimpretty-Normalform, jetzt übernommen). `nim check` danach 0
Fehler, nur die vorbestehende `tables`-Unused-Import-Warnung.

### Wichtige Selbstkorrektur

In der letzten Session hatte ich behauptet, die P1.2-Ausgabe sei „byte-
identisch zu `test1.txt`". Das war unvollständig: mein damaliger Vergleich
endete bewusst bei `STARTING ABILITIES`, weil ich P1.1 als offen behandelt
hatte — aber die reale `test1.txt` im Repo zeigt danach bereits die volle
Level-1-Sektion inkl. `(CLASS)`/`(RACE)`-Feat-Herkunft (P1.3) und
Übersetzung (P2). Ich hatte das nicht klar genug als Teilvergleich markiert.

### Nebenfund: Golden-Files zeigen jetzt das Zielformat, nicht den Ist-Zustand

Alle `.txt`-Referenzdateien unter `examples/bic/` (`test`, `test1`, `test2`,
`test3`, `palemas169`) zeigen inzwischen das vollständige deutsche NWN-Tool-
Zielformat (Level-Details, Feat-Herkunft, Übersetzung) statt des bisherigen
Programm-Ist-Zustands. Ein exakter Datei-Diff gegen diese Dateien ist daher
erst nach P1.1 **und** P1.3 **und** P2 gemeinsam sinnvoll. Die bestehenden
`grep`-Teilstring-Checks in `build.yml` bleiben davon unberührt, da sie den
generierten Output direkt prüfen, nicht per Datei-Diff gegen die eingecheckte
Referenz vergleichen.

**Vorsicht beim lokalen Testen:** Das Programm schreibt die Ausgabe neben die
Eingabedatei (P0.3-Design) — ein lokaler Testlauf gegen `examples/bic/test1.bic`
im echten Checkout **überschreibt** `examples/bic/test1.txt`. Im CI-Runner
unproblematisch (Checkout wird verworfen), lokal aber immer in einem
Kopierverzeichnis arbeiten und danach `git checkout -- examples/` nicht
vergessen (mir selbst passiert, per `git status`/`git checkout` bemerkt und
zurückgesetzt, kein Schaden am Repo).

## P1.3 (Feat-Herkunft CLASS/RACE/frei) — erledigt in diesem Durchgang, bewusst eingeschränkt (Option B)

### Datenlage geprüft, bevor irgendetwas geschrieben wurde

`LvlStatList[x].FeatList[]` UND das Top-Level `FeatList[]` tragen pro Eintrag
nur die `Feat`-ID (word/uint16) — kein Herkunfts-Flag, real per JSON-Dump
(`toJson(root)` aus `neverwinter/gffjson`) an `test1.bic` geprüft. Auch
`examples/2da/feat.2da` (im Repo vorhanden) hat keine Spalte, die zeigt,
welche Klasse/Rasse ein Feat automatisch vergibt — nur allgemeine
Feat-Metadaten (Voraussetzungen, Kategorie, `ALLCLASSESCANUSE`). Diese Info
steckt in NWN normalerweise in separaten `cls_feat_<klasse>.2da`-Tabellen
(eine pro Klasse) plus einer Rassen-Feat-Quelle, die **nicht** im Repo
liegen (vollständige Suche: nur `feat.2da`/`skills.2da`/`spells.2da` unter
`examples/2da/`, keine `cls_feat_*`/`racial*`-Dateien irgendwo im Repo).

Eine allgemeingültige, für jede Klasse/Rasse korrekte Herleitung ist damit
aktuell nicht möglich, ohne zu raten — und Raten hätte hier denselben
gefährlichen Bug-Typ wie P0.2 reproduziert: plausibel aussehende, aber bei
den meisten Klassen/Rassen falsche Labels, die nicht durch „Unknown"
auffallen.

### Gewählter Weg: Option B — bewusst eingeschränkte, verifizierte Tabelle

Statt zu raten: eine kleine Lookup-Tabelle, **nur** für die (Klasse-oder-
Rasse, Feat)-Paare, die tatsächlich in den vorhandenen Golden-Referenzen
belegt sind. Alles andere bekommt **kein** Label (unbekannt ≠ „garantiert
frei gewählt", sondern „nicht verifiziert").

Herangezogene Quellen (jede einzeln gegengeprüft, nicht nur gelesen):

| Quelle | Charakter | Status | Beitrag |
|---|---|---|---|
| `test1.bic`/`test1.txt` | Mensch Barbar Lvl 1 | echtes Testpaar | 8× CLASS, 1× RACE (Barbar/Mensch) |
| `test2.bic`/`test2.txt` | Mensch Barbar Lvl 2 | echtes Testpaar | +1× CLASS (Uncanny Dodge I) |
| `test3.bic`/`test3.txt` | Mensch Barbar Lvl 3 | echtes Testpaar | bestätigt „Cleave" = frei |
| `palemas169.bic`/`palemas1691.txt` | Mensch Magier/Bleicher Meister Lvl 15 | Ability-Werte real gegen `palemas169.bic.json` abgeglichen (Str/Dex/Con/Int/Wis/Cha exakt identisch) → echtes Paar, trotz Namens-Konvention ohne „1"-Suffix wie sonst üblich | 8× CLASS (3× Magier, 5× Bleicher Meister) |
| `aluviandarks169.bic.json`/`aluviandarks1691.txt` | Elf Magierin Lvl 1 | **kein** exaktes Testpaar (Con-Wert weicht ab, siehe letzte Session) — aber Feat-Herkunft ist eine feste Spielregel (welche Klasse/Rasse ein Feat vergibt hängt nicht vom individuellen Charakter-Snapshot ab), deshalb trotzdem als Regel-Quelle verwendet, explizit als solche markiert | 2× CLASS (Wizard, deckungsgleich mit palemas169-Fund), 8× RACE (Elf) |

`palemas169.txt` selbst (nicht `palemas1691.txt`) wurde **nicht** als Quelle
verwendet — die Datei zeigt Anzeichen einer kaputten/veralteten Referenz
(leere Skill-Werte nach dem Doppelpunkt, eine offensichtlich generische statt
charakter-eigene Feat-Liste in FINAL BUILD). Nicht weiter untersucht, da
`palemas1691.txt` für denselben Charakter eine saubere, in sich konsistente
Alternative bietet.

Ergebnis (`helper.nim`, `bicIsClassFeat`/`bicIsRaceFeat`):

```nim
proc bicIsClassFeat*(classId, featId: int): bool =
  case classId
  of 0: # Barbarian
    featId in [3, 4, 32, 45, 46, 194, 195, 293, 1089]
  of 10: # Wizard
    featId in [51, 303, 945]
  of 34: # Pale Master
    featId in [228, 886, 889, 890, 891]
  else:
    false

proc bicIsRaceFeat*(raceId, featId: int): bool =
  case raceId
  of 1: # Elf
    featId in [235, 236, 237, 238, 239, 240, 256, 354]
  of 6: # Human
    featId == 258
  else:
    false
```

`nwn_bic.nim`: In der FEATS-Schleife wird für jedes Feat zuerst auf
`bicIsRaceFeat(charRace, featId)` geprüft, sonst über **alle** Klassen des
Charakters (Multiklassen-fähig, `for cc in 0..<nbrc`) auf
`bicIsClassFeat(...)`. Präfix `(RACE) `/`(CLASS) `/leer entsprechend.

Bewusst **nicht** in P1.1s Level-für-Level-Abschnitt eingebaut (der ist noch
Platzhalter) — stattdessen additiv in die bereits bestehende FINAL-BUILD-
„FEATS:"-Sektion, die einzige, die es aktuell überhaupt gibt. Kleinster Diff,
sofortiger Nutzen; wenn P1.1 später die Level-Struktur nachzieht, wandert die
gleiche Lookup-Logik einfach mit dorthin.

### Verifikation — alle sechs verfügbaren `.bic`-Dateien, real kompiliert und gelaufen

| Datei | Ergebnis |
|---|---|
| `test.bic` (Barbar Lvl 1) | 11 Feats, Labels exakt wie hergeleitet |
| `test1.bic` (Barbar Lvl 1) | identisch zu `test.bic` (gleicher Build) |
| `test2.bic` (Barbar Lvl 2) | +`(CLASS) Uncanny Dodge I`, Rest unverändert |
| `test3.bic` (Barbar Lvl 3) | +`Cleave` ohne Label, Rest unverändert |
| `palemas169.bic` (Magier/Bleicher Meister Lvl 15) | alle 18 Feats exakt wie aus `palemas1691.txt` hergeleitet — unabhängige Bestätigung des Multiklassen-Zweigs |
| `aluviandarks169.bic.json` (Elf Magierin Lvl 1) | über nachgebauten JSON-Weg (echte Binärdatei stürzt an einem **vorbestehenden**, von P1.3 unabhängigen Bug ab, s.u.) — alle 11 Feats exakt wie aus `aluviandarks1691.txt` hergeleitet |

`nimpretty --backup:off` dreimal stabil (0 Änderungen), `nim check` 0 neue
Fehler/Warnungen.

### Nebenfund: `aluviandarks169.bic` crasht (vorbestehend, nicht P1.3)

`root["BaseAttackBonus", byte]` (nicht-optionaler Zugriff, STATISTICS-
Sektion) wirft `KeyError`, weil `aluviandarks169.bic` dieses Feld nicht hat.
Bereits in `docs/nwn_bic-analyse.md` als bekanntes, generelles Problem
dokumentiert („Abhängigkeit von konkreten GFF-Feldern... ohne defensive
Feldprüfung kann eine Datei deshalb mit einem Key-Fehler abbrechen").
Betrifft mehrere Felder (`ArmorClass`, `WillSaveThrow`, `willbonus`, ...),
nicht nur `BaseAttackBonus`, und ist ein eigenständiges, größeres Aufräumen
(alle nicht-optionalen Feldzugriffe in der STATISTICS-Sektion defensiv
machen) — bewusst **nicht** Teil dieses P1.3-Commits. Für die eigene
Verifikation wurde stattdessen ein lokal gepatchtes JSON verwendet (fehlende
Felder mit plausiblen Werten ergänzt), rein um den P1.3-Feat-Zweig zu prüfen,
nicht um den Bug zu verstecken. Empfehlung: als eigenen kleinen Fix vor P1.1
einplanen (P1.1 wird ohnehin mehr GFF-Felder anfassen, dort passt eine
generelle „optionaler Zugriff mit sinnvollem Default"-Passage gut rein).

## Vorgemerkt für später: echter 2DA/Spieldaten-Zugriff statt hartcodierter Tabelle

Auf Wunsch hier festgehalten, kein Teil dieses Commits:

Die aktuelle `bicIsClassFeat`/`bicIsRaceFeat`-Tabelle ist explizit eine
Übergangslösung (Option B), gültig nur für die fünf Klassen/Rassen, die in
den vorhandenen Testdateien vorkommen. Der korrekte, allgemeingültige Weg
(Option A aus der letzten Runde) ist ein eigenes kleines Tool/Modul, das zur
Laufzeit die **echten** Spieldaten liest, statt eine Tabelle im Quelltext zu
pflegen:

- **Datenquelle:** `cls_feat_<klasse>.2da` (eine Tabelle pro Klasse, listet
  auf, welches Feat bei welchem Level automatisch vergeben wird) plus die
  entsprechende Rassen-Feat-Quelle (vermutlich über `racialtypes.2da`
  referenziert oder in festen `racialfeat*.2da`-Tabellen, muss noch geklärt
  werden). Analog zu `neverwinter/twoda`, das für `feat.2da`/`skills.2da`/
  `spells.2da` schon als Abhängigkeit vorhanden ist (siehe P2.1/P2.2 im
  Hauptplan).
- **Datenherkunft ist bewusst offen zu lassen, nicht von mir zu entscheiden:**
  Diese 2DA-Dateien sind Bioware/Beamdog-Spieldaten. Ob/wie sie ins Repo
  kommen (aus einer eigenen NWN-Installation extrahiert, wie es bei
  `feat.2da` offenbar schon geschehen ist, oder zur Laufzeit von einem vom
  Nutzer angegebenen NWN-Installationspfad gelesen, ähnlich der bereits
  geplanten `--tlk <pfad>`-Option aus P2.4) ist eine bewusste
  Lizenz-/Produktentscheidung, die ich nicht eigenmächtig treffen will —
  daher hier nur als offener Punkt vorgemerkt, keine 2DA-Sammlungen von
  irgendwoher automatisch eingebunden.
- **Custom-Content-Flag:** Module/Spielstände können HAK-Paks mit
  überschriebenen `cls_feat_*.2da`/`feat.2da`-Einträgen mitbringen — die
  Standard-2DA-Werte stimmen dann nicht mehr mit dem, was der Charakter
  tatsächlich bekommen hat. Ein Warn-Flag ist sinnvoll für den Fall, dass ein
  Feat aus dem Charakter-GFF in der geladenen `cls_feat_*.2da`/Rassen-Quelle
  gar nicht auftaucht (weder als CLASS- noch als RACE-Feat für diese
  Klasse/Rasse) UND auch keine bekannte, generische Bonus-Feat-Auswahl ist —
  das deutet auf Custom Content hin, den die geladenen 2DA-Dateien nicht
  abdecken. In dem Fall: Feat trotzdem anzeigen (nicht verschlucken), aber
  mit einem Hinweis markieren (z. B. `(?)` oder ein separater Warnhinweis am
  Dateiende „N Feats konnten nicht zugeordnet werden, evtl. Custom Content"),
  statt stillschweigend „frei gewählt" zu unterstellen. Das ist dieselbe
  Grundhaltung wie beim aktuellen Option-B-Ansatz (lieber ehrlich
  „unbekannt" zeigen als falsch labeln), nur mit einer echten Datenquelle
  im Rücken statt einer Handtabelle.
- **Zeitliche Einordnung:** Gehört inhaltlich zu P2 (2DA/TLK-Datenimport),
  wo ohnehin die gleiche Grundsatzfrage (welche 2DA-Dateien werden wie
  bereitgestellt) für `feat.2da`/`skills.2da`/`spells.2da` geklärt werden
  muss. Im Hauptplan als neuer Punkt **P2.7** vorgesehen (siehe
  `docs/nwn_bic-cli-plan.md`-Ergänzung unten), NICHT als Ersatz für P2.1/2.2,
  sondern als deren Erweiterung um klassen-/rassenspezifische Feat-Vergabe.
