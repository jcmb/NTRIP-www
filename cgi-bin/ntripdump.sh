#! /bin/bash
#rm source_table
echo -e "Content-type: text/html\r\n\r\n"

cat  <<EOF
<html><head>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.0/jquery.min.js"></script>
<script src="/IBSS/jquery.tablesorter.min.js"></script>
<script src="/IBSS/jquery.tablesorter.widgets.min.js"></script>
<link rel="stylesheet" type="text/css" href="/css/theme.blue.css">
<link rel="stylesheet" type="text/css" href="/css/tcui-styles.css">
<title>NTRIP Table information</title></head>
<body class="page">
<div class="container clearfix">
  <div style="padding: 10px 10px 10px 0 ;"> <a href="http://construction.trimble.com/">
        <img src="/images/trimble-logo.png" alt="Trimble Logo" id="logo"> </a>
      </div>
  <!-- end #logo-area -->
</div>
<div id="content-area">
<div id="content">
<div id="main-content" class="clearfix">

EOF

IP=`echo "$QUERY_STRING" | sed -n 's/^.*IP=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
PORT=`echo "$QUERY_STRING" | sed -n 's/^.*PORT=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
HEADERS=`echo "$QUERY_STRING" | sed -n 's/^.*HEADERS=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
USER=`echo "$QUERY_STRING" | sed -n 's/^.*USER=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
PASSWORD=`echo "$QUERY_STRING" | sed -n 's/^.*PASSWORD=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
VERSION=`echo "$QUERY_STRING" | sed -n 's/^.*VERSION=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`
RAW=`echo "$QUERY_STRING" | sed -n 's/^.*RAW=\([^&]*\).*$/\1/p' | sed "s/%20/ /g"`

#IP=ibss.ibss.trimbleos.com
#PORT=2101
#USER=status
#PASSWORD=trimble
#IP=sps855.com
#PORT=2101

echo -e "<h1>NTRIP Table information for $IP:$PORT</h1>\n"
if [ $VERSION ]
then
   if [ $USER ]
   then
      curl --http0.9 --user $USER:$PASSWORD -D headers_$$ -f -o /tmp/st_$$ -A NTRIP --silent -H "Ntrip-Version: Ntrip/2.0" -H "User-Agent: NTRIP CURL_NTRIP_TEST/0.1" http://$IP:$PORT
   else
      curl --http0.9 -D /tmp/headers_$$ -f -o /tmp/st_$$ -A NTRIP --silent -H "Ntrip-Version: Ntrip/2.0" -H "User-Agent: NTRIP CURL_NTRIP_TEST/0.1" http://$IP:$PORT
   fi
else
   if [ $USER ]
   then
       curl --http0.9 --user $USER:$PASSWORD -D headers_$$ -f -o /tmp/st_$$ -A NTRIP --silent -H "Ntrip-Version: Ntrip/1.0" -H "User-Agent: NTRIP CURL_NTRIP_TEST/0.1" http://$IP:$PORT
   else
       curl --http0.9 -D /tmp/headers_$$ -f -o /tmp/st_$$ -A NTRIP --silent -H "Ntrip-Version: Ntrip/1.0" -H "User-Agent: NTRIP CURL_NTRIP_TEST/0.1" http://$IP:$PORT
   fi
fi

RES=$?
#echo "Result: $?"
#echo perl ntripdump.pl <~/tmp/st_$$
#cat ~/tmp/st_$$
if [ $RES == 0 ]
then

    perl ntripdump.pl $IP $PORT $USER $PASSWORD </tmp/st_$$
    echo "<p/>End of table"
else
    if [ $RES == 22 ]
    then
        echo "Invalid Password"
    else
        echo "Connection Error ($RES)"
    fi
fi


if [ $HEADERS ]
    then
    echo "<br><H2>Headers</h2><pre>"
    cat /tmp/headers_$$
    echo "</pre>"
    fi

if [ $RAW ]
then
   echo "<br><H2>RAW</h2><pre>"
   cat /tmp/st_$$
   echo "</pre>"
fi



echo "</div></div></div>"
echo "</body></html>"
rm /tmp/st_$$
rm /tmp/headers_$$
