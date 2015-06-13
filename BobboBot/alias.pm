#!/usr/bin/perl

package BobboBot::alias;

use warnings;
use strict;
use BobboBot::users;

use BobboBot::command;
use JSON qw(decode_json encode_json);

my $file = 'alias.json';
my $json;

sub load
{
  open (my $fh, '<', $file) or return 0;
  my @lines = <$fh>;
  close($fh);

  my $src = join('', @lines);
  $json = length($src) ? decode_json($src) : {};
  setAliases($json);
  return 1;
}

sub save
{
  return 0 if (!defined $json);

  my $text = encode_json($json);
  open(my $fh, '>', $file) or return 0;
  print $fh $text;
  close($fh);
  setAliases($json);
  return 1;
}

sub run
{
  # load config if unloaded
  load() if (!defined $json);

  my @args = @{$_[0]->{arg}};
  my $action = shift(@args);
  my $alias = shift(@args);
  my $target = shift(@args);

  if ($action eq 'set')
  {
    my $targetValid = isValidCommand($target);
    my $aliasValid = isValidCommand($alias);
    return $target . ' is unknown.' if ($targetValid == 0);
    return $target . ' is an alias.' if ($targetValid == 2);

    return $alias . ' is a command.' if ($aliasValid == 1);
    return $alias . ' is an alias already.' if ($aliasValid == 2);

    $json->{$alias} = $target;
    save();
    return 'Added alias ' . $alias . '.';
  }
  elsif ($action eq 'del')
  {
    my $aliasValid = isValidCommand($alias);
    return $alias . ' is unknown.' if ($aliasValid == 0);
    return $alias . ' is a command.' if ($aliasValid == 1);

    delete $json->{$alias};
    save();
    return 'Removed alias ' . $alias . '.';
  }
  else
  {
    my $pointee = lookupAlias($action);
    return 'Unknown alias: ' . $action . '.' if ($pointee eq $action);
    return $action . ' -> ' . $pointee . '.';
  }
}

sub help
{
  return '!alias - ';
}

sub auth
{
  return accessLevel('op');
}

BobboBot::command::add('alias', 'run', \&BobboBot::alias::run);
BobboBot::command::add('alias', 'help', \&BobboBot::alias::help);
BobboBot::command::add('alias', 'auth', \&BobboBot::alias::auth);

1;
