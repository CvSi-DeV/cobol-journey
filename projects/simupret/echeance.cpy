       01 ECHEANCIER.
          05 NB-ECHEANCES          PIC 9(3).
          05 ECHEANCES OCCURS 1 TO 300
      *    limit du pret à 25 ans soit 300 echances   
                DEPENDING ON NB-ECHEANCES
                INDEXED BY ECHEANCEID.
             10 NUM-ECHEANCE       PIC 9(4).
             10 CAPITAL-PREC       PIC 9(6)V99.
             10 INTERET-ECHEANCE   PIC 9(6)V99.
             10 CAPITAL-REMBOURSE  PIC 9(6)V99.
             10 CAPITAL-RESTANT    PIC S9(6)V99.
