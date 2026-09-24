# SFD — Étape 4 : Wrapper Java

**Projet :** Projet 5 — Simulateur de prêt bancaire (`simupret`)
**Étape :** 4 / 7 — Wrapper Java consommant le programme COBOL
**Statut :** terminé

## 1. Objectif

Écrire un programme Java qui :
1. Lance l'exécutable COBOL compilé `simupret` comme **processus externe**.
2. Lui fournit les 3 entrées attendues (type de prêt, capital, durée) de façon **programmatique** — sans intervention humaine au clavier.
3. Attend la fin de son exécution.
4. Lit le fichier `pret.json` qu'il a produit.
5. Le **parse** en structures Java exploitables et affiche le résultat en console.

C'est la première étape du projet qui sort de COBOL — elle prouve que le programme métier est consommable depuis un langage moderne, sans toucher au COBOL existant. L'exposition en API REST (Étape 5) viendra se brancher sur ce même mécanisme.

## 2. Rappel de ce qui existe déjà côté COBOL (inchangé à cette étape)

- `./simupret` (une fois compilé) attend, dans l'ordre, sur son entrée standard : le type de prêt (`A`/`C`/`I`), le capital (entier), la durée en années.
- Il produit un fichier `pret.json` dans son **répertoire de travail courant** au moment de l'exécution — pas un chemin absolu fixe.
- Il affiche aussi des messages `DISPLAY` sur sa sortie standard (bienvenue, invites de saisie, taux, mensualité) — ce ne sont que des messages de confort utilisateur, la donnée structurée est dans le fichier JSON, pas dans cette sortie console.

Aucune modification du COBOL n'est nécessaire pour cette étape.

## 3. Notions nouvelles à mobiliser

### `ProcessBuilder` — lancer et piloter un processus externe depuis Java

C'est la classe Java qui permet de démarrer un programme externe (ici, `simupret`) et d'interagir avec lui comme s'il s'agissait d'un sous-processus. Points clés à connaître avant de coder :

- **Démarrage** : `ProcessBuilder` se configure (commande à exécuter, répertoire de travail) puis `.start()` renvoie un objet `Process` représentant le programme en cours d'exécution.
- **Répertoire de travail** : `ProcessBuilder` permet de fixer le répertoire dans lequel le processus externe s'exécute. C'est important ici, puisque `pret.json` est écrit relativement à ce répertoire — le wrapper doit savoir précisément où le chercher après coup.
- **Flux d'entrée/sortie du processus** : un `Process` expose trois flux, du point de vue du programme Java : son flux vers l'**entrée standard** du processus enfant (pour lui "taper" les 3 valeurs comme le ferait un humain), son flux depuis sa **sortie standard**, et un depuis sa **sortie d'erreur**. Écrire dans le premier revient à simuler une saisie clavier.
- **Attente de fin** : le programme Java doit explicitement attendre que le processus enfant se termine avant de considérer que `pret.json` est complet et prêt à être lu — sans quoi il risquerait de lire un fichier encore en cours d'écriture, ou pas encore créé.
- **Code de retour** : comme en COBOL avec `FILE STATUS` ou `RETURN-CODE`, un processus externe se termine avec un code numérique (0 = succès, autre = échec) — à vérifier avant de faire confiance au fichier produit.

### Point de vigilance sérieux : le risque de blocage mutuel (deadlock)

`simupret` produit un volume non négligeable de messages `DISPLAY` sur sa sortie standard. Le flux de sortie d'un processus externe transite par un tampon (buffer) de taille limitée, côté système d'exploitation. Si le programme Java n'est jamais en train de **lire** cette sortie pendant que `simupret` continue à afficher des choses, ce tampon peut se remplir — et `simupret` se retrouve alors bloqué en écriture, en attente que quelqu'un vide le tampon, pendant que le programme Java, lui, attend la fin de `simupret` sans jamais lire sa sortie. **Les deux processus s'attendent mutuellement indéfiniment.**

Sur un programme qui affiche seulement quelques lignes comme `simupret`, le risque réel de saturer le tampon est faible en pratique — mais c'est un piège suffisamment classique et bien documenté sur `ProcessBuilder` pour le connaître et vérifier comment s'en prémunir (indice : `ProcessBuilder` propose des méthodes pour rediriger/fusionner les flux plutôt que de les laisser s'accumuler sans lecteur).

### Lire et parser le fichier JSON produit

Une fois le processus terminé (et son code de retour vérifié), il reste à lire le contenu texte de `pret.json`, puis à le transformer en structure Java exploitable (l'équivalent, côté Java, de ce que `JSON PARSE` ferait côté COBOL). Cela nécessite une **bibliothèque de parsing JSON** — le JDK ne fournit pas de parseur JSON en standard.

## 4. Décisions à prendre avant de coder

- **Bibliothèque JSON** : plusieurs choix courants existent (`org.json`, `Gson`, `Jackson`...), chacune avec ses idiomes propres pour naviguer dans une structure JSON parsée. Maven est disponible sur ta machine (`mvn -version` confirmé), donc la gestion de dépendance ne pose pas de contrainte technique particulière quel que soit ton choix.
- **Structure du projet** : nouveau dossier à créer (proposition : `projects/simupret/wrapper-java/`, à ajuster si tu préfères une autre organisation), projet Maven (`pom.xml`) ou fichier source unique compilé directement (Java 21 permet d'exécuter un fichier `.java` sans compilation explicite via `java MonFichier.java`) — à toi de choisir le niveau d'outillage adapté à cette étape.
- **Localisation de l'exécutable `simupret`** : comment le wrapper Java sait-il où se trouve l'exécutable COBOL compilé (chemin relatif codé en dur, argument de lancement, variable d'environnement) ? Décision de conception qui t'appartient.

## 5. Architecture proposée

Un seul programme Java (nom de classe à ton choix) qui orchestre l'ensemble : construit et lance le processus `simupret`, lui écrit les 3 valeurs d'entrée, attend sa fin, vérifie son code de retour, lit `pret.json` depuis le bon répertoire, le parse, en extrait au minimum le type de prêt, le capital, la mensualité et le nombre d'échéances, et les affiche en console.

Pas encore de serveur HTTP, pas encore de séparation en plusieurs classes/couches à ce stade — cette structuration viendra naturellement à l'Étape 5 quand il faudra exposer ça derrière un endpoint.

## 6. Cas de test attendus

Pour chacun des 3 cas déjà validés aux étapes précédentes (Auto 25 000€/5 ans, Immobilier 200 000€/20 ans, Consommation 8 000€/3 ans) :

- Le wrapper doit lancer `simupret`, lui fournir les bonnes entrées, et se terminer sans erreur.
- Le contenu lu et parsé en Java doit correspondre exactement aux fichiers `SIMU-PRET-*.json` déjà validés à l'Étape 3 (mensualité, `NB-ECHEANCES`, signe de `CAPITAL-RESTANT` sur le cas Immobilier).
- Vérifie en particulier que le wrapper lit bien `pret.json` **après** la fin complète de l'exécution de `simupret`, pas pendant — un test utile : introduire volontairement un léger délai ou observer le comportement si cette synchronisation était mal gérée, pour t'assurer que ta solution ne dépend pas d'une coïncidence de timing.

## 7. Hors périmètre de cette étape

- Exposition HTTP/REST (Étape 5)
- Dockerisation (Étape 6)
- Collection Postman (Étape 7)
- Toute modification du code COBOL existant

## Questions ouvertes

- Décisions de la section 4 (bibliothèque JSON, structure de projet, localisation de l'exécutable) — à trancher avant de coder.
- *(à compléter par toi au fil du développement)*
