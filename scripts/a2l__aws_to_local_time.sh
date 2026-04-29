#!/usr/bin/env bash

# This is an ancillary function that converts a date value retrieved from an AWS resource
# to the localized value in a human-friendly format factoring in the daylight savings
#
# Usage: a2l <date formatted by the pattern of the default argument ("val") below.
#

main(){
	val="${1:-2023-03-29T17:27:23+00:00}"

	# Replace trailing code from "dot" on for "+00:00"
	# E.g. 2024-01-02T05:41:02.369860226Z => 2024-01-02T05:41:02+00:00
	nval="$( echo "$val" | sed -E -e "s~.[[:digit:]]+Z$~+00:00~" )"

    # validation_status = validate_timestamp "$nval"    # Call executable py script. Returns 0 if ok, 1 - otherwise.
	if [[ ! $nval =~ $input_format ]]; then . sv val; echo "Unsupported input format"; exit 1; fi

	utc="$( date -d "$nval" "+%s" )"
	loc="$( TZ="$ThisTZ" date -d@$utc "$output_format" )"
	# gmt="$( TZ="$BaseTZ" date -d@$utc "$output_format" )"
	echo "$loc"
	# . sv val utc loc gmt
}

normalize_date_function(){
	os_type="$( uname -a | awk '{print $1}' )"
	case "$os_type" in
		"Darwin")
			datefunc="date"
			sought_date_folder="gnubin"
			sought_date_package="coreutils"
			sought_date_path="/usr/local/opt/$sought_date_package/libexec/$sought_date_folder"
			date_home="$( basename "$( dirname "$( which $datefunc )" )" 2> /dev/null )"
			if [[ "$date_home" == "$sought_date_folder" ]]; then return 0; fi      # GNU date is in place
			if [[ ! -x "$sought_date_path/$datefunc" ]]
			then
            read -p "Need to install $sought_date_package for GNU \"$datefunc\" function to work. Proceed (Y/N)? " uinp
            case "$uinp" in
                     "y"|"Y") brew install "$sought_date_package" ;;
									*) exit 1 ;;
            esac
			fi
			if [[ -x "$sought_date_path/$datefunc" ]]
			then
				export PATH="$sought_date_path:$PATH"
			else
				echo "Could not initialize GNU \"$datefunc\" function. Quitting..."
				exit 1
			fi
			;;
				*) ;;
	esac
}

initialize(){
	BaseTZ='Europe/London'
	ThisTZ='America/Los_Angeles'
	input_format="19|20([[:digit:]]{2}-){2}[[:digit:]]{2}T([[:digit:]]{2}:){2}[[:digit:]]{2}[+-][[:digit:]]{2}:[[:digit:]]{2}"
	output_format="+%Y %b-%d(%a) %T"
}

normalize_date_function
initialize
main $@

