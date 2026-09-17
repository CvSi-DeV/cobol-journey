# Simulateur de Prêt Bancaire — vers une API COBOL → REST (Projet 5)

Simulateur de prêt bancaire, développé progressivement des notions déjà maîtrisées vers de nouvelles, en vue d'exposer terme un service COBOL via une API REST (wrapper Java, Docker, tests Postman). Correspond au Projet 5 du plan de formation (Semaine 7-8 : Intégrations Modernes, Option A recommandée — COBOL → API REST).

Le projet est découpé en 7 étapes progressives. **Étape 1 (calcul de mensualité) terminée** ; les étapes suivantes (tableau d'amortissement, format d'échange, wrapper Java, exposition HTTP, Docker, Postman) sont à venir. Chaque étape fait l'objet d'une spécification dédiée (`SFD-etapeN.md`).

## Étape 1 — Calcul de la mensualité

Calcule la mensualité d'un prêt à taux fixe et annuités constantes à partir d'une demande de prêt (type, capital, durée). Le taux d'intérêt annuel n'est pas saisi par le client : il est déterminé par le programme selon le type de prêt et la durée demandée. Spécification complète : [`SFD-etape1.md`](SFD-etape1.md).

### Architecture

| Fichier         | Rôle                                                                                          |
| --------------- | ----------------------------------------------------------------------------------------------|
| `simupret.cob`  | Orchestrateur : saisie interactive de la demande, appels aux sous-programmes, affichage        |
| `dempret.cpy`   | Copybook — structure de la demande de prêt (`TYPE-PRET` avec niveaux 88, `CAPITAL`, `DUREE-PRET-ANNEE`) |
| `tauxinter.cpy` | Copybook — enregistrement `TAUX-INTERET` (`TAUX-ANNUEL`/`TAUX-MENSUEL`), calculé une fois dans `evaltaux.cob` et partagé tel quel avec `calcmens.cob` (via `COPY ... REPLACING` pour adapter le préfixe par programme) |
| `evaltaux.cob`  | Sous-programme — détermination du taux annuel et mensuel selon le profil (type de prêt × tranche de durée) |
| `calcmens.cob`  | Sous-programme — calcul de la mensualité (formule d'annuités constantes)                       |

Chaque sous-programme est compilé en module (`.dylib` sur macOS) et appelé depuis `simupret.cob` via `CALL 'NOM' USING ...`, `LINKAGE SECTION` pour recevoir les paramètres — même pattern que `systpaii` (Projet 4).

### Règles métier — grille de taux

| Type de prêt        | Durée         | Taux annuel |
| -------------------- | ------------- | ----------- |
| Immobilier (`I`)     | ≤ 15 ans      | 3,10 %      |
| Immobilier (`I`)     | 16 à 20 ans   | 3,45 %      |
| Immobilier (`I`)     | 21 ans et +   | 3,80 %      |
| Auto (`A`)           | ≤ 3 ans       | 2,90 %      |
| Auto (`A`)           | 4 à 5 ans     | 3,20 %      |
| Auto (`A`)           | 6 ans et +    | 3,60 %      |
| Consommation (`C`)   | ≤ 2 ans       | 4,50 %      |
| Consommation (`C`)   | 3 à 4 ans     | 5,20 %      |
| Consommation (`C`)   | 5 ans et +    | 6,00 %      |

Grille fictive, à but pédagogique. Formule de mensualité :

```
M = C × (t / (1 - (1 + t) ** -n))
```

où `C` = capital emprunté, `t` = taux mensuel (taux annuel / 12 / 100), `n` = nombre de mensualités (durée en années × 12).

### Prérequis

- [GnuCOBOL](https://gnucobol.sourceforge.io/) installé (`cobc --version`)
- `make`

### Compilation & exécution

```bash
make            # compile les modules (-m) puis l'exécutable (-x)
make run        # équivaut à : make simupret && ./simupret
make clean      # supprime l'exécutable et les modules compilés (.dylib)
```

Saisie interactive : type de prêt (`A`/`C`/`I`), capital emprunté (montant entier, ex: `200000` pour 200 000,00 €), durée en années.

### Exemple d'exécution

Session réelle (prêt immobilier, 200 000,00 €, 20 ans) :

```
Bienvenue dans le simulateur de pret.
   Veuillez saisir le type de pret :
      - A pour Pret AUTO 🚘
      - C pour Pret CONSO 🛍️
      - I pour Pret IMMO 🏠
   Veuillez saisir le montant emprunté :
      (max 999 999.99)
   Veuillez saisir la durée du pret (années) :
📈 Le taux annuel est de :  3.45 %
📈 Le taux mensuel est de : 0.0028750 %
💰 La mensualité est de   1154.79
```

Autres cas vérifiés (résultats confirmés à ±0,01 € près par un calcul indépendant, après correction de précision sur `TAUX-MENSUEL` — voir `simupret-project.md`) :

| Type         | Capital     | Durée  | Taux   | Mensualité |
| ------------ | ----------- | ------ | ------ | ---------- |
| Immobilier   | 200 000,00 € | 20 ans | 3,45 % | 1 154,79 € |
| Auto         | 25 000,00 €  | 5 ans  | 3,20 % | 451,44 €   |
| Consommation | 8 000,00 €   | 3 ans  | 5,20 % | 240,49 €   |

## Concepts démontrés (Étape 1)

- Opérateur d'exponentiation `**` dans un `COMPUTE`
- `EVALUATE TRUE ALSO TRUE` avec niveaux 88 combinés sur deux champs distincts, pour une grille de décision à deux critères
- Sous-programmes (`CALL`/`LINKAGE SECTION`), copybook de structure de données partagée, `COPY ... REPLACING` pour adapter les noms de champs au préfixe de chaque programme
- `ROUNDED` sur un `COMPUTE` final pour un résultat monétaire — précision réglementaire en contexte bancaire/assurance
- `ROUNDED` et nombre de décimales du `PICTURE` sont deux leviers indépendants : un taux mensuel stocké avec trop peu de décimales (`PIC 9V9(5)`) reste imprécis même arrondi, et l'erreur s'amplifie avec l'exponentiation sur un prêt long — corrigé en élargissant le `PICTURE` (`9V9(7)`), pas seulement en ajoutant `ROUNDED`

## Limites connues / à venir

- Pas de validation complète des données saisies au-delà d'un contrôle "non nul" — cohérent avec la décision déjà prise sur `systpaii` (validation backloggée pour un futur projet)
- Pas encore de tableau d'amortissement, de format d'échange structuré, ni d'exposition HTTP — objet des étapes suivantes du Projet 5
