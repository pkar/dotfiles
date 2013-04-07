# If not running interactively, don't do anything
[ -z "$PS1" ] && return

if [ -f /etc/bashrc ]; then
	. /etc/bashrc   # --> Read /etc/bashrc, if present.
fi

export EDITOR=$(which vim)

txtblk='\[\e[0;30m\]' # Black - Regular
txtred='\[\e[0;31m\]' # Red
txtgrn='\[\e[0;32m\]' # Green
txtylw='\[\e[0;33m\]' # Yellow
txtblu='\[\e[0;34m\]' # Blue
txtpur='\[\e[0;35m\]' # Purple
txtcyn='\[\e[0;36m\]' # Cyan
txtwht='\[\e[0;37m\]' # White
bldblk='\[\e[1;30m\]' # Black - Bold
bldred='\[\e[1;31m\]' # Red
bldgrn='\[\e[1;32m\]' # Green
bldylw='\[\e[1;33m\]' # Yellow
bldblu='\[\e[1;34m\]' # Blue
bldpur='\[\e[1;35m\]' # Purple
bldcyn='\[\e[1;36m\]' # Cyan
bldwht='\[\e[1;37m\]' # White
unkblk='\[\e[4;30m\]' # Black - Underline
undred='\[\e[4;31m\]' # Red
undgrn='\[\e[4;32m\]' # Green
undylw='\[\e[4;33m\]' # Yellow
undblu='\[\e[4;34m\]' # Blue
undpur='\[\e[4;35m\]' # Purple
undcyn='\[\e[4;36m\]' # Cyan
undwht='\[\e[4;37m\]' # White
bakblk='\[\e[40m\]'   # Black - Background
bakred='\[\e[41m\]'   # Red
bakgrn='\[\e[42m\]'   # Green
bakylw='\[\e[43m\]'   # Yellow
bakblu='\[\e[44m\]'   # Blue
bakpur='\[\e[45m\]'   # Purple
bakcyn='\[\e[46m\]'   # Cyan
bakwht='\[\e[47m\]'   # White
txtrst='\[\e[0m\]'    # Text Reset

export PS1="\n${txtgrn}[\u@\H] ${txtwht}\! ${bldwht}\w \T \$(if [[ \$? == 0 ]]; then echo \"${txtgrn}:)\"; else echo \"${txtred}:(\"; fi) ${txtcyn}\$(parse_git_branch)\n${bldwht}$ "
export PATH=/usr/local/bin:~/go/bin:$PATH
export GOROOT=~/go/
export GOBIN=~/go/bin/

# History across tabs
export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
shopt -s histappend                      # append to history, don't overwrite it
# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias pyclean='find . -name "*.pyc" -print0|xargs -0 rm'
alias ds_store_clean='find . -name ".DS_Store" -print0|xargs -0 rm'
alias showhidden='defaults write com.apple.finder AppleShowAllFiles -bool YES; killall Finder'
alias hidehidden='defaults write com.apple.finder AppleShowAllFiles -bool NO'
alias rmempty='find . -type f -empty -not -name "__init__.py" -not -name "Icon" -exec rm -f {} \;'
alias gopath='export GOPATH=$(pwd)'
alias vb_login="ssh -p 2222 ubuntu@127.0.0.1"
alias vb_scp="scp -P 2222" # /path/to/file ubuntu@127.0.0.1:~/
alias vpnch="sudo chown -R root /usr/local/juniper/nc/7.1.0/*"
alias ip="ifconfig | grep \"inet .*broadcast.*\" | head -n 1 | sed 's/^.*inet\ *\(.*\)\ netmask.*$/\1/'"
alias ls="ls -G"
alias la="ls -lAhG"
alias deldlist="sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'select LSQuarantineDataURLString from LSQuarantineEvent'"
alias deld="sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent'"
alias be="bundle exec"
alias h='history'
alias j='jobs -l'
alias which='type -a'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'
alias du='du -kh'    # Makes a more readable output.
alias df='df -kTh'

parse_git_branch() {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(git::\1)/'
}

# Determine size of a file or total size of a directory
function fs() {
	if du -b /dev/null > /dev/null 2>&1; then
		local arg=-sbh
	else
		local arg=-sh
	fi
	if [[ -n "$@" ]]; then
		du $arg -- "$@"
	else
		du $arg .[^.]* *
	fi
}

function rmall {
  find . -name $1 -exec rm -rf {} \;
}

# Start an HTTP server from a directory, optionally specifying the port
function server() {
	local port="${1:-8000}"
	sleep 1 && open "http://localhost:${port}/" &
	# Set the default Content-Type to `text/plain` instead of `application/octet-stream`
	# And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
	python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port"
}

# All the dig info
function digga() {
	dig +nocmd "$1" any +multiline +noall +answer
}

