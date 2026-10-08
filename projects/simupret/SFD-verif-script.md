# SFD — Script de vérification HTTP (`verif.sh`)

**Rattaché à :** Étape 5 — Exposition HTTP/REST (voir `SFD-etape5.md`, section 6 "Cas de test attendus")
**Fichier :** `projects/simupret/verif.sh`
**Statut :** en cours

## 1. Objectif

Un script `bash` autonome qui démarre le serveur HTTP (`simupret-wrapper`), vérifie automatiquement l'ensemble des cas de test listés dans `SFD-etape5.md` §6, affiche un bilan, et se termine en laissant l'environnement propre (aucun processus serveur résiduel), quel que soit le résultat des tests.

## 2. Configuration nécessaire avant de démarrer le serveur

Le serveur Java (`App.java`) lit ses paramètres dans les variables d'environnement `SIMUPRET_SERVER_PORT`, `SIMUPRET_CBL_CWD`, `SIMUPRET_CBL_EXEC`, `SIMUPRET_CBL_JSON` — le script doit les définir et les exporter avant de lancer Maven.

**Indice** : `export VAR=valeur`. Sois attentif à la valeur de `SIMUPRET_CBL_CWD` : elle doit être cohérente avec le dossier **depuis lequel Maven sera réellement lancé** — rappelle-toi ce qu'on avait découvert sur `ProcessBuilder` et la résolution des chemins relatifs à l'Étape 4 (le piège `../simupret` vs `./simupret`). `verif.sh` vit dans `projects/simupret/`, pas dans `simupret-wrapper/` — le chemin ne sera donc pas forcément le même que celui que tu utilisais dans `test.sh`.

## 3. Étapes du script

### 3.1 Se positionner dans un répertoire de travail prévisible

Quel que soit l'endroit depuis lequel on appelle `./verif.sh`, le script doit toujours partir du même point de référence.

**Indice** : `$0`, `dirname`, `cd`.

### 3.2 Démarrer le serveur en arrière-plan

Lancer la commande qui démarre `App.java` (Maven), sans bloquer la suite du script.

**Indice** : `&` en fin de commande. Pense à rediriger la sortie du serveur vers un fichier journal plutôt que de la laisser se mélanger à celle du script (tu as déjà vu les redirections `>`).

### 3.3 Capturer le PID et poser le filet de sécurité **immédiatement**

Avant toute autre chose, récupérer le PID du serveur tout juste lancé, et enregistrer le nettoyage qui doit se produire quoi qu'il arrive ensuite.

**Indice** : `$!`, puis `trap ... EXIT`. L'ordre compte : si une commande plante entre le démarrage du serveur et la pose du `trap`, rien ne nettoiera le serveur.

### 3.4 Attendre que le serveur soit prêt

Le serveur met quelques secondes à démarrer (JVM + Maven). Il ne faut pas envoyer de requêtes avant qu'il réponde, mais il ne faut pas non plus attendre indéfiniment s'il ne démarre jamais.

**Indice** : une boucle bornée (nombre d'essais maximum, pas une boucle infinie), avec une requête de sondage à chaque tour et une pause entre deux essais. Tu as déjà la route qui sert exactement à ça dans le serveur.

### 3.5 Définir la fonction de comparaison

Une fonction qui compare une valeur obtenue à une valeur attendue, compte les réussites/échecs, et affiche le résultat.

**Indice** : variables globales `PASS`/`FAIL` (pas de `local` dessus), et **attention à la façon dont tu appelles cette fonction** — un appel via une substitution de commande la ferait tourner dans un sous-shell, et tes compteurs globaux ne bougeraient jamais.

### 3.6 Cas de test — routes et méthodes

- `GET /OK` → 200
- `GET /simupret` (mauvaise méthode) → 405

**Indice** : `curl -o /dev/null -w '%{http_code}'`, capturé dans une variable, passé à ta fonction de comparaison.

### 3.7 Cas de test — corps de requête invalide

`POST /simupret` avec un corps qui n'est pas du JSON valide → 400.

**Indice** : `-d` avec des guillemets simples pour un contenu fixe (pas de variable à insérer ici).

### 3.8 Cas de test — les 3 simulations canoniques

Pour Auto (25 000€/5 ans), Immobilier (200 000€/20 ans), Consommation (8 000€/3 ans) :

- Code HTTP = 200
- Mensualité correcte
- Nombre d'échéances correct
- **Sur le cas Immobilier uniquement** : signe correct de `CAPITAL-RESTANT` sur la dernière échéance

**Indice** : `jq -r` pour extraire une valeur scalaire de la réponse. La réponse du serveur est en camelCase (`mensualite`, `nbEcheances`, `capitalRestant`) — pas de crochets nécessaires ici, contrairement aux fichiers `SIMU-PRET-*.json` d'origine. Pour "la dernière échéance" : l'indexation négative d'un tableau jq.

### 3.9 (Optionnel — décision ouverte de `SFD-etape5.md` §4) Test de requêtes rapprochées

Si tu as choisi de sérialiser les requêtes côté serveur : vérifier que deux requêtes très rapprochées ne se mélangent pas (chaque réponse doit correspondre à sa propre demande).

**Indice** : lancer deux `curl` en arrière-plan presque simultanément, récupérer leurs PID, et une commande que tu n'as pas encore utilisée dans ce tutoriel pour attendre que **les deux** se terminent avant de comparer chaque réponse à la demande qui lui correspond (`DEMANDE-PRET` est renvoyée dans chaque réponse).

### 3.10 Bilan final et code de sortie

**Indice** : le compteur `PASS`/`FAIL`, `exit` selon qu'il y a eu des échecs ou non.

## 4. Nettoyage des fichiers de réponse

Chaque requête POST produit un fichier de réponse local. Évite `/tmp` (déjà discuté) — un dossier de travail dans le projet, créé s'il n'existe pas, est plus prévisible.

**Indice** : `mkdir -p`.

## 5. Hors périmètre

- Tests automatisés JUnit (Étape 8, autre outillage)
- Modification du serveur Java ou du COBOL — ce script teste l'existant, ne le modifie pas

## Questions ouvertes

- Le point 3.9 dépend de la décision de concurrence encore ouverte dans `SFD-etape5.md` — à confirmer avant de l'implémenter.
- _(à compléter par toi au fil du développement)_
