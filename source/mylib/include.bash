#!/bin/bash

:<<\true

NB: this is a "shell library" script and it is not supposed to be executed directly!

true


# --------------------------------------------------------------------- 
# placeholders

# to be replaced by the invoking script
## PROBENAME='unknown_probe'
PROBENAME='_unknown_'
PROBEVAR='value'

message() {
    # a placeholder function to be replaced by the probe
    :
}

probe() {
    # a placeholder function to be replaced by the probe
    printf '-1\n'
}



# --------------------------------------------------------------------- 
# script constants

# normally /bin:/usr/bin shall be on the path, though
logger=/usr/bin/logger

# some Linux systems do not have /sbin:/usr/sbin on the path
ip=$(which ip || /usr/sbin/ip)
route=$(which route || /usr/sbin/route)


# --------------------------------------------------------------------- 
# syslog messages, etc

# these are scripts run by an external user, therefore --
LOGGER_FACILITY='user'


_message() {
    LOG_LEVEL="${1-debug}"
    shift 1

    "$logger" -i -p "${LOGGER_FACILITY}.${LOG_LEVEL}" -- "($$) $*" # do we really need this '--' ?
}

debug() {
    _message debug "$@"
}

info() {
    _message info "$@"
}

notice() {
    _message notice "$@"
}

warning() {
    _message warning "$@"
}

error() {
    _message error "$@"
}

critical() {
    _message crit "$@"
}

#
# the two below are not really expected to be sent by a probe
#

alert() {
    _message alert "$@"
}

panic() {
    _message emerg "$@"
}



# log the executed command first
verbose() {
    debug "$@"
    "$@"
}





# --------------------------------------------------------------------- 
# formatting the report - alerts, etc

START_TIME=`date '+%F %T %:::z/%Z'`
SCRIPT_NAME=$(basename $0 || $0)

# this allows to adjust the probe start time, if necessary;
# it also lets the system know that a script has been staretd by an exetrnal user )
started() {
    USERNAME=$(id -un)
    debug "<$PROBENAME> probe started by /$USERNAME/ as '$0'"

    START_TIME=`date '+%F %T %:::z/%Z'`
}


#
# adding a helpful tag to the message with some information about the potential alert
#

MESSAGE_TAG=''

maketag() {
    HOSTNAME=$(hostname -s)

    GWIFACE=$( $route -n | grep '^0\.0\.0\.0' | awk '{ print $NF }' )
    ## IPADDR=$( $ip -br addr show dev $GWIFACE | awk '{ print $3 }' )
    IPADDR=$( $ip -br addr show dev $GWIFACE | tr '/' ' ' | awk '{ print $3 }' )

    # setting message tag for possible alerts
    TAG=''
    if [ "x${HOSTNAME}" = x ]; then : ; else
        TAG="${HOSTNAME}"
    fi

    if [ "x${IPADDR}" = x ]; then : ; else
        TAG="${TAG} (${IPADDR})"
    fi

    if [ "x${START_TIME}" = x ]; then : ; else
        TAG="${TAG} at ${START_TIME}"
    fi
    
    if [ "x${TAG}" = x ]; then : ; else
        MESSAGE_TAG="[${TAG}]:"
    fi
}



# [  ]
report() {

    keyname="${1-key}"
    value="${2-'-'}"

    header=$(message | tr '\t\r\n' '   ' )
    sample=$(probe |  tr '\t\r\n' '   ' )

    debug "${SCRIPT_NAME} - ${PROBENAME}/${PROBEVAR}/${sample}"

    maketag
    printf "Message: ${MESSAGE_TAG} ${header}\n"
    printf "Data:\n"
    printf "${PROBEVAR}:\t${sample}" 

    # apparently the probes will trigger a critical alert if they fail,
    # so the current sampling strategy is to silently drop the sample if it can not be recorded
    true
}

