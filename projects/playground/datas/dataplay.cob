       IDENTIFICATION DIVISION.
           PROGRAM-ID. DATAPLAY.

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *> chaine de 64 caractères
       01 PROGRAM-MESSAGE PIC X(64).
      *> nombre de 2 digit PIC 9(2)
       01 ANSWER PIC 99.

       PROCEDURE DIVISION.

      *> affecter une chaine litteral dans un variable
           MOVE "dataplay.cob exemple" to PROGRAM-MESSAGE
           DISPLAY PROGRAM-MESSAGE

           MOVE "calcul de 6 * 7" to PROGRAM-MESSAGE
           DISPLAY PROGRAM-MESSAGE

           MOVE "la réponse est : " TO PROGRAM-MESSAGE
           DISPLAY PROGRAM-MESSAGE

      *>executer une calcul
           COMPUTE ANSWER = 6 * 7.
           DISPLAY ANSWER

           GOBACK.

       END PROGRAM DATAPLAY.

