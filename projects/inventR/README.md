# Gestionnaire d'Inventaire

Programme COBOL qui traite des commandes sur un stock de produits : il lit un fichier de produits et un fichier de commandes, vérifie pour chaque commande que le produit existe et que le stock est suffisant, puis écrit un rapport (acceptée/refusée, motif de refus le cas échéant, et stock restant).

Le programme charge les produits et les commandes en mémoire dans des tables (`OCCURS`), croise les deux pour chaque commande, et gère la lecture de deux fichiers séquentiels.

## Règles métier

1. **Produit inconnu** : le code produit de la commande n'existe dans aucun enregistrement du fichier produits → commande **REFUSÉE**.
2. **Stock insuffisant** : quantité commandée > quantité en stock → commande **REFUSÉE**.
3. **Commande acceptée** : stock suffisant → le stock restant est calculé (`stock − quantité commandée`) et reporté → commande **ACCEPTÉE**.

## Prérequis

- [GnuCOBOL](https://gnucobol.sourceforge.io/) installé (`cobc --version` pour vérifier)
- Les fichiers `produits.dat` et `commandes.dat` présents dans le dossier :
  - `produits.dat` : `CODE-PRODUIT PIC X(6)` + `DESIGNATION PIC X(20)` + `QUANTITE-STOCK PIC 9(5)` + `PRIX-UNITAIRE PIC 9(5)V99` (38 caractères/ligne, format fixe, pas de séparateur)
  - `commandes.dat` : `CODE-PRODUIT PIC X(6)` + `QUANTITE-COMMANDEE PIC 9(5)` (11 caractères/ligne)

## Compilation & exécution

```bash
cobc -std=ibm -xj inventR.cob
```

Ou en deux étapes :

```bash
cobc -std=ibm -x inventR.cob -o inventR
./inventR
```

Le programme affiche le nombre de produits et de commandes chargés, puis génère `rapport-inventaire.txt` (fichier gitignoré, régénérable à chaque exécution).

## Exemple de sortie

Extrait de `rapport-inventaire.txt` sur le jeu de données fourni :

```
ACCEPTEE PROD01CLAVIER MECANIQUE   00040
ACCEPTEE PROD02SOURIS SANS FIL     00000
REFUSEE  PROD03ECRAN 27 POUCES     00003
REFUSEE  PROD99Produit Non trouve  00000
```

Couvre les 3 règles métier, dont un cas limite (commande qui vide exactement le stock disponible).

## Concepts démontrés

- `OCCURS ... DEPENDING ON ... INDEXED BY` pour charger produits et commandes dans des tables de taille variable
- Lecture de deux fichiers séquentiels en parallèle, avec un `FILE STATUS` distinct par fichier
- Recherche dans une table via boucle indexée (`PERFORM VARYING ... INDEXED BY`)
- `IN` pour qualifier un nom de champ ambigu entre deux records

Développé avec relecture systématique et validation sur 4 cas de test couvrant chaque règle métier, dont un cas limite.

## Limites connues / à venir

- Fichiers séquentiels uniquement — organisation `INDEXED`/`RELATIVE` (accès direct par clé) non traitée sur ce projet.
- Gestion d'erreurs `FILE STATUS` limitée au cas "fichier absent" ; pas de gestion des erreurs de lecture/écriture au-delà de la fin de fichier.
