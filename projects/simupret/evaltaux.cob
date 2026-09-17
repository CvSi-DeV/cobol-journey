       IDENTIFICATION DIVISION.
       PROGRAM-ID. EVALTAUX.

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       LINKAGE SECTION.
      *    Type de pret
       01 LK-TYPE-PRET   PIC X.
          88 PRET-AUTO          VALUE 'A'.
          88 PRET-CONSO         VALUE 'C'.
          88 PRET-IMMO          VALUE 'I'.

      *    Durée du pret (année)
       01 LK-DUREE-PRET  PIC 99.
          88 AUTO-1             VALUE 0 THRU 3.
          88 AUTO-2             VALUE 4 THRU 5. 
          88 AUTO-3             VALUE 6 THRU 99. 
          88 CONSO-1            VALUE 0 THRU 2.
          88 CONSO-2            VALUE 3 THRU 4.
          88 CONSO-3            VALUE 5 THRU 99.
          88 IMMO-1             VALUE 0 THRU 15.
          88 IMMO-2             VALUE 16 THRU 20.
          88 IMMO-3             VALUE 21 THRU 99.
          

      *    Taux Interet
           COPY 'tauxinter' REPLACING TAUX-INTERET BY LK-TAUX-INTERET
                                      TAUX-ANNUEL BY LK-TAUX-ANNUEL
                                      TAUX-MENSUEL BY LK-TAUX-MENSUEL.
       
           
       PROCEDURE DIVISION USING LK-TYPE-PRET
                                LK-DUREE-PRET
                                LK-TAUX-INTERET.

           EVALUATE TRUE ALSO TRUE
      *    Conditions Pret Auto
           WHEN PRET-AUTO ALSO AUTO-1 
                MOVE 2.90 TO LK-TAUX-ANNUEL
           WHEN PRET-AUTO ALSO AUTO-2
                MOVE 3.20 TO LK-TAUX-ANNUEL 
           WHEN PRET-AUTO ALSO AUTO-3 
                MOVE 3.60 TO LK-TAUX-ANNUEL 
      *    Conditions Pret Conso
           WHEN PRET-CONSO ALSO CONSO-1 
                MOVE 4.50 TO LK-TAUX-ANNUEL 
           WHEN PRET-CONSO ALSO CONSO-2
                MOVE 5.20 TO LK-TAUX-ANNUEL 
           WHEN PRET-CONSO ALSO CONSO-3  
                MOVE 6.00 TO LK-TAUX-ANNUEL 
      *    Conditions Pret Immobilier     
           WHEN PRET-IMMO ALSO IMMO-1 
                MOVE 3.10 TO LK-TAUX-ANNUEL 
           WHEN PRET-IMMO ALSO IMMO-2 
                MOVE 3.45 TO LK-TAUX-ANNUEL 
           WHEN PRET-IMMO ALSO IMMO-3 
                MOVE 3.80 TO LK-TAUX-ANNUEL 
           END-EVALUATE

      *    Calculer le taux mensuel
           COMPUTE LK-TAUX-MENSUEL = LK-TAUX-ANNUEL / 100 / 12
           
           GOBACK.
       END PROGRAM EVALTAUX.
