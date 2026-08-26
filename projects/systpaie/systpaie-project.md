# Système de Paie — Progress Tracker

## Apprentissage

- EVALUATE
- Structure / Record
- LESS THAN OR EQUAL TO

## Challenge

comprendre le concept de déclaration de structure hierarchique.

### Objectif

Programme COBOL qui calcule le salaire **brut → net** d'un employé, avec cotisations sociales et impôt simplifié par tranches. Version simple (semaine 2 du plan) : un seul employé, données codées en dur (pas de fichier, pas de saisie utilisateur — ça viendra au Projet 3/4).

### Structure de données suggérée

```cobol
       WORKING-STORAGE SECTION.
       01  WS-EMPLOYE.
           05 WS-NOM             PIC X(30).
           05 WS-BRUT            PIC 9(6)V99.

       01  WS-CALCULS.
           05 WS-COTISATIONS     PIC 9(6)V99.
           05 WS-BASE-IMPOSABLE  PIC 9(6)V99.
           05 WS-TAUX-IMPOT      PIC 9V999.
           05 WS-IMPOT           PIC 9(6)V99.
           05 WS-NET             PIC 9(6)V99.
```

### Règles métier (simplifiées pour l'exercice)

1. **Cotisations sociales** : 22 % du brut.
   `Cotisations = Brut × 0.22`
2. **Base imposable** : brut moins cotisations.
   `Base imposable = Brut − Cotisations`
3. **Taux d'impôt par tranche** (appliqué à toute la base imposable — simplification volontaire, pas un vrai barème progressif par palier) :

   | Base imposable   | Taux |
   | ---------------- | ---- |
   | ≤ 1500 €         | 0 %  |
   | 1500,01 – 3000 € | 11 % |
   | 3000,01 – 6000 € | 30 % |
   | > 6000 €         | 41 % |

4. **Impôt** : `Impôt = Base imposable × Taux`
5. **Net à payer** : `Net = Base imposable − Impôt`

### Notions à mobiliser (déjà vues en playground)

- `PICTURE` pour les montants décimaux (`V99`) — déjà fait.
- `EVALUATE` pour choisir la tranche — déjà fait (pair/impair).
- **Nouveau : `COMPUTE`** pour les calculs arithmétiques, ex :
  ```cobol
  COMPUTE WS-COTISATIONS = WS-BRUT * 0.22
  ```
  Plus lisible que `MULTIPLY`/`ADD`/`SUBTRACT` séparés dès qu'il y a plusieurs opérations.

### Affichage attendu (fiche de paie simplifiée)

```
FICHE DE PAIE - Jean Pierre
Brut            :   3500.00
Cotisations     :    770.00
Base imposable  :   2730.00
Taux impot      :      0.11
Impot           :    300.30
NET A PAYER     :   2429.70
```

### Tests à documenter

Tester au moins 4 valeurs de brut pour valider chaque branche de l'`EVALUATE` (une par tranche) :

- Un brut donnant une base imposable ≤ 1500 € (tranche à 0 %)
- Un brut donnant une base imposable entre 1500 et 3000 €
- Un brut donnant une base imposable entre 3000 et 6000 €
- Un brut donnant une base imposable > 6000 €

Noter les résultats obtenus dans ce fichier (section Apprentissage/Temps) pour vérifier qu'ils sont cohérents à la main (calcul de contrôle au brouillon ou tableur).

### Hors scope pour cette version (à venir plan Semaine 3-4)

- Lire plusieurs employés depuis un fichier (`OCCURS`, tables).
- Écrire un rapport de sortie.

## Temps

- 1h30

## Confiance

- 9/10

## RESULTATS D'EXECUTION

```
--------------------------
----- FICHE DE PAIE ------
--------------------------
- NOM : CONTRIB
- PRENOM : MICHELE
--------------------------
- SALAIRE BRUT     :01420.00
--
- COTISATIONS      :00312.40
- BASE IMPOSABLE   :01107.60
- TAUX IMPOT       :00%
- IMPOT            :00000.00
--
- SALAIRE NET      :01107.60
--------------------------

--------------------------
----- FICHE DE PAIE ------
--------------------------
- NOM : CONTRIB
- PRENOM : MICHELE
--------------------------
- SALAIRE BRUT     :03200.00
--
- COTISATIONS      :00704.00
- BASE IMPOSABLE   :02496.00
- TAUX IMPOT       :11%
- IMPOT            :00274.56
--
- SALAIRE NET      :02221.44
--------------------------

--------------------------
----- FICHE DE PAIE ------
--------------------------
- NOM : CONTRIB
- PRENOM : MICHELE
--------------------------
- SALAIRE BRUT     :06400.00
--
- COTISATIONS      :01408.00
- BASE IMPOSABLE   :04992.00
- TAUX IMPOT       :30%
- IMPOT            :01497.60
--
- SALAIRE NET      :03494.40
--------------------------

--------------------------
----- FICHE DE PAIE ------
--------------------------
- NOM : CONTRIB
- PRENOM : MICHELE
--------------------------
- SALAIRE BRUT     :08000.00
--
- COTISATIONS      :01760.00
- BASE IMPOSABLE   :06240.00
- TAUX IMPOT       :41%
- IMPOT            :02558.40
--
- SALAIRE NET      :03681.60
--------------------------
```
