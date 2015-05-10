#!/usr/bin/perl

package BobboBot::shutdown;

use warnings;
use strict;

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
  return 1;
}

BobboBot::command::add('shutdown', 'run', \&BobboBot::shutdown::run);
BobboBot::command::add('shutdown', 'help', \&BobboBot::shutdown::help);
BobboBot::command::add('shutdown', 'auth', \&BobboBot::shutdown::auth);

1;
