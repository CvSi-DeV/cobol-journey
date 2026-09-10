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

- 2026-09-02 : lecon sur le makefile. Realisation des makefiles des projets (hors playground)
- 2026-09-03 :
  - OPEN OUTPUT crée le fichier si il n'existe pas
  - OPEN I-O le fichier doit exister
    sinon le SELECT du fichier doit etre OPTIONAL. avec la clause OPTIONAL, le fichier peut etre créé si il n'existe pas
  - REWRITE seulement applicable sur une ouverture I-O ou Extends
  - Une organisation INDEXED produit un fichier binaire.
  - la variable INDEXED BY dans un record n'a pas besoin de déclaration

  - **REX exercice `navalbat` (bataille navale, `REWRITE` + fichier `INDEXED`) :**
    - Acquis solide : `REWRITE` (objectif initial de l'exercice, rattraper ce qui manquait sur `inventR`) — usage et prérequis bien compris, testé à plusieurs reprises.
    - Acquis bonus (au-delà de la consigne) : `SORT` sur table en mémoire + `SEARCH ALL` avec clé composée (`REDEFINES` en clé unique 4 chiffres pour contourner un bug GnuCOBOL du `WHEN ... AND ...` sur deux champs).
    - Point de vigilance identifié : le même bug racine est revenu 3 fois sous des formes différentes (génération de grille silencieusement cassée, `READ` échoué réutilisant une donnée périmée, `LS-FS-GRILLE` réutilisée comme condition alors qu'elle change à chaque opération fichier) — `FILE STATUS` vérifié seulement au moment où ça plante visiblement, pas systématiquement après chaque `READ`/`WRITE`/`REWRITE`. À travailler : en faire un réflexe d'écriture, pas une étape de debug après coup.
    - Progression notée sur le débogage autonome : premier bug de l'exercice (erreur de compilation `RECORD KEY`) résolu avec questions guidées nécessaires ; dernier bug (`LS-FS-GRILLE` périmée) diagnostiqué correctement avant la fin des questions guidées.
    - Écart assumé à la consigne initiale : contrainte "recherche séquentielle dans le fichier" contournée par un accès direct `INDEXED`/`RECORD KEY` — reporté à l'Exercice 3 (fichier `INDEXED`, pratique du `READ` séquentiel sans clé en complément du `READ ... KEY IS`).

- 2026-09-04 : **Exercice 2 (`RELATIVE`) : `creneaux.cob`.**
  - Acquis : `ORGANIZATION IS RELATIVE`, `RELATIVE KEY` (variable hors `FD`, distincte du `RECORD KEY` de l'`INDEXED`), écriture séquentielle initiale (`OPEN OUTPUT` + `WRITE`), accès direct par position en `ACCESS MODE IS DYNAMIC`, `REWRITE`, vérification par relecture séquentielle complète (`READ ... NEXT` + `AT END`).
  - **Point précisé (doc IBM z/OS COBOL, WRITE — Relative Files) :** en accès `RANDOM` ou `DYNAMIC`, le `RELATIVE KEY` doit être renseigné **avant** l'exécution du `WRITE` (ce n'est qu'en accès `SEQUENTIAL` que la numérotation est automatique et que le champ est rempli _après_ le `WRITE`). C'est exactement pour cette raison que `INIT-WRITE` utilise la variable de boucle `LS-RK-CRENEAUX` à la fois comme compteur et comme `RELATIVE KEY` — le commentaire d'origine dans le code n'était pas faux sur le fond, seulement sur la terminologie (`RECORD KEY` au lieu de `RELATIVE KEY`) et le mode d'accès cité (`RANDOM` au lieu de `DYNAMIC`, déclaré dans le `SELECT`).
  - Corrections appliquées après revue :
    `INVALID KEY` / `NOT INVALID KEY` ajouté sur le `READ` de `MOD-REWRITE` (le `FILE STATUS` n'était pas vérifié avant le `REWRITE`.
    constante `CST-FS-EOF` ajoutée pour remplacer le littéral `"10"`.
  - `Makefile` vérifié : compile (`cobc -x -std=ibm`), `make run` nettoie `creneaux.dat` avant exécution — comportement conforme.

- 2026-09-09 : **Exercice indexedf manipulation des fichiers indexe**
  - Acquis : UPSERT PATTERN toujours lire pour positionner la clé avant le REWRITE : les compilateurs ne se comporte pas toujours de la meme facon notament au premier REWRITE juste après l'OPEN.
  - niveau 88 pour créer le types booleen. C'est le conditon-name

  ```cobol
  01 boolean pic X.
    88 boolean-state "O" FALSE "N".
    ...
    SET boolean-state TO TRUE
    Set boolean-state TO FALSE
    IF boolean-state THEN
    ...
    END-IF
  ```

  - Nouvelles notions par rapport à `navalbat`/`creneaux` : `DELETE` direct par clé (`RECORD KEY`, pas besoin de `READ` préalable en accès `DYNAMIC`, contrairement à `REWRITE`)

  - **Complément (relecture) : Exercice 3 (`INDEXED`) — `indexedf.cbl`.**
    ; `READ ... KEY IS` désormais systématiquement accompagné de `INVALID KEY`/`NOT INVALID KEY` (jusqu'ici pratiqué sans gestion d'erreur dans `navalbat`).
    - Bug réel trouvé et corrigé : `PRODUCT-MOD` rouvrait le fichier (`OPEN I-O`) à **chaque itération** d'une boucle de ressaisie — sur GnuCOBOL ça n'a pas cassé visiblement (testé avec une saisie invalide suivie d'une valide), mais rouvrir un fichier déjà ouvert est un statut d'erreur en COBOL standard (`FILE STATUS "41"`) non garanti portable. Cause : faute d'inattention selon l'utilisateur. Corrigé en déplaçant l'`OPEN` avant la boucle (aligné sur le modèle déjà correct de `PRODUCT-DEL`), protégé par `IF FS-OK`. Même famille de point de vigilance que sur `navalbat` (`FILE STATUS` non vérifié systématiquement) — ici la correction a été immédiate et bien comprise, signe que le réflexe s'installe.
    - Bonus non demandés, ajoutés spontanément après la revue : renommage `FS-FILE-MISSING` → `FS-FILE-CREATED` (plus fidèle au sens du code `"05"`, qui signifie que le fichier vient d'être créé, pas qu'il manque) ; `88 FS-END-OF-FILE VALUE "10"` introduit et réutilisé dans `READ-AND-DISPLAY` à la place d'un `PERFORM UNTIL 1 = 2` (boucle infinie déguisée) — cohérent avec l'idiome déjà utilisé dans `creneaux.cob` (`CST-FS-EOF`).
    - Tout testé en exécution réelle (pas que lecture de code), y compris le chemin d'erreur (saisie d'un code produit invalide sur `PRODUCT-MOD`).
