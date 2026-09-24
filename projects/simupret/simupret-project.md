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
- **`JSON GENERATE`** : convertit un groupe COBOL en texte JSON (`COUNT IN` pour la longueur réelle produite, clause `NAME` pour personnaliser les clés). **Limite réelle de GnuCOBOL confirmée par test** : ne gère pas les éléments `OCCURS` (warning `[-Wpending]`, seule la première occurrence exportée, silencieusement) — limitation connue et non résolue du projet, indépendante du dialecte. Contourné en construisant l'échéancier manuellement via boucle + `STRING`, tout en gardant `JSON GENERATE` pour les parties sans tableau (demande, taux, mensualité).
- **`STRING` ne vide jamais le champ récepteur** : il n'écrit que les caractères qu'il produit, sans effacer ce qui dépassait déjà au-delà (le "garbage tail"). Se produit dès que le récepteur contient du contenu non-espace au-delà de la position d'arrivée — indépendamment du fait que source et cible soient ou non le même champ (vérifié par test avec deux champs distincts).
- **`MOVE` vs `STRING` sur ce point précis** : `MOVE` réinitialise **tout** le champ récepteur à chaque exécution (cadrage à gauche, complément d'espaces à droite jusqu'à la fin), y compris quand source et cible sont le même champ (`MOVE FUNCTION TRIM(champ) TO champ`) — contrairement à `STRING`, qui ne touche jamais à ce qu'il n'écrit pas explicitement. Exploité pour recompacter un champ sans garbage tail, sans variable intermédiaire ni `WITH POINTER`.
- **`STRING ... WITH POINTER`** : le pointeur ne se réinitialise **jamais** implicitement entre deux `STRING` — doit être remis à 1 explicitement avant chaque utilisation, sinon l'écriture reprend là où le pointeur en était resté (positions décalées, voire débordement silencieux du champ récepteur sans `ON OVERFLOW`). Piège rencontré une seconde fois dans la session, caché cette fois derrière une variable "fourre-tout" (`LS-JSON-COUNT`) réutilisée pour trois usages différents (`COUNT IN`, calcul de longueur, pointeur `STRING`) — a provoqué une troncature sévère et silencieuse du JSON final (confondue un temps avec une hypothétique limite de `LINE SEQUENTIAL`, qui n'existait pas).
- **`ORGANIZATION SEQUENTIAL` vs `LINE SEQUENTIAL`** : `SEQUENTIAL` écrit des enregistrements de taille physique fixe, sans délimiteur, complétés d'espaces — adapté aux données binaires exactes. `LINE SEQUENTIAL` ajoute un délimiteur de fin d'enregistrement (`\n`/0x0A) à l'écriture et le retire à la lecture, avec troncature automatique des espaces de fin — adapté à un contenu texte de taille variable (JSON), mais à proscrire pour du binaire (un octet 0x0A dans les données serait pris pour une fin d'enregistrement). Confirmé par test isolé (`od -c`) et par le Guide du Programmeur GnuCOBOL officiel.

### Outillage

- `.PHONY` est une **cible spéciale** de Make, se déclare avec `:` et non `=` — avec `=`, Make crée simplement une variable ordinaire nommée `.PHONY` (les points sont autorisés dans les noms de variable), et les cibles listées ne sont alors pas réellement protégées contre un fichier homonyme.

### Java (Étape 4 — premier contact hors COBOL)

