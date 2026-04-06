#!/usr/bin/env bash
# zrl -> .../terraform_backend.sh

temp_file_prefix="tempf_"
trap 'for tf in $( . ws "$temp_file_prefix" ); do rm -f "${tf#*=}"; done' EXIT

mode="${1}"
if [[ -z "$mode" ]]; then
    echo "Terraform backend handler (alias tbe)."
    echo "Usage:    zrl <mode> -- where "mode" is: r[emote_state] | l[ocal_state] | v[iew_state_source]"
    exit 1
fi

home="$( pwd )"
mode="${mode::1}"
mode="${mode,,}"

# Use ".ft" instead of ".tf" to preclude early warning for "terraform init"
infra_source="$(
    find . -type f '(' -name "*.ft" -o -name "*.tf" ')' \
  -exec egrep -l -e "^[[:space:]]+backend[[:space:]]+\"s3\"[[:space:]]+{" "{}" \; \
  2> /dev/null \
  | head -1\
  )"

if [[ -z "$infra_source" ]]; then
    echo "Backend definitions file (e.g., backend.tf) not found."
	exit 1
fi

state_type="$( basename "$infra_source" )"
state_type="${state_type##*.}" # Yields "ft" or "tf"
case $mode in
    "r") state_mode="Remote" ;;
    "l") state_mode="Local"  ;;
    "v") case "$state_type" in
            "tf") state_mode="Remote" ;;
               *) state_mode="Local"  ;;
         esac
         ;;
esac


for x in bucket key region dynamodb_table
do
	eval $( echo "$x=$( sed -E -n "\~^[[:space:]]*$x[[:space:]]+=[[:space:]]+\"[^\"]+\"~p" "$infra_source" \
		| cut -d\" -f2 )" )
done

tfstate_file="$( basename "$key" )"
backend_folder="$( dirname "$key" )"
if [[ "$backend_folder" == "." ]]; then unset backend_folder; fi

key_name="LockID"
capacity_units=5	# default in AWS console UI

