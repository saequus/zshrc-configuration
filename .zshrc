export LDFLAGS="-I/usr/local/opt/openssl/include -L/usr/local/opt/openssl/lib"
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export PATH="/usr/local/opt/gettext/bin:$PATH"
export PATH="/usr/local/opt/openssl/bin:$PATH"
export PATH="/usr/local/opt:$PATH"

export PYENV_ROOT=/usr/local/var/pyenv
PYTHONHOME=/usr/lib/python2.7
PYENV_ROOT="$HOME/.pyenv"
PATH="$PYENV_ROOT/bin:$PATH"
ZDOTDIR=~/.zsh

export PATH="$PATH:$HOME/bin:./node_modules/.bin/"
export PYTHONSTARTUP=~/.pythonrc

export EDITOR=vim
if ! command -v vim > /dev/null && command -v nvim > /dev/null; then
    export EDITOR=nvim
    alias vim='nvim'
    alias vimdiff='nvim -d'
fi

if [ -n "$DISPLAY" ]; then
    export TERM=xterm-256color
    [ -n "$TMUX" ] && export TERM=screen-256color
fi

bindkey -e
REPORTTIME=2

export HISTTIMEFORMAT="%t%d.%m.%y %H:%M:%S%t"
export HISTIGNORE="&:ls:[bf]g:exit"
HISTFILE=~/.zsh/history.log
HISTSIZE=2000
SAVEHIST=$HISTSIZE
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_find_no_dups
setopt appendhistory
setopt sharehistory

# bind UP and DOWN arrow keys
# next two lines work locally
bindkey '\e[A' history-beginning-search-backward
bindkey '\e[B' history-beginning-search-forward
# next two lines work over ssh
[[ -n "${key[Up]}" ]] && bindkey "${key[Up]}" history-beginning-search-backward
[[ -n "${key[Down]}" ]] && bindkey "${key[Down]}" history-beginning-search-forward

setopt autocd
setopt notify
setopt extendedglob
unsetopt beep
unsetopt nomatch
unsetopt correct_all

# type a directory's name to cd to it
compctl -/ cd

autoload -Uz compinit; compinit

zstyle ':completion:*' completer _expand _complete _match _ignored _files
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' max-errors 1
zstyle ':completion:*' menu select=long-list select=0
zstyle ':completion:*' verbose true
zstyle ':completion:*' group-name ''

# tab completion for PID :D
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always
zstyle ':completion:*:processes' command 'ps -xuf'
zstyle ':completion:*:processes' sort false
zstyle ':completion:*:processes-names' command 'ps xho command'

# project based .venv file for virtualenv activation, etc.
venv_cd() {
    if builtin cd "$@"; then
        if [ -e .venv ]; then
            VIRTUAL_ENV_DISABLE_PROMPT=1
            source .venv
            command -v python
        fi
        return 0
    else
        return $?
    fi
}
venv_info() {
    if [ $VIRTUAL_ENV ]; then
        echo "%F{blue}[%F{cyan}env: %B`basename $VIRTUAL_ENV`%b%F{blue}] "
    fi
}

### Aliases
alias cd="venv_cd"

alias ll='ls -l'
alias python3.5="/usr/local/bin/python3.5"
alias du='du --human-readable --total -d0'
alias df='df --human-readable'
alias grep='grep --color=auto'
alias killall="killall --interactive --verbose"
alias tmux='tmux -2'
alias nohup='nohup > /dev/null $1'
alias free="free -t -m"

alias wifi-menu="sudo wifi-menu"

alias ssha='eval $(ssh-agent) && ssh-add ~/.ssh/id_rsa && echo SSH_AUTH_SOCK=$SSH_AUTH_SOCK'

alias pacmanc="sudo pacman --config=/home/pacman/pacman.conf"
alias pacaur="pacaur --rebuild"
alias cower="cower --color=auto --rsort=votes"

