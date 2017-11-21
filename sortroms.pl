#!/usr/bin/perl

use strict;
use Data::Dumper;

my $dir = shift;

opendir(DIR, $dir);
my @rfiles = readdir(DIR);
closedir(DIR);

my $ignored = {};
open(IGNORED, "<$dir/ignore_roms/ignore");
while(<IGNORED>) {
  chomp;
  $ignored->{$_} = 1;
}
close(IGNORED);

foreach my $file(sort @rfiles) {
  if($file =~ /\.zip$/) {
    my $clean = $file;
    $clean =~ s/\.(zip|png)$//;
    my $base = $clean;
    $base =~ s/(\s*(\(|\[)[^)]+(\)|\]))*$//;
    $base =~ s/\+/&/g;
    my $qfile = quotemeta($file);

    if($ignored->{$base} || ($file !~ /[,(](USA|Europe)[,)]/ && $file !~ /[,(]En[,)]/)) {
      `mv $dir/$qfile $dir/ignore_roms/`;
    }
  }
}
