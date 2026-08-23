# Plan: Vervollständigung des `nwn_bic`-CLI-Programms

Stand: 18. August 2026 (Plan) · **Update 20. August 2026: P0 (0.1–0.4) vollständig umgesetzt · Update 23. August 2026: P1 (1.1–1.4) vollständig umgesetzt**
Basis: Code-Review von `dunahan/nwn_bic` (main) + Abgleich mit der Lazy-Coding-Leiter aus `DietrichGebert/ponytail`

> **Status-Update:** Alle vier P0-Punkte sind gefixt, jeweils real gegen die
> gepinnte `neverwinter.nim`-Library (Tag `2.2.0`) kompiliert und ausgeführt,
> nicht nur gelesen. Vollständige Herleitung, jede verworfene/korrigierte
> Annahme und alle Testfälle: `docs/nwn_bic-cli-plan-status.md`. Dieses
> Dokument bekommt hier nur die Kurzfassung je Punkt, damit der ursprüngliche
> Plan als Nachschlagewerk erhalten bleibt statt dupliziert zu werden.

---

## 1. Kurzfassung

`build.yml` baut jetzt zuverlässig auf allen drei Plattformen und führt sogar einen Smoke-Test aus – gute Basis. Das CLI selbst (`src/nwn_bic.nim` + `src/helper.nim`) war zum Zeitpunkt dieser Analyse noch ein Prototyp: Die IDENTITY- und ABILITIES-Abschnitte funktionierten, SKILLS und FEATS lasen den falschen Wert aus dem GFF (Schleifenindex statt echter ID), und BUILD DETAILS war ein Platzhalter.

> **Update:** SKILLS- und FEATS-Bug sind gefixt (P0.1/P0.2), ebenso der
> Ausgabepfad (P0.3) und die Fehlerbehandlung (P0.4). Details unten in
> Abschnitt 5 und im Status-Dokument. BUILD DETAILS ist weiterhin ein
> Platzhalter – das ist P1.1, noch offen.

Der zweite, überraschend ergiebige Befund: **`helper.nim` ist mit 3671 Zeilen zu 90 % eine Übersetzungstabelle** (`bicFeat`: Zeilen 220–2277, `bicSpell`: Zeilen 2278–3671), die von Hand aus dem 1.69-Regelwerk abgetippt wurde – fest verdrahtet auf Englisch, mit `Unknown` als Fallback. Im Repo liegen unter `examples/2da/` (`feat.2da`, `skills.2da`, `spells.2da`) und `examples/tlk/{de,en}/` aber bereits genau die Originaldaten, aus denen diese Tabellen stammen – inklusive fertiger deutscher Übersetzung. Die Projektabhängigkeit `neverwinter` (schon in `nwn_bic.nimble`) bringt mit `neverwinter/twoda` und `neverwinter/tlk` fertige Parser für genau diese Formate mit.

> **Update:** Beim P0.2-Fix wurde diese Tabellenlücke praktisch bestätigt –
> Feat-ID 1089 (aus `test1.bic`) fehlt in `bicFeat()`s Tabelle und fällt auf
> `else: "Unkown"` zurück (Tippfehler im Original, bewusst nicht mit-
> korrigiert). Ein konkreter, realer Beleg dafür, dass P2.1 kein
> theoretisches Aufräumen ist, sondern schon an einer einzigen Testdatei
> sichtbar wird.

Das ist exakt der Fall, für den `ponytail` steht: Sprosse 5 der Leiter ("*already-installed dependency solves it*") schlägt hier zwei bis drei ganze Sprossen höher aus als das aktuell verbaute "vollständig neu geschriebene Sonderlösung"-Muster. Der größte Hebel für dieses Projekt ist daher nicht neuer Code, sondern **Löschen**: ~3400 Zeilen Tabellen raus, ~150 Zeilen datengetriebenes Lookup rein – und die Ausgabe wird nebenbei automatisch mehrsprachig und korrekt.

---

## 2. Ist-Zustand in Kürze

