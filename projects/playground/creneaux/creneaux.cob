      *> CRENEAUX.COB
      *> 04/09/2026
      *> CVSI 
       IDENTIFICATION DIVISION. 
       PROGRAM-ID. CRENEAUX.

       ENVIRONMENT DIVISION. 
       INPUT-OUTPUT SECTION. 
       FILE-CONTROL.
           SELECT OPTIONAL FCRENEAUX
           ASSIGN TO "creneaux.dat"
           ORGANIZATION IS RELATIVE
           FILE STATUS IS LS-FS-CRENEAUX
           ACCESS MODE IS DYNAMIC
           RELATIVE KEY IS LS-RK-CRENEAUX.

       DATA DIVISION. 
       FILE SECTION. 
       FD FCRENEAUX.
       01 CRENEAU.
          05 SLOT         PIC 9(2).
          05 ETAT         PIC X(10).
          
       WORKING-STORAGE SECTION.
       77 CST-FS-EOF      PIC X(2)  VALUE "10".

       LOCAL-STORAGE SECTION. 
       01 LS-FS-CRENEAUX  PIC X(2).
       01 LS-RK-CRENEAUX  PIC 9(3).
       01 LS-FILE-STATUS  PIC X(2).
       01 LS-COUNT        PIC 9(2).

       PROCEDURE DIVISION.
      *>   Ecriture initiale des créneaux. 
           PERFORM INIT-WRITE
      *>   Relecture des créneaux. 
           PERFORM CHECK-READ     
      *>   Modification des créneaux.     
           PERFORM MOD-REWRITE
      *>   Relecture des crénaux.     
           PERFORM CHECK-READ

           GOBACK.
      *> Procédure d'écriture initiale des créneaux.
       INIT-WRITE.
           DISPLAY "--"
           DISPLAY "INIT WRITE"
           DISPLAY "--"
           OPEN OUTPUT FCRENEAUX.
           MOVE LS-FS-CRENEAUX TO LS-FILE-STATUS
           DISPLAY "OPEN FS : " LS-FILE-STATUS

      *>   Comme ACCESS IS DYNAMIC le RELATIVE KEY doit être spécifié.
      *>   C'est pour cela qu'on se sert de RELATIVE KEY pour boucler.
      *>
      *>   On crée des créneaux de 9h à 13h
           IF LS-FILE-STATUS = "00" OR LS-FILE-STATUS = "05" THEN
              PERFORM TEST AFTER VARYING LS-RK-CRENEAUX FROM 1 BY 1
                 UNTIL LS-RK-CRENEAUX = 5
                 OR LS-FILE-STATUS IS NOT EQUAL TO '00'
                      COMPUTE SLOT = LS-RK-CRENEAUX + 8
                      MOVE "LIBRE" TO ETAT
                      WRITE CRENEAU
                      MOVE LS-FS-CRENEAUX TO LS-FILE-STATUS
              END-PERFORM
           END-IF
           CLOSE FCRENEAUX
           .
     
      *> Procédure de modification des créneaux. 
       MOD-REWRITE.
           DISPLAY "--"
           DISPLAY "MOD REWRITE"
           DISPLAY "--"

           OPEN I-O FCRENEAUX
           MOVE LS-FS-CRENEAUX TO LS-FILE-STATUS
           DISPLAY "OPEN FS : " LS-FILE-STATUS

      *>   Modifier le 3e enregistrement
           MOVE 3 TO LS-RK-CRENEAUX
           READ FCRENEAUX INTO CRENEAU
           INVALID KEY
                   DISPLAY "CRENEAU INTROUVABLE"
           NOT INVALID KEY
               DISPLAY CRENEAU
               MOVE "RESERVE" TO ETAT
               REWRITE CRENEAU
               MOVE LS-FS-CRENEAUX TO LS-FILE-STATUS
               DISPLAY LS-FILE-STATUS  
           END-READ   
           CLOSE FCRENEAUX
           .

      *> Procédure de relecture des créneaux écrits en REWRITE. 
       CHECK-READ.
           DISPLAY "--"
           DISPLAY "CHECK READ"
           DISPLAY "--"     
           
           OPEN INPUT FCRENEAUX
           MOVE LS-FS-CRENEAUX TO LS-FILE-STATUS
           DISPLAY "OPEN FS : " LS-FILE-STATUS
      
           PERFORM TEST AFTER UNTIL LS-FILE-STATUS = CST-FS-EOF
      *>   NEXT doit être précisé pour les fichiers en acces Dynamic
                   READ FCRENEAUX NEXT INTO CRENEAU
                   AT END 
                      MOVE LS-FS-CRENEAUX TO LS-FILE-STATUS
                      DISPLAY "END FS : " LS-FILE-STATUS
                   NOT AT END 
                       MOVE LS-FS-CRENEAUX TO LS-FILE-STATUS
                       DISPLAY "-- " SLOT "h -- " ETAT " --"
                   END-READ
           END-PERFORM
           CLOSE FCRENEAUX
           . 

       END PROGRAM CRENEAUX.
