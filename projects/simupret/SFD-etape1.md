# SFD — Étape 1 : Calcul de la mensualité de prêt

**Projet :** Projet 5 — Simulateur de prêt bancaire (`simupret`)
**Étape :** 1 / 7 — Service COBOL, calcul de mensualité
**Statut :** à développer

## 1. Objectif

Calculer la mensualité d'un prêt à taux fixe et annuités constantes, à partir d'une demande de prêt. Le taux d'intérêt annuel n'est **pas saisi** par le client : il est déterminé par le programme selon le type de prêt et la durée demandée (règle de gestion, section 4).

## 2. Données d'entrée — copybook `DEMPRET.cpy`

Le copybook actuel doit être revu : `TAUX-INTERET-ANNUEL` retiré de la demande (ce n'est plus une saisie), remplacé par un champ de profil `TYPE-PRET`.

```cobol
01 DEMANDE-PRET.
   05 TYPE-PRET            PIC X.
      88 PRET-IMMOBILIER   VALUE 'I'.
      88 PRET-AUTO         VALUE 'A'.
      88 PRET-CONSOMMATION VALUE 'C'.
   05 CAPITAL              PIC 9(6)V99.
   05 DUREE-EMPRUNT-ANNEE  PIC 99.
```

| Champ | Description | Contrainte |
|---|---|---|
| `TYPE-PRET` | Catégorie de prêt | `I`, `A` ou `C` uniquement (pas de contrôle de saisie à cette étape — voir backlog validation, comme sur `systpaii`) |
| `CAPITAL` | Montant emprunté | > 0, jusqu'à 999 999,99 |
| `DUREE-EMPRUNT-ANNEE` | Durée du prêt en années | > 0, jusqu'à 99 |

## 3. Données de sortie

Pas de fichier à cette étape — affichage `DISPLAY` suffisant (le format d'échange structuré est traité à l'Étape 3). Afficher au minimum :

- Le taux annuel déterminé (`TAUX-INTERET-ANNUEL`, calculé, pas saisi)
- Le taux mensuel utilisé dans le calcul
- La mensualité calculée (`MENSUALITE`)

## 4. Règles de gestion — détermination du taux annuel

Le taux dépend du **type de prêt** et de la **durée**. Grille de taux (fictive, à but pédagogique) :

| Type de prêt | Durée | Taux annuel |
|---|---|---|
| Immobilier (`I`) | ≤ 15 ans | 3,10 % |
| Immobilier (`I`) | 16 à 20 ans | 3,45 % |
| Immobilier (`I`) | 21 ans et + | 3,80 % |
| Auto (`A`) | ≤ 3 ans | 2,90 % |
| Auto (`A`) | 4 à 5 ans | 3,20 % |
| Auto (`A`) | 6 ans et + | 3,60 % |
| Consommation (`C`) | ≤ 2 ans | 4,50 % |
| Consommation (`C`) | 3 à 4 ans | 5,20 % |
| Consommation (`C`) | 5 ans et + | 6,00 % |

À implémenter via `EVALUATE TRUE`, avec des conditions combinant `TYPE-PRET` (ou les niveaux `88`) et `DUREE-EMPRUNT-ANNEE` — comme pour les tranches d'impôt de `systpaie`, mais sur deux critères au lieu d'un seul.

## 5. Règle de calcul — mensualité

```
M = C × (t / (1 - (1 + t) ** -n))
```

- `C` = `CAPITAL`
- `t` = taux mensuel = taux annuel déterminé (section 4) / 12 / 100
- `n` = nombre de mensualités = `DUREE-EMPRUNT-ANNEE` × 12
- `M` = `MENSUALITE`, résultat arrondi à 2 décimales (`ROUNDED`)

**Notion nouvelle à mobiliser :** l'opérateur `**` dans un `COMPUTE` pour l'exponentiation, y compris avec un exposant négatif (`-n`).

## 6. Contraintes techniques / points de vigilance

- Prévoir suffisamment de décimales sur les champs intermédiaires (taux mensuel, base de l'exposant) pour ne pas perdre de précision avant l'exponentiation — un `PIC` trop court peut tronquer le taux mensuel et fausser tout le résultat.
- Isoler le calcul `(1 + t) ** -n` dans une variable intermédiaire avant de l'utiliser dans le `COMPUTE` final, pour pouvoir vérifier chaque étape en cas de résultat incohérent.
- Tester `**` avec un exposant négatif isolément (petit programme jetable ou `DISPLAY` intermédiaire) si le résultat semble faux, avant de suspecter la formule elle-même.

## 7. Cas de test attendus

| # | Type | Capital | Durée | Taux attendu | Mensualité attendue (à vérifier par toi) |
|---|---|---|---|---|---|
| 1 | Immobilier | 200 000,00 | 20 ans | 3,45 % | — |
| 2 | Immobilier | 150 000,00 | 10 ans | 3,10 % | — |
| 3 | Auto | 25 000,00 | 5 ans | 3,20 % | — |
| 4 | Consommation | 8 000,00 | 3 ans | 5,20 % | — |
| 5 | Consommation | 3 000,00 | 1 an | 4,50 % | — |

Calcule la mensualité attendue toi-même (avec une calculatrice/tableur) avant de lancer le programme, pour avoir une référence indépendante de vérification.

## 8. Hors périmètre de cette étape

- Contrôle de saisie / validation des champs (voir backlog validation, cohérent avec la décision prise sur `systpaii`)
- Génération du tableau d'amortissement (Étape 2)
- Tout format de sortie structuré exploitable par un autre programme (Étape 3)

## Questions ouvertes

*(à compléter par toi au fil du développement — pose-les ici ou directement en conversation)*
