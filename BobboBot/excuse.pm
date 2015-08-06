#!/usr/bin/perl

package BobboBot::excuse;

use warnings;
use strict;

use BobboBot::users;
use POSIX;

sub run
{
  open(my $fh, '<', 'excuses.list');
  my @excuses = <$fh>;
  close($fh);

  my $i = floor(rand(@excuses));
  my $excuse = $excuses[$i];
  return $excuse;
}

sub help
{
  return 'excuse - Returns a random excuse, courtesy of http://pages.cs.wisc.edu/~ballard/bofh/';
}

sub auth
{
  return accessLevel('normal');
}

BobboBot::command::add('excuse', 'run', \&BobboBot::excuse::run);
BobboBot::command::add('excuse', 'help', \&BobboBot::excuse::help);
BobboBot::command::add('excuse', 'auth', \&BobboBot::excuse::auth);

1;
