#!/usr/bin/perl

use strict;
use Data::Dumper;

opendir(DIR, '.');
my @files = readdir(DIR);
closedir(DIR);

my $roms = {};
my $boxes = {};
my $shots = {};

foreach my $file(@files) {
  next if $file !~ /\.(zip|png)$/;

  my $base = $file;
  my @tags = ();
  $base =~ s/(_(box|background))?\.(zip|png)$//;

  while($base =~ /\s*(\(|\[)([^)\]]+)(\)|\])\s*$/) {
    push @tags, "($2)";
    $base =~ s/\s*(\(|\[)([^)\]]+)(\)|\])\s*$//;
  }

  if($file =~ /_background\.png$/) {
    $shots->{$base} = $file;
  } elsif($file =~ /_box\.png$/) {
    $boxes->{$base} = $file;
  } else {
    if(!$roms->{$base}) {
      $roms->{$base} = {
        file => $file,
        tags => \@tags
      };
    } else {
      # need to determine if this is better than the saved one based on tags
      my $usenew = 0;
      my $oldfile = $roms->{$base}->{'file'};
      my @oldtags = @{$roms->{$base}->{'tags'}};

      # if new is beta or demo and old is not, hard block
      if(grep(/\((proto|beta|b\)|demo|kiosk|sample)/i, @tags) && !grep(/\((proto|beta|b\)|demo|kiosk|sample)/i, @oldtags)) {
        print "Preserving $oldfile over $file.\n";
      } elsif(grep(/\((proto|beta|b\))/i, @oldtags) && !grep(/\((proto|beta|b\))/i, @tags)) {
        # prefer non-proto, non-beta
        $usenew = 1;
        print "Prefering non-proto $file over $oldfile.\n";
      } elsif(grep(/\((demo|kiosk|sample)\)/i, @oldtags) && !grep(/\((demo|kiosk|sample)\)/i, @tags)) {
        # prefer non-demo non-kiosk
        $usenew = 1;
        print "Prefering non-demo $file over $oldfile.\n";
      } elsif(!grep(/USA/, @oldtags) && grep(/USA/, @tags)) {
        # otherwise prefer USA
        $usenew = 1;
        print "Prefering USA $file over $oldfile.\n";
      } elsif(grep(/\(beta /i, @oldtags) && grep(/\(beta/i, @tags)) {
        # if both are betas, preserve the newest
        my $oldbeta = join('',@oldtags) =~ /\(beta ([^)]+)\)/i ? $1 : '0';
        my $newbeta = join('',@tags) =~ /\(beta ([^)]+)\)/i ? $1 : '0';
        $usenew = 1 if $newbeta gt $oldbeta;
        print "Prefering beta $newbeta $file over $oldbeta $oldfile.\n" if $usenew;
      } else {
        # otherwise prefer higher rev
        my $oldrev = join('',@oldtags) =~ /\((rev |v)([^)]+)\)/i ? $1 : '0';
        my $newrev = join('',@tags) =~ /\((rev |v)([^)]+)\)/i ? $1 : '0';
        $usenew = 1 if $newrev gt $oldrev;
        print "Prefering rev $file over $oldfile.\n" if $usenew;
        print "Preserving $oldfile over $file.\n" if !$usenew;
      }

      if($usenew) {
        $roms->{$base}->{'file'} = $file;
        $roms->{$base}->{'tags'} = \@tags;
      }
    }
  }
}

`mkdir -p final`;
foreach my $key(keys %{$roms}) {
  my $file = $roms->{$key}->{'file'};
  my $qfile = quotemeta($file);

  my $newbox = $file;
  my $newshot = $file;
  $newbox =~ s/\.zip$/_box.png/;
  $newshot =~ s/\.zip$/_background.png/;

  my $box = $boxes->{$key};
  my $shot = $shots->{$key};

  my $qbox = quotemeta($box);
  my $qshot = quotemeta($shot);

  my $qnewbox = quotemeta($newbox);
  my $qnewshot = quotemeta($newshot);


  #print "cp $qfile final/$qfile\n";
  #`cp $qfile final/$qfile`;

  #print "cp $qbox final/$qnewbox\n";
  #`cp $qbox final/$qnewbox`;

  if($shot && $shot ne '') {
    #print "cp $qshot final/$qnewshot\n";
    #`cp $qshot final/$qnewshot`;
  }
}
