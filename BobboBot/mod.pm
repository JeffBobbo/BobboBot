#!/usr/bin/perl

package BobboBot::mod;

use warnings;
use strict;

use BobboBot::math;
use BobboBot::users;
use POSIX;

sub run
{
  my $flag = shift(@{$_[0]->{arg}});

  return 'Invalid flag.' if (!isNumber($flag));

  return "Flag must be at 1 or higher" if ($flag <= 0);

  my @modNames = qw(Miniaturized Composite Shielded Extended Scoped Dynamic Amorphous Radioactive Sleek Resonating Docktastic Intelligent Amplified Rewired Workhorse Evil Superconducting Transcendental Overclocked Forceful Gyroscopic Buffered Superintelligent Reinforced Angelic);

  my $high = 0;
  for (my $i = 0; $i < @modNames; $i++)
  {
    $high |= (1 << $i);
  }

  return "Error: The highest possible bitflag value is $high." if ($flag > $high); # make sure they provided a possible value

  my $result = "";

  for (my $i = 0; $i < @modNames; $i++)
  {
    my $name = $modNames[$i];
    if ($flag & (1 << $i))
    {
      $result .= ", " if (length($result) > 0);
      $result .= $name;
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
  return accessLevel('normal');
}

BobboBot::command::add('mod', 'run', \&BobboBot::mod::run);
BobboBot::command::add('mod', 'help', \&BobboBot::mod::help);
BobboBot::command::add('mod', 'auth', \&BobboBot::mod::auth);

1;
