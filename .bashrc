# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# reference:
# https://bluz71.github.io/2018/03/15/bash-shell-tweaks-tips.html

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# trim huge dir strings
PROMPT_DIRTRIM=4

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# autocorrect mispelled dirs
shopt -s cdspell dirspell

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=10000

# include local MANPATH (added for zoxide)
MANPATH=$HOME/.local/share/man:$MANPATH

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
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

if [ "$color_prompt" = yes ]; then
  PS1='${debian_chroot:+($debian_chroot)}\[\e[1;34m\]\u@\h\[\e[m\]:\[\e[1;33m\]\w$(__git_ps1 "\[\e[m\]:\[\e[1;36m\]%s")\[\e[m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


# mn ALL MN from here till alias import...

# color manpages
export LESS_TERMCAP_mb=$'\E[01;31m' # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m' # begin bold
export LESS_TERMCAP_me=$'\E[0m' # end mode
export LESS_TERMCAP_se=$'\E[0m' # end standout-mode
export LESS_TERMCAP_so=$'\E[38;5;246m' # begin standout-mode - info box export LESS_TERMCAP_ue=$'\E[0m' # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

# append history with every new command issued
# and share between concurrent sessions
PROMPT_COMMAND="history -a; history -n"

#
# CUSTOM FUNCTIONS
#

# 'a' gets you the package manager on ubuntu or tumbleweed
a() {
    if [ -f /etc/os-release ] && grep -q "ubuntu\|debian" /etc/os-release; then
        sudo apt "$@"
    elif [ -f /etc/os-release ] && grep -q "opensuse\|suse" /etc/os-release; then
        sudo zypper "$@"
    else
        echo "Unsupported distribution" >&2
        return 1
    fi
}

svim () {
  # X11 version
  # vimer $1 && xdotool search --name "GVIM" windowactivate --sync
  # Wayland version
  vimer $1 && raise "Gvim"
}

nv() {
    local sock=/tmp/nvim-$USER
    # clean up dead socket if needed
    if [ -S "$sock" ] && ! nvim --server "$sock" --remote-expr 1 >/dev/null 2>&1; then
        rm -f "$sock"
    fi
    if [ -S "$sock" ]; then
        if [ $# -eq 0 ]; then
            raise neovide
        else
            eval "set -- $*"
            nvim --server "$sock" --remote "$@"
            raise neovide
        fi
    else
        neovide -- --listen "$sock" "$@" &
    fi
}

# http://tuxdiary.com/2015/02/05/navigate-up-without-cd/
function up() {
  for ((i=1; i<=${1:-1}; i++));
  do
    cd ..
  done
}

#
# INTEGRATIONS
#

# zoxide integration
if command -v zoxide 1>/dev/null 2>&1; then
    eval "$(zoxide init bash)"
fi

# fzf integration
if command -v fzf 1>/dev/null 2>&1; then
    # for ubuntu >= 22.04
    if [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
        source /usr/share/doc/fzf/examples/key-bindings.bash
    fi
    # for ubuntu < 22.04
    if [ -f /usr/share/doc/fzf/examples/completion.bash ]; then
        source /usr/share/doc/fzf/examples/completion.bash
    fi
    # for opensuse
    if [ -f /usr/share/fzf/shell/key-bindings.bash ]; then
        source /usr/share/fzf/shell/key-bindings.bash
    fi
fi

# direnv integration
if command -v direnv 1>/dev/null 2>&1; then
    eval "$(direnv hook bash)"
fi

# pyenv completion
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

# django completion
if command -v "$HOME/.local/lib/django_bash_completion" 1>/dev/null 2>&1; then
    . "$HOME/.local/lib/django_bash_completion"
fi

# uv / uvx completion
if command -v uv 1>/dev/null 2>&1; then
    eval "$(uv generate-shell-completion bash)"
fi
if command -v uvx 1>/dev/null 2>&1; then
    eval "$(uvx --generate-shell-completion bash)"
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
