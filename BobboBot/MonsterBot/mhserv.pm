#!/usr/bin/perl

package BobboBot::mhserv;

use warnings;
use strict;

use BobboBot::users;
use Switch;
use POSIX qw(:errno_h mkfifo);
use Fcntl;

my $lookup = {
  ULES00318 => 'MHF',
  ULES00851 => 'MHF2',
  ULUS10391 => 'MHFU',
  ULES01213 => 'MHFU',
  ULJM05800 => 'MHP3rd'
};

my $path = "../AdhocServerPro/pipe";
my $rfd = '';

mkfifo($path, 0666);
sysopen(my $pd, $path, O_NONBLOCK|O_RDONLY) or die "Can't open pipe: $!\n";

sub readPipe
{
  my $buf;
  my $bytes = sysread($pd, $buf, 1024);
  if (!defined $bytes)
  {
    if ($! != EAGAIN)
    {
      $main::irc->yield('privmsg', '#bottest', "ERROR: Pipe read failed: $!");
    }
  }
  else
  {
    my @queue = split("\0", $buf);
    foreach my $message (@queue)
    {
      foreach my $channel (BobboBot::channels::channelList())
      {
        switch ($message)
        {
          case 'START'
          {
            $main::irc->yield('privmsg', $channel, '[Ad-Hoc Server] Server started');
          }
          case 'STOP'
          {
            $main::irc->yield('privmsg', $channel, '[Ad-Hoc Server] Server stopped');
          }
          else
          {
            my @toks = split(':', $message); # who, what, game, room
            my $who = shift(@toks);
            my $action = shift(@toks) eq 'JOIN' ? 'joined' : 'left';
            my $game = shift(@toks);
            $game = $lookup->{$game} || $game;
            my $room = substr(shift(@toks), -3) + 1;
            $main::irc->yield('privmsg', $channel, '[Ad-Hoc Server] ' . $who . ' ' . $action . ' room ' . $room . ' (' . $game . ')');
          }
        }
      }
    }
  }
#  close($pd);
}

sub run
{
  readPipe();
  return "";
}

sub help
{
  return 'mhserv - Automatic module that tracks MHFU and MHP3rd states';
}

sub auth
{
  return accessLevel('normal');
}

#BobboBot::command::add('mhserv', 'run', \&BobboBot::mhserv::run);
#BobboBot::command::add('mhserv', 'help', \&BobboBot::mhserv::help);
#BobboBot::command::add('mhserv', 'auth', \&BobboBot::mhserv::auth);
BobboBot::command::addEvent(\&BobboBot::mhserv::readPipe);


1;
