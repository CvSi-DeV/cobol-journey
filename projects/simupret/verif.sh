#!/bin/bash
echo "#################################"
echo "# VERIFICATION SIMUPRET SERVEUR #"
echo "#################################"

#où est on ? 
echo "Où est on ? "
cd "$(dirname "$0")"
pwd

#Variable d'environnement 
export "SIMUPRET_CBL_CWD"="./.."
export "SIMUPRET_CBL_EXEC"="./simupret"
export "SIMUPRET_SERVER_PORT"="8765"

#dossier pour les output générés
mkdir -p tmp/tests

#execution du serveur
cd simupret-wrapper
pwd
mvn -o exec:java -Dexec.mainClass="nc.cvsi.simupret.App" > ../tmp/tests/templogerr.txt &
serveurPid=$!
echo "serveur pid = "$serveurPid""
trap 'kill "$serveurPid" 2>/dev/null && echo "ciao"' exit
echo "trap posé"

#Appel aux endpoint /OK pour etre sur que le serveur est ok 
essai=0
while true; do
httpCode=$(curl -sS -w '%{http_code}' -o /dev/null http://localhost:${SIMUPRET_SERVER_PORT}/OK)
sleep 2
essai=$((essai + 1 ))
[ $httpCode = 200 ] || [ $essai = 10 ] && break;
done

#Si le serveur n'a jamais démarrer
if [ $essai = 10 ]; then 
echo "echec démarrage du serveur sur le port ${SIMUPRET_SERVER_PORT}"
exit 1
fi
echo $httpCode

SUCCES=0
ECHECS=0

#Fonction de comparaison pour les resultats
###########################################
comparer() {
    local testName=$1
    local recu=$2
    local attendu=$3

    if [ "$recu" = "$attendu" ]; then 
        SUCCES=$((SUCCES + 1))
    else
        ECHECS=$((ECHECS + 1))
        echo "$testName => KO"
        echo $testName
        echo "recu : $recu"
        echo "attendu : $attendu"
    fi
}

#3.6 routes et methodes
httpCode=$(curl -sS -w '%{http_code}' -o /dev/null http://localhost:${SIMUPRET_SERVER_PORT}/OK)
comparer "test /OK" $httpCode 200

httpCode=$(curl -sS -w '%{http_code}' -o /dev/null http://localhost:${SIMUPRET_SERVER_PORT}/simupret)
comparer "test /simupret (GET)" $httpCode 405

#3.7 corps de requête invalid
httpCode=$(curl -sS -w '%{http_code}' -o /dev/null -X POST -d 'toto' http://localhost:${SIMUPRET_SERVER_PORT}/simupret)
comparer "test /simupret invalid (POST)" $httpCode 400

#3.8 les 3 simulations canoniques
#pret auto 
httpCode=$(curl -sS -w '%{http_code}' -o ./../tmp/tests/pretauto.json -X POST -d '{"typePret":"A","capital":25000.00,"duree":5}' http://localhost:${SIMUPRET_SERVER_PORT}/simupret)
comparer "test /simupret Pret AUTO" $httpCode 200
mensuauto=$(jq -r '.mensualite' ../tmp/tests/pretauto.json)
comparer "pret auto mensualite" $mensuauto 451.44
nbechauto=$(jq -r '.echeancier.nbEcheances' ../tmp/tests/pretauto.json)
comparer "pret auto nb echeances" $nbechauto 60
capiresauto=$(jq -r '.echeancier.echeances[-1].capitalRestant' ../tmp/tests/pretauto.json)
comparer "pret auto capital restant" $capiresauto 0.13

#pret immo 
httpCode=$(curl -sS -w '%{http_code}' -o ../tmp/tests/pretimmo.json -X POST -d '{"typePret":"I","capital":200000.00,"duree":20}' http://localhost:${SIMUPRET_SERVER_PORT}/simupret)
comparer "test /simupret Pret IMMO" $httpCode 200
mensuimmo=$(jq -r '.mensualite' ../tmp/tests/pretimmo.json)
comparer "pret immo mensualite" $mensuimmo 1154.79
nbechimmo=$(jq -r '.echeancier.nbEcheances' ../tmp/tests/pretimmo.json)
comparer "pret immo nb echeances" $nbechimmo 240
capiresimmo=$(jq -r '.echeancier.echeances[-1].capitalRestant' ../tmp/tests/pretimmo.json)
comparer "pret immo capital restant" $capiresimmo -0.87

#pret conso
httpCode=$(curl -sS -w '%{http_code}' -o ../tmp/tests/pretconso.json -X POST -d '{"typePret":"C","capital":8000,"duree":3}' http://localhost:${SIMUPRET_SERVER_PORT}/simupret)
comparer "test /simupret Pret CONSO" $httpCode 200
mensuconso=$(jq -r '.mensualite' ../tmp/tests/pretconso.json)
comparer "pret conso mensualite" $mensuconso 240.49
nbechconso=$(jq -r '.echeancier.nbEcheances' ../tmp/tests/pretconso.json)
comparer "pret conso nb echeances" $nbechconso 36
capiresconso=$(jq -r '.echeancier.echeances[-1].capitalRestant' ../tmp/tests/pretconso.json)
comparer "pret conso capital restant" $capiresconso -0.15

#3.9 requetes rapprochees (test de concurrence)
#deux requetes differentes envoyees en parallele : chaque reponse doit
#correspondre a sa propre demande, pas a l'autre
curl -sS -o ../tmp/tests/concurauto.json -w '%{http_code}' -X POST -d '{"typePret":"A","capital":25000.00,"duree":5}' http://localhost:${SIMUPRET_SERVER_PORT}/simupret > ../tmp/tests/concurauto_code.txt &
pidAuto=$!
curl -sS -o ../tmp/tests/concurimmo.json -w '%{http_code}' -X POST -d '{"typePret":"I","capital":200000.00,"duree":20}' http://localhost:${SIMUPRET_SERVER_PORT}/simupret > ../tmp/tests/concurimmo_code.txt &
pidImmo=$!
wait "$pidAuto" "$pidImmo"

codeConcurAuto=$(cat ../tmp/tests/concurauto_code.txt)
comparer "concurrence : code http reponse auto" $codeConcurAuto 200
codeConcurImmo=$(cat ../tmp/tests/concurimmo_code.txt)
comparer "concurrence : code http reponse immo" $codeConcurImmo 200

capiConcurAuto=$(jq -r '.demandePret.capital' ../tmp/tests/concurauto.json)
comparer "concurrence : reponse auto correspond a sa demande" $capiConcurAuto 25000.00
capiConcurImmo=$(jq -r '.demandePret.capital' ../tmp/tests/concurimmo.json)
comparer "concurrence : reponse immo correspond a sa demande" $capiConcurImmo 200000.00

echo "################################"
echo "# Resultats                     "
echo "################################"
echo "#                               "
echo "# echecs : $ECHECS              "
echo "# succes : $SUCCES              "
echo "#                               "
echo "# AUTO :                        "
echo "#  - mensualité      : $mensuauto "
echo "#  - nb echéances    : $nbechauto "
echo "#  - capital restant : $capiresauto "
echo "#                              #"
echo "# IMMO :                       "
echo "#  - mensualité      : $mensuimmo "
echo "#  - nb echéances.   : $nbechimmo "
echo "#  - capital restant : $capiresimmo "
echo "#                              #"
echo "# CONSO :                      "
echo "#  - mensualité      : $mensuconso "
echo "#  - nb echéances    : $nbechconso "
echo "#  - capital restant : $capiresconso "
echo "#                              #"
echo "################################"

#3.10 Bilan final et code de sortie
if [ $ECHECS != 0 ]; then 
exit 1
else 
rm -rf ../tmp/tests
exit 0
fi
