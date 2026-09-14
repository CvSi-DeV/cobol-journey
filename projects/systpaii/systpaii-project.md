# Refactoring Système de Paie (Projet 4) — Progress Tracker

## Apprentissage

### COBOL

- Copybooks (`COPY`) — convention Z/OS (nom de membre, sans guillemets ni extension : `COPY EMPLOYE`) vs convention COBOL (littéral fichier : `COPY 'employe.cpy'`)
- Sous-programmes (`CALL`/`LINKAGE SECTION`), passage de paramètres via `USING`
- `BY REFERENCE` (défaut) vs `BY CONTENT` — mémoire partagée avec l'appelant vs copie
- `RETURNING` : valide dans le standard des deux côtés (définition + `CALL ... RETURNING`), mais **non implémenté par GnuCOBOL côté définition** pour un `PROGRAM-ID` classique (fonctionne seulement pour une `FUNCTION-ID`) — donc tout passer en `USING`, y compris les sorties
- Appel statique (`CALL 'X'`, nom fixe résolu à la compilation) vs appel dynamique (`CALL X`, nom lu dans une variable à l'exécution)
- Aucune vérification de signature entre appelant et appelé (ni nombre, ni type, ni ordre) — correspondance uniquement positionnelle, erreurs silencieuses possibles
- Ordre imposé des sections de la `DATA DIVISION` : `FILE SECTION` → `WORKING-STORAGE SECTION` → `LOCAL-STORAGE SECTION` → `LINKAGE SECTION`
- Niveaux 88 utilisables sur n'importe quelle section (y compris `LINKAGE SECTION`) — mais le **nom** du niveau 88 n'est jamais partagé entre programmes, seule la mémoire (valeur brute) l'est ; chaque programme redéclare son propre 88 sur sa propre variable si besoin
- Niveaux 88 avec `VALUES ... THRU ...` pour modéliser des tranches de barème (bornes continues, sans recouvrement)
- **Group MOVE** : une affectation groupe-à-groupe (`MOVE groupe-A TO groupe-B`) est une copie d'octets bruts alphanumérique, pas une conversion champ par champ — casse tout formatage numérique édité si les tailles/offsets des deux groupes ne coïncident pas exactement. Piège central de la session.
- `PICTURE` éditée (`Z`, point décimal explicite `.`, virgule `,`) pour un affichage "human readable", à appliquer via `MOVE` élémentaire (champ par champ), jamais via un `MOVE` de groupe

### Outillage / environnement

- Deux moteurs de résolution de copybook actifs en parallèle dans VSCode : `zapp.yaml` (IBM ZCodeScan) et un réglage LSP séparé (`cobol-lsp.cpy-manager.paths-local`, utilisé par Broadcom COBOL Language Support **et** par le moteur intégré à IBM Z Open Editor, tous deux issus du même projet open-source Eclipse Che4z) — deux configurations indépendantes à maintenir
- Le vrai bug racine d'une longue session de debug outillage était en réalité plus basique que toute la configuration explorée : un fichier copybook mal nommé/extension incorrecte
- Modules compilés (`cobc -m`) : format natif de l'OS (`.dylib` sur macOS, `.so` sous Linux, `.dll` sous Windows) — ne pas forcer l'extension via `-o`, ça ne change pas le format binaire sous-jacent
- Résolution des modules `CALL` à l'exécution : gérée par `libcob` via le dossier courant ou `COB_LIBRARY_PATH`, totalement indépendante de `zapp.yaml`/du LSP (qui ne travaillent qu'au niveau source)
- Erreurs Make classiques : sensibilité à la casse des noms de variables (`$(GENERAPP)` ≠ `$(generapp)`, dépendance silencieusement vide), espace de fin de ligne caché dans une affectation (`GENERAPP = generapp ` → dépendance circulaire détectée par Make)

## Challenge / Objectif

Refactorer `systpaie` (Projet 2) en architecture de production : copybooks pour les structures communes, sous-programmes réutilisables pour le calcul et la génération du rapport, Makefile professionnel — conformément au Projet 4 du plan (Semaines 5-6).

## Bugs rencontrés (récap)

1. **Copybook introuvable en pré-analyse** — deux résolveurs concurrents (`zapp.yaml`/ZCodeScan vs LSP) mal configurés, cause racine finalement plus simple : fichier mal nommé.
2. **`program RETURNING is not implemented [-Wpending]`** — `RETURNING` dans la définition d'un `PROGRAM-ID` (`calccoti.cob`) ignoré par GnuCOBOL ; corrigé en passant la sortie en paramètre `USING` supplémentaire.
3. **Dépendance Make vide puis circulaire** — faute de casse (`$(generapp)` au lieu de `$(GENERAPP)`), puis espace de fin de ligne caché dans `GENERAPP = generapp ` provoquant `Circular generapp <- generapp dependency dropped`.
4. **`make: ./: Permission denied`** — même famille de bug : `./$(systpaii)` avec variable en minuscule non définie, donc commande réduite à `./`.
5. **Formatage numérique cassé malgré un champ édité correctement déclaré** — `MOVE LK-PAIE-DATA(idx) TO LS-PAIE-DATA-DISP` en `MOVE` de groupe : copie brute d'octets ignorant les `PICTURE` éditées de chaque sous-champ, tailles de groupes différentes en plus. Corrigé en `MOVE`-ant chaque champ individuellement.

## Temps

- 4 à 6h

## Confiance

- 8/10 sur les nouvelles notions (copybooks, `CALL`/`LINKAGE SECTION`, niveaux 88 avancés)
- 8/10 sur le débogage autonome

## Résultats d'exécution

Rapport généré dans `rapport-fp.txt` (non versionné — régénérable via `make run`), 8 employés traités. Extraits :

```
-----------------------------
------ FICHE DE PAIE --------
-----------------------------
- NOM : CONTRIB
- PRENOM : MICHELE
-----------------------------
- SALAIRE BRUT     :  1420.00
--
- COTISATIONS      :   312.40
- BASE IMPOSABLE   :  1107.60
- TAUX IMPOT       :     0.00
- IMPOT            :     0.00
--
- SALAIRE NET      :  1107.60
-----------------------------
```

```
-----------------------------
------ FICHE DE PAIE --------
-----------------------------
- NOM : DUPONT
- PRENOM : JEAN
-----------------------------
- SALAIRE BRUT     :  3200.00
--
- COTISATIONS      :   704.00
- BASE IMPOSABLE   :  2496.00
- TAUX IMPOT       :     0.11
- IMPOT            :   274.56
--
- SALAIRE NET      :  2221.44
-----------------------------
```

Nombre d'employés traités : 8
