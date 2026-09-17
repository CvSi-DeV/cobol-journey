       IDENTIFICATION DIVISION. 
       PROGRAM-ID. SIMUPRET.

       ENVIRONMENT DIVISION. 
       
       DATA DIVISION. 
       WORKING-STORAGE SECTION.
      *    Caractéristique du pret    
           COPY 'dempret'.
      *    Taux Interet Annuel
       01 WS-TAUX-INTERET   PIC 9(2)V99.
       01 WS-MT-MENSUALITE  PIC 9(6)V99.
       LOCAL-STORAGE SECTION. 
       01 LS-TAUX-INTERET   PIC Z9.99.
       01 LS-MT-MENSUALITE  PIC Z(5)9.99.
       PROCEDURE DIVISION.

           DISPLAY "Bienvenue dans le simulateur de pret."
      
      *    Selectionner le type de pret
           PERFORM SELECT-TYPE-PRET.
      *    Selectionner le capital emprunté
           PERFORM SELECT-CAPITAL.
      *    Selectonner la durée du pret
           PERFORM SELECT-DUREE-PRET.

      *    Récuperer le taux d'interet 
           CALL 'EVALTAUX' USING TYPE-PRET
                                 DUREE-PRET-ANNEE
                                 WS-TAUX-INTERET 
                                 
           MOVE WS-TAUX-INTERET TO LS-TAUX-INTERET 
           DISPLAY '📈 Le taux annuel est de : ' LS-TAUX-INTERET ' %'

      *    Calculer la mensualité
           CALL 'CALCMENS' USING CAPITAL
                                 WS-TAUX-INTERET
                                 DUREE-PRET-ANNEE
                                 WS-MT-MENSUALITE    

           MOVE WS-MT-MENSUALITE TO LS-MT-MENSUALITE 
           DISPLAY "💰 La mensualité est de " LS-MT-MENSUALITE 
      
           GOBACK.

       SELECT-TYPE-PRET.
           DISPLAY "   Veuillez saisir le type de pret :"
           DISPLAY "      - A pour Pret AUTO 🚘"
           DISPLAY "      - C pour Pret CONSO 🛍️"
           DISPLAY "      - I pour Pret IMMO 🏠"
           PERFORM TEST AFTER
              UNTIL PRET-AUTO OR PRET-CONSO OR PRET-IMMO
                   ACCEPT TYPE-PRET
                   IF NOT PRET-AUTO AND NOT PRET-CONSO AND NOT PRET-IMMO
                      THEN 
                      DISPLAY "Saisie invalide ❌"
                   END-IF  
           END-PERFORM
           .
       SELECT-DUREE-PRET.
           DISPLAY "   Veuillez saisir la durée du pret (années) :"
           MOVE ZEROES TO DUREE-PRET-ANNEE 
           PERFORM TEST AFTER UNTIL DUREE-PRET-ANNEE NOT = 0
                   ACCEPT DUREE-PRET-ANNEE
                   IF DUREE-PRET-ANNEE = 0 THEN 
                      DISPLAY "Saisie invalide ❌"
                   END-IF  
           END-PERFORM
           .
       SELECT-CAPITAL.
           DISPLAY "   Veuillez saisir le montant emprunté :"
           DISPLAY "      (max 999 999.99)"
           MOVE ZEROES TO CAPITAL 
           PERFORM TEST AFTER UNTIL CAPITAL NOT = 0
                   ACCEPT CAPITAL 
                   IF CAPITAL = 0 THEN 
                      DISPLAY "Saisie invalide ❌"
                   END-IF 
           END-PERFORM
           .
      
       END PROGRAM SIMUPRET.
