# Status-Update zu `docs/nwn_bic-release-plan.md` — P2.9

Stand: 28. August 2026
Bezug: Tobias' Wunsch, `--draft` zu entfernen — Releases sollen direkt
veröffentlicht werden, kein manueller "Publish"-Schritt mehr. Kein Rewrite
von P2.7/P2.8, nur das Delta.

## Änderung

`gh release create` verliert `--draft`, bekommt `--generate-notes` dazu.

**Warum `--generate-notes` mit dazu:** Ohne `--draft` besteht ein reales,
in dieser Sandbox nicht testbares Risiko (kein `gh`-Binary verfügbar), dass
`gh release create` im nicht-interaktiven CI-Kontext eine Notes-Quelle
verlangt (`--notes`, `--notes-file` oder `--generate-notes`) — eine
Anforderung, von der `--draft` möglicherweise befreit hat, da ein Draft per
Definition noch nicht "fertig" sein muss. `--generate-notes` erzeugt
automatisch Notizen aus den Commits/PRs seit dem letzten Release — kostet
nichts, falls die Anforderung ohnehin nicht bestand, verhindert aber einen
möglichen dritten Fehlschlag, falls doch.

**Warum die URL-Prüfung diesmal wieder drin ist:** Der ganze P2.7/P2.8-
Fund war spezifisch an `--draft` gebunden — ein Draft bekommt seine echte
Tag-URL laut den recherchierten `gh`-Issues erst beim Veröffentlichen. Ohne
`--draft` entfällt genau der Mechanismus, der die Prüfung beim letzten Mal
zu Unrecht hat scheitern lassen. Die Prüfung ist damit keine blinde
Wiederholung des vorherigen Fehlers, sondern gezielt auf den jetzt anderen
Kontext zugeschnitten.

## Nebenwirkungen, die Tobias kennen sollte

- **Sofortige Sichtbarkeit:** Watcher/Stargazer des Repos werden ab jetzt
  bei jedem Release-Lauf sofort benachrichtigt — Drafts waren stumm.
- **Kein Review-Schritt mehr** vor der Veröffentlichung. Wer vor dem
  Livegang noch etwas an Titel/Notizen ändern will, muss das jetzt vor dem
  Tag-Push erledigen (z. B. Commit-Messages/PR-Titel, die `--generate-notes`
  einliest), nicht mehr danach im Draft.
- **Alte, liegen gebliebene Drafts** (aus den `v0.1.1.2`-/`v0.1.1.3`-
  Testläufen) bleiben unverändert bestehen und wandeln sich nicht
  automatisch um — reine Aufräumarbeit auf der GitHub-Weboberfläche, kein
  technisches Problem.

## Nicht in dieser Sandbox testbar

Wie schon P1.5/P2.7/P2.8: kein `gh`-Binary hier verfügbar, daher weder die
`--generate-notes`-Notwendigkeit noch der komplette Release-Vorgang end-to-
end nachstellbar. Empfehlung wie zuvor: einen frischen, bisher unbenutzten
Tag pushen und das Ergebnis zurückmelden.
