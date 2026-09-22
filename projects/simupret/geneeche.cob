       IDENTIFICATION DIVISION. 
       PROGRAM-ID. GENEECHE.

       ENVIRONMENT DIVISION. 

       DATA DIVISION.
       WORKING-STORAGE SECTION. 
       LOCAL-STORAGE SECTION. 
       01 LS-CAPITAL-PREC   PIC 9(6)V99.

       LINKAGE SECTION.
       01 LK-CAPITAL        PIC 9(6)V99.
       01 LK-MT-MENSUALITE  PIC 9(6)V99.

       COPY 'tauxinter' REPLACING TAUX-INTERET BY LK-TAUX-INTERET
                                      TAUX-ANNUEL BY LK-TAUX-ANNUEL
                                      TAUX-MENSUEL BY LK-TAUX-MENSUEL.
       COPY 'echeance' REPLACING ECHEANCIER BY LK-ECHANCIER.

       PROCEDURE DIVISION USING LK-CAPITAL
                                LK-MT-MENSUALITE
                                LK-TAUX-INTERET
                                LK-ECHANCIER.

      *    Premiere occurence le capital precedent est le capital
           MOVE LK-CAPITAL TO LS-CAPITAL-PREC 

      *    Génération des échéances 3342
           PERFORM TEST AFTER VARYING ECHEANCEID FROM 1 BY 1
              UNTIL ECHEANCEID = NB-ECHEANCES
                   MOVE ECHEANCEID TO NUM-ECHEANCE(ECHEANCEID)

      *    Valoriser le capital précédent
                   MOVE LS-CAPITAL-PREC TO CAPITAL-PREC(ECHEANCEID)
                  
      *    Valoriser les intérêts
                   COMPUTE INTERET-ECHEANCE(ECHEANCEID) ROUNDED =
                      CAPITAL-PREC(ECHEANCEID) * LK-TAUX-MENSUEL 
                           
      *    Valoriser le capital remboursé
                   COMPUTE CAPITAL-REMBOURSE(ECHEANCEID) =
                      LK-MT-MENSUALITE -
                      INTERET-ECHEANCE(ECHEANCEID)

      *    Valoriser le capital restant 
                   COMPUTE CAPITAL-RESTANT(ECHEANCEID) =
                      CAPITAL-PREC(ECHEANCEID) - CAPITAL-REMBOURSE
                      (ECHEANCEID)
      
      *    Préparer le tour suivant 
                   MOVE CAPITAL-RESTANT(ECHEANCEID) TO LS-CAPITAL-PREC

           END-PERFORM
           
           GOBACK.
       END PROGRAM GENEECHE.
