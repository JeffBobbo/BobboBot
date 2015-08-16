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

BobboBot::module::add('force', 'run', \&BobboBot::force::run);
BobboBot::module::add('force', 'help', \&BobboBot::force::help);
BobboBot::module::add('force', 'auth', \&BobboBot::force::auth);

1;
