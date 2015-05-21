#!/usr/bin/perl

package BobboBot::users;

use warnings;
use strict;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(userEvent readUsers writeUsers checkUsers userAccess userIdentified accessLevel accessName);


my $levels = {
  ignore => -2,
  utils  => -1,
  normal => 0,
  op     => 1
};

my $default = 'utils';
my $access = {}; # list from file
my @ident; # those who're ID'd

sub readUsers
{
  my $file = shift();

  open(my $fh, '<', $file) or die "Couldn't open file: $!\n";
  while (<$fh>)
  {
    chomp();
    my ($who, $level) = split(': ');
    $access->{$who} = accessLevel($level);
  }
  close($fh);
}

sub writeUsers
{
  my $file = shift();

  open(my $fh, '>', $file) or die "Couldn't open file: $!\n";
  foreach my $who (keys %{$access})
  {
    print $fh $who . ': ' . $access->{$who} . "\n";
  }
  close($fh);
}

sub checkUsers
{
  foreach my $who (keys %{$access})
  {
    $main::irc->yield('who', $who);
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

sub userIdentified
{
  my $nick = shift();

  foreach my $dude (@ident)
  {
    if ($nick eq $dude)
    {
      return $access->{$nick} if ($access->{$nick});
    }
  }
  return $levels->{$default};
}

sub userAccess
{
  my $nick = shift();

  if ($access->{$nick})
  {
    return $access->{$nick};
  }
  return $levels->{$default};
}

sub accessLevel
{
  my $level = shift();

  return defined $levels->{$level} ? $levels->{$level} : undef;
}

sub accessName
{
  my $level = shift();

  foreach my $key (keys %{$levels})
  {
    return $key if ($levels->{$key} == $level);
  }
  return 'Unknown access level: ' . $level;
}

1;