- **`ProcessBuilder`** : lance un programme externe comme sous-processus. Points clés : répertoire de travail (`directory(...)`, important puisque `simupret` écrit `pret.json` relativement à celui-ci), flux stdin/stdout/stderr du processus enfant accessibles depuis le parent, `waitFor()` pour attendre la fin et récupérer le code de retour (équivalent Java du `RETURN-CODE`/`FILE STATUS` déjà pratiqué côté COBOL).
- **Risque de deadlock** : si le parent ne lit jamais la sortie standard de l'enfant (tampon système de taille limitée), les deux processus peuvent s'attendre mutuellement indéfiniment. Anticipé dès la SFD, traité par `redirectOutput/Error(Redirect.INHERIT)` (les flux de l'enfant sont directement évacués vers ceux du parent).
- **Jackson (`ObjectMapper`)** : désérialisation JSON → objets Java. `@JsonAlias("TYPE-PRET")` par champ pour mapper un nom JSON différent du nom de champ Java (fonctionne uniquement en désérialisation, pas en écriture). Alternative découverte a posteriori (voir ci-dessous) : une stratégie de nommage globale sur l'`ObjectMapper` (`PropertyNamingStrategies.KEBAB_CASE` + `MapperFeature.ACCEPT_CASE_INSENSITIVE_PROPERTIES`) évite d'annoter chaque champ individuellement, à condition que la transformation soit régulière sur toute la structure — vérifié par test, fonctionne sans aucune annotation par champ.
- Jackson désérialise correctement une valeur JSON string d'un seul caractère (`"I"`) directement vers un `char` Java, et une valeur numérique vers `BigDecimal` — y compris négative (`CAPITAL-RESTANT: -0.87`), sans piège particulier contrairement au signe côté COBOL.
- `Path.of(cwd, nom)` pour construire un chemin de fichier de façon robuste, plutôt qu'une concaténation de chaînes qui dépend d'un séparateur potentiellement absent.
- Exceptions personnalisées non vérifiées (`extends RuntimeException`/`IllegalArgumentException`) pour la validation de domaine (type de prêt, capital, durée) — pattern proche des niveaux `88`/`FILE STATUS` côté COBOL dans l'esprit (échouer vite, avec un message explicite), mais matérialisé en classes dédiées plutôt qu'en simple test de condition.

## Challenge / Objectif

Étape 1 du Projet 5 (Semaine 7-8 du plan, Option A — COBOL → API REST) : calculer la mensualité d'un prêt à taux fixe et annuités constantes, avec un taux d'intérêt déterminé par le programme selon le profil emprunteur (type de prêt × durée), pas saisi directement. Architecture : orchestrateur `simupret.cob` + sous-programmes `evaltaux.cob` (détermination du taux) et `calcmens.cob` (calcul de mensualité), copybook `dempret.cpy`.

**Étape 2** : générer l'échéancier complet du prêt (répartition intérêts/capital par mensualité, capital restant dû). Nouveau sous-programme `geneeche.cob`, nouveau copybook `echeance.cpy` (table `ECHEANCIER` à occurrences variables). Refacto associé : le taux (annuel + mensuel) regroupé dans un enregistrement partagé `TAUX-INTERET` (`tauxinter.cpy`), calculé une seule fois dans `evaltaux.cob`.

**Étape 3** : produire un JSON unique et exploitable par un programme externe (demande + taux + mensualité + échéancier), en fichier (`LINE SEQUENTIAL`). Nouveau sous-programme `genejson.cob`. Exigence associée : corriger le masquage de signe sur `CAPITAL-RESTANT` (`echeance.cpy` passé en `PIC S9(6)V99`).

**Étape 4** : premier wrapper hors COBOL — un programme Java (`projects/simupret/simupret-wrapper/`, Maven) qui lance `simupret` via `ProcessBuilder`, lui fournit les 3 entrées programmatiquement, attend sa fin, lit `pret.json` et le désérialise (Jackson) en objets Java. Aucune modification du COBOL existant.

## Bugs rencontrés (récap)

1. **Exposant négatif sur champ non signé ignoré par `**`** — `LS-FACTEUR-CROISSANCE ** (- LS-NB-MENSUALITE)` renvoyait systématiquement `1.0000000000` au lieu de la valeur attendue (~0,85 sur le cas de test). Diagnostiqué par comparaison du code à la formule commentée, confirmé par le symptôme (résultat identique à un exposant nul), contourné en réécrivant la formule sans exposant négatif (`1 / (base ** n)`).
2. **`ROUNDED` manquant sur le `COMPUTE` final de la mensualité** — la SFD l'exigeait explicitement, raté au premier passage, corrigé en revue. A changé le résultat (écart d'arrondi confirmé par l'utilisateur).
3. **`.PHONY = cleanmodule clean` au lieu de `.PHONY : cleanmodule clean`** dans le `Makefile` — cibles listées comme phony non réellement protégées (bug silencieux tant qu'aucun fichier `clean`/`cleanmodule` n'existe dans le dossier).
4. **`PICTURE` insuffisant sur `TAUX-MENSUEL` — `ROUNDED` seul n'a pas suffi** (fix post-clôture, découvert en préparant l'Étape 2). Le refacto du taux en enregistrement partagé `TAUX-INTERET` (`tauxinter.cpy`) a ajouté `ROUNDED` sur le calcul de `TAUX-MENSUEL`, mais le champ restait déclaré en `PIC 9V9(5)` (5 décimales) — insuffisant pour représenter certains taux mensuels sans perte (ex: `3,45 % / 12 = 0,002875`, qui a besoin de 6 décimales). `ROUNDED` n'a fait que déplacer l'erreur d'un côté à l'autre (mensualité passée de 1154,17 € à 1155,41 € au lieu de converger vers la valeur exacte), l'exponentiation `** n` amplifiant l'écart sur les prêts longs (240 mensualités). Diagnostiqué par comparaison à un calcul de référence indépendant (Python), pas par simple relecture de code. Corrigé en passant `TAUX-MENSUEL` à `PIC 9V9(7)` dans `tauxinter.cpy` (propagé à `calcmens.cob`) — les 3 cas de test retombent exactement sur la valeur mathématique exacte. **Leçon** : `ROUNDED` et le nombre de décimales du `PICTURE` sont deux leviers indépendants ; corriger l'un sans vérifier l'autre peut ne rien améliorer, voire déplacer l'erreur ailleurs.
5. **Accumulateurs de vérification non initialisés (`geneeche.cob`)** — `LS-CAPITAL-RECALC` et `LS-INTERET-SOMME` déclarés en `LOCAL-STORAGE SECTION` sans `VALUE ZERO`, utilisés en `COMPUTE x = x + ...` dans la boucle de génération de l'échéancier. Résultat : totaux affichés faux (`24 230,33 €` au lieu de `24 999,87 €` sur le cas Auto), mais **de façon reproductible** (même valeur fausse à chaque exécution), ce qui aurait pu faire croire à tort que c'était correct. Diagnostiqué en isolant le champ avec `VALUE ZERO` en test et en comparant à une somme recalculée indépendamment (Python) — confirmé, puis corrigé par l'utilisateur. **Leçon** : un accumulateur doit toujours avoir une valeur initiale explicite, jamais compter sur un hypothétique zéro implicite du compilateur, même quand le résultat a l'air stable.
6. **Masquage de signe sur `CAPITAL-RESTANT` (champ non signé)** — sur les prêts où la dérive d'arrondi cumulée aboutit à un léger *sur-remboursement* (cas Immobilier 240 échéances : `+0,87 €`, Consommation 36 échéances : `+0,15 €`), le résultat mathématique réel de la dernière échéance est négatif, mais `CAPITAL-RESTANT PIC 9(6)V99` (non signé) ne peut pas le représenter : COBOL stocke silencieusement la valeur absolue, sans erreur. L'affichage final donne l'impression qu'il reste un solde dû, alors que le client a en réalité payé en trop. Même famille de piège que le bug #1 (champ non signé + résultat négatif), ici sans casser le calcul mais en inversant la lecture métier du résultat. Diagnostiqué en comparant la somme réelle des remboursements (recalculée indépendamment) au capital initial sur les 3 cas de test. **Corrigé à l'Étape 3** (exigence explicite de la SFD) : `CAPITAL-RESTANT` passé en `PIC S9(6)V99`, revérifié sur les 3 cas — le signe négatif apparaît désormais correctement (`-0,87 €` sur Immobilier, `-0,15 €` sur Consommation).
7. **`STRING` garbage tail** — un `STRING` n'efface jamais le contenu du champ récepteur au-delà de ce qu'il écrit explicitement. Repéré par l'utilisateur sur un test isolé (`LS-TEST`), diagnostiqué avec l'assistant (mécanisme confirmé par test : reproductible même avec source et cible différentes), et **résolu de façon autonome par l'utilisateur** avec une solution plus élégante que celle suggérée par l'assistant (`WITH POINTER` + `MOVE SPACES` ciblé) : `MOVE FUNCTION TRIM(champ) TO champ`, qui exploite le fait que `MOVE` réinitialise tout le champ récepteur (contrairement à `STRING`).
8. **`LS-JSON-COUNT` réutilisé comme pointeur `STRING` sans réinitialisation** — variable "fourre-tout" servant à la fois de sortie `COUNT IN` (`JSON GENERATE`), de calcul de longueur (`FINALISE-JSON`) et de pointeur pour le `STRING` d'assemblage final (`WITH POINTER LS-JSON-COUNT`), jamais remise à 1 entre ces usages. Résultat : le `STRING` final démarrait l'écriture à la position laissée par le calcul de longueur de l'échéancier (ex: position 30115 sur le cas Immobilier), tronquant silencieusement l'essentiel du JSON assemblé (`41000 - 30115 = 10885` caractères restants, taille de fichier observée : 10887). **D'abord suspecté à tort comme une limite de `LINE SEQUENTIAL`** — diagnostiqué en traçant les valeurs affichées par le programme lui-même (`DISPLAY 'Longueur : '` déjà présents), confirmé par calcul exact. Même famille que le piège `WITH POINTER` de `geneeche.cob`, mais caché derrière une variable à usages multiples. Corrigé par l'utilisateur (`MOVE 1 TO LS-JSON-COUNT` avant le `STRING` final).

