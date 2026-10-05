       IDENTIFICATION DIVISION. 
       PROGRAM-ID. SIMUPRET.

       ENVIRONMENT DIVISION. 
       
       DATA DIVISION. 
       WORKING-STORAGE SECTION.
       01 WS-JSON-FILE-NAME  PIC X(50).
      *    Caractéristique du pret    
           COPY 'dempret'.
      *    Taux Interet
           COPY 'tauxinter' REPLACING TAUX-INTERET BY WS-TAUX-INTERET
                                         TAUX-ANNUEL BY WS-TAUX-ANNUEL 
                                       TAUX-MENSUEL BY WS-TAUX-MENSUEL.
      *    Tableau des échéances (amortissement)
           COPY 'echeance'.
                                                
       01 WS-MT-MENSUALITE   PIC 9(6)V99.
       LOCAL-STORAGE SECTION. 
       01 LS-NB-MENSUALITE   PIC 9(3).
       01 LS-TAUX-ANNUEL     PIC Z9.99.
       01 LS-TAUX-MENSUEL    PIC 9.9(7).
       01 LS-MT-MENSUALITE   PIC Z(5)9.99.
       PROCEDURE DIVISION.

           DISPLAY "Bienvenue dans le simulateur de pret."
           ACCEPT WS-JSON-FILE-NAME FROM COMMAND-LINE
      D     DISPLAY "   Paramètre reçu : " WS-JSON-FILE-NAME 
      
      *    Selectionner le type de pret
           PERFORM SELECT-TYPE-PRET.
      *    Selectionner le capital emprunté
           PERFORM SELECT-CAPITAL.
      *    Selectonner la durée du pret
           PERFORM SELECT-DUREE-PRET.

      *    Calculer le nombre de mensualités
           COMPUTE LS-NB-MENSUALITE = DUREE-PRET-ANNEE * 12
           
      *    Récuperer le taux d'interet 
           CALL 'EVALTAUX' USING TYPE-PRET
                                 DUREE-PRET-ANNEE
                                 WS-TAUX-INTERET 
                                 
           MOVE WS-TAUX-ANNUEL TO LS-TAUX-ANNUEL  
           DISPLAY '📈 Le taux annuel est de : ' LS-TAUX-ANNUEL ' %'
           MOVE WS-TAUX-MENSUEL TO LS-TAUX-MENSUEL  
           DISPLAY '📈 Le taux mensuel est de : ' LS-TAUX-MENSUEL ' %'

      *    Calculer la mensualité
           CALL 'CALCMENS' USING CAPITAL
                                 WS-TAUX-MENSUEL
                                 DUREE-PRET-ANNEE
                                 WS-MT-MENSUALITE    

           MOVE WS-MT-MENSUALITE TO LS-MT-MENSUALITE 
           DISPLAY "💰 La mensualité est de " LS-MT-MENSUALITE 
          
      *    Générer l'échéancier 
           MOVE LS-NB-MENSUALITE TO NB-ECHEANCES 
           CALL 'GENEECHE' USING CAPITAL
                                 WS-MT-MENSUALITE
                                 WS-TAUX-INTERET
                                 ECHEANCIER 
      *    Générer la sortie JSON
           CALL 'GENEJSON' USING DEMANDE-PRET
                                 WS-TAUX-INTERET
                                 WS-MT-MENSUALITE
                                 ECHEANCIER
                                 WS-JSON-FILE-NAME
      
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
              AND DUREE-PRET-ANNEE NOT > 25
                   ACCEPT DUREE-PRET-ANNEE
                   
                   IF DUREE-PRET-ANNEE = 0 THEN 
                      DISPLAY "Saisie invalide ❌"
                   END-IF
                   
                   IF DUREE-PRET-ANNEE > 25 THEN 
                      DISPLAY 
                      "La durée du prêt est limitée à 25 ans ❌"
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
