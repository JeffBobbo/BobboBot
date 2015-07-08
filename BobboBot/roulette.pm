#!/usr/bin/perl

package BobboBot::roulette;

use warnings;
use strict;

use POSIX;
use List::MoreUtils qw(none); # array searching
use BotData;
use BobboBot::users;

my $chamber = load();

my @players;
my $file = 'data/roulette.json';
my $data = BotData->new($file, \&addPlayer);

sub addPlayer
{
  return {survive => 0, death => 0, game => 0, click => 0};
}

sub load
{
  return floor(rand(6)) + 1;
}

sub reload
{
  $chamber = load();
  $data->incStat('reload');
  $data->save();
  undef(@players); # clear array
  return {type => 'ACTION', text => 'loads a single round and spins the chamber.'};
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

  $chamber--;
  if ($chamber == 0)
  {
    foreach my $p (@players)
    {
      next if ($p eq $player);
      $data->incStat('game', $p);
      $data->incStat('survive', $p);
    }
    $data->incStat('game', $player);
    $data->incStat('death', $player);
    $data->incStat('kill');

    return ['BANG! You\'ve been shot!', reload()];
  }
  else
  {
    $data->incStat('click');
    $data->incStat('click', $player);
    push(@players, $player) if (none {$_ eq $player} @players);
    return 'CLICK! Who\'s next?!';
  }
}

sub help
{
  return ['!roulette - Think you\'ve got good luck?',
          '!roulette stat [player] - Retrieve game stats.'];
}

sub auth
{
  return accessLevel('normal');
}

BobboBot::command::add('roulette', 'run', \&BobboBot::roulette::run);
BobboBot::command::add('roulette', 'help', \&BobboBot::roulette::help);
BobboBot::command::add('roulette', 'auth', \&BobboBot::roulette::auth);

1;
