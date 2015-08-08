#!/usr/bin/perl

package BobboBot::ud;

use warnings;
use strict;

use BobboBot::users;

use WebService::UrbanDictionary;
use WebService::UrbanDictionary::Term;
use WebService::UrbanDictionary::Term::Definition;

use URI::Encode qw(uri_encode);
sub run
{
  my $phase = join(' ', @{$_[0]->{arg}});

  if (!defined $phase || length($phase) == 0)
  {
    return 'Nothing to look up!';
  }

  my $ud = WebService::UrbanDictionary->new();
  print uri_encode($phase, {encode_reserved => 1}), "\n";
  my $result = $ud->request(uri_encode($phase, {encode_reserved => 1}));
  my @defs = $result->definition();

  my $best = 0;

  for (my $i = 1; $i < @defs; $i++)
  {
    if ($defs[$i]->{thumbs_up} - $defs[$i]->{thumbs_down} > $defs[$best]->{thumbs_up} - $defs[$best]->{thumbs_down})
    {
      $best = $i;
    }
  }

  # have to clean up the definition
  my $definition = $defs[$best]->{definition};

  if (!defined $definition || length($definition) == 0)
  {
    return 'No definitions found.';
  }

  $definition =~ s/[\n\r]+/ /g;

  if (length($definition) >= 300)
  {
    $definition = substr($definition, 0, 300) . '...';
  }

  my $ret = $defs[$best]->{word} . ': ' . $definition;

  my $last = substr($ret, -1);
  if ($last ne '.' && $last ne '!' && $last ne '?')
  {
    $ret .= '. Submitted by ';
  }
  elsif ($last eq ',')
  {
    $ret .= ' submitted by ';
  }
  else
  {
    $ret .= ' by ';
  }

  return $ret . $defs[$best]->{author} . ' -- ' . $defs[$best]->{permalink};
}

sub help
{
  return 'ud (phase)- Looks up a phase on Urban Dictionary';
}

sub auth
{
  return accessLevel('normal');
}

BobboBot::command::add('ud', 'run', \&BobboBot::ud::run);
BobboBot::command::add('ud', 'help', \&BobboBot::ud::help);
BobboBot::command::add('ud', 'auth', \&BobboBot::ud::auth);

1;
