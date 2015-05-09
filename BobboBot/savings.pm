#!/usr/bin/perl

package BobboBot::savings;

use warnings;
use strict;

use BobboBot::math;
use POSIX;

sub run
{
  my @arg = @{$_[0]->{arg}};
  my $build = shift(@arg);
  my $num = shift(@arg);

  if (!defined $build)
  {
    return 'Bad parameters given. Usage: !savings (numBuilding) [numItems]';
  }
  if (!isNumber($build))
  {
    return "'$build' is not a number";
  }
  if ($build < 1)
  {
    return 'You can\'t build less than 1 items';
  }
  if ($build > 10000)
  {
    return 'You can\'t build more than 10000 in one batch.';
  }
  if (!defined $num || !isNumber($num) || $num < 1) {
    $num = 1;
  }

  my $mult = discountPercent($build) * 100;
  my $cost = ceil($num * $build * $mult);
  my $tot = $build * $num;
  my $save = floor($tot - ($cost / 100));

  return 'Number builds: ' . commifyNumber($build) . ', Number items: ' . commifyNumber($num) . '. Savings: ' . commifyNumber($save) . '/' . commifyNumber($tot) . '(' . sprintf("%.2f", 100 - $mult)  . '%).';
}

sub help
{
  return '!savings (numBuilds) [numItem] - Calculates how much you save from the multibuild discount. Note this may be inaccurate.';
}

sub auth
{
  return 0;
}

BobboBot::command::add('savings', 'run', \&BobboBot::savings::run);
BobboBot::command::add('savings', 'help', \&BobboBot::savings::help);
BobboBot::command::add('savings', 'auth', \&BobboBot::savings::auth);

1;
