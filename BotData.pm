#!/usr/bin/perl

package BotData;

use warnings;
use strict;

use JSON qw(decode_json encode_json);

our $global = '@global'; # the global key for global settings

sub new
{
  my $class = shift();
  my $file = shift();
  my $addPlayer = shift();
  my $self = {};

  bless($self, $class);
  $self->{file} = $file;
  $self->{json} = {};
  $self->{add} = $addPlayer;
  $self->load();
  return $self;
}

sub load
{
  my $self = shift();

  open(my $fh, '<', $self->{file}) or return 0;
  my @lines = <$fh>;
  close($fh);

  my $src = join('', @lines);
  $self->{json} = decode_json($src) if (length($src));
  $self->{json}{$global} = {} if (!defined $self->{json}{$global});
}

sub save
{
  my $self = shift();

  my $text = encode_json($self->{json});
  open(my $fh, '>', $self->{file}) or return 0;
  print $fh $text;
  close($fh);
  return 1;
}

sub getStat
{
  my $self = shift();

  my $stat = shift();
  my $who = shift(); # can be undef (for globals)

  if (defined $who)
  {
    $self->{json}{$who} = $self->{add}() if (!defined $self->{json}{$who});
    return $self->{json}{$who}{$stat};
  }
  else
  {
    $self->{json}{$global}{$stat} = 0 if (!defined $self->{json}{$global}{$stat});
    return $self->{json}{$global}{$stat};
  }
}

sub deltaStat
{
  my $self = shift();

  my $stat = shift();
  my $who = shift(); # can be undef (for globals)
  my $delta = shift() || 1;

  if (defined $who)
  {
    $self->{json}{$who} = $self->{add}() if (!defined $self->{json}{$who});
    if (!defined $self->{json}{$who}{$stat})
    {
      print 'Tried to change invalid stat: ' . $stat . "\n";
      return;
    }
    $self->{json}{$who}{$stat} += $delta;
  }
  else
  {
    $self->{json}{$global} = {} if (!defined $self->{json}{$global});
    $self->{json}{$global}{$stat} = 0 if (!defined $self->{json}{$global}{$stat});
    $self->{json}{$global}{$stat} += $delta;
  }
}

sub incStat
{
  my $self = shift();
  my $stat = shift();
  my $who = shift();
  $self->deltaStat($stat, $who, 1);
}

sub statList
{
  my $self = shift();

  my $what = shift();

  return sort(keys(%{$self->{json}{$what}})) if (defined $self->{json}{$what});
  return ();
}

sub printStats
{
  my $self = shift();

  my $player = shift();


  my @stats = $self->statList($player || $global);
  my $ret;
  if (defined $player)
  {
    return $player . ' has no stats!' if (@stats == 0);
    $ret = 'Stats for ' . $player . ': ';
  }
  else
  {
    return 'No global stats yet!' if (@stats == 0);
    $ret = 'Overall stats: ';
  }

  $ret .= $self->getStat($stats[0], $player) . ' ' . $stats[0] . ($self->getStat($stats[0], $player) != 1 ? (substr($stats[0], -1) eq 's' ? 'es' : 's') : '');
  for (my $i = 1; $i < @stats; $i++)
  {
    $ret .= ', ' . $self->getStat($stats[$i], $player) . ' ' . $stats[$i] . ($self->getStat($stats[$i], $player) != 1 ? (substr($stats[$i], -1) eq 's' ? 'es' : 's') : '');
  }
  return $ret . '.';
}

1;
