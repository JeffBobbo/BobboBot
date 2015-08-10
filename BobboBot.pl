#!/usr/bin/perl

#IRC bot script

use strict;
use warnings;

#perl modules
use POE qw(Component::IRC);
use File::Copy;

# only "core" modules/commands go in here, rest go in bon.conf
# super command module
use BobboBot::command;
# bobbobot util commands
use BobboBot::list;
use BobboBot::help;
use BobboBot::alias;
# supporting modules
use BobboBot::math;
use BobboBot::config;
use BobboBot::channels;
use BobboBot::logger;
# auth stuff
use BobboBot::access;
use BobboBot::users;
use BobboBot::shutdown;
use BobboBot::restart;
use BobboBot::update;

#flush files

my $config = Config->new('bot.conf');
$config->read();

{
  my $moduleDir = $config->getValue('moduleDir');
  foreach my $module (split(' ', $config->getValue('modules')))
  {
    require $moduleDir . '/' . $module . '.pm';
  }
}

$| = $config->getValue('noBuffer') || 0;
readUsers();

loadChannels("channels.conf");

# load alias
BobboBot::alias::load();

# message stuff
my $lastMsg  = -1;
my $lastPing = -1;
my $lastPong = -1;

my $lastMsgs = {};

our $cleanExit = 0; # 1 for shutdown, 2 for restart

use constant {
  PUBLIC  => 0,
  NOTICE  => 1,
  PRIVMSG => 2,
};

our $irc = POE::Component::IRC->spawn(
  Nick     => $config->getValue("nick"),
  Username => $config->getValue("user"),
  Ircname  => $config->getValue("user"),
  Server   => $config->getValue("addr"),
  Port     => $config->getValue("port"),
  Flood    => 1,
  debug    => 1
) or die "Failed to create PoCo object: $!\n";

POE::Session->create(
  package_states => [
    main => [
      "_start",
      "_stop",
      "irc_001", # connect
      "irc_352", # who
      "irc_432", # nick being held
      "irc_433", # nick in use
      "irc_join",
      "irc_part",
      "irc_quit",
      "irc_kick",
      "irc_nick",
      "irc_public",
      "irc_notice",
      "irc_msg",
      "irc_ping",
      "irc_pong",
      "irc_mode",
      "irc_shutdown",
      "autoEvents"
    ],
  ],
  heap => { irc => $irc },
);

$poe_kernel->run();

sub _start
{
  my ($kernel, $heap) = @_[KERNEL, HEAP];

  my $irc = $heap->{irc};

  $irc->yield(register => 'all');
  $irc->yield(connect => {});

  print STDOUT "Connecting to " . $config->getValue("addr") . ":" . $config->getValue("port") . " as " . $config->getValue("nick") . "!" . $config->getValue("user") . "\n";

  return;
}

sub _stop
{
  if ($cleanExit == 2)
  {
    exec "./StartBot";
  }
  elsif ($cleanExit == 1)
  {
    exit(0);
  }
}

sub irc_001 {
  my ($sender, $kernel) = @_[SENDER, KERNEL];

  my $irc = $sender->get_heap();

  print STDOUT "Connected to ", $irc->server_name(), "\n";

  my $ns = Config->new('ns.conf');
  $ns->read();
  $irc->yield('privmsg', 'nickserv', 'identify ' . $ns->getValue("nspass")) if (length($ns->getValue("nspass")));

  foreach my $chan (channelList())
  {
    my $data = channelData($chan);
    if ($data->{key} ne "")
    {
      $irc->yield(join => $chan, $data->{key});
      next;
    }
    $irc->yield(join => $chan);
  }
  $lastPing = time();
  $kernel->delay(autoEvents => 4);
  return;
}

sub irc_352 # WHO resp
{
  my $who = $_[ARG2][4] . '!' . $_[ARG2][1] . '@' . $_[ARG2][2];
  my $modes = $_[ARG2][5];
  userEvent($_[ARG2][4], 'WHO', $modes);
}

sub irc_432 # nick being held
{
  $irc->yield(nick => $config->getValue('nick') . '_');
}

sub irc_433 # nick in use
{
  $irc->yield(nick => $config->getValue('nick') . '_');
}

sub irc_ping
{
  $lastPing = time();
}

sub irc_pong
{
  $lastPong = time();
}

