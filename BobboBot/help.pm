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
    return BobboBot::command::commands()->{'list'}{run}(@_); # hard coded, slightly eww
  }
  if (!defined BobboBot::command::commands()->{$command})
  {
    return 'Unknown command: ' . $command .  ".";
  }
  return BobboBot::command::commands()->{$command}{help}(@_);
}

sub help
{
  return '!help [command] - Get command specific help';
}

sub auth
{
  return accessLevel('utils');
}

BobboBot::command::add('help', 'run', \&BobboBot::help::run);
BobboBot::command::add('help', 'help', \&BobboBot::help::help);
BobboBot::command::add('help', 'auth', \&BobboBot::help::auth);

1;