# redis 267 6379
function redis () {
  if [ -f ~/Library/LaunchAgents/homebrew.mxcl.redis.plist ]; then
    brew uninstall redis
    launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.redis.plist
    sudo rm ~/Library/LaunchAgents/*redis*
  fi

  export ROOT="$(pwd)"
  mkdir -p ~/.dbs
  cd ~/.dbs/

  versions=("2.6.7" "2.4.18" "2.0.4")
  for i in $versions
  do
    ver=$(echo $i | sed "s/\.//g")
    if [ ! -f ~/.dbs/redis$ver/src/redis-server ] && [ ! -f ~/.dbs/redis$ver/redis-server ]; then
      echo pwd
      cd ~/.dbs/
      wget "http://redis.googlecode.com/files/redis-$i.tar.gz"
      tar xzfv redis-$i.tar.gz
      rm redis-$i.tar.gz
      mv redis-$i redis$ver
      cd redis$ver
      make
      cd ~/.dbs/
    fi
  done

  cd $ROOT
  unset ROOT

  ver=$(echo $1 | sed "s/\.//g")
  if [ -e ~/.dbs/redis$ver/src/redis-server ]; then
	  ~/.dbs/redis$ver/src/redis-server --port "$2"
  else
	  echo "port $2" | ~/.dbs/redis$ver/redis-server -
  fi
}

# cassandra 0710
function cassandra () {
  
  if [ ! -e $(which java) ]; then
    if [ "$(uname)" == "Darwin" ]; then
      echo "Install Java first"
			exit
    else
      sudo apt-get install openjdk-6-jdk
    fi
  fi

  export ROOT="$(pwd)"
  mkdir -p ~/.dbs
  cd ~/.dbs/

  versions=("0.7.10")
  for i in $versions
  do
    cd ~/.dbs/
    ver=$(echo $i | sed "s/\.//g")
 
    if [ ! -d ~/.dbs/cassandra$ver ]; then
      wget "http://mir2.ovh.net/ftp.apache.org/dist/cassandra/$i/apache-cassandra-$i-bin.tar.gz"
      tar xzfv apache-cassandra-$i-bin.tar.gz
      rm apache-cassandra-$i-bin.tar.gz
      mv apache-cassandra-$i cassandra$ver
    fi

    sudo mkdir -p /var/log/cassandra
    sudo mkdir -p /var/lib/cassandra
    sudo chown -R $(whoami):admin /var/log/cassandra
    touch /var/log/cassandra/system.log
    sudo chown -R $(whoami):admin /var/lib/cassandra
  done
  cd $ROOT
  unset ROOT

	~/.dbs/cassandra$1/bin/cassandra start
}

function rabbit () {
  if [ ! -e $(which erl) ]; then
    if [ "$(uname)" == "Darwin" ]; then
      brew install erlang
    else
      sudo apt-get install erlang
    fi
  fi

  export ROOT="$(pwd)"
  mkdir -p ~/.dbs
  cd ~/.dbs/

  versions=("3.0.1")
  for i in $versions
  do
    cd ~/.dbs/
    ver=$(echo $i | sed "s/\.//g")
 
    if [ ! -d ~/.dbs/ver ]; then
      wget http://www.rabbitmq.com/releases/rabbitmq-server/v3.0.1/rabbitmq-server-generic-unix-3.0.1.tar.gz
      tar xzfv apache-cassandra-$i-bin.tar.gz
      #rm apache-cassandra-$i-bin.tar.gz
      #mv apache-cassandra-$i cassandra$ver
    fi
  done

  cd $ROOT
  unset ROOT

	#~/.dbs/rabbit$1/bin/cassandra start

}

function pss () {
  ps -ef | grep $1
}

function coffees () {
  coffee --bare --watch --compile *.coffee &
}

function my_ps() { ps $@ -u $USER -o pid,%cpu,%mem,bsdtime,command ; }
function pp() { my_ps f | awk '!/awk/ && $0~var' var=${1:-".*"} ; }

function killps() {
	local pid pname sig="-TERM"   # default signal
	if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
		echo "Usage: killps [-SIGNAL] pattern"
		return;
	fi
	if [ $# = 2 ]; then sig=$1 ; fi
	for pid in $(my_ps| awk '!/awk/ && $0~pat { print $1 }' pat=${!#} )
	do
		pname=$(my_ps | awk '$1~var { print $5 }' var=$pid )
		if ask "Kill process $pid <$pname> with signal $sig?"
				then kill $sig $pid
		fi
	done
}

function repeat() {
	local i max
	max=$1; shift;
	for ((i=1; i <= max ; i++)); do  # --> C-like syntax
			eval "$@";
	done
}


if [ "${BASH_VERSION%.*}" \< "3.0" ]; then
	echo "You will need to upgrade to version 3.0 for full \
		programmable completion features"
	return
fi
shopt -s extglob        # Necessary.

complete -A hostname   rsh rcp telnet rlogin ftp ping disk
complete -A export     printenv
complete -A variable   export local readonly unset
complete -A enabled    builtin
complete -A alias      alias unalias
complete -A function   function
complete -A user       su mail finger

complete -A helptopic  help     # Currently same as builtins.
complete -A shopt      shopt
complete -A stopped -P '%' bg
complete -A job -P '%'     fg jobs disown

complete -A directory  mkdir rmdir
complete -A directory   -o default cd
complete -W "$(echo `cat ~/.ssh/known_hosts | cut -f 1 -d ' ' | sed -e s/,.*//g | uniq | grep -v "\["`;)" ssh

