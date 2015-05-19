#!/usr/bin/perl

package BobboBot::manhours;

use warnings;
use strict;

use BobboBot::math;
use BobboBot::users;
use POSIX;

sub run
{
  my @arg = @{$_[0]->{arg}};

  my $manhours = shift(@arg);
  my $workers  = shift(@arg) || 1;
  my $num      = shift(@arg) || 1;
  my $percent  = shift(@arg);

  if (!defined $manhours)
  {
    return 'Invalid parameters given. Usage: !manhours (manhours) [workers] [numBuilding] [percent]';
  }
  if (!isNumber($manhours))
  {
    return 'Error: manhours was not a number.';
  }
  if (!int $manhours)
  {
    $manhours = floor($manhours);
  }

  if (!int $workers)
  {
    $workers = floor($workers);
  }
  if ($workers < 1)
  {
    return 'No workforce provided.';
  }

  if ($num != floor($num))
  {
    $num = floor($num);
  }

  if ($num < 1)
  {
    return 'You can\'t build less than 1 item.';
  }
  if ($num > 10000)
  {
    return 'You can\'t build more than 10000 items in one go.';
  }

  my $mult = discountPercent($num) * 100;
  my $bTime = (($manhours * 10) / $workers) * $mult;

  my $result = commifyNumber($num) . ' builds. Requiring ' . commifyNumber($manhours) . ' manhours each, using ' . commifyNumber($workers) . ' workers should take ';
  if (defined $percent)
  {
    if (index($percent, '%') >= 0)
    {
      $percent = PC2Dec($percent);
    }
    $bTime *= 1-$percent;
  }
  $bTime = floor($bTime / 100);
  $result .= humanTime($bTime * $num);
  $result .= ' (' . humanTime($bTime) . ' per item)' if ($num > 1);
  if (defined $percent)
  {
    $result .= ' from ' . $percent * 100 . '%.';
  }
  else
  {
    $result .= '.';
  }
  return $result;
}

sub help
{
  return '!manhours (manhours) [workforce] [numBuilds] [progress] - Calculates build time, use progress to calculate time remaining'
}

sub auth
{
  return accessLevel('utils');
}

BobboBot::command::add('manhours', 'run', \&BobboBot::manhours::run);
BobboBot::command::add('manhours', 'help', \&BobboBot::manhours::help);
BobboBot::command::add('manhours', 'auth', \&BobboBot::manhours::auth);

1;
