      *>COBOL TRAINING
      *>HELLO COBOL WORD
      *>AUTHOR: D GABA
      *>DATE STARTED : 2026-08-25
       IDENTIFICATION DIVISION.
           PROGRAM-ID. HELLOWLD.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       PROCEDURE DIVISION.
           DISPLAY 'HELLO COBOL WORLD !'.
      *>STOP RUN renvoie le controle à l'appelant le plus proche
      *>peut fermer le groupe d'activation (unite d execution)
      *>et les fichiers associés
           STOP RUN.
      *>------------------------------------
      *>Commandes équivalentes avec nuances
      *>------------------------------------
      *>   EXIT PROGRAM.
      *>   GOBACK.
      *>------------------------------------

       END PROGRAM HELLOWLD.
