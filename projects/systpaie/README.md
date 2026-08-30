# Système de Paie — Calcul Brut → Net

Programme COBOL qui lit une liste d'employés depuis un fichier, calcule le salaire net de chacun (cotisations sociales + impôt simplifié par tranches), et écrit un rapport de sortie.

Version actuelle (V2) : lecture multi-employés depuis `employes.dat` (format ligne fixe), traitement au fil de l'eau (lecture → calcul → écriture, un employé à la fois), écriture du rapport dans `rapport-fp.txt`.

## Évolution du programme

**V1** : un seul employé, données codées en dur (pas de fichier, pas de saisie utilisateur).

## Règles métier

1. **Cotisations sociales** : 22 % du brut
   `Cotisations = Brut × 0.22`
2. **Base imposable** : brut moins cotisations
   `Base imposable = Brut − Cotisations`
3. **Taux d'impôt par tranche** (appliqué à toute la base imposable — barème simplifié, pas un vrai barème progressif par palier) :

   | Base imposable   | Taux |
   | ---------------- | ---- |
   | ≤ 1500 €         | 0 %  |
   | 1500,01 – 3000 € | 11 % |
   | 3000,01 – 6000 € | 30 % |
   | > 6000 €         | 41 % |

4. **Impôt** : `Impôt = Base imposable × Taux`
5. **Net à payer** : `Net = Base imposable − Impôt`

## Prérequis

- [GnuCOBOL](https://gnucobol.sourceforge.io/) installé (`cobc --version` pour vérifier)
- Un fichier `employes.dat` présent dans le dossier (format : prénom `PIC X(25)`, nom `PIC X(25)`, salaire brut `PIC 9(5)V99`, une ligne par employé)

## Compilation & exécution

```bash
cobc -std=ibm -xj systpaie.cob
```

Ou en deux étapes :

```bash
cobc -std=ibm -x systpaie.cob -o systpaie
./systpaie
```

`-std=ibm` aligne le compilateur sur le dialecte Enterprise COBOL (z/OS) plutôt que le dialecte GnuCOBOL par défaut — notamment, `DISPLAY` d'un champ `PIC 9(5)V99` n'insère pas de point décimal (décimale implicite, comme sur mainframe).

Le programme lit `employes.dat`, affiche le nombre d'employés traités, et génère `rapport-fp.txt` (fichier gitignoré, régénérable à chaque exécution).

## Exemple de sortie

Extrait de `rapport-fp.txt` pour un employé (brut 3200,00 — tranche à 11 %) :

```
-----------------------------
------ FICHE DE PAIE --------
-----------------------------
- NOM : DUPONT
- PRENOM : JEAN
-----------------------------
- SALAIRE BRUT     : 0320000
--
- COTISATIONS      : 0070400
- BASE IMPOSABLE   : 0249600
- TAUX IMPOT       : 11%
- IMPOT            : 0027456
--
- SALAIRE NET      : 0222144
-----------------------------
```

## Concepts démontrés

- Structures / records (`01`, `05`) pour modéliser un employé et ses calculs
- `PICTURE` pour les montants décimaux (`9(5)V99`)
- `COMPUTE` pour les calculs arithmétiques
- `EVALUATE TRUE` pour sélectionner une tranche d'imposition
- `FUNCTION TRIM` pour l'affichage des chaînes
- Fichiers séquentiels : `OPEN`/`READ`/`WRITE`/`CLOSE`, `FILE STATUS`
- `PERFORM UNTIL` + `AT END`/`NOT AT END` pour boucler sur un fichier
- `STRING`/`INITIALIZE` pour construire les lignes du rapport
- `PERFORM nom-paragraphe` pour factoriser l'écriture (paragraphe `2000-WRITE-RECORDS`)

## Limites connues / à venir

- Traitement au fil de l'eau (pas de table en mémoire via `OCCURS`) — choix assumé pour ce projet
- Pas de gestion d'erreurs `FILE STATUS` avancée (fichier absent, erreur de lecture)
