#!/bin/sh

################################################################################
#									       #
#				COMMON					       #
#									       #
################################################################################

# Function:	Define HTML color names.
# Parameters:	None.
# Remarks:	Do not use "tput" command because it fails for "ssh root@localhost ~delta/show-inventory".
#		See http://stackoverflow.com/questions/4332478/read-the-current-text-color-in-a-xterm/4332530#4332530
#		See http://www.cyberciti.biz/faq/bash-shell-change-the-color-of-my-shell-prompt-under-linux-or-unix
#		See https://stackoverflow.com/questions/4842424/list-of-ansi-color-escape-sequences
#		See https://www.codegists.com/code/color-bash-prompt-freebsd
# Returns:	None.
add_colors () {
  # Make carriage return and escape characters work for all operating systems.
  RETURN="$(printf "\\015")"
  ESCAPE="$(printf "\\033")"

  # The _colors.mk file used by Makefile defines color names.
  # However, its syntax is for makefiles and it fails when dot sourced by a shell. 
  # Convert makefile syntax to shell compatible syntax.
  cat "${SRCDIR}/_colors.mk" | while read color; do
    color="$(echo "${color}" | grep " = " | tr -d " " | tr "(" "{" | tr ")" "}")"
    color="$(echo "${color}" | sed -re "s/^(.*)=(.*)$/\1=\"\2\"/g")"
    eval "${color}"
  done

  export RETURN ESCAPE
  export RESET
  export BLACK MAROON GREEN OLIVE NAVY PURPLE TEAL SILVER GRAY RED LIME YELLOW BLUE FUCHSIA MAGENTA AQUA CYAN WHITE
  export BG_BLACK BG_MAROON BG_GREEN BG_OLIVE BG_NAVY BG_PURPLE BG_TEAL BG_SILVER BG_GRAY BG_RED BG_LIME BG_YELLOW BG_BLUE BG_FUCHSIA BG_MAGENTA BG_AQUA BG_CYAN BG_WHITE
}

# Function:	Append line to file if it is missing.
# Parameters:	The 1st parameter contains the file name.
#		The 2nd parameter contains the line.
# Returns:	None.
append_line () {
  local file line
  file="$1"
  line="$2"
  if ! grep --quiet "${line}" "${file}"; then
    # Back up file if its backup is missing.
    backup_file "${file}"
    echo "${line}" >> "${file}"
  fi
}

# Function:	Back up file if its backup is missing.
# Parameters:	The 1st parameter contains the file name.
# Returns:	None.
backup_file () {
  local file
  file="$1"
  if [ -f "${file}" ] && [ ! -f "${file}.org" ]; then
    cp -a "${file}" "${file}.org"
  fi
}

# Function:	Remove line from file if it is present.
# Parameters:	The 1st parameter contains the file name.
#		The 2nd parameter contains the line.
# Returns:	None.
remove_line () {
  local file line
  file="$1"
  line="$2"
  if grep --quiet "${line}" "${file}"; then
    sed -i "/${line}/d" "${file}"
  fi
}

# Function:	Remove file if present.
# Parameters:	The 1st parameter contains the file name.
# Returns:	None.
remove_file () {
  local file
  file="$1"
  if [ -f "${file}" ]; then
    rm -f "${file}"
  fi
}

# Function:	Remove folder if present.
# Parameters:	The 1st parameter contains the folder name.
# Returns:	None.
remove_folder () {
  local folder
  folder="$1"
  if [ -d "${folder}" ]; then
    rm -rf "${folder}"
  fi
}

# Function:	Restore file from its backup if present.
# Parameters:	The 1st parameter contains the file name.
# Returns:	None.
revert_file () {
  local file
  file="$1"
  if [ -f "${file}.org" ]; then
    command cp -a "${file}.org" "${file}"
  fi
}

# Function:	Check for root privileges.
# Parameters:	None.
# Returns:	Exit status 1 if no root privileges.
test_root_privileges () {
  if [ "$(id -u)" -ne 0 ]; then
#   >> /dev/tty echo ":: No root privileges, aborting..."
    echo "${MAGENTA}:: No root privileges, aborting...${RESET}"
    return 1
  fi
}

################################################################################
#									       #
#				MAIN					       #
#									       #
################################################################################

# Exit immediately for any failed (non-zero exit code) untested commands.
set -e

CMDDIR="$(dirname "$(readlink -f "$0")")"
SRCDIR="$(echo "${CMDDIR}" | sed -e "s/commands/src/")"

add_colors

