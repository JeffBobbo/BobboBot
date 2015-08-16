#!/usr/bin/perl

package BobboBot::module;

use warnings;
use strict;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(commands commandsList aliases aliasesList setAliases lookupAlias isValidCommand addEvent numEvents runEvents);

my $commands = {};
my $aliases = {};
my @autoEvents = ();

use constant {
  WHO => 0,
  WHERE => 1,
  FORM => 2,
  ARG => 3
};

sub add
{
  my $name = shift();
  my $which = shift();
  my $function = shift();

  return if ($which ne "run" && $which ne "help" && $which ne "auth");

  $commands->{$name}{$which} = $function;
}

sub commands
{
  return $commands;
}

sub commandsList
{
  return keys %{$commands};
}

sub setAliases
{
  $aliases = {};
  $aliases = shift() if (@_);
}

sub aliases
{
  return $aliases;
}

sub aliasesList
{
  return keys %{$aliases}
}

sub lookupAlias
{
  my $alias = shift();
  return aliases()->{$alias} || $alias; # if this isn't one, return what we gave
}

sub isValidCommand
{
  my $com = shift();

  return 2 if (aliases()->{$com});
  return 1 if (commands()->{$com});
  return 0;
}


# auto event stuff
sub addEvent
{
  my $event = {
    function => shift(),
    interval => shift() || 1
  };
  push(@autoEvents, $event);
}

sub runEvents
{
  for (my $i = 0; $i < @autoEvents; $i++)
  {
    my $now = time();
    my $event = $autoEvents[$i];

    if (!$event->{last} || $now - $event->{last} > $event->{interval})
    {
      my $string = $event->{function}();
      if (defined $string && length($string) > 0)
      {
        foreach my $chan (BobboBot::channels::channelList())
        {
          $main::irc->yield('privmsg', $chan, $string);
        }
      }
      $event->{last} = $now;
    }
  }
}

1;
