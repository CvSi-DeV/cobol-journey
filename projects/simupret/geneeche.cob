       IDENTIFICATION DIVISION. 
       PROGRAM-ID. GENEECHE.

       ENVIRONMENT DIVISION. 

       DATA DIVISION.
       WORKING-STORAGE SECTION. 
       LOCAL-STORAGE SECTION. 
       01 LS-CAPITAL-PREC     PIC 9(6)V99.

      *    TEMPORAIRE ET DEBUG 
      
       01 LS-CAPITAL-RECALC   PIC 9(6)V99  VALUE ZERO.
       01 LS-DISP-CAPI-REC    PIC Z(5)9.99.
       01 LS-INTERET-SOMME    PIC 9(6)V99  VALUE ZERO.
       01 LS-DISP-INT-SOM     PIC Z(5)9.99.
       01 LS-COUT-TOTAL       PIC 9(6)V99  VALUE ZERO.
       01 LS-DISP-COUT-TOTAL  PIC Z(5)9.99.
       01 LS-DISP-VALUE       PIC Z(5)9.99.
       LINKAGE SECTION.
       01 LK-CAPITAL          PIC 9(6)V99.
       01 LK-MT-MENSUALITE    PIC 9(6)V99.

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
      *    --
                   MOVE CAPITAL-PREC(ECHEANCEID) TO LS-DISP-VALUE 
                   DISPLAY 'Capital précédent : ' LS-DISP-VALUE 
                  
      *    Valoriser les intérêts
                   COMPUTE INTERET-ECHEANCE(ECHEANCEID) ROUNDED =
                      CAPITAL-PREC(ECHEANCEID) * LK-TAUX-MENSUEL 
      *    --
                   MOVE INTERET-ECHEANCE(ECHEANCEID) TO LS-DISP-VALUE 
                   DISPLAY 'Interet echeance : ' LS-DISP-VALUE 
                           
      *    Valoriser le capital remboursé
                   COMPUTE CAPITAL-REMBOURSE(ECHEANCEID) =
                      LK-MT-MENSUALITE -
                      INTERET-ECHEANCE(ECHEANCEID)
      *    --
                   MOVE CAPITAL-REMBOURSE(ECHEANCEID) TO LS-DISP-VALUE     
                   DISPLAY 'Capital remboursé : ' LS-DISP-VALUE 

      *    TEST-------------------------------------------------------
                   COMPUTE LS-INTERET-SOMME = LS-INTERET-SOMME +
                      INTERET-ECHEANCE(ECHEANCEID)                   
                   COMPUTE LS-CAPITAL-RECALC =
                      LS-CAPITAL-RECALC + CAPITAL-REMBOURSE(ECHEANCEID)
      *    TEST-------------------------------------------------------

      *    Valoriser le capital restant 
                   COMPUTE CAPITAL-RESTANT(ECHEANCEID) =
                      CAPITAL-PREC(ECHEANCEID) - CAPITAL-REMBOURSE
                      (ECHEANCEID)
      *    --
                   MOVE CAPITAL-RESTANT(ECHEANCEID) TO LS-DISP-VALUE  
                   DISPLAY 'Capital restant : ' LS-DISP-VALUE 
      
      *    Préparer le tour suivant 
                   MOVE CAPITAL-RESTANT(ECHEANCEID) TO LS-CAPITAL-PREC

           END-PERFORM
           
      *    TEST-------------------------------------------------------
           DISPLAY '-- VERIFICATION --'
           MOVE LS-CAPITAL-RECALC TO LS-DISP-CAPI-REC 
           DISPLAY 'CAPI RECALC : ' LS-DISP-CAPI-REC  
           MOVE LS-INTERET-SOMME TO LS-DISP-INT-SOM 
           DISPLAY 'SOMMES INTERET : ' LS-DISP-INT-SOM 
           COMPUTE LS-COUT-TOTAL = LS-CAPITAL-RECALC + LS-INTERET-SOMME 
           MOVE LS-COUT-TOTAL TO LS-DISP-COUT-TOTAL 
           DISPLAY 'COUT TOTAL : ' LS-DISP-COUT-TOTAL 
           DISPLAY '-- VERIFICATION --'
      *    TEST-------------------------------------------------------

           GOBACK.
       END PROGRAM GENEECHE.
