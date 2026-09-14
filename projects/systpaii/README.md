# Système de Paie — Refactoring Production (V2 modulaire)

Refonte de [`systpaie`](../systpaie) (Projet 2) en architecture modulaire de production : copybooks pour les structures partagées, sous-programmes réutilisables pour le calcul et la génération du rapport, Makefile multi-cibles. Correspond au Projet 4 du plan de formation (Semaines 5-6 : Copybooks, `CALL`, `LINKAGE SECTION`, Makefile professionnel).

Le programme lit une liste d'employés depuis `employes.dat`, calcule le salaire net de chacun (cotisations sociales + impôt simplifié par tranches) via une chaîne de sous-programmes, et génère un rapport dans `rapport-fp.txt`.

## Pourquoi une version séparée de `systpaie`

`systpaie` (V1/V2) reste tel quel volontairement — les deux versions sont conservées côte à côte pour montrer des **notions** différentes :

- `systpaie` illustre un programme monolithique fonctionnel (Semaines 2-3 du plan).
- `systpaii` montre la même logique métier refactorée avec de nouvelles pratiques de production (copybooks, découpage en sous-programmes, gestion mémoire via `LINKAGE SECTION`).

## Architecture

| Fichier        | Rôle                                                                                                    |
| -------------- | ------------------------------------------------------------------------------------------------------- |
| `systpaii.cob` | Orchestrateur : lecture du fichier employés, boucle, appels aux sous-programmes                         |
| `EMPLOYE.cpy`  | Copybook — structure d'un employé lu depuis `employes.dat`                                              |
| `paiedata.cpy` | Copybook — table `PAIE-DATA OCCURS 500`, structure employé + résultats de calcul                        |
| `calccoti.cob` | Sous-programme — calcul des cotisations sociales                                                        |
| `calcbimp.cob` | Sous-programme — calcul de la base imposable                                                            |
| `calcimpo.cob` | Sous-programme — évaluation de la tranche d'imposition (niveaux 88, `VALUES THRU`) et calcul de l'impôt |
| `calcsaln.cob` | Sous-programme — calcul du salaire net                                                                  |
| `generapp.cob` | Sous-programme — génération du rapport (formatage humain, écriture fichier)                             |

Chaque sous-programme est compilé en module (`.dylib` sur macOS) et appelé depuis `systpaii.cob` via `CALL 'NOM' USING ...`, avec passage de paramètres `BY REFERENCE` (défaut) et `LINKAGE SECTION` pour recevoir les données de l'appelant.

## Règles métier

Identiques à `systpaie`, avec un changement de représentation du taux d'imposition (fraction directement multipliable plutôt que pourcentage entier + division) :

1. **Cotisations sociales** : 22 % du brut → `Cotisations = Brut × 0.22`
2. **Base imposable** : `Base imposable = Brut − Cotisations`
3. **Taux d'impôt par tranche** (barème simplifié, pas progressif par palier) :

   | Base imposable   | Taux |
   | ---------------- | ---- |
   | ≤ 1500 €         | 0    |
   | 1500,01 – 3000 € | 0.11 |
   | 3000,01 – 6000 € | 0.30 |
   | > 6000 €         | 0.41 |

4. **Impôt** : `Impôt = Base imposable × Taux`
5. **Net à payer** : `Net = Base imposable − Impôt`

## Prérequis

- [GnuCOBOL](https://gnucobol.sourceforge.io/) installé (`cobc --version`)
- `make`
- Un fichier `employes.dat` présent dans le dossier (format : prénom `PIC X(25)`, nom `PIC X(25)`, salaire brut `PIC 9(5)V99`, une ligne par employé)

## Compilation & exécution

```bash
make all    # compile les modules (-m) puis l'exécutable (-x)
make run    # équivaut à : make all && ./systpaii
make clean  # supprime les .dylib, l'exécutable et le rapport généré
```

Chaque module est compilé séparément (`cobc -m -std=ibm`) et lié dynamiquement à l'exécution par le runtime GnuCOBOL — pas d'édition de liens manuelle nécessaire, `libcob` résout les `CALL` via le nom de fichier du module présent dans le dossier courant.

## Exemple de sortie

Extrait de `rapport-fp.txt` (brut 3200,00 — tranche à 0.11) :

```
-----------------------------
------ FICHE DE PAIE --------
-----------------------------
- NOM : DUPONT
- PRENOM : JEAN
-----------------------------
- SALAIRE BRUT     :  3200.00
--
- COTISATIONS      :   704.00
- BASE IMPOSABLE   :  2496.00
- TAUX IMPOT       :     0.11
- IMPOT            :   274.56
--
- SALAIRE NET      :  2221.44
-----------------------------
```

## Concepts démontrés

- Copybooks (`COPY`) pour des structures partagées entre programmes
- Sous-programmes (`CALL`/`LINKAGE SECTION`), passage de paramètres `USING`/`BY REFERENCE`
- Compilation modulaire (`-m` pour un module, `-x` pour l'exécutable) et résolution dynamique à l'exécution
- Niveaux 88 avec `VALUES ... THRU ...` pour modéliser des tranches de barème
- `PICTURE` éditée (`ZZZZ9.99`) pour un affichage lisible, distincte du champ de calcul brut
- Makefile multi-cibles (modules, exécutable, run, clean)

## Limites connues / à venir

- Pas de sous-programme de validation des données d'entrée (ex: salaire nul/invalide) — décision assumée : les données de `employes.dat` sont volontairement contrôlées pour cet exercice, backloggé pour un futur projet du plan
- Pas de gestion d'erreurs `FILE STATUS` avancée au-delà de la détection fichier absent
