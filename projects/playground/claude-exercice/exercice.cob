       IDENTIFICATION DIVISION.
           PROGRAM-ID. EXCERCICE.

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-NOM PIC X(64).
       01 WS-AGE PIC 9(3).
       01 WS-SALAIRE PIC 9(12)V9(2).
       01 WS-LOOP PIC 9(2).
       01 WS-RESULTAT PIC 9(2).
       01 WS-REMAIN PIC 9(2).

       PROCEDURE DIVISION.
      *> initialisation des variables avec MOVE
           MOVE "Jean Pierre" tO WS-NOM
           MOVE 42 TO WS-AGE
           MOVE 3456.34 TO WS-SALAIRE

      *> affichage des variables avec DISPLAY
           DISPLAY "NOM : " FUNCTION TRIM(WS-NOM)
           DISPLAY "AGE : " WS-AGE
           DISPLAY "Salaire : " WS-SALAIRE

      *> affichage conditionnel majeur ou mineur
           IF WS-AGE IS LESS THAN 18 THEN
            DISPLAY FUNCTION TRIM(WS-NOM) " est mineur. (age " WS-AGE
      -    ")"
           ELSE
            DISPLAY FUNCTION TRIM(WS-NOM) " est majeur. (age " WS-AGE
      -    ")"
           END-IF

      *> boucle de comptage avec PERFORM VARYING qui affiche le statut
      *> pair ou impair du nombre (combine boucle + condition)
           PERFORM VARYING WS-LOOP
            FROM 1 BY 1
            UNTIL WS-LOOP > 10

      *> recupérer le reste de la division pour le modulo 2
      *> afin de savoir si le nombre est pair ou non
            DIVIDE WS-LOOP BY 2 GIVING WS-RESULTAT REMAINDER WS-REMAIN

            EVALUATE WS-REMAIN
                WHEN 0
                    DISPLAY '"' WS-LOOP '"' " est pair."
                WHEN OTHER
                     DISPLAY '"' WS-LOOP '"' " est impair."
            END-EVALUATE

           END-PERFORM

           GOBACK.

       END PROGRAM EXCERCICE.
