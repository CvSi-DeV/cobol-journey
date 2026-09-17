       IDENTIFICATION DIVISION. 
       PROGRAM-ID. CALCMENS.

       ENVIRONMENT DIVISION. 

       DATA DIVISION. 
       LOCAL-STORAGE SECTION. 
       01 LS-NB-MENSUALITE        PIC 9(4).
       01 LS-FACTEUR-CROISSANCE   PIC 9V9(7).
       01 LS-FACT-CROI-DUREE      PIC 9V9(11).
       01 LS-ANNUITE              PIC 9V9(11).
       01 LS-FACT-AMORT           PIC 9(5)V9(10).

       LINKAGE SECTION. 
       01 LK-CAPITAL              PIC 9(6)V99.
       01 LK-DUREE-EMPRUNT-ANNEE  PIC 99.
       01 LK-MT-MENSUALITE        PIC 9(6)V99.
       01 LK-TAUX-MENSUEL         PIC 9V9(7).
         
       PROCEDURE DIVISION USING LK-CAPITAL
                                LK-TAUX-MENSUEL
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
      *     DISPLAY 'nb. mensualite : ' LS-NB-MENSUALITE 

      *    Calcul du facteur de croissance
           COMPUTE LS-FACTEUR-CROISSANCE = 1 + LK-TAUX-MENSUEL  
      *     DISPLAY 'FC : ' LS-FACTEUR-CROISSANCE 

      *    Calcul du facteur de croissance ramenée à la durée
           COMPUTE LS-FACT-CROI-DUREE ROUNDED =
              1 /(LS-FACTEUR-CROISSANCE ** LS-NB-MENSUALITE)
      *     DISPLAY 'FCd : ' LS-FACT-CROI-DUREE 
                   
      *    Calcul de l'annuité
           COMPUTE LS-ANNUITE = 1 - LS-FACT-CROI-DUREE 
      *     DISPLAY 'annuite : ' LS-ANNUITE 

      *    Calcul du facteur amortissement 
           COMPUTE LS-FACT-AMORT ROUNDED = LK-TAUX-MENSUEL / LS-ANNUITE 
      *     DISPLAY 'fact amort : ' LS-FACT-AMORT 

      *    Calul de la mensualité
           COMPUTE LK-MT-MENSUALITE ROUNDED = LK-CAPITAL * LS-FACT-AMORT 
      *     DISPLAY 'mensua : ' LK-MT-MENSUALITE 
           GOBACK.
       END PROGRAM CALCMENS.
