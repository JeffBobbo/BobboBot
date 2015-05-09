#!/usr/bin/perl

package BobboBot::roulette;

use warnings;
use strict;

use POSIX;

my $chamber = floor(rand(6)) + 1;

sub reload
{
  $chamber = floor(rand(6)) + 1;
  return {type => 'ACTION', text => 'loads a single round and spins the chamber.'};
}

sub run
{
  if (index($_[0]->{where}, '#') == -1)
  {
    return ""; # do nothing if not in public
  }

  my $player = $_[0]->{who};

  $chamber--;
  my @ret;
  if ($chamber == 0)
  {
    push(@ret, 'BANG! ' . $player . ' has been shot!');
    push(@ret, reload());
  }
  else
  {
    push(@ret, 'CLICK! Whose next?!');
  }
  return \@ret;
}

sub help
{
  return '!roulette - Think you\'ve got good luck?';
}

sub auth
{
  return 0;
}

BobboBot::command::add('roulette', 'run', \&BobboBot::roulette::run);
BobboBot::command::add('roulette', 'help', \&BobboBot::roulette::help);
BobboBot::command::add('roulette', 'auth', \&BobboBot::roulette::auth);

1;
