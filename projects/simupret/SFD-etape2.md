# SFD — Étape 2 : Tableau d'amortissement complet

**Projet :** Projet 5 — Simulateur de prêt bancaire (`simupret`)
**Étape :** 2 / 7 — Génération de l'échéancier
**Statut :** terminé

## 1. Objectif

Générer l'échéancier complet du prêt : pour chaque mensualité, la répartition entre part d'intérêts et part de capital remboursé, ainsi que le capital restant dû. La mensualité elle-même reste constante (calculée à l'Étape 1) ; ce qui varie d'une échéance à l'autre, c'est la répartition intérêts/capital.

## 2. Rappel du principe (amortissement à annuités constantes)

Pour chaque échéance `i` (de 1 à `n`) :

```
Intérêts(i)          = CapitalRestant(i-1) × t
PartCapital(i)        = Mensualité − Intérêts(i)
CapitalRestant(i)      = CapitalRestant(i-1) − PartCapital(i)
```

avec `CapitalRestant(0) = Capital emprunté` et `t` = taux mensuel.

Mécaniquement : la part d'intérêts diminue à chaque échéance (le capital restant dû diminue), donc la part de capital remboursé augmente d'autant — la mensualité, elle, ne change pas.

## 3. Structure de données

### 3.1 Copybook `TAUXPRET.cpy` (nouveau, remplace le paramètre `LK-TAUX-INTERET` isolé)

Décision actée : le taux annuel et le taux mensuel sont désormais regroupés dans un même enregistrement, calculés une seule fois dans `EVALTAUX`, puis transmis tel quel aux sous-programmes qui en ont besoin (`CALCMENS`, `GENAMORT`) — plus de recalcul ni de duplication de la formule taux annuel → taux mensuel.

```cobol
01 TAUX-INTERET.
   05 TAUX-ANNUEL   PIC 9(2)V99.
   05 TAUX-MENSUEL  PIC 9V9(5).
```

### 3.2 Copybook `ECHEANCIER.cpy` (nouveau)

```cobol
01 TABLE-ECHEANCIER.
   05 NB-ECHEANCES        PIC 9(4).
   05 ECHEANCE OCCURS 1 TO 1200 TIMES
                DEPENDING ON NB-ECHEANCES
                INDEXED BY IDX-ECH.
      10 NUM-ECHEANCE        PIC 9(4).
      10 CAPITAL-DEBUT       PIC 9(6)V99.
      10 INTERETS-PERIODE    PIC 9(6)V99.
      10 CAPITAL-REMBOURSE   PIC 9(6)V99.
      10 CAPITAL-FIN         PIC 9(6)V99.
```

`1200` = borne haute large (100 ans × 12) cohérente avec `DUREE-PRET-ANNEE PIC 99` (max 99 ans → max 1188 mensualités). **Notion nouvelle à mobiliser :** `OCCURS ... DEPENDING ON` — une table dont le nombre d'occurrences réellement utilisées est piloté par une variable (`NB-ECHEANCES`), pas fixe comme les `OCCURS n TIMES` déjà vus.

## 4. Évolution de l'architecture

- **`EVALTAUX`** change de responsabilité : il ne calcule plus seulement le taux annuel, il calcule et retourne l'enregistrement `TAUX-INTERET` complet (annuel + mensuel). Son `LINKAGE SECTION` et son interface d'appel changent en conséquence — `simupret.cob` devra être ajusté pour recevoir ce nouveau record au lieu d'un simple champ.
- **`CALCMENS`** reçoit désormais `TAUX-INTERET` (ou au moins `TAUX-MENSUEL`) au lieu de recalculer le taux mensuel lui-même en interne — à toi de voir si tu gardes son calcul interne actuel ou si tu le fais consommer directement le champ transmis.
- **`GENAMORT`** (nouveau sous-programme) reçoit le capital, la mensualité, `TAUX-INTERET`, et remplit `TABLE-ECHEANCIER`.

```
simupret.cob
  → EVALTAUX   (modifié : calcule TAUX-ANNUEL + TAUX-MENSUEL)
  → CALCMENS   (modifié : consomme TAUX-MENSUEL au lieu de le recalculer)
  → GENAMORT   (nouveau : remplit TABLE-ECHEANCIER)
```

## 5. Données de sortie (cette étape)

Toujours pas de fichier ni de format structuré (Étape 3) — un affichage console de l'échéancier complet suffit pour valider visuellement le résultat.

## 6. Contraintes techniques / points de vigilance

- **`OCCURS ... DEPENDING ON` (ODO) et `LINKAGE SECTION`** : la variable qui pilote le nombre d'occurrences (`NB-ECHEANCES`) doit être renseignée **avant** que la table soit manipulée ou passée en paramètre — sinon le runtime ne sait pas combien d'occurrences sont valides.
- **Dérive d'arrondi cumulative** : chaque arrondi sur les intérêts/part de capital d'une échéance introduit un micro-écart (fraction de centime) par rapport au calcul théorique exact. Sur un échéancier de 240 lignes, ces écarts peuvent s'accumuler et faire que le capital restant dû de la dernière échéance ne tombe pas exactement à `0.00`. **C'est un comportement attendu à cette étape** (pas un bug à corriger maintenant) — les vrais systèmes bancaires ajustent la dernière mensualité pour compenser ; à backlogger explicitement si tu veux le traiter dans une étape ultérieure.
- **Taille de la table** : `1200` occurrences × 5 champs numériques n'est pas énorme, mais reste conscient que la table est allouée en mémoire pour sa taille maximale déclarée, pas seulement pour `NB-ECHEANCES` réellement utilisé — normal en COBOL, à savoir plutôt qu'à corriger.
- **Cohérence entre programmes** : `EVALTAUX`, `CALCMENS` et `GENAMORT` doivent tous les trois déclarer `TAUX-INTERET` de façon identique (via `COPY` du même copybook) — rappel du point déjà noté sur `systpaii` : COBOL ne vérifie aucune correspondance de signature entre appelant et appelé, une divergence de déclaration entre deux programmes serait une erreur silencieuse.

## 7. Cas de test attendus

Reprends un cas déjà validé à l'Étape 1 pour vérifier la cohérence :

- **Auto, 25 000,00 €, 5 ans (60 mensualités), taux 3,20 %, mensualité 451,36 €** (déjà vérifié à l'Étape 1)
  - Échéance 1 : intérêts = 25 000,00 × taux mensuel — calcule la valeur toi-même pour comparer
  - Échéance 60 (dernière) : le capital restant dû doit être proche de `0.00` (à la dérive d'arrondi près, voir section 6)
  - Vérifie que la somme des parts de capital remboursées sur les 60 échéances est proche du capital initial (25 000,00 €)

## 8. Hors périmètre de cette étape

- Format de sortie structuré exploitable par un autre programme (Étape 3)
- Correction de la dérive d'arrondi sur la dernière échéance (backlog potentiel, pas demandé ici)
- Validation des données d'entrée (toujours backloggée, cohérent avec `systpaii`)

## Questions ouvertes

_(à compléter par toi au fil du développement — pose-les ici ou directement en conversation)_
