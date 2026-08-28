# Status-Update zu `docs/nwn_bic-release-plan.md` — P2.7 (Bugfix aus dem ersten echten Lauf)

Stand: 26. August 2026
Bezug: erster echter Tag-Push (`v0.1.1.2`) durch Tobias. Vier von fünf Jobs
liefen fehlerfrei; der `release`-Job "lief durch" (grün), erzeugte aber
einen Release unter einem falschen, automatisch generierten Tag. Kein Rewrite
der P0/P1/P2-Status-Dokumente, nur das Delta.

**Kurzstatus:** Bug gefunden und behoben ✅. Root Cause **nicht** zu 100 %
bestätigt (keine `gh`/Live-API-Verifikation in der Sandbox möglich) — Fix
und Absicherung sind trotzdem konkret und risikoarm.

---

## Der Fund

Tobias meldete: Workflow lief durch, keine Fehler, aber keine Zip-Dateien am
erwarteten Ort. Log-Analyse (`gh actions run download-log` von Tobias
bereitgestellt) zeigt die eigentliche Ursache im letzten Schritt des
`release`-Jobs:

```
https://github.com/dunahan/nwn_bic/releases/tag/untagged-231aae3f5061afb05bfa
```

`gh release create "${GITHUB_REF_NAME}" ...` hat den Release **tatsächlich
erstellt**, inklusive aller vier Dateien (drei Zips + `SHA256SUMS.txt`) —
aber unter einem automatisch generierten `untagged-<hash>`-Tag statt unter
`v0.1.1.2`. Exit-Code 0, kein sichtbarer Fehler — ein stiller Fehlschlag,
der als grüner Lauf erscheint.

Das erklärt auch Tobias' Beobachtung, dass die von Hand nachgeladenen
Dateien "nur die Binaries, keine Readme oder Lizenz" enthielten: Das waren
die rohen Build-Artefakte (`actions/upload-artifact`), nicht die fertigen
Release-Zips (die lagen die ganze Zeit im falsch benannten Draft-Release,
nur unter einem Tag, nach dem niemand gesucht hat).

Alle vier anderen Jobs (`build-linux-win` beide Matrix-Einträge,
`smoke-test-windows`, `build-macos`) liefen fehlerfrei durch — keine
Regression durch diesen Bug, er betrifft ausschließlich den letzten Schritt
des `release`-Jobs.

## Diagnose (begründete Vermutung, nicht abschließend bewiesen)

Der `checkout`-Schritt im `release`-Job holt per `fetch-depth: 1` und
`fetch-tags: false` **ausschließlich** die eine Tag-Referenz:

```
git fetch --no-tags --prune --no-recurse-submodules --depth=1 origin +refs/tags/v0.1.1.2:refs/tags/v0.1.1.2
git checkout --progress --force refs/tags/v0.1.1.2
```

Ergebnis: ein Checkout ganz ohne jede Branch-Information, reiner Detached-
HEAD-Zustand mit genau einer Tag-Referenz. Vermutung: `gh release create`
ohne explizites `--target` kann in diesem Zustand den Ziel-Commit nicht
zuverlässig auflösen und weicht auf seinen "kein Tag angegeben"-Codepfad
aus, der einen `untagged-<hash>`-Platzhalter erzeugt.

**Ehrlich unsicher:** Diese Sandbox hat kein `gh`-Binary und keinen
Schreibzugriff auf ein echtes GitHub-Repo — die Vermutung konnte nicht an
der echten API nachgestellt werden (dieselbe Lücke, die schon in P1.5
dokumentiert war: "Syntax bekannt, hier nicht ausführbar getestet"). Möglich,
dass die tatsächliche Ursache eine andere ist (z. B. eine Eigenheit, wie
`gh` speziell bei `--draft`-Releases die Tag-Zuordnung erst beim
Veröffentlichen vornimmt). Deshalb wurde die Lösung zweigleisig aufgebaut:
eine plausible Abhilfe **und** eine vom genauen Mechanismus unabhängige
Absicherung.

## Der Fix

**1. Mitigation:** `--target "${GITHUB_SHA}"` explizit ergänzt. Nimmt `gh`
jede Notwendigkeit, einen Ziel-Commit selbst herzuleiten — unabhängig davon,
ob das tatsächlich die Ursache war, kann es nicht schaden.

