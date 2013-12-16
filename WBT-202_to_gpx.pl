#!/usr/bin/perl

# Convert (and delete) TES files in Wintec WBT-201 to GPX files.

use strict;
use warnings;

use File::Basename;
use Time::Piece;

# my $dir = 'tmp/';
my $date = Time::Piece->new->strftime(" %Y %m %d %a %H %M %S");

my $BASE = "/Volumes/NO NAME";
my $dir = "gpsbabel export" . $date;
my $DEST = "$ENV{'HOME'}/Desktop/" . $dir;



my $GPSBABEL = "gpsbabel";

my $delete = 0;
if ($#ARGV >= 0 and $ARGV[0] eq "-d") {
  $delete = 1;
}

my @teses = glob "'$BASE/WBT202/20*/*.TES'";
if ($#teses < 0) {
  die("no files to convert");
}else{
  unless(-d $DEST . $dir ){
    mkdir $DEST  or die("not possible to create export folder at " . $DEST);
  }
}

foreach my $tes (@teses) {
  print "converting $tes\n";

  # Create a Time object from the name of a TES file.
  # Note that the time is represented in GMT
  my $str = $tes;
  $str =~ s/^.+([0-9]{8}\/[0-9_]{8})\.TES$/$1 GMT/;
  my $t = Time::Piece->strptime($str, "%Y%m%d/%H_%M_%S %Z");

  # Convert to a GPX file. The file name is the local time.
  my @args = ($GPSBABEL,
    "-i", "wintec_tes",
    "-f", $tes,
    "-o", "gpx",
    "-F", $DEST . "/" . $t->strftime("%Y%m%d-%H_%M_%S") . ".gpx");
  system(@args);
  if (! $?) {
    if ($delete) {
      unlink($tes) or warn("cannot unlink $tes");
      rmdir(dirname($tes));
    }
  } else {
    die("cannot convert $tes (status: $?)");
  }
}
