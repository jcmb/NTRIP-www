use strict;
my $Result="";
my $Result_Text="";
my $Error="";
my $Text="";
my $Server="";

while (<>) {
    chomp;
#    print;
    if (/^HTTP\/1\.[01] (\d*) (.*)/) {$Result=$1; $Result_Text= $2};
    if (/^ICY 200 OK/) {$Result=200; $Result_Text="OK"};
    if (/^ERROR\s*-\s*(.*)/i) {$Result=401; $Result_Text=$1};
    if (/^X-ntrip-error-code: TRMB-(\d*)/) {$Error=$1};
    if (/^X-ntrip-error-text: (.*)/) {$Text=$1};
    if (/^Server: (.*)/) {$Server=$1};
}

if ( $Result == 200 ) {
   print "Base Station can be used<br>\n";
   print "IBSS Server Version: $Server<br>\n";
   exit (0);
   }
else {
   print "Base Station can not be accessed<p/>\n";
   if ($Text ne "") {
      print "IBSS Error: $Text ($Error)<br>\n";
   }
   if ($Result == 401 && $Result_Text ne "") {
      print "Authentication error: $Result_Text<br>\n";
   }
   elsif ($Result_Text ne "") {
      print "NTRIP Error: $Result_Text ($Result)<br>\n";
   }
   else {
      print "HTTP Error: unknown ($Result)<br>\n";
   }
   print "Server Version: $Server<br>\n";
   exit (1);
   }
