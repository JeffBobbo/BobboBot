#!/usr/bin/perl

package Config;

use warnings;
use strict;

require Exporter;

my $comment = '//'; # what denotes a comment in the configuration file

sub new
{
  my $class = shift();
  my $file = shift();

  my $self = {};

  bless($self, $class);

  $self->{file} = $file;
  return $self;
}

sub getFileName
{
  my $self = shift();
  return $self->{file};
}

sub read
{
  my $self = shift();
  my $file = $self->getFileName();
  open(my $fh, '<', $file) or die  __FILE__ . ':' .__LINE__ . " Can't open " . $file . ": $!\n";
  while (<$fh>)
  {
    chomp(); # remove tailing whitespace
    my $parseTo = index($_, $comment);

    my $line = $_;
    $line = substr($_, 0, $parseTo) if ($parseTo >= 0); # chop of comments
    next if (length($line) == 0); # skip empty lines
    my @tokens = split(/[:] ?/, $line);

    my $param = shift(@tokens);
    $self->{config}->{$param} = join(' ', @tokens); # store the values as a space deliminated list
  }
  close($fh);
}

sub getParams
{
  my $self = shift();

  return (keys %{$self->{config}});
}

sub getValue
{
  my $self = shift();
  my $param = shift();

  return defined $self->{config}->{$param} ? $self->{config}->{$param} : '';
}

sub setValue
{
  my $self = shift();
  my $param = shift();
  my $value = shift();

  if (!defined $param)
  {
    return 0 ;
  }

  if (!defined $value)
  {
    return 0;
  }

  if (!defined $self->{config}->{$param})
  {
    return 0;
  }

  $self->{config}->{$param} = $value;
  return 1;
}

sub write
{
  my $self = shift();

  open(my $fh, '>', $self->getFileName()) or return 0;
  foreach my $key (keys %{$self->{config}})
  {
    print $fh $key . ": " . $self->{config}->{$key} . "\n";
#    print $key . ": " . join(", ", split(/ /, $self->{config}->{$key})) . "\n";
  }
  close($fh);
}
