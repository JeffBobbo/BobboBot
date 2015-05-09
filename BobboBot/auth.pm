#!/usr/bin/perl

package BobboBot::auth;

use warnings;
use strict;

use BobboBot::users;
use BobboBot::channels;

sub check
{
  my $nick = shift();
  my $targ = shift();

  if (defined channelData($targ) && channelData($targ)->{key} ne "")
  {
    return 1;
  }

  if (hasAuth($nick))
  {
    return 1;
  }

  return 0;
}

sub run
{
  my @arg = @{$_[0]->{arg}};

  if (check($_[0]->{who}, $_[0]->{where}))
  {
    return 'You have authorization';
  }
  return 'Respect my authoritah!';
}

sub help
{
  return '!auth - Checks if you have authorization';
}

sub auth
{
  return 0;
}

BobboBot::command::add('auth', 'run', \&BobboBot::auth::run);
BobboBot::command::add('auth', 'help', \&BobboBot::auth::help);
BobboBot::command::add('auth', 'auth', \&BobboBot::auth::auth);

1;
