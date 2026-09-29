# SFD — Étape 5 : Exposition HTTP/REST

**Projet :** Projet 5 — Simulateur de prêt bancaire (`simupret`)
**Étape :** 5 / 8 — API HTTP au-dessus du wrapper Java
**Statut :** à développer

## 1. Objectif

Exposer la simulation de prêt (aujourd'hui exécutable uniquement via `App.java` avec 3 cas codés en dur) derrière un **endpoint HTTP** : un client externe envoie une demande de prêt (type, capital, durée) et reçoit en retour le résultat de simulation, sans jamais avoir besoin de connaître l'existence de COBOL ni de `ProcessBuilder` en dessous.

C'est la dernière brique logicielle du projet avant la Dockerisation (Étape 6) et les tests Postman (Étape 7) — le plan de formation mentionne aussi un "client exemple qui consomme l'API" : décision à prendre en section 4 sur son périmètre exact à cette étape.

## 2. Rappel de ce qui existe déjà (inchangé dans son principe)

`SimuPretWrapper` sait déjà tout faire : construire et lancer le processus `simupret`, lui fournir les entrées, attendre sa fin, lire et désérialiser `pret.json`. Cette étape ne réécrit pas cette logique — elle la **déclenche depuis une requête HTTP** au lieu d'un `main()` avec des valeurs fixes.

## 3. Notions nouvelles à mobiliser

### Le principe d'un serveur HTTP en Java

Un serveur HTTP écoute sur un port, reçoit des requêtes (méthode, chemin, corps), et renvoie des réponses (code de statut, corps). `com.sun.net.httpserver.HttpServer` est une classe **native du JDK** (vérifiée disponible sur ton installation, aucune dépendance supplémentaire nécessaire) :

- `HttpServer.create(adresse, backlog)` crée le serveur, `.start()` le démarre.
- `createContext(chemin, handler)` associe un chemin d'URL à un gestionnaire de requêtes.
- Le gestionnaire implémente l'interface `HttpHandler` — une seule méthode `handle(HttpExchange exchange)` à fournir, appelée à chaque requête reçue sur ce chemin.
- `HttpExchange` donne accès à la méthode HTTP utilisée, au corps de la requête entrante (flux à lire), et permet d'écrire la réponse : d'abord `sendResponseHeaders(code, longueur)`, puis écrire les octets de la réponse dans le flux qu'il expose.

**Alternative** : des micro-frameworks (Javalin, Spark) offrent une syntaxe plus concise pour définir des routes et gèrent la sérialisation JSON de façon intégrée — mais nécessitent une dépendance Maven supplémentaire, dont je n'ai pas vérifié la disponibilité hors-ligne sur ta machine (à tester au moment de choisir).

### Sérialiser du JSON en sortie (nouveau sens d'usage de Jackson)

Jusqu'ici, `ObjectMapper` n'a servi qu'à **lire** du JSON (`readValue`, du fichier vers un objet Java). Pour répondre à une requête HTTP, il faut cette fois **produire** du JSON à partir d'un objet Java (`writeValueAsString(objet)`) — l'opération inverse, avec le même outil.

### Point de vigilance sérieux : la concurrence sur un fichier partagé

`genejson.cob` écrit toujours vers le **même nom de fichier fixe** (`pret.json`), dans le même répertoire. Si deux requêtes HTTP arrivent en même temps (ou même juste à quelques millisecondes d'écart) et déclenchent chacune un `simupret`, les deux processus écriraient potentiellement dans le même fichier en même temps — une requête pourrait alors lire le résultat destiné à l'autre, ou un fichier à moitié écrit. **C'est un vrai risque d'architecture, pas une hypothèse d'école** : `HttpServer` peut traiter plusieurs requêtes en parallèle selon sa configuration.

Décision à prendre en section 4 sur comment le gérer à cette étape.

## 4. Décisions à prendre avant de coder

- **Framework HTTP** : `HttpServer` natif (disponible, zéro dépendance) ou micro-framework (Javalin/Spark, à vérifier). À toi de choisir selon ce que tu veux pratiquer.
- **Contrat de l'API** : méthode HTTP (le plan suggère `POST` — cohérent, puisqu'une simulation n'est pas une simple lecture), chemin exact (ex: `/simulate-loan` déjà évoqué dans le plan, à toi de le garder ou l'adapter), format du corps de requête en entrée (JSON avec type/capital/durée ?) et de la réponse (le JSON de simulation complet, ou un sous-ensemble ?).
- **Gestion de la concurrence sur `pret.json`** : deux pistes possibles, à trancher —
  - **(a)** Traiter les requêtes **une par une** à cette étape (le serveur ne lance un nouveau `simupret` qu'une fois la précédente requête entièrement terminée) — limitation assumée et documentée, à améliorer dans un futur projet.
  - **(b)** Revoir `genejson.cob` pour que le nom du fichier JSON soit **paramétrable** (ex: un identifiant unique par exécution) — sort du principe "aucune modification du COBOL" tenu jusqu'ici sur ce projet, à valider explicitement si tu veux aller dans cette direction.
- **Client exemple** (mentionné dans le plan de formation) : un script `curl` documenté suffit-il à cette étape, ou tu préfères reporter cette démonstration à la collection Postman de l'Étape 7 ?

## 5. Architecture proposée

Un point d'entrée serveur (nouvelle classe, nom à ton choix) qui démarre `HttpServer`, route les requêtes entrantes vers la logique déjà existante de `SimuPretWrapper` (aucune duplication de cette logique), et retourne le résultat en JSON. `App.java` peut soit devenir ce point d'entrée serveur, soit rester tel quel (mode "démo 3 cas") pendant qu'une nouvelle classe prend le rôle de serveur — à toi de voir selon ce qui te semble le plus propre.

## 6. Cas de test attendus

Pour chacun des 3 cas déjà validés aux étapes précédentes (Auto 25 000€/5 ans, Immobilier 200 000€/20 ans, Consommation 8 000€/3 ans) :

- Envoyer la requête HTTP réelle (`curl` ou équivalent) plutôt qu'un appel Java direct — c'est justement ce qui change à cette étape.
- Vérifier le code de statut HTTP retourné (200 en cas de succès).
- Vérifier que le contenu JSON de la réponse correspond exactement aux fichiers déjà validés à l'Étape 3/4 (mensualité, `NB-ECHEANCES`, signe de `CAPITAL-RESTANT` sur le cas Immobilier).
- Si tu choisis l'option (a) de la section 4 (requêtes séquentielles), un test utile : envoyer deux requêtes très rapprochées et vérifier qu'aucune ne récupère le résultat de l'autre.

## 7. Hors périmètre de cette étape

- Dockerisation (Étape 6)
- Collection Postman formalisée (Étape 7) — sauf si tu choisis d'anticiper le client exemple dessus
- Tests automatisés Java (Étape 8)
- Authentification/sécurisation de l'API (non demandée par le plan à ce stade)

## Questions ouvertes

- Décisions de la section 4 (framework, contrat d'API, gestion de la concurrence, client exemple) — à trancher avant de coder.
- *(à compléter par toi au fil du développement)*
