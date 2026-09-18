       01 ECHEANCIER.
          05 NB-ECHEANCES          PIC 9(4).
          05 ECHEANCE OCCURS 1 TO 1200
                DEPENDING ON NB-ECHEANCES
                INDEXED BY ECHEANCEID.
             10 NUM-ECHEANCE       PIC 9(4).
             10 CAPITAL-PREC       PIC 9(6)V99.
             10 INTERET-ECHEANCE   PIC 9(6)V99.
             10 CAPITAL-REMBOURSE  PIC 9(6)V99.
             10 CAPITAL-RESTANT    PIC 9(6)V99.
