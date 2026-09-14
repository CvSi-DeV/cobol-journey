      *>Evaluer le taux d'imposition et calculer l'impot
       IDENTIFICATION DIVISION. 
       PROGRAM-ID. CALCIMPO.

       ENVIRONMENT DIVISION. 

       DATA DIVISION. 
       WORKING-STORAGE SECTION. 
       01 WS-CST-TX-0               PIC 9V99    VALUE 0.
       01 WS-CST-TX-11              PIC 9V99    VALUE 0.11.
       01 WS-CST-TX-30              PIC 9V99    VALUE 0.30.
       01 WS-CST-TX-41              PIC 9V99    VALUE 0.41.
       LINKAGE SECTION. 
       01 LK-BASE-IMPOSABLE         PIC 9(5)V99.
          88 TRANCHE-BASE-EXONEREE              VALUE 0 THRU 1500.
          88 TRANCHE-BASE-11                    VALUE 1500.01 THRU 3000.
          88 TRANCHE-BASE-30                    VALUE 3000.01 THRU 6000.
          88 TRANCHE-BASE-41                    VALUE 6000.01 THRU
                99999.99.
       01 LK-TAUX-IMPO              PIC 9V99.
       01 LK-IMPOT                  PIC 9(5)V99.


       PROCEDURE DIVISION USING LK-BASE-IMPOSABLE LK-TAUX-IMPO LK-IMPOT.

           EVALUATE TRUE 
           WHEN TRANCHE-BASE-EXONEREE 
                MOVE WS-CST-TX-0 TO LK-TAUX-IMPO 
                COMPUTE LK-IMPOT = LK-BASE-IMPOSABLE * WS-CST-TX-0
           WHEN TRANCHE-BASE-11 
                MOVE WS-CST-TX-11 TO LK-TAUX-IMPO 
                COMPUTE LK-IMPOT = LK-BASE-IMPOSABLE * WS-CST-TX-11 
           WHEN TRANCHE-BASE-30 
                MOVE WS-CST-TX-30 TO LK-TAUX-IMPO 
                COMPUTE LK-IMPOT = LK-BASE-IMPOSABLE * WS-CST-TX-30 
           WHEN TRANCHE-BASE-41
                MOVE WS-CST-TX-41 TO LK-TAUX-IMPO 
                COMPUTE LK-IMPOT = LK-BASE-IMPOSABLE * WS-CST-TX-41 
           END-EVALUATE

           GOBACK.
           
       END PROGRAM CALCIMPO.
