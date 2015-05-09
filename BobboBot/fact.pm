#!/usr/bin/perl

package BobboBot::fact;

use warnings;
use strict;

use LWP::Simple;

sub run
{
  my $page = get('http://randomfactgenerator.net/');
  if (!defined $page)
  {
    return 'Couldn\'t get the connect to the generator, maybe the server is down?';
  }
  if ($page =~ /<div id='z'>(.*?)<br\/>/) # this regex could use improving
  {
    return $1;
  }
  return 'Couldn\'t find the fact, maybe the page has changed?';
}

sub help
{
  return 'fact - Returns a random fact (of questionable truth), courtesy of http://randomfactgenerator.net/';
}

sub auth
{
  return 0;
}

BobboBot::command::add('fact', 'run', \&BobboBot::fact::run);
BobboBot::command::add('fact', 'help', \&BobboBot::fact::help);
BobboBot::command::add('fact', 'auth', \&BobboBot::fact::auth);

1;
