       IDENTIFICATION DIVISION. 
       PROGRAM-ID. INDEXEDF.

       ENVIRONMENT DIVISION. 
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT OPTIONAL PRODUCTS ASSIGN TO "products.dat"
           ORGANIZATION IS INDEXED
           RECORD KEY IS PRODUCT-CODE
      *> permet de lire en séquentiel comme en keyed.     
           ACCESS MODE IS DYNAMIC
           FILE STATUS IS LS-FS-PRODUCTS.


       DATA DIVISION. 
       FILE SECTION. 
      *> File Description 
       FD PRODUCTS.
       01 PRODUCTS-DATAS.
          05 PRODUCT-CODE            PIC X(4).
          05 PRODUCT-DESIGNATION     PIC X(10).
          05 PRODUCT-STOCK           PIC 9(3).

       WORKING-STORAGE SECTION.
       
       LOCAL-STORAGE SECTION.
       01 LS-FS-PRODUCTS             PIC X(2).
          88 FS-OK                             VALUE "00".
          88 FS-FILE-CREATED                   VALUE "05".
          88 FS-END-OF-FILE                    VALUE "10".
       01 LS-FEED                    PIC 9(2).
       01 LS-PRODUCT-DATA.
          05 LS-PRODUCT-CODE         PIC X(4)  VALUE "POXX".
          05 LS-PRODUCT-DESIGNATION  PIC X(10).
          05 LS-PRODUCT-STOCK        PIC 9(3). 
       01 LS-FINDPRODUCT             PIC 9(2).
       01 LS-FOUNDPRODUCT            PIC X.
          88 FOUNDPRODUCT                      VALUE "O" FALSE "N".
       01 LS-MODSTOCKVALUE           PIC 9(3).

       
       PROCEDURE DIVISION.
      *>   Création du fichier PRODUCTS
           PERFORM PRODUCTS-STATIC-INIT
      *>   Rechercher un produit 
           PERFORM PRODUCT-FIND 
      *>   Modifier le stock d'un produit 
           PERFORM PRODUCT-MOD
      *>   Suppression d'un produit
           PERFORM PRODUCT-DEL
      *>   Relecture Finale 
           PERFORM READ-AND-DISPLAY

           GOBACK.
           
      *> Initialisation statique du fichier produits
       PRODUCTS-STATIC-INIT.
           OPEN I-O PRODUCTS
           DISPLAY "OPEN I-O PRODUCTS FS : " LS-FS-PRODUCTS
           IF NOT (FS-OK OR FS-FILE-CREATED) THEN 
              DISPLAY "Problème ouverture du fichier PRODUCTS"
           ELSE
              IF FS-FILE-CREATED THEN 
      *>         Le fichier n'existait pas, a été créé, puis ouvert     
                 DISPLAY "DOESNT EXISTS, CREATES AND OPENS"
              ELSE
      *>         Le fichier existait et a bien été ouvert     
                 DISPLAY "EXISTS AND OPENS"
              END-IF
              PERFORM PRODUCTS-FEED
           END-IF

           CLOSE PRODUCTS
           .

      *> Alimentation du fichier produits
       PRODUCTS-FEED.
           PERFORM TEST AFTER VARYING LS-FEED FROM 1 BY 1
              UNTIL LS-FEED = 4
                   DISPLAY " -------  "        

      *>         Générer le code produit
                   STRING "PO" LS-FEED DELIMITED BY SIZE INTO
                      LS-PRODUCT-CODE   
                   END-STRING
                   DISPLAY "Code Produit : " LS-PRODUCT-CODE
      *>         Générer la désignation 
                   STRING "Produit " LS-FEED DELIMITED BY SIZE INTO
                      LS-PRODUCT-DESIGNATION
                   END-STRING
                   DISPLAY "Désignation Produit : "
                           LS-PRODUCT-DESIGNATION
      *>         Générer le stock         
                   COMPUTE LS-PRODUCT-STOCK = LS-FEED * 100 + LS-FEED
                   DISPLAY "Stock Produit : " LS-PRODUCT-STOCK

      *>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>      
      *>   Application du pattern UPSERT : 
      *>      - Lecture avant TOUT REWRITE 
      *>         Si clé invalide WRITE
      *>         Sinon REWRITE     
      *>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>      
      *>         Enregistrer le produit 
                   MOVE LS-PRODUCT-CODE TO PRODUCT-CODE
      
      *>           Lecture à blanc pour positionner la clé
                   READ PRODUCTS KEY IS PRODUCT-CODE
                   INVALID KEY 
                           DISPLAY "1READ INVALID KEY  FS : "
                                   LS-FS-PRODUCTS
      *>           la clé n'est pas valide, on passe en WRITE
                           WRITE PRODUCTS-DATAS FROM LS-PRODUCT-DATA 
                           INVALID KEY
                                   DISPLAY
                                      "1READ->WRITE INVALID KEY : "
                                      PRODUCT-CODE
                           NOT INVALID KEY 
                               DISPLAY "1READ->WRITE OK : "
                                       LS-FS-PRODUCTS
                           END-WRITE
                   NOT INVALID KEY
                       DISPLAY "1READ NOT INVALID KEY FS : "
                               LS-FS-PRODUCTS
      *>               Pousser les données 
                       MOVE LS-PRODUCT-DATA TO PRODUCTS-DATAS
                       REWRITE PRODUCTS-DATAS
                       INVALID KEY
                               DISPLAY "1READ->REWRITE INVALID KEY : "
                                       LS-FS-PRODUCTS
                       NOT INVALID KEY 
                           DISPLAY "1READ->REWRITE OK : "
                                   LS-FS-PRODUCTS
                       END-REWRITE
                   END-READ
                   DISPLAY " -------  "        
      *>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>      
           END-PERFORM
           .

      *> Saisie d'un numéro de produit 1 à 4, reconstitution de clé
      *> lecture indexée puis affichage du produit si trouvé     
       PRODUCT-FIND.
           DISPLAY "Saisir le numéro de produit recherché : "
           ACCEPT LS-FINDPRODUCT
           PERFORM PRODNUM-TO-PRODCODE

           DISPLAY LS-PRODUCT-CODE
           OPEN I-O PRODUCTS
          
           MOVE LS-PRODUCT-CODE TO PRODUCT-CODE
           READ PRODUCTS INTO LS-PRODUCT-DATA KEY IS PRODUCT-CODE
           INVALID KEY
                   DISPLAY "READ INVALID KEY : " LS-PRODUCT-CODE
                   DISPLAY "READ FS STATUS : " LS-FS-PRODUCTS
           NOT INVALID KEY
               DISPLAY "READ VALID KEY : " LS-PRODUCT-CODE
               DISPLAY "READ FS STATUS : " LS-FS-PRODUCTS
               
               DISPLAY "-------------------------------------------"
               DISPLAY "- PRODUIT TROUVE : "
                       LS-PRODUCT-CODE
                       " - "
                       LS-PRODUCT-DESIGNATION
                       " - "
                       LS-PRODUCT-STOCK 
               DISPLAY "-------------------------------------------"
           END-READ
           CLOSE PRODUCTS
           .

      *> Demander le numéro de produit 1 à 4, reconstitution de clé 
      *> Demander la quantité
      *> Modifier la quantité
       PRODUCT-MOD.
           
           SET FOUNDPRODUCT TO FALSE
           OPEN I-O PRODUCTS
           IF FS-OK THEN 

              PERFORM TEST AFTER UNTIL FOUNDPRODUCT
                      DISPLAY "Saisir le numéro du produit à modifier"
                      ACCEPT LS-FINDPRODUCT
                      PERFORM PRODNUM-TO-PRODCODE

      *>      Relire le produit 
                      MOVE LS-PRODUCT-CODE TO PRODUCT-CODE
                      READ PRODUCTS INTO LS-PRODUCT-DATA KEY IS
                         PRODUCT-CODE
                      INVALID KEY
                              DISPLAY "  Le produit "
                                      LS-FINDPRODUCT
                                      " n'existe pas."
                      NOT INVALID KEY
                          SET FOUNDPRODUCT TO TRUE
                          DISPLAY "   Produit "
                                  LS-FINDPRODUCT
                                  " -> Stock actuel : "
                                  LS-PRODUCT-STOCK
                      END-READ
              END-PERFORM

      *    Saisir le nouveau stock     
              DISPLAY "Saisir le nouveau stock (max 999)"
              ACCEPT LS-MODSTOCKVALUE
           
              MOVE LS-MODSTOCKVALUE TO LS-PRODUCT-STOCK
              MOVE LS-PRODUCT-DATA TO PRODUCTS-DATAS
      
              REWRITE PRODUCTS-DATAS
              INVALID KEY 
                      DISPLAY "   Le stock n'a pas pu être mis à jour"
                      DISPLAY "      FS : " LS-FS-PRODUCTS
              NOT INVALID KEY 
                  DISPLAY "   Le stock a été mis à jour"
                  DISPLAY "      FS : " LS-FS-PRODUCTS

              END-REWRITE 
           END-IF
           CLOSE PRODUCTS
           .

      *>Suppression d'un produit 
       PRODUCT-DEL. 
       
           SET FOUNDPRODUCT TO FALSE

           OPEN I-O PRODUCTS
    
           PERFORM TEST AFTER UNTIL FOUNDPRODUCT
                   DISPLAY "Saisir le numéro du produit à supprimer"
                   ACCEPT LS-FINDPRODUCT
                   PERFORM PRODNUM-TO-PRODCODE
           
      *>   Lecture du produit 
                   MOVE LS-PRODUCT-CODE TO PRODUCT-CODE
                   READ PRODUCTS INTO LS-PRODUCT-DATA KEY IS
                      PRODUCT-CODE
                   INVALID KEY    
                           DISPLAY " R B S : produit introuvable ("
                                   PRODUCT-CODE
                                   ")"
                           DISPLAY "     FS : " LS-FS-PRODUCTS
                   NOT INVALID KEY 
                       SET FOUNDPRODUCT TO TRUE
                       DISPLAY "   Le produit "
                               PRODUCT-CODE
                               " va être supprimé"
                   END-READ
           END-PERFORM

      *>   Suppression du produit 
           DELETE PRODUCTS
           INVALID KEY 
                   DISPLAY
                      "   La suppression a échoué"
                   DISPLAY
                      "      FS : " LS-FS-PRODUCTS
           NOT INVALID KEY
               DISPLAY
                  "   La suppression a été réalisée"
               READ PRODUCTS INTO LS-PRODUCT-DATA KEY IS PRODUCT-CODE
               INVALID KEY 
                       DISPLAY
                          "      Suppression confirmée par relecture"
                       DISPLAY
                          "        FS " LS-FS-PRODUCTS
               NOT INVALID KEY 
                   DISPLAY "      Erreur suppression "
               END-READ
           END-DELETE
           CLOSE PRODUCTS
           .    
      
      *> Conversion numero vers produit code
       PRODNUM-TO-PRODCODE.
           STRING "PO" LS-FINDPRODUCT DELIMITED BY SIZE INTO
              LS-PRODUCT-CODE
           END-STRING
           .

      *> Relecture sequentiel pour affiche
       READ-AND-DISPLAY.
           OPEN INPUT PRODUCTS
           PERFORM UNTIL FS-END-OF-FILE
                   READ PRODUCTS NEXT RECORD INTO LS-PRODUCT-DATA
                   NOT AT END 
                       DISPLAY
                          "-------------------------------------------"
                       DISPLAY "- PRODUIT TROUVE : "
                               LS-PRODUCT-CODE
                               " - "
                               LS-PRODUCT-DESIGNATION
                               " - "
                               LS-PRODUCT-STOCK 
                       DISPLAY
                          "-------------------------------------------"
                   END-READ
           END-PERFORM
           CLOSE PRODUCTS
           .
      
       END PROGRAM INDEXEDF.
