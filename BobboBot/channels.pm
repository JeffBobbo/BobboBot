#!/usr/bin/perl

package BobboBot::channels;

use warnings;
use strict;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(loadChannels channelList channelData);

my $channels = {};

sub loadChannels
{
  my $file = shift();
  my $config =  Config->new($file);
  $config->read();

  my @channels = $config->getParams();

  foreach my $channel (@channels)
  {
    my @opts = split(' ', $config->getValue($channel));

    $channels->{$channel} = {};
    $channels->{$channel}->{op} = $opts[0] || '';
    $channels->{$channel}->{key} = $opts[1] || '';
  }
}

sub channelList
{
  return keys(%{$channels});
}

sub channelData
{
  my $chan = shift();

  return $channels->{$chan};
}