| Bereich | Status |
|---|---|
| IDENTITY (Name, Rasse, Geschlecht, Alter, Beschreibung) | funktioniert, aber LocString-Parsing per String-Slicing (`delete(s, ...find(s,'"')...)`) statt über `GffCExoLocString.entries` |
| CLASSES | funktioniert für die Endstufe |
| ABILITIES | funktioniert |
| STATISTICS | funktioniert überwiegend; `ArmorClass`/`NaturalAC`-Zugriff laut Kommentar im Code selbst als unsicher markiert ("works for 1.69 but not for EE?") |
| SKILLS | ✅ **P0.1 gefixt.** War kein ID-Bug (Position im Array *ist* die Skill-ID, deckt sich mit `bicSkill()`), sondern: `Rank` wurde nie gelesen und nie auf `> 0` gefiltert. Jetzt: nur investierte Skills, mit Wert. |
| FEATS | ✅ **P0.2 gefixt.** War ein echter ID-Bug: `FeatList`-Einträge tragen ihre eigene ID im `Feat`-Feld (word/uint16), der Code nutzte den Schleifenindex. Gefährlicher als der SKILLS-Bug, weil er nicht sichtbar mit "Unknown" scheiterte, sondern plausible, aber falsche Feat-Namen druckte. |
| BUILD DETAILS | ✅ **P1.1 gefixt.** Level-für-Level (Klasse via `LvlStatClass`, Trefferwürfel, Skillpunkte, Feats mit `(CLASS)`/`(RACE)`-Herkunft, Attributssteigerung via `LvlStatAbility`), empirisch gegen `test2`/`test3`/`palemas169` verifiziert. Bewusste Abweichung vom externen Referenztext bei „Skills:" (echte Werte statt des dort fehlerhaft immer gezeigten „None"), dokumentiert im Status-Doc. |
| Ausgabepfad | ✅ **P0.3 gefixt.** `dir` wird jetzt tatsächlich benutzt (`dir / (name & ".txt")`); beide CI-Smoke-Tests mussten mitgezogen werden, da sie explizit auf dem alten (fehlerhaften) Verhalten aufbauten. |
| Fehlerbehandlung | ✅ **P0.4 gefixt.** `try/except CatchableError` um Datei-Öffnen + GFF-Parsing (deckt "Datei nicht gefunden" und "kein gültiges GFF" ab), `else`-Zweig für den bisher stillen `output`-ist-`nil`-Fall. Bewusst **nicht** abgedeckt: eine Datei mit plausiblem Header, aber absurdem `structCount` kann den Prozess per OOM-Kill beenden – das ist kein Nim-Exception-Pfad und keine "S/M"-Aufgabe mehr, sondern Bounds-Checking in der Library selbst. Dokumentiert, nicht gefixt. |
| Sprache | Codeausgabe komplett Englisch, Referenzdateien (`*1.txt`, aus "NWN Tool") komplett Deutsch – keine Umschaltung vorgesehen |
| Tests | keine; `examples/bic/*.bic` + zugehörige `.txt`/`.json` liegen aber bereits als perfekte Golden-Files bereit |
| CI (`build.yml`) | ✅ funktioniert (Matrix, `nimpretty`-Check, Build, **drei** Smoke-Tests: Basis-Charakter, Charakter mit SKILLS/FEATS-Werten, Fehlerpfad seit P0.4) |
| CI (`release.yml`) | weiterhin veraltet (`ubuntu-18.04`, `actions/*@v1`/`@v2`, kein Test vor dem Release) – nicht Teil dieses Plans, aber vorgemerkt |

Die vollständige, ältere Tiefenanalyse dazu liegt bereits in `docs/nwn_bic-analyse.md` und bleibt inhaltlich gültig; dieser Plan verdichtet sie zu Prioritäten und ergänzt die ponytail-Perspektive.

---

## 3. Referenzformat (Zielbild)

Aus `examples/bic/aluviandarks1691.txt` und `palemas1691.txt` (Export eines externen "NWN Tool") lässt sich das Zielformat ableiten:

```
IDENTITY  → Name, Rasse, Geschlecht, Alter, Beschreibung, Subrasse, Gottheit
FINAL BUILD
  CLASSES  → inkl. "School:" bei Zauberklassen
  ABILITIES
  STATISTICS → Trefferpunkte, RK, Wille/Zäh./Reflex
  SKILLS   → nur tatsächlich vorhandene Skills, mit Punktwert
BUILD DETAILS
  STARTING ABILITIES → Basis + Punktekauf-Aufschlüsselung ("base 08+08")
  je Level: Klasse, Trefferwürfel, Skillpunkte dieser Stufe, Feats dieser Stufe
            mit Herkunft: (CLASS) / (RACE) / frei gewählt
```

