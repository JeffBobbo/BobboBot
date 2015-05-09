#!/usr/bin/perl

package BobboBot::countdown;

use warnings;
use strict;

use JSON qw(decode_json encode_json);
use BobboBot::math;

my $file = 'countdowns.json';
my $json;

sub doAlerts
{
  $json = load() if (!defined $json); # load if unloaded
  return if (!defined $json); # do nothing if loading failed

  my @countdowns = keys %{$json};
  foreach my $cd (@countdowns)
  {
    next if (!defined $json->{$cd}{alerts}); # skip those with no count downs

    $json->{$cd}{rAlerts} = [split(' ', $json->{$cd}{alerts})] if (!defined $json->{$cd}{rAlerts}); # fill the alerts if not there
    if (@{$json->{$cd}{rAlerts}} != 0)
    {
      my $when = $json->{$cd}{when};
      my $alert = $json->{$cd}{rAlerts}[0];
      my $now = time();
      $now %= $json->{$cd}{repeat} if ($json->{$cd}{repeat} != -1);
      if ($now + $alert > $when)
      {
        shift($json->{$cd}{rAlerts});
        my $time = $when - $now;
        if ($time > 0 && (@{$json->{$cd}{rAlerts}} == 0 || $now + @{$json->{$cd}{rAlerts}}[0] <= $when))
        {
          my $str = $json->{$cd}{desc} . ' (' . $cd . ') is in ' . humanTime($time) . '.';
          if (defined $json->{$cd}{channel})
          {
            $main::irc->yield('privmsg', $json->{$cd}{channel}, $str);
          }
          else
          {
            foreach my $chan (main::channelList())
            {
              $main::irc->yield('privmsg', $chan, $str);
            }
          }
        }
      }
    }
    else
    {
      $json->{$cd}{rAlerts} = [split(' ', $json->{$cd}{alerts})];
    }
  }
}

sub load
{
  open(my $fh, '<', $file) or return undef;
  my @lines = <$fh>;
  close($fh);

  my $src = join('', @lines);
  if (length($src))
  {
    return decode_json($src);
  }
  return undef;
}

sub save
{
  return 0 if (!defined $json);

  my $tmp = {}; # back up and remove remaining alerts
  foreach my $cd (keys %{$json})
  {
    next if (!defined $json->{$cd}{rAlerts});

    $tmp->{$cd} = {};
    $tmp->{$cd}{rAlerts} = delete $json->{rAlerts};
  }
  my $text = encode_json($json);
  open(my $fh, '>', $file) or return 0;
  print $fh $text;
  close($fh);
  foreach my $cd (keys %{$tmp}) # restore
  {
    $json->{$cd}{rAlerts} = $tmp->{$cd}{rAlerts};
  }
  return 1;
}

