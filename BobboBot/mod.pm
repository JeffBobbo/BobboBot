#!/usr/bin/perl

package BobboBot::mod;

use warnings;
use strict;

use BobboBot::math;
use POSIX;

sub run
{
  my $flag = shift(@{$_[0]->{arg}});

  return 'Invalid flag.' if (!isNumber($flag));

  return "Flag must be at 1 or higher" if ($flag <= 0);

  my @modNames = qw(Angelic Reinforced Superintelligent Buffered Gyroscopic Forceful Overclocked Transcendental Superconducting Evil Workhorse Rewired Amplified Intelligent Docktastic Resonating Sleek Radioactive Amorphous Dynamic Scoped Extended Shielded Composite Miniaturized);
  my @modFlag = (0x1000000, 0x800000, 0x400000, 0x200000, 0x100000 , 0x80000 , 0x40000 , 0x20000, 0x10000, 0x8000 , 0x4000 , 0x2000, 0x1000, 0x800, 0x400, 0x200, 0x100, 0x80, 0x40, 0x20, 0x10, 0x8, 0x4, 0x2, 0x1);

  my $high = 0;
  for my $x (0..$#modFlag)
  {
    $high += $modFlag[$x];
  }

  if ($flag > $high) # make sure they provided a possible value
  {
    return "Error: The highest possible bitflag value is $high.";
  }

  my $result = "";

  for my $x (0..$#modNames)
  {
    my $value = $modFlag[$x];
    my $name = $modNames[$x];
    if (($flag-$value) >= 0)
    {
      if (length($result) > 0)
      {
        $result .= ", ";
      }
      $result .= "$name";
      $flag -= $value;
    }
  }
  if ($result ne '')
  {
    return "Your item has the following mods: $result.";
  }
  return 'Something went wrong calculating the mods.';
}

sub help
{
  return '!mod (bitflag) - Calculates the mods on an item from the bitflag saved in the inventory XML under the \'m\' attribute.';
}

sub auth
{
  return 0;
}

BobboBot::command::add('mod', 'run', \&BobboBot::mod::run);
BobboBot::command::add('mod', 'help', \&BobboBot::mod::help);
BobboBot::command::add('mod', 'auth', \&BobboBot::mod::auth);

1;