Alle benötigten Rohdaten dafür liegen im GFF selbst (`ClassList`, `SkillList`, `FeatList` – vermutlich inkl. eines Level-Historie-Feldes wie `LvlStatList`, das noch nicht ausgewertet wird) sowie in `feat.2da` / `skills.2da` / `spells.2da` + TLK für die Klartext-Übersetzung.

---

## 4. Ponytail-Leiter, angewendet auf `nwn_bic`

Die Leiter aus `ponytail` (Stop an der ersten passenden Sprosse):

1. Muss das existieren? (YAGNI)
2. Gibt es das schon im Repo?
3. Kann Stdlib das?
4. Kann eine Plattform-/Bordfunktion das?
5. Kann eine bereits installierte Abhängigkeit das?
6. Passt es in eine Zeile?
7. Erst dann: das Minimum, das funktioniert.

Angewendet:

| Baustelle im Code | Sprosse | Konsequenz |
|---|---|---|
| 3400 Zeilen Feat-/Spell-Tabellen in `helper.nim` | **5** – `neverwinter/twoda` ist bereits Abhängigkeit, `examples/2da/*.2da` liegen bereits im Repo | Tabellen durch Laufzeit-Parsing ersetzen statt pflegen |
| Deutsche Referenzausgabe vs. hart kodiertes Englisch | **5** – `neverwinter/tlk` + `examples/tlk/{de,en}` bereits vorhanden | Namen über TLK-StrRef auflösen statt zweite Tabelle von Hand schreiben |
| LocString wird per String-Slicing zerschnitten | **2/3** – `GffCExoLocString.entries` ist bereits Teil der genutzten `neverwinter/gff`-API | direkten Feldzugriff nutzen, kein eigener Parser |
| CLI-Argumente (`--output`, `--language`, `--tlk`) | **3** – `std/parseopt` ist Stdlib | keine neue CLI-Bibliothek (kein `cligen` o. Ä.) einführen |
| Tests gegen Referenzdateien | **3** – `std/unittest` ist Stdlib, Golden-Files liegen schon vor | kein Testframework nachziehen |
| Rasse/Geschlecht/Klasse/Gesinnung (~10–40 stabile Einträge) | **1** – lohnt sich (noch) nicht zu dynamisieren | bewusst hart kodiert lassen, aber zweisprachig (siehe P2.3) |
| Level-für-Level-Historie | **2** – Daten stecken vermutlich schon im GFF (`ClassList`/Levelfelder) | erst prüfen, was das GFF hergibt, bevor etwas "berechnet" wird |

Grundsatz für die Umsetzung: keine ungefragten Abstraktionen (kein Plugin-System für "später mehr Formate"), kürzester Diff, der das Problem tatsächlich löst – aber erst nachdem die GFF-Struktur (`test1.bic.json` etc.) wirklich gelesen wurde, nicht geraten.

---

## 5. Priorisierte Liste

### P0 – Korrektheit der bestehenden Ausgabe (Blocker) — ✅ vollständig erledigt

