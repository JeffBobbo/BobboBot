#!/usr/bin/perl

package BobboBot::roll;

use warnings;
use strict;

use BobboBot::math;
use POSIX;

sub run
{
  my $max = shift(@{$_[0]->{arg}});
  my $who = $_[0]->{who};

  if (!defined $max)
  {
    return 'Usage: !roll (max)';
  }
  if (!isNumber($max))
  {
    return 'Argument must be a number';
  }
  if ($max <= 1)
  {
    return 'Can\'t roll on less than a two';
  }
  if (floor($max) != $max)
  {
    return 'Can\'t roll on a fraction';
  }

  my $rolled = 1 + floor(rand($max+0.5));
  return $who . ' rolled a ' . commifyNumber($rolled) . ' out of ' . commifyNumber($max) . '.';
}

sub help
{
  return '!roll (max) - Roll for a random integer in the range [1, max].';
}

sub auth
{
  return 0;
}

BobboBot::command::add('roll', 'run', \&BobboBot::roll::run);
BobboBot::command::add('roll', 'help', \&BobboBot::roll::help);
BobboBot::command::add('roll', 'auth', \&BobboBot::roll::auth);

1;
