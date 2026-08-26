       IDENTIFICATION DIVISION.
           PROGRAM-ID. ifelsest.

       ENVIRONMENT DIVISION.


       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 RESULT PIC 9(2).

       PROCEDURE DIVISION.

           COMPUTE RESULT = 13 * 7

           IF RESULT IS LESS THAN 100 THEN
           DISPLAY "Le resultat est inférieur à 100 => " RESULT
           ELSE
           DISPLAY "L'UNIVERS NE TOURNE PAS ROND"
           END-IF

           GOBACK.

       END PROGRAM ifelsest.
