#!/usr/bin/perl

package BobboBot::access;

use warnings;
use strict;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(checkAccess);

use BobboBot::module;  # commands(), isValidCommand()
use BobboBot::users;    # accessLevel, accessName, userIdentified, userAccess
use BobboBot::channels; # channelData()

sub checkAccess
{
  my $who = shift();
  my $targ = shift();

  if (defined channelData($targ) && channelData($targ)->{key} ne "")
  {
    return accessLevel('op');
  }
  return userAccess($who); # if we have full user info, use that
}

sub run
{
  my @arg = @{$_[0]->{arg}};

  my $where = $_[0]->{where};

  if (@arg == 0)
  {
    my $who = $_[0]->{who};
    return 'Your current access level is ' . accessName(checkAccess($who, $where)) . '.';
  }
  elsif (@arg == 1)
  {
    my $what = $arg[0];
    if (isValidCommand($what) == 1)
    {
      return $what . ' requires at least level ' . accessName(commands()->{$what}{auth}()) . ' to use.';
    }
    elsif ($what eq 'levels')
    {
      my $ret = 'Access levels: ';
      my $levels = BobboBot::users::levels();
      my @keys = sort { $levels->{$a} <=> $levels->{$b} or lc($a) cmp lc($b) } keys $levels;

      return 'No access levels.' if (@keys == 0); # should never happen
      $ret .= $keys[0] . ' (' . $levels->{$keys[0]} . ')';
      for (my $i = 1; $i < @keys; $i++)
      {
        $ret .= ', ' . $keys[$i] . ' (' . $levels->{$keys[$i]} . ')';
      }
      return $ret . '.';
    }
    return $what . '\'s access level: ' . accessName(userAccess($what)) . '.';
  }
  elsif (@arg == 3)
  {
    return "Permission denied." if (checkAccess($_[0]->{who}, $where) < accessLevel('op'));

    my $action = $arg[0];
    my $user = $arg[1];
    my $level = $arg[2];

    my $ret = modifyAccess($user, $level, $action);

    return $ret || 'Saved.';
  }
  return 'Not sure what you wanted to do.';
}

sub help
{
  if (checkAccess($_[0]->{who}, $_[0]->{where}))
  {
    return ['!access [target] - Checks access level of target if provided, otherwise yourself.',
            '!access command - Retrieves the acccess level you need for a command.',
            '!access levels - Retrieves the list of access levels.',
            '!access set nick[!name@host] level - Add or change this person.',
            '!access del nick[!name@host] level - Remove this person.'];
  }
  else
  {
    return ['!access [target] - Checks access level of target if provided, otherwise yourself.',
            '!access command - Retrieves the acccess level you need for a command.',
            '!access levels - Retrieves the list of access levels.'];
  }
}

sub auth
{
  return accessLevel('ignore'); # special case, so ignored people know
}

BobboBot::module::addCommand('access', 'run', \&BobboBot::access::run);
BobboBot::module::addCommand('access', 'help', \&BobboBot::access::help);
BobboBot::module::addCommand('access', 'auth', \&BobboBot::access::auth);

1;
