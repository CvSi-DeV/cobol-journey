sleep 100 &
sleepPid=$!
trap 'kill "${sleepPid}"' exit
echo "trap posé"
exit 1
echo "exit 1 executé"
ps -aux | grep sleep