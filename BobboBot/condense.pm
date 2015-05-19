#!/usr/bin/perl

package BobboBot::condense;

use warnings;
use strict;

use BobboBot::math;
use BobboBot::users;
use POSIX;

sub run
{
  my @arg = @{$_[0]->{arg}};
  my $destination = shift(@arg);

  my $augRef = {
    MINOR => 0x01,
    BASIC => 0x02,
    STD   => 0x04,
    GOOD  => 0x08,
    EXC   => 0x10,
    SUP   => 0x20,
    ULT   => 0x40,
  };
  my $augCount = {
    Minor => shift(@arg) || 0,
    Basic => shift(@arg) || 0,
    Std   => shift(@arg) || 0,
    Good  => shift(@arg) || 0,
    Exc   => shift(@arg) || 0,
    Sup   => shift(@arg) || 0,
    Ult   => shift(@arg) || 0,
  };
  if (!defined $augRef->{(uc($destination))})
  {
    return "Augmenter type $destination does not seem to exist. Maybe you included a '.'?";
  }
  foreach my $level (keys %{$augCount})
  {
    if (!isNumber($augCount->{$level}))
    {
      return 'Invalid quantity for aug type ' . $level;
    }
    if (floor($augCount->{$level}) != $augCount->{$level})
    {
      return 'Can\'t have a fraction of an augmenter';
    }
    if ($augCount->{$level} > 10000) # can't condense this much
    {
      return 'Can\'t condense that much.';
    }
  }
  my $totalPoints = 0;

  my @levels = sort {$augRef->{uc($a)} <=> $augRef->{uc($b)}} keys %{$augCount}; # sort into order

  for (my $i = 0; $i < @levels - 1; $i++)
  {
    my $level = $levels[$i];
    if ($augRef->{uc($level)} >= $augRef->{uc($destination)})
    {
      next;
    }
    while ($augCount->{$level} >= 2)
    {
      my $num = $augCount->{$level} >> 1; # take half
      my $cost = ceil(ceil((2 * $num) * (discountPercent($num) * 100)) / 100);
      $augCount->{$level} -= $cost;
      $augCount->{$levels[$i + 1]} += $num;
    }
  }
  while (my ($type, $num) = each (%{$augCount}))
  {
    if (!isNumber($num))
    {
      return "Not a number for aug type $type\n";
    }
    if ($augRef->{uc($type)} > $augRef->{uc($destination)})
    {
      next;
    }
    $totalPoints += ($augRef->{uc($type)} * $num);
  }
  my $result = floor($totalPoints / $augRef->{uc($destination)});
  my $remain = $totalPoints % $augRef->{uc($destination)};
  return 'The combination of those augmenters will make ' . commifyNumber($result) . ' ' . $destination . ' augs, with ' . $remain . ' remaining \'augmenter points\'.';
}

sub help
{
  return '!condense target minor (basic) (std) (good) (exc) (sup) (ult) - Calculates how many augmenters you can make of target type from the numbers you have. Only need to fill in number of augs up to highest. Target must not contain punctation';
}

sub auth
{
  return accessLevel('utils');
}

BobboBot::command::add('condense', 'run', \&BobboBot::condense::run);
BobboBot::command::add('condense', 'help', \&BobboBot::condense::help);
BobboBot::command::add('condense', 'auth', \&BobboBot::condense::auth);

1;
