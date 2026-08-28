# Hello World COBOL

Premier programme du parcours : un programme minimal qui pose les bases de la structure d'un programme COBOL (les 4 divisions).

## Prérequis

- [GnuCOBOL](https://gnucobol.sourceforge.io/) installé (`cobc --version` pour vérifier)

## Compilation & exécution

```bash
cobc -std=ibm -xj HELLOWLD.cob
```

Ou en deux étapes :

```bash
cobc -std=ibm -x HELLOWLD.cob -o hellowld
./hellowld
```

`-std=ibm` aligne le compilateur sur le dialecte Enterprise COBOL (z/OS) plutôt que le dialecte GnuCOBOL par défaut.

## Sortie attendue

```
HELLO COBOL WORLD !
```

## Concepts démontrés

- Structure d'un programme COBOL en 4 divisions : `IDENTIFICATION`, `ENVIRONMENT`, `DATA`, `PROCEDURE`
- Zones de colonnes historiques : indicateur (colonne 7), zone A (colonne 8), zone B (colonne 12)
- Instruction `DISPLAY`
- Fin de programme : différence entre `STOP RUN`, `GOBACK` et `EXIT PROGRAM`
- `END PROGRAM` doit reprendre le nom déclaré dans `PROGRAM-ID`