case "$mode" in
	"r") # Initialize s3 bucket vvvvv
         if [[ "$state_type" == "ft" ]]; then
             echo "Setting up the infrastructure for remote state ..."
             aws s3api create-bucket --bucket "$bucket" --region "$region" > /dev/null
             # vvv Reinstate output for details: => "... # > /dev/null  vvv
             printf "Bucket name: %s\n" "$( aws s3api list-buckets | jq -r '.Buckets[]|.Name' )" > /dev/null
             if [[ -n "$backend_folder" ]]; then
                aws s3api put-object --bucket "$bucket" --key "$backend_folder" > /dev/null
             fi
             # vvv Reinstate output for details: => "... # > /dev/null  vvv
             printf "Created %s %s\tSize: %s\t\tKey: %s\n" $( aws s3 ls "s3://$bucket" \
                 | awk '{print $1, $2, $3, $4}' ) > /dev/null

             # Initialize dynamodb table vvvvv
             aws dynamodb create-table \
                --table-name "$dynamodb_table" \
                --attribute-definitions AttributeName="$key_name",AttributeType=S \
                --key-schema AttributeName="$key_name",KeyType=HASH \
                --provisioned-throughput ReadCapacityUnits=$capacity_units,WriteCapacityUnits=$capacity_units \
                --region "$region" \
                > /dev/null
             aws dynamodb wait table-exists --table-name "$dynamodb_table" --region "$region"
             # vvv Reinstate output for details: => "... # > /dev/null  vvv
             printf "Dynamodb table: %s\tKey: %s\n" \
                 $( aws dynamodb describe-table --table-name "$dynamodb_table" --region "$region" \
                 | jq -r '.Table|[.TableName, .KeySchema[].AttributeName] | @tsv' ) > /dev/null

             # Skip "terraform init" if this script is called from init.sh
             # Otherwise, run "terraform init" assuming toggle belween local and remote state
             called_from="$( basename "$( ps -o command= $PPID | awk '{print $2}' )" )"
             if [[ "$called_from" != "init.sh" ]]; then
                 backend_name="$( basename "$infra_source" )"
                 [[ -s "${infra_source}" ]] && mv "${infra_source}" "${home}/${backend_name%.*}.tf"
                 # vvv Reinstate output for details: => "... # > /dev/null  vvv
                 terraform init -migrate-state -force-copy > /dev/null
             fi
         fi
		 echo "$state_mode state is in effect"
         ;;
	"l") # Reinstate local state:
         if [[ "$state_type" == "tf" ]]; then
             apex="$( dirname "$( dirname "$( realpath "$0" )" )" )"
             target_name="$( basename "$infra_source" )"
             cd "$home"
             [[ -s "${target_name}" ]] && mv "${target_name}" "$apex/${target_name%.*}.ft"
             prev_workspace="$( terraform workspace show )"
             # vvv Reinstate output for details: => "... # > /dev/null  vvv
             terraform init -migrate-state -force-copy > /dev/null
             this_workspace="$( terraform workspace show )"
             if [[ "$this_workspace" != "$prev_workspace" ]]; then
                 terraform workspace select default
                 terraform workspace new "$prev_workspace"
             fi

             # Delete dynamodb table vvvvv
             echo "Removing the remote state infrastructure..."
             aws dynamodb delete-table --table-name "$dynamodb_table" --region "$region" > /dev/null 2>&1
             aws dynamodb wait table-not-exists --table-name "$dynamodb_table" --region "$region"
             # vvv Reinstate output for details: => "... # > /dev/null  vvv
             aws dynamodb list-tables  --region "$region" \
                | jq -r '.TableNames' | sed -e "s~^\[\]$~No tables found.~" > /dev/null

             # Delete s3 bucket vvvvv
             aws s3 rm "s3://$bucket" --recursive > /dev/null 2>&1
             aws s3api delete-bucket --bucket "$bucket" 2> /dev/null
             # vvv Reinstate output for details: => "... # > /dev/null  vvv
             aws s3api list-buckets | jq -r '.Buckets' | sed -e "s~^\[\]$~No buckets found.~" > /dev/null
         fi
         echo "$state_mode state is in effect"
		 ;;
	"v") # "cat" the state file vvvvv
         this_workspace="$( terraform workspace show )"
         case "$this_workspace" in
            "default") case "$state_type" in
                        "tf") show_key="$key" ;;
                           *) show_key="$( basename "$key" )" ;; # evaluates to $state_file_name from init.sh
                       esac
                       ;;
                    *) case "$state_type" in
                        "tf") show_key="env:/$this_workspace/$key" ;;
                        *) show_key="./terraform.tfstate.d/$this_workspace/$( basename "$key" )" ;;
                       esac
                       ;;
         esac

         printf "%s state\tWorkspace: \"%s\"\n\x1b[4m%s\x1b[0m\n" "$state_mode" "$this_workspace" "$show_key:"
         #                                      [4m - underscore style
         sleep 4
         # seq -s "-" $(( ${#show_key} + 1 )) | tr -d '[:digit:]'

         no_state_msg="Unavailable at this time."
         case "$state_type" in
             "tf") aws s3 cp "s3://$bucket/$show_key" - 2> /dev/null | more
                   if [[ $? -ne 0 ]]; then
                      echo "$no_state_msg"
                   fi
                   ;;
                *) if [[ -s "$show_key" ]]; then
                      more "$show_key"
                   else
                      echo "$no_state_msg"
                   fi
                   ;;
         esac

		 # Show specs of the lock on the state file vvvvv
		 dbkey="$bucket/$show_key"
		 dbkeymd5="${dbkey}-md5"

		 tempf_qry=$( mktemp )
		 cat > "$tempf_qry" << QRY
#!/usr/bin/env bash
read id who created path <<< \$( aws dynamodb scan --table-name "$dynamodb_table" --region "$region" \\
	| jq -r '.Items[]|select(.LockID.S == "$dbkey")|.Info.S' \\
	| jq -r '[.ID, .Who, .Created, .Path] | @tsv' )
if [[ -n "\$id" ]]; then
	ltime="\$( ./a2l__aws_to_local_time.sh "\$created" )"
	echo "\$ltime - \$who - \$path - \$id"
else
	aws dynamodb scan --table-name "$dynamodb_table" --region "$region" \\
	| jq -r '[.Items[]|select(.LockID.S == "$dbkeymd5")|.Digest.S, "$dbkeymd5"] | @tsv' \\
	| awk '{print \$2 ":\t" \$1}'
fi
QRY
		 chmod +x "$tempf_qry"
         # vvv Reinstate output for details: => "... # > /dev/null 2>&1  vvv
		 "$tempf_qry" > /dev/null 2>&1
		 ;;

      *) echo "Supported: r(emote_state), l(ocal_state), v(iew_state). \"$1\" unsupported."
		 ;;
esac

