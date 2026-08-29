# Plan: Modernisierung von `release.yml`

Stand: 23. August 2026
Basis: Code-Review von `.github/workflows/release.yml` (main) + Abgleich mit
dem bereits modernisierten `.github/workflows/build.yml`, `nwn_bic.nimble`
und `nim.cfg`. Ergänzt die bestehende Tiefenanalyse in
`docs/nwn_bic-analyse.md` (Abschnitt "release.yml") um eine priorisierte,
ponytail-geleitete Umsetzungsliste. Kein Ersatz für diese Analyse, sondern
ihre Fortsetzung — genau wie `nwn_bic-cli-plan.md` zu `nwn_bic-analyse.md`
steht.

> Dieser Plan war bereits als P4-Punkt in `docs/nwn_bic-cli-plan.md`
> vorgemerkt ("`release.yml` modernisieren ... bewusst zurückgestellt, bis
> das CLI selbst stabil ist"). Das CLI ist jetzt stabil (P0+P1 erledigt),
> daher eigener Plan statt eines Unterpunkts im Hauptplan — anderer Umfang,
> andere Baustelle (CI/CD, nicht der Parser selbst).

**Wichtig: reine Planung.** Dieses Dokument beschreibt, was zu tun ist, es
ändert noch keine Datei. Umsetzung erst nach Freigabe, dann analog zum
CLI-Plan mit einem eigenen Status-Dokument (`nwn_bic-release-plan-status.md`),
das jeden Schritt real gegen einen Tag-Push verifiziert, bevor er als
erledigt markiert wird.

---

## 1. Kurzfassung

`release.yml` ist, wie der Name im Auftrag schon andeutet, ein **Prototyp,
kein funktionierender Workflow**. Bei einem echten Tag-Push in der jetzigen
Fassung würde er nicht "schlecht" releasen, sondern **gar nicht erst
starten**: Der Runner `ubuntu-18.04` existiert nicht mehr, und selbst wenn er
existierte, würde die gepinnte Nim-Version `1.6.4` an der eigenen
`nwn_bic.nimble`-Anforderung (`requires "nim >= 2.0.0"`) scheitern. Das sind
keine Modernisierungswünsche, sondern Blocker — der Workflow ist seit dem
letzten `build.yml`-Umbau (Nim-2.0-Umstellung, GCC-14-Fix, moderne Actions)
nicht mitgezogen worden.

Der zweite, größere Befund: **die Lösung für das Windows-DLL-Problem liegt
bereits ungenutzt im Repo.** `nwn_bic.nimble` deklariert schon einen `win`-
Task mit `--passL:-static --dynlibOverrideAll` — ein statisch gelinktes
Windows-Binary, das gar keine DLLs bräuchte. `release.yml` ruft diesen Task
nie auf, baut stattdessen von Hand mit rohem `nimble build -d:mingw` und
kopiert danach ungefiltert ein komplettes `dlls.zip` (SDL/MySQL/Postgres-
Client-Libs und mehr, die `nwn_bic` nie braucht) ins Artefakt. Sprosse 2 der
Ponytail-Leiter ("bereits im Repo vorhanden") schlägt hier fast wörtlich zu.

---

## 2. Ist-Zustand im Detail

| Bereich | Befund | Schwere |
|---|---|---|
| Runner `ubuntu-18.04` (`build-linux-win`, `release`) | Image seit Jahren aus GitHub Actions entfernt, Jobs starten nicht | **Blocker** |
| `NIMVER: "1.6.4"` | Widerspricht `nwn_bic.nimble`s `requires "nim >= 2.0.0"`; `build.yml` löst das längst über `vars.NIM_VERSION` | **Blocker** |
| Fehlender GCC-14-Workaround bei `nimble install --depsOnly -y` | `build.yml` hat den Fix (`--passNim:"--passC:-Wno-error=incompatible-pointer-types"`) bereits für exakt dieses Problem (docopt.nim.c) — `release.yml` nie nachgezogen | **Blocker** (Windows-Ziele) |
| `create-release@v1` / `upload-release-asset@v1` | Von GitHub selbst als veraltet markiert, kein aktives Maintenance mehr | Hoch |
| Fehlt: `permissions: contents: write` | `GITHUB_TOKEN` kann je nach Repo-Voreinstellung ohne diesen Block keine Releases anlegen | Hoch |
| `actions/checkout@v2`, `cache@v2`, `upload-/download-artifact@v2` | `build.yml` ist bereits bei `checkout@v7`/`cache@v6` | Mittel |
| Kein Smoke-Test vor dem Packen | `build.yml` hat vier reale Smoke-Tests (Basis, Großcharakter, Fehlerpfad, fehlendes Feld) — `release.yml` prüft das gebaute Binary nie | Hoch |
| Kein Tag/Version-Abgleich | Jeder beliebige Tag löst einen Release-Versuch aus, unabhängig vom `version`-Feld in `nwn_bic.nimble` | Mittel |
| Windows via mingw-Cross-Compile von `ubuntu-18.04` aus | Fragiler Pfad; `dlls.zip` wird komplett hineinkopiert statt gezielt; **der bereits vorhandene `win`-Nimble-Task mit `--passL:-static` würde das Problem strukturell lösen** | Hoch |
| Kein macOS arm64 | Nur `macosx.amd64`; Apple-Silicon-Nutzer bekommen kein natives Binary | Niedrig (kein bekannter Bedarf) |
| macOS-Build kompiliert Nim komplett aus Quellcode (`build.sh` + `koch boot`) | Funktioniert, aber ~10x langsamer als `jiro4989/setup-nim-action@v2`, das `build.yml` schon nutzt | Mittel |
| Windows i386-Ziel | Kein dokumentierter Bedarf im Repo erkennbar (YAGNI, Sprosse 1) | Niedrig — Entscheidung nötig |
| `win`/`macos`-Tasks in `nwn_bic.nimble` | Deklariert, aber von `release.yml` nie aufgerufen — Duplikat-Logik statt Wiederverwendung | Mittel |
| Keine Checksums | Kein `sha256sum` der Release-Artefakte | Niedrig |
| Tag-Trigger `push: tags: '*'` | Jeder Tag löst aus, keine `v*`-Konvention | Niedrig |

Vollständige, noch ausführlichere Detailkritik (inkl. aller einzelnen
veralteten Action-Versionen) bereits in `docs/nwn_bic-analyse.md` unter
"release.yml" — hier bewusst nicht dupliziert, nur priorisiert und mit
konkretem Fix-Ansatz versehen.

---

## 3. Ponytail-Leiter angewendet

| Baustelle | Sprosse | Konsequenz |
|---|---|---|
| Windows-DLLs | **2** — `win`-Nimble-Task existiert bereits (`--passL:-static`) | Task aufrufen statt neu erfinden; DLL-Zip-Schritt komplett streichen |
| macOS-Build-Tooling | **2/5** — `setup-nim-action` ist bereits in `build.yml` bewährt | gleiche Action wiederverwenden, kein Nim-Source-Build mehr |
| Release-Erstellung | **4** — `gh` CLI ist auf jedem GitHub-Actions-Runner vorinstalliert | `gh release create`/`gh release upload` statt Drittanbieter-Actions; keine neue Abhängigkeit |
| Checksums | **3** — `sha256sum` ist Standard-Unix-Tool | ein Einzeiler pro Artefakt |
| Tag/Version-Abgleich | **6/7** — ein `grep`/`if`-Zweizeiler reicht | kein neues Skript, kein Node-Tooling wie im Ponytail-Projekt selbst nötig |
| Windows i386 | **1** — YAGNI, bis Bedarf belegt ist | streichen, es sei denn Tobias bestätigt einen Anwendungsfall |
| macOS arm64 | **1** — kein bekannter Bedarf | zurückstellen, nicht vergessen (P2-Punkt, nicht P0/P1) |

---

## 4. Priorisierte Liste

### P0 — Blocker (Release-Workflow ist aktuell nicht lauffähig)

| # | Aufgabe | Warum zuerst |
|---|---|---|
| 0.1 | `runs-on: ubuntu-18.04` überall durch `ubuntu-latest` ersetzen | ohne diesen Fix startet kein Job |
| 0.2 | `NIMVER` auf dieselbe Version wie `build.yml`s `vars.NIM_VERSION` (≥2.0.0) heben, oder direkt dieselbe Repo-Variable referenzieren statt eines eigenen hartkodierten Werts | sonst Versionskonflikt mit `nwn_bic.nimble` |
| 0.3 | `jiro4989/setup-nim-action@v2` statt manueller Nim-Installation/-Kompilierung für **alle** Plattformen übernehmen (identisch zu `build.yml`) | löst 0.1/0.2 strukturell mit, spart die komplette manuelle Download-/Cache-Logik, ein Werkzeug für beide Workflows |
| 0.4 | GCC-14-Workaround (`--passNim:"--passC:-Wno-error=incompatible-pointer-types"`) bei jedem `nimble install --depsOnly` ergänzen | identisches, bereits gelöstes Problem wie in `build.yml`; ohne den Fix bricht `docopt.nim.c` auf aktuellen Runnern |
| 0.5 | `permissions: contents: write` auf Job- oder Workflow-Ebene setzen | `GITHUB_TOKEN` braucht das explizit für Release-Erstellung |

Ohne P0 lässt sich der Workflow nicht einmal testen — das ist die
Voraussetzung für alles Weitere, genau wie P0 im Hauptplan Voraussetzung
für P1 war.

### P1 — Robustheit vor dem nächsten echten Release

| # | Aufgabe | Warum |
|---|---|---|
| 1.1 | Windows-Build auf den bereits vorhandenen `nimble win`-Task umstellen (`-d:mingw --passL:-static --dynlibOverrideAll`) statt Handbau + `dlls.zip` | statisch gelinktes Binary braucht keine DLL-Paketierung — löst das größte Windows-Risiko strukturell, nicht kosmetisch |
| 1.2 | macOS-Build auf `setup-nim-action` umstellen (Sprosse 2, siehe 0.3) statt `build.sh`/`koch boot` | 10x schneller, ein Werkzeug für beide Workflows, weniger Wartungsfläche |
| 1.3 | Smoke-Test vor dem Packen: dieselben Prüfungen wie in `build.yml` (mindestens `test.bic` + `test1.bic`, IDENTITY/FINAL BUILD/BUILD DETAILS-Marker) pro gebautem Binary ausführen | ein Release, das nie ausgeführt wurde, ist reine Hoffnung; Wiederverwendung der bereits geschriebenen Checks (Sprosse 2), kein neues Test-Framework |
| 1.4 | `actions/checkout@v7`, `actions/cache@v6` (Versionsgleichstand mit `build.yml`) | ein gepflegter Versionsstand für beide Workflows, keine zwei Wahrheiten |
| 1.5 | `create-release@v1`/`upload-release-asset@v1` ersetzen — Empfehlung: `gh release create <tag> --draft <dateien...>` über die im Runner vorinstallierte GitHub CLI, keine dritte Action nötig (Sprosse 4) | archivierte Actions ohne Garantie für Fortbestand; `gh` ist nativ vorhanden |

### P2 — Qualität/Ergonomie

| # | Aufgabe | Warum |
|---|---|---|
| 2.1 | ✅ `sha256sum` je Artefakt erzeugen und mit hochladen | Erledigt 2026-08-24, real erzeugt und mit `sha256sum -c` gegengeprüft |
| 2.2 | ✅ Tag-Trigger auf `v*` beschränken | Erledigt 2026-08-24 |
| 2.3 | ✅ Tag-gegen-Version-Check, harter Fehlschlag bei Mismatch | Erledigt 2026-08-24, Regex und Vergleichslogik real gegen beide Richtungen getestet |
| 2.4 | ✅ Windows i386-Ziel streichen, sofern kein belegter Bedarf | Entschieden 2026-08-24: gestrichen, bereits mit P1 umgesetzt |
| 2.5 | ✅ README + LICENSE ins jeweilige Artefakt-Zip aufnehmen | Erledigt 2026-08-24 |
| 2.6 | ✅ `win`/`macos`-Nimble-Tasks als einzige Quelle nutzen | Erledigt 2026-08-24 — deckte dabei einen echten Fehler in P1 auf, s. `nwn_bic-release-plan-status-p2.md` |

### P3 — Später / optional

| # | Aufgabe | Warum zurückgestellt |
|---|---|---|
| 3.1 | macOS arm64 (nativ oder Universal-Binary via `lipo`) | kein bekannter Bedarf, GitHub bietet inzwischen native arm64-Runner (`macos-14`+) — technisch machbar, aber ohne Anfrage kein Aufwand wert (YAGNI) |
| 3.2 | ✅ Release Notes automatisch aus Commits/CHANGELOG generieren | Nebeneffekt erledigt: `--generate-notes` kam mit P2.9 dazu (Sicherheitsnetz gegen eine mögliche Notes-Pflicht nach dem `--draft`-Wegfall), erfüllt aber gleichzeitig genau diesen Punkt |

> **Nachtrag (P2.7–P2.9, 26.–28.08.2026):** Der erste echte Tag-Push deckte
> einen `gh release create`-Bug auf (Release landete unter einer
> automatisch generierten `untagged-<hash>`-URL statt dem echten Tag),
> der zwei Korrekturrunden brauchte, bis die tatsächliche Ursache
> (dokumentiertes, `--draft`-spezifisches GitHub/`gh`-Verhalten) gefunden
> war. Auf Tobias' Wunsch wurde `--draft` danach ganz entfernt — Releases
> werden jetzt sofort veröffentlicht. Diese drei Runden passen in kein
> P0–P3-Raster (sie entstanden erst nach der Sandbox-Verifikation, an
> echter Infrastruktur), volle Herleitung in `nwn_bic-release-plan-status-
> p2-7.md`, `-p2-8.md`, `-p2-9.md`.

---

## 5. Empfohlene Zielstruktur (Skizze, keine fertige Implementierung)

Zeigt nur die Grundform nach P0+P1, kein vollständiger Workflow — Details
(Matrix-Achsen, genaue Artefaktnamen) folgen erst bei der Umsetzung, real
gegen einen Test-Tag verifiziert, nicht nur behauptet:

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: write

jobs:
  build:
    strategy:
      matrix:
        include:
          - os: ubuntu-latest
            artifact: nwn_bic.linux.amd64
          - os: ubuntu-latest
            artifact: nwn_bic.windows.amd64
            nimble-task: win        # bestehender Task: -d:mingw --passL:-static
          - os: macos-latest
            artifact: nwn_bic.macosx.amd64
            nimble-task: macos      # bestehender Task
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v7
      - uses: jiro4989/setup-nim-action@v2
        with:
          nim-version: ${{ vars.NIM_VERSION }}
      - run: nimble install --depsOnly -Y --passNim:"--passC:-Wno-error=incompatible-pointer-types"
      - run: nimble ${{ matrix.nimble-task || 'build' }} -d:release
      # Smoke-Test: dieselben Checks wie build.yml, kein Duplikat-Skript
      - run: ./bin/nwn_bic examples/bic/test1.bic && grep -Fq 'BUILD DETAILS' examples/bic/test1.txt
      - run: sha256sum bin/nwn_bic* > bin/${{ matrix.artifact }}.sha256
      - uses: actions/upload-artifact@v5
        with:
          name: ${{ matrix.artifact }}
          path: bin/*

  release:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7   # für nwn_bic.nimble (Versions-Check)
      - name: Tag-Version-Abgleich
        run: |
          set -eu
          nimble_version=$(grep -oP '(?<=version\s{5}= ")[^"]+' nwn_bic.nimble)
          [ "v$nimble_version" = "${{ github.ref_name }}" ] || {
            echo "Tag ${{ github.ref_name }} != nimble version v$nimble_version"
            exit 1
          }
      - uses: actions/download-artifact@v6
        with: { path: dist }
      - run: gh release create "${{ github.ref_name }}" --draft dist/**/*
        env: { GH_TOKEN: ${{ github.token }} }
```

Windows i386 bewusst nicht in der Skizze (siehe 2.4, offene Frage).
Action-Versionsnummern (`upload-artifact@v5` etc.) sind Platzhalter für "zum
Umsetzungszeitpunkt aktuell", nicht als exakter Wert fixiert — analog zur
Vorgehensweise bei `build.yml`, das seine Versionen ebenfalls empirisch beim
Umbau geprüft hat, nicht geraten.

---

## 6. Offene Entscheidungen (nicht eigenmächtig getroffen)

> **Update 2026-08-24 (nach P1):** Beide folgenden Punkte sind entschieden —
> "die üblichen Binaries reichen, Spezialfälle bei Bedarf nachträglich oder
> selbst generiert." Windows i386 ist aus `release.yml` entfernt (Diff in
> `docs/nwn_bic-release-plan-status-p1.md`), macOS arm64 bleibt wie geplant
> zurückgestellt. Ursprünglicher Text unten bleibt als Herleitung stehen.

- **Windows i386**: streichen oder behalten? Ohne belegten Bedarf spricht
  YAGNI fürs Streichen, aber das ist Tobias' Entscheidung, kein
  Implementierungsdetail.
- **macOS arm64**: jetzt schon mitbauen (native `macos-14`-Runner verfügbar)
  oder auf P3 zurückstellen? Kein Aufwand ohne Anfrage (YAGNI), aber auch
  kein großer Zusatzaufwand, falls gewünscht — sollte vor der Umsetzung
  geklärt werden, nicht danach nachgezogen werden.
- **Release-Erstellung**: `gh` CLI (Vorschlag oben, keine neue Abhängigkeit)
  oder `softprops/action-gh-release@v2` (Drittanbieter-Action, aktiv
  gepflegt, etwas komfortabler bei Multi-File-Uploads)? Beide Optionen sind
  in der Praxis gleich groß im Diff — `gh` gewinnt nur, weil es *keine*
  neue Abhängigkeit ist (Sprosse 4 vor Sprosse 5).

---

## 7. Reihenfolge

```
P0 (0.1–0.5)  →  P1 (1.1–1.5)  →  P2 (2.1–2.6)  →  P3
  Blocker         Robustheit       Qualität         optional
```

P0 zuerst, weil der Workflow davor nicht einmal startet — jeder weitere
Punkt ist bedeutungslos, solange kein Job überhaupt läuft. P1 vor P2, weil
ein Release ohne Smoke-Test (1.3) und ohne die DLL-Lösung (1.1) zwar
"funktioniert", aber ein kaputtes oder unnötig aufgeblähtes Artefakt
produzieren kann — dieselbe Prämisse wie im Hauptplan ("P0 zuerst, weil
alles Weitere auf korrekten Werten aufbaut"), hier übertragen auf
"korrekte Artefakte" statt "korrekte Ausgabewerte".

**Kurzfassung des größten Einzeleffekts:** Punkt 1.1 (den bereits
vorhandenen `win`-Nimble-Task tatsächlich benutzen) beseitigt das
komplette DLL-Zip-Problem, ohne eine einzige neue Zeile Build-Logik zu
schreiben — die Lösung lag die ganze Zeit schon in `nwn_bic.nimble`, sie
wurde nur nie aufgerufen. Das ist derselbe Fund wie P2.1 im Hauptplan
(`neverwinter/twoda` liegt schon als Abhängigkeit vor, wird nur nicht
genutzt) — nur diesmal im Build-Tooling statt im Anwendungscode.