| # | Aufgabe | Warum zuerst | Aufwand | Status |
|---|---|---|---|---|
| 0.1 | **SkillList-Bug fixen:** `Skill`-ID + Rang aus jedem `SkillList`-Struct lesen statt Schleifenindex `c` | aktuell falsche/leere Werte, Kernversprechen des Tools gebrochen | S | ✅ **Erledigt.** Annahme korrigiert: kein ID-Feld vorhanden, Position *ist* die ID. Echter Bug war das fehlende `Rank`-Lesen + fehlende `> 0`-Filterung. Gegen `test1.bic.json`-Referenzwerte verifiziert (Discipline/Listen/Parry/Spot/Taunt = 4/4/4/2/4), deckt sich 1:1 mit `test1.txt`. |
| 0.2 | **FeatList-Bug fixen:** `Feat`-ID aus jedem `FeatList`-Struct lesen statt Schleifenindex `c` | zeigt aktuell komplett falsche Feats an | S | ✅ **Erledigt.** Hier stimmte die Plan-Annahme: echter ID-Bug. Falle dabei: `Feat` ist `GffWord` (uint16), konvertiert anders als `GffInt` **nicht** implizit zu `int` – `.int` nötig, sonst Compile-Error. Real gegen die gepinnte Library (Tag `2.2.0`) kompiliert und mit einer aus `test1.bic.json` gebauten echten GFF-Struktur gegengeprüft: 10 von 11 Feats decken sich mit `test1.txt`; die eine Abweichung (ID 1089) ist die oben erwähnte Tabellenlücke in `bicFeat()`, kein Teil dieses Fixes. |
| 0.3 | **Ausgabepfad korrigieren:** `foo.bic` → `foo.txt` im selben Verzeichnis wie die Eingabe (`dir`-Variable wird schon berechnet, aber nicht benutzt) | Minimal-Fix, kein neuer Code nötig (Sprosse 7) | S | ✅ **Erledigt.** `dir / (name & ".txt")`. Mit einer aus JSON gebauten *echten* Binär-`.bic` end-to-end über den tatsächlichen CLI-Lesepfad getestet (nicht nur den JSON-Umweg). Beide bestehenden CI-Smoke-Tests bauten explizit auf dem alten Verhalten auf (einer sogar mit einem Kommentar, der das wörtlich sagt) und mussten mitgezogen werden – kein optionaler Zusatz, sondern Teil desselben Commits. Nebenfund: `nimpretty` ist bei ≥2 aufeinanderfolgenden Kommentarzeilen nicht idempotent; alle Fix-Kommentare halten sich deshalb an "eine Zeile pro Kommentar", wie es die Datei schon vorher tat. |
| 0.4 | **Fehlerbehandlung für Datei-/GFF-Fehler:** Datei nicht gefunden, kein gültiges GFF, `output`/`root` ist `nil` → verständliche Meldung + Exit-Code statt Absturz | verhindert unlesbare Nim-Stacktraces bei Anwendern | S/M | ✅ **Erledigt.** Empirisch ermittelt statt geraten: die Library wirft für alle realistischen "falsche Datei"-Fälle `IOError`/`ValueError` (`CatchableError`), kein `doAssert`/`Defect` – ein `try/except CatchableError` reicht. Fünf reale Fälle gegen die kompilierte Binary durchgespielt (fehlende Datei, leere Datei, Zufallsmüll, gültige Datei, nicht beschreibbares Zielverzeichnis via `chattr +i`). **Bewusst offen gelassen:** ein Header mit plausiblem Magic, aber absurdem `structCount` bringt den Prozess per OOM-Kill zu Fall – kein Nim-Exception-Pfad, `try/except` kann das strukturell nicht lösen. Wäre Bounds-Checking in `neverwinter/gff.nim` selbst, klar außerhalb der "S/M"-Größe. |

Vollständige Herleitung, verworfene Zwischenstände und alle Testkommandos: `docs/nwn_bic-cli-plan-status.md`.

### P1 – Kernfunktion vervollständigen