sub irc_mode
{
  my $who      = $_[ARG0] || "";
  my $target   = $_[ARG1] || "";
  my $modes    = $_[ARG2] || "";
  my $operands = $_[ARG3] || "";

  logEvent("$who at $target set modes $modes $operands");
}

sub irc_join
{
  my $user    = $_[ARG0] || "";
  my $channel = $_[ARG1] || "";
  my ($nick, $host) = (split '!', $user);

  if ($nick eq $irc->nick_name())
  {
    if (length(channelData($channel)->{op})) # if we're op, op ourselves
    {
      $irc->yield('privmsg', 'chanserv', $channel . ' ' . channelData($channel)->{op});
    }
  }
  else
  {
    userEvent($nick, 'JOIN');
  }

  logEvent("$nick ($host) joined $channel", $channel);
}

sub irc_part
{
  my $user    = $_[ARG0] || "";
  my $channel = $_[ARG1] || "";
  my $msg     = $_[ARG2] || "";
  my ($nick, $host) = (split '!', $user);

  logEvent("$nick ($host) left $channel ($msg)", $channel);
}

sub irc_quit
{
  my $user    = $_[ARG0] || "";
  my $channel = $_[ARG1] || "";
  my $msg     = $_[ARG2] || "";
  my ($nick, $host) = (split '!', $user);

  if ($nick ne $irc->nick_name())
  {
    userEvent($nick, 'QUIT');
  }

  logEvent("$nick ($host) quit $channel ($msg)", $channel);
}

sub irc_kick
{
  my $user    = $_[ARG0] || "";
  my $channel = $_[ARG1] || "";
  my $victim  = $_[ARG2] || "";
  my $msg     = $_[ARG3] || "";
  my ($nick, $host) = (split '!', $user);

  logEvent("$victim was kicked from $channel by $nick ($host): $msg", $channel);
}

sub irc_nick
{
  my $user    = $_[ARG0] || "";
  my $nNick   = $_[ARG1] || "";
  my ($nick, $host) = (split '!', $user);

  if ($nick eq $irc->nick_name())
  {
    return;
  }

  userEvent($nick, 'NICK', $nNick);

  logEvent("$nick ($host) changed nick to $nNick", undef);
  return;
}

sub irc_public
{
  my ($who, $target, $msg) = @_[ARG0..ARG2];
  $target = @{$target}[0];
  logMsg($who, $target, $msg);
  $msg = sanitizeString($msg, 0);
  my $command = sanitizeString($msg, 1);

  if ($command =~ s/^!([^!].*)$/$1/)
  {
    runCommands($command, $who, $target, ($config->getValue("silent") ? NOTICE : PUBLIC));
    return;
  }

  if ($lastMsgs->{$who} && $lastMsgs->{$who}{msg} eq $msg)
  {
    $lastMsgs->{$who}{count}++;
    $irc->yield('privmsg', $target, 'Warning: Repeating is not allowed.') if ($lastMsgs->{$who}{count} == 3);
    $irc->yield('kick', $target, substr($who, 0, index($who, '!')), 'Repeating is not allowed.') if ($lastMsgs->{$who}{count} > 3);
  }
  else
  {
    $lastMsgs->{$who}{count} = 1;
    $lastMsgs->{$who}{msg} = $msg;
  }
  return;
}

sub irc_notice
{
  my ($who, $target, $msg) = @_[ARG0..ARG2];
  $target = @{$target}[0];
  $msg = sanitizeString($msg, 1);

  if ($msg =~ s/^!([^!].*)$/$1/)
  {
    runCommands($msg, $who, $target, NOTICE);
    return;
  }
  return;
}

sub irc_msg
{
  my ($who, $target, $msg) = @_[ARG0..ARG2];
  $target = @{$target}[0];
  $msg = sanitizeString($msg, 1);


  if ($msg =~ s/^!([^!].*)$/$1/)
  {
    runCommands($msg, $who, $target, PRIVMSG);
    return;
  }
  return;
}

