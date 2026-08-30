# Gestionnaire d'Inventaire — Progress Tracker

## Objectif

Programme COBOL qui lit un fichier de **produits** (stock), traite un fichier de **commandes**, et pour chaque commande :

- vérifie que le produit existe,
- vérifie que le stock est suffisant,
- si oui : décrémente le stock et marque la commande **ACCEPTÉE**,
- sinon : marque la commande **REFUSÉE** (stock insuffisant, ou produit inconnu).

Le programme écrit un rapport `rapport-inventaire.txt` récapitulant chaque commande traitée (acceptée/refusée) et l'état final du stock.

C'est le projet Semaine 4 du plan (`Fichiers & I/O Production`) : after `LINE SEQUENTIAL`, on introduit une vraie gestion d'erreurs par `FILE STATUS` et, en bonus, les fichiers `INDEXED`.

## Notions nouvelles à mobiliser

Tu maîtrises déjà `OPEN`/`READ`/`WRITE`/`CLOSE`, `PERFORM UNTIL` + `AT END`/`NOT AT END`, `FILE STATUS` (vu sur systpaie, y compris le piège du `CLOSE`). Nouveau sur ce projet :

- **Deux fichiers en lecture simultanée** (produits + commandes) — donc deux `FILE STATUS` distincts à gérer, pas un seul.
- **Recherche d'un produit** : pour chaque commande lue, il faut retrouver le produit correspondant. En V1 (fichiers séquentiels), ça veut dire relire le fichier produits (ou le charger en table `OCCURS` — à toi de choisir, comme tu l'as fait sur playground/csvlec).
- **`REWRITE`** : pour mettre à jour le stock d'un produit après une commande acceptée. Différent de `WRITE` : `REWRITE` remplace un enregistrement déjà existant dans un fichier ouvert en `I-O` (pas juste `OUTPUT`).
- **`FILE STATUS` en gestion d'erreurs réelle** (pas juste `AT END`) : que fait ton programme si `produits.dat` n'existe pas à l'ouverture ? Code `'35'` = fichier introuvable. À tester et gérer proprement (message clair + arrêt propre), plutôt que laisser planter le programme.

### Bonus (optionnel, pour aller au bout du plan Semaine 4)

- Convertir le fichier produits en **fichier `INDEXED`** (`ORGANIZATION IS INDEXED`, `RECORD KEY IS CODE-PRODUIT`) pour faire un accès direct par code produit (`READ ... KEY IS ...`) au lieu de reparcourir le fichier à chaque commande. Plus proche de la réalité production, mais pas indispensable pour valider le projet.

## Structure de données suggérée

```cobol
       FD  PRODUITS-DAT.
       01  PRODUIT-RECORD.
           05 PR-CODE-PRODUIT      PIC X(6).
           05 PR-DESIGNATION       PIC X(20).
           05 PR-QUANTITE-STOCK    PIC 9(5).
           05 PR-PRIX-UNITAIRE     PIC 9(5)V99.

       FD  COMMANDES-DAT.
       01  COMMANDE-RECORD.
           05 CM-CODE-PRODUIT      PIC X(6).
           05 CM-QUANTITE-COMMANDEE PIC 9(5).

       WORKING-STORAGE SECTION.
       01  WS-STATUT-COMMANDE      PIC X(9).
      *> 'ACCEPTEE ' ou 'REFUSEE  ' (padding pour alignement)
```

Libre à toi d'adapter (noms, tailles) — ce n'est qu'une suggestion, comme pour systpaie.

## Règles métier

1. **Produit inconnu** : le `CODE-PRODUIT` de la commande n'existe dans aucun enregistrement du fichier produits → commande **REFUSÉE**, motif "produit inconnu".
2. **Stock insuffisant** : `QUANTITE-COMMANDEE > QUANTITE-STOCK` → commande **REFUSÉE**, motif "stock insuffisant".
3. **Commande acceptée** : stock suffisant → `QUANTITE-STOCK = QUANTITE-STOCK - QUANTITE-COMMANDEE`, commande **ACCEPTÉE**.
4. Le rapport final liste chaque commande traitée avec son statut, et peut inclure un état du stock restant par produit en fin de traitement (à toi de voir le niveau de détail).

## Fichiers fournis

- `produits.dat` — format fixe : `CODE-PRODUIT PIC X(6)` + `DESIGNATION PIC X(20)` + `QUANTITE-STOCK PIC 9(5)` + `PRIX-UNITAIRE PIC 9(5)V99` (38 caractères/ligne, pas de séparateur).
- `commandes.dat` — format fixe : `CODE-PRODUIT PIC X(6)` + `QUANTITE-COMMANDEE PIC 9(5)` (11 caractères/ligne).

Ces deux fichiers couvrent volontairement les 3 cas de règles métier (voir section Tests).

## Tests à documenter

Le jeu de données fourni (`commandes.dat`) est construit pour couvrir :

- une commande **acceptée** (stock largement suffisant)
- une commande **acceptée** qui vide exactement le stock restant (cas limite : quantité commandée = quantité en stock)
- une commande **refusée pour stock insuffisant**
- une commande **refusée pour produit inconnu** (code produit absent de `produits.dat`)

Noter les résultats obtenus dans ce fichier (section Temps/Confiance) et vérifier à la main que le rapport correspond bien aux règles métier.

## Apprentissage

_(à compléter au fil du projet)_

## Challenge

_(à compléter)_

## Temps

_(à compléter)_

## Confiance

_(à compléter)_
