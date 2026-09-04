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
- `OCCURS ... DEPENDING ON ... INDEXED BY` pour une table de taille variable (chargement en mémoire d'un fichier lu séquentiellement)
- Gérer **deux fichiers en lecture simultanée** : deux `FILE STATUS` distincts à ne pas confondre
- `IN` / `OF` pour qualifier un nom de champ ambigu entre deux records (interchangeables, préférence perso pour `IN`)
- `WRITE` (créer un enregistrement, fichier en `OUTPUT`) vs `REWRITE` (remplacer un enregistrement déjà écrit, fichier en `I-O`) — les confondre ne plante pas forcément, mais ne produit rien d'utile
- `SET index UP BY 1` existe comme alternative à `ADD 1 TO index` pour manipuler une variable `INDEXED BY` (vu en apprentissage, pas encore pratiqué dans un programme)
- Makefile pour les projets

## Blockers

- Résolu : boucle infinie dans `systpaie.cob` v2 — `CLOSE` sur un fichier avec `FILE STATUS IS ...` met à jour cette même variable (pas seulement `READ`). Fermer le fichier à l'intérieur du `AT END` écrasait le code `'10'` (fin de fichier) par le code de retour du `CLOSE`, cassant la condition de sortie du `PERFORM UNTIL`. Fix : sortir les `CLOSE` après le `END-PERFORM`, jamais à l'intérieur d'une branche testée par la condition de boucle.
- Résolu : sur `inventR.cob`, confusion d'indices entre deux tables
- Résolu : `PERFORM VARYING ... UNTIL` est **pré-évalué** (condition testée avant chaque itération, y compris la première) → `UNTIL I = N` saute le traitement du dernier élément de la table ; il faut `UNTIL I > N`.
- Résolu : cohérence de sizing entre le compteur (`PIC 9(3)`, jusqu'à 999) et la borne de la table (`OCCURS 100 TIMES`) — un dépassement du nombre de lignes en entrée aurait pu écrire hors table.

## Next

- Projet 2 (Système de Paie) v2 : lecture multi-employés (`employes.dat`), calcul et écriture d'un rapport — fait, bug corrigé
- Projet 3 (Gestionnaire d'Inventaire) : fichiers séquentiels multiples, tables `OCCURS`, `FILE STATUS` en gestion d'erreurs réelle (cas fichier absent) — fait, validé sur 4 cas de test
- Repo GitHub public créé (`cobol-journey`)
- Démarrer le Projet 4 (Refactoring Prod) — copybooks, sous-programmes (`CALL`, `LINKAGE SECTION`)
- A traiter séparément : organisation `INDEXED`/`RELATIVE FILE` (non pratiquée sur le Projet 3), pratique de la clause `REWRITE` sur un fichier dédié en playground

## Semaine 5 — Makefile & Organisation de fichiers

- Makefile : anatomie `cible: prérequis` + recette tabulée (jamais d'espaces), `.PHONY` pour les cibles sans fichier produit, variables (`$(VAR)`) et variables automatiques (`$@`, `$<`, `$^`)
- Dépendance make = comparaison de timestamps : ne pas mettre une donnée d'exécution (ex: fichier `.dat`) en prérequis d'une cible de *compilation*, sinon recompilation inutile à chaque changement de donnée
- Forcer `clean` en prérequis de `build`/`run` casse l'incrémentalité de make (recompile tout, tout le temps) — garder `clean`/`rebuild` comme cibles séparées, jamais dans la chaîne de dépendance par défaut
- Modes d'ouverture fichier complets : `INPUT`/`OUTPUT`/`I-O`/`EXTEND` — `REWRITE` exige `I-O`
- `SELECT OPTIONAL` permet un `OPEN I-O` même si le fichier n'existe pas encore (sinon code `FILE STATUS '35'`, fichier introuvable) ; code `'05'` = fichier optionnel créé à l'ouverture
- `ORGANIZATION IS INDEXED` / `RELATIVE` : accès direct par clé métier (`RECORD KEY`) ou par position (`RELATIVE KEY`), en plus du séquentiel déjà pratiqué — produit un fichier **binaire** (format dépendant du moteur GnuCOBOL, ici Berkeley DB), pas du texte ; utilitaire `db_dump` pour l'inspecter en clair
- `RECORD KEY` doit désigner un champ de la `FILE SECTION`, jamais une variable `WORKING-STORAGE`/`LOCAL-STORAGE`
- Pour une clé par élément d'une table `OCCURS`, le champ clé doit être **imbriqué à l'intérieur** de l'occurrence (niveau inférieur), pas en frère avec un `REDEFINES` de la table entière
- `INDEXED BY` crée un nom d'index spécial : ne pas le redéclarer comme variable normale ailleurs (conflit de nom)
- `SORT nom-table ASCENDING KEY champ` : tri d'une table en mémoire (existe aussi pour les fichiers, mais ici sur `WORKING-STORAGE`)
- `SEARCH ALL` (recherche dichotomique) exige `ASCENDING`/`DESCENDING KEY` + `INDEXED BY` sur la table — **`ASCENDING KEY` ne trie pas automatiquement**, c'est une promesse faite au compilateur : la donnée doit être triée par le programme avant l'appel
- Piège GnuCOBOL (3.2) constaté : `SEARCH ALL` avec un `WHEN` combinant deux champs par `AND` ne trouve rien même sur données triées ; contournement fiable : une seule clé combinée (`REDEFINES` d'un champ unique) plutôt que deux comparaisons de champs
- Une variable `FILE STATUS` est écrasée à **chaque** opération fichier (`OPEN`, `READ`, `WRITE`, `REWRITE`...) — pour retenir le statut d'une opération précise (ex: l'`OPEN`) en vue d'une condition plus tard dans une boucle, la copier dans une variable dédiée avant qu'elle ne soit réécrite par l'opération suivante
- Discipline à renforcer : vérifier `FILE STATUS` après **chaque** instruction fichier qui peut échouer, pas seulement au moment où un plantage devient visible (même bug racine rencontré 3 fois sous des formes différentes sur un seul exercice avant d'être fixé à la source)
