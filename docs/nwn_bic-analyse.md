# Analyse von `dunahan/nwn_bic`

## Kurzfassung

`nwn_bic` ist derzeit ein kleines Kommandozeilenprogramm in **Nim**, das eine Neverwinter-Nights-Spielerdatei (`.bic`) als GFF-Datei einliest und daraus eine lesbare Textdatei erzeugt. Der aktuelle Schwerpunkt liegt auf einer groben Darstellung des finalen Charakterzustands. Die geplante Endfunktion — eine vollständige, zuverlässige Durchanalyse der BIC-Datei einschließlich des Level-für-Level-Buildverlaufs und einer gleichnamigen Textausgabe — ist noch nicht umgesetzt.

## Technischer Stand

- Sprache: Nim, laut `nwn_bic.nimble` mindestens Nim `1.6.4`.
- Paketname und Version: `nwn_bic`, Version `0.1.1`.
- Abhängigkeit: das Nim-Paket `neverwinter` ab Version `1.4.2`, insbesondere dessen GFF-Unterstützung.
- Einstiegspunkt: `src/nwn_bic.nim`.
- Hilfsfunktionen und Tabellen für Übersetzungen/Zuordnungen: `src/helper.nim`.
- Geplanter bzw. dokumentierter Aufruf:

```bash
nwn_bic test.bic
```

Die README beschreibt das Programm als CLI-Werkzeug, das aus einer BIC-Datei eine lesbare Textdatei mit dem Levelaufbau eines Charakters erzeugen soll.

## Was das Programm derzeit kann

### Eingabe und Ausgabe

1. Es nimmt einen Dateipfad als erstes Kommandozeilenargument entgegen.
2. Es öffnet die angegebene Datei als GFF-Datei über `readGffRoot(false)`.
3. Es ermittelt den Dateinamen ohne Pfad und Endung.
4. Es schreibt eine Datei mit dem Namen `<Dateiname>.txt`.

Beispiel: `examples/bic/test.bic` führt konzeptionell zu `test.txt` im aktuellen Arbeitsverzeichnis, nicht automatisch zu `examples/bic/test.txt`.

### Bereits ausgelesene bzw. ausgegebene Werte

Der aktuelle Code versucht, folgende Daten aus dem BIC-GFF zu lesen und auszugeben:

- Vorname und Nachname
- Rasse
- Geschlecht
- Alter
- Beschreibung
- Subrace/Subrasse
- Gottheit
- Klassen und Klassenstufen aus `ClassList`
- Attribute: Stärke, Geschicklichkeit, Konstitution, Intelligenz, Weisheit und Charisma
- Gesinnung
- Erfahrungspunkte
- maximale Trefferpunkte
- Base Attack Bonus
- natürliche und aktuelle Rüstungsklasse
- Willens-, Zähigkeits- und Reflexwurf einschließlich Bonuswerten
- Skill-Liste
- Feat-Liste

Die Zuordnung numerischer Werte erfolgt in `helper.nim`, unter anderem für Rassen, Geschlechter, Klassen, Gesinnungen, Skills und Feats. Nicht bekannte IDs werden teilweise als `Unknown` ausgegeben.

### Aktuelles Ausgabeformat

Die Textausgabe ist in Abschnitte gegliedert:

- `IDENTITY`
- `FINAL BUILD`
  - `CLASSES`
  - `ABILITIES`
  - `STATISTICS`
  - `SKILLS`
  - `FEATS`
- `BUILD DETAILS`

Die Beispieldatei `test.txt` zeigt, dass Identität, finale Klasse, Attribute und einige Statistikwerte bereits ausgegeben werden können. Die Dateien mit der Endung `1.txt`, etwa `test1.txt` oder `aluviandarks1691.txt`, zeigen dagegen ein deutlich umfangreicheres Ziel-/Vergleichsformat mit übersetzten Werten, Skills und einem Level-für-Level-Abschnitt.

## Was aktuell noch fehlt oder fehleranfällig ist

