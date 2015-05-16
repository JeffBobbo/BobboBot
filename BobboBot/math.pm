#!/usr/bin/perl

package BobboBot::math;

use warnings;
use strict;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(min max isNumber boolValue discountPercent humanTime timestamp PC2Dec commifyNumber);

use POSIX;
use Time::HiRes;
use Scalar::Util qw(looks_like_number);

sub min
{
  my $l = 0;

  for (my $i = 0; $i < @_; $i++)
  {
    $l = $i if ($_[$i] < $_[$l]);
  }
  return $_[$l];
}

sub max
{
  my $h = 0;

  for (my $i = 0; $i < @_; $i++)
  {
    $h = $i if ($_[$i] > $_[$h]);
  }
  return $_[$h];
}

sub bound
{
  my $a = shift();
  my $min = shift();
  my $max = shift();
  return ($a < $min ? $min : ($a > $max ? $max : $a));
}

sub isNumber
{
  my $num = shift();
  if (!defined $num)
  {
    print STDERR "\$num was not defined in isNumber call\n";
    return 0;
  }
  $num =~ s/,_//g; #trim out commas and underscores
  return looks_like_number($num);
}

sub boolValue
{
  my $data = shift();
  if (!defined $data)
  {
    return 0;
  }
  if (lc($data) eq 'true' || lc($data) eq 'yes')
  {
    return 1;
  }
  if (isNumber($data))
  {
    return ($data > 0 ? 1 : 0);
  }
  return 0;
}

sub discountPercent
{
  my $buildQuant = min(shift, 1000); # max discount of 1k builds
  return 0.9 ** log10($buildQuant);
}

sub humanTime
{
  my $time = shift();
  $time = time() if (!defined $time);

  my $result = "";
  if (floor($time / (86400 * 7)))
  {
    my $val = floor($time / (86400 * 7));
    $result .= "$val week" . ($val > 1 ? "s" : "");
    $time = $time % (86400 * 7)
  }
  if (floor($time / 86400))
  {
    my $val = floor($time / 86400);
    if (length($result))
    {
      $result .= ", ";
    }
    $result .= "$val day" . ($val > 1 ? "s" : "");
    $time = $time % 86400;
  }
  if (floor($time / 3600))
  {
    my $val = floor($time / 3600);
    if (length($result))
    {
      $result .= ", "
    }
    $result .= "$val hour" . ($val > 1 ? "s" : "");
    $time = $time % 3600;
  }
  if (floor($time / 60))
  {
    my $val = floor($time / 60);
    if (length($result))
    {
      $result .= ", "
    }
    $result .= "$val minute" . ($val > 1 ? "s" : "");
    $time = $time % 60;
  }
  if ($time)
  {
    my $val = $time;
    if (length($result))
    {
      $result .= " and "
    }
    $result .= "$val second" . ($val > 1 ? "s" : "");
  }
  return $result;
}


sub timestamp
{
  my $when = shift();
  $when = time() if (!defined $when || $when == 0);

  my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime($when);
#  $year += 1900; # make year YYYY format
#  $mon  += 1; # mon range is 0..11
  $hour += 1 if ($isdst);

#  $mon  = '0' . $mon  if ($mon < 10);
#  $mday = '0' . $mday if ($mday < 10);
  $hour = '0' . $hour if ($hour < 10);
  $min  = '0' . $min  if ($min < 10);
  $sec  = '0' . $sec  if ($sec < 10);
  return $hour . ':' . $min . ':' . $sec;
}

sub PC2Dec
{
  my $percent = shift();
  $percent = substr($percent, 0, index($percent, '%'));
  return $percent / 100;
}

sub commifyNumber
{
  my $num = shift();

  my ($sign, $int, $frac) = ($num =~ /^([+-]?)(\d*)(.*)/);

  my $commified = (
    reverse scalar join ',',
    unpack '(A3)*',
    scalar reverse $int
  );
  return $sign . $commified . $frac;
}

1;
