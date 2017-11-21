#!/usr/bin/perl

use strict;

opendir(DIR, '.');
my @files = readdir(DIR);
closedir(DIR);

my $rom = {};
my $box = {};

foreach my $file(@files) {
  my $prefix = $file;
  $prefix =~ s/(\s*(\(|\[)[^)]+(\)|\])\s*)*(\.zip|_box\.png)$//;

  $rom->{$prefix} = 1 if $file =~ /\.zip$/;
  $box->{$prefix} = 1 if $file =~ /_box\.png/;
}

my $count = 0;
foreach my $key(keys %{$rom}) {
  if(!$box->{$key}) {
    print "MISSING BOX: $key\n";
    $count++;
  }
}
print "$count roms missing cover art.\n";
