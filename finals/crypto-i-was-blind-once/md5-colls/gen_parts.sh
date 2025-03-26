echo "VALID MESSAGE :                                                 abcd" > prefix.txt

../../../hashclash/scripts/poc_no.sh prefix.txt
mv collision1.bin part1A.bin
mv collision2.bin part1B.bin
for i in {1..23}
do
  echo "Starting round $i"
  sleep 5
  ../../../hashclash/scripts/poc_no.sh part"${i}"A.bin
  mv collision1.bin part"$((i+1))"A.bin
  mv collision2.bin part"$((i+1))"B.bin
  sleep 5
done