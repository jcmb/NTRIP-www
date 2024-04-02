#! /usr/bin/perl 
use strict;
use Switch;

$/ ="\r\n"; #The NTRIP source tables are CR/LF 
# need to set on linux 

my $skipped_header=0;
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


while (<>) {
   chomp;
#   print "***+$_=\n";
   if ($skipped_header) {
      if ($_ ne "ENDSOURCETABLE" ) {
	   ($type,$mount,$id,$format,$format_details,$carrier,$nav,$network,$country,$lat,$long,$nmea,$solution,$generator,$comp,$authentication,$fee,$bitrate,$misc) = split (/;/);
		if ($type eq "STR") {	
#			print"$type;$mount;$id;$format;$format_details;$carrier;$nav;$network;$country;$lat;$long;$nmea;$solution;$generator;$comp;$authentication;$fee;$bitrate;$misc\n";

      $mount = quotemeta($mount);
      if ($lat != 0) {
         print `./IBSS_kml_circle $lat $long $mount $nav $format`;
         }
		   }
		}
     }
   else {
      $skipped_header = $_ eq "";
      }
   }
   
