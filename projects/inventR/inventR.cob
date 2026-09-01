      *> inventR - programme de gestion d'inventaire
      *> author : CVSI - DG
      *> date : 30/08/2026
      *>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       IDENTIFICATION DIVISION. 
       PROGRAM-ID. INVENTR.
       AUTHOR. CVSI-DG
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION. 
       FILE-CONTROL.
      *> Fichier des produits
           SELECT PRODUITS
           ASSIGN TO "produits.dat"
           ORGANIZATION IS LINE SEQUENTIAL
      *>   Local Storage Produit File Status
           FILE STATUS IS LS-P-FS.
      
      *> Fichier des commandes 
           SELECT COMMANDES
           ASSIGN TO "commandes.dat"
           ORGANIZATION IS LINE SEQUENTIAL
      *>   Local Storage Commande File Status     
           FILE STATUS IS LS-C-FS.

      *> Fichier de sortie : Rapport-inventaire.txt
           SELECT RAPPORT 
           ASSIGN TO "rapport-inventaire.txt"
           ORGANIZATION IS LINE SEQUENTIAL
           FILE STATUS IS LS-RI-FS.
             

       DATA DIVISION. 
       FILE SECTION.
       FD PRODUITS.
       01 PRODUIT.
          05 PCODE            PIC X(6).
          05 LIBELLE          PIC X(20).
          05 STOCK            PIC 9(5).
          05 PRIX             PIC 9(5)V9(2).
           
       FD  COMMANDES.
       01 COMMANDE. 
          05 CCODE            PIC X(6).
          05 QUANTITE         PIC 9(5).

       FD  RAPPORT.
       01 RAPPORT-RECORDS. 
          05 RAPPORT-RECORD   PIC X(100).
       
       WORKING-STORAGE SECTION.

       LOCAL-STORAGE SECTION.
       01 LS-P-FS             PIC X(2).
       01 LS-C-FS             PIC X(2).
       01 LS-RI-FS            PIC X(2).
       01 LS-TRAITE           PIC A(1).

      *> Liste des produits
       01 PRODUITS-TABLE.
          05 LS-PRODUIT OCCURS 999 TIMES
                DEPENDING ON LS-NB-PRODUITS
                INDEXED BY I-PRODUIT.
             10 LS-PCODE      PIC X(6).
             10 LS-LIBELLE    PIC X(20).  
             10 LS-STOCK      PIC 9(5).
             10 LS-PRIX       PIC 9(5)V99.
       01 LS-NB-PRODUITS      PIC 9(3).

      *> Liste des commandes 
       01 COMMANDES-TABLE.
          05 LS-COMMANDE OCCURS 999 TIMES
                DEPENDING ON LS-NB-COMMANDES
                INDEXED BY I-COMMANDE.
             10 LS-CCODE      PIC X(6).
             10 LS-QUANTITE   PIC 9(5).
       01 LS-NB-COMMANDES     PIC 9(3).

      *> Variables pour l'écriture du rapport 
       01 RAPPORT-DATA.
          05 LS-RSTATUS       PIC X(9).
          05 LS-RCODE         PIC X(6).
          05 LS-RLIBELLE      PIC X(20).
          05 LS-RSTOCK-FINAL  PIC 9(5).
            
        PROCEDURE DIVISION.
      *> Chargement des produits 
           PERFORM CHARGER-LES-PRODUITS.
           PERFORM CHARGER-LES-COMMANDES.
      
      *> Ouvrir le fichier rapport en écriture
           OPEN OUTPUT RAPPORT
      *> Traitement des commandes
           PERFORM VARYING I-COMMANDE FROM 1 BY 1 UNTIL I-COMMANDE >
              LS-NB-COMMANDES
      *> Chercher le produit
                   MOVE 'N' TO LS-TRAITE
                   PERFORM VARYING I-PRODUIT FROM 1 BY 1 UNTIL I-PRODUIT
                      > LS-NB-PRODUITS OR LS-TRAITE = 'O'
                           IF LS-CCODE(I-COMMANDE) = LS-PCODE
                              (I-PRODUIT) THEN
                              MOVE 'O' TO LS-TRAITE
      *> Verifier les quantités et valoriser le rapport
                              IF LS-QUANTITE(I-COMMANDE) <= LS-STOCK
                                 (I-PRODUIT) THEN
                                 PERFORM ACCEPTER-COMMANDE    
                                 DISPLAY "Commande Acceptée"
                                 WRITE RAPPORT-RECORDS FROM
                                    RAPPORT-DATA          
                              ELSE
                                 PERFORM REFUSER-COMMANDE
                                 DISPLAY "Commande Refusée"
                                 WRITE RAPPORT-RECORDS FROM
                                    RAPPORT-DATA
                              END-IF               
                           END-IF
                   END-PERFORM  
                   IF LS-TRAITE = "N"
                      PERFORM PRODUIT-NON-TROUVE
                      DISPLAY "Produit Non Trouvé"
                      WRITE RAPPORT-RECORDS FROM RAPPORT-DATA
                   END-IF
           END-PERFORM
      *> Fermer le rapport en sortie     
           CLOSE RAPPORT

           GOBACK.
      *>----------------------------------------------------------------
      *>----------------------------------------------------------------
      *> Lecture du fichier produits
       CHARGER-LES-PRODUITS.
           INITIALIZE LS-NB-PRODUITS
           OPEN INPUT PRODUITS
           IF LS-P-FS IS NOT EQUAL TO "35" THEN
              PERFORM VARYING I-PRODUIT FROM 1 BY 1 UNTIL LS-P-FS = "10"
                      READ PRODUITS
                      AT END
                         DISPLAY LS-NB-PRODUITS " produits chargés."
                      NOT AT END
                          ADD 1 TO LS-NB-PRODUITS
                          MOVE PRODUIT IN PRODUITS TO
                             LS-PRODUIT(I-PRODUIT) 
              END-PERFORM
              CLOSE PRODUITS
           ELSE
              DISPLAY "Fichier de produit absent"
              GOBACK
           END-IF.

      *> Lecture du fichier commandes
       CHARGER-LES-COMMANDES.
           INITIALIZE LS-NB-COMMANDES
           OPEN INPUT COMMANDES
           IF LS-C-FS IS NOT EQUAL TO "35" THEN 
              PERFORM VARYING I-COMMANDE FROM 1 BY 1 UNTIL LS-C-FS =
                 "10"
                      READ COMMANDES
                      AT END
                         DISPLAY LS-NB-COMMANDES " commandes chargées."
                      NOT AT END
                          ADD 1 TO LS-NB-COMMANDES
                          MOVE COMMANDE IN COMMANDES TO
                             LS-COMMANDE(I-COMMANDE)  
              END-PERFORM
              CLOSE COMMANDES
           ELSE
              DISPLAY "Fichier de commandes absent"
              GOBACK
           END-IF.   
      

      *> Accepter Commande
       ACCEPTER-COMMANDE.
           INITIALIZE RAPPORT-DATA
           MOVE "ACCEPTEE" TO LS-RSTATUS
           MOVE LS-CCODE(I-COMMANDE) TO LS-RCODE
           MOVE LS-LIBELLE(I-PRODUIT) TO LS-RLIBELLE
           COMPUTE LS-RSTOCK-FINAL = LS-STOCK(I-PRODUIT) -
              LS-QUANTITE(I-COMMANDE).

      *> Refuser Commande
       REFUSER-COMMANDE.
           INITIALIZE RAPPORT-DATA
           MOVE "REFUSEE" TO LS-RSTATUS
           MOVE LS-CCODE(I-COMMANDE) TO LS-RCODE
           MOVE LS-LIBELLE(I-PRODUIT) TO LS-RLIBELLE
           MOVE LS-STOCK(I-PRODUIT) TO LS-RSTOCK-FINAL.
      
      *> Produit non trouvé
       PRODUIT-NON-TROUVE.
           INITIALIZE RAPPORT-DATA
           MOVE "REFUSEE" TO LS-RSTATUS
           MOVE LS-CCODE(I-COMMANDE) TO LS-RCODE
           MOVE "Produit Non trouve" TO LS-RLIBELLE
           MOVE 0 TO LS-RSTOCK-FINAL.
           
       END PROGRAM INVENTR.
