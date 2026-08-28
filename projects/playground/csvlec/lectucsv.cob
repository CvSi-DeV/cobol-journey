       IDENTIFICATION DIVISION.
       PROGRAM-ID. LECTUCSV.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
           FILE-CONTROL.
      *> Selection du fichier
           SELECT EMPLOYES-CSV
           ASSIGN TO "employes.csv"
           ORGANIZATION IS LINE SEQUENTIAL
           FILE STATUS IS LS-F-STATUS.

       DATA DIVISION.
       FILE SECTION.
      *> File Description Employé
       FD EMPLOYES-CSV.
       01 EMPLOYE-RECORDS.
           05 EMPLOYE-RECORD PIC X(100).

       WORKING-STORAGE SECTION.
      *> Table de travail employé
       01 EMPLOYE-TABLE.
           05 EMPLOYE OCCURS 100 TIMES
               DEPENDING ON LS-NB-EMPLOYES
               INDEXED BY LS-ID-EMPLOYES.
           10 PRENOM PIC X(25).
           10 NOM PIC X(25).
           10 SALAIRE-BRUT PIC 9(5)V99.

       LOCAL-STORAGE SECTION.
      *> Statut Fin de fichier (EOF)
       01 LS-F-STATUS PIC X(2) VALUE '00'.
      *> Nombre de lignes lues
       01 LS-NB-READ PIC 9(3) VALUE 0.
      *> Nombre d'employés
       01 LS-NB-EMPLOYES PIC 9(3) VALUE 0.
      *> Salaire Brut format alpha 5.2
       01 SALAIRE-BRUT-ALPHA PIC X(8).

      *> Struture Record pour les calculs
       01 CALCULS.
           05 COTISATION PIC 9(5)V99.
           05 BASE-IMPOSABLE PIC 9(5)V99.
           05 TAUX-IMPOSITION PIC 9(2).
           05 IMPOT PIC 9(5)V99.
           05 SALAIRE-NET PIC 9(5)V99.

       PROCEDURE DIVISION.
      *> Ouverture du fichier
           OPEN INPUT EMPLOYES-CSV.

      *> Lecture du fichier
           PERFORM UNTIL LS-F-STATUS = '10'
           READ EMPLOYES-CSV
               AT END
                   DISPLAY 'Nombre d''employés : ' LS-NB-EMPLOYES
               NOT AT END
      *> Incrementation du nombre d'enregistrement lu
               ADD 1 TO LS-NB-READ
      *> Ignore la premiere ligne (entete)
               IF LS-NB-READ IS GREATER THAN 1
      *> Incrementation du nombre d'employé
                   ADD 1 TO LS-NB-EMPLOYES
      *> affectation de l'index
                   MOVE LS-NB-EMPLOYES to LS-ID-EMPLOYES
      *> Récupération des données de l'enregistrement.
                   UNSTRING EMPLOYE-RECORD DELIMITED BY ','
                       INTO PRENOM(LS-ID-EMPLOYES), NOM(LS-ID-EMPLOYES),
                       SALAIRE-BRUT-ALPHA
                   END-UNSTRING

      *> Conversion du salaire brut en nombre
                   COMPUTE SALAIRE-BRUT(LS-ID-EMPLOYES) =
                   FUNCTION NUMVAL(SALAIRE-BRUT-ALPHA)

      *> Affichage de la liste d'employés
                   DISPLAY '- '
                       FUNCTION TRIM(PRENOM(LS-ID-EMPLOYES)) ' '
                          FUNCTION TRIM(NOM(LS-ID-EMPLOYES)) ' : '
                              SALAIRE-BRUT(LS-ID-EMPLOYES)

        *> Calcul de cotisation
                   COMPUTE COTISATION =
                       SALAIRE-BRUT(LS-ID-EMPLOYES) * 22 / 100
      *> Calcul de la base imposable
                   COMPUTE BASE-IMPOSABLE =
                       SALAIRE-BRUT(LS-ID-EMPLOYES) - COTISATION
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
                   COMPUTE IMPOT =
                       BASE-IMPOSABLE * TAUX-IMPOSITION / 100
      *> Calcul du Salaire NET
                   COMPUTE SALAIRE-NET =
                       BASE-IMPOSABLE - IMPOT

      *> AFFICHAGE FINALE
           DISPLAY '-----------------------------'
           DISPLAY '------ FICHE DE PAIE --------'
           DISPLAY '-----------------------------'
           DISPLAY '- NOM : ' FUNCTION TRIM(NOM(LS-ID-EMPLOYES))
           DISPLAY '- PRENOM : ' FUNCTION TRIM(PRENOM(LS-ID-EMPLOYES))
           DISPLAY '-----------------------------'
           DISPLAY '- SALAIRE BRUT     : ' SALAIRE-BRUT(LS-ID-EMPLOYES)
           DISPLAY '--'
           DISPLAY '- COTISATIONS      : ' COTISATION
           DISPLAY '- BASE IMPOSABLE   : ' BASE-IMPOSABLE
           DISPLAY '- TAUX IMPOT       : ' TAUX-IMPOSITION '%'
           DISPLAY '- IMPOT            : ' IMPOT
           DISPLAY '--'
           DISPLAY '- SALAIRE NET      : ' SALAIRE-NET
           DISPLAY '-----------------------------'
           DISPLAY ' '

               END-IF
           END-PERFORM.

      *> Fermeture du fichier
           CLOSE EMPLOYES-CSV.
           GOBACK.
       END PROGRAM LECTUCSV.
