#!/usr/bin/perl

package BobboBot::shutdown;

use warnings;
use strict;

use BobboBot::users;

sub run
{
  $main::cleanExit = 1;
  $main::irc->yield('shutdown', 'Goodbye cruel world!!!');
  return "";
}

sub help
{
  return '!shutdown - Shuts the bot down';
}

sub auth
{
  return accessLevel('op');
}

BobboBot::command::add('shutdown', 'run', \&BobboBot::shutdown::run);
BobboBot::command::add('shutdown', 'help', \&BobboBot::shutdown::help);
BobboBot::command::add('shutdown', 'auth', \&BobboBot::shutdown::auth);

1;
