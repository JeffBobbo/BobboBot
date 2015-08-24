#!/usr/bin/perl

package BobboBot::update;

use warnings;
use strict;

use BobboBot::users;

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
  return accessLevel('op');
}

BobboBot::module::addCommand('update', 'run', \&BobboBot::update::run);
BobboBot::module::addCommand('update', 'help', \&BobboBot::update::help);
BobboBot::module::addCommand('update', 'auth', \&BobboBot::update::auth);

1;
