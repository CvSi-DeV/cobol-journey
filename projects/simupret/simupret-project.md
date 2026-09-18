# Simulateur de Prêt Bancaire (Projet 5) — Progress Tracker

## Apprentissage

### COBOL

- Opérateur d'exponentiation `**` dans un `COMPUTE`, y compris avec un exposant théoriquement négatif
- **Piège GnuCOBOL identifié** : appliquer un signe négatif *dans l'expression* (`- LS-NB-MENSUALITE`) sur un champ dont le `PICTURE` est **non signé** (`PIC 9(4)`, sans `S`) ne se propage pas correctement jusqu'à l'opérateur `**` — le résultat retombe à `1` comme si l'exposant valait `0`. Contourné mathématiquement plutôt que par un champ signé intermédiaire : `(1+t)^-n` réécrit en `1 / (1+t)^n`, qui n'a jamais besoin d'exposant négatif.
- `EVALUATE TRUE ALSO TRUE` avec des niveaux `88` combinant deux champs différents (`TYPE-PRET` et `DUREE-PRET`) pour une grille de taux à deux critères — extension du pattern à un seul critère déjà maîtrisé sur `systpaie` (tranches d'impôt).
- `ROUNDED` sur un `COMPUTE` final : sans cette clause, COBOL **tronque** l'excédent de décimales au lieu de l'arrondir — écart potentiel d'1 centime avec une référence de calcul externe qui arrondit, silencieux et facile à manquer si la spec ne le rappelle pas au moment de coder.
- `PICTURE` éditée dédiée à l'affichage (`PIC 9(5).99`, `PIC Z(5)9.99`) séparée du champ de calcul réel — bonne pratique déjà appliquée spontanément, cohérente avec la leçon "group MOVE" du Projet 4.
- **`OCCURS ... DEPENDING ON` (ODO)** : table à occurrences variables (`OCCURS 1 TO 1200 DEPENDING ON NB-ECHEANCES`), la mémoire est allouée pour la borne max mais seule la portion pilotée par le compteur est logiquement valide — "pseudo-dynamique", pas un vrai tableau redimensionnable. `INDEXED BY` associé (index dédié, pas un simple subscript numérique).
- **`PERFORM TEST AFTER VARYING ... UNTIL x = borne`** : variante post-test (exécute d'abord, teste après) qui traite correctement les occurrences 1 à N *inclus* quand la borne est testée par égalité — moins intuitif au premier abord que `TEST BEFORE ... UNTIL x > borne`, mais logiquement équivalent et volontairement choisi.
- **Champ non signé et résultat négatif** : un `COMPUTE` dont le résultat mathématique est négatif, affecté à un champ `PIC 9(n)V99` **sans `S`**, stocke silencieusement la **valeur absolue** — pas d'erreur, pas de troncature du chiffre, juste le signe perdu. Même famille que le piège de l'exposant négatif de l'Étape 1 (champ non signé), mais ici la conséquence est un résultat métier trompeur (un solde semble "dû" alors qu'il est en réalité "créditeur") plutôt qu'un plantage de calcul.
- `COPY ... REPLACING` réutilisé une seconde fois (après `TAUX-INTERET`) pour un deuxième copybook partagé (`ECHEANCIER`) entre plusieurs sous-programmes — pattern maintenant consolidé, pas juste un one-off.

### Outillage

- `.PHONY` est une **cible spéciale** de Make, se déclare avec `:` et non `=` — avec `=`, Make crée simplement une variable ordinaire nommée `.PHONY` (les points sont autorisés dans les noms de variable), et les cibles listées ne sont alors pas réellement protégées contre un fichier homonyme.

## Challenge / Objectif

Étape 1 du Projet 5 (Semaine 7-8 du plan, Option A — COBOL → API REST) : calculer la mensualité d'un prêt à taux fixe et annuités constantes, avec un taux d'intérêt déterminé par le programme selon le profil emprunteur (type de prêt × durée), pas saisi directement. Architecture : orchestrateur `simupret.cob` + sous-programmes `evaltaux.cob` (détermination du taux) et `calcmens.cob` (calcul de mensualité), copybook `dempret.cpy`.

**Étape 2** : générer l'échéancier complet du prêt (répartition intérêts/capital par mensualité, capital restant dû). Nouveau sous-programme `geneeche.cob`, nouveau copybook `echeance.cpy` (table `ECHEANCIER` à occurrences variables). Refacto associé : le taux (annuel + mensuel) regroupé dans un enregistrement partagé `TAUX-INTERET` (`tauxinter.cpy`), calculé une seule fois dans `evaltaux.cob`.

## Bugs rencontrés (récap)

1. **Exposant négatif sur champ non signé ignoré par `**`** — `LS-FACTEUR-CROISSANCE ** (- LS-NB-MENSUALITE)` renvoyait systématiquement `1.0000000000` au lieu de la valeur attendue (~0,85 sur le cas de test). Diagnostiqué par comparaison du code à la formule commentée, confirmé par le symptôme (résultat identique à un exposant nul), contourné en réécrivant la formule sans exposant négatif (`1 / (base ** n)`).
2. **`ROUNDED` manquant sur le `COMPUTE` final de la mensualité** — la SFD l'exigeait explicitement, raté au premier passage, corrigé en revue. A changé le résultat (écart d'arrondi confirmé par l'utilisateur).
3. **`.PHONY = cleanmodule clean` au lieu de `.PHONY : cleanmodule clean`** dans le `Makefile` — cibles listées comme phony non réellement protégées (bug silencieux tant qu'aucun fichier `clean`/`cleanmodule` n'existe dans le dossier).
4. **`PICTURE` insuffisant sur `TAUX-MENSUEL` — `ROUNDED` seul n'a pas suffi** (fix post-clôture, découvert en préparant l'Étape 2). Le refacto du taux en enregistrement partagé `TAUX-INTERET` (`tauxinter.cpy`) a ajouté `ROUNDED` sur le calcul de `TAUX-MENSUEL`, mais le champ restait déclaré en `PIC 9V9(5)` (5 décimales) — insuffisant pour représenter certains taux mensuels sans perte (ex: `3,45 % / 12 = 0,002875`, qui a besoin de 6 décimales). `ROUNDED` n'a fait que déplacer l'erreur d'un côté à l'autre (mensualité passée de 1154,17 € à 1155,41 € au lieu de converger vers la valeur exacte), l'exponentiation `** n` amplifiant l'écart sur les prêts longs (240 mensualités). Diagnostiqué par comparaison à un calcul de référence indépendant (Python), pas par simple relecture de code. Corrigé en passant `TAUX-MENSUEL` à `PIC 9V9(7)` dans `tauxinter.cpy` (propagé à `calcmens.cob`) — les 3 cas de test retombent exactement sur la valeur mathématique exacte. **Leçon** : `ROUNDED` et le nombre de décimales du `PICTURE` sont deux leviers indépendants ; corriger l'un sans vérifier l'autre peut ne rien améliorer, voire déplacer l'erreur ailleurs.
5. **Accumulateurs de vérification non initialisés (`geneeche.cob`)** — `LS-CAPITAL-RECALC` et `LS-INTERET-SOMME` déclarés en `LOCAL-STORAGE SECTION` sans `VALUE ZERO`, utilisés en `COMPUTE x = x + ...` dans la boucle de génération de l'échéancier. Résultat : totaux affichés faux (`24 230,33 €` au lieu de `24 999,87 €` sur le cas Auto), mais **de façon reproductible** (même valeur fausse à chaque exécution), ce qui aurait pu faire croire à tort que c'était correct. Diagnostiqué en isolant le champ avec `VALUE ZERO` en test et en comparant à une somme recalculée indépendamment (Python) — confirmé, puis corrigé par l'utilisateur. **Leçon** : un accumulateur doit toujours avoir une valeur initiale explicite, jamais compter sur un hypothétique zéro implicite du compilateur, même quand le résultat a l'air stable.
6. **Masquage de signe sur `CAPITAL-RESTANT` (champ non signé)** — sur les prêts où la dérive d'arrondi cumulée aboutit à un léger *sur-remboursement* (cas Immobilier 240 échéances : `+0,87 €`, Consommation 36 échéances : `+0,15 €`), le résultat mathématique réel de la dernière échéance est négatif, mais `CAPITAL-RESTANT PIC 9(6)V99` (non signé) ne peut pas le représenter : COBOL stocke silencieusement la valeur absolue, sans erreur. L'affichage final donne l'impression qu'il reste un solde dû, alors que le client a en réalité payé en trop. Même famille de piège que le bug #1 (champ non signé + résultat négatif), ici sans casser le calcul mais en inversant la lecture métier du résultat. Diagnostiqué en comparant la somme réelle des remboursements (recalculée indépendamment) au capital initial sur les 3 cas de test. **Non corrigé à cette étape** — documenté comme limite connue (la dérive d'arrondi elle-même était déjà anticipée et backloggée en SFD, mais pas ce masquage de signe spécifiquement).

