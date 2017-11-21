#!/usr/bin/perl

use strict;

opendir(DIR, '../');
my @rfiles = readdir(DIR);
closedir(DIR);

opendir(DIR, "./Named_Boxarts");
my @bfiles = readdir(DIR);
closedir(DIR);

opendir(DIR, "./Named_Titles");
my @sfiles = readdir(DIR);
closedir(DIR);

my $roms = map_files(@rfiles);
my $boxes = map_files(@bfiles);
my $shots = map_files(@sfiles);

foreach my $rom (keys %{$roms}) {
  my $box = './Named_Boxarts/' . $boxes->{$rom} . '.png';
  my $newbox = '../' . $roms->{$rom} . '_box.png';
  my $shot = './Named_Titles/' . $shots->{$rom} . '.png';
  my $newshot = '../' . $roms->{$rom} . '_background.png';

  my $qbox = quotemeta($box);
  my $qnewbox = quotemeta($newbox);
  my $qshot = quotemeta($shot);
  my $qnewshot = quotemeta($newshot);

  if(-e $box) {
    #`cp $qbox $qnewbox`;
  } else {
    print "NO BOX $rom\n";
  }

  if(-e $shot) {
    #`cp $qshot $qnewshot`;
  } else {
    print "NO SHOT $rom\n";
  }
}

sub map_files {
  my @files = @_;
  my $files = {};
  foreach my $file(sort @files) {
    if($file =~ /\.(zip|png)$/ && ($file =~ /[,(](USA|Europe|World)[,)]/ || $file =~ /[,(]En[,)]/)) {
      my $clean = $file;
      $clean =~ s/\.(zip|png)$//;
      my $base = $clean;
      $base =~ s/(\s*(\(|\[)[^)]+(\)|\]))*$//;
      $base =~ s/\+/&/g;

      $files->{$base} = $clean;
    }
  }
  return $files;
}
