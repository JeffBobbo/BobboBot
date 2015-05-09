#!/usr/bin/perl

package BobboBot::kill;

use warnings;
use strict;

sub run
{
  $main::irc->yield('shutdown', 'Goodbye cruel world!!!');
  $main::restart = 0;
  return "";
}

sub help
{
  return '!kill - Shuts the bot down';
}

sub auth
{
  return 1;
}

BobboBot::command::add('kill', 'run', \&BobboBot::kill::run);
BobboBot::command::add('kill', 'help', \&BobboBot::kill::help);
BobboBot::command::add('kill', 'auth', \&BobboBot::kill::auth);

1;
