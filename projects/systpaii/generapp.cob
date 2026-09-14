      *> Génération du rapport
       IDENTIFICATION DIVISION. 
       PROGRAM-ID. GENERAPP.

       ENVIRONMENT DIVISION. 
       INPUT-OUTPUT SECTION. 
       FILE-CONTROL. 
           SELECT RAPPORT-FP
           ASSIGN TO 'rapport-fp.txt'
           ORGANIZATION IS LINE SEQUENTIAL.
       DATA DIVISION. 
       FILE SECTION. 
      *> FD du fichier de sortie
       FD RAPPORT-FP.
       01 FS-RAPPORT-RECORDS.
          05 RAPPORT-RECORD           PIC X(29).
       LOCAL-STORAGE SECTION. 
       01 LS-NB-FICHE-PAIE            PIC 9(3).
      *>Record pour le formatage de l'affichage
       01 LS-PAIE-DATA-DISP.
          05 LS-PRENOM-DISP           PIC X(25).
          05 LS-NOM-DISP              PIC X(25).
          05 LS-SALAIRE-BRUT-DISP     PIC ZZZZ9.99.
          05 LS-COTISATION-DISP       PIC ZZZZ9.99.
          05 LS-BASE-IMPOSABLE-DISP   PIC ZZZZ9.99.
          05 LS-TAUX-IMPOSITION-DISP  PIC ZZZZ9.99.
          05 LS-IMPOT-DISP            PIC ZZZZ9.99.
          05 LS-SALAIRE-NET-DISP      PIC ZZZZ9.99.
 
       LINKAGE SECTION. 
       COPY 'PAIEDATA' REPLACING PAIE-DATA BY LK-PAIE-DATA.
       01 LK-NB-RAPPORT               PIC 9(3).

       PROCEDURE DIVISION USING LK-PAIE-DATA LK-NB-RAPPORT.
      *>   Ouvrir le fihier 
           OPEN OUTPUT RAPPORT-FP.

      *>   Boucle sur les fiches de paies
           PERFORM TEST AFTER VARYING LS-NB-FICHE-PAIE FROM 1 BY 1
              UNTIL LS-NB-FICHE-PAIE = LK-NB-RAPPORT 
 
      *>   Initialiser la zone de sortie
                   MOVE ZEROS TO RAPPORT-RECORD
                   MOVE '-----------------------------' TO
                      RAPPORT-RECORD 
                   PERFORM RAPPORT-LINE
                   MOVE '------ FICHE DE PAIE --------' TO
                      RAPPORT-RECORD
                   PERFORM RAPPORT-LINE 
                   MOVE '-----------------------------' TO
                      RAPPORT-RECORD 
                   PERFORM RAPPORT-LINE 

                   MOVE NOM(LS-NB-FICHE-PAIE) TO LS-NOM-DISP 
                   STRING '- NOM : '
                          FUNCTION
                      TRIM(LS-NOM-DISP) DELIMITED BY
                      SIZE
                      INTO RAPPORT-RECORD
                   PERFORM RAPPORT-LINE 

                   MOVE PRENOM(LS-NB-FICHE-PAIE) TO LS-PRENOM-DISP 
                   STRING '- PRENOM : '
                          FUNCTION
                      TRIM(LS-PRENOM-DISP)
                      DELIMITED BY SIZE INTO RAPPORT-RECORD
                   PERFORM RAPPORT-LINE 
                   MOVE '-----------------------------' TO
                      RAPPORT-RECORD
                   PERFORM RAPPORT-LINE 
      
                   MOVE SALAIRE-BRUT(LS-NB-FICHE-PAIE) TO
                      LS-SALAIRE-BRUT-DISP 
                   STRING '- SALAIRE BRUT     : '
                          LS-SALAIRE-BRUT-DISP
                      DELIMITED BY SIZE INTO RAPPORT-RECORD
                   PERFORM RAPPORT-LINE 
                   MOVE '--' TO RAPPORT-RECORD
                   PERFORM RAPPORT-LINE 

                   MOVE COTISATION(LS-NB-FICHE-PAIE) TO
                      LS-COTISATION-DISP 
                   STRING '- COTISATIONS      : '
                          LS-COTISATION-DISP
                      DELIMITED BY SIZE INTO RAPPORT-RECORD
                   PERFORM RAPPORT-LINE 

                   MOVE BASE-IMPOSABLE(LS-NB-FICHE-PAIE) TO
                      LS-BASE-IMPOSABLE-DISP 
                   STRING '- BASE IMPOSABLE   : '
                          LS-BASE-IMPOSABLE-DISP
                      DELIMITED BY SIZE INTO RAPPORT-RECORD
                   PERFORM RAPPORT-LINE 

                   MOVE TAUX-IMPOSITION(LS-NB-FICHE-PAIE) TO
                      LS-TAUX-IMPOSITION-DISP 
                   STRING '- TAUX IMPOT       : '
                          LS-TAUX-IMPOSITION-DISP
                      DELIMITED BY SIZE INTO RAPPORT-RECORD
                   PERFORM RAPPORT-LINE 

                   MOVE IMPOT(LS-NB-FICHE-PAIE) TO LS-IMPOT-DISP 
                   STRING '- IMPOT            : '
                          LS-IMPOT-DISP DELIMITED BY SIZE
                      INTO RAPPORT-RECORD
                   PERFORM RAPPORT-LINE 

                   MOVE SALAIRE-NET(LS-NB-FICHE-PAIE) TO
                      LS-SALAIRE-NET-DISP 
                   MOVE '--' TO RAPPORT-RECORD
                   PERFORM RAPPORT-LINE 
                   STRING '- SALAIRE NET      : '
                          LS-SALAIRE-NET-DISP
                      DELIMITED BY SIZE INTO RAPPORT-RECORD
                   PERFORM RAPPORT-LINE 
                   MOVE '-----------------------------' TO
                      RAPPORT-RECORD
                   PERFORM RAPPORT-LINE 

           END-PERFORM
      *>   Fermer le fichier     
           CLOSE RAPPORT-FP.

           GOBACK.
           
      *>   Ecrire une ligne du rapport     
       RAPPORT-LINE.
           DISPLAY RAPPORT-RECORD
           WRITE FS-RAPPORT-RECORDS
           MOVE SPACES TO RAPPORT-RECORD
           .
       END PROGRAM GENERAPP.
