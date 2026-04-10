#!/bin/sh

################################################################################
#									       #
#				APT					       #
#									       #
################################################################################

# Function:	Configuration of apt.
# Parameters:	The 1st parameter contains the action to perform.
#		Valid actions: config, revert.
# Remarks:	Only for Debian Trixie.
# Returns:	None.
setup_apt () {
  local action distro file line lines

  # Get distro edition.
  distro="$(grep "^VERSION=" /etc/os-release | sed -e "s/^.*(\(.*\))\"$/\1/")"
  # Only do for Debian Trixie.
  if echo "${distro}" | grep -Eiq "Trixie"; then
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

  # Add ansi color variables.
  file="/etc/profile.d/ansi_colors.sh"
  # Apply single quotes around EOF to avoid interpreting variables.
cat << 'EOF' | sed -e "s/^  //" > "${file}"
  ESC="$(printf "\\033")"

  RST="${ESC}[0m"

  BLK="${ESC}[0;30m"
  MRN="${ESC}[0;31m"
  GRN="${ESC}[0;32m"
  OLV="${ESC}[0;33m"
  NVY="${ESC}[0;34m"
  PUR="${ESC}[0;35m"
  TEL="${ESC}[0;36m"
  SLV="${ESC}[0;37m"
  GRY="${ESC}[1;30m"
  RED="${ESC}[1;31m"
  LME="${ESC}[1;32m"
  YLW="${ESC}[1;33m"
  BLU="${ESC}[1;34m"
  MGT="${ESC}[1;35m"
  CYN="${ESC}[1;36m"
  WHT="${ESC}[1;37m"

  BG_BLK="${ESC}[0;7;30;40m"
  BG_MRN="${ESC}[0;7;31;40m"
  BG_GRN="${ESC}[0;7;32;40m"
  BG_OLV="${ESC}[0;7;33;40m"
  BG_NVY="${ESC}[0;7;34;40m"
  BG_PUR="${ESC}[0;7;35;40m"
  BG_TEL="${ESC}[0;7;36;40m"
  BG_SLV="${ESC}[0;7;37;40m"
  BG_GRY="${ESC}[0;5;30;40m"
  BG_RED="${ESC}[0;5;30;41m"
  BG_LME="${ESC}[0;5;30;42m"
  BG_YLW="${ESC}[0;5;30;43m"
  BG_BLU="${ESC}[0;5;30;44m"
  BG_MGT="${ESC}[0;5;30;45m"
  BG_CYN="${ESC}[0;5;30;46m"
  BG_WHT="${ESC}[0;5;30;47m"

  export ESC RST
  export BLK MRN GRN OLV NVY PUR TEL SLV
  export GRY RED LME YLW BLU MGT CYN WHT
  export BG_BLK BG_MRN BG_GRN BG_OLV BG_NVY BG_PUR BG_TEL BG_SLV
  export BG_GRY BG_RED BG_LME BG_YLW BG_BLU BG_MGT BG_CYN BG_WHT
EOF

  # Add skeleton files.
  file="/etc/skel/.bash_aliases"
  # Apply single quotes around EOF to avoid interpreting variables.
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
  # Apply single quotes around EOF to avoid interpreting variables.
cat << 'EOF' | sed -e "s/^  //" > "${file}"
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

  # Back up file if its backup is missing.
  backup_file "/root/.bashrc"
  # Copy skeleton files to root account.
  command cp -a /etc/skel/.bash_aliases /root
  command cp -a /etc/skel/.bashrc /root
  command cp -a /etc/skel/.bashrc_aliases /root

  # Get local user accounts.
  users="$(awk -F: '($3>=1000)&&($7!="/bin/false")&&($7!="/usr/sbin/nologin"){print $1}' /etc/passwd)"
  # Copy skeleton files to all user accounts.
  # Do not double quote to allow globbing and word splitting.
  for user in ${users}; do
    # Back up file if its backup is missing.
    backup_file "/home/${user}/.bashrc"
    # Copy skeleton files to user account.
    command cp -a /etc/skel/.bash_aliases "/home/${user}"
    command cp -a /etc/skel/.bashrc "/home/${user}"
    command cp -a /etc/skel/.bashrc_aliases "/home/${user}"
    chown "${user}:${user}" "/home/${user}/.bash_aliases"
    chown "${user}:${user}" "/home/${user}/.bashrc"
    chown "${user}:${user}" "/home/${user}/.bashrc_aliases"
  done

  # Change color of root prompt from lime to red.
  sed -i "s/lime/red/"  "/root/.bash_aliases"
  sed -i "s/;32m/;31m/" "/root/.bash_aliases"
}

