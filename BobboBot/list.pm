#!/usr/bin/perl

package BobboBot::list;

use warnings;
use strict;
use BobboBot::users;

use BobboBot::command;

sub run
{
  my @keys = sort(commandsList());
  my $list = "";
  if (@keys >= 1)
  {
    $list .= $keys[0];
    for (my $i = 1; $i < @keys; $i++)
    {
      $list .= ', ' . $keys[$i] . (commands()->{$keys[$i]}{auth}() >= accessLevel('op') ? '*' : '');
    }
  }
  return 'Available commands: ' . $list . '. See !help [command] for more information.';
}

sub help
{
  return '!list - Returns a list of commands';
}

sub auth
{
  return accessLevel('utils');
}

BobboBot::command::add('list', 'run', \&BobboBot::list::run);
BobboBot::command::add('list', 'help', \&BobboBot::list::help);
BobboBot::command::add('list', 'auth', \&BobboBot::list::auth);

1;
