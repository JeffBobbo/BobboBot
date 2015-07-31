#!/usr/bin/perl

package BobboBot::quote;

use warnings;
use strict;

use POSIX;
use JSON qw(decode_json encode_json);
use Switch;

use BobboBot::users;
use BobboBot::access;


my $file = 'quotes.json';
my $json;


my $styles = {
  NORMAL => 0, # will appear IRC style: <nick> quote
  ACTION => 1, # like an IRC action: * <nick> actions
  ELEGANT => 2 # author is prepended using an em-dash
};

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
  return {};
}


sub save
{
  return 0 if (!defined $json);

  my $text = encode_json($json);
  open(my $fh, '>', $file) or return 0;
  print $fh $text;
  close($fh);
  return 1;
}

sub add
{
  my @arg = @{$_[0]->{arg}};
  my $who = $_[0]->{who};

  if (checkAccess($who, $_[0]->{where}) < accessLevel('op'))
  {
    return 'Permission denied.';
  }

  my $string = join(' ', splice(@arg, 1));

  my $start;
  my $end;

  my $style;
  if (($start = index($string, '-s ')) >= 0)
  {
    $end = index($string, ' -', $start + 3);
    $style  = substr($string, $start + 3, ($end == -1 ? length($string) : $end) - ($start + 3));
  }
  my $author;
  if (($start = index($string, '-a')) >= 0)
  {
    $end = index($string, ' -', $start + 3);
    $author = substr($string, $start + 3, ($end == -1 ? length($string) : $end) - ($start + 3));
  }
  my $quote;
  if (($start = index($string, '-q')) >= 0)
  {
    $end = index($string, ' -', $start + 3);
    $quote  = substr($string, $start + 3, ($end == -1 ? length($string) : $end) - ($start + 3));
  }

  return "No quote given to add" if (length($quote) == 0);

  $style = $style ? $styles->{uc($style)} : 0;

  my ($nick)  = split('!', $who);
  my $h = {
    style => $style,
    author => $author,
    quote => $quote,
    who => $nick,
  };

  push(@{$json}, $h);
  save();
  return "Added '" . $quote . "' to the list and saved";
}

use Data::Dumper;
sub run
{
  $json = load() if (!defined $json);
  return 'No quotes!' if (!defined $json);


  my @arg = @{$_[0]->{arg}};
  my $action = shift(@arg);

  if (defined $action && $action eq '-add')
  {
    return add($_[0]);
  }
  elsif (defined $action && $action eq '-styles')
  {
    my @a = sort(keys %{$styles});
    my $ret = lc($a[0]);
    for (my $i = 1; $i < @a; $i++)
    {
      $ret .= ', ' . lc($a[$i]);
    }
    return $ret;
  }
  else
  {
    my $a = $action;
    my $q = shift(@arg);

    my @list = @{$json};
    if ($a && length($a))
    {
      $a =~ s/\*/.*/g;
      for (my $i = @list - 1; $i >= 0; $i--)
      {
        if ($list[$i]->{author} !~ /^$a$/)
        {
          splice(@list, $i, 1);
        }
      }
    }
    if ($q && length($q))
    {
      for (my $i = @list; $i >= 0; $i--)
      {
        if (index($list[$i]->{quote}, $q) == -1)
        {
          splice(@list, $i, 1);
        }
      }
    }

    return 'No quotes found' if (@list == 0);
    my $i = floor(rand(@list));
    my $quote = $list[$i];

    my $resp = "";
    switch ($quote->{style})
    {
      case ($styles->{NORMAL})
      {
        $resp = '<' . $quote->{author} . '> ' . $quote->{quote};
      }
      case ($styles->{ACTION})
      {
        $resp = '* ' . $quote->{author} . ' ' . $quote->{quote};
      }
      case ($styles->{ELEGANT})
      {
        $resp = '"' . $quote->{quote} . '" — ' . $quote->{author};
      }
    }
    return $resp;
  }
}

sub help
{
  return [
    '!quote - Retrieve a quote from the list',
    '!quote -add -a author -q quote -s style - Add a quote to the list',
    '!quote -styles - Retrieve the possible styles'
  ];
}

sub auth
{
  return accessLevel('normal');
}

BobboBot::command::add('quote', 'run', \&BobboBot::quote::run);
BobboBot::command::add('quote', 'help', \&BobboBot::quote::help);
BobboBot::command::add('quote', 'auth', \&BobboBot::quote::auth);

1;
