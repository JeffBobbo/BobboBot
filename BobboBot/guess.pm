#!/usr/bin/perl

package BobboBot::guess;

use warnings;
use strict;

use POSIX;
use List::MoreUtils qw(none); # array searching
use BobboBot::math;
use BobboBot::users;
use BotData;

my $number = pickNumber();
my $guesses = 0;

my @players;
my $file = 'data/guess.json';
my $data = BotData->new($file, \&addPlayer);

sub addPlayer
{
  return {play => 0, win => 0, lose => 0, guess => 0};
}

sub pickNumber
{
  return floor(rand(100)) + 1;
}

sub think
{
  $number = pickNumber();
  $data->incStat('thought');
  $data->save();
  undef(@players);
  $guesses = 0;
  return {type => 'ACTION', text => 'thinks of another number betwen 1 and 100.'};
}

sub run
{
  my @args = @{$_[0]->{arg}};
  if (defined $args[0] && ($args[0] eq "stat" || $args[0] eq "stats"))
  {
    my $player = $args[1] || undef;

    return $data->printStats($player);
  }

  if (index($_[0]->{where}, '#') == -1)
  {
    return ""; # do nothing if not in public
  }

  my ($player) = split('!', $_[0]->{who});
  my $guess =  shift(@args);

  if (!defined $guess || !isNumber($guess))
  {
    return 'Not a number';
  }
  if (floor($guess) != $guess)
  {
    return 'I only think of integers';
  }

  $guesses++;
  $data->incStat('guess', $player);
  push(@players, $player) if (none {$_ eq $player} @players);
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
    foreach my $p (@players)
    {
      $data->incStat('play', $p);
      next if ($p eq $player);
      $data->incStat('lose', $p);
    }
    $data->incStat('win', $player);

    return ['Well done, ' . $player . ', you guessed it! It took ' . $guesses . ' guesses to get it!', think()];
  }
}

sub help
{
  return ['!guess guess - Guess my number of 1 to 100!'.
          '!guess stat [player] - Retrieve game stats.'];
}

sub auth
{
  return accessLevel('normal');
}

BobboBot::command::add('guess', 'run', \&BobboBot::guess::run);
BobboBot::command::add('guess', 'help', \&BobboBot::guess::help);
BobboBot::command::add('guess', 'auth', \&BobboBot::guess::auth);

1;
