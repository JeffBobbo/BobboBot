#!/usr/bin/perl

package BobboBot::update;

use warnings;
use strict;

sub run
{
  if (system('git pull') == 0)
  {
    return "Update successful";
  }
  return "Failed to update";
}

sub help
{
  return '!update - Updates the bot.';
}

sub auth
{
  return 1;
}

BobboBot::command::add('update', 'run', \&BobboBot::update::run);
BobboBot::command::add('update', 'help', \&BobboBot::update::help);
BobboBot::command::add('update', 'auth', \&BobboBot::update::auth);

1;
