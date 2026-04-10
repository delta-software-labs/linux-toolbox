#!/bin/sh

################################################################################
#									       #
#				COMMON					       #
#									       #
################################################################################

# Function:	Append line to file if it is missing.
# Parameters:	The 1st parameter contains the file name.
#		The 2nd parameter contains the line.
# Returns:	None.
append_line () {
  local file line
  file="$1"
  line="$2"

  if [ ! -f "${file}" ]; then
    echo "${MAGENTA}:: ${file} is missing, aborting...${RESET}"
    return 1
  fi

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

  if [ ! -f "${file}" ]; then
    echo "${MAGENTA}:: ${file} is missing, aborting...${RESET}"
    return 1
  fi

  if [ ! -f "${file}.org" ]; then
    cp -a "${file}" "${file}.org"
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

# Function:	Remove line from file if it is present.
# Parameters:	The 1st parameter contains the file name.
#		The 2nd parameter contains the line.
# Returns:	None.
remove_line () {
  local file line
  file="$1"
  line="$2"

  if [ ! -f "${file}" ]; then
    echo "${MAGENTA}:: ${file} is missing, aborting...${RESET}"
    return 1
  fi

  if grep --quiet "${line}" "${file}"; then
    sed -i "/${line}/d" "${file}"
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
    echo "${MAGENTA}:: No root privileges, aborting...${RESET}"
    return 1
  fi
}

