#!/usr/bin/perl

package BobboBot::mastermind;

use warnings;
use strict;

use POSIX;
use List::MoreUtils qw(none);
use BobboBot::math;
use BobboBot::users;
use BotData;

use constant {
  CODE_LENGTH => 9,
  MAX_ATTEMPTS => 7
};

my $code = makeCode();
my $guesses = 0;

my @players;
my $file = 'data/mastermind.json';
my $data = BotData->new($file, \&addPlayer);

sub addPlayer
{
  return {play => 0, win => 0, lose => 0, guess => 0};
}

sub makeCode
{
  return floor(rand(2 ** CODE_LENGTH));
}

sub restart
{
  $code = makeCode();
  $data->incStat('thought');
  $data->save();
  undef(@players);
  $guesses = 0;
  return {type => 'ACTION', text => 'thinks of a new code'};
}

# pretty prints $code so that it's formatted in a readable manner
sub codePrint
{
  my $chunk = (CODE_LENGTH % 3 == 0 ? 3 : (CODE_LENGTH % 4 == 0 ? 4 : 5));

  my $i;
  my $ret;
  for ($i = CODE_LENGTH - 1; $i > $chunk; $i -= $chunk)
  {
    for (my $j = $i; $j > ($i - $chunk); $j--)
    {
      $ret .= ($code >> $j) & 1;
    }
    $ret .= ' ';
  }
  for (my $j = $i; $j > ($i - $chunk); $j--)
  {
    $ret .= ($code >> $j) & 1;
  }
  return $ret;
}

sub postGuess
{
  my $guess  = shift();
  my $bulls = shift();
  my $cows  = shift();

  my $used = 0;

  # find bulls
  for (my $i = 0; $i < CODE_LENGTH; $i++)
  {
    if ((($guess >> $i) & 1) == (($code >> $i) & 1))
    {
      $$bulls++;
      $used |= 1 << $i;
    }
  }

  # find cows
  for (my $i = 0; $i < CODE_LENGTH; $i++)
  {
    next if (($used >> $i) & 1);

    my $bit = ($guess >> $i) & 1;
    for (my $j = $i + 1; $j < CODE_LENGTH; $j++)
    {
      next if (($used >> $j) & 1);
      if ((($code >> $j) & 1) == $bit)
      {
        $$cows += 2;
        $used |= 1 << $i;
        $used |= 1 << $j;
        last;
      }
    }
  }
}

sub run
{
  my ($player) = split('!', $_[0]->{who});
  my @args = @{$_[0]->{arg}};

  if (defined $args[0] && $args[0] eq 'new')
  {
    restart();
  }
  elsif (defined $args[0] && ($args[0] eq 'stat' || $args[0] eq 'stats'))
  {
    my $player = $args[1] || undef;
    return $data->printStats($player);
  }
  else
  {
    my $guess = join('', @args);
    $guess =~ s/, \t//g; # strip stuff

    # we can do tests here to make sure it's a number
    if (length($guess) != CODE_LENGTH)
    {
      return 'Guess length does not match code length of ' . CODE_LENGTH . '.';
    }
    if (isNumber($guess) == 0 || floor($guess) != $guess)
    {
      return 'Invalid guess.';
    }

    $guess = oct("0b" . $guess); # convert

    $guesses++;
    $data->incStat('guess', $player);
    push(@players, $player) if (none {$_ eq $player} @players);

    my $bulls = 0;
    my $cows = 0;

    postGuess($guess, \$bulls, \$cows);

    if ($guesses >= MAX_ATTEMPTS)
    {
      foreach my $p (@players)
      {
        $data->incStat('play', $p);
        next if ($p eq $player);
        $data->incStat('lose', $p);
      }
      $data->incStat($bulls == 9 ? 'win' : 'lose', $player);

      if ($bulls == 9)
      {
        return ['Well done ' . $player . '! You got the code right in ' . $guesses . ' attemp' . ($guesses != 1 ? 's.' : '.'), restart()];
      }
      return ['Too bad! You didn\'t work it out. The code was ' . codePrint() . '.', restart()];
    }
    else
    {
      return 'Bulls: ' . $bulls . ', Cows: ' . $cows . '. Guess: ' . $guesses . ' of ' . MAX_ATTEMPTS . '.';
    }
  }
}

sub help
{
  return [
    '!mastermind guess - Make a guess at the secret code. The code is ' . CODE_LENGTH . ' 0\'s and 1\'s. Your input may include spaces',
    '!mastermind new - Abandons the current game and resets for a new game.',
    '!mastermind stat [player] - Retrieve game stats.'
  ];
}

sub auth
{
  return accessLevel('normal');
}

BobboBot::command::add('mastermind', 'run', \&BobboBot::mastermind::run);
BobboBot::command::add('mastermind', 'help', \&BobboBot::mastermind::help);
BobboBot::command::add('mastermind', 'auth', \&BobboBot::mastermind::auth);

1;
