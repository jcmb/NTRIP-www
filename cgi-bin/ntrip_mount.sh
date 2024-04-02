#! /bin/bash
echo -e "Content-type: text/html\r\n\r\n"
echo -e "<html><head><title>NTRIP Connection information</title></head><body>"

IP=`echo "$QUERY_STRING" | sed -n 's/^.*IP=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
PORT=`echo "$QUERY_STRING" | sed -n 's/^.*PORT=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
USER=`echo "$QUERY_STRING" | sed -n 's/^.*USER=\([^&]*\).*$/\1/p' | sed "s/%20/ /g" | sed "s/+/ /g"`
PASS=`echo "$QUERY_STRING" | sed -n 's/^.*PASS=\([^&]*\).*$/\1/p' | sed "s/%20/ /g" | sed "s/+/ /g"`
MOUNT=`echo "$QUERY_STRING" | sed -n 's/^.*MOUNT=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
HEADERS=`echo "$QUERY_STRING" | sed -n 's/^.*HEADERS=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
RAW=`echo "$QUERY_STRING" | sed -n 's/^.*RAW=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`

#SERVER=sps855.com
#PORT=2101
#USER=IBS
#PASS=IBS
#BASE=CMRx


echo -e "<h1>NTRIP mountpoint $MOUNT information for $USER from $IP:$PORT</h1>\n"
echo -e "<br>This test takes 15 seconds"
# echo curl -f  --connect-timeout 10 -m 10  -H "Ntrip-Version: Ntrip/2.0" -H "User-Agent: NTRIP CURL_NTRIP_TEST/0.1" -u $USER:$PASS  http://$USER_ORG.ibss.trimbleos.com:2101/$BASE
#curl -D ~/tmp/headers_$$  -o ~/tmp/st_$$   --connect-timeout 10 -m 10  -H "Ntrip-Version: Ntrip/1.0" -H "User-Agent: NTRIP CURL_NTRIP_TEST/0.1" -u $USER:$PASS  http://$SERVER:$PORT/$BASE
#echo ./NtripClient.py --HeaderFile ~/tmp/headers_$$  -f ~/tmp/st_$$   -m 10  -u "$USER" -p "$PASS"  $IP $PORT $MOUNT
./NtripClient.py --HeaderFile ~/tmp/headers_$$  -f ~/tmp/st_$$   -m 10  -u "$USER" -p "$PASS"  $IP $PORT $MOUNT
#echo "Result: $?"
echo "<br><H2>Status:</h2><br>"
perl -f ibss_mount.pl < ~/tmp/headers_$$
RES=$?
echo "</pre>"
if [ $RES == 0 ]
then
   echo "<H2>Data:</H2>"

   if [ -s ~/tmp/st_$$ ]
   then
      Size=`stat -c %s ~/tmp/st_$$`
      echo "Base is sending data ($Size bytes)"
      rm ~/tmp/st_$$
   else
      echo "Base is not sending data"
   fi
fi

if [ $HEADERS ]
then
   echo "<br><H2>Headers</h2><pre>"
   cat ~/tmp/headers_$$
   echo "</pre>"
fi

#rm headers_$$
#curl -f  -o ~/tmp/st_$$ --connect-timeout 10 -m 300  -H "Ntrip-Version: Ntrip/2.0" -H "User-Agent: NTRIP CURL_NTRIP_TEST/0.1" -u $USER:$PASS  http://$USER_ORG.ibss.trimbleos.com:2101/
#echo "Result: $?"
#stat ~/tmp/st_$$
#echo perl ntripdump.pl <~/tmp/st_$$
#cat ~/tmp/st_$$
#if [ $? == 0 ]
#then
#    perl ntripdump.pl <~/tmp/st_$$
#    echo "<p/>End of table"
#else
#    echo "Invalid Password"
#fi
echo "</body></html>"
#echo "<pre>";
#cat ~/tmp/st_$$