**2. Absicherung (die eigentlich wichtige Änderung):** Statt einer separaten
Nachfrage à la `gh release view "$TAG"` (die denselben Tag-Auflösungs-Schritt
erneut durchläuft, der möglicherweise schon beim Erstellen versagt hat, und
deshalb im Fehlerfall selbst lautlos bleiben könnte) wird die **von
`gh release create` selbst zurückgegebene URL** direkt geprüft — genau das
Signal, an dem der Bug hier überhaupt erst auffiel:

```bash
url=$(gh release create "${GITHUB_REF_NAME}" --target "${GITHUB_SHA}" --draft ...)
echo "release URL: $url"
case "$url" in
  */releases/tag/"${GITHUB_REF_NAME}") ;;
  *)
    echo "::error::gh created the release at '$url', not under tag '${GITHUB_REF_NAME}'"
    exit 1
    ;;
esac
```

Real getestet (Bash-`case`-Pattern-Matching, drei Fälle):

| URL | erwarteter Tag | Ergebnis |
|---|---|---|
| `.../releases/tag/v0.1.1.2` | `v0.1.1.2` | ✅ PASS |
| `.../releases/tag/untagged-231aae3f5061afb05bfa` (der reale Fehlerfall) | `v0.1.1.2` | ❌ FAIL → `exit 1` |
| `.../releases/tag/v0.1.1.20` (Substring-Grenzfall) | `v0.1.1.2` | ❌ FAIL → `exit 1` (exaktes Pattern-Matching, kein Präfix-Treffer) |

Der Job schlägt jetzt **laut** fehl, statt still einen falsch benannten
Release zu erzeugen — dieselbe Grundhaltung wie P2.3 (harter Tag/Version-
Check): ein Fehler, der nicht auffällt, ist schlimmer als einer, der den
Job rot macht.

## Sofortmaßnahme für den bereits erzeugten Fehl-Release

Der Draft-Release unter `untagged-231aae3f5061afb05bfa` (Titel: `v0.1.1.2`,
enthält alle vier korrekten Dateien) sollte manuell bereinigt werden:

- **Entweder** löschen und nach dem Fix erneut taggen (`git tag -d
  v0.1.1.2 && git push origin :v0.1.1.2`, dann `git tag v0.1.1.2 && git push
  origin v0.1.1.2` — löst den reparierten Workflow erneut aus), **oder**
- über die GitHub-Weboberfläche den Draft öffnen (`Releases` →
  Titel `v0.1.1.2` suchen, nicht über die Tag-URL) und das Tag-Feld manuell
  auf `v0.1.1.2` korrigieren, dann veröffentlichen.

Die erste Option ist vorzuziehen — sie beweist gleichzeitig, dass der Fix
wirkt, statt nur den Zustand von Hand geradezubiegen.

## Nicht Teil dieses Fixes

- Die zugrunde liegende Ursache (Shallow-Checkout-Theorie) bleibt eine
  begründete, nicht abschließend bewiesene Vermutung. Sollte der Bug trotz
  `--target` erneut auftreten, fängt ihn die Verifikation zuverlässig ab —
  aber die eigentliche Ursache wäre dann noch offen.
- Kein Test dieses Fixes in der Sandbox möglich (kein `gh`-Binary, kein
  Schreibzugriff auf ein echtes Repo) — die Bash-Case-Logik wurde isoliert
  getestet, der komplette `gh`-Aufruf nicht end-to-end.

## Ehrlicher Gesamt-Hinweis

Das ist der erste Bug, der ausschließlich durch einen echten Lauf auf
echter GitHub-Infrastruktur sichtbar wurde — keine der Sandbox-
Verifikationen (P0–P2) konnte ihn finden, weil sie alle ohne echten `gh`
und ohne echte GitHub-API liefen. Das bestätigt nachträglich, warum P1.5
von Anfang an als "Syntax bekannt, hier nicht ausführbar getestet" markiert
war, statt fälschlich als verifiziert zu gelten. Die Lehre für den Rest des
Workflows: jede Stelle, die von hier aus nicht real testbar war, verdient
genau diese Skepsis, bis ein echter Lauf sie bestätigt.
