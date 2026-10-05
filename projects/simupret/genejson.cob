       IDENTIFICATION DIVISION. 
       PROGRAM-ID. GENEJSON.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL. 
           SELECT OPTIONAL PRET-JSON 
           ASSIGN USING LK-JSON-FILE-NAME
      *    LINE SEQUENTIAL s'ajuste directement à la taille du contenu
      *    pas d'allocation de tout le buffer dans le fichier     
           ORGANIZATION IS LINE SEQUENTIAL
           FILE STATUS IS LS-FS-PRET-JSON.
       
       DATA DIVISION. 
       FILE SECTION. 
       FD PRET-JSON.
       01 FILE-PRET-JSON.
          05 JSON-DATA                PIC X(41000).

       WORKING-STORAGE SECTION. 
       01 WS-JSON-DEM-PRET            PIC X(76)      VALUE SPACES.
       01 WS-JSON-TAUX-INTER          PIC X(65)      VALUE SPACES.
       01 WS-JSON-MENSUALITE          PIC X(28)      VALUE SPACES.
       01 WS-PRET-DATA.
           COPY 'dempret' REPLACING ==05== BY ==10==
                                    ==01== BY ==05==.
           COPY 'tauxinter' REPLACING ==05== BY ==10==
                                      ==01== BY ==05==.                                     

       LOCAL-STORAGE SECTION. 
      *compteur fourre-tout 
       01 LS-JSON-COUNT               PIC 9(5)       VALUE ZERO.
      
       01 LS-JSON-KEY                 PIC X(50)      VALUE SPACES.
       01 LS-JSON-VALUES              PIC X(1000)    VALUE SPACES.
       01 LS-JSON-ECHEANCIER-DATA     PIC X(40500)   VALUE SPACES.
       01 LS-JSON-VALUE-DISP          PIC -(6)9.9(7).
       01 LS-JSON-NUMBER-PARSER-CNT   PIC 99         VALUE 15.
       01 LS-JSON-NUMBER-PARSER-STOP  PIC X.
       01 LS-JSON-FINAL               PIC X(41000)   VALUE SPACES.

       01 LS-FS-PRET-JSON             PIC X(2).

       LINKAGE SECTION. 
           COPY 'dempret' REPLACING  DEMANDE-PRET BY LK-DEMANDE-PRET.
           COPY 'tauxinter' REPLACING TAUX-INTERET BY LK-TAUX-INTERET.
           COPY 'echeance' REPLACING ECHEANCIER BY LK-ECHEANCIER.
       01 LK-MT-MENSUALITE            PIC 9(6)V99.
       01 LK-JSON-FILE-NAME           PIC X(50).

       PROCEDURE DIVISION USING LK-DEMANDE-PRET
                                LK-TAUX-INTERET
                                LK-MT-MENSUALITE
                                LK-ECHEANCIER
                                LK-JSON-FILE-NAME.
      *    JSON : Caractéristique du pret
           JSON GENERATE WS-JSON-DEM-PRET FROM LK-DEMANDE-PRET
              COUNT IN LS-JSON-COUNT
              NAME LK-DEMANDE-PRET 'DEMANDE-PRET' 
           ON EXCEPTION 
              DISPLAY "ERREUR ERREUR JSON GENERATE 1"
           NOT ON EXCEPTION 
               DISPLAY 'TOUT EST OK 1'
           END-JSON 

      *    JSON : Taux d'intérêt du pret
           JSON GENERATE WS-JSON-TAUX-INTER FROM LK-TAUX-INTERET
              COUNT IN LS-JSON-COUNT
              NAME LK-TAUX-INTERET 'TAUX-INTERET'
           ON EXCEPTION 
              DISPLAY "ERREUR ERREUR JSON GENERATE 2"
           NOT ON EXCEPTION
               DISPLAY 'TOUT EST OK 2'
           END-JSON 

      *    JSON : Montant mensualité
           JSON GENERATE WS-JSON-MENSUALITE FROM LK-MT-MENSUALITE
              COUNT IN LS-JSON-COUNT
              NAME LK-MT-MENSUALITE 'MENSUALITE'  
           END-JSON 

      *    JSON : Echéancier
      *       // GNU-COBOL ne gere pas le occurs dans JSON GENERATE
      *       // obligé de créer le json manuellement
           PERFORM ECHEANCE-TO-JSON 
           MOVE FUNCTION LENGTH(
              FUNCTION TRIM(LS-JSON-ECHEANCIER-DATA)) TO LS-JSON-COUNT   

      *    JSON : Réunir toutes les informations JSON
           PERFORM FINALISE-JSON 

      *    JSON : exporter sous forme de fichier
           PERFORM EXPORT-JSON 
           GOBACK.

       ECHEANCE-TO-JSON.
      *    Génération du l'échéancier au format JSON
           MOVE '{"ECHEANCIER":' TO LS-JSON-ECHEANCIER-DATA 
      *    Nb échéances 
           MOVE '{"NB-ECHEANCES":' TO LS-JSON-KEY 
           MOVE NB-ECHEANCES IN LK-ECHEANCIER TO LS-JSON-VALUE-DISP 
           MOVE LS-JSON-VALUE-DISP TO LS-JSON-VALUES
           PERFORM NUMBER-PARSER
           
           IF NB-ECHEANCES IN LK-ECHEANCIER = 0 THEN 
              PERFORM SET-JSON-VALUE 
           ELSE 
              STRING
                 FUNCTION TRIM(LS-JSON-ECHEANCIER-DATA) DELIMITED BY
                 SIZE
                 FUNCTION TRIM(LS-JSON-KEY) DELIMITED BY SIZE
                 FUNCTION TRIM(LS-JSON-VALUES) DELIMITED BY SIZE
                 ',"ECHEANCES":[' DELIMITED BY SIZE
                 INTO LS-JSON-ECHEANCIER-DATA 
              END-STRING
      *    Valorisation tableau d'échéances
              PERFORM TEST AFTER VARYING ECHEANCEID FROM 1 BY 1
                 UNTIL ECHEANCEID = NB-ECHEANCES 

      *               Numero échéance 
                      MOVE '{"NUM-ECHEANCE":' TO LS-JSON-KEY  
                      MOVE NUM-ECHEANCE(ECHEANCEID)
                         TO LS-JSON-VALUE-DISP 
                      MOVE LS-JSON-VALUE-DISP TO LS-JSON-VALUES
                      PERFORM NUMBER-PARSER  
                      PERFORM SET-JSON-VALUE 

      *               Capital précédent
                      MOVE ',"CAPITAL-PREC":' TO LS-JSON-KEY 
                      MOVE CAPITAL-PREC(ECHEANCEID)
                         TO LS-JSON-VALUE-DISP 
                      MOVE LS-JSON-VALUE-DISP TO LS-JSON-VALUES  
                      PERFORM NUMBER-PARSER
                      PERFORM SET-JSON-VALUE 

      *               Intérêt échéance 
                      MOVE ',"INTERET-ECHEANCE":' TO LS-JSON-KEY 
                      MOVE INTERET-ECHEANCE(ECHEANCEID)
                         TO LS-JSON-VALUE-DISP 
                      MOVE LS-JSON-VALUE-DISP TO LS-JSON-VALUES  
                      PERFORM NUMBER-PARSER
                      PERFORM SET-JSON-VALUE 

      *               Capital remboursé
                      MOVE ',"CAPITAL-REMBOURSE":' TO LS-JSON-KEY 
                      MOVE CAPITAL-REMBOURSE(ECHEANCEID)
                         TO LS-JSON-VALUE-DISP 
                      MOVE LS-JSON-VALUE-DISP TO LS-JSON-VALUES  
                      PERFORM NUMBER-PARSER
                      PERFORM SET-JSON-VALUE   

      *               Capital restant 
                      MOVE ',"CAPITAL-RESTANT":' TO LS-JSON-KEY 
                      MOVE CAPITAL-RESTANT(ECHEANCEID)
                         TO LS-JSON-VALUE-DISP 
                      MOVE LS-JSON-VALUE-DISP TO LS-JSON-VALUES
                      
                      PERFORM NUMBER-PARSER 
                              
      *    /!\ STRING GARBAGE TAIL : ce move permet de cadrer à gauche 
      *    et d'ajouter des spaces à droite pour le string suivant /!\
                      MOVE FUNCTION TRIM(LS-JSON-VALUES) TO
                         LS-JSON-VALUES   
                     
                      IF ECHEANCEID = NB-ECHEANCES THEN 
                         STRING
                            FUNCTION TRIM(LS-JSON-VALUES) DELIMITED BY
                            SIZE
                            '}' DELIMITED BY SIZE
                            INTO LS-JSON-VALUES
                         END-STRING
                      ELSE 
                         STRING
                            FUNCTION TRIM(LS-JSON-VALUES) DELIMITED BY
                            SIZE
                            '},' DELIMITED BY SIZE
                            INTO LS-JSON-VALUES 
                         END-STRING
                      END-IF 
                      
                      PERFORM SET-JSON-VALUE 
              END-PERFORM

      *    Fermeture tableau 
              STRING
                 FUNCTION TRIM(LS-JSON-ECHEANCIER-DATA)
                 DELIMITED BY SIZE
                 ']' DELIMITED BY SIZE
                 INTO LS-JSON-ECHEANCIER-DATA 
              END-STRING
           END-IF 
         
      *    Fin Nb échéances.  
           STRING
              FUNCTION TRIM(LS-JSON-ECHEANCIER-DATA) DELIMITED BY SIZE
              '}' DELIMITED BY SIZE
              INTO LS-JSON-ECHEANCIER-DATA 
           END-STRING

      *    Fin Echéancier
           STRING
              FUNCTION TRIM(LS-JSON-ECHEANCIER-DATA) DELIMITED BY SIZE
              '}' DELIMITED BY SIZE
              INTO LS-JSON-ECHEANCIER-DATA 
           END-STRING
           .
           
       SET-JSON-VALUE.
      *    Crée la clé valeur - evite le code dupliqué.
           STRING
              FUNCTION TRIM(LS-JSON-ECHEANCIER-DATA) DELIMITED BY
              SIZE
              FUNCTION TRIM(LS-JSON-KEY) DELIMITED BY SIZE
              FUNCTION trim(LS-JSON-VALUES) DELIMITED BY SIZE
              INTO LS-JSON-ECHEANCIER-DATA 
           END-STRING 

           MOVE SPACES TO LS-JSON-VALUES 
           .
           
       NUMBER-PARSER.
      *    Analyse la partie décimale stockée dans la chaine de carac-
      *    tères en partant de la droite. Si c'est un zero inutile, on 
      *    remplace par un blanc si on atteint un chiffre utile, on
      *    arrete le parcours. 
           MOVE 'N' TO LS-JSON-NUMBER-PARSER-STOP 

           PERFORM TEST AFTER VARYING LS-JSON-NUMBER-PARSER-CNT
              FROM 15 BY -1 UNTIL
              LS-JSON-VALUES(LS-JSON-NUMBER-PARSER-CNT:1) = '.'
              OR LS-JSON-NUMBER-PARSER-STOP = 'O'

                   EVALUATE TRUE
                   WHEN LS-JSON-VALUES(LS-JSON-NUMBER-PARSER-CNT:1) = 0
                        MOVE ' ' TO LS-JSON-VALUES
                           (LS-JSON-NUMBER-PARSER-CNT:1)
                   WHEN LS-JSON-VALUES(LS-JSON-NUMBER-PARSER-CNT:1)
                      = '.'
                        MOVE ' ' TO LS-JSON-VALUES
                           (LS-JSON-NUMBER-PARSER-CNT:1)
                        MOVE 'O' TO LS-JSON-NUMBER-PARSER-STOP   
                   WHEN OTHER 
                        MOVE 'O' TO LS-JSON-NUMBER-PARSER-STOP   
                   END-EVALUATE 
           END-PERFORM
           .
      
       FINALISE-JSON.
      
      *    Préparation des caractéristiques du pret 
           MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-JSON-DEM-PRET))
              TO LS-JSON-COUNT
           COMPUTE LS-JSON-COUNT = LS-JSON-COUNT - 2
             
           MOVE WS-JSON-DEM-PRET(2:LS-JSON-COUNT) TO WS-JSON-DEM-PRET
          
      *    Préparation des taux d'intérêts
           MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-JSON-TAUX-INTER))
              TO LS-JSON-COUNT 
           COMPUTE LS-JSON-COUNT = LS-JSON-COUNT - 2

           MOVE WS-JSON-TAUX-INTER(2:LS-JSON-COUNT)
              TO WS-JSON-TAUX-INTER 
              
      *    Préparation de la mensualité
           MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-JSON-MENSUALITE))
              TO LS-JSON-COUNT 
           COMPUTE LS-JSON-COUNT = LS-JSON-COUNT - 2 
           
           MOVE WS-JSON-MENSUALITE(2:LS-JSON-COUNT)
              TO WS-JSON-MENSUALITE   

      *    Préparation de l'échéancier 
           MOVE FUNCTION LENGTH(FUNCTION TRIM(LS-JSON-ECHEANCIER-DATA))
              TO LS-JSON-COUNT 
           COMPUTE LS-JSON-COUNT = LS-JSON-COUNT - 2
      
           MOVE LS-JSON-ECHEANCIER-DATA(2:LS-JSON-COUNT) TO
              LS-JSON-ECHEANCIER-DATA 
           
      *    Assemblage des objets JSON
           MOVE SPACES TO LS-JSON-FINAL
           MOVE 1 TO LS-JSON-COUNT  

           STRING
              '{' DELIMITED BY SIZE
              FUNCTION TRIM(WS-JSON-DEM-PRET) DELIMITED BY SIZE
              ',' DELIMITED BY SIZE
              FUNCTION TRIM(WS-JSON-TAUX-INTER) DELIMITED BY SIZE
              ',' DELIMITED BY SIZE
              FUNCTION TRIM(WS-JSON-MENSUALITE) DELIMITED BY SIZE
              ',' DELIMITED BY SIZE
              FUNCTION TRIM(LS-JSON-ECHEANCIER-DATA) DELIMITED BY SIZE
              '}' DELIMITED BY SIZE
              INTO LS-JSON-FINAL
              WITH POINTER LS-JSON-COUNT 
           END-STRING
           .

       EXPORT-JSON.
           OPEN OUTPUT PRET-JSON
           EVALUATE TRUE 
           WHEN LS-FS-PRET-JSON = '00' 
                DISPLAY 'Le fichier existe déjà'
           WHEN LS-FS-PRET-JSON = '05'
                DISPLAY 'Le fichier est créé'
           WHEN OTHER
                DISPLAY 'Impossible d''ouvrir le fichier en ecriture : '
                        LS-FS-PRET-JSON 
           END-EVALUATE
           
           WRITE FILE-PRET-JSON FROM LS-JSON-FINAL
           
           IF LS-FS-PRET-JSON = '00' THEN
              DISPLAY 'Le fichier JSON a bien été écrit'
           ELSE 
              DISPLAY 'Le fichier JSON n''a pas pu être écrit'
           END-IF
           CLOSE PRET-JSON 
           .
       END PROGRAM GENEJSON.
