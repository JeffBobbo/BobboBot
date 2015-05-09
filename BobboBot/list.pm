#!/usr/bin/perl

package BobboBot::list;

use warnings;
use strict;

sub run
{
  my @keys = sort(BobboBot::command::commandsList());
  my $list = "";
  if (@keys >= 1)
  {
    $list .= $keys[0];
    for (my $i = 1; $i < @keys; $i++)
    {
      $list .= ', ' . $keys[$i] . (BobboBot::command::commands()->{$keys[$i]}{auth}() ? '*' : '');
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
  return 0;
}

BobboBot::command::add('list', 'run', \&BobboBot::list::run);
BobboBot::command::add('list', 'help', \&BobboBot::list::help);
BobboBot::command::add('list', 'auth', \&BobboBot::list::auth);

1;