### 1. Der Build-Verlauf ist nicht implementiert

Der Abschnitt `BUILD DETAILS` schreibt derzeit lediglich:

```text
working on this section
```

Damit wird der eigentliche Zweck — nachvollziehbar zu zeigen, wie der Charakter über die einzelnen Level aufgebaut wurde — noch nicht erfüllt.

### 2. Skills werden nur als Namen, nicht als Werte ausgegeben

Der Code iteriert über `SkillList`, verwendet aber den Schleifenindex für die Namensauflösung und schreibt keinen aus der jeweiligen Struktur ausgelesenen Skillwert. Das Ergebnis enthält daher nicht zuverlässig die tatsächlichen Skillpunkte.

### 3. Feats werden nicht aus der BIC-Struktur gelesen

Ähnlich wird über `FeatList` iteriert, aber `bicFeat(c)` erhält den Schleifenindex statt der konkreten Feat-ID aus der jeweiligen GFF-Struktur. Dadurch sind die ausgegebenen Feats nicht zuverlässig die tatsächlich im Charakter vorhandenen Feats.

### 4. Sprach- und Ausgabevarianten sind nicht konsistent

Die aktuelle Implementierung in `src/nwn_bic.nim` verwendet englische Bezeichnungen wie `Human`, `Male`, `Barbarian` und `Hit Points`. Die Vergleichsdateien aus dem Ordner `examples/bic` zeigen teilweise eine deutsche Ausgabe, etwa `Mensch`, `Männlich`, `Barbar` und `Trefferpunkte`. Eine explizite Lokalisierungsstrategie oder Sprachoption ist derzeit nicht erkennbar.

### 5. Abhängigkeit von konkreten GFF-Feldern

Einige Felder werden mit festen Typen und festen Namen gelesen. Im Quelltext ist bereits vermerkt, dass Felder wie `ArmorClass` in unterschiedlichen NWN-Versionen bzw. BIC-Dateien nicht immer vorhanden oder zugänglich sind. Ohne defensive Feldprüfung kann eine Datei deshalb mit einem Key-Fehler abbrechen.

### 6. LocString-Verarbeitung ist fragil

Vorname, Nachname und Beschreibung werden aktuell durch String-Manipulation aus der Darstellung eines `GffCExoLocString` herausgeschnitten. Robuster wäre es, die LocString-Struktur über die Bibliothek auszulesen und Sprachvarianten gezielt zu behandeln.

### 7. Eingabevalidierung und Fehlermeldungen sind unvollständig

Es gibt zwar eine Meldung für fehlende Argumente, aber keine erkennbare systematische Prüfung für:

- nicht vorhandene Dateien
- falsche Dateiendung
- ungültige oder beschädigte GFF-Dateien
- fehlende Pflichtfelder
- nicht unterstützte BIC-Varianten
- Fehler beim Erzeugen oder Schreiben der Ausgabedatei

### 8. Zielpfad der Ausgabe ist nicht eindeutig

Die Ausgabedatei wird aus dem reinen Namen gebildet und im aktuellen Prozessverzeichnis angelegt. Für die gewünschte Bedienung sollte ausdrücklich festgelegt werden, ob die Datei:

- neben der Eingabe-BIC,
- im aktuellen Arbeitsverzeichnis oder
- in einem per Option angegebenen Zielordner

entstehen soll. Die naheliegendste Erwartung ist `foo.bic` → `foo.txt` im selben Ordner.

### 9. Keine sichtbaren automatisierten Tests

Im Repository sind Beispiele und Build-Workflows vorhanden, aber für das eigentliche Parsing und Rendering der BIC-Daten ist kein belastbarer Testbestand erkennbar. Gerade die vorhandenen BIC/JSON/Text-Paare eignen sich sehr gut als Golden-File- bzw. Regressionstests.

## Bedeutung der Beispiele in `examples/bic`

Der Ordner enthält mehrere nützliche Vergleichsgruppen:

