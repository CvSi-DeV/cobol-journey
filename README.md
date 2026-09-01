# COBOL - JOURNEY

_**Expert legacy COBOL spécialisé intégration moderne.
Expérience Z/OS, IBM i, Java.
Je lis le COBOL legacy, je l'optimise, et je le branche aux APIs modernes**_

## A propos

Je travaille sur les environnements IBM (Mainframe, IBMi) depuis près de 15 ans. Dans ce parcours, j'ai rencontré divers systèmes critiques et exigeants me forçant à m'adapter.

Je suis aujourd'hui en pivot complet vers COBOL, avec un objectif clair : devenir l'interlocuteur capable de faire le pont entre un système COBOL historique et les besoins actuels — API, intégrations Java, modernisation ciblée sans réécriture complète.

Ce dépôt documente ce pivot : chaque projet est un jalon vers un objectif concret, pas un exercice isolé. L'ambition n'est pas d'apprendre COBOL mais d'exposer mon expertise legacy et ma capacité à le connecter au monde moderne.

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

| Projet                                         | Phase | Focus                                         | Status        |
| ---------------------------------------------- | ----- | --------------------------------------------- | ------------- |
| 1. [Hello World](projects/hellowld/README.md)  | 1     | Setup + syntaxe + Déploiement simple          | ✅ terminé    |
| 2. [Système Paie](projects/systpaie/README.md) | 1 - 2 | Variables, logique, Calculs financiers        | ✅ terminé    |
| 3. [Inventaire](projects/inventR/README.md)    | 2     | Fichiers I/O, traitement batch                | 👨‍💻 en cours   |
| 4. Refactoring Prod                            | 2     | Copybooks, sous-programmes, code réutilisable | 🚧 non débuté |
| 5. API COBOL (REST)                            | 2     | Intégrations modernes                         | 🚧 non débuté |
| 6. E-commerce Complet                          | 2     | Everything + BD                               | 🚧 non débuté |

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
