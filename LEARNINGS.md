# Week 1 Learnings

## Ce que j'ai compris

- Structure d'un programme COBOL en 4 divisions : `IDENTIFICATION`, `ENVIRONMENT`, `DATA`, `PROCEDURE`
  - mémotechnique : `I ENter DATA PROperly`
- Zones de colonnes historiques (indicateur, zone A, zone B) et rôle du point comme terminateur d'instruction
- Différence entre `STOP RUN`, `GOBACK` et `EXIT PROGRAM`
- Déclaration de variables et clauses `PICTURE` (`PIC X`, `PIC 9`, `PIC 9V9` pour les décimaux), `MOVE`
  - WORKING-STORAGE SECTION.
- Structures conditionnelles `IF/ELSE/END-IF` et `EVALUATE TRUE` pour la sélection multi-cas
- Boucles `PERFORM VARYING`, opérateur `DIVIDE ... REMAINDER`
- Structures / records hiérarchiques (`01`, `05`) pour modéliser des données composites
- `COMPUTE` pour les calculs arithmétiques (plus lisible que `MULTIPLY`/`ADD`/`SUBTRACT` séparés)
- `FUNCTION TRIM` pour l'affichage propre des chaînes à largeur fixe
- lecture de fichiers `File I/O`
- Table record avec `OCCURS`
- `READ` avec `AT END` et `NOT AT END`
- manipulation des files status
- utilisation de `UNSTRING`
- `FUNCTION NUMVAL` pour convertir un champ alpha en valeur numérique exploitable dans un `COMPUTE`

## Blockers

- Aucune difficulté technique identifiée cette semaine

## Next

- Poursuivre le Projet 2 (Système de Paie) : passage à un traitement multi-employés (fichier, `OCCURS`, tables) prévu Semaine 2-3 du plan
- Démarrer le Projet 3 (Gestionnaire d'Inventaire) — fichiers séquentiels, I/O