| Gruppe | Vorhandene Dateien | Zweck |
|---|---|---|
| `test` | `test.bic`, `test.bic.json`, `test.txt` | Kleines Minimalbeispiel und aktueller Output |
| `test1` | `test1.bic`, `test1.bic.json`, `test1.txt` | Vollständigerer Charakter mit erwartetem Detailformat |
| `test2` | `test2.bic`, `test2.bic.json`, `test2.txt` | Weiterer Vergleichsfall |
| `test3` | `test3.bic`, `test3.bic.json`, `test3.txt` | Weiterer Vergleichsfall |
| `aluviandarks169` | BIC, JSON und `aluviandarks169.txt` | NWN-1.69-Beispiel mit englischer Ausgabe im aktuellen Format |
| `aluviandarks1691` | keine gleichnamige BIC/JSON-Datei, aber Textdatei | Referenz-/Sollausgabe aus dem NWN Tool |
| `palemas169` | BIC, JSON und zwei Textvarianten | Großes 1.69-Beispiel und Soll-/Ist-Vergleich |

Die JSON-Dateien sind als lesbare Zwischenrepräsentationen der BIC-Inhalte wertvoll. Sie sollten jedoch nicht stillschweigend als primäre Eingabe des Programms verwendet werden: Das Endziel ist das direkte Parsen der originalen binären `.bic`-Datei. Die JSON-Dateien eignen sich vor allem zur Untersuchung der tatsächlichen Feldnamen, Datentypen und verschachtelten Strukturen.

## Empfohlenes Zielbild

### Bedienung

```bash
nwn_bic path/to/Charakter.bic
# erzeugt: path/to/Charakter.txt
```

Sinnvolle spätere Optionen wären beispielsweise:

```bash
nwn_bic Charakter.bic --output Charakter.txt
nwn_bic Charakter.bic --language de
nwn_bic Charakter.bic --language en
nwn_bic Charakter.bic --json-debug
```

### Verarbeitungspipeline

1. CLI-Argumente und Pfade validieren.
2. BIC-Datei binär öffnen.
3. GFF-Root sicher einlesen.
4. Pflichtfelder und BIC-Version erkennen.
5. LocStrings, primitive Felder und Listen typisiert auslesen.
6. Fehlende optionale Felder mit einem definierten Platzhalter behandeln.
7. IDs über zentrale Tabellen in Namen übersetzen.
8. Klassenliste, Skill-Liste und Feat-Liste aus den jeweiligen Struct-Feldern auswerten — nicht aus dem Schleifenindex.
9. Attribute, Trefferpunkte, AC, Saves, BAB, Erfahrung und Gesinnung berechnen bzw. ausgeben.
10. Den Build-Verlauf aus den tatsächlich vorhandenen Level-/Klasseninformationen rekonstruieren.
11. Eine formatierte Textdatei neben der Eingabedatei schreiben.
12. Fehler mit verständlicher Meldung und passendem Exit-Code melden.

## Empfohlene Implementierungsschritte

### Phase 1: Stabilisierung des bestehenden Parsers

- Ausgabeziel auf den Eingabepfad beziehen.
- Datei-, GFF- und Feldfehler sauber behandeln.
- Typ- und Feldzugriffe in kleine sichere Hilfsfunktionen kapseln.
- LocString nicht mehr per String-Slicing extrahieren.
- Schreibfehler prüfen.

### Phase 2: Korrekte finale Charakterdaten

- `ClassList` anhand der echten Feldwerte lesen.
- Skill-ID und Skill-Rang aus jedem `SkillList`-Struct lesen.
- Feat-ID aus jedem `FeatList`-Struct lesen.
- Ausgabefehler wie `Aligment` korrigieren bzw. aus Kompatibilitätsgründen bewusst dokumentieren.
- Englische und deutsche Bezeichner in getrennten Mappingtabellen organisieren.

### Phase 3: Build-Details

