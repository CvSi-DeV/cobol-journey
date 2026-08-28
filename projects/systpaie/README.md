# Système de Paie — Calcul Brut → Net

Programme COBOL qui calcule le salaire net d'un employé à partir du salaire brut, avec cotisations sociales et impôt simplifié par tranches.

Version actuelle : un seul employé, données codées en dur (pas de fichier, pas de saisie utilisateur).

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

## Exemple de sortie

Pour le brut actuellement codé en dur (8000,00 — tranche à 41 %), compilé avec `-std=ibm` :

```
-----------------------------
------ FICHE DE PAIE --------
-----------------------------
- NOM : CONTRIB
- PRENOM : MICHELE
-----------------------------
- SALAIRE BRUT     : 0800000
--
- COTISATIONS      : 0176000
- BASE IMPOSABLE   : 0624000
- TAUX IMPOT       : 41%
- IMPOT            : 0255840
--
- SALAIRE NET      : 0368160
-----------------------------
```

Sans `-std=ibm`, le même montant s'afficherait `08000.00` (point décimal inséré par le dialecte GnuCOBOL par défaut).

## Concepts démontrés

- Structures / records (`01`, `05`) pour modéliser un employé et ses calculs
- `PICTURE` pour les montants décimaux (`9(5)V99`)
- `COMPUTE` pour les calculs arithmétiques
- `EVALUATE TRUE` pour sélectionner une tranche d'imposition
- `FUNCTION TRIM` pour l'affichage des chaînes

## Limites connues / à venir

- Un seul employé, données codées en dur
- Pas de lecture de fichier ni de saisie utilisateur
- Traitement multi-employés (fichier, `OCCURS`, tables) et rapport de sortie prévus dans un prochain projet
