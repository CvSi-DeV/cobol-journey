      *>Programme COBOL qui calcule le salaire **brut → net**
      *>d'un employé, avec cotisations sociales et impôt simplifié
      *>par tranches.
      *>Version simple : un seul employé, données codées en dur
      *>(pas de fichier, pas de saisie utilisateur).
      ******************************************************************
      *> V2 : intégration de la lecture d'un fichier externe d'employés
       IDENTIFICATION DIVISION.
           PROGRAM-ID. systpaie.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
           FILE-CONTROL.
           SELECT EMPLOYES-DAT
           ASSIGN TO 'employes.dat'
           ORGANIZATION IS LINE SEQUENTIAL
           FILE STATUS IS LS-F-STATUS.

           SELECT RAPPORT-FP
           ASSIGN TO 'rapport-fp.txt'
           ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  EMPLOYES-DAT.
       01  EMPLOYE-RECORDS.
           05 ER-PRENOM PIC X(25).
           05 ER-NOM PIC X(25).
           05 ER-SALAIRE-BRUT PIC 9(5)V99.

      *> FD du fichier de sortie
       FD RAPPORT-FP.
       01  RAPPORT-RECORDS.
           05 RAPPORT-RECORD PIC X(29).

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

       LOCAL-STORAGE SECTION.
       01 LS-F-STATUS PIC X(2) VALUE '00'.

       01 LS-NB-READ PIC 9(3) VALUE 0.
       01 LS-NB-EMPLOYES PIC 9(3) VALUE 0.

       PROCEDURE DIVISION.
      *> Ouverture du ficher EMPLOYES-DAT en lecture
           OPEN INPUT EMPLOYES-DAT.
           OPEN OUTPUT RAPPORT-FP.

      *> Lecture du fichier jusqu'à la fin (EOF)
           PERFORM UNTIL LS-F-STATUS = '10'
               READ EMPLOYES-DAT
                   AT END

      *> Affichage du nombre d'employés
                       DISPLAY 'Nombre d''employés : ' LS-NB-EMPLOYES

                   NOT AT END
                       ADD 1 TO LS-NB-READ
                       ADD 1 TO LS-NB-EMPLOYES

      *> Valorisation des données lues dans la mémoire de travail
               MOVE EMPLOYE-RECORDS TO EMPLOYE
      *> Ecriture équivalente champs par champs
      *         MOVE ER-PRENOM TO PRENOM
      *         MOVE ER-NOM TO NOM
      *         MOVE ER-SALAIRE-BRUT TO SALAIRE-BRUT

      *> Calcul de cotisation
               COMPUTE COTISATION = SALAIRE-BRUT * 22 / 100
      *> Calcul de la base imposable
               COMPUTE BASE-IMPOSABLE = SALAIRE-BRUT - COTISATION
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
               END-EVALUATE
      *> Calcul de l'impot
               COMPUTE IMPOT = BASE-IMPOSABLE * TAUX-IMPOSITION / 100
      *> Calcul du Salaire NET
               COMPUTE SALAIRE-NET = BASE-IMPOSABLE - IMPOT

      *> AFFICHAGE FINALE
               INITIALIZE RAPPORT-RECORD
               MOVE '-----------------------------' TO RAPPORT-RECORD
               PERFORM 2000-WRITE-RECORDS

               INITIALIZE RAPPORT-RECORD
               MOVE '------ FICHE DE PAIE --------' TO RAPPORT-RECORD
               PERFORM 2000-WRITE-RECORDS

               INITIALIZE RAPPORT-RECORD
               MOVE '-----------------------------' TO RAPPORT-RECORD
               PERFORM 2000-WRITE-RECORDS

               INITIALIZE RAPPORT-RECORD
               STRING '- NOM : ' FUNCTION TRIM(NOM) DELIMITED BY SIZE
                   INTO RAPPORT-RECORD
               PERFORM 2000-WRITE-RECORDS

               INITIALIZE RAPPORT-RECORD
               STRING '- PRENOM : ' FUNCTION TRIM(PRENOM)
                   DELIMITED BY SIZE INTO RAPPORT-RECORD
               PERFORM 2000-WRITE-RECORDS

               INITIALIZE RAPPORT-RECORD
               MOVE '-----------------------------' TO RAPPORT-RECORD
               PERFORM 2000-WRITE-RECORDS

               INITIALIZE RAPPORT-RECORD
               STRING '- SALAIRE BRUT     : ' SALAIRE-BRUT
                   DELIMITED BY SIZE INTO RAPPORT-RECORD
               PERFORM 2000-WRITE-RECORDS

               INITIALIZE RAPPORT-RECORD
               MOVE '--' TO RAPPORT-RECORD
               PERFORM 2000-WRITE-RECORDS

               INITIALIZE RAPPORT-RECORD
               STRING '- COTISATIONS      : ' COTISATION
                   DELIMITED BY SIZE INTO RAPPORT-RECORD
               PERFORM 2000-WRITE-RECORDS

               INITIALIZE RAPPORT-RECORD
               STRING '- BASE IMPOSABLE   : ' BASE-IMPOSABLE
                   DELIMITED BY SIZE INTO RAPPORT-RECORD
               PERFORM 2000-WRITE-RECORDS

               INITIALIZE RAPPORT-RECORD
               STRING '- TAUX IMPOT       : ' TAUX-IMPOSITION '%'
                   DELIMITED BY SIZE INTO RAPPORT-RECORD
               PERFORM 2000-WRITE-RECORDS

               INITIALIZE RAPPORT-RECORD
               STRING '- IMPOT            : ' IMPOT DELIMITED BY SIZE
                   INTO RAPPORT-RECORD
               PERFORM 2000-WRITE-RECORDS

               INITIALIZE RAPPORT-RECORD
               MOVE '--' TO RAPPORT-RECORD
               PERFORM 2000-WRITE-RECORDS

               INITIALIZE RAPPORT-RECORD
               STRING '- SALAIRE NET      : ' SALAIRE-NET
               DELIMITED BY SIZE INTO RAPPORT-RECORD
               PERFORM 2000-WRITE-RECORDS

               INITIALIZE RAPPORT-RECORD
               MOVE '-----------------------------' TO RAPPORT-RECORD
               PERFORM 2000-WRITE-RECORDS


           END-PERFORM.

           CLOSE EMPLOYES-DAT
          *> Fermeture du fichier de sortie
           CLOSE RAPPORT-FP

           GOBACK.

       2000-WRITE-RECORDS.
           DISPLAY RAPPORT-RECORD
           WRITE RAPPORT-RECORDS.

       END PROGRAM systpaie.
