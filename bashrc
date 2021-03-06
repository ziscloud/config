# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

#always screen...
#if [ -z $STY ]; then
#    exec screen -RR
#fi

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

currbranch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/' -e 's/jamesh-//'
}
if [ "$color_prompt" = yes ]; then
    #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    bash_prompt_command() {
      # How many characters of the $PWD should be kept
      local pwdmaxlen=25
      # Indicate that there has been dir truncation
      local trunc_symbol="..."
      NEW_PWD=${PWD/#$HOME/\~}
      local dir=${NEW_PWD##*/}
      pwdmaxlen=$(( ( pwdmaxlen < ${#dir} ) ? ${#dir} : pwdmaxlen ))
      local pwdoffset=$(( ${#NEW_PWD} - pwdmaxlen ))
      if [ ${pwdoffset} -gt "0" ]
      then
        temp=${NEW_PWD:$pwdoffset:$pwdmaxlen}
        temp=${trunc_symbol}/${temp#*/}
        if [ ${#temp} -lt ${#NEW_PWD} ]
        then
          NEW_PWD=${temp}
        fi
      fi
      if git branch > /dev/null 2> /dev/null; then
        CURR_BRANCH=" [`currbranch`]"
      else
        unset CURR_BRANCH
      fi
    }

    # PS1="\[[4;32m\]\h\[[0m\]:\[[1;34m\]\${NEW_PWD}\[[0m\]\${CURR_BRANCH}\$ "
    PS1="\[[1;34m\]\${NEW_PWD}\[[0m\]\${CURR_BRANCH}\$ "

    case $TERM in
    xterm*|rxvt*|screen*)
      PROMPT_COMMAND='echo -ne "\033]0;${USER}@$HOSTNAME\007";bash_prompt_command'
      ;;
    *)
      PROMPT_COMMAND=bash_prompt_command
      ;;
    esac

    alias ll='ls -FC --color=always'
    alias ls='ls --color'
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

unset color_prompt force_color_prompt

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# turn off stupid ctrl-s
stty -ixon

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# screen wipes this out... bleh

# set up user binaries etc.
function insert() {
    if [ -z "${!1}" ]; then
        export $1="$2"
    else
        export $1="$2:${!1}"
    fi
}
export -f insert
PREFIX=~/local
if [ -d $PREFIX ] ; then
    insert PATH "$PREFIX/bin"
    insert MANPATH "/usr/share/man"
    insert MANPATH "$PREFIX/share/man"
    insert MANPATH "$PREFIX/man"
    insert LIBRARY_PATH "$PREFIX/lib"
    insert LD_LIBRARY_PATH "$HOME/local/lib"
    insert CPATH "$PREFIX/include"
fi
insert PATH "/opt/vagrant/bin"

alias f='find . -name'
export EDITOR=vim
#export TZ="/usr/share/zoneinfo/Australia/Sydney"
