#!/usr/bin/perl

package BobboBot::users;

use warnings;
use strict;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(userEvent readUsers writerUsers checkUsers hasAuth);

my @auth; # list from file
my @ident; # those in @auth and ID'd

sub readUsers
{
  my $file = shift();

  open(my $fh, '<', $file) or return;
  while (<$fh>)
  {
    chomp();
    push(@auth, $_);
  }
  close($fh);
}

sub writeUsers
{
  my $file = shift();

  open(my $fh, '>', $file) or return;
  foreach my $user (@auth)
  {
    print $fh $user . "\n";
  }
  close($fh);
}

sub checkUsers
{
  foreach my $user (@auth)
  {
    $main::irc->yield('who', $user);
  }
}

sub userEvent
{
  my $nick = shift();
  my $what = shift();
  my $extra = shift();

  my $id = -1; # find if we already have him
  for my $i (0..$#ident)
  {
    if ($ident[$i] eq $nick)
    {
      $id = $i;
      last;
    }
  }

  if ($what eq 'WHO')
  {
    if ($extra =~ /r/)
    {
      push(@ident, $nick) if ($id == -1);
    }
    else
    {
      splice(@ident, $nick) if ($id != -1);
    }
  }
  if ($what eq 'QUIT' && $id != -1)
  {
    splice(@ident, $id, 1);
  }
  if ($what eq 'NICK' && $id != -1)
  {
    my $nid = -1; # make sure the new nick is valid
    for my $i (0..$#ident)
    {
      if ($ident[$i] eq $extra)
      {
        $nid = $i;
        last;
      }
    }
    $ident[$id] = $extra if ($nid != -1);
  }
}

sub hasAuth
{
  my $nick = shift();

  foreach my $dude (@ident)
  {
    return 1 if ($nick eq $dude);
  }
  return 0;
}

1;
