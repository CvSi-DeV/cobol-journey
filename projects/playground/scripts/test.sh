#!/bin/bash
#ceci est un commentaire, ignoré par bash 
pwd
cd "$(dirname "$0")"
pwd
#suppression des fichiers créés
rm -f /tmp/rep_immo.json
echo "Bonjour"
date 
echo "----"
NOM="serveur" # pas d'espace autour du =
echo "Le $NOM tourne" #le $NOM est replacé par sa valeur
echo 'Le $Nom tourne' #guillemets simple pas de remplacement
echo "le ${NOM}_v1" # pour delimiter le nom
echo 
PORT=8089
SERVEUR_ADR="http://localhost"
echo ""$SERVEUR_ADR":${PORT}"
echo "${SERVEUR_ADR}:${PORT}"
echo "test et conditions"
echo "------------------"
ls -l test.sh 2>/dev/null 
RC=$?
echo "Résultat ls : ${RC}"
if [ -f test.sh ]; then
 echo "fichier présent"
else 
 echo "fichier absent"
fi

ls test.sh 2>/dev/null || echo "fichier absent"

doubler() {
    local value=$1
    local doubleValue=$((value*2))
    echo ${doubleValue}
    return 0
}

DOUBLERESULT=$(doubler 3)
RC=$?
echo "execution ${RC}"
echo "resultat fonction double = ${DOUBLERESULT}"

CODE_OK=$(curl -sS -o /dev/null -w '%{http_code}' http://localhost:8765/OK)
echo "code OK : ${CODE_OK}"
CODE_GET=$(curl -sS -o /dev/null -w '%{http_code}' http://localhost:8765/simupret)
echo "code GET : ${CODE_GET}"
if [ "${CODE_OK}" -eq 200 ]; then 
echo OK
else 
echo KO
fi

CODE_IMMO=$(curl -sS -o /tmp/rep_immo.json -w '%{http_code}' \
-d '{"typePret":"I", "capital":"200000", "duree":"20"}' \
http://localhost:8765/simupret)
echo "CODE IMMO : ${CODE_IMMO}"

MENSUALITE=$(jq -r '.mensualite' /tmp/rep_immo.json)
if [ "${MENSUALITE}" = 1154.79 ];then
echo "mensualité => OK"
fi

jq  '.echeancier.echeances[-1].capitalRestant' /tmp/rep_immo.json  

jq -e '.echeancier.nbEcheances == 240' /tmp/rep_immo.json 

sleep 100 &
myPID=$!
echo "PID du sleep : ${myPID}"
sleep 2
ps -p "$myPID"
kill "$myPID"
echo "ps 2"
ps -p "$myPID"