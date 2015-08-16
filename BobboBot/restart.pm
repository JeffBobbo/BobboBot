#!/usr/bin/perl

package BobboBot::restart;

use warnings;
use strict;

use BobboBot::users;
sub run
{
  $main::cleanExit = 2;
  $main::irc->yield('shutdown', 'Be right back!');
  return "";
}

sub help
{
  return '!restart - Restars the bot.';
}

sub auth
{
  return accessLevel('op');
}

BobboBot::module::add('restart', 'run', \&BobboBot::restart::run);
BobboBot::module::add('restart', 'help', \&BobboBot::restart::help);
BobboBot::module::add('restart', 'auth', \&BobboBot::restart::auth);

1;
