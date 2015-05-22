#!/usr/bin/perl

package BobboBot::quote;

use warnings;
use strict;

use BobboBot::users;

use POSIX;

my $source = 'quote.list';

sub add
{
  my $who = shift();
  my $where = shift();
  my $author = shift();
  my $quote = shift();

  if (checkAccess($who, $where) < accessLevel('op'))
  {
    return 'Permission denied.';
  }

  my $entry = "";
  if ($author ne 'NO_AUTH')
  {
    $entry .= '<' . $author . '> '
  }
  $entry .= $quote;

  open(my $fh, '>>', $source) or return 'Failed to open quote list: ' . $!;
  print $fh $entry . "\n";
  close($fh);

  return 'Added "<' . $author . '> ' . $quote . '" to the list.';
}

sub run
{
  my @arg = @{$_[0]->{arg}};

  my $action = shift(@arg);
  if (defined $action && $action eq 'add')
  {
    my $author = shift(@arg);
    my $quote = join(' ', @arg);
    return add($_[0]->{who}, $_[0]->{where}, $author, $quote);
  }
  else
  {
    open(my $fh, '<', $source) or return 'Failed to open quote list: ' . $!;
    my @lines = <$fh>;
    close($fh);

    if (@lines == 0)
    {
      return 'No quotes!';
    }
    return $lines[floor(rand(@lines))];
  }
}

sub help
{
  return '!quote [add nick quote] - Retrieve a quote from the list, or add one (requires auth)';
}

sub auth
{
  return accessLevel('normal');
}

BobboBot::command::add('quote', 'run', \&BobboBot::quote::run);
BobboBot::command::add('quote', 'help', \&BobboBot::quote::help);
BobboBot::command::add('quote', 'auth', \&BobboBot::quote::auth);

1;
