#!/usr/bin/perl

package BobboBot::core;

use warnings;
use strict;

use POSIX;

my $source = 'core.list';

sub run
{
  open(my $fh, '<', $source) or return 'Failed to open core list: ' . $1;
  my @lines = <$fh>;
  close($fh);

  if (@lines == 0)
  {
    return 'No cores!';
  }
  return $lines[floor(rand(@lines))];
}

sub help
{
  return '!core - Returns a quote from a Portal core';
}

sub auth
{
  return 0;
}

BobboBot::command::add('core', 'run', \&BobboBot::core::run);
BobboBot::command::add('core', 'help', \&BobboBot::core::help);
BobboBot::command::add('core', 'auth', \&BobboBot::core::auth);

1;
