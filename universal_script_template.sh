#!/bin/bash

#
#	Author:
#	Last change:
#	Description: 
#	

VERSION=""


# Template author: Martin Sukany
# Template version: 2018041600
#
#
# Changelog:
# * 2018-04-16: logger will notice start / end point

### Variables definition
_TRUE=0
_FALSE=1

# Current environment
CUR_HOST=$(hostname)
SHORT_CUR_HOST=${CUR_HOST%%.*}
CUR_OS=$(uname -s)
typeset -r SCRIPTNAME="${0##*/}"
typeset SCRIPTDIR="${0%/*}"
if [ "${SCRIPTNAME}"x = "${SCRIPTDIR}"x ] ; then
  SCRIPTDIR="$( whence ${SCRIPTNAME} )"
  SCRIPTDIR="${SCRIPTDIR%/*}"
fi  
REAL_SCRIPTDIR="$( cd -P ${SCRIPTDIR} ; pwd )"
REAL_SCRIPTNAME="${REAL_SCRIPTDIR}/${SCRIPTNAME}"

LOGFILE="${LOGFILE:=/var/tmp/${SCRIPTNAME}_${SHORT_CUR_HOST}.log}"
ROTATE_LOG=1
LOGGER=1

case "${CUR_OS}" in

  SunOS )
    ID="/usr/xpg4/bin/id"
    ;;
    
  * )
    ID="id"
    ;;

esac

CUR_USER_ID="$( ${ID} -u )"
CUR_USER_NAME="$( ${ID} -un )"

CUR_GROUP_ID="$( ${ID} -g )"
CUR_GROUP_NAME="$( ${ID} -gn )"

# TTY check

################################
### Functions definition #######
################################

#RotateLog
function RotateLog {
  typeset THISRC=1
  typeset THIS_LOGFILES="${LOGFILE}"
  typeset THIS_LOGFILE=""
  typeset i
  
  [ $# -ne 0 ] && THIS_LOGFILES="$*"
  if [ "${THIS_LOGFILES}"x != ""x ] ; then
    for THIS_LOGFILE in "${THIS_LOGFILES}" ; do
      for i in 8 7 6 5 4 3 2 1 0  ; do
        [ -r "${THIS_LOGFILE}.${i}" ] && mv "${THIS_LOGFILE}.${i}" "${THIS_LOGFILE}.$(( i + 1 ))"
      done
      [ -r "${THIS_LOGFILE}" ] && mv "${THIS_LOGFILE}" "${THIS_LOGFILE}.0"
    done
    THISRC=0
  fi

  return ${THISRC}
}



########################################
##### Running in dettached session #####
########################################

__USE_TTY=${__FALSE}
tty -s && RUNNING_IN_TERMINAL_SESSION=0 || RUNNING_IN_TERMINAL_SESSION=1
if [ ${RUNNING_IN_TERMINAL_SESSION} = 1 ] ; then
  STDOUT_FILE="/var/tmp/${SCRIPTNAME}.STDOUT_STDERRR"
  RotateLog "${STDOUT_FILE}"
  
  echo "${SCRIPTNAME} -- Running in a detached session ... STDOUT/STDERR will be in ${STDOUT_FILE}" >&2
 
  exec 3>&1
  exec 4>&2
  exec 1>>"${STDOUT_FILE}"  2>&1
fi

###########################
##### Other functions #####
###########################

function LogOnly {
  LogMsg "$*" >/dev/null
}

function LogInfo {
  LogMsg "INFO: $*" >&2
}


#--- LogMsg --- #
function LogMsg {

  typeset THISMSG=""

  [ ${ROTATE_LOG} -eq 1 ] && RotateLog
  ROTATE_LOG=0
  
    THISMSG="[$( date +"%Y/%m/%d %H:%M:%S" ) ${SCRIPTNAME}] $*"
  
  echo "${THISMSG}"  
  [ "${LOGFILE}"x != ""x ] && echo "${THISMSG}" >>"${LOGFILE}"
}

# --- Log ERROR --- #
function LogError {
  LogMsg "ERROR: $*" >&2
}


# --- Warning logging --- #
function LogWarning  {
  LogMsg "WARNING: $*"
}


# ---- Execute and log --- #

function executeCommandAndLog {
  set +e
  typeset THISRC=0

    LogInfo "### Executing: $@" || LogOnly "### Executing: $@"
    eval "$*" 2>&1 | tee -a ${LOGFILE}
    THISRC=$PIPESTATUS

    LogInfo "### RC: $THISRC" || LogOnly "### RC: $THISRC"
  return ${THISRC}
}



# --- current time stamp --- #
function timestamp {
  date +%Y.%m.%d.%H_%M_%S_%s 
}

# --- continue_yesno --- #
function continue_yesno() {
	typeset RETURN=${1:-""}
	if [ "${RETURN}x" = "x" ]; then
		echo -e "Do you want to continue? (yes/no): \c"
		read RETURN
		case $RETURN in
			yes|y)
				return 0
				;;
			*)
				return 1
				;;
		esac
	fi
	return $RETURN
}


# --- colorized output definitions --- #
bg_black=$(tput setab 0)
bg_red=$(tput setab 1)
bg_green=$(tput setab 2)
bg_yellow=$(tput setab 3)
bg_blue=$(tput setab 4)
bg_white=$(tput setab 7)

fg_black=$(tput setaf 0)
fg_red=$(tput setaf 1)
fg_green=$(tput setaf 2)
fg_yellow=$(tput setaf 3)
fg_blue=$(tput setaf 4)
fg_white=$(tput setaf 7)

color_reset=$(tput sgr0)


#####################################
#####################################
#####################################
#		                    #
#	MODIFY FROM HERE 	    #
#                                   #
#####################################
#####################################
#####################################

# --- usage --- #
function usage() {
cat << EOF

HERE WILL BE YOUR USAGE TEXT

EOF
}
# --- main --- #
LogInfo "Starting ..."
if [ ${LOGGER} -eq 1 ]; then  logger "Starting ${REAL_SCRIPTNAME}"; fi



LogInfo "Done."
if [ ${LOGGER} -eq 1 ]; then logger "Finishing ${REAL_SCRIPTNAME}" ; fi

exit 0
