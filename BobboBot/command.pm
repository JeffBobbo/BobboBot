#!/usr/bin/perl

package BobboBot::command;

use warnings;
use strict;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(commands list isValidCommand commandsList);

our $commands = {};

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

  if ($which ne "run" && $which ne "help" && $which ne "auth")
  {
    return;
  }

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

sub isValidCommand
{
  my $com = shift();

  foreach my $key (commandsList())
  {
    if ($com eq $key)
    {
      return 1;
    }
  }
  return 0;
}

1;