# Function:	Undo configuration of bash shell.
# Parameters:	None.
# Remarks:	Restores the bash shell. Removes the new skeleton files.
#		Removes the copied skeleton files from all user accounts.
#		Restores the prompt for all users.
#		Disables ANSI color output.
# Returns:	None.
revert_bash () {
  local user users

  remove_file "/etc/profile.d/ansi_colors.sh"
  remove_file "/etc/skel/.bash_aliases"
  remove_file "/etc/skel/.bashrc_aliases"
  remove_file "/root/.bash_aliases"
  remove_file "/root/.bashrc_aliases"

  # Restore file from its backup if present.
  revert_file "/root/.bashrc"

  # Get local user accounts.
  users="$(awk -F: '($3>=1000)&&($7!="/bin/false")&&($7!="/usr/sbin/nologin"){print $1}' /etc/passwd)"
  # Remove skeleton files for all user accounts.
  # Do not double quote to allow globbing and word splitting.
  for user in ${users}; do
    remove_file "/home/${user}/.bash_aliases"
    remove_file "/home/${user}/.bashrc_aliases"
    # Restore file from its backup if present.
    revert_file "/home/${user}/.bashrc"
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
  # Check vim is installed.
  if ! which -s vim.basic; then
    echo ":: Please install ${WHT}vim${RST} package and try again."
    return
  fi

  # Make vim.basic the default editor.
  update-alternatives --quiet --set editor /usr/bin/vim.basic
}

# Function:	Undo configuration of the default editor.
# Parameters:	None.
# Remarks:	Restores the default editor for all users.
# Returns:	None.
revert_editor () {
  # Restore default editor.
  update-alternatives --quiet --auto editor
}

################################################################################
#									       #
#				JUMP HOST				       #
#									       #
################################################################################

# Function:	Configuration for RDP/SSH jump host.
# Parameters:	None.
# Remarks:	Enables remote port forwarding on the jump host.
# Returns:	None.
config_jumphost () {
  local file line lines pattern

  # Check ssh server is installed.
  if ! which -s sshd; then
    echo ":: Please install ${WHT}openssh-server${RST} package and try again."
    return
  fi

  # Check firewall is installed.
  if ! which -s ufw; then
    echo ":: Please install ${WHT}ufw${RST} package and try again."
    return
  fi

  file="/etc/default/ufw"
  # Back up file if its backup is missing.
  backup_file "${file}"
  # Enable remote port forwarding.
  sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' "${file}"

  file="/etc/ssh/sshd_config"
  # Back up file if its backup is missing.
  backup_file "${file}"
  # Enable remote port forwarding.
  sed -i "s/#GatewayPorts no/GatewayPorts yes/"              "${file}"
  sed -i "s/#AllowTcpForwarding yes/AllowTcpForwarding yes/" "${file}"

  file="/etc/ufw/before.rules"
  # Back up file if its backup is missing.
  backup_file "${file}"
  if ! grep --quiet "# Port forwarding for jump host." "${file}"; then
    pattern="# Don't delete these required lines, otherwise there will be errors"
    # Apply single quotes around EOF to avoid interpreting variables.
    # Insert text above pattern.
cat << 'EOF' | sed "s/^  //" | sed -i "/${pattern}/e cat /dev/stdin" "${file}"
  # JUMP HOST CONFIGURATION HEAD
  # Port forwarding for jump host.
  *nat
  :PREROUTING ACCEPT [0:0]
  -A PREROUTING -p tcp --dport 22222 -j REDIRECT --to-port 22
  COMMIT
  # JUMP HOST CONFIGURATION TAIL
EOF
  fi

  file="/etc/ufw/sysctl.conf"
  # Back up file if its backup is missing.
  backup_file "${file}"
  # Enable remote port forwarding.
  sed -i 's|#net/ipv4/ip_forward=1|net/ipv4/ip_forward=1|' "${file}"
  sed -i 's|#net/ipv6/conf/default/forwarding=1|net/ipv6/conf/default/forwarding=1|' "${file}"
  sed -i 's|#net/ipv6/conf/all/forwarding=1|net/ipv6/conf/all/forwarding=1|' "${file}"

  # Port 22222 is for setting up a reverse SSH tunnel.
  # Ports 22000-22099 are for reverse SSH tunnels.
  # Ports 33000-33099 are for reverse RDP tunnels.
  ufw allow 22222/tcp > /dev/null
  ufw allow 22000:22099/tcp > /dev/null
  ufw allow 33000:33099/tcp > /dev/null

  # Restart ssh server.
  systemctl restart ssh

  # Restart firewall.
  systemctl restart ufw
}

