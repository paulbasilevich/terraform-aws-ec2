#!/usr/bin/env bash

# This script complements the terraform's <timeadd> function
# by automated evaluation of the local time deviation from GMT
# factoring in the daylight savings mode as retrieved from the system.
#
# Usage: check_daylight.sh [Time Zone Code]
# The argument is optional and defaults to local time zone
#
# Returns in json format in compliance with HCL convention:
#   Deviation from GMT in hours
#   Time Zone Code adjusted to daylight savings

eval "$(jq -r '@sh "LOC_TZ=\(.time_zone)"')"

unset DTZ
[[ -n "$LOC_TZ" ]] && DTZ="TZ=\"$LOC_TZ\""
GMT_TZ='Europe/London'
FMT="+%F %T"
sec_in_hr=3600
cmnd="date --date=\"\$( "$DTZ" date \"$FMT\" )\" \"+%s\""
LOC_UTC="$( eval "$cmnd" )"
GMT_UTC=$( date --date="$( TZ="$GMT_TZ" date "$FMT" )" "+%s" )
HOUR_SHIFT="$(( $(( $LOC_UTC - $GMT_UTC )) / $sec_in_hr ))h"
cmnd="$DTZ date | cut -d' ' -f5"
ZONE="$( eval "$cmnd" )"

jq -n --arg hour_shift "$HOUR_SHIFT" --arg time_zone "$ZONE" '{"hour_shift":$hour_shift,"time_zone":$time_zone}'

