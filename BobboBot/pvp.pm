#!/usr/bin/perl

package BobboBot::pvp;

use warnings;
use strict;

use BobboBot::math;
use POSIX;

sub run
{
  my @arg = @{$_[0]->{arg}};

  my $myLevel  = shift(@arg);
  my $theirLevel = shift(@arg);
  my $df       = shift(@arg);
  my $war      = shift(@arg) || 0;
  my $emp      = shift(@arg) || 0;

  if (!defined($myLevel) || !defined($theirLevel) || !defined($df))
  {
    return 'Not enough arguements, check !help pvp for information.';
  }

  if (isNumber($myLevel) == 0 || isNumber($theirLevel) == 0 || isNumber($df) == 0)
  {
    return 'Invalid arguements, see !help pvp';
  }

  return 'You can\'t be less than level 0.' if ($myLevel < 0);
  return 'They can\'t be less than level 0.' if ($theirLevel < 0);
  return 'Danger Factor must be greater than 0.' if ($df < 0);


  use constant {
    WAR_MULT => 0.15,
    EMP_MULT => 0.30,
    EFFECTIVE_MAX => 2200
  };

  my $topLevel = min(max($myLevel, $theirLevel), EFFECTIVE_MAX);
  my $bottomLevel = min(min($myLevel, $theirLevel), EFFECTIVE_MAX);

  my $multiplier = 0.0;
  # df multiplier
  if ($df < 25)
  {
    $multiplier = 0.20;
  }
  elsif ($df < 75)
  {
    $multiplier = 0.35;
  }
  elsif ($df < 125)
  {
    $multiplier = 0.50;
  }
  else
  {
    $multiplier = 0.65;
  }

  # war multiplied
  if (!defined($war))
  {
    $war = 0;
  }
  if (lc($war) eq 'one-sided' || (isNumber($war) && boolValue($war) == 1))
  {
    $multiplier += WAR_MULT;
  }
  if (lc($war) eq 'mutual' || (isNumber($war) && $war == 2))
  {
    $multiplier += WAR_MULT;
  }

  # emp
  if (boolValue($emp) == 1)
  {
    $multiplier += EMP_MULT;
  }

  $multiplier = min($multiplier, 1.0);


  my $bottomAttackLevel = floor($topLevel * (1.0 - $multiplier));
  $bottomAttackLevel = max(0, min($bottomAttackLevel, floor($topLevel - $multiplier * 50.0)));
  my $upperLimit = 0.0;
  my $lowerLimit = 0.0;

  my $return = "";

  if ($myLevel > $theirLevel)
  {
    $lowerLimit = max(0, min($topLevel * (1.0 - $multiplier), $topLevel - $multiplier * 50.0));
    $upperLimit = min(EFFECTIVE_MAX, max($topLevel / (1.0 - $multiplier), $topLevel + $multiplier * 50.0));
  }
  else
  {
    $lowerLimit = max(0, min($bottomLevel * (1.0 - $multiplier), $bottomLevel - $multiplier * 50.0));
    $upperLimit = min(EFFECTIVE_MAX, max($bottomLevel / (1.0 - $multiplier), $bottomLevel + $multiplier * 50.0));
  }
  $lowerLimit = floor($lowerLimit);
  $upperLimit = floor($upperLimit);
  if ($bottomLevel < $bottomAttackLevel)
  {
    $return = 'Can\'t attack.';
  }
  else
  {
    $return = 'Can attack.';
  }
  $return .= ' Your PvP range is [' . commifyNumber($lowerLimit) . ", " . ($upperLimit < EFFECTIVE_MAX ? commifyNumber($upperLimit) : 'oo') . '].';
  return $return;
}

sub help
{
  return '!pvp (yourLevel) (theirLevel) (df) [war] [emp] - Calculates if you can attack someone of theirLevel based on your current danger factor (df) and war and emperor conditions. war and emp assume no, war can either be \'one-sided\' / \'1\' or \'mutual\' / \'2\'.';
}

sub auth
{
  return 0;
}

BobboBot::command::add('pvp', 'run', \&BobboBot::pvp::run);
BobboBot::command::add('pvp', 'help', \&BobboBot::pvp::help);
BobboBot::command::add('pvp', 'auth', \&BobboBot::pvp::auth);

1;
