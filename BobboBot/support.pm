#!/usr/bin/perl

package BobboBot::support;

use warnings;
use strict;

use BobboBot::math;
use BobboBot::users;
use POSIX;

sub run
{
# return "For support relating to issues with Star Sonata, you can create a support ticket at http://support.starsonata.com or visit the forums at http://forum.starsonata.com/ For issues involving " . getConfig("nick") . ", contact Bobbo";
  return "For support relating to issues with Star Sonata, you can create a support ticket at http://support.starsonata.com. or visit the forums at http://forum.starsonata.com. -- For issues regarding BobboBot, contact Bobbo on IRC.";
}

sub help
{
  return '!support - Provides some basic information on where to get help for Star Sonata or me.';
}

sub auth
{
  return accessLevel('utils');
}

BobboBot::command::add('support', 'run', \&BobboBot::support::run);
BobboBot::command::add('support', 'help', \&BobboBot::support::help);
BobboBot::command::add('support', 'auth', \&BobboBot::support::auth);

1;