- Prüfen, welche Level- und Klassenfelder in den BIC-Beispielen vorhanden sind.
- Startattribute und Attributssteigerungen ableiten.
- Pro Level Klasse, Trefferwürfel, Skillpunkte und Feats ausgeben.
- Klassen-, Rassen- und allgemeine Feats unterscheiden.
- Zauber, Spezialfähigkeiten, Ausrüstung und weitere optionale Daten nur als eigene klar gekennzeichnete Erweiterungen aufnehmen.

### Phase 4: Regressionstests

Für jede Beispielgruppe sollte ein Test mindestens prüfen:

- Charaktername
- Rasse und Geschlecht
- Anzahl und Namen der Klassen
- Klassenstufen
- Attribute
- Trefferpunkte
- Skills und Werte
- Feats
- Vorhandensein des Abschnitts `BUILD DETAILS`
- Ausgabe am erwarteten Zielpfad

Ein vollständiger Textvergleich gegen eine Referenzdatei ist möglich, sollte aber wegen Übersetzungen, Reihenfolge und Formatänderungen durch strukturierte Assertions ergänzt werden.

## Definition of Done für das gewünschte Endergebnis

Die Funktion ist fertig, wenn für jede unterstützte BIC-Datei gilt:

- Die originale `.bic` wird direkt eingelesen.
- Eine gleichnamige `.txt` wird im definierten Zielordner erzeugt.
- Die Identität des Charakters wird korrekt ausgegeben.
- Alle Klassen und Klassenstufen werden aus den echten BIC-Daten übernommen.
- Skills erscheinen mit ihren tatsächlichen Werten.
- Feats erscheinen mit ihren tatsächlichen IDs/Namen.
- Finale Attribute und zentrale Kampf-/Rettungswurfwerte werden ausgegeben.
- Der Build-Verlauf enthält echte Leveldaten und nicht nur einen Platzhalter.
- Fehlende optionale Felder führen nicht zu einem unverständlichen Absturz.
- Die vorhandenen Beispiele dienen als automatisierte Regressionstests.

## Prüfung der GitHub-Workflows

Das Repository enthält zwei Workflows: `build.yml` und `release.yml`.

### `build.yml`

Der Workflow ist als grundlegender CI-Workflow gedacht und verwendet eine Betriebssystem-/Nim-Versionsmatrix. Er prüft derzeit jedoch nicht den eigentlichen Build von `nwn_bic` und führt auch keine Tests des BIC-Parsers aus.

#### Positives

- Windows, Linux und macOS sind grundsätzlich als Zielplattformen vorgesehen.
- Mehrere Nim-Versionen sollen abgedeckt werden.
- Die Nim- und Nimble-Version werden ausgegeben.
- Der Workflow läuft bei Pushes und Pull Requests.

#### Kritische Probleme

1. **Falsche Testaktion:** Statt das Repository mit `nimble build` oder `nimble test` zu bauen, installiert der Workflow `nimjson` und führt `nimjson -h` aus. Damit wird weder `nwn_bic` kompiliert noch der Parser getestet.
2. **Lokale Action nicht erkennbar:** `uses: ./` setzt eine lokale GitHub Action im Repository-Root voraus. In der aktuellen Repository-Struktur ist keine passende `action.yml`/`action.yaml` im Root erkennbar. Der Schritt dürfte daher scheitern oder zumindest nicht das erwartete Nim-Setup leisten.
3. **Branch-Mismatch:** Der Push-Trigger ist auf `master` beschränkt, während das Repository laut aktueller Ansicht den Branch `main` verwendet. Pushes auf `main` lösen diesen Teil daher nicht aus.
4. **Veraltete Action-Versionen:** `actions/checkout@v3` ist nicht mehr zeitgemäß.
5. **Kein echter Test:** Es gibt keinen Aufruf des Programms mit einer Beispieldatei aus `examples/bic` und keine Prüfung der erzeugten Textdatei.
6. **Keine Artefaktprüfung:** Es wird kein plattformabhängiges Binary erzeugt, hochgeladen oder gestartet.
7. **Matrix deckt die Projektanforderung nicht sauber ab:** Die Nimble-Datei verlangt Nim `>= 1.6.4`, während die Matrix `1.0.0`, `stable` und `devel` verwendet. Eine alte Version kann das Projekt nicht unterstützen; `devel` kann unnötig instabil sein.

