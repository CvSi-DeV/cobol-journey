       IDENTIFICATION DIVISION.
           PROGRAM-ID. IFSTAT.

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 RESULT PIC 9(3).

       PROCEDURE DIVISION.
           MULTIPLY 6 BY 7 GIVING RESULT.

           IF RESULT IS LESS THAN 100 THEN
           DISPLAY "Le resultat est inférieur à 100 => " RESULT

           END-IF

      *> juste ecrire une condition opposée qui ne sera jamais vraie
           IF RESULT is GREATER THAN 100 THEN
           DISPLAY "Anomalie : le resultat est plus grand que 100 => "
      -     RESULT
           END-IF

           GOBACK.

       END PROGRAM IFSTAT.
