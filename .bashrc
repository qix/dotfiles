# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

txtblk='\e[0;30m' # Black - Regular
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtblu='\e[0;34m' # Blue
txtpur='\e[0;35m' # Purple
txtcyn='\e[0;36m' # Cyan
txtwht='\e[0;37m' # White
bldblk='\e[1;30m' # Black - Bold
bldred='\e[1;31m' # Red
bldgrn='\e[1;32m' # Green
bldylw='\e[1;33m' # Yellow
bldblu='\e[1;34m' # Blue
bldpur='\e[1;35m' # Purple
bldcyn='\e[1;36m' # Cyan
bldwht='\e[1;37m' # White
unkblk='\e[4;30m' # Black - Underline
undred='\e[4;31m' # Red
undgrn='\e[4;32m' # Green
undylw='\e[4;33m' # Yellow
undblu='\e[4;34m' # Blue
undpur='\e[4;35m' # Purple
undcyn='\e[4;36m' # Cyan
undwht='\e[4;37m' # White
bakblk='\e[40m'   # Black - Background
bakred='\e[41m'   # Red
badgrn='\e[42m'   # Green
bakylw='\e[43m'   # Yellow
bakblu='\e[44m'   # Blue
bakpur='\e[45m'   # Purple
bakcyn='\e[46m'   # Cyan
bakwht='\e[47m'   # White
txtrst='\e[0m'    # Text Reset

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

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
#force_color_prompt=yes

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

# Ignore duplicates and lines starting with space
export HISTCONTROL="ignoreboth"

# Reduce clutter in the history
export HISTIGNORE='&:exit:fc:history:ht'

# Timestamp the history entries (important!!)
export HISTTIMEFORMAT="%Y-%m-%d %T "

# Long session history (default is 500)
export HISTSIZE=3000

# Long history file (default is 500)
export HISTFILESIZE=50000


# Today's history
function ht { history | grep "$(date +%Y-%m-%d)" $@; }

# Grep history
alias h='history|grep'

# Update history from other shells
alias hu='history -n' 

## ls aliases
alias l='ls -l'      # long listing
alias ll='ls -lhvrt'     # long listing
alias l.='ls -ld .*' # dotfiles only
alias l1='ls -1'     # one file per line
alias la='ls -la'    # list all files
alias lr='ls -R'     # recursive listing
alias lR='ls -laR'   # all-inclusive recurse
alias lld='ls -lUd */' # list directories

## Up-directory aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

function mkcd { [ -n "$1" ] && mkdir -p "$@" && cd "$1"; }

## Import SSH agent environment into existing screen session
if [[ -x "$(type -p screen)" ]]; then
    function grabssh {
        SSHVARS="SSH_CLIENT SSH_TTY SSH_AUTH_SOCK SSH_CONNECTION DISPLAY"
        for x in ${SSHVARS} ; do
            (eval echo $x=\$$x) | sed  's/=/="/
                                       s/$/"/
                                       s/^/export /'
        done
    }
    alias screen_attach='grabssh > $HOME/.fixssh; screen -d -R'
    alias screen_fixssh='source $HOME/.fixssh'
fi

## Get geographic location for IP address
function geoip {
    IP="$1"
    if [[ -z "$1" ]]; then
       IP=$(curl -s icanhazip.com)
    fi
    curl -s "http://www.geody.com/geoip.php?ip=$IP" | sed '/^IP:/!d;s/<[^>][^>]*>//g'
}


function urlquote {
	python -c "import urllib; print urllib.quote_plus(\"$*\")"
}


prompt_git_branch() {
    if type -p __git_ps1; then
        branch=$(__git_ps1 '%s')
        if [ -n "$branch" ]; then
					echo -e "$branch:"
        fi
    fi
}
prompt_git_branch_color() {
    if type -p __git_ps1; then
        branch=$(__git_ps1 '%s')
        if [ -n "$branch" ]; then
            status=$(git status 2> /dev/null)

            if $(echo $status | grep 'added to commit' &> /dev/null); then
                # If we have modified files but no index (blue)
                echo -e "\033[1;34m$branch\033[0m:"
            else
                if $(echo $status | grep 'to be committed' &> /dev/null); then
                    # If we have files in index (red)
                    echo -e "\033[1;31m$branch\033[0m:"
                else
                    # If we are completely clean (green)
                    echo -e "\033[1;32m$branch\033[0m:"
                fi
            fi
        fi
    fi
}

WHITE="\[\033[1;37m\]"

color_prompt="yes"
if [ "$color_prompt" = yes ]; then
    #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:$(prompt_git_branch_color)\[\033[01;34m\]\w\[\033[0m\]\$ '
    PS1='${debian_chroot:+($debian_chroot)}\u@\h\[\033[00m\]:$(prompt_git_branch_color)\w\$ '
else
	PS1="${debian_chroot:+($debian_chroot)}\u@\h:\w\[$bakblk\]$(prompt_git_branch)\[$txtrst\]\$ "
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