**Étape 4 (Java, revue de code — aucun bug de logique métier, uniquement robustesse/conception)** :

9. `parseJson(File fileToParse, Class<T> jsonDataModel)` ignorait ses propres paramètres génériques — relisait toujours le chemin depuis les variables d'environnement et ciblait toujours `SimuPretWrapperData.class`, quel que soit l'argument fourni. Fonctionnait par coïncidence (l'appelant passait toujours le même fichier), aurait échoué en `ClassCastException` si un jour appelé avec un autre type. Cause reconnue par l'utilisateur : résidu d'un premier jet codé en dur dans `main` avant l'extraction en méthode. Corrigé.
10. Concaténation de chemin fragile (`CWD + EXEC`, `CWD + JSON`, sans séparateur) — ne fonctionnait que si la variable d'environnement `CWD` se terminait par `/`. Corrigé via `Path.of(cwd, nom)`, revérifié par l'assistant sans slash final — fonctionne quelle que soit la convention de la variable d'environnement.
11. Gestion d'erreur silencieuse (`catch (IOException...) { System.out.println(...) }`) alors que des exceptions dédiées existaient déjà (`ProcessException`) sans être levées — incohérence entre l'architecture (exceptions personnalisées) et sa mise en œuvre réelle (juste un message consolé). Corrigé : `ProcessException` désormais levée à la fois dans `parseJson` et `startProcess()`.
12. Stubs `equals`/`hashCode`/`toString` générés par l'IDE et jamais retravaillés (`// TODO Auto-generated method stub` + `return super.equals(obj)`) sur plusieurs classes — code mort. Supprimés.

## Points de vigilance

- **Précision métier banque/assurance** : l'oubli du `ROUNDED` a été relevé par l'utilisateur lui-même comme un point à sa défaveur dans un contexte bancaire/assurance, où l'arrondi n'est pas cosmétique mais réglementaire. Réflexe à muscler pour la suite du Projet 5 : traiter une contrainte de formatage/arrondi explicitement spécifiée dès l'écriture, pas en retour de revue.
- `RETURN-CODE` positionné dans `evaltaux.cob` (`WHEN OTHER`) mais jamais exploité côté appelant — essai volontaire de l'utilisateur pour observer le comportement, pas un oubli ; actuellement verrouillé en amont par la validation de saisie (`SELECT-TYPE-PRET`), donc sans impact réel.
- **Masquage de signe sur `CAPITAL-RESTANT`** (bug #6) : corrigé à l'Étape 3, voir bug #6 mis à jour.
- **`STRING ... WITH POINTER`** : piège rencontré une seconde fois dans le projet (déjà vu sur `geneeche.cob`), cette fois plus insidieux car caché derrière une variable réutilisée à plusieurs fins (`LS-JSON-COUNT`). Réflexe à muscler : une variable qui sert de pointeur `STRING` ne devrait servir qu'à ça, pas cumuler d'autres usages (compteur, longueur) dans le même passage de code — sans quoi la réinitialisation nécessaire avant chaque `STRING` est facile à oublier.
- **`new String(x)` sur une chaîne déjà immuable** (Java, Étape 4) — réflexe répété dans plusieurs classes, sans effet néfaste mais sans utilité ; assumé tel quel par l'utilisateur, à perdre progressivement avec la pratique.

## Temps

- Étape 1 : ~2h53 à 3h30 (11h00 → 16h23, moins 2h30 de pause — écart entre calcul brut et ressenti de l'utilisateur, les deux valeurs sont cohérentes à ~35 min près)
- Étape 2 : ~1h45 de développement (`geneeche.cob`), hors temps de revue/diagnostic des bugs #5 et #6
- Étape 3 : ~8h de travail effectif, étalées sur 36h — étape nettement plus dense que les deux précédentes (nouvelle instruction `JSON GENERATE` et sa limite réelle, construction JSON manuelle, deux pièges `STRING` distincts)
- Étape 4 : ~8h de travail effectif — étude de `ProcessBuilder`, du guide officiel Maven ("Getting Started"), et de l'`ObjectMapper` Jackson, en plus du développement lui-même

## Confiance

- Étape 1 : 8,5/10 — nuancé par l'utilisateur lui-même : l'oubli du `ROUNDED` explicitement spécifié en SFD est jugé à sa défaveur dans l'optique d'un métier exigeant une précision réglementaire (banque/assurance)
- Étape 2 : **désaccord assumé entre les deux évaluations** — utilisateur : 8,5/10 (l'absence d'initialisation sur les accumulateurs de test est dommage mais sans impact sur le code métier, qui fonctionne sans bug) ; assistant : 7,5/10 (le code de vérification a pour rôle de démontrer la fiabilité du reste — un bug dedans retire la certitude acquise sur la logique métier, même si celle-ci s'avère correcte après coup). Écart de philosophie de notation, pas de désaccord sur les faits.
- Étape 3 : **8/10 des deux côtés, pour la première fois pas de désaccord de fond** — utilisateur : nuancé par le piège `WITH POINTER` particulièrement retors car survenu en toute fin d'étape, alors que le travail semblait terminé ; point positif retenu : résolution autonome du "garbage tail" via `MOVE FUNCTION TRIM`, en mobilisant ses propres connaissances plutôt qu'en suivant une suggestion de l'assistant qui ne le convainquait pas, et apprentissage `SEQUENTIAL`/`LINE SEQUENTIAL` jugé positif pour la montée en expertise.
  - **Évaluation assistant (mêmes critères explicités à la demande de l'utilisateur)** :
    - *Points positifs* : contournement complet et fonctionnel de la limite `JSON GENERATE`/`OCCURS` (pas une bidouille, un vrai algorithme d'assemblage validé sur 3 tailles d'échéancier) ; autonomie réelle sur le "garbage tail" — rejet argumenté de la suggestion de l'assistant (`WITH POINTER`) au profit d'une solution plus simple et plus juste (`MOVE FUNCTION TRIM`), preuve d'une compréhension personnelle de `MOVE` vs `STRING`, pas d'une application mécanique ; vérification finale rigoureuse des 3 cas, signe inclus sur le cas Immobilier qui avait motivé l'exigence ; discipline de clôture correcte (annoncée seulement une fois réellement terminé, contrairement à l'assistant qui a voulu clore trop tôt sur un seul test).
    - *Point qui retient la note* : le bug `LS-JSON-COUNT`/`WITH POINTER` est une **récidive** du même piège déjà corrigé sur `geneeche.cob` à l'Étape 2 (pointeur non réinitialisé) — réapparu ici car une variable "fourre-tout" (`COUNT IN`, calcul de longueur, pointeur `STRING`) cumulait trois rôles distincts ; principe de conception (une variable-pointeur ne devrait servir qu'à ça) pas encore complètement intégré malgré la leçon déjà tirée une première fois.
    - *Différence avec l'Étape 2* : les deux bugs de cette étape (masquage de signe, garbage tail, pointeur) ont tous été trouvés et corrigés **avant** que l'étape soit déclarée terminée, pas après coup en revue — contrairement à l'Étape 2 où le bug d'initialisation avait été découvert par l'assistant après la clôture annoncée. C'est ce qui explique l'absence de désaccord cette fois : la confiance dans le résultat final n'est pas entamée par un doute sur la méthode de vérification elle-même.
- Étape 4 : utilisateur 7,5-8/10 — nuancé par la comparaison à un développeur Java plus expérimenté (irait plus vite, n'aurait pas certains réflexes comme `new String(x)`) ; satisfaction affirmée sur l'architecture mise en place et l'absence de blocage pour produire quelque chose de fonctionnel à partir de la seule SFD, dans un langage pourtant peu pratiqué.
  - **Évaluation assistant : 8/10, sans complaisance** — contrairement aux Étapes 1 à 3, **aucun bug de logique métier** trouvé en revue — les 4 points relevés (paramètres génériques ignorés, chemin fragile, gestion d'erreur incohérente, stubs morts) touchaient tous à la robustesse/conception, jamais au résultat produit, qui était correct dès le premier jet (vérifié par exécution réelle des 3 cas). Méthode de résolution du mapping JSON (`@JsonAlias`) trouvée en comprenant d'abord la cause via le message d'exception, pas par essais-erreurs aveugles — transposition réussie du réflexe de diagnostic déjà acquis côté COBOL vers un langage différent. Les 4 points de revue ont été corrigés en un seul aller-retour, sans qu'aucun n'ait nécessité une deuxième explication. Ce qui retient la note sous 9-10 : ces points de robustesse (paramètre générique jamais utilisé, concaténation de chemin sans séparateur, exception créée mais jamais levée) auraient pu être attrapés par une relecture personnelle avant soumission, indépendamment du niveau d'expérience Java — et le réflexe "chemin portable" n'était pas encore complètement acquis, y compris après une première correction (`launch.json` recontenant un chemin absolu personnel malgré la correction Java déjà faite sur le même sujet).

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

Étape 3 close. JSON unique généré et vérifié en profondeur sur les 3 cas de test (`SIMU-PRET-AUTO.json`, `SIMU-PRET-CONSO.json`, `SIMU-PRET-IMMO.json`) — validation faite valeur par valeur (pas seulement syntaxique) :

| Cas | JSON valide | `NB-ECHEANCES` | Mensualité | `CAPITAL-RESTANT` dernière échéance | Cohérence capital |
| --- | --- | --- | --- | --- | --- |
| Auto (25 000 €, 5 ans) | ✅ | 60 = 60 ✅ | 451,44 € ✅ | +0,13 € (sous-payé, pas de signe à tester) | ✅ |
| Consommation (8 000 €, 3 ans) | ✅ | 36 = 36 ✅ | 240,49 € ✅ | **-0,15 €** ✅ (signe corrigé) | ✅ |
| Immobilier (200 000 €, 20 ans) | ✅ | 240 = 240 ✅ | 1 154,79 € ✅ | **-0,87 €** ✅ (signe corrigé, cas qui avait motivé le fix) | ✅ |

Structure JSON (identique sur les 3 cas), un seul document assemblé :
```json
{
  "DEMANDE-PRET": { "TYPE-PRET": "...", "CAPITAL": ..., "DUREE-PRET-ANNEE": ... },
  "TAUX-INTERET": { "TAUX-ANNUEL": ..., "TAUX-MENSUEL": ... },
  "MENSUALITE": ...,
  "ECHEANCIER": { "NB-ECHEANCES": ..., "ECHEANCES": [ {...}, ... ] }
}
```

Étape 4 close. Wrapper Java (`simupret-wrapper`, Maven) exécuté et vérifié par l'assistant (pas seulement lu) sur les 3 cas canoniques — compilation + exécution réelle avec les variables d'environnement (`SIMUPRET_CBL_CWD`/`SIMUPRET_CBL_EXEC`/`SIMUPRET_CBL_JSON`) :

| Cas | Code retour | Mensualité (Java) | `CAPITAL-RESTANT` dernière échéance (Java, `BigDecimal`) |
| --- | --- | --- | --- |
| Auto (25 000 €, 5 ans) | 0 | 451,44 | +0,13 |
| Consommation (8 000 €, 3 ans) | 0 | 240,49 | -0,15 (signe correctement désérialisé) |
| Immobilier (200 000 €, 20 ans) | 0 | 1 154,79 | -0,87 (signe correctement désérialisé, cas critique de l'Étape 3) |

Valeurs identiques aux JSON de l'Étape 3 sur les 3 cas — le pipeline Java (`ProcessBuilder` → fichier → Jackson) reproduit fidèlement les données produites par COBOL, y compris le point le plus sensible (le signe).
