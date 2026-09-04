      *> Jeu de Bataille Naval
      *>   Generer une grille de 100 cases


       IDENTIFICATION DIVISION. 
       PROGRAM-ID. NAVALBAT.
       
       ENVIRONMENT DIVISION. 
       INPUT-OUTPUT SECTION.    
       FILE-CONTROL.
           SELECT OPTIONAL GRILLE
           ASSIGN TO "grille.dat"
           ORGANIZATION IS INDEXED
           FILE STATUS IS LS-FS-GRILLE
           ACCESS IS DYNAMIC
           RECORD KEY IS GRILLE-KEY.

       DATA DIVISION. 
       FILE SECTION.
       FD GRILLE.
       01 GRILLAGE. 
          05 GRILLE-KEY.
             10 GRILLE-KEY-COL     PIC 9(2).  
             10 GRILLE-KEY-LIG     PIC 9(2).
          05 GRILLE-STATUS         PIC X(10).
       
       WORKING-STORAGE SECTION.
      *> Constantes
       77 CST-EAU                  PIC X(10) VALUE "EAU".
       77 CST-MANQUE               PIC X(10) VALUE "MANQUE".
       77 CST-TOUCHE               PIC X(10) VALUE "TOUCHE".
       77 CST-NB-ESSAI             PIC 9     VALUE 5.

       01 NAVIRE-COORD.
          05 COORDINATES OCCURS 5 TIMES ASCENDING KEY IS COORD-KEY
                INDEXED BY COORD-IDX.
             10 COORD-KEY          PIC 9(4).
             10 COORD-VALUES REDEFINES COORD-KEY.
                15 COL-COORD       PIC 9(2).
                15 LIG-COORD       PIC 9(2).
             
       LOCAL-STORAGE SECTION.
       01 LS-FS-GRILLE             PIC X(2).
       01 LS-FS-OPEN               PIC X(2).
       
       01 LS-NB-ESSAI              PIC 9.
       01 LS-NB-TOUCHE             PIC 9.
       01 LS-NB-MANQUE             PIC 9.
       01 LS-A-COL-COORD           PIC X.

       01 BATTLE-SHOT.
          05 BS-COL-COORD          PIC 99.
          05 BS-LIG-COORD          PIC 99.
     
       01 LS-GRILLAGE.
          05 LS-GRILLE-KEY.
             10 LS-GRILLE-KEY-COL  PIC 9(2).  
             10 LS-GRILLE-KEY-LIG  PIC 9(2).
          05 LS-GRILLE-STATUS      PIC X(10).
          
      *> Controle des variables d'entrées
       01 LS-LIG-OK                PIC X(2).
       01 LS-COL-OK                PIC X(2).

      *> Nombre de modifications identifiées dans check Grille
       01 LS-NB-MOD                PIC 9.    
       
       PROCEDURE DIVISION.
      *> Créer la grille de jeu
           PERFORM GENERERGRILLE. 
      *> Initialiser les navires
           PERFORM NAVIRE-INIT.
      *     DISPLAY NAVIRE-COORD

      *> Tirer et Verifier la cible 
           PERFORM SHOT-CHECK.
      *> Vérifier la grille de sortie
           PERFORM GRILLE-CHECK.

           GOBACK.
           
      *> Initialiser la grille de jeu
      *>*****************************
       GENERERGRILLE.
           OPEN I-O GRILLE
           MOVE LS-FS-GRILLE TO LS-FS-OPEN
           PERFORM VARYING LS-GRILLE-KEY-COL FROM 1 BY 1 UNTIL
              LS-GRILLE-KEY-COL = 11
                   PERFORM VARYING LS-GRILLE-KEY-LIG FROM 1 BY 1 UNTIL
                      LS-GRILLE-KEY-LIG = 11
                           MOVE CST-EAU TO LS-GRILLE-STATUS
      *> Verifier le statut de l'ouverture pour le choix du mode d'écri
      *> ture.                     
                           IF LS-FS-OPEN = "05"
                              WRITE GRILLAGE FROM LS-GRILLAGE 
                           ELSE 
                              REWRITE GRILLAGE FROM LS-GRILLAGE 
                           END-IF
      *                     DISPLAY GRILLAGE
                   END-PERFORM
           END-PERFORM
           CLOSE GRILLE
           . 
      *> Stocker les coordonnées des navires
      *>************************************
       NAVIRE-INIT.
           MOVE 0503 TO COORDINATES(1)
           MOVE 1009 TO COORDINATES(2)
           MOVE 0304 TO COORDINATES(3)
           MOVE 0806 TO COORDINATES(4)
           MOVE 0510 TO COORDINATES(5)
           .
           
      *> Vérifier la cible du tir
      *>*************************
       SHOT-CHECK.
      *> Ouverture en I-O pour lecture et ecriture 
           OPEN I-O GRILLE

           MOVE 0 TO LS-NB-ESSAI
           MOVE 0 TO LS-NB-TOUCHE
           MOVE 0 TO LS-NB-MANQUE

      *> Trie de la table des cibles pour fonctionner avec SEARCH ALL 
           SORT COORDINATES ASCENDING KEY COORD-KEY

           PERFORM VARYING LS-NB-ESSAI FROM 1 BY 1 UNTIL
              LS-NB-ESSAI > CST-NB-ESSAI
      *> Viser
                   MOVE 'KO' TO LS-COL-OK
                   PERFORM TEST AFTER UNTIL LS-COL-OK = 'OK'
                           DISPLAY "*> Quelle colonne viser ? (A à J)"
                           ACCEPT LS-A-COL-COORD
                           PERFORM CONVERT-COL-ALPHA
                           IF BS-COL-COORD <= 0 OR BS-COL-COORD > 10
                              DISPLAY "❌ erreur saisie " 
                              LS-A-COL-COORD
                           ELSE
                              MOVE 'OK' TO LS-COL-OK
                           END-IF
                   END-PERFORM

                   MOVE 'KO' TO LS-LIG-OK
                   PERFORM TEST AFTER UNTIL LS-LIG-OK = 'OK'
                           DISPLAY "*> Quelle ligne viser ? (1 à 10)"
                           ACCEPT BS-LIG-COORD
                           IF BS-LIG-COORD <= 0 OR BS-LIG-COORD > 10
                              DISPLAY "❌ erreur saisie " BS-LIG-COORD
                           ELSE
                              MOVE 'OK' TO LS-LIG-OK
                           END-IF
                   END-PERFORM
      
                   MOVE BATTLE-SHOT TO GRILLE-KEY
                   READ GRILLE INTO GRILLAGE KEY IS GRILLE-KEY
      
                   MOVE GRILLAGE TO LS-GRILLAGE       
      *> Si le statut de la grille est EAU,
      *>   verifier si la cible est un navire
      *>      si c'est un navire : marquer "TOUCHE" dans la grille
      *>      sinon marquer "MANQUE" dans la grille
      *> Sinon DISPLAY cible déjà visée
                   IF LS-GRILLE-STATUS = CST-EAU THEN
      *> rechercher si les coordonnées sont des cibles
                      SEARCH ALL COORDINATES
                      AT END
                         DISPLAY '💦 MANQUE : '
                                 LS-A-COL-COORD
                                 LS-GRILLE-KEY-LIG
                         MOVE CST-MANQUE TO LS-GRILLE-STATUS
                         ADD 1 TO LS-NB-MANQUE
      *> Mettre à jour la grille. 
                         REWRITE GRILLAGE FROM LS-GRILLAGE       
                      WHEN COORD-KEY(COORD-IDX) = LS-GRILLE-KEY
                           DISPLAY '💥 TOUCHE : '
                                   LS-A-COL-COORD
                                   LS-GRILLE-KEY-LIG
                           MOVE CST-TOUCHE TO LS-GRILLE-STATUS
                           ADD 1 TO LS-NB-TOUCHE
      *> Mettre à jour la grille. 
                           REWRITE GRILLAGE FROM LS-GRILLAGE
                      END-SEARCH
                   ELSE
                      DISPLAY "🔎 La cible a déjà été visée : "
                              LS-A-COL-COORD
                              LS-GRILLE-KEY-LIG
      *> Ne pas compter le tir
                      ADD -1 TO LS-NB-ESSAI
                   END-IF
      *> Fin de partie 
                   IF LS-NB-ESSAI = CST-NB-ESSAI THEN 
                      DISPLAY "La partie est terminée."
                      DISPLAY " 🎯 Vous avez touché "
                              LS-NB-TOUCHE
                              " cibles."                        
                      DISPLAY " ❌ Vous avez manqué "
                              LS-NB-MANQUE
                              " cibles."
                      IF LS-NB-TOUCHE = CST-NB-ESSAI THEN 
                         DISPLAY "🏆 Vous avez gagné!!! 🏆"
                      ELSE 
                         DISPLAY "🤩 Essayer à nouveau 🤩"
                      END-IF
                   END-IF
           END-PERFORM
      *> Fermer le fichier 
           CLOSE GRILLE.
      *> Vérifier la grille avant de quitter
       GRILLE-CHECK.
           MOVE 0 TO LS-NB-MOD
           OPEN INPUT GRILLE
           IF LS-FS-GRILLE IS NOT EQUAL TO '00'
              DISPLAY "Erreur OPEN INPUT GRILLE-CHECK"
           END-IF
           PERFORM VARYING LS-GRILLE-KEY-COL FROM 1 BY 1 UNTIL
              LS-GRILLE-KEY-COL > 10
                   PERFORM VARYING LS-GRILLE-KEY-LIG FROM 1 BY 1 UNTIL
                      LS-GRILLE-KEY-LIG > 10
                           MOVE LS-GRILLE-KEY TO GRILLE-KEY
                           READ GRILLE INTO GRILLAGE KEY IS GRILLE-KEY
                           NOT INVALID KEY
      *> Rechercher une modification de la grille           
                               IF GRILLE-STATUS IS NOT EQUAL TO CST-EAU
                                  ADD 1 TO LS-NB-MOD
                               END-IF
                           END-READ
                   END-PERFORM
           END-PERFORM
           
      *     DISPLAY "NB MOD : " LS-NB-MOD
      *     IF LS-NB-MOD = 5
      *        DISPLAY "CHECK-GRILLE OK ✅"
      *     ELSE
      *        DISPLAY "CHECK GRILLE KO ❌"
      *     END-IF
           CLOSE GRILLE. 
      
      *> Convertir l'entrée colonne Alpha en numérique pour la suite 
      *> des traitements.
       CONVERT-COL-ALPHA.
           MOVE FUNCTION UPPER-CASE(LS-A-COL-COORD) TO LS-A-COL-COORD
           EVALUATE TRUE
           WHEN LS-A-COL-COORD IS EQUAL TO "A"
                MOVE 1 TO BS-COL-COORD 
           WHEN LS-A-COL-COORD IS EQUAL TO "B"
                MOVE 2 TO BS-COL-COORD 
           WHEN LS-A-COL-COORD IS EQUAL TO "C"
                MOVE 3 TO BS-COL-COORD 
           WHEN LS-A-COL-COORD IS EQUAL TO "D"
                MOVE 4 TO BS-COL-COORD 
           WHEN LS-A-COL-COORD IS EQUAL TO "E"
                MOVE 5 TO BS-COL-COORD 
           WHEN LS-A-COL-COORD IS EQUAL TO "F"
                MOVE 6 TO BS-COL-COORD 
           WHEN LS-A-COL-COORD IS EQUAL TO "G"
                MOVE 7 TO BS-COL-COORD 
           WHEN LS-A-COL-COORD IS EQUAL TO "H"
                MOVE 8 TO BS-COL-COORD 
           WHEN LS-A-COL-COORD IS EQUAL TO "I"
                MOVE 9 TO BS-COL-COORD 
           WHEN LS-A-COL-COORD IS EQUAL TO "J"
                MOVE 10 TO BS-COL-COORD 
           WHEN OTHER
                MOVE 0 TO BS-COL-COORD     
           END-EVALUATE
           .           
           
       END PROGRAM NAVALBAT.
