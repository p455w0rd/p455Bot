alias socketbot {
  sockclose bot
  socklisten bot 113
  sockopen bot_x $server 6667
}
menu channel {
  p455Bot:{
    if ($sock(bot_x)) { .sockclose bot_x }
    socketbot
  }
}
alias -l botchan { return #p455w0rd }
alias -l botnick { return p455Bot }
on *:socklisten:bot: {
  var %_rb = $r(1,500)
  sockaccept bot_ [ $+ [ %_r ] ]
  sockclose bot
}

on *:sockopen:bot_x: {
  sockwrite -n bot_x nick $botnick
  sockwrite -n bot_x user $botnick . . . $botnick
}
alias getnick {
  return $gettok($gettok($1,1,58),1,33)
}
alias bmsg { return $right($1,$calc($len($1-) - 1)) }
on *:sockread:bot*: {
  if (!$window(@p455Bot)) {
    window -ae0g0k0w1 @p455Bot $mircexe 0
    titlebar @p455Bot :: $server :: $botchan
  }
  sockread %pb
  tokenize 32 %pb
  var %_ntoks2 = $numtok($1-,44)
  if (%_ntoks2 == 2 && $1,$3 isnum) { sockwrite -n $sockname $3 , $1 : USERID : UNIX : p455Bot }
  if ($bmsg($4) == !pingme) {
    sockwrite -tn $sockname PRIVMSG $getnick($1) $+(:,$chr(1),PING) $+($ctime,$chr(1))
  }
  if ($bmsg($4) == !help) { sockwrite -nt $sockname PRIVMSG $getnick($1) : $+ Public commands: !calc, !pingme }
  if ($bmsg($4) == !say && ($getnick($1) == $me)) { sockwrite -nt $sockname PRIVMSG $botchan : $+ $5- }
  if ($bmsg($4) == !calc) { sockwrite -n bot_x PRIVMSG $botchan :Answer $5 = $calc($5) }
  if ($bmsg($4) == !die && ($getnick($1) == $me))  {
    sockwrite -nt $sockname QUIT $+(12,$chr(44),1,$chr(10027),11,$chr(44),1,$chr(10032) 8,$chr(44),1^_^ 7,$chr(44),1L8er T8er8,$chr(44),1 ^_^11,$chr(44),1 $chr(10032),12,$chr(44),1,$chr(10027))
    sockclose bot
  }
  if ($bmsg($4) == !restart && ($getnick($1) == $me)) { sockwrite -nt $sockname QUIT Restarting... | sockclose bot | .timer 1 1 bot | .timer 1 2 bjoin $botchan }
  if ($bmsg($4) == !cycle && ($getnick($1) == $me)) { sockwrite -nt $sockname PART $5 | sockwrite -n bot_x JOIN $5- } 
  if ($bmsg($4) == !kick && ($getnick($1) == $me)) { sockwrite -nt $sockname KICK $botchan $5 :moo }
  if ($bmsg($4) == !src) { sockwrite -nt $sockname PRIVMSG $botchan : $+ https://github.com/p455w0rd/p455Bot/blob/master/p455Bot.mrc }
  if ($+(:,$chr(1),version,$chr(1)) isin $4) { sockwrite -tn $sockname notice $getnick($1) : $+ $chr(1) $+ VERSION p455Bot - A Socket Driven IRC Bot - v0.2 by p455w0rd $chr(1) | goto done }
  if ($+(:,$chr(1),ping) isin $4 && $3 == PRIVMSG && $bmsg($1) != !pingme) { sockwrite -tn $sockname notice $getnick($1) $+(:,$chr(1),PING) $+($ctime,$chr(1)) | goto done }
  if ($+(:,$chr(1),ping) isin $4 && $2 == NOTICE && $bmsg($1) != !pingme) { sockwrite -tn $sockname privmsg $botchan :PING for $getnick($1) $+ : $duration($calc($ctime - $left($5,$calc($len($5) - 1)))) | goto done }
  if ($1 == PING && $2) { sockwrite -n $sockname PONG $2- | goto done }
  if ($2 == 376) { echo @p455Bot Successfully Connected.. | sockwrite -tn $sockname join $botchan | set %bot_connected 1 }
  if ($2 == 332) { echo @p455Bot $4 Topic: $5- }
  if (($3 == JOIN) && ($getnick($1) == $botnick)) { halt }
  if (($2 == PRIVMSG) && $3 == $botchan) {
    echo @p455Bot $+(<,$getnick($1),>) $bmsg($4-)
    goto done
  }
  echo @p455Bot $1-
  :done
  unset %pb
  halt
}

alias bpart { sockwrite -n bot_x PART $1- | halt }
alias bjoin { sockwrite -n bot_x JOIN $1- | halt }
alias bsay { sockwrite -n bot_x PRIVMSG $active : $+ $1- | halt }
alias bkill { sockwrite -nt bot_x QUIT QuitMSG :O | sockclose bot | sockclose bot_x }
alias bnick { sockwrite -n bot_x NICK $1 }
