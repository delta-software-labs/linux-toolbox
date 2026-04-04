#!/bin/sh

################################################################################
#									       #
#				APT					       #
#									       #
################################################################################

# Function:	Configuration of apt.
# Parameters:	The 1st parameter contains the action to perform.
#		Valid actions: config, revert.
# Returns:	None.
setup_apt () {
  local action file line lines
  file="/etc/issue.net" 
  # Only do for Debian 13 Trixie.
  if [ ! -f "${file}" ] || [ "$(sed -e "s/.* //g" "${file}")" != "13" ]; then
    return
  fi
  action="$1"
  file="/etc/apt/sources.list"
  lines="
    deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
    deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
    deb http://deb.debian.org/debian trixie-proposed-updates main contrib non-free non-free-firmware
    deb http://deb.debian.org/debian trixie-backports main contrib non-free non-free-firmware
    deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
  "
  lines="$(echo "${lines}" | sed -e "s/^ *//g" | grep --invert-match "^$")"
  substitues="
    main non-free-firmware | main contrib non-free non-free-firmware
  "
  substitutes="$(echo "${substitutes}" | sed -e "s/^ *//g" | grep --invert-match "^$")"
  if [ "${action}" = "config" ]; then
    echo "${lines}" | while read line; do
      append_line "${file}" "${line}"
    done
  elif [ "${action}" = "revert" ]; then
    echo "${lines}" | while read line; do
      remove_line "${file}" "${line}"
    done
  else
    echo "Invalid action: ${action}".
  fi
}

# deb     http://deb.debian.org/debian/ trixie main non-free-firmware
# deb-src http://deb.debian.org/debian/ trixie main non-free-firmware
# deb     http://security.debian.org/debian-security trixie-security main non-free-firmware
# deb-src http://security.debian.org/debian-security trixie-security main non-free-firmware
# deb     http://deb.debian.org/debian/ trixie-updates main non-free-firmware
# deb-src http://deb.debian.org/debian/ trixie-updates main non-free-firmware


# deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
# deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
# deb http://deb.debian.org/debian trixie-proposed-updates main contrib non-free non-free-firmware
# deb http://deb.debian.org/debian trixie-backports main contrib non-free non-free-firmware
# deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware

################################################################################
#									       #
#				BASH					       #
#									       #
################################################################################

# Function:	Configuration of bash shell.
# Parameters:	None.
# Remarks:	Configures the bash shell. Adds new skeleton files.
#		Copies the skeleton files to all user accounts.
#		Adjusts the prompt for root and all users.
#		Changes the color of the root prompt from lime to red.
#		Enables ANSI color output by unsetting the NO_COLOR variable.
# Returns:	None.
config_bash () {
  local file user users
  # Add skeleton files.
  file="/etc/skel/.bash_aliases"
  # Use single quotes around EOF to prevent interpreting variables.
cat << 'EOF' | sed -e "s/^  //" > "${file}"
  # Set default editor.
  export EDITOR=vi
  export VISUAL=vi
  # Enable ansi color output in interactive shells, except for crontab.
  unset NO_COLOR
  # Do not put duplicate lines or lines starting with space in history.
  export HISTCONTROL=ignoreboth
  # Append to history file, do not overwrite it.
  shopt -s histappend
  # Set history length.
  export HISTSIZE=10000
  export HISTFILESIZE=20000
  # Needed for openbox installation.
  export NCURSES_NO_UTF8_ACS=1
  # Disable <Ctrl-d> to prevent accidental log out.
  set -o ignoreeof
  # Don't echo control characters.
  if $(tty -s); then
    stty -echoctl
  fi
  # Show date, time in white, show user and hostname in lime, show working directory in blue.
  # The "\[\e]0;\u@\h\a\]" string is used to change the PuTTY window title.
  # It will also get rid of the annoying "Thanks for flying Vim" title.
  PS1='\[\e]0;\u@\h\a\]${debian_chroot:+($debian_chroot)}\[\033[01;37m\]\D{%Y-%m-%d} \t \[\033[01;32m\]\u@\h\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\]\$ '
  # Alias definitions.
  if [ -f ~/.bashrc_aliases ]; then
    . ~/.bashrc_aliases
  fi
EOF
  file="/etc/skel/.bashrc_aliases"
  # Do not use single quotes around EOF to allow interpreting variables.
cat << EOF | sed -e "s/^  //" > "${file}"
  # A trailing space in the alias value causes the next word to be checked
  # for alias substitution when the alias is expanded. E.g. "sudo dir /".
  alias sudo='sudo '
  # Alias for hexadecimal dump.
  alias hex='od -t x1'
  # Aliases for diff that ignore case and white space.
  alias diff-i='diff -i'
  alias diff-w='diff -w'
  alias diff-iw='diff -i -w'
  # Aliases for git.
  alias git-diff='git difftool -x "/usr/bin/diff" -y'
  alias git-diff-c='git difftool -x "/usr/bin/diff --color" -y'
  alias git-diff-i='git difftool -x "/usr/bin/diff -i" -y'
  alias git-diff-w='git difftool -x "/usr/bin/diff -w" -y'
  alias git-diff-iw='git difftool -x "/usr/bin/diff -iw" -y'
  alias git-diff-icw='git difftool -x "/usr/bin/diff --color -iw" -y'
  alias git-incoming='git fetch && git log ..origin'
  alias git-log='git log --pretty=format:"%C(yellow)Commit %h%Creset%nAuthor: %an <%ae>%nDate: %ai%nMessage: %s%n"'
  alias git-outgoing='git fetch && git log origin..'
  alias git-status='git status -s'
  # Exclude Git repository, Node.js modules, Bootstrap, Bootbox, Cordova and jQuery libraries.
  alias jsdiff='diff --exclude=.git --exclude=node_modules --exclude=bootstrap* --exclude=bootbox* --exclude=cordova* --exclude=*jquery* --exclude=*.min.css --exclude=*.min.js'
  alias jsgrep='grep --exclude-dir=.git --exclude-dir=node_modules --exclude=bootstrap* --exclude=bootbox* --exclude=cordova* --exclude=*jquery* --exclude=*.min.css --exclude=*.min.js'
  alias jslint='jslint --browser --indent=2 --maxerr=999 --nomen --white --windows'
  alias jshint-all='find . -path "*node_modules*" -prune -o ! -iname "*.min.js" ! -iname "bootstrap*" ! -iname "bootbox*" ! -iname "cordova*" ! -iname "*jquery*" ! -size 0 -iname "*.js" -exec jshint {} \;'
  alias jslint-all='find . -path "*node_modules*" -prune -o ! -iname "*.min.js" ! -iname "bootstrap*" ! -iname "bootbox*" ! -iname "cordova*" ! -iname "*jquery*" ! -size 0 -iname "*.js" -exec jslint --browser --indent=2 --maxerr=999 --nomen --white --windows {} \;'
  # Fix syntax highlighting when editing crontab.
  # See https://unix.stackexchange.com/questions/68972/no-syntax-highlighting-when-editing-crontab
  alias crontab='EDITOR=vi crontab'
  # JSLint customization.
  # Note: Options give problems when added alphabetically.
  alias jslint='jslint --todo --nomen --white --windows --browser --indent=2 --unparam --maxerr=999'
  # Several aliases for list command.
  # The LC_COLLATE=C makes the ls command show hidden files and folders first.
  alias vdir='ls --color=auto --escape --show-control-chars -l'
  alias dir='ls --color=auto --escape --show-control-chars'
  alias ls='LC_COLLATE=C ls --color=auto --show-control-chars'
  alias ll='LC_COLLATE=C ls --color=auto --show-control-chars -l'
  alias l='ls --color=auto --show-control-chars -lA'
  # Some aliases to prevent making mistakes.
  alias cp='cp -i'
  alias mv='mv -i'
  alias rm='rm -i'
  # Some wifi aliases.
  alias iw-scan='iw dev wlan0 scan | grep -Ei "^BSS|freq:|signal:|SSID:" | grep -Eiv "HESSID:"'
  alias iwlist-scan='iwlist wlan0 scan | grep -Ei "Cell|Freq|Qual|SSID"'
EOF
  # Back up original .bashrc file of root account.
  backup_file "/root/.bashrc"
  # Copy skeleton files to root account.
  /bin/cp -a /etc/skel/.bash_aliases /root
  /bin/cp -a /etc/skel/.bashrc /root
  /bin/cp -a /etc/skel/.bashrc_aliases /root
  # Get local user accounts.
  users="$(awk -F: '($3>=1000)&&($7!="/bin/false")&&($7!="/usr/sbin/nologin"){print $1}' /etc/passwd)"
  # Copy skeleton files to all user accounts.
  # Do not double quote to allow globbing and word splitting.
  for user in ${users}; do
    # Back up original .bashrc file of user account.
    backup_file "/home/${user}/.bashrc"
    # Copy skeleton files to user account.
    /bin/cp -a /etc/skel/.bash_aliases "/home/${user}"
    /bin/cp -a /etc/skel/.bashrc "/home/${user}"
    /bin/cp -a /etc/skel/.bashrc_aliases "/home/${user}"
    chown "${user}:${user}" "/home/${user}/.bash_aliases"
    chown "${user}:${user}" "/home/${user}/.bashrc"
    chown "${user}:${user}" "/home/${user}/.bashrc_aliases"
  done
  # Change color of root prompt from lime to red.
  sed -i "s/lime/red/"  /root/.bash_aliases
  sed -i "s/;32m/;31m/" /root/.bash_aliases
}

# Function:	Undo configuration of bash shell.
# Parameters:	None.
# Remarks:	Restores the bash shell. Removes the new skeleton files.
#		Removes the copied skeleton files from all user accounts.
#		Restores the prompt for all users.
#		Disables ANSI color output.
# Returns:	None.
revert_bash () {
  local file user users
  # Remove skeleton files for root account.
  file="/etc/skel/.bash_aliases"
  if [ -f "${file}" ]; then
    rm -f "${file}"
  fi
  file="/etc/skel/.bashrc_aliases"
  if [ -f "${file}" ]; then
    rm -f "${file}"
  fi
  # Remove skeleton files from root account.
  file="/root/.bash_aliases"
  if [ -f "${file}" ]; then
    rm -f "${file}"
  fi
  file="/root/.bashrc_aliases"
  if [ -f "${file}" ]; then
    rm -f "${file}"
  fi
  # Restore original .bashrc file of root account.
  file="/root/.bashrc"
  if [ -f "${file}.org" ]; then
    mv -f "${file}.org" "${file}"
  fi
  # Get local user accounts.
  users="$(awk -F: '($3>=1000)&&($7!="/bin/false")&&($7!="/usr/sbin/nologin"){print $1}' /etc/passwd)"
  # Remove skeleton files for all user accounts.
  # Do not double quote to allow globbing and word splitting.
  for user in ${users}; do
    file="/home/${user}/.bash_aliases"
    if [ -f "${file}" ]; then
      rm -f "${file}"
    fi
    file="/home/${user}/.bashrc_aliases"
    if [ -f "${file}" ]; then
      rm -f "${file}"
    fi
    # Restore original .bashrc file of user account.
    file="/home/${user}/.bashrc"
    if [ -f "${file}.org" ]; then
      mv -f "${file}.org" "${file}"
    fi
  done
}

################################################################################
#									       #
#				CRON					       #
#									       #
################################################################################

# Function:	Configuration of cron.
# Parameters:	The 1st parameter contains the action to perform.
#		Valid actions: config, revert.
# Returns:	None.
setup_cron () {
  local action file line lines
  action="$1"
  file="/etc/environment"
  lines="
    # Prevent ANSI color output in cron jobs.
    NO_COLOR=true
  "
  lines="$(echo "${lines}" | sed -e "s/^ *//g" | grep --invert-match "^$")"
  if [ "${action}" = "config" ]; then
    echo "${lines}" | while read line; do
      append_line "${file}" "${line}"
    done
  elif [ "${action}" = "revert" ]; then
    echo "${lines}" | while read line; do
      remove_line "${file}" "${line}"
    done
  else
    echo "Invalid action: ${action}."
  fi
}

################################################################################
#									       #
#				DATE					       #
#									       #
################################################################################

# Function:	Configuration of date format.
# Parameters:	The 1st parameter contains the action to perform.
#		Valid actions: config, revert.
# Returns:	None.
setup_date () {
  local action file line lines
  action="$1"
  file="/etc/environment"
  lines="
    # Set ISO 8601 international date format.
    TIME_STYLE='+%Y-%m-%d %H:%M:%S'
  "
  lines="$(echo "${lines}" | sed -e "s/^ *//g" | grep --invert-match "^$")"
  if [ "${action}" = "config" ]; then
    echo "${lines}" | while read line; do
      append_line "${file}" "${line}"
    done
  elif [ "${action}" = "revert" ]; then
    echo "${lines}" | while read line; do
      remove_line "${file}" "${line}"
    done
  else
    echo "Invalid action: ${action}."
  fi
}

################################################################################
#									       #
#				EDITOR					       #
#									       #
################################################################################

# Function:	Configuration of the default editor.
# Parameters:	None.
# Remarks:	Sets the default editor for all users to vim.basic.
# Returns:	None.
config_editor () {
# local editor file folder user users
  # Check vim is installed.
  if ! which -s vim.basic; then
    return
  fi
# editor="$(update-alternatives --display editor |
#   grep "link currently points to" |
#   sed "s/^.*link currently points to //"
# )"
  # Back up symbolic link of original default editor.
  backup_file "/etc/alternatives/editor"
  # Make vim.basic the default editor.
  update-alternatives --set editor /usr/bin/vim.basic
}

# Function:	Undo configuration of the default editor.
# Parameters:	None.
# Remarks:	Restores the default editor for all users.
# Returns:	None.
revert_editor () {
  local editor file
  # Check vim is installed.
  if ! which -s vim.basic; then
    return
  fi
  # Restore default editor.
  file="/etc/alternatives/editor"
# if [ -f "${file}.org" ]; then
#   mv -f "${file}.org" "${file}"
# fi
  if [ -f "${file}.org" ]; then
    editor="$(ls -al "${file}.org" | sed -e "s/^.* //g")"
    update-alternatives --set editor "${editor}"
  fi
# editor="$(update-alternatives --display editor |
#   grep "link currently points to" |
#   sed "s/^.*link currently points to //"
# )"
# if ! echo "${editor}" | grep --quiet "vim.tiny"; then
#   update-alternatives --set editor "${editor}"
# fi
}

################################################################################
#									       #
#				SUDO					       #
#									       #
################################################################################

# Function:	Configuration of sudo for Debian.
# Parameters:	None.
# Remarks:	Configures sudo to ask for the root password instead of the
#		user password, but only if the root password has been set.
#		Enables sudo and removes the first time lecture about sudo
#		for all users.
# Returns:	None.
config_sudo () {
  local file user users
  # Only do for Debian.
  if ! grep --ignore-case --no-messages --quiet "Debian" "/etc/issue.net"; then
    return
  fi
  # Check sudo is installed.
  if ! which -s sudo; then
    return
  fi
  file="/etc/sudoers"
  # Back up original file if backup file is missing.
  backup_file "${file}"
  # Check root password has been set.
  if grep --quiet "^root:\*:" /etc/shadow; then
    echo "${YELLOW}:: Skipped making sudo ask for root password, due to no root password set.${RESET}"
  else
    # Make sudo ask for root password.
    if ! grep --ignore-case --quiet "Defaults[[:space:]]rootpw" "${file}"; then
      sed -i "/Defaults\tmail_badpass$/a Defaults\trootpw" "${file}"
    fi
  fi
  # Get local user accounts.
  users="$(awk -F: '($3>=1000)&&($7!="/bin/false")&&($7!="/usr/sbin/nologin"){print $1}' /etc/passwd)"
  # Do not double quote to allow globbing and word splitting.
  for user in ${users}; do
    # Allow user account to use sudo.
    if ! grep --quiet "^sudo.*${user}" /etc/group; then
      usermod --append --groups sudo "${user}"
    fi
    # Remove first time lecture about sudo.
    mkdir -p "/var/lib/sudo/lectured"
    file="/var/lib/sudo/lectured/${user}"
    touch                "${file}"
    chmod 600            "${file}"
    chown "root:${user}" "${file}"
  done
}

# Function:	Undo configuration of sudo for Debian.
# Parameters:	None.
# Remarks:	Restores sudo to ask for the user password instead of the root
#		password. Disables sudo and restores the first time lecture
#		for all users.
# Returns:	None.
revert_sudo () {
  local file user users
  # Only do for Debian.
  if ! grep --ignore-case --no-messages --quiet "Debian" "/etc/issue.net"; then
    return
  fi
  # Check sudo is installed.
  if ! which -s sudo; then
    return
  fi
  file="/etc/sudoers"
  # Restore original file.
  if [ -f "${file}.org" ]; then
    mv -f "${file}.org" "${file}"
  fi
  # Get local user accounts.
  users="$(awk -F: '($3>=1000)&&($7!="/bin/false")&&($7!="/usr/sbin/nologin"){print $1}' /etc/passwd)"
  # Do not double quote to allow globbing and word splitting.
  for user in ${users}; do
    # Disallow user account to use sudo.
    file="/etc/group"
    if grep --quiet "^sudo.*${user}" "${file}"; then
      sed -i -r "s/^(sudo:.*),${user}(.*)$/\1\2/" "${file}"
      sed -i -r "s/^(sudo:.*)${user},(.*)$/\1\2/" "${file}"
      sed -i -r "s/^(sudo:.*)${user}(.*)$/\1\2/"  "${file}"
    fi
    # Restore first time lecture about sudo.
    file="/var/lib/sudo/lectured/${user}"
    if [ -f "${file}" ]; then
      rm -f "${file}"
    fi
  done
}

################################################################################
#									       #
#				VIM					       #
#									       #
################################################################################

# Function:	Configuration of vim.
# Parameters:	The 1st parameter contains the action to perform.
#		Valid actions: config, revert.
# Returns:	None.
setup_vim () {
  local action file line lines
  action="$1"
  file="/etc/environment"
  lines="
    # Make vim syntax highlighting work for Windows Terminal.
    # Default terminal setting of xterm-256color does not work.
    TERM=xterm-color
  "
  lines="$(echo "${lines}" | sed -e "s/^ *//g" | grep --invert-match "^$")"
  if [ "${action}" = "config" ]; then
    echo "${lines}" | while read line; do
      append_line "${file}" "${line}"
    done
  elif [ "${action}" = "revert" ]; then
    echo "${lines}" | while read line; do
      remove_line "${file}" "${line}"
    done
  else
    echo "Invalid action: ${action}."
  fi
}

# Function:	Configuration of the vim editor.
# Parameters:	None.
# Remarks:	Creates vim backup folder for all users and adds
#		the /etc/vim/vimrc.local vim configuration file.
#		Adds syntax highlighing for PowerShell language.
# Returns:	None.
config_vim () {
  local file folder user users
  # Check vim is installed.
  if ! which -s vim; then
    return
  fi
  # Configuration of /etc/environment file.
  setup_vim config
  # Add vim backup folder for root user.
  folder="/root/.vim/backup"
  mkdir -p "${folder}"
  # Get local user accounts.
  users="$(awk -F: '($3>=1000)&&($7!="/bin/false")&&($7!="/usr/sbin/nologin"){print $1}' /etc/passwd)"
  # Add vim backup folder for all local users.
  # Do not double quote to allow globbing and word splitting.
  for user in ${users}; do
    folder="/home/${user}/.vim/backup"
    mkdir -p "${folder}"
    chown "${user}:${user}" "/home/${user}/.vim"
    chown "${user}:${user}" "/home/${user}/.vim/backup"
  done
  # Add vim configuration file.
  file="/etc/vim/vimrc.local"
  # Use single quotes around EOF to prevent interpreting variables.
cat << 'EOF' | sed -e "s/^  //" > "${file}"
  if exists('${DISPLAY}')
    " Running under X11.
    " Set default background color after detecting terminal background color.
    set background&
  else
    " Running on console.
    set background=dark
  endif

  " Set cursor shape at vim startup. Enter insert mode at startup and then return to normal mode.
  "augroup init_cursor
  "    autocmd!
  "    autocmd VimEnter * normal! :startinsert :stopinsert
  "augroup END

  " Set cursor shape at vim startup.
  autocmd VimEnter * silent !echo -ne "\e[1 q"

  autocmd BufEnter * :syntax sync fromstart

  autocmd BufNewFile,BufWinEnter * setlocal cinoptions=
  autocmd BufNewFile,BufWinEnter * setlocal formatoptions-=c
  autocmd BufNewFile,BufWinEnter * setlocal formatoptions-=o
  autocmd BufNewFile,BufWinEnter * setlocal formatoptions-=r
  autocmd BufNewFile,BufWinEnter * setlocal formatoptions-=t
  autocmd BufNewFile,BufWinEnter * setlocal indentkeys=
  autocmd BufNewFile,BufRead     * setlocal mouse=
  autocmd BufNewFile,BufWinEnter * setlocal nocindent
  autocmd BufNewFile,BufWinEnter * setlocal nosmartindent

  "colorscheme industry

  " Custom asciidoctor syntax highlighting.
  highlight link asciidocListingBlock Type
  highlight link asciidocLiteralBlock Statement
  highlight link asciidocLiteralParafraph Statement

  " See https://vimdoc.sourceforge.net/htmldoc/term.html
  " Fix cursor in Windows Terminal after using vim.
  " t_SI Start insert mode
  " t_SR Start replace mode
  " t_EI End insert or replace mode
  " Cursor settings:
  " 1 -> blinking block
  " 2 -> solid block
  " 3 -> blinking underscore
  " 4 -> solid underscore
  " 5 -> blinking vertical bar
  " 6 -> solid vertical bar
  let &t_SI = "\<Esc>[1 q"
  let &t_SR = "\<Esc>[1 q"
  let &t_EI = "\<Esc>[1 q"

  " The .bash_aliases file is sourced from .bashrc, but only for interactive shells.
  " The vim :! command is used to run external shell commands, but only within a non-interactive, non-login shell.
  " Read aliases file each time an external shell command is run from within vim.
  let $BASH_ENV = "~/.bash_aliases"

  " Prevent ^[[>0;136;0c garbage characters or escape codes from showing.
  "set t_RV=
  " Prevent ^[[2;2R garbage characters or escape codes from showing.
  "set t_u7=

  " set compatible
  set encoding=utf-8
  set hlsearch
  set ignorecase
  set modeline
  set noautoindent
  set printoptions=paper:a4
  set title
  set viminfo='100,<500,s10,h
  set wrap

  " Save backup, swap and undo files in your home folder.
  " Backups will persist across reboots and only be accessible to you.
  " The double slash (//) tells Vim to use the full path of the file being edited to create the backup filename,
  " which prevents filename collisions when having files with the same name in different directories.
  " Vim will still use /tmp and the current directory as fallback options if the primary folder is not writable.
  set backup
  set backupdir=$HOME/.vim/backup//,/tmp//,.
  set directory=$HOME/.vim/backup//,/tmp//,.
  set undodir=$HOME/.vim/backup//,/tmp//,.
EOF
  # Add PowerShell syntax highlighting.
  mkdir -p /etc/vim/ftdetect
  mkdir -p /etc/vim/ftplugin
  mkdir -p /etc/vim/indent
  mkdir -p /etc/vim/syntax
  wget --directory-prefix /etc/vim/ftdetect --quiet https://github.com/PProvost/vim-ps1/raw/master/ftdetect/ps1.vim
  wget --directory-prefix /etc/vim/ftdetect --quiet https://github.com/PProvost/vim-ps1/raw/master/ftdetect/ps1xml.vim
  wget --directory-prefix /etc/vim/ftdetect --quiet https://github.com/PProvost/vim-ps1/raw/master/ftdetect/xml.vim
  wget --directory-prefix /etc/vim/ftplugin --quiet https://github.com/PProvost/vim-ps1/raw/master/ftplugin/ps1.vim
  wget --directory-prefix /etc/vim/ftplugin --quiet https://github.com/PProvost/vim-ps1/raw/master/ftplugin/ps1xml.vim
  wget --directory-prefix /etc/vim/indent   --quiet https://github.com/PProvost/vim-ps1/raw/master/indent/ps1.vim
  wget --directory-prefix /etc/vim/syntax   --quiet https://github.com/PProvost/vim-ps1/raw/master/syntax/ps1.vim
  wget --directory-prefix /etc/vim/syntax   --quiet https://github.com/PProvost/vim-ps1/raw/master/syntax/ps1xml.vim
}

# Function:	Undo configuration of the vim editor.
# Parameters:	None.
# Remarks:	Removes the vim backup folder for all users and removes
#		the /etc/vim/vimrc.local vim configuration file.
#		Removes syntax highlighing for PowerShell language.
# Returns:	None.
revert_vim () {
  local file folder user users
  # Check vim is installed.
  if ! which -s vim; then
    return
  fi
  # Configuration of /etc/environment file.
  setup_vim revert
  # Remove vim backup folder for root user.
  folder="/root/.vim/backup"
  if [ -d "${folder}" ]; then
    rm -rf "${folder}"
  fi
  folder="/root/.vim"
  # Check folder is empty.
  if [ ! "$(ls -A "${folder}")" ]; then
    rmdir "${folder}"
  fi
  # Get local user accounts.
  users="$(awk -F: '($3>=1000)&&($7!="/bin/false")&&($7!="/usr/sbin/nologin"){print $1}' /etc/passwd)"
  # Remove vim backup folder for all local users.
  # Do not double quote to allow globbing and word splitting.
  for user in ${users}; do
    folder="/home/${user}/.vim/backup"
    if [ -d "${folder}" ]; then
      rm -rf "${folder}"
    fi
    folder="/home/${user}/.vim"
    # Check folder is empty.
    if ! [ "$(ls -A "${folder}")" ]; then
      rmdir "${folder}"
    fi
  done
  # Remove vim configuration file.
  file="/etc/vim/vimrc.local"
  if [ -f "${file}" ]; then
    rm -f "${file}"
  fi
  # Remove PowerShell syntax highlighting.
  rm -rf /etc/vim/ftdetect
  rm -rf /etc/vim/ftplugin
  rm -rf /etc/vim/indent
  rm -rf /etc/vim/syntax
}

################################################################################
#									       #
#				MAIN					       #
#									       #
################################################################################

# Exit immediately for any failed (non-zero exit code) untested commands.
set -e

