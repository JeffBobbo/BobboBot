#!/usr/bin/perl

package BobboBot::restart;

use warnings;
use strict;

sub run
{
  $main::irc->yield('shutdown', 'Be right back!');
  $main::restart = 1;
  return "";
}

sub help
{
  return '!restart - Restars the bot.';
}

sub auth
{
  return 1;
}

BobboBot::command::add('restart', 'run', \&BobboBot::restart::run);
BobboBot::command::add('restart', 'help', \&BobboBot::restart::help);
BobboBot::command::add('restart', 'auth', \&BobboBot::restart::auth);

1;
