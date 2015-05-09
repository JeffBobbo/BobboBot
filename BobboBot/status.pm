#!/usr/bin/perl

package BobboBot::status;

use warnings;
use strict;

use BobboBot::math;
use IO::Socket::INET; # sockets

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(autoStatus);


my $info = {
  'name'   => ['Liberty', 'Livetest', 'Test'],
  'addr'   => ['liberty.starsonata.com', 'livetest.starsonata.com', 'test.starsonata.com'],
  'port'   => ['3030', '3030', '3030'],
  'prot'   => ['tcp', 'tcp', 'tcp'],
  'start'  => [0, 0, 0],
  'status' => [1, 1, 1],
};

sub run
{
  my $server = shift(@{$_[0]->{arg}});

  if (!defined $server)
  {
    $server = 'liberty';
  }
  else
  {
    $server = lc($server);
  }

  if ($server ne 'all') # clean this up
  {
    for my $x (0..$#{$info->{name}})
    {
      if (lc($info->{name}[$x]) ne $server)
      {
        next;
      }
      if (statusCheck($info->{addr}[$x], $info->{port}[$x]))
      {
        if ($info->{start}[$x] != 0)
        {
          return "$info->{name}[$x] ($info->{addr}[$x]:$info->{port}[$x]) is running, uptime: " . humanTime(time() - $info->{start}[$x]);
        }
        return "$info->{name}[$x] ($info->{addr}[$x]:$info->{port}[$x]) is running.";
      }
      return "$info->{name}[$x] ($info->{addr}[$x]:$info->{port}[$x]) is down.";
    }
    return "It didn't work for some reason, did you give a correct option? (Liberty, Livetest, Test or all)";
  }
  my $result = "";
  for my $x (0..$#{$info->{name}})
  {
    if (statusCheck($info->{addr}[$x], $info->{port}[$x]))
    {
      $result .= "$info->{name}[$x] ($info->{addr}[$x]:$info->{port}[$x]) is running. ";
      next;
    }
    $result .= "$info->{name}[$x] ($info->{addr}[$x]:$info->{port}[$x]) is down. ";
  }
  return $result;
}

sub help
{
  return '!status [server] - Checks the server status of the given server. Options for server are liberty, livetest, test or all. Liberty is the default.';
}

# private function to check server status
sub statusCheck
{
  my $server = shift();
  my $port   = shift();

  my $socket = IO::Socket::INET->new(Proto => 'tcp', PeerPort => $port, PeerAddr => $server) or return 0;
  if ($socket)
  {
    $socket->shutdown(2);
    return 1;
  }
  return 0;
}

sub autoStatus # used by autoEvents in BobboBot.pl
{
  my $statStr = "Automatic update: ";
  for my $x (0..$#{$info->{name}})
  {
    if (statusCheck($info->{addr}[$x], $info->{port}[$x]))
    {
      if ($info->{status}[$x] == 0) {
        if (statusCheck($info->{addr}[$x], $info->{port}[$x]))
        {
          $statStr .= "$info->{name}[$x] ($info->{addr}[$x]:$info->{port}[$x]) is up. ";
          $info->{status}[$x] = 1;
          $info->{start}[$x] = time();
        }
        sleep(2);
      }
    }
    else
    {
      if ($info->{status}[$x] == 1)
      {
        if (!statusCheck($info->{addr}[$x], $info->{port}[$x]))
        {
          $statStr .=  "$info->{name}[$x] ($info->{addr}[$x]:$info->{port}[$x]) is down";
          if ($info->{start}[$x] != 0)
          {
            my $uptime = humanTime(time() - $info->{start}[$x]);
            $statStr .=  ", uptime: $uptime";
          }
          $statStr .= ". ";
          $info->{status}[$x] = 0;
        }
        sleep(2);
      }
    }
  }
  if (length($statStr) > 18)
  {
    return $statStr;
  }
  return "";
}

sub auth
{
  return 0;
}

BobboBot::command::add('status', 'run', \&BobboBot::status::run);
BobboBot::command::add('status', 'help', \&BobboBot::status::help);
BobboBot::command::add('status', 'auth', \&BobboBot::status::auth);

1;