**Bewertung:** Als CLI-CI für dieses Projekt ist `build.yml` derzeit nicht sinnvoll. Er muss durch einen tatsächlichen Build-/Test-Workflow ersetzt werden.

### `release.yml`

Der Release-Workflow wird bei jedem Tag ausgelöst und versucht, Linux-, Windows- und macOS-ZIP-Dateien zu bauen und an einen GitHub Release anzuhängen.

#### Positives

- Linux und Windows werden grundsätzlich als Releaseziele berücksichtigt.
- Windows wird für 32 Bit und 64 Bit vorgesehen.
- macOS wird separat gebaut.
- Die erzeugten Dateien werden zu Release-Assets gepackt.
- Der Workflow soll automatisch einen Draft-Release anlegen.

#### Kritische Probleme und Risiken

1. **Veraltete Runner:** `ubuntu-18.04` ist als GitHub-Runner nicht mehr zukunftssicher und kann inzwischen nicht mehr verfügbar sein.
2. **Veraltete Actions:** `checkout@v2`, `cache@v2`, `upload-artifact@v2`, `download-artifact@v2`, `create-release@v1` und `upload-release-asset@v1` sollten ersetzt werden.
3. **Keine macOS-Architekturabdeckung:** Es wird nur ein `macosx.amd64`-Artefakt erzeugt. Apple-Silicon-Systeme benötigen entweder ein natives `arm64`-Binary oder ein Universal-Binary.
4. **Manuelle Nim-Installation ist fragil:** Nim wird aus festen Download-URLs geladen. Es fehlen Integritätsprüfung, robuste Pfadbehandlung und eine moderne Setup-Action.
5. **Cross-Compilation ist unvollständig:** Für Windows wird MinGW installiert, aber die tatsächliche Verfügbarkeit und Kompatibilität der benötigten Bibliotheken wird nicht im Zielsystem geprüft.
6. **DLL-Paketierung ist zu breit:** `dlls.zip` wird offenbar vollständig in das Windows-Artefakt kopiert. Das kann unnötige DLLs enthalten; außerdem wird nicht sichergestellt, dass alle benötigten Laufzeitbibliotheken tatsächlich enthalten sind.
7. **Statische Builds sind nicht für alle Ziele abgesichert:** Die Nimble-Aufgaben definieren zwar Optionen für Windows und macOS, der Release-Workflow ruft diese Tasks aber nicht konsistent auf. Für Linux wird schlicht `nimble build -d:release` verwendet.
8. **Keine Tests vor dem Release:** Vor dem Verpacken wird das erzeugte Programm nicht mit `examples/bic/*.bic` ausgeführt. Ein Release kann daher erfolgreich gebaut werden, obwohl der Parser nicht funktioniert.
9. **Keine Prüfung des erzeugten Binärnamens bzw. der Plattform:** Es wird pauschal über `bin/*` gepackt. Das kann Zusatzdateien, falsche Endungen oder ungewollte Bibliotheken einschließen.
10. **Release-Berechtigungen fehlen explizit:** Moderne Workflows sollten `permissions: contents: write` setzen und mit einem aktuellen Release-Mechanismus arbeiten.
11. **Tag-Validierung fehlt:** Jeder beliebige Tag löst einen Release-Versuch aus. Sinnvoller wäre eine Konvention wie `v*` sowie eine Prüfung, ob Tag und Paketversion zusammenpassen.

**Bewertung:** Die Absicht ist richtig, aber der Workflow ist in der aktuellen Form nicht zuverlässig genug für reproduzierbare Releases eines Windows/Linux/macOS-CLI-Tools. Besonders macOS arm64, moderne Runner/Actions, echte Tests und eine robuste Nim-Toolchain fehlen.

## Empfohlene CI/CD-Struktur

### 1. CI auf Pull Requests und `main`

