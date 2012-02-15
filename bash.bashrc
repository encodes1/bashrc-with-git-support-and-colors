# System-wide .bashrc file for interactive bash(1) shells.

# To enable the settings / commands in this file for login shells as well,
# this file has to be sourced in /etc/profile.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, overwrite the one in /etc/profile)
PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '

# Commented out, don't overwrite xterm -T "title" -n "icontitle" by default.
# If this is an xterm set the title to user@host:dir
#case "$TERM" in
#xterm*|rxvt*)
#    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
#    ;;
#*)
#    ;;
#esac

# enable bash completion in interactive shells
#if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
#    . /etc/bash_completion
#fi

# if the command-not-found package is installed, use it
if [ -x /usr/lib/command-not-found -o -x /usr/share/command-not-found ]; then
	function command_not_found_handle {
	        # check because c-n-f could've been removed in the meantime
                if [ -x /usr/lib/command-not-found ]; then
		   /usr/bin/python /usr/lib/command-not-found -- $1
                   return $?
                elif [ -x /usr/share/command-not-found ]; then
		   /usr/bin/python /usr/share/command-not-found -- $1
                   return $?
		else
		   return 127
		fi
	}
fi

 # used bashrc from darren Worrall, edited to use git plugin and display username@host

# Color codes
RED='\[\033[01;31m\]'
GREEN='\[\033[01;32m\]'
YELLOW='\[\033[01;33m\]'
BLUE='\[\033[01;34m\]'
PURPLE='\[\033[01;35m\]'
CYAN='\[\033[01;36m\]'
WHITE='\[\033[01;37m\]'
NIL='\[\033[00m\]'

# Hostname styles
FULL='\H'
SHORT='\h'

# System => color/hostname map:
# HC: hostname color
# LC: location/cwd color
# HD: hostname display (\h vs \H)
# UC: username colour

# Defaults:
HC=$YELLOW
LC=$BLUE
HD=${HOSTNAME}
UC=$GREEN
# Manually cut hostname; hostname -s bails out on some systems.
case $( hostname | cut -d '.' -f 1 ) in
# yonah | yonah-nix | diamondville ) HC=$YELLOW LC=$GREEN HD=$SHORT ;;
    *-production ) HC=$RED HD=$SHORT ;;
    mail | code | www* | monitor | xen | penryn ) HC=$RED ;;
esac

# Highlight when we're a special user
case ${USER} in
    root | www-data ) UC=$RED ;;
esac

# Prompt function because PROMPT_COMMAND is awesome
function set_prompt() {
    # If logged in as another user, not gonna have all this firing anyway.
    # So let's just show the host only and be done with it.
    host="${HC}${HD}${NIL}"

    # Virtualenv
    _venv=`basename "$VIRTUAL_ENV"`
    venv="" # need this to clear it when we leave a venv
    if [[ -n $_venv ]]; then
venv=" ${NIL}{${PURPLE}${_venv}${NIL}}"
    fi
    # Dollar/hash
    end="${LC}\$ ${NIL}"

    # Working dir
    wd="${LC}\w"

    # bzr version
    if [[ -f .bzr/branch/last-revision ]];
    then
BZRVER=`cat .bzr/branch/last-revision| awk '{print $1}'`
        BZR=" ${RED}{bzr rev: ${BZRVER}}${NIL}"
    else
BZR=""
    fi

    # svn version
    if [[ -f .svn/entries ]];
    then
SVNVER=`svn info | grep Revision | awk '{print $NF}'`
        SVN=" ${RED}{svn rev: ${SVNVER}}${NIL}"
    else
SVN=""
    fi
    # Feels kind of like cheating...but works so well!
    #export PS1="${host}:${wd}${venv}${BZR}${SVN} ${UC}\u${end}"
    #export PS1='\u@\h \[\033[1;33m\]\w\[\033[0m\]$(parse_git_branch)$ '
    export PS1="${UC}\u@\h:${wd}${venv}${PURPLE} ${BZR}${SVN}$(parse_git_branch)${PURPLE}${end}"
    #export PS1="${UC}\u@\h:${wd}${venv} ${PURPLE}$(parse_git_branch)${RED}$(parse_git_dirty)${PURPLE}${end} "
    #export PS1 = '\u @ \h $(parse_git_branch) ${end}'
}
export PROMPT_COMMAND=set_prompt

# Dont store commands starting with a space in the history
export HISTIGNORE="[ ]*"
alias ls="ls -F"

function parse_git_dirty {
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit (working directory clean)" ]] && echo -e "\e[01;31m*\e[01;35m"
}
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/[\1$(parse_git_dirty)]/"
}

## Alias ##
## Git
alias gb='git branch -a -v'
alias gs='git status'
alias gd='git diff'

# gc      => git checkout master
# gc bugs => git checkout bugs
function gc {
  if [ -z "$1" ]; then
    git checkout master
  else
    git checkout $1
  fi
}




