#!/usr/bin/perl

package BobboBot::guess;

use warnings;
use strict;

use POSIX;
use BobboBot::math;

my $number = floor(rand(100)) + 1;
my $guesses = 0;
sub think
{
  $number = floor(rand(100)) + 1;
  $guesses = 0;
  return {type => 'ACTION', text => 'thinks of another number betwen 1 and 100.'};
}

sub run
{
  if (index($_[0]->{where}, '#') == -1)
  {
    return ""; # do nothing if not in public
  }

  my $player = $_[0]->{who};
  my $guess =  shift(@{$_[0]->{arg}});

  if (!defined $guess || !isNumber($guess))
  {
    return 'Not a number';
  }
  if (floor($guess) != $guess)
  {
    return 'I only think of integers';
  }

  $guesses++;
  if ($guess < $number)
  {
    return 'Too low!';
  }
  elsif ($guess > $number)
  {
    return 'Too high!';
  }
  else
  {
    return ['Well done, ' . $player . ', you guessed it! It took ' . $guesses . ' guesses to get it!', think()];
  }
}

sub help
{
  return '!guess guess - Guess my number of 1 to 100!';
}

sub auth
{
  return 0;
}

BobboBot::command::add('guess', 'run', \&BobboBot::guess::run);
BobboBot::command::add('guess', 'help', \&BobboBot::guess::help);
BobboBot::command::add('guess', 'auth', \&BobboBot::guess::auth);

1;
