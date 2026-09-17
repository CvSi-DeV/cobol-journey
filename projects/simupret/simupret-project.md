# Simulateur de Prêt Bancaire (Projet 5) — Progress Tracker

## Apprentissage

### COBOL

- Opérateur d'exponentiation `**` dans un `COMPUTE`, y compris avec un exposant théoriquement négatif
- **Piège GnuCOBOL identifié** : appliquer un signe négatif *dans l'expression* (`- LS-NB-MENSUALITE`) sur un champ dont le `PICTURE` est **non signé** (`PIC 9(4)`, sans `S`) ne se propage pas correctement jusqu'à l'opérateur `**` — le résultat retombe à `1` comme si l'exposant valait `0`. Contourné mathématiquement plutôt que par un champ signé intermédiaire : `(1+t)^-n` réécrit en `1 / (1+t)^n`, qui n'a jamais besoin d'exposant négatif.
- `EVALUATE TRUE ALSO TRUE` avec des niveaux `88` combinant deux champs différents (`TYPE-PRET` et `DUREE-PRET`) pour une grille de taux à deux critères — extension du pattern à un seul critère déjà maîtrisé sur `systpaie` (tranches d'impôt).
- `ROUNDED` sur un `COMPUTE` final : sans cette clause, COBOL **tronque** l'excédent de décimales au lieu de l'arrondir — écart potentiel d'1 centime avec une référence de calcul externe qui arrondit, silencieux et facile à manquer si la spec ne le rappelle pas au moment de coder.
- `PICTURE` éditée dédiée à l'affichage (`PIC 9(5).99`, `PIC Z(5)9.99`) séparée du champ de calcul réel — bonne pratique déjà appliquée spontanément, cohérente avec la leçon "group MOVE" du Projet 4.

### Outillage

- `.PHONY` est une **cible spéciale** de Make, se déclare avec `:` et non `=` — avec `=`, Make crée simplement une variable ordinaire nommée `.PHONY` (les points sont autorisés dans les noms de variable), et les cibles listées ne sont alors pas réellement protégées contre un fichier homonyme.

## Challenge / Objectif

Étape 1 du Projet 5 (Semaine 7-8 du plan, Option A — COBOL → API REST) : calculer la mensualité d'un prêt à taux fixe et annuités constantes, avec un taux d'intérêt déterminé par le programme selon le profil emprunteur (type de prêt × durée), pas saisi directement. Architecture : orchestrateur `simupret.cob` + sous-programmes `evaltaux.cob` (détermination du taux) et `calcmens.cob` (calcul de mensualité), copybook `dempret.cpy`.

## Bugs rencontrés (récap)

1. **Exposant négatif sur champ non signé ignoré par `**`** — `LS-FACTEUR-CROISSANCE ** (- LS-NB-MENSUALITE)` renvoyait systématiquement `1.0000000000` au lieu de la valeur attendue (~0,85 sur le cas de test). Diagnostiqué par comparaison du code à la formule commentée, confirmé par le symptôme (résultat identique à un exposant nul), contourné en réécrivant la formule sans exposant négatif (`1 / (base ** n)`).
2. **`ROUNDED` manquant sur le `COMPUTE` final de la mensualité** — la SFD l'exigeait explicitement, raté au premier passage, corrigé en revue. A changé le résultat (écart d'arrondi confirmé par l'utilisateur).
3. **`.PHONY = cleanmodule clean` au lieu de `.PHONY : cleanmodule clean`** dans le `Makefile` — cibles listées comme phony non réellement protégées (bug silencieux tant qu'aucun fichier `clean`/`cleanmodule` n'existe dans le dossier).

## Points de vigilance

- **Précision métier banque/assurance** : l'oubli du `ROUNDED` a été relevé par l'utilisateur lui-même comme un point à sa défaveur dans un contexte bancaire/assurance, où l'arrondi n'est pas cosmétique mais réglementaire. Réflexe à muscler pour la suite du Projet 5 : traiter une contrainte de formatage/arrondi explicitement spécifiée dès l'écriture, pas en retour de revue.
- `RETURN-CODE` positionné dans `evaltaux.cob` (`WHEN OTHER`) mais jamais exploité côté appelant — essai volontaire de l'utilisateur pour observer le comportement, pas un oubli ; actuellement verrouillé en amont par la validation de saisie (`SELECT-TYPE-PRET`), donc sans impact réel.

## Temps

- ~2h53 à 3h30 (11h00 → 16h23, moins 2h30 de pause — écart entre calcul brut et ressenti de l'utilisateur, les deux valeurs sont cohérentes à ~35 min près)

## Confiance

- 8,5/10 — nuancé par l'utilisateur lui-même : l'oubli du `ROUNDED` explicitement spécifié en SFD est jugé à sa défaveur dans l'optique d'un métier exigeant une précision réglementaire (banque/assurance)

## Résultats

Étape 1 close. Grille de taux à deux critères (type de prêt × durée) et formule de mensualité (annuités constantes) validées par l'utilisateur sur ses propres calculs de contrôle, après correction du `ROUNDED`.
