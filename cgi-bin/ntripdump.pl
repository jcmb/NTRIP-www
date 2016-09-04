use strict;

my $add_link=@ARGV == 4;
my $ip=shift (@ARGV);
my $port=shift (@ARGV);
my $user=shift (@ARGV);
my $password=shift(@ARGV);


$/ ="\r\n"; #The NTRIP source tables are CR/LF

my $skipped_header=1;
my $type;
my $mount;
my $id;
my $format;
my $format_details;
my $carrier;
my $nav;
my $network;
my $country;
my $lat;
my $long;
my $nmea;
my $solution;
my $generator;
my $comp;
my $authentication;
my $fee;
my $bitrate;
my $misc;
my $total_mounts=0;

#print "<HTML>\n";
#print "<BODY>\n";
print <<'EOF';
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
<script src="/jquery.tablesorter.min.js"></script>
<link rel="stylesheet" type="text/css" href="/style.css"></link>
<script>
$(document).ready(function()
{
    $("#Mounts").tablesorter();
}
);
</script>
EOF

print ;
print "<TABLE BORDER=1 id=\"Mounts\" class=\"tablesorter\">\n";
printf("<thead><tr>\n");
#printf("   <th> Type</th>\n");
printf("   <th> Mount point</th>\n");
printf("   <th> Id</th>\n");
printf("   <th> Format</th>\n");
#printf("   <th> Format details</th>\n");
printf("   <th> Carrier Phase</th>\n");
printf("   <th> GNSS System</th>\n");
printf("   <th> Network</th>\n");
printf("   <th> Country</th>\n");
printf("   <th> Latitude</th>\n");
printf("   <th> Longitude</th>\n");
printf("   <th> NMEA</th>\n");
printf("   <th> Solution Type</th>\n");
printf("   <th> Generator</th>\n");
#printf("   <th> Compression</th>\n");
printf("   <th> Login</th>\n");
printf("   <th> Fee</th>\n");
#printf("   <th> bitrate</th>\n");
printf("   <th> Misc</th>\n");
printf("</tr><thead><tbody>\n");

while (<>) {
   chomp;
#   print "***+$_=\n";
   if ($skipped_header) {
       if ($_ ne "ENDSOURCETABLE" ) {
			($type,$mount,$id,$format,$format_details,$carrier,$nav,$network,$country,$lat,$long,$nmea,$solution,$generator,$comp,$authentication,$fee,$bitrate,$misc) = split (/;/);
		  if ($type eq "STR") {	
		      printf("<tr>\n");
		      $total_mounts++;
	#        printf("   <TD>$type</TD>\n");
		      if ($add_link) {
			  if ($nmea == "0") {
			     printf("   <TD><a href=\"ntrip_mount.sh?IP=$ip&PORT=$port&USER=$user&PASS=$password&MOUNT=$mount&FORMAT=$format\"> $mount</a></TD>\n");
			  }
			  else {
			     printf("   <TD><a href=\"VRS_Mount_Front?IP=$ip&PORT=$port&USER=$user&PASS=$password&MOUNT=$mount&FORMAT=$format\"> $mount</a></TD>\n");
			  }
		      }
		      else {
			  printf("   <TD> $mount</TD>\n");
		      }
			  printf("   <TD> $id</TD>\n");
			  printf("   <TD> $format</TD>\n");
	#        printf("   <TD> $format_details</TD>\n");
	#        printf("   <TD> $carrier</TD>\n");
			  printf("   <TD> ");
           if ($carrier == "0") {
				  print "Code Only"
              }
           elsif ($carrier == "1") {
				  print "L1"
              }
           elsif ($carrier == "2") {
				  print "L1/L2"
              }
           else {
              print "Unknown $carrier"
              }
				 
			  printf("</TD>\n");
	
			  printf("   <TD> $nav</TD>\n");
			  printf("   <TD> $network</TD>\n");
			  printf("   <TD> $country</TD>\n");
			  printf("   <TD> $lat</TD>\n");
			  printf("   <TD> $long</TD>\n");
			  printf("   <TD> ");

			  if ($nmea == "0") { print "Must Not Send NMEA"}
           elsif ($nmea == "1") { print "Must Send NMEA" }
			  else { print "Unknown $nmea" }

			  printf("</TD>\n");
			  printf("   <TD> ");

			  if ($solution == "0") { print "Single base" }
           elsif ($solution == "1") {print "Network"}
			  else {print "Unknown $solution"}

			  printf("</TD>\n");
			  printf("   <TD> $generator</TD>\n");
#			  printf("   <TD> $comp</TD>\n");
			  printf("   <TD> ");

			  if ($authentication == "N") {print "No"}
			  elsif ( $authentication ==  "B") {print "Required"}
			  elsif ( $authentication ==  "D") {print "Digest"}
			  else {print "Unknown $authentication"}
				
			  printf("</TD>\n");
			  printf("   <TD> ");
			  if ($fee == "N") {print "No"}
			  elsif ($fee == "Y") {print "Yes"}
			  else {print "Unknown $fee"}
				  
			  printf("</TD>\n");
	#        printf("   <TD> $bitrate</TD>\n");
			  printf("   <TD> $misc</TD>\n");
			  printf("</tr>\n");
	#			print"$type;$mount;$id;$format;$format_details;$carrier;$nav;$network;$country;$lat;$long;$nmea;$solution;$generator;$comp;$authentication;$fee;$bitrate;$misc\n";
				}
			}
       }
   else {
      $skipped_header = $_ eq "";
      }
   }
   
print "</tbody></TABLE>\n";
print "<p/>Total Mount Points: $total_mounts"
#print "</BODY>\n";
#print "</HTML>\n";
