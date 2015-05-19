#!/usr/bin/perl

package BobboBot::8ball;

use warnings;
use strict;
use BobboBot::users;

use POSIX;

my @good = (
  "It is certain",
  "It is decidedly so",
  "Without a doubt",
  "Yes definitely",
  "You may rely on it",
  "As I see it, yes",
  "Most likely",
  "Outlook good",
  "Yes",
  "Signs point to yes"
);
my @neutral = (
  "Reply hazy try again",
  "Ask again later",
  "Better not tell you now",
  "Cannot predict now",
  "Concentrate and ask again"
);
my @bad = (
  "Don't count on it",
  "My reply is no",
  "My sources say no",
  "Outlook not so good",
  "Very doubtful"
);
my @responses = (\@good, \@neutral, \@bad);
my @fails = (
  "Query looks questionable",
  "Questioning if your question is a question.",
  "Put your hand up to ask a question.",
  "Have you no respect for proper etiquette?",
  "Ask properly and ye shall know.",
  "Clearly not a fan of Question Time.",
  "8ball hears you, 8ball don't care."
);

my @badQs  = qw(how why where when);
my @goodQs = qw(can is will should do would);

sub run
{
  my $question = lc(join(' ', @{$_[0]->{arg}}));

  if (!defined $question)
  {
    return $fails[floor(rand(@fails))];
  }

  foreach my $q (@badQs)
  {
    if (index($question, $q) != -1)
    {
      return $neutral[floor(rand(@neutral))];
    }
  }
  foreach my $q (@goodQs)
  {
    if (index($question, $q) != -1)
    {
      my @pool = @{$responses[floor(rand(@responses))]};
      return $pool[floor(rand(@pool))];
    }
  }
  return $fails[floor(rand(@fails))];
}

sub help
{
  return '!8ball (question) - Query the magic 8ball for cosmic help and advice.';
}

sub auth
{
  return accessLevel('normal');
}

BobboBot::command::add('8ball', 'run', \&BobboBot::8ball::run);
BobboBot::command::add('8ball', 'help', \&BobboBot::8ball::help);
BobboBot::command::add('8ball', 'auth', \&BobboBot::8ball::auth);

1;
