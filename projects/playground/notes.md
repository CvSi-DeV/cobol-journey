# Playground — Notes

Bac à sable pour manipuler la syntaxe COBOL (DATA DIVISION, conditions, boucles) avant de les réinvestir dans les projets numérotés du plan.

Pas un projet numéroté du plan (`.plan/plan.md`) — pas de template de suivi complet ici, juste un journal court. Organisé en sous-dossiers par thème : `datas/`, `if-statement/`, `claude-exercice/`.

## Journal

- 2026-08-26 : squelette du programme `dataplay.cob` créé (4 divisions vides).
- 2026-08-26 : réorganisation en `projects/playground/` avec sous-dossiers thématiques (`datas/`, `if-statement/`, `claude-exercice/`).
- 2026-08-26 : `claude-exercice/exercice.cob` — exercices Jour 4-5 du plan réalisés et validés :
  - Déclaration de variables (`PIC X`, `PIC 9`, `PIC 9V9` pour les décimaux) + `MOVE`.
  - `IF/ELSE/END-IF` (test majeur/mineur).
  - `PERFORM VARYING` + `DIVIDE ... REMAINDER` + `EVALUATE` (pair/impair de 1 à 10).
  - `FUNCTION TRIM` pour retirer les espaces de padding d'un `PIC X(n)` à l'affichage.
  - Compilé et testé avec `cobc -x -j exercice.cob` — résultat correct.
- Ces briques (variables, `IF`/`EVALUATE`, `PERFORM`, `COMPUTE` à venir) alimentent directement le démarrage du **Projet 2 : Système de Paie**.
