#! /usr/bin/perl
use strict;
#use Switch;
use Data::Dumper;
use feature qw/say/;

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

my @bases=();

my $IBSS=shift;


while (<>) {
   chomp;
#   print "***+$_=\n";
   if ($skipped_header) {
      if ($_ ne "ENDSOURCETABLE" ) {
#      ($type,$mount,$id,$format,$format_details,$carrier,$nav,$network,$country,$lat,$long,$nmea,$solution,$generator,$comp,$authentication,$fee,$bitrate,$misc) = split (/;/);
         my @fields = split (/;/);
#         print Dumper(@fields);
         if (@fields[0] eq "STR") {
#           print"$type;$mount;$id;$format;$format_details;$carrier;$nav;$network;$country;$lat;$long;$nmea;$solution;$generator;$comp;$authentication;$fee;$bitrate;$misc\n";
            if ($fields[10] != 0) { #long
               if ($fields[12] != "1" || $IBSS ) { #Not a network solution or IBSS
                   if ($fields[11] != "1" || $IBSS ) { #Does not require NMEA or IBSS
#                         print $fields[3],"\n";
                      if ($fields[3] ne "RAW") { #Not a raw stream
#                         print $fields[3]," *****\n";
                         push(@bases,[@fields]);
                         }
                     }
                  }
#               print Dumper(@bases)
               }
            }
        }
     }
   else {
      $skipped_header = $_ eq "";
      }
   }

#my $base;
my $number_bases=scalar @bases;
# Here we have an array of all the non zero bases
#for $base  (0 .. $#bases) {
#   print "base: ", base;
#   print Dumper(base);
#   }
my @unique_bases;

for (my $base_id = 0; $base_id < $number_bases; $base_id++) {
    my $base_fields=@bases[$base_id];
    my $dup=0;
    my $base_lat=$base_fields->[9];
    my $base_long=$base_fields->[10];
    for (my $check_base_id = $base_id+1; ($check_base_id < $number_bases) and not $dup; $check_base_id++) {
        my $fields=@bases[$check_base_id];
        $dup=($base_lat==$fields->[9]) && ($base_long==$fields->[10]);
        if ($dup) {
#            print "Duplicate Station: ", $base_id," " , $base_fields->[1], " ", $check_base_id," " , $fields->[1],"\n";
#            print $fields->[1],",'", $fields->[3],"',",$fields->[6],"\n";

            $fields->[3].=", "  . $base_fields->[3];
            if (length($base_fields->[6]) > length($fields->[6])) { #Assume that we want the longest text in the nav system
                $fields->[6]=$base_fields->[6];
                }
            ($fields->[1] ^ $base_fields->[1]) =~ /^(\0*)/;
            my  $commonLen = $+[0];
            if ($commonLen>0) {
                if ($commonLen>1 && (substr($fields->[1],$commonLen-1,1) eq "-")) { #Common part of the Name ends with -
                    $fields->[1]=substr($fields->[1],0,$commonLen-1);
                    }
                else {
                    $fields->[1]=substr($fields->[1],0,$commonLen);
                    }
                }
#            print $base_fields->[1],",'", $base_fields->[3],"',",$base_fields->[6],"\n";
#            print $fields->[1],",'", $fields->[3],"',",$fields->[6],"\n";
#            print "Found Dup: ", $base_id," ",$check_base_id,"\n";
            }
        }
    if (not $dup) {
#        print "Real Station: ", $base_id," " , $base_fields->[1],"\n";
#        print $base_fields->[1],",'", $base_fields->[3],"',",$base_fields->[6],"\n";
        push(@unique_bases,$base_fields);
        }
    }


my $number_unique_bases=scalar @unique_bases;

#print $number_unique_bases;
#print Dumper(@unique_bases);

for (my $base_id = 0; $base_id < $number_unique_bases; $base_id++) {
    my $base_fields=@unique_bases[$base_id];

    my $mount = quotemeta($base_fields->[1]);
    my $lat = $base_fields->[9];
    my $long = $base_fields->[10];
    my $nav = $base_fields->[6];
    my $format = $base_fields->[3];

    print `./IBSS_kml_vert_circle $lat $long $mount "$nav" "$format"`;
    }
#           }
#        }