if [[ "$TERM" == *256* ]]; then
    alias mc="mc -S modarin256"
else
    alias mc="mc -S default"
fi

alias o=xdg-open
alias myip="curl ip.appspot.com"
alias timesync='sudo ntpdate ua.pool.ntp.org'
alias rsyncc='rsync -aAXHvh --stats'
alias rsyncp='rsync -rth --progress --stats'
alias rand16='openssl rand -hex 16'

alias pipi="pip install"
alias pipu="pip uninstall"
alias pipw="pip wheel"
alias pips="pip search"

alias pyclean="find . -name \"*.pyc\" -exec rm -rf {} \;"
alias pysmtpd="python -m smtpd -n -c DebuggingServer localhost:1025"

alias dockerc='\
    v=$(docker ps -q) && [ -n "$v" ] && docker stop $(echo $v);\
    v=$(docker ps -a -q) && [ -n "$v" ] && docker rm $(echo $v);\
    v=$(docker images -qf "dangling=true") && [ -n "$v" ] && docker rmi $(echo $v);\
    docker images\
'

alias lxc-ls='sudo lxc-ls'
alias lxc-destroy='sudo lxc-destroy'
alias lxc-start='sudo lxc-start'
alias lxc-stop='sudo lxc-stop'
alias lxc-attach='sudo lxc-attach'

### Prompt
autoload colors; colors
setopt prompt_subst

# Decide if we need to set titlebar text.
case $TERM in
    (xterm*|rxvt)
        titlebar_precmd () { print -Pn "\e]0;%n@%m: %~\a" }
        titlebar_preexec () { print -Pn "\e]0;$1 %n@%m: %~\a" }
        ;;
    (screen*)
        titlebar_precmd () { print -Pn "\e]0;%n@%m: %~ $1\a" }
        titlebar_preexec () { print -Pn "\e]0;%n@%m: %~ $1\a" }
        ;;
    (*)
        titlebar_precmd () {}
        titlebar_preexec () {}
        ;;
esac
precmd () {
    titlebar_precmd $*
}
preexec () {
    titlebar_preexec $*
}

# VCS info
autoload -Uz vcs_info

zstyle ':vcs_info:*' stagedstr '%F{28} ●'
zstyle ':vcs_info:*' unstagedstr '%F{11} ●'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{11}%r'
zstyle ':vcs_info:*' enable git hg svn
precmd () {

    if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]] {
        zstyle ':vcs_info:*' formats '%F{blue}[%F{green}%b%c%u%F{blue}] '
    } else {
        zstyle ':vcs_info:*' formats '%F{blue}[%F{green}%b%c%u%F{red} ●%F{blue}] '
    }
    vcs_info
    titlebar_precmd
}

pwd_length() {
  local length
  (( length = $COLUMNS / 2 - 25 ))
  echo $(($length < 20 ? 20 : $length))
}

# red, green, yellow, blue, magenta, cyan, white, black
# B(bold), K(background color), F(foreground color)
# %F{yellow} - make the foreground color yellow
# %f - reset the foreground color to the default
p_user_host='%f%B%(!.%F{red}.%F{green})'`if [[ ! $HOME == */$USER ]] echo '%n@'`'%m%b:'
p_time='%f%F{magenta}[%T] '
p_pwd='%f%B%F{blue}%$(pwd_length)<...<%(!.%/.%~)%<< %b'
p_vcs_info='%f${vcs_info_msg_0_}'
p_venv_info='%f$(venv_info)'
p_exit_code='%f%F{red}%(0?..%? ↵)'
p_jobs='%f%F{cyan}%1(j.(%j) .)'
p_sigil='%f%B%F{green}%(!.%F{red}.)\$ '
p_end='%f%b'

# left
PS1="$p_time$p_user_host$p_pwd$p_venv_info$p_vcs_info$p_jobs$p_exit_code
$p_sigil$p_end%f"

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

