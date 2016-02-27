#!/usr/bin/perl

package BobboBot::help;

use warnings;
use strict;

use BobboBot::math;
use BobboBot::users;
use POSIX;

sub run
{
  my $command = $_[0]->{arg}[0];

  if (!defined $command)
  {
    return BobboBot::module::commands()->{'list'}{run}(@_); # hard coded, slightly eww
  }
  if (BobboBot::module::isValidCommand($command) == 0)
  {
    return 'Unknown command: ' . $command .  ".";
  }
  return BobboBot::module::commands()->{BobboBot::module::lookupAlias($command)}{help}(@_);
}

sub help
{
  return '!help [command] - Get command specific help';
}

sub auth
{
  return accessLevel('utils');
}

BobboBot::module::addCommand('help', 'run', \&BobboBot::help::run);
BobboBot::module::addCommand('help', 'help', \&BobboBot::help::help);
BobboBot::module::addCommand('help', 'auth', \&BobboBot::help::auth);

1;
