#!/usr/bin/perl

package BobboBot::logger;

use warnings;
use strict;

use BobboBot::math;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(logEvent logMsg);

my $logdir = "logs"; # we'll place logs in here based on yyyy-mm-dd
mkdir($logdir, 0755) if (!-d $logdir);

sub logEvent
{
  my $msg     = shift();
  my $channel = shift();

  my (undef, undef, undef, $mday, $mon, $year) = localtime(time);
  $year += 1900;
  $mon += 1;

  my $logmsg = "[" . timestamp() . "] " . $msg;

  open(my $log, '>>', "$logdir/$year-$mon-$mday") or die "Couldn't open file to write log in log dir: $!\n";
  print $log $logmsg, "\n";
  close($log);

  return;
}

sub logMsg
{
  my $who   = shift();
  my $target = shift();
  my $msg    = shift();

  my (undef, undef, undef, $mday, $mon, $year) = localtime(time);
  $year += 1900;
  $mon += 1;
  my $logmsg = "[" . timestamp() . "] <$target:$who> $msg";

  open(my $log, '>>', "$logdir/$year-$mon-$mday") or die "Couldn't open file to write log in log dir: $!\n";
  print $log $logmsg, "\n";
  close($log);

  return;
}

1;