sub runCommands
{
  my ($command, $who, $where, $form) = @_;

  my ($nick) = split('!', $who);
  if ($form == NOTICE)
  {
    $where = $nick;
    $form = 'notice';
  }
  elsif ($form == PUBLIC)
  {
    $form = 'privmsg';
  }
  else
  { #if it ain't a notice and ain't public, must be a pm
    $where = $nick;
    $form = 'privmsg'
  }

  if (index('#', $where) != -1 && time() < ($lastMsg + $config->getValue("msgRate")) && checkAccess($who, $where) < accessLevel('op'))
  {
    my $remain = ($lastMsg + $config->getValue("msgRate")) - time();
    $irc->yield('privmsg', $nick, 'Flood control in effect for ' . $remain . 's.');
    return;
  }
  $lastMsg = time();

  print STDOUT "who: $nick, target: $where, form: $form, msg: $command\n";

  ($command, my @arg) = split(' ', $command);

  my $args = {
    'who'   => $who,
    'where' => $where,
    'form'  => $form,
    'arg'   => \@arg
  };

  $command = lookupAlias($command); # automatically check for an alias
  if (isValidCommand($command) != 0)
  {
    if (checkAccess($who, $where) < commands()->{$command}{auth}())
    {
      if (commands()->{$command}{auth}() > accessLevel('ignore'))
      {
        $irc->yield($form, $where, $nick . ': Permission denied.');
      }
      else
      {
        $irc->yield('privmsg', $nick, 'You are on my ignore list.');
      }
    }
    else
    {
      my $response = eval { commands()->{$command}{run}($args) };
      if ($@)
      {
        $irc->yield('privmsg', $where, $nick . ': ERROR: ' . $@);
        print STDERR 'ERROR: ' . $@ . "\n";
      }
      else
      {
        if (ref($response) eq 'ARRAY')
        {
          foreach my $r (@{$response})
          {
            if (ref($r) eq 'HASH')
            {
              if ($r->{type} eq 'ACTION')
              {
                $irc->yield(ctcp => $where => 'ACTION ' . $r->{text}) if (length($r->{text}));
              }
            }
            else
            {
              $irc->yield($form, $where, $nick . ': ' . $r) if (length($r));
            }
          }
        }
        elsif (ref($response) eq 'HASH')
        {
          if ($response->{type} eq 'ACTION')
          {
            $irc->yield(ctcp => $where => 'ACTION ' . $response->{text}) if (length($response->{text}));
          }
        }
        else # scalar
        {
          $irc->yield($form, $where, $nick . ': ' . $response) if (length($response));
        }
      }
    }
  }
  else
  {
    $irc->yield($form, $where, $nick . ': Unknown command, see !list');
  }
}

sub irc_shutdown
{
  _stop();
}

sub autoEvents
{
  my ($kernel, $heap) = @_[KERNEL, HEAP];

  # check if we're still connected
  if (time() > (max($lastMsg, $lastPing, $lastPong) + 60))
  {
    $irc->yield(ping => {});
  }
  if (time() > (max($lastMsg, $lastPing, $lastPong) + 90))
  {
    my $irc = $heap->{irc};
    $irc->yield(connect => {});
    $kernel->delay(autoEvents => $config->getValue('autoEventsInterval')); # set this again, incase connect fails
    return; # we don't want to do the other stuff yet
  }

  # check if I'm me
  if ($irc->nick_name() ne $config->getValue('nick'))
  {
    my $ns = Config->new('ns.conf');
    $ns->read();
    if (length($ns->getValue("nspass")))
    {
      $irc->yield('privmsg', 'nickserv', 'ghost ' . $config->getValue('nick') . ' ' . $ns->getValue("nspass"));
      $irc->yield('privmsg', 'nickserv', 'release ' . $config->getValue('nick') . ' ' . $ns->getValue("nspass"));
      $irc->yield(nick => $config->getValue('nick'));
      $irc->yield('privmsg', 'nickserv', 'identify ' . $ns->getValue("nspass"));
      $kernel->delay(autoEvents => 2);
      return; # return early so we don't overwrite this or do status checks twice quickly
    }
  }

  runEvents();

  $kernel->delay(autoEvents => $config->getValue("autoEventsInterval"));
}

sub sanitizeString
{
  my ($string, $level) = @_;
  if (!defined $level)
  {
    $level = 1;
  }
  $string=~ s/(?:[\x1F\x02\x16])|(:?\x03[0-9]{1,2},[0-9]{1,2}|\x03[0-9]{1,2})//g; # remove IRC special characters like colour
  if ($level > 0)
  {
#    $string =~ s/[^a-zA-Z0-9_\-:\/ \\\.!#~ \*\+\?%\^"']//g; # be extra anal and remove some extra things
  }
  return $string;
}
