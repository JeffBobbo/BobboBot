#!/usr/bin/perl

package BobboBot::proverb;

use warnings;
use strict;

use LWP::Simple;

sub run
{
  my $page = get('http://www.idefex.net/b3taproverbs/');
  if (!defined $page) {
    return 'Couldn\'t get the connect to the generator, maybe the server is down?';
  }
  if ($page =~ /Your random proverb is:<br\/><br\/><center><h2>((?:.|\r|\n)*?)<\/h2><\/center>/) {
    my $proverb = $1;
    $proverb =~ s/(?:\r|\n)//g;
    return $proverb;
  }
  return 'Couldn\'t find the proverb, maybe the page has changed?';
}

sub help
{
  return 'proverb - Returns a random proverb (of questionable sense), courtesy of http://www.idefex.net/b3taproverbs/';
}

sub auth
{
  return 0;
}

BobboBot::command::add('proverb', 'run', \&BobboBot::proverb::run);
BobboBot::command::add('proverb', 'help', \&BobboBot::proverb::help);
BobboBot::command::add('proverb', 'auth', \&BobboBot::proverb::auth);

1;