| # | Aufgabe | Warum | Aufwand |
|---|---|---|---|
| 1.1 | `BUILD DETAILS` implementieren: Level-für-Level (Klasse, Trefferwürfel, Skillpunkte, Feats), auf Basis dessen, was tatsächlich im GFF steckt (`test1.bic.json` als Referenz für die Feldnamen nehmen, nicht raten) | einziger noch komplett fehlender Abschnitt, Kernzweck laut README | M/L | ✅ **Erledigt.** `LvlStatList[i]` = Charakterlevel `i+1`, empirisch bestätigt (nicht angenommen): `LvlStatClass` trägt die echte Klassen-ID (multiklassen-fähig, real an `palemas169.bic` verifiziert), `SkillList`/`FeatList` pro Level sind inkrementell, nicht kumulativ (additiv geprüft gegen die finale Top-Level-Liste). Feat-Herkunft nutzt die P1.3-Tabelle, jetzt präziser (Level-Klasse bekannt, keine Schleife über alle Klassen nötig). Bewusste Abweichung: zeigt echte Skillpunkte pro Level statt des im externen Referenztool fehlerhaft immer gezeigten „None". Volle Herleitung: `docs/nwn_bic-cli-plan-status.md`. |
| 1.2 | `STARTING ABILITIES` mit Punktekauf-Aufschlüsselung (`base 08+08`) ergänzen | Teil des Referenzformats, direkt neben 1.1 sinnvoll | S | ✅ **Erledigt.** `base = 8 + Rassenmodifikator`. Formel gegen `aluviandarks1691.txt` kontrollgerechnet (kein exaktes Testpaar, s. Status-Doc): 5/6 exakt inkl. beider Elfen-Modifikatoren, Int-Abweichung dokumentiert (vermutlich inhärenter Bonus, nicht modellierbar). |
| 1.3 | Feat-Herkunft kennzeichnen: `(CLASS)` / `(RACE)` / frei gewählt, wie in `aluviandarks1691.txt` | ohne Herkunft ist die Feat-Liste für den eigentlichen Zweck (Levelaufbau nachvollziehen) wenig aussagekräftig | M | ✅ **Erledigt, bewusst eingeschränkt (Option B).** Kleine Lookup-Tabelle `bicIsClassFeat`/`bicIsRaceFeat` in `helper.nim`, nur für (Klasse/Rasse, Feat)-Paare verifiziert gegen `test1`/`test2`/`test3`/`palemas169`/`aluviandarks169` (Barbar, Mensch, Magier, Bleicher Meister, Elf). Unbekannte Paare bleiben ohne Label statt geraten. Kein GFF-Feld und keine 2DA-Tabelle im Repo kodiert diese Info direkt — echte, allgemeingültige Lösung braucht `cls_feat_<klasse>.2da` + Rassen-Feat-Quelle, siehe neuer Punkt **P2.7**. Volle Herleitung: `docs/nwn_bic-cli-plan-status.md`. |
| 1.4 | `CLASSES`: `School:`-Zusatz bei Zauberklassen ergänzen (Code-Kommentar dazu existiert schon, ist nur auskommentiert) | im Referenzformat vorhanden, im Code bereits vorbereitet | S | ✅ **Erledigt.** Optionaler Feldzugriff (`clist[c]["School", 255.GffByte]`, Sentinel 255) real verifiziert. Kein CI-Fixture mit gesetztem `School`-Feld zum Zeitpunkt der Implementierung, inzwischen durch `palemas169.bic` (Magier/Bleicher Meister) abgedeckt. |

### P2 – Ponytail-Vereinfachung: Daten statt Handarbeit

| # | Aufgabe | Warum | Aufwand |
|---|---|---|---|
| 2.1 | `bicFeat`/`bicSpell`-Tabellen (Zeilen 220–3671 in `helper.nim`) durch `neverwinter/twoda`-Parsing von `feat.2da` / `spells.2da` ersetzen (Spalte `Label` bzw. `FEAT`-/`Name`-StrRef) | größter Hebel im Repo: ~3200 Zeilen weniger Code, kein manuelles Nachpflegen bei neuen Feats/Spells mehr | M |
| 2.2 | `skills.2da` ebenso einbinden (kleine Tabelle, aber gleiche Logik – lohnt sich, weil sonst zwei Mechanismen parallel existieren) | Konsistenz: eine Lookup-Strategie für alle drei Listen | S |
| 2.3 | `neverwinter/tlk` einbinden, um StrRefs aus 2.1/2.2 in Klartext aufzulösen; `--language de|en`-Option (Default an lokal gefundenem TLK oder `en`) | ersetzt die Notwendigkeit zweier Tabellen (DE/EN) durch eine Datenquelle; macht die Ausgabe automatisch mehrsprachig | M |
| 2.4 | Pfad zum TLK-Verzeichnis/zur `dialog.tlk` konfigurierbar machen (`--tlk <pfad>`), da Anwender die Originaldatei aus ihrer NWN-Installation mitbringen müssen (75 MB, gehört nicht ins Repo/Release) | Lizenz-/Größenproblem vermeiden, Konvention wie bei `nwn_tlk`/`nwn_gff` aus `neverwinter.nim` selbst | S |
| 2.5 | Rasse/Geschlecht/Klasse/Gesinnung bewusst weiter als kleine, hart kodierte DE/EN-Tabelle behandeln (kein 2DA-Anschluss) | ~10–40 stabile Einträge, Aufwand für Dynamisierung steht in keinem Verhältnis (YAGNI, Sprosse 1) | – |
| 2.6 | `GffCExoLocString.entries` statt String-Slicing für Vor-/Nachname und Beschreibung nutzen | robuster, weniger Code, nutzt vorhandene API statt eigenem Parser | S |
| 2.7 | Feat-Herkunft (`(CLASS)`/`(RACE)`) datengetrieben statt hartcodiert: `cls_feat_<klasse>.2da` pro Klasse + eine Rassen-Feat-Quelle zur Laufzeit lesen, ersetzt die in P1.3 bewusst eingeschränkte Handtabelle (`bicIsClassFeat`/`bicIsRaceFeat`). Warn-Flag für Feats, die in keiner geladenen Klassen-/Rassen-Tabelle auftauchen (Hinweis auf Custom-Content/HAK-Überschreibungen statt stiller Falsch-Zuordnung). Datenherkunft (eigene NWN-Installation vs. `--data-path`-Option analog zu 2.4) ist eine bewusste, noch offene Entscheidung, keine automatische Übernahme fremder 2DA-Sammlungen. | löst die in P1.3 dokumentierte Lücke sauber, gleiche Grundsatzfrage wie 2.1/2.2 (welche 2DA-Dateien, welche Quelle) | M |