Eine moderne CI sollte:

- `actions/checkout@v4` verwenden.
- Nim über eine gepflegte Setup-Action oder reproduzierbar per Version installieren.
- die vom Projekt geforderte Nim-Version testen, mindestens Nim `1.6.4` bzw. die tatsächlich unterstützte Version.
- `nimble install -d` bzw. `nimble install --depsOnly -Y` ausführen.
- `nimble build -d:release` ausführen.
- `nimble test` ausführen, sobald Tests vorhanden sind.
- jede Beispiel-BIC mit dem erzeugten Binary verarbeiten.
- prüfen, dass jeweils eine passende `.txt` entsteht und zentrale erwartete Werte enthält.
- den Build in einer Matrix für `ubuntu-latest`, `windows-latest` und `macos-latest` ausführen.

Beispiel für den Kernschritt:

```yaml
- name: Build
  run: nimble build -d:release

- name: Smoke test
  shell: bash
  run: |
    ./bin/nwn_bic examples/bic/test.bic
    test -f test.txt
```

Für Windows muss der Pfad bzw. die Endung über `${{ runner.os }}` oder einen plattformneutralen Testschritt angepasst werden.

### 2. Release-Matrix

Für Releases sollten mindestens folgende Ziele definiert werden:

| Ziel | Empfehlung |
|---|---|
| Linux x86_64 | natives Build auf `ubuntu-latest` |
| Windows x86_64 | natives Build auf `windows-latest` oder validierte Cross-Compilation |
| macOS x86_64 | natives Build auf passendem macOS-Runner |
| macOS arm64 | natives Build auf passendem arm64-Runner, sofern verfügbar |
| macOS universal | optionales Zusammenführen von x86_64 und arm64 mit `lipo` |
| Windows i386 | nur behalten, wenn dieses Ziel wirklich benötigt und getestet wird |

Jedes Artefakt sollte enthalten:

- das Binary mit plattformgerechter Endung
- eine kurze README mit Aufrufbeispiel
- Lizenzdatei
- optional Checksums, zum Beispiel SHA-256

### 3. Validierung vor dem Packen

Vor dem Upload sollte jeder Job:

1. das Binary bauen,
2. `--help` bzw. den Aufruf ohne Argument testen,
3. mindestens `examples/bic/test.bic` und einen größeren Charakter verarbeiten,
4. die Ausgabedatei prüfen,
5. das Archiv erzeugen,
6. eine SHA-256-Prüfsumme schreiben.

### 4. Release-Erstellung

Statt der alten `create-release`-/`upload-release-asset`-Kombination sollte ein aktueller Release-Schritt verwendet werden. Der Release-Job sollte die Artefakte aus den Build-Jobs laden und bei Tags der Form `v*` einen Release mit den fertigen Archiven und Checksums erzeugen. Für reproduzierbare Releases sollte die Paketversion aus `nwn_bic.nimble` mit dem Tag abgeglichen werden.

## Gesamtbewertung

Das Repository besitzt bereits einen funktionierenden Prototypen für das Öffnen einer BIC-GFF und das Erzeugen eines lesbaren Grundgerüsts. Die Mappingfunktionen und Beispieldateien bilden eine gute Basis. Der wichtigste nächste Schritt ist jedoch nicht die Erweiterung einzelner Ausgabetexte, sondern eine saubere, typisierte Auswertung der Listenstrukturen (`ClassList`, `SkillList`, `FeatList`) sowie die Rekonstruktion des Build-Verlaufs. Erst danach erfüllt das Programm die im Projekt beschriebenen Erwartungen zuverlässig.

Die vorhandenen Workflows unterstützen dieses Ziel derzeit nur unzureichend: `build.yml` testet faktisch nicht das Nim-Projekt, und `release.yml` ist technisch veraltet und deckt moderne macOS-Systeme sowie verlässliche Smoke-Tests nicht ab. Nach einer Überarbeitung können sie jedoch zu einer soliden plattformübergreifenden CI/CD-Pipeline ausgebaut werden.