sub run
{
  $json = load() if (!defined $json); # loaded if it's unloaded
  return 'No countdown configurations.' if (!defined $json); # if it's still unloaded, abort

  my @args = @{$_[0]->{arg}};
  my $what = shift(@args);

  if ($what eq 'list')
  {
    my @list = keys %{$json};
    my $ret = "Countdown list: ";
    for (my $i = 0; $i < @list; $i++)
    {
      if (!defined $json->{$list[$i]}{channel} || $json->{$list[$i]}{channel} eq $_[0]->{where})
      {
        $ret .= (length($ret) > 16 ? ', ' : '') . $list[$i];
      }
    }
    return $ret;
  }
  elsif ($what eq 'set' || $what eq 'add')
  {
    if (BobboBot::auth::check($_[0]->{who}, $_[0]->{where}) == 0)
    {
      return 'Permission denied.';
    }
    my $countdown = shift(@args);
    my $channel   = shift(@args);
    my $when      = shift(@args);
    my $repeat    = shift(@args);
    my $desc;

    my $tmp = join(' ', @args);
    my $start = index($tmp, '"');
    if ($start != -1)
    {
      my $end = index($tmp, '"', $start + 1);
      $desc = substr($tmp, $start + 1, $end - ($start + 1), '');
      substr($tmp, index($tmp, '"'), 2, ''); # remove the remaining ""
    }
    my @alerts = split(' ', $tmp); # add in alerts

    if (!(defined $countdown && defined $channel && defined $when && defined $repeat && defined $desc))
    {
      return 'Not enough arguments';
    }
    if ($channel ne 'all' && index('#', $channel) != 0)
    {
      return 'Bad channel name: ' . $channel . ' should be "#channel" or "all".';
    }

    if (!defined $json->{$countdown})
    {
      $json->{$countdown} = {};
    }
    $json->{$countdown}{channel} = $channel eq 'all' ? undef : $channel;
    $json->{$countdown}{when}    = $when;
    $json->{$countdown}{repeat}  = $repeat;
    $json->{$countdown}{desc}    = $desc;
    $json->{$countdown}{alerts}  = join(' ', @alerts);
    delete $json->{$countdown}{rAlerts};

    if (save() == 1)
    {
      return 'Set and saved.';
    }
    return 'Set but failed to save.';
  }
  elsif ($what eq 'del')
  {
    if (BobboBot::auth::check($_[0]->{who}, $_[0]->{where}) == 0)
    {
      return 'Permission denied.';
    }
    my $countdown = shift(@args);
    if (!defined $json->{$countdown})
    {
      return 'Unknown countdown: ' . $countdown . '.';
    }
    delete $json->{$countdown};
    if (save() == 1)
    {
      return 'Removed and saved.';
    }
    return 'Removed but failed to save.';
  }
  elsif ($what eq 'save')
  {
    if (BobboBot::auth::check($_[0]->{who}, $_[0]->{where}) == 0)
    {
      return 'Permissiong denied.';
    }
    if (save() == 1)
    {
      return 'Saved countdown configuration.';
    }
    return 'Failed to save countdown configuration.';
  }
  elsif ($what eq 'reload')
  {
    if (BobboBot::auth::check($_[0]->{who}, $_[0]->{where}) == 0)
    {
      return 'Permissiong denied.';
    }
    $json = load();
    if (defined $json)
    {
      return 'Reloaded countdown configuration.';
    }
    return 'Failed to load countdown configuration.';
  }
  else
  {
    my $countdown = $what;
    if (!defined $json->{$countdown})
    {
      return 'Unknown countdown: ' . $countdown . '.';
    }
    if (defined $json->{$countdown}{channel} && $json->{$countdown}{channel} ne $_[0]->{where})
    {
      return 'Unknown countdown: ' . $countdown . '.'; # lie and tell them it doesn't exist
    }
    my $now = time();
    if ($json->{$countdown}{repeat} != -1)
    {
      $now %= $json->{$countdown}{repeat};
    }
    my $when = $json->{$countdown}{when};

    my $desc = $json->{$countdown}{desc} . ' (' . $countdown . ')';
    if ($json->{$countdown}{repeat} != -1)
    {
      my $remaining = $when - $now;
      $remaining = $json->{$countdown}{repeat} + $remaining if ($remaining < 0); # $remaining is negative
      if ($remaining != 0)
      {
        return $desc . ' is in ' . humanTime($remaining) . '.';
      }
      return $desc . ' is now.';
    }
    else
    {
      if ($now < $when)
      {
        return $desc . ' is in ' . humanTime(abs($when - $now)) . '.';
      }
      elsif ($now == $when)
      {
        return $desc . ' is now.';
      }
      else
      {
        return $desc . ' was ' . humanTime(abs($when - $now)) . ' ago.';
      }
    }
  }
}

sub help
{
  my @a = ('!countdown <event> - Time remaining until a certain event.',
          '!countdown list - List of events.',
          '!countdown add|set event channel when repeat "desc" [alerts] - Add or change an event, when and repeat in unix epoch, -1 if non repeating.',
          '!countdown del event - Remove an event',
          '!countdown reload - Reload the countdown configuration.',
          '!countdown save - Manually save the countdown configuration.'
          );

  if (BobboBot::auth::check($_[0]->{who}, $_[0]->{where}) == 0)
  {
    return [$a[0], $a[1]];
  }
  return \@a;
}

sub auth
{
  return 0;
}

BobboBot::command::add('countdown', 'run', \&BobboBot::countdown::run);
BobboBot::command::add('countdown', 'help', \&BobboBot::countdown::help);
BobboBot::command::add('countdown', 'auth', \&BobboBot::countdown::auth);

1;