### P3 – Robustheit & Ergonomie

| # | Aufgabe | Warum | Aufwand |
|---|---|---|---|
| 3.1 | `--output <pfad>` und `--language de|en` über `std/parseopt` (Stdlib) statt Positionsparameter-only | kleine, stabil benötigte Optionen, keine neue Abhängigkeit nötig | S |
| 3.2 | Regressionstests mit `std/unittest` gegen `examples/bic/*.bic` + zugehörige `.txt` (Golden-Files, liegen schon vor) | nutzt vorhandenes Material, verhindert Rückfälle bei 2.1–2.4 | M |
| 3.3 | `nimble test`-Task in `nwn_bic.nimble` ergänzen und in `build.yml` aufrufen | schließt die CI-Lücke, die in `docs/nwn_bic-analyse.md` schon benannt ist | S |

### P4 – Später / optional (nicht Teil dieser Runde)

- `release.yml` modernisieren (analog zu `build.yml`: aktuelle Actions, macOS arm64, Smoke-Test vor dem Packen) – bewusst zurückgestellt, bis das CLI selbst stabil ist.
- `--json-debug`-Option für die rohe GFF-Struktur.
- Ausrüstungs-/Inventarabschnitt, Zauberbuch-Abschnitt.
- Weitere Sprachen über zusätzliche TLK-Dateien (Infrastruktur aus 2.3/2.4 trägt das bereits).

---

## 6. Empfohlene Reihenfolge

```
P0 (0.1–0.4) ✅  →  P1 (1.1–1.4) ✅  →  P2 (2.1–2.7)  →  P3 (3.1–3.3)  →  P4
   erledigt          erledigt           nächster
                                          Schritt
```

P0 zuerst, weil alles Weitere (insbesondere die Regressionstests in P3) auf korrekten Werten aufbaut – das war die Prämisse und ist erfüllt: `test1.bic` liefert reale, verifizierte Werte für SKILLS und FEATS, landet am richtigen Pfad, und Datei-/GFF-Fehler brechen nicht mehr mit Stacktrace ab. Mit P1.1 (Level-für-Level) ist jetzt auch sichtbar, wie viele Feat-/Spell-Namen tatsächlich pro Level gebraucht werden – der Umbau auf 2DA/TLK (P2) lohnt sich jetzt erst recht, weil er sonst an halbfertigem Code vorbeigeplant worden wäre. Der bereits real beobachtete Tabellenlücken-Fund bei P0.2 (Feat-ID 1089 → "Unkown") ist ein zusätzliches, konkretes Argument für P2.1 – nicht mehr nur theoretisch. Der bei P1.3 gefundene Datenlücken-Fund (keine `cls_feat_*.2da`/Rassen-Feat-Quelle im Repo) ist das gleiche Argument für den neuen Punkt P2.7.

**Kurzfassung des größten Einzeleffekts:** Punkt 2.1–2.4 bedeutet netto **Code löschen** (rund 3200 von 3671 Zeilen in `helper.nim` fallen weg) bei gleichzeitig **mehr** Funktionsumfang (automatische DE/EN-Übersetzung statt einer hart kodierten Sprache). Das ist der Kern dessen, was `ponytail` mit "*already-installed dependency solves it*" meint – hier lässt sich das wörtlich am eigenen Repo nachweisen, weil die Rohdaten (`examples/2da`, `examples/tlk`) bereits vorliegen.
