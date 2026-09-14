      *>Programme COBOL qui calcule le salaire **brut → net**
      *>d'un employé, avec cotisations sociales et impôt simplifié
      *>par tranches.
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. SYSTPAII.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT EMPLOYES-DAT
           ASSIGN TO 'employes.dat'
           ORGANIZATION IS LINE SEQUENTIAL
           FILE STATUS IS LS-F-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  EMPLOYES-DAT.
      *> Convention COBOL 
      *    COPY 'employe.cpy' REPLACING EMPLOYE BY EMPLOYE-RECORDS.
      *> Convention Z/OS
           COPY "EMPLOYE" REPLACING EMPLOYE BY EMPLOYE-RECORDS.

       WORKING-STORAGE SECTION.
      *> Définition d'un employé
      *> Convention COBOL 
      *     COPY "employe.cpy".
      *> Convention Z/OS
           COPY "EMPLOYE".

      *> Struture Record pour les calculs
           COPY "PAIEDATA".

       LOCAL-STORAGE SECTION.
       01 LS-F-STATUS      PIC X(2) VALUE "00".
          88 END-OF-FILE            VALUE "10".
          88 FILE-MISSING           VALUE "35".

       01 LS-NB-READ       PIC 9(3) VALUE 0.
       01 LS-NB-EMPLOYES   PIC 9(3) VALUE 0.

       PROCEDURE DIVISION.
      *> Ouverture du ficher EMPLOYES-DAT en lecture
           OPEN INPUT EMPLOYES-DAT.

           IF FILE-MISSING THEN 
              DISPLAY "ERREUR : fichier employes.dat absent."
              STOP RUN
           END-IF 
      
      *> Lecture du fichier jusqu'à la fin (EOF)
           PERFORM UNTIL END-OF-FILE
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
                       MOVE PRENOM OF EMPLOYE TO PRENOM IN
                          PAIE-DATA(LS-NB-EMPLOYES)
                       MOVE NOM OF EMPLOYE TO NOM IN
                          PAIE-DATA(LS-NB-EMPLOYES)
                       MOVE SALAIRE-BRUT OF EMPLOYE TO SALAIRE-BRUT IN
                          PAIE-DATA(LS-NB-EMPLOYES)
      *> Calcul de cotisation
                       CALL "CALCCOTI"
                          USING SALAIRE-BRUT OF EMPLOYE
                                COTISATION(LS-NB-EMPLOYES) 
      *> Calcul de la base imposable
                       CALL "CALCBIMP"
                          USING SALAIRE-BRUT OF EMPLOYE
                                COTISATION(LS-NB-EMPLOYES)
                                BASE-IMPOSABLE(LS-NB-EMPLOYES)

      *> Evaluation du taux d'imposition et calcul de l'impot
                       CALL "CALCIMPO"
                          USING BASE-IMPOSABLE(LS-NB-EMPLOYES)
                                TAUX-IMPOSITION(LS-NB-EMPLOYES)
                                IMPOT(LS-NB-EMPLOYES)

      *> Calcul du Salaire NET
                       CALL "CALCSALN"
                          USING BASE-IMPOSABLE(LS-NB-EMPLOYES)
                                IMPOT(LS-NB-EMPLOYES)
                                SALAIRE-NET(LS-NB-EMPLOYES)
                   END-READ
           END-PERFORM
           CLOSE EMPLOYES-DAT.
                          
           CALL "GENERAPP" USING PAIE-DATA LS-NB-EMPLOYES 

           GOBACK.

       END PROGRAM SYSTPAII.
