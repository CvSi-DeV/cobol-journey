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
- `INITIALIZE` pour remettre à blanc un `PIC X(n)` avant reconstruction
- `PERFORM nom-paragraphe` pour factoriser un bloc de code répété (pas un `CALL` de sous-programme externe, juste un paragraphe du même `PROCEDURE DIVISION`)
- `OPEN OUTPUT` / `WRITE` pour générer un fichier de sortie (rapport), en plus de la lecture déjà pratiquée

## Blockers

- Résolu : boucle infinie dans `systpaie.cob` v2 — `CLOSE` sur un fichier avec `FILE STATUS IS ...` met à jour cette même variable (pas seulement `READ`). Fermer le fichier à l'intérieur du `AT END` écrasait le code `'10'` (fin de fichier) par le code de retour du `CLOSE`, cassant la condition de sortie du `PERFORM UNTIL`. Fix : sortir les `CLOSE` après le `END-PERFORM`, jamais à l'intérieur d'une branche testée par la condition de boucle.

## Next

- Projet 2 (Système de Paie) v2 : lecture multi-employés (`employes.dat`), calcul et écriture d'un rapport — fait, bug corrigé
- Démarrer le Projet 3 (Gestionnaire d'Inventaire) — fichiers séquentiels, I/O, `FILE STATUS` en gestion d'erreurs réelle
