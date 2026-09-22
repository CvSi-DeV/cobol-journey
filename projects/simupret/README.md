# Simulateur de Prêt Bancaire — vers une API COBOL → REST (Projet 5)

Simulateur de prêt bancaire, développé progressivement des notions déjà maîtrisées vers de nouvelles, en vue d'exposer terme un service COBOL via une API REST (wrapper Java, Docker, tests Postman). Correspond au Projet 5 du plan de formation (Semaine 7-8 : Intégrations Modernes, Option A recommandée — COBOL → API REST).

Le projet est découpé en 7 étapes progressives. **Étapes 1 (calcul de mensualité), 2 (tableau d'amortissement) et 3 (export JSON) terminées** ; les étapes suivantes (wrapper Java, exposition HTTP, Docker, Postman) sont à venir. Chaque étape fait l'objet d'une spécification dédiée (`SFD-etapeN.md`).

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

## Étape 2 — Tableau d'amortissement

Génère l'échéancier complet du prêt : pour chaque mensualité, la répartition entre intérêts et capital remboursé, et le capital restant dû. Spécification complète : [`SFD-etape2.md`](SFD-etape2.md).

### Architecture (ajouts)

| Fichier         | Rôle                                                                                          |
| --------------- | ----------------------------------------------------------------------------------------------|
| `echeance.cpy`  | Copybook — table `ECHEANCIER` à occurrences variables (`OCCURS 1 TO 1200 DEPENDING ON NB-ECHEANCES`), une occurrence par échéance |
| `geneeche.cob`  | Sous-programme — génère l'échéancier ligne par ligne (intérêts, part de capital, capital restant dû) |

### Exemple d'exécution (cas Auto, 25 000 €, 5 ans)

```
Capital précédent :  25000.00
Interet echeance :      66.67
Capital remboursé :    384.77
Capital restant :   24615.23
...
Capital précédent :     45.04
Interet echeance :       0.12
Capital remboursé :     45.02
Capital restant :        0.13
```

| Cas | Échéances | Somme intérêts | Somme capital remboursé |
| --- | --- | --- | --- |
| Auto (25 000 €, 5 ans) | 60 | 2 086,53 € | 24 999,87 € |
| Immobilier (200 000 €, 20 ans) | 240 | 77 148,73 € | 200 000,87 € |
| Consommation (8 000 €, 3 ans) | 36 | 657,49 € | 8 000,15 € |

### Concepts démontrés (Étape 2)

- `OCCURS ... DEPENDING ON` — table à occurrences variables ("pseudo-dynamique" : mémoire allouée pour la borne max, portion logiquement valide pilotée par un compteur), `INDEXED BY` pour l'index de parcours
- `PERFORM TEST AFTER VARYING ... UNTIL x = borne` — variante post-test qui traite les occurrences 1 à N inclus
- `COPY ... REPLACING` réutilisé pour un second copybook partagé entre plusieurs sous-programmes

### Limite connue à l'Étape 2 — masquage de signe sur `CAPITAL-RESTANT`

Sur les prêts longs, la dérive d'arrondi cumulée peut aboutir à un léger sur-remboursement (ex: +0,87 € sur 240 échéances). Le résultat mathématique réel de la dernière échéance est alors négatif, mais `CAPITAL-RESTANT` était déclaré `PIC 9(6)V99` (non signé) : COBOL stockait silencieusement la valeur absolue, sans erreur. **Corrigé à l'Étape 3** (voir ci-dessous).

## Étape 3 — Export JSON

Assemble un document JSON unique (demande + taux + mensualité + échéancier) exploitable par un programme externe — préparation directe du wrapper Java de l'Étape 4. Spécification complète : [`SFD-etape3.md`](SFD-etape3.md).

### Architecture (ajouts)

| Fichier         | Rôle                                                                                          |
| --------------- | ----------------------------------------------------------------------------------------------|
| `genejson.cob`  | Sous-programme — génère le JSON complet (`JSON GENERATE` pour demande/taux/mensualité, construction manuelle via `STRING` pour l'échéancier) et l'écrit dans un fichier `LINE SEQUENTIAL` |

### Correction — signe de `CAPITAL-RESTANT`

`CAPITAL-RESTANT` (dans `echeance.cpy`) passé en `PIC S9(6)V99` (champ signé), conformément à l'exigence de la SFD. Revérifié sur les 3 cas de test : le signe négatif apparaît désormais correctement en cas de sur-remboursement.

### Limite GnuCOBOL confirmée — `JSON GENERATE` et `OCCURS`

GnuCOBOL ne supporte pas les éléments `OCCURS` dans `JSON GENERATE` (warning `[-Wpending]` à la compilation ; seule la première occurrence serait exportée, silencieusement) — limitation connue et non résolue du projet GnuCOBOL, confirmée par test isolé et par la documentation communautaire. Contournée en générant le tableau d'échéances manuellement (boucle + `STRING`), tout en gardant `JSON GENERATE` pour les parties sans tableau.

### Exemple de sortie (extrait, cas Immobilier)

```json
{
  "DEMANDE-PRET": { "TYPE-PRET": "I", "CAPITAL": 200000.0, "DUREE-PRET-ANNEE": 20 },
  "TAUX-INTERET": { "TAUX-ANNUEL": 3.45, "TAUX-MENSUEL": 0.002875 },
  "MENSUALITE": 1154.79,
  "ECHEANCIER": {
    "NB-ECHEANCES": 240,
    "ECHEANCES": [
      { "NUM-ECHEANCE": 1, "CAPITAL-PREC": 200000.0, "INTERET-ECHEANCE": 575.0, "CAPITAL-REMBOURSE": 579.79, "CAPITAL-RESTANT": 199420.21 },
      ...
      { "NUM-ECHEANCE": 240, "CAPITAL-PREC": 1150.61, "INTERET-ECHEANCE": 3.31, "CAPITAL-REMBOURSE": 1151.48, "CAPITAL-RESTANT": -0.87 }
    ]
  }
}
```

| Cas | `NB-ECHEANCES` | Mensualité | `CAPITAL-RESTANT` dernière échéance |
| --- | --- | --- | --- |
| Auto (25 000 €, 5 ans) | 60 | 451,44 € | +0,13 € |
| Consommation (8 000 €, 3 ans) | 36 | 240,49 € | -0,15 € (signe corrigé) |
| Immobilier (200 000 €, 20 ans) | 240 | 1 154,79 € | -0,87 € (signe corrigé) |

### Concepts démontrés (Étape 3)

- `JSON GENERATE` (et sa limite réelle avec `OCCURS`, confirmée par test)
- `STRING` ne réinitialise jamais le champ récepteur au-delà de ce qu'il écrit (le "garbage tail"), contrairement à `MOVE` qui réinitialise tout le champ — exploité via `MOVE FUNCTION TRIM(champ) TO champ` pour recompacter un champ sans effet de bord
- `STRING ... WITH POINTER` : le pointeur ne se réinitialise jamais implicitement, doit être remis à 1 avant chaque utilisation
- `ORGANIZATION SEQUENTIAL` vs `LINE SEQUENTIAL` : délimitation des enregistrements, troncature automatique des espaces de fin, adéquation au contenu (texte vs binaire)

## Concepts démontrés (Étape 1)

- Opérateur d'exponentiation `**` dans un `COMPUTE`
- `EVALUATE TRUE ALSO TRUE` avec niveaux 88 combinés sur deux champs distincts, pour une grille de décision à deux critères
- Sous-programmes (`CALL`/`LINKAGE SECTION`), copybook de structure de données partagée, `COPY ... REPLACING` pour adapter les noms de champs au préfixe de chaque programme
- `ROUNDED` sur un `COMPUTE` final pour un résultat monétaire — précision réglementaire en contexte bancaire/assurance
- `ROUNDED` et nombre de décimales du `PICTURE` sont deux leviers indépendants : un taux mensuel stocké avec trop peu de décimales (`PIC 9V9(5)`) reste imprécis même arrondi, et l'erreur s'amplifie avec l'exponentiation sur un prêt long — corrigé en élargissant le `PICTURE` (`9V9(7)`), pas seulement en ajoutant `ROUNDED`

## Limites connues / à venir

- Pas de validation complète des données saisies au-delà d'un contrôle "non nul" — cohérent avec la décision déjà prise sur `systpaii` (validation backloggée pour un futur projet)
- Pas encore de wrapper Java, ni d'exposition HTTP, ni de Docker/Postman — objet des étapes suivantes du Projet 5
