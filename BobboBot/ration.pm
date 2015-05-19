#!/usr/bin/perl

package BobboBot::ration;

use warnings;
use strict;

use BobboBot::math;
use BobboBot::users;
use POSIX;

sub run
{
  my $workers = shift(@{$_[0]->{arg}}) || "0";
  if (!isNumber($workers))
  {
    return "Invalid number of workers.";
  }
  if ($workers <= 0)
  {
    return "No workers eat no rations!";
  }
  my $consumption = $workers * 0.6;
  my $factories = ceil($consumption / 3600 * 12);
  my $hydroponics = ceil($workers / 300);


  my $result = commifyNumber($workers) . ' workers consume ' . commifyNumber($consumption) . ' rations every hour.';
  if ($factories > 0)
  {
    $result .= ' This requires at least ' . commifyNumber($factories) . ' MRE Factor' . ($factories == 1 ? 'y' : 'ies') . ' and ' . commifyNumber($hydroponics) . ' hydroponic' . ($hydroponics != 1 ? 's' : '') . ' to support.';
  }
  return $result;
}

sub help
{
  return '!rations (num) - Calculates the ration consumption of \'num\' workers and the amount of MRE Factories and Hydroponics required to support that.'
}

sub auth
{
  return accessLevel('utils');
}

BobboBot::command::add('ration', 'run', \&BobboBot::ration::run);
BobboBot::command::add('ration', 'help', \&BobboBot::ration::help);
BobboBot::command::add('ration', 'auth', \&BobboBot::ration::auth);

1;
