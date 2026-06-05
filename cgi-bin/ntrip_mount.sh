#! /bin/bash
echo -e "Content-type: text/html\r\n\r\n"
echo -e "<html><head><title>NTRIP Connection information</title>"
echo -e '<link rel="stylesheet" type="text/css" href="/css/tcui-styles.css"></head><body class="page"><div class="container clearfix"><div style="padding: 10px 10px 10px 0 ;">'
echo -e '<a href="http://construction.trimble.com/"><img src="/images/trimble-logo.jpg" alt="Trimble Logo" id="logo"> </a></div></div><div id="top-header-trim"></div><div id="content-area"><div id="content"><div id="main-content" class="clearfix">'

IP=`echo "$QUERY_STRING" | sed -n 's/^.*IP=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
PORT=`echo "$QUERY_STRING" | sed -n 's/^.*PORT=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
USER=`echo "$QUERY_STRING" | sed -n 's/^.*USER=\([^&]*\).*$/\1/p' | sed "s/%20/ /g" | sed "s/+/ /g"`
PASS=`echo "$QUERY_STRING" | sed -n 's/^.*PASS=\([^&]*\).*$/\1/p' | sed "s/%20/ /g" | sed "s/+/ /g"`
MOUNT=`echo "$QUERY_STRING" | sed -n 's/^.*MOUNT=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
HEADERS=`echo "$QUERY_STRING" | sed -n 's/^.*HEADERS=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
RAW=`echo "$QUERY_STRING" | sed -n 's/^.*RAW=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
TIME=10

#IP=209.236.50.154
#PORT=2101
#USER=IBS
#PASS=IBS
#MOUNT=CMR

echo -e "<h1>NTRIP mountpoint $MOUNT information for $USER from $IP:$PORT</h1>\n"
echo -e "<br>This test takes $TIME seconds"
./NtripClient.py --HeaderFile /tmp/headers_$$  -f /tmp/st_$$   -m $TIME  -u "$USER" -p "$PASS"  $IP $PORT $MOUNT
echo "<br><H2>Status:</h2><br>"
perl -f ibss_mount.pl < /tmp/headers_$$
RES=$?
if [ $RES == 0 ]
then
   echo "<H2>Data:</H2>"

   if [ -s /tmp/st_$$ ]
   then
      Size=`stat -c %s /tmp/st_$$`
      echo "Base is sending data ($Size bytes)"
      rm /tmp/st_$$
   else
      echo "Base is not sending data"
   fi
fi

if [ $HEADERS ]
then
   echo "<br><H2>Headers</h2><pre>"
   cat /tmp/headers_$$
   echo "</pre>"
fi
rm -f /tmp/headers_$$

echo "</div></div></div>"
echo "</body></html>"
