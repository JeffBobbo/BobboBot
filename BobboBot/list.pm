#!/usr/bin/perl

package BobboBot::list;

use warnings;
use strict;
use BobboBot::users;

use BobboBot::module;

sub run
{
  my @keys = commandsList();
  push(@keys, aliasesList());
  @keys = sort(@keys);
  my $list = "";
  if (@keys > 0)
  {
    my $com = isValidCommand($keys[0]) == 2 ? lookupAlias($keys[0]) : $keys[0];
    $list .= $keys[0] . (commands()->{$com}{auth}() >= accessLevel('op') ? '*' : isValidCommand($keys[0]) == 2 ? ' (> ' . lookupAlias($com) . ')' : '');
    for (my $i = 1; $i < @keys; $i++)
    {
      my $com = isValidCommand($keys[$i]) == 2 ? lookupAlias($keys[$i]) : $keys[$i];
      $list .= ', ' . $keys[$i] . (commands()->{$com}{auth}() >= accessLevel('op') ? '*' : isValidCommand($keys[$i]) == 2 ? ' (> ' . lookupAlias($com) . ')' : '');
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

BobboBot::module::addCommand('list', 'run', \&BobboBot::list::run);
BobboBot::module::addCommand('list', 'help', \&BobboBot::list::help);
BobboBot::module::addCommand('list', 'auth', \&BobboBot::list::auth);

1;
