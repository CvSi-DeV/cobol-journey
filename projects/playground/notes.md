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
- 2026-08-28 : lecture d'un fichier csv dans **lectucsv.cob**.
  Dans ENVIRONMENT DIVISION
  - `INPUT-OUTPUT SECTION`
  - `FILE CONTROL` en Zone B
  - clause `SELECT` en Zone B `Assign To ` lien avec le fichier systeme
  - clause `FD`

  Dans Data DIVISION
  - `FILE SECTION`
  - `FD` meme nom de fichier que dans le `SELECT`
  - `OCCURS` avec `DEPENDING ON` et `INDEXED BY`

  Dans PROCEDURE DIVISION
  - `OPEN INPUT FILE`, `READ FILE`, `CLOSE FILE`
  - utilisation de la variable `FILE STATUS` pour l'affectation des variables du record `subscripting`
  - `UNSTRING ... DELIMITED BY ',' INTO ...` pour découper une ligne CSV en plusieurs champs
  - `FUNCTION NUMVAL(...)` pour convertir un champ alpha extrait par `UNSTRING` en valeur numérique exploitable dans un `COMPUTE`
  - technique pour sauter la ligne d'en-tête CSV : compteur de lignes lues (`IF LS-NB-READ IS GREATER THAN 1`), pas de mécanisme dédié en COBOL

- 2026-08-28 : points de vigilance découverts en corrigeant `lectucsv.cob` (portabilité GnuCOBOL vs IBM COBOL, cf. Risque 1 de `.plan/plan.md`) :
  - `OCCURS integer-2 TIMES DEPENDING ON ...` **sans** `TO` est en fait la syntaxe standard IBM pour une borne minimale de 1 (`[integer-1 TO] integer-2 TIMES DEPENDING ON` — si `integer-1` omis, `TO` doit l'être aussi). Le warning GnuCOBOL sur ce point n'indique pas une erreur de portabilité.
  - Continuer un mot COBOL (identifiant, mot réservé) sur plusieurs lignes avec un tiret `-` en colonne 7 est une fonctionnalité **obsolète**, tolérée par GnuCOBOL pour compatibilité avec du vieux code mais déconseillée en code neuf (warning `-Wdialect`). En format libre, une instruction peut simplement continuer sur la ligne suivante sans tiret, tant qu'on ne coupe pas un littéral.
  - `DISPLAY` d'un champ `PIC 9(5)V99` insère un point décimal par défaut avec GnuCOBOL (`08000.00`), mais pas avec l'option de compilation `-std=ibm` (`0800000`, décimale implicite non affichée, fidèle au runtime z/OS). **Compiler systématiquement avec `-std=ibm`** pour rester fidèle à l'environnement cible — adopté comme convention dans les README du repo.

- 2026-08-28 : bonus `lectucsv.cob` — fiche de paie complète calculée pour chaque employé du CSV, en reprenant telle quelle la logique métier de `systpaie.cob` (cotisations 22 %, tranches EVALUATE, impôt, net) appliquée à `SALAIRE-BRUT(LS-ID-EMPLOYES)` dans la boucle de lecture. Résultats croisés avec les cas déjà documentés dans `systpaie-project.md` (bruts 3200 et 8000) — valeurs identiques, calculs corrects. Logique dupliquée entre les deux programmes pour l'instant (pas de copybook/sous-programme partagé) — normal à ce stade, sera reconsidéré Semaine 5-6 du plan (Copybooks, `CALL`).
