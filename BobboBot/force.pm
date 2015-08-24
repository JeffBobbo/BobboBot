#!/usr/bin/perl

package BobboBot::force;

use warnings;
use strict;

use BobboBot::users;
use BobboBot::status;

sub run
{
  return autoStatus();
}

sub help
{
  return '!force - Process automatic events instantly instead of waiting';
}

sub auth
{
  return accessLevel('op');
}

BobboBot::module::addCommand('force', 'run', \&BobboBot::force::run);
BobboBot::module::addCommand('force', 'help', \&BobboBot::force::help);
BobboBot::module::addCommand('force', 'auth', \&BobboBot::force::auth);

1;
