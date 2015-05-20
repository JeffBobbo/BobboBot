#!/usr/bin/perl

package BobboBot::access;

use warnings;
use strict;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(checkAccess);

use BobboBot::command;  # commands(), isValidCommand()
use BobboBot::users qw(levels);    # accessLevel, accessName, userIdentified, userAccess
use BobboBot::channels; # channelData()

my $default = 'normal'; #%BobboBot::users::levels{'normal'};

sub checkAccess
{
  my $nick = shift();
  my $targ = shift();

  if (defined channelData($targ) && channelData($targ)->{key} ne "")
  {
    return accessLevel('op');
  }
  return userIdentified($nick);
}

sub run
{
  my @arg = @{$_[0]->{arg}};

  my $where = $_[0]->{where};

  if (defined $arg[0])
  {
    my $what = $arg[0];
    if (isValidCommand($what) == 1)
    {
      return $what . ' requires at least level ' . accessName(commands()->{$what}{auth}()) . ' to use.';
    }
    return $what . '\'s access level: ' . accessName(userAccess($what)) . '.';
  }
  else
  {
    my $who = $_[0]->{who};
    return 'Your current access level is ' . accessName(checkAccess($who, $where)) . '.';
  }
}

sub help
{
  return ['!access [target] - Checks access level of target if provided, otherwise yourself.',
          '!access command - Retrieves the acccess level you need for a command.'];
}

sub auth
{
  return accessLevel('ignore'); # special case, so ignored people know
}

BobboBot::command::add('access', 'run', \&BobboBot::access::run);
BobboBot::command::add('access', 'help', \&BobboBot::access::help);
BobboBot::command::add('access', 'auth', \&BobboBot::access::auth);

1;
