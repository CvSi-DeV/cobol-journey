# SFD — Étape 3 : Format d'échange structuré (JSON)

**Projet :** Projet 5 — Simulateur de prêt bancaire (`simupret`)
**Étape :** 3 / 7 — Sortie JSON exploitable par un autre programme
**Statut :** terminé

## 1. Objectif

Produire, à partir des résultats déjà calculés (mensualité de l'Étape 1, échéancier de l'Étape 2), une sortie **JSON** exploitable par un programme externe — préparation directe du wrapper Java de l'Étape 4, qui devra lire et interpréter cette sortie.

Décision actée : le format est **JSON**, généré via l'instruction native `JSON GENERATE` (confirmé disponible : GnuCOBOL 3.2.0 compilé avec `json-c` sur cet environnement).

## 2. Exigence obligatoire — correction du masquage de signe sur `CAPITAL-RESTANT`

**À traiter dans le cadre de cette étape, avant ou en même temps que la génération JSON.**

Rappel du problème (découvert à l'Étape 2, documenté mais non corrigé) : `CAPITAL-RESTANT` dans `echeance.cpy` est déclaré `PIC 9(6)V99` — **non signé**. Sur les prêts où la dérive d'arrondi cumulée aboutit à un léger sur-remboursement, le résultat réel de la dernière échéance est négatif, mais le champ non signé stocke silencieusement la valeur absolue : un consommateur externe (le futur wrapper Java) lirait alors une donnée trompeuse (un solde qui semble dû, alors qu'il est en réalité créditeur), sans aucun moyen de le détecter.

**Exigence** : passer `CAPITAL-RESTANT` en `PIC S9(6)V99` (champ signé) dans `echeance.cpy`, et vérifier que `geneeche.cob` propage correctement le signe le cas échéant. Retester les 3 cas de test déjà utilisés à l'Étape 2 (Auto, Immobilier, Consommation) pour confirmer que le signe réel apparaît désormais correctement sur la dernière échéance dans les cas de sur-remboursement.

## 3. Contenu de la sortie JSON

La sortie doit représenter, pour une simulation donnée :

- Les caractéristiques de la demande (type de prêt, capital, durée)
- Le taux déterminé (annuel et mensuel)
- La mensualité calculée
- L'échéancier complet (une entrée par échéance : numéro, capital en début de période, intérêts, part de capital remboursée, capital restant dû)

La structure exacte (noms de clés JSON, imbrication) est à ta charge de définir — c'est une décision de conception qui t'appartient, pas une prescription de cette SFD.

## 4. Notion nouvelle à mobiliser : `JSON GENERATE` — et sa limite confirmée

L'instruction `JSON GENERATE` convertit un élément de groupe COBOL (`01`, `05`, etc.) en texte JSON, vers un champ alphanumérique récepteur.

**Limite confirmée par test (2026-09-21), pas une simple hypothèse à vérifier** : GnuCOBOL **ne supporte pas** les éléments `OCCURS` dans `JSON GENERATE` (warning `[-Wpending]` à la compilation, confirmé par un test isolé et par la documentation communautaire du projet GnuCOBOL — limitation connue et non résolue à ce jour, sur toutes les versions actuelles). Concrètement : sur un groupe contenant une table `OCCURS` (fixe ou `DEPENDING ON`), seule la **première occurrence** est exportée, les suivantes sont silencieusement ignorées — pas d'erreur bloquante, juste une sortie incomplète.

**Conséquence sur l'architecture** : `TABLE-ECHEANCIER` (qui contient la table `OCCURS`) ne peut pas être passée telle quelle à `JSON GENERATE`. Deux parties à traiter différemment :

- La partie **sans tableau** (demande de prêt, taux, mensualité) : `JSON GENERATE` fonctionne normalement, aucun problème.
- La partie **échéancier** (le tableau) : à construire **manuellement**, en bouclant sur `NB-ECHEANCES` et en assemblant le texte JSON de chaque échéance avec `STRING` (concaténation), encadré par `[` et `]`, séparé par des virgules — puis à assembler avec la partie générée automatiquement.

Points à vérifier par toi-même en testant, sur la partie qui utilise réellement `JSON GENERATE` (la partie sans tableau) :

- Quels noms de clés JSON sont utilisés par défaut (nom du champ COBOL tel quel, ou faut-il une clause `NAME` pour personnaliser) ?
- Quelle taille de champ récepteur (`PIC X(n)`) prévoir pour contenir le JSON généré ou construit manuellement, sachant qu'un prêt long (240 échéances) produit une sortie nettement plus grande qu'un prêt court ? Une taille sous-dimensionnée tronquerait silencieusement le JSON.

**Recommandation méthodologique** : teste chaque brique isolément (le `JSON GENERATE` sur la partie sans tableau, puis la construction manuelle d'un objet JSON pour une seule échéance) avant d'assembler le tout — même logique que pour l'exponentiation `**` à l'Étape 1.

## 5. Décision à prendre : destination de la sortie

Deux options, à trancher avant de coder (ça conditionne aussi ce que l'Étape 4 devra faire pour récupérer la donnée) :

- **(a)** Écrire le JSON dans un **fichier** (ex: `simulation.json`) — le futur wrapper Java lira ce fichier après exécution du programme COBOL.
- **(b)** Afficher le JSON sur la **sortie standard** (`DISPLAY`) — le futur wrapper Java capturera la sortie du process COBOL directement (`ProcessBuilder` redirige déjà `stdout`).

Qu'est-ce que tu choisis ?

## 6. Architecture proposée

Un nouveau sous-programme (nom à choisir par toi) dédié à la génération JSON, appelé après `GENEECHE`, recevant les structures déjà peuplées (`DEMANDE-PRET`, `TAUX-INTERET`, la mensualité, `TABLE-ECHEANCIER`) et produisant la sortie JSON. Cohérent avec le découpage en sous-programmes déjà établi (`EVALTAUX`, `CALCMENS`, `GENEECHE`).

## 7. Cas de test attendus

Reprends les 3 cas déjà validés aux Étapes 1 et 2 (Auto 25 000€/5 ans, Immobilier 200 000€/20 ans, Consommation 8 000€/3 ans) :

- Vérifie que le JSON produit est syntaxiquement valide (un simple `python3 -m json.tool` ou équivalent suffit pour vérifier)
- Vérifie que le nombre d'échéances dans le JSON correspond bien à `NB-ECHEANCES` (60/240/36) — pas plus, pas moins
- Vérifie spécifiquement sur le cas Immobilier (celui qui présentait le sur-remboursement) que `CAPITAL-RESTANT` de la dernière échéance apparaît désormais avec le bon signe

## 8. Hors périmètre de cette étape

- Le wrapper Java lui-même, qui consommera cette sortie (Étape 4)
- L'exposition HTTP (Étape 5)
- Validation des données d'entrée (toujours backloggée)

## Questions ouvertes

- Décision section 5 (fichier vs stdout) — à trancher avant de coder.
- *(à compléter par toi au fil du développement)*