# Function:	Undo configuration for RDP/SSH jump host.
# Parameters:	None.
# Remarks:	Disables remote port forwarding on the jump host.
# Returns:	None.
revert_jumphost () {
  local file line lines pattern

  file="/etc/default/ufw"
  if [ -f "${file}" ]; then
    # Back up file if its backup is missing.
    backup_file "${file}"
    # Disable remote port forwarding.
    sed -i 's/DEFAULT_FORWARD_POLICY="ACCEPT"/DEFAULT_FORWARD_POLICY="DROP"/' "${file}"
  fi

  file="/etc/ssh/sshd_config"
  if [ -f "${file}" ]; then
    # Back up file if its backup is missing.
    backup_file "${file}"
    # Disable remote port forwarding.
    sed -i "s/GatewayPorts yes/#GatewayPorts no/"              "${file}"
    sed -i "s/AllowTcpForwarding yes/#AllowTcpForwarding yes/" "${file}"
  fi

  file="/etc/ufw/before.rules"
  if [ -f "${file}" ]; then
    # Back up file if its backup is missing.
    backup_file "${file}"
    # Disable remote port forwarding.
    sed -i "/# JUMP HOST CONFIGURATION HEAD/,/# JUMP HOST CONFIGURATION TAIL/d" "${file}"
  fi

  file="/etc/ufw/sysctl.conf"
  if [ -f "${file}" ]; then
    # Back up file if its backup is missing.
    backup_file "${file}"
    # Disable remote port forwarding.
    sed -i 's|net/ipv4/ip_forward=1|#net/ipv4/ip_forward=1|' "${file}"
    sed -i 's|net/ipv6/conf/default/forwarding=1|#net/ipv6/conf/default/forwarding=1|' "${file}"
    sed -i 's|net/ipv6/conf/all/forwarding=1|#net/ipv6/conf/all/forwarding=1|' "${file}"
  fi

  # Check firewall is installed.
  if which -s ufw; then
    # Port 22222 is for setting up a reverse SSH tunnel.
    # Ports 22000-22099 are for reverse SSH tunnels.
    # Ports 33000-33099 are for reverse RDP tunnels.
    ufw delete allow 22222/tcp > /dev/null
    ufw delete allow 22000:22099/tcp > /dev/null
    ufw delete allow 33000:33099/tcp > /dev/null
  fi

  # Check ssh server is installed.
  if which -s sshd; then
    # Restart ssh server.
    systemctl restart ssh
  fi

  # Check firewall is installed.
  if which -s ufw; then
    # Restart firewall.
    systemctl restart ufw
  fi
}

################################################################################
#									       #
#				OPENSSH SERVER				       #
#									       #
################################################################################

# Function:	Configuration of OpenSSH server.
# Parameters:	None.
# Remarks:	
# Returns:	None.
config_openssh_server () {
  ::
}

# Function:	Undo configuration of OpenSSH server.
# Parameters:	None.
# Remarks:	
# Returns:	None.
revert_openssh_server () {
  ::
}

################################################################################
#									       #
#				RSYSLOG					       #
#									       #
################################################################################

# Function:	Configuration of rsyslog.
# Parameters:	None.
# Remarks:	Disables systemd-journald for Debian distro's.
# Returns:	None.
config_rsyslog () {
  local distro file

  # Check rsyslog is installed.
  if ! which -s rsyslogd; then
    echo ":: Please install ${WHT}rsyslog${RST} package and try again."
    return
  fi

  # Get distro edition.
  distro="$(grep "^VERSION=" /etc/os-release | sed -e "s/^.*(\(.*\))\"$/\1/")"

  # Only do for Debian distro's. Skip for Ubuntu distro's.
  if echo "${distro}" | grep -Eiq "Bullseye|Bookworm|Trixie"; then
    file="/etc/systemd/journald.conf"
    # Back up file if its backup is missing.
    backup_file "${file}"
    sed -i "s/#Storage=auto/Storage=none/"              "${file}"
    sed -i "s/#ForwardToSyslog=no/ForwardToSyslog=yes/" "${file}"
    systemctl restart rsyslog
    systemctl restart systemd-journald
  fi
}

