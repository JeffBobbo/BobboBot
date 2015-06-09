#!/usr/bin/perl

package BobboBot::users;

use warnings;
use strict;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(userEvent readUsers writeUsers checkUsers userAccess userIdentified modifyAccess accessLevel accessName);


my $levels = {
  ignore => -2,
  utils  => -1,
  normal => 0,
  op     => 1
};

my $default = 'normal';
my $access = {}; # list from file
my @ident; # those who're ID'd
my $file = 'access.conf';

sub readUsers
{
  open(my $fh, '<', $file) or return "Couldn't open file: $!\n";
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
  open(my $fh, '>', $file) or return "Couldn't open file: $!\n";
  foreach my $who (keys %{$access})
  {
    print $fh $who . ': ' . accessName($access->{$who}) . "\n";
  }
  close($fh);
  return undef;
}

sub checkUsers
{
  foreach my $who (keys %{$access})
  {
    next if (index($who, '!') != -1); # only check the nickserv entries
    $main::irc->yield('who', $who);
  }
}

sub userEvent
{
  my $who = shift();
  my $what = shift();
  my $extra = shift();

  my $id = -1; # find if we already have him
  for my $i (0..$#ident)
  {
    if ($ident[$i] eq $who)
    {
      $id = $i;
      last;
    }
  }

  if ($what eq 'WHO')
  {
    if ($extra =~ /r/)
    {
      push(@ident, $who) if ($id == -1);
    }
    else
    {
      splice(@ident, $id, 1) if ($id != -1);
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
  my $who = shift();

  foreach my $dude (@ident)
  {
    if (userMatch($who, $dude))
    {
      return $access->{$dude} if ($access->{$dude});
    }
  }
  return undef;
}

sub userMatch
{
  my $user = shift();
  my $dude = shift();

  $user .= '!*' if (index($user, '!') == -1); # if there's no username, add it
  $user .= '@*' if (index($user, '@') == -1); # if there's no hostmask, add it
  $dude .= '!*' if (index($dude, '!') == -1);
  $dude .= '@*' if (index($dude, '@') == -1);

  #regexify
  $user =~ s/\?/./g;
  $user =~ s/\*/.*/g;
  $dude =~ s/\?/./g;
  $dude =~ s/\*/.*/g;

  $dude = '^' . $dude . '$'; # anchors to enforce a full match

  return $user =~ $dude; # test!
}

sub userAccess
{
  my $who = shift();

  foreach my $dude (keys %{$access})
  {
    if ($dude !~ /.+!.+@.+/)
    {
      my $idd = userIdentified($who);
      return $idd if (defined $idd);
    }
    else
    {
      if (userMatch($who, $dude))
      {
        return $access->{$dude} if ($access->{$dude});
      }
    }
  }
  return $levels->{$default};
}

sub modifyAccess
{
  my $user = shift();
  my $level = shift();
  my $action = shift();

#  return 'Invalid user, format: nick!user@mask.' if ($user !~ /.+!.+@.+/);
  return 'Unknown level.' if (!defined accessLevel($level));
  return 'Invalid action, ' . $action . '.' if ($action ne 'set' && $action ne 'del');

  if ($action eq 'del')
  {
    delete $access->{$user};
  }
  elsif ($action eq 'set')
  {
    $access->{$user} = accessLevel($level);
  }

  return writeUsers();
}

sub accessLevel
{
  my $name = shift();

  return defined $levels->{$name} ? $levels->{$name} : undef;
}

sub accessName
{
  my $level = shift();

  foreach my $key (keys %{$levels})
  {
    return $key if ($levels->{$key} == $level);
  }
  return undef;
}

sub levels
{
  return $levels;
}

1;
