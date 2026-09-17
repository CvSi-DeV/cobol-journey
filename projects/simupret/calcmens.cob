       IDENTIFICATION DIVISION. 
       PROGRAM-ID. CALCMENS.

       ENVIRONMENT DIVISION. 

       DATA DIVISION. 
       LOCAL-STORAGE SECTION. 
       01 LS-TAUX-INTER-M         PIC 9V9(5).
       01 LS-TAUX-INTER-M-DISP    PIC 9.9(5).
       01 LS-NB-MENSUALITE        PIC 9(4).
       01 LS-FACTEUR-CROISSANCE   PIC 9V9(5).
       01 LS-FACT-CROI-DUREE      PIC 9V9(10).
       01 LS-ANNUITE              PIC 9V9(10).
       01 LS-FACT-AMORT           PIC 9(5)V9(10).

       LINKAGE SECTION. 
       01 LK-CAPITAL              PIC 9(6)V99.
       01 LK-TAUX-INTERET         PIC 9(2)V99.
       01 LK-DUREE-EMPRUNT-ANNEE  PIC 99.
       01 LK-MT-MENSUALITE        PIC 9(6)V99.

       PROCEDURE DIVISION USING LK-CAPITAL
                                LK-TAUX-INTERET
                                LK-DUREE-EMPRUNT-ANNEE
                                LK-MT-MENSUALITE.
      *-------------------------------------------
      * FORMULE 
      *    La mensualité d'un prêt à taux fixe et annuités constantes 
      *    M = C × (t / (1 - (1 + t)^-n))
      *       où :
      *          M = mensualité
      *          C = capital emprunté
      *          t = taux d'intérêt mensuel (taux annuel / 12)
      *          n = nombre de mensualités (durée en années × 12)
      *-------------------------------------------
      *    Calcul du nombre de mensualités
           COMPUTE LS-NB-MENSUALITE = LK-DUREE-EMPRUNT-ANNEE * 12
      
      *    Calcul du taux interet mensuel
           COMPUTE LS-TAUX-INTER-M = LK-TAUX-INTERET / 100 / 12
           MOVE LS-TAUX-INTER-M TO LS-TAUX-INTER-M-DISP 
           DISPLAY '📈 Le taux mensuel est de : ' LS-TAUX-INTER-M-DISP 
      
      *    Calcul du facteur de croissance
           COMPUTE LS-FACTEUR-CROISSANCE = 1 + LS-TAUX-INTER-M 
        
      *    Calcul du facteur de croissance ramenée à la durée
           COMPUTE LS-FACT-CROI-DUREE =
              1 /(LS-FACTEUR-CROISSANCE ** LS-NB-MENSUALITE)
                   
      *    Calcul de l'annuité
           COMPUTE LS-ANNUITE = 1 - LS-FACT-CROI-DUREE 
           
      *    Calcul du facteur amortissement 
           COMPUTE LS-FACT-AMORT = LS-TAUX-INTER-M / LS-ANNUITE 
          
      *    Calul de la mensualité
           COMPUTE LK-MT-MENSUALITE ROUNDED = LK-CAPITAL * LS-FACT-AMORT 

           GOBACK.
       END PROGRAM CALCMENS.