# Function:	Undo configuration of rsyslog.
# Parameters:	None.
# Remarks:	Restores systemd-journald for Debian distro's.
# Returns:	None.
revert_rsyslog () {
  local distro file

  # Get distro edition.
  distro="$(grep "^VERSION=" /etc/os-release | sed -e "s/^.*(\(.*\))\"$/\1/")"

  # Only do for Debian distro's. Skip for Ubuntu distro's.
  if echo "${distro}" | grep -Eiq "Bullseye|Bookworm|Trixie"; then
    file="/etc/systemd/journald.conf"
    if [ -f "${file}" ]; then
      sed -i "s/Storage=none/#Storage=auto/"              "${file}"
      sed -i "s/ForwardToSyslog=yes/#ForwardToSyslog=no/" "${file}"
    else
      echo "${MGT}:: ${file} is missing, aborting...${RST}"
      return 1
    fi

    # Check rsyslog is installed.
    if which -s rsyslogd; then
      systemctl restart rsyslog
      systemctl restart systemd-journald
    fi
  fi
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
    echo ":: Please install ${WHT}sudo${RST} package and try again."
    return
  fi

  file="/etc/sudoers"
  # Back up file if its backup is missing.
  backup_file "${file}"
  # Check root password has been set.
  if grep --quiet "^root:\*:" /etc/shadow; then
    echo "${YLW}:: Skipped making sudo ask for root password, due to no root password set.${RST}"
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

  file="/etc/sudoers"
  # Restore file from its backup if present.
  revert_file "${file}"

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
    remove_file "/var/lib/sudo/lectured/${user}"
  done
}

################################################################################
#									       #
#				UFW					       #
#									       #
################################################################################

# Function:	Configuration of uncomplicated firewall.
# Parameters:	None.
# Remarks:	Enables and restarts the firewall.
#		Allows incoming ssh connections on port 22.
# Returns:	None.
config_ufw () {
  local file

  # Check firewall is installed.
  if ! which -s ufw; then
    echo ":: Please install ${WHT}ufw${RST} package and try again."
    return
  fi

  file="/etc/default/ufw"
  # Back up file if its backup is missing.
  backup_file "${file}"

  file="/etc/ufw/sysctl.conf"
  # Back up file if its backup is missing.
  backup_file "${file}"

  # Enable uncomplicated firewall.
  ufw --force enable > /dev/null
  # Allow outgoing connections.
  ufw default allow outgoing > /dev/null
  # Deny incoming connections.
  ufw default deny incoming > /dev/null
  # Allow incoming SSH.
  ufw allow ssh > /dev/null

  # Restart uncomplicated firewall.
  systemctl restart ufw
}

# Function:	Undo configuration of uncomplicated firewall.
# Parameters:	None.
# Remarks:	Disables and restarts the firewall.
# Returns:	None.
revert_ufw () {
  local file

  file="/etc/default/ufw"
  # Restore file from its backup if present.
  revert_file "${file}"

  file="/etc/ufw/sysctl.conf"
  # Restore file from its backup if present.
  revert_file "${file}"

  # Check firewall is installed.
  if which -s ufw; then
    # Disable uncomplicated firewall.
    ufw disable > /dev/null
    # Restart uncomplicated firewall.
    systemctl restart ufw
  fi
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
    echo ":: Please install ${WHT}vim${RST} package and try again."
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
  # Apply single quotes around EOF to avoid interpreting variables.
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

  # Configuration of /etc/environment file.
  setup_vim revert

  # Remove vim backup folder for root user.
  remove_folder "/root/.vim/backup"
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
    remove_folder "/home/${user}/.vim/backup"
    folder="/home/${user}/.vim"
    # Check folder is empty.
    if ! [ "$(ls -A "${folder}")" ]; then
      rmdir "${folder}"
    fi
  done

  # Remove vim configuration file.
  remove_file "/etc/vim/vimrc.local"

  # Remove PowerShell syntax highlighting.
  remove_folder "/etc/vim/ftdetect"
  remove_folder "/etc/vim/ftplugin"
  remove_folder "/etc/vim/indent"
  remove_folder "/etc/vim/syntax"
}

