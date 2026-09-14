      *>Calcul de la base imposable
       IDENTIFICATION DIVISION. 
       PROGRAM-ID. CALCBIMP.
       
       ENVIRONMENT DIVISION. 

       DATA DIVISION. 
       WORKING-STORAGE SECTION. 
       LOCAL-STORAGE SECTION. 
       LINKAGE SECTION. 
       01 LK-BASE-IMPOSABLE  PIC 9(5)V99.
       01 LK-SALAIRE-BRUT    PIC  9(5)V99.
       01 LK-COTISATION      PIC 9(5)V99.

       PROCEDURE DIVISION USING LK-SALAIRE-BRUT
                                LK-COTISATION
                                LK-BASE-IMPOSABLE.
                                
           COMPUTE LK-BASE-IMPOSABLE = LK-SALAIRE-BRUT - LK-COTISATION.      
           
           GOBACK.
       END PROGRAM CALCBIMP.
