# COBOL - JOURNEY

![License](https://img.shields.io/github/license/CvSi-DeV/cobol-journey)

_**Concepteur Développeur Mainframe z/OS & IBM i — 12 ans sur des SI critiques (PL/I, Adelia).
Ce dépôt documente ma pratique de COBOL et sa connexion aux architectures modernes (API REST, Java).**_

## A propos

Je travaille depuis 12 ans sur des environnements IBM : 3 ans et demi sur z/OS (PL/I, JCL, DB2, CICS) et près de 9 ans sur IBM i (Adelia), sur des SI critiques de télécom, de banque et de protection sociale.

Ce dépôt documente ma montée en compétences sur COBOL, avec un objectif concret : savoir faire le pont entre un système COBOL historique et les besoins actuels — API, intégration Java, modernisation ciblée sans réécriture complète.

Chaque projet est un jalon vers cet objectif, pas un exercice isolé. Les programmes sont écrits en dialecte Enterprise COBOL (voir `-std=ibm` plus bas) et complètent le parcours IBM Z Xplore, réalisé sur un environnement z/OS réel jusqu'au badge All Star (2026).

## Journey

### Phase 1 : COBOL Core Mastery

- Fondamentaux COBOL
- Structures & Logique
- Fichiers & I/O Production

### Phase 2 : COBOL Production & Intégrations Modernes

- Architectures Production
- Intégrations Modernes
- Robustesse Production

## Projets développés

| Projet                                                                | Phase | Focus                                         | Status        |
| --------------------------------------------------------------------- | ----- | --------------------------------------------- | ------------- |
| 1. [Hello World](projects/hellowld/README.md)                         | 1     | Setup + syntaxe + Déploiement simple          | ✅ terminé    |
| 2. [Système Paie](projects/systpaie/README.md)                        | 1 - 2 | Variables, logique, Calculs financiers        | ✅ terminé    |
| 3. [Inventaire](projects/inventR/README.md)                           | 2     | Fichiers I/O, traitement batch                | ✅ terminé    |
| 4. [Système Paie 2](projects/systpaii/README.md) (Refactoring Prod)   | 2     | Copybooks, sous-programmes, code réutilisable | ✅ terminé    |
| 5. [Simulateur de Prêt](projects/simupret/README.md) API COBOL (REST) | 2     | Intégrations modernes                         | 🧑‍💻 en cours   |
| 6. E-commerce Complet                                                 | 2     | Everything + BD                               | 🚧 non débuté |

## Badges IBM Z Xplore

Parcours réalisé sur un environnement z/OS réel : [IBM Z Xplore – All Star, Advanced et Concepts](https://www.credly.com/users/david-gaba/badges) (septembre – octobre 2026).

## Stack et outils

- **GnuCOBOL GitHub:** https://github.com/GnuCOBOL/GnuCOBOL
- **VSCode COBOL Extension:** "COBOL" by bitlang
- **Docker GnuCOBOL:** https://hub.docker.com/r/gnucobol/gnucobol

## Comment lancer les projets

La commande compile et exécute le programme.

```bash
cobc -std=ibm -xj fichier.cob
```

`-std=ibm` aligne le comportement du compilateur/runtime sur le dialecte Enterprise COBOL (z/OS) plutôt que le dialecte GnuCOBOL par défaut — évite des écarts de comportement silencieux (ex: `DISPLAY` d'un champ `PIC 9(5)V99` insère un point décimal par défaut sous GnuCOBOL, mais pas sous `-std=ibm`, fidèle au comportement mainframe réel).

## Contact

Via mon profil GitHub : [@CvSi-DeV](https://github.com/CvSi-DeV)
