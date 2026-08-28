      *>Programme COBOL qui calcule le salaire **brut → net**
      *>d'un employé, avec cotisations sociales et impôt simplifié
      *>par tranches.
      *>Version simple : un seul employé, données codées en dur
      *>(pas de fichier, pas de saisie utilisateur).
       IDENTIFICATION DIVISION.
           PROGRAM-ID. systpaie.

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *> Définition d'un employé
       01 EMPLOYE.
           05 PRENOM PIC X(25).
           05 NOM    PIC X(25).
           05 SALAIRE-BRUT PIC 9(5)V99.

      *> Struture Record pour les calculs
       01 CALCULS.
           05 COTISATION PIC 9(5)V99.
           05 BASE-IMPOSABLE PIC 9(5)V99.
           05 TAUX-IMPOSITION PIC 9(2).
           05 IMPOT PIC 9(5)V99.
           05 SALAIRE-NET PIC 9(5)V99.

       PROCEDURE DIVISION.

      *> Valorisation du record EMPLOYE
           MOVE "MICHELE" TO PRENOM
           MOVE "CONTRIB" TO NOM
           MOVE 8000 TO SALAIRE-BRUT


      *> Calcul de cotisation
           COMPUTE COTISATION = SALAIRE-BRUT * 22 / 100.
      *> Calcul de la base imposable
           COMPUTE BASE-IMPOSABLE = SALAIRE-BRUT - COTISATION.
      *> Evaluation du taux d'imposition
           EVALUATE TRUE
               WHEN BASE-IMPOSABLE LESS THAN OR EQUAL TO 1500
                   MOVE 0 TO TAUX-IMPOSITION
               WHEN BASE-IMPOSABLE <= 3000
                   MOVE 11 TO TAUX-IMPOSITION
               WHEN BASE-IMPOSABLE <= 6000
                   MOVE 30 TO TAUX-IMPOSITION
               WHEN OTHER
                   MOVE 41 TO TAUX-IMPOSITION
           END-EVALUATE.
      *> Calcul de l'impot
           COMPUTE IMPOT = BASE-IMPOSABLE * TAUX-IMPOSITION / 100
      *> Calcul du Salaire NET
           COMPUTE SALAIRE-NET = BASE-IMPOSABLE - IMPOT

      *> AFFICHAGE FINALE
           DISPLAY '-----------------------------'
           DISPLAY '------ FICHE DE PAIE --------'
           DISPLAY '-----------------------------'
           DISPLAY '- NOM : ' FUNCTION TRIM(NOM)
           DISPLAY '- PRENOM : ' FUNCTION TRIM(PRENOM)
           DISPLAY '-----------------------------'
           DISPLAY '- SALAIRE BRUT     : ' SALAIRE-BRUT
           DISPLAY '--'
           DISPLAY '- COTISATIONS      : ' COTISATION
           DISPLAY '- BASE IMPOSABLE   : ' BASE-IMPOSABLE
           DISPLAY '- TAUX IMPOT       : ' TAUX-IMPOSITION '%'
           DISPLAY '- IMPOT            : ' IMPOT
           DISPLAY '--'
           DISPLAY '- SALAIRE NET      : ' SALAIRE-NET
           DISPLAY '-----------------------------'

           GOBACK.

       END PROGRAM systpaie.
