COMPTEUR=0
incrementer() {
    COMPTEUR=$((COMPTEUR+1))
}
incrementer
incrementer
echo "$COMPTEUR"

PASS=0
FAIL=0

tester(){
    local description="$1"
    local attendu="$2"
    local obtenu="$3"

    if [ "$obtenu" = "$attendu" ]; then 
    PASS=$((PASS + 1))
    echo "OK : $description"
    else
    FAIL=$((FAIL + 1))
    echo "Fail : $description (attendu '$attendu', obtenu '$obtenu')"
    fi
}
#tester test1 a b 
tester test2 a a 

echo "----"
echo "Résultat : $PASS réussi(s), $FAIL échec(s)"

if [ "$FAIL" -eq 0 ]; then
    exit 0
else
    exit 1
fi