## Points de vigilance

- **Précision métier banque/assurance** : l'oubli du `ROUNDED` a été relevé par l'utilisateur lui-même comme un point à sa défaveur dans un contexte bancaire/assurance, où l'arrondi n'est pas cosmétique mais réglementaire. Réflexe à muscler pour la suite du Projet 5 : traiter une contrainte de formatage/arrondi explicitement spécifiée dès l'écriture, pas en retour de revue.
- `RETURN-CODE` positionné dans `evaltaux.cob` (`WHEN OTHER`) mais jamais exploité côté appelant — essai volontaire de l'utilisateur pour observer le comportement, pas un oubli ; actuellement verrouillé en amont par la validation de saisie (`SELECT-TYPE-PRET`), donc sans impact réel.
- **Masquage de signe sur `CAPITAL-RESTANT`** (bug #6) : limite connue et documentée, pas corrigée — à garder en tête si une étape future affiche ce champ sans contexte (pourrait induire en erreur un lecteur qui ne connaît pas cette nuance).

## Temps

- Étape 1 : ~2h53 à 3h30 (11h00 → 16h23, moins 2h30 de pause — écart entre calcul brut et ressenti de l'utilisateur, les deux valeurs sont cohérentes à ~35 min près)
- Étape 2 : ~1h45 de développement (`geneeche.cob`), hors temps de revue/diagnostic des bugs #5 et #6

## Confiance

- Étape 1 : 8,5/10 — nuancé par l'utilisateur lui-même : l'oubli du `ROUNDED` explicitement spécifié en SFD est jugé à sa défaveur dans l'optique d'un métier exigeant une précision réglementaire (banque/assurance)
- Étape 2 : **désaccord assumé entre les deux évaluations** — utilisateur : 8,5/10 (l'absence d'initialisation sur les accumulateurs de test est dommage mais sans impact sur le code métier, qui fonctionne sans bug) ; assistant : 7,5/10 (le code de vérification a pour rôle de démontrer la fiabilité du reste — un bug dedans retire la certitude acquise sur la logique métier, même si celle-ci s'avère correcte après coup). Écart de philosophie de notation, pas de désaccord sur les faits.

## Résultats

Étape 1 close. Grille de taux à deux critères (type de prêt × durée) et formule de mensualité (annuités constantes) validées par l'utilisateur sur ses propres calculs de contrôle, après correction du `ROUNDED`.

Sessions réelles (entrées interactives, `type / capital / durée`), post-fix précision (bug #4) — valeurs vérifiées exactes contre un calcul de référence indépendant (Python) :

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

| Type         | Capital      | Durée  | Taux   | Mensualité | Valeur exacte (référence) |
| ------------ | ------------ | ------ | ------ | ---------- | -------------------------- |
| Immobilier   | 200 000,00 € | 20 ans | 3,45 % | 1 154,79 € | 1 154,79 €                  |
| Auto         | 25 000,00 €  | 5 ans  | 3,20 % | 451,44 €   | 451,44 €                    |
| Consommation | 8 000,00 €   | 3 ans  | 5,20 % | 240,49 €   | 240,49 €                    |

Étape 2 close. Échéancier complet généré et vérifié sur les 3 cas de test (`geneeche.cob`), après correction du bug d'initialisation (#5) :

| Cas | Échéances | Somme intérêts | Somme capital remboursé | Écart vs capital initial |
| --- | --- | --- | --- | --- |
| Auto (25 000 €, 5 ans) | 60 | 2 086,53 € | 24 999,87 € | −0,13 € (sous-payé) |
| Immobilier (200 000 €, 20 ans) | 240 | 77 148,73 € | 200 000,87 € | +0,87 € (sur-payé, masqué en `+0.87` par le champ non signé — voir bug #6) |
| Consommation (8 000 €, 3 ans) | 36 | 657,49 € | 8 000,15 € | +0,15 € (sur-payé, même masquage) |

Écarts cohérents avec la dérive d'arrondi cumulative anticipée en SFD (quelques centimes sur l'ensemble de l'échéancier), amplifiée par le nombre d'échéances.
