#!/usr/bin/perl

package BobboBot::module;

use warnings;
use strict;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(loadModules commands commandsList aliases aliasesList setAliases lookupAlias isValidCommand addEvent runEvent);

my $commands = {};
my $aliases = {};

use JSON;

sub loadModules
{
  my $file = shift() || 'modules.json';

  my $text = '';
  if (open(my $fh, '<', $file))
  {
    my @lines = <$fh>;
    close($fh);
    $text = join('', @lines);
  }

  my $json = decode_json($text) || {};

  moduleTree($json);
}

sub moduleTree
{
  my $json = shift();
  my $path = shift() || '';

  if (ref($json) eq 'HASH')
  {
    my @keys = keys %{$json};
    foreach my $key (@keys)
    {
      my $npath = $path . $key;
      moduleTree($json->{$key}, $npath . '/');
    }
  }
  if (ref($json) eq 'ARRAY')
  {
    foreach my $e (@{$json})
    {
      my $mod = $path . $e . '.pm';
      require $mod;
    }
  }
}

sub addCommand
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

# event stuff
my $events = {
  LOAD   => [], # after modules are require'd
#  UNLOAD => [], # when unloaded ?
  CONNECT    => [], # when connection to IRCd is made
  DISCONNECT => [], # when disconnected
  AUTO => [],

  START   => [],
  STOP    => [],
  RESTART => [],
};

sub addEvent
{
  my $type = shift();
  my $fn   = shift();
  my $opt  = shift();

  if (!$events->{$type})
  {
    die "Tried to register for unknown event: " . $type . "\n";
  }

  push(@{$events->{$type}}, {function => $fn, opt => $opt});
}

use Data::Dumper;

sub runEvent
{
  my $type = shift();
  my $data = shift(); # any extra data

  my @toRun = @{$events->{$type}};

  if ($type eq 'START')
  {
    print Dumper($events->{$type});
  }

  for (my $i = 0; $i < @toRun; $i++)
  {
    my $now = time();
    my $event = $toRun[$i];
    if ($type ne 'AUTO' || (!$event->{last} || $now - $event->{last} > $event->{opt}))
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
