#! /bin/bash
#rm source_table
echo -e "Content-type: text/html\r\n\r\n"
echo -e "<html><head><title>NTRIP Table information</title>"
echo -e '<link rel="stylesheet" type="text/css" href="/css/tcui-styles.css"></head><body class="page"><div class="container clearfix"><div style="padding: 10px 10px 10px 0 ;">'
echo -e '<a href="http://construction.trimble.com/"><img src="/images/trimble-logo.jpg" alt="Trimble Logo" id="logo"> </a></div></div><div id="top-header-trim"></div><div id="content-area"><div id="content"><div id="main-content" class="clearfix">'

IP=`echo "$QUERY_STRING" | sed -n 's/^.*IP=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
PORT=`echo "$QUERY_STRING" | sed -n 's/^.*PORT=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
HEADERS=`echo "$QUERY_STRING" | sed -n 's/^.*HEADERS=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
USER=`echo "$QUERY_STRING" | sed -n 's/^.*USER=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
PASSWORD=`echo "$QUERY_STRING" | sed -n 's/^.*PASSWORD=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
VERSION=`echo "$QUERY_STRING" | sed -n 's/^.*VERSION=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
#IP=ibss.ibss.trimbleos.com
#PORT=2101
#USER=status
#PASSWORD=trimble
#IP=sps852.com
#PORT=2101
echo -e "<h1>NTRIP Table information for $IP:$PORT</h1>\n"
if [ $VERSION ]
then
   if [ $USER ]
   then    
      curl --user $USER:$PASSWORD -D headers_$$ -f -o /tmp/st_$$ -A NTRIP --silent -H "Ntrip-Version: Ntrip/2.0" -H "User-Agent: NTRIP CURL_NTRIP_TEST/0.1" http://$IP:$PORT
   else
      curl -D /tmp/headers_$$ -f -o /tmp/st_$$ -A NTRIP --silent -H "Ntrip-Version: Ntrip/2.0" -H "User-Agent: NTRIP CURL_NTRIP_TEST/0.1" http://$IP:$PORT
   fi
else
   if [ $USER ]
   then    
       curl --user $USER:$PASSWORD -D headers_$$ -f -o /tmp/st_$$ -A NTRIP --silent -H "Ntrip-Version: Ntrip/1.0" -H "User-Agent: NTRIP CURL_NTRIP_TEST/0.1" http://$IP:$PORT
   else
       curl -D /tmp/headers_$$ -f -o /tmp/st_$$ -A NTRIP --silent -H "Ntrip-Version: Ntrip/1.0" -H "User-Agent: NTRIP CURL_NTRIP_TEST/0.1" http://$IP:$PORT
   fi
fi

RES=$?
#echo "Result: $?"
#echo perl ntripdump.pl <~/tmp/st_$$
#cat ~/tmp/st_$$
if [ $RES == 0 ]
then
    if [ $HEADERS ]
    then
	echo "<br><H2>Headers</h2><pre>"
	cat /tmp/headers_$$
	echo "</pre>"
    fi


    perl ntripdump.pl $IP $PORT $USER $PASSWORD </tmp/st_$$
    echo "<p/>End of table"
else
    echo "Connection Error ($RES)"
fi

echo "</div></div></div>"
echo "</body></html>"
rm /tmp/st_$$
rm /tmp/headers_$$
