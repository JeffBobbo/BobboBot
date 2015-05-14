#!/usr/bin/perl

package BobboBot::roulette;

use warnings;
use strict;

use POSIX;
use JSON qw(decode_json encode_json);
use List::MoreUtils qw(none); # array searching

my $chamber = floor(rand(6)) + 1;
my @players;

my $file = 'roulette.json';
my $json;

sub load
{
  open(my $fh, '<', $file) or return {};
  my @lines = <$fh>;
  close($fh);

  my $src = join('', @lines);
  return decode_json($src) if length($src);
  return {};
}

sub save
{
  return 0 if (!defined $json);

  my $text = encode_json($json);
  open(my $fh, '>', $file) or return 0;
  print $fh $text;
  close($fh);
  return 1;
}

sub addPlayer
{
  my $who = shift();
  $json->{$who} = {survive => 0, death => 0, play => 0};
}

sub getStat
{
  my $stat = shift();
  my $who = shift(); # can be undef (for reload)

  if (defined $who)
  {
    addPlayer($who) if (!defined $json->{$who});
    return $json->{$who}{$stat};
  }
  else
  {
    $json->{global} = {} if (!defined $json->{global});
    $json->{global}{$stat} = 0 if (!defined $json->{global}{$stat});
    return $json->{$stat};
  }
}
sub incStat
{
  my $stat = shift();
  my $who = shift(); # can be undef (for globals)

  if (defined $who)
  {
    addPlayer($who) if (!defined $json->{$who});
    return $json->{$who}{$stat}++;
  }
  else
  {
    $json->{'@global'} = {} if (!defined $json->{'@global'}); # cheap hack, using @ so there's no collisions
    $json->{'@global'}{$stat} = 0 if (!defined $json->{'@global'}{$stat});
    return $json->{$stat}++;
  }
}

sub statList
{
  my $what = shift();
  return keys %{$json->{$what}} if (defined $json->{$what});
  return ();
}

sub reload
{
  $chamber = floor(rand(6)) + 1;
  incStat('reload');
  undef(@players); # clear array
  return {type => 'ACTION', text => 'loads a single round and spins the chamber.'};
}

sub run
{
  $json = load() if (!defined $json);

  my @args = @{$_[0]->{arg}};
  if (defined $args[0] && $args[0] eq "stat")
  {
    my $player = $args[1] || undef;

    my @stats = statList($player || '@global');
    my $ret;
    if (defined $player)
    {
      return $player . ' has no stats!' if (@stats == 0);
      $ret = 'Stats for ' . $player . ': ';
    }
    else
    {
      return 'Uh-oh! No global stats!' if (@stats == 0);
      $ret = 'Overall stats: ';
    }

    @stats = sort(@stats);
    $ret .= getStat($stats[0], $player) . ' ' . $stats[0] . (getStat($stats[0], $player) != 1 ? 's' : '');
    for (my $i = 1; $i < @stats; $i++)
    {
      $ret .= ', ' . getStat($stats[$i], $player) . ' ' . $stats[$i] . (getStat($stats[$i], $player) != 1 ? 's' : '');
    }
    return $ret . '.';
  }

  if (index($_[0]->{where}, '#') == -1)
  {
    return ""; # do nothing if not in public
  }

  my $player = $_[0]->{who};

  $chamber--;
  my @ret;
  if ($chamber == 0)
  {
    foreach my $p (@players)
    {
      next if ($p eq $player);
      incStat('play', $p);
      incStat('survive', $p);
    }
    incStat('play', $player);
    incStat('death', $player);
    incStat('kill');
    save();
    push(@ret, 'BANG! ' . $player . ' has been shot!');
    push(@ret, reload());
  }
  else
  {
    incStat('click');
    push(@players, $player) if (none {$_ eq $player} @players);
    push(@ret, 'CLICK! Whose next?!');
  }
  return \@ret;
}

sub help
{
  return ['!roulette - Think you\'ve got good luck?',
          '!roulette stat [player] - Retrieve stats'];
}

sub auth
{
  return 0;
}

BobboBot::command::add('roulette', 'run', \&BobboBot::roulette::run);
BobboBot::command::add('roulette', 'help', \&BobboBot::roulette::help);
BobboBot::command::add('roulette', 'auth', \&BobboBot::roulette::auth);

1;
