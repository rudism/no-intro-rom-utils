#!/usr/bin/perl

use strict;
use Data::Dumper;
use URI::Escape;
use LWP::UserAgent;
use XML::LibXML::Simple qw(XMLin);
use Text::Levenshtein qw(distance);

my $dir = shift;
my $platform = uri_escape(shift);

my $ua = LWP::UserAgent->new;
$ua->agent('Firefox Safari Chrome Mozilla');

opendir(DIR, $dir);
my @rfiles = readdir(DIR);
closedir(DIR);

opendir(DIR, "$dir/img/Named_Boxarts");
my @bfiles = readdir(DIR);
closedir(DIR);

opendir(DIR, "$dir/img/Named_Titles");
my @sfiles = readdir(DIR);
closedir(DIR);

my $roms = map_files(@rfiles);
my $boxes = map_files(@bfiles);
my $shots = map_files(@sfiles);

my $max = keys %{$roms};
my $counter = 0;

my $ignored = {};
open(IGNORED, "<$dir/ignore_roms/ignore");
while(<IGNORED>) {
  chomp;
  $ignored->{$_} = 1;
}
close(IGNORED);

foreach my $rom(sort keys %{$roms}) {
  $counter++;
  next if !$rom;
  next if $boxes->{$rom} || $ignored->{$rom};
  open(IGNORE, ">>$dir/ignore_roms/ignore");
  print "$rom -> ";
  my $query = $rom;
  $query =~ s/[^a-zA-Z0-9' ]//g;
  $query =~ s/\s+/ /g;
  $query = uri_escape($query);
  my $url = "http://thegamesdb.net/api/GetGame.php?platform=$platform&name=$query";
  #print "$url\n";
  my $resp = $ua->get($url);
  if($resp->is_success) {
    my $xml = XMLin($resp->decoded_content, ForceArray => 1);
    my $baseurl = $xml->{'baseImgUrl'};
    my $match = undef;
    my $matchgid = undef;
    my $matchdist = 99999;
    my @gids = keys %{$xml->{'Game'}};
    foreach my $gid(keys %{$xml->{'Game'}}) {
      my $name = $xml->{'Game'}->{$gid}->{'GameTitle'};
      my $lsd = distance($rom, $name, { ignore_diacritics => 1 });
      if($lsd < $matchdist) {
        $match = $name;
        $matchgid = $gid;
        $matchdist = $lsd;
      }
    }
    if($match) {
      print "[$counter/$max] $match [$matchdist] y/n: ";
      my $input = $matchdist <= 1 ? "y\n" : readline;
      chomp($input);
      if($input =~ /^y$/i) {
        my $arts = $xml->{'Game'}->{$matchgid}->{'Images'}->[0]->{'boxart'};
        my $handled = 0;
        for(my $i = 0; $i < @{$arts}; $i++) {
          if($arts->[$i]->{'side'} eq 'front') {
            my $imgpath = $arts->[$i]->{'content'};
            my ($ext) = $imgpath =~ /(\.[^.]+)$/;
            my $dest = $roms->{$rom} . $ext;
            get_image("$baseurl$imgpath", "$dir/img/Named_Boxarts/$dest");
            $handled = 1;
            last;
          }
        }
        if(!$handled) {
          print "No boxart found :(\n";
        }
      } elsif($input =~ /^n$/i) {
        print IGNORE "$rom\n";
      } elsif($input =~ /^http/) {
        my ($ext) = $input =~ /(\.[^.]+)$/;
        my $dest = $roms->{$rom} . $ext;
        get_image($input, "$dir/img/Named_Boxarts/$dest");
      }
    } else {
      print "NO MATCH, url?: ";
      my $url = readline;
      chomp($url);
      if($url =~ /^http/) {
        my ($ext) = $url =~ /(\.[^.]+)$/;
        my $dest = $roms->{$rom} . $ext;
        get_image($url, "$dir/img/Named_Boxarts/$dest");
      } elsif($url =~ /^n$/i) {
        print IGNORE "$rom\n";
      }
    }
  } else {
    print $resp->status_line;
  }
  close(IGNORE);
}

sub get_image {
  my $url = shift;
  my $fname = shift;

  print "Downloading $url to $fname...\n";
  my $qurl = quotemeta($url);
  my $qfname = quotemeta($fname);

  print `curl -L -o $qfname $qurl`;

  if($fname !~ /\.png$/i) {
    my $pngname = $qfname;
    $pngname =~ s/\.[^.]+$/.png/;
    `convert $qfname $pngname`;
    `rm $qfname`;
  }
}

sub map_files {
  my @files = @_;
  my $files = {};
  foreach my $file(sort @files) {
    if($file =~ /\.(zip|png)$/ && ($file =~ /[,(](USA|Europe)[,)]/ || $file =~ /[,(]En[,)]/)) {
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
