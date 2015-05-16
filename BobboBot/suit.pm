#!/usr/bin/perl

package BobboBot::suit;

use warnings;
use strict;

use BobboBot::math;
use POSIX;

use constant {
  CA_BONUS => 0.05,
  MAX_SUIT => 1.25
};

sub run
{
  my @arg = @{$_[0]->{arg}};

  my $conditions = {
    heavy => 0.5,
    low => 0.75,
    normal => 1.0,
    frozen => 0.5,
    blistering => 0.75,
    temperate => 1.0,
    gaseous => 0.5,
    noxious => 0.75,
    terran => 1.0
  };

  my @conditions = splice(@arg, 0, 3);

  my $suitability = 1.0;
  foreach my $condition (@conditions)
  {
    if ($conditions->{lc($condition)})
    {
      $suitability *= $conditions->{lc($condition)};
    }
    else
    {
      return 'Unrecognized planet condition: ' . $condition . '.';
    }
  }

  my $caLevel = shift(@arg) || 0;
  return 'Not a number for Colonial Administration level.' if (isNumber($caLevel) == 0);
  return 'Can\'t have a fraction of a level.' if (floor($caLevel) != $caLevel);

  $suitability = min(MAX_SUIT, $suitability * (1 + $caLevel * CA_BONUS));

  return 'Planet suitability: ' . floor($suitability * 100) . '%.';
}

sub help
{
  return '!suit (conditions) [CA] - Calculates planet suitability from conditions (heavy, low, normal, frozen, blistering, temperate, gaseous, noxious, terran) and Colonial Admin bonus.';
}

sub auth
{
  return 0;
}

BobboBot::command::add('suit', 'run', \&BobboBot::suit::run);
BobboBot::command::add('suit', 'help', \&BobboBot::suit::help);
BobboBot::command::add('suit', 'auth', \&BobboBot::suit::auth);

1;
