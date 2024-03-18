#!/usr/bin/env bash
# be -> backend.sh

# This script initializes terraform to work on either "local" or "remote"(s3/dynamo_db) backend.
# Usage:    tbe l[ocal]     # Sets up the local backend
                            # and destroys all the artifacts, if any found, pertaining to the "remote" backend
                            # Omitted or unrecognized argument defaults to "local"
                            #
#           tbe r[emote]    # Creates S3 bucket and dynamo_db table for the state locking.
#                           # Initializes terraform to work on the remote S3 backend


main(){
    # Read in the argument setting the backend type: local(default) or remote.
    # Only first character matters:
    arg="${1::1}"
    case "$arg" in
        "l"|"r") mode="$arg" ;; # l[ocal], r[emote], c[at] - known modes
              *) mode="l";;     # Other input defaults to "local"
    esac

    # Defaut names for S3 backend settings:
    _bucket="kit-tf-backend"
    _key="ec2_instance/terraform.tfstate"
    _region="us-east-1"
    _dynamodb_table="terraform-state-locking"

    # Define the file meant to store the definition of the remote backend:
    infra_source=./backend.tf
    if [[ -s "$infra_source" ]]         # Retrieve all backend settings
    then
        read_s3_backend_settings
    fi

    case "$mode" in
        "l")        # Local backend
            if [[ -s "$infra_source" ]]
            then
                # terraform init -migrate-state   # This call does not help clearing off S3 binding.
	            # Delete dynamodb table vvvvv
		        aws dynamodb delete-table --table-name "$dynamodb_table" --region "$region" > /dev/null 2>&1
		        aws dynamodb wait table-not-exists --table-name "$dynamodb_table" --region "$region"
		        aws dynamodb list-tables  --region "$region" \
		 	    | jq -r '.TableNames' | sed -e "s~^\[\]$~No tables found.~"

		        # Delete s3 bucket vvvvv
		        aws s3 rm "s3://$bucket" --recursive > /dev/null 2>&1
                aws s3api delete-bucket --bucket "$bucket" 2> /dev/null
                aws s3api list-buckets | jq -r '.Buckets' | sed -e "s~^\[\]$~No buckets found.~"

                rm -f "$infra_source"

                # terraform init -reconfigure  # This call does not clear of the binding to S3
                # vvv Must remove .terraform folder to "erase the memory" of S3 backend
                rm -rf .terraform
                terraform init
            fi
            echo "Local backend appears in effect."
            ;;

        "r")        # Remote backend
            if [[ ! -s "$infra_source" ]]
            then
                cat > "$infra_source" << BEND
terraform {
    backend "s3" {
    bucket = "$_bucket"
    key = "$_key"
    region = "$_region"
    dynamodb_table = "$_dynamodb_table"
  }
}                
BEND
                terraform fmt > /dev/null
                read_s3_backend_settings
	        
                # Initialize s3 bucket vvvvv
                aws s3api create-bucket --bucket "$bucket" --region "$region" | jq -r '.Location' > /dev/null
                aws s3api list-buckets | jq -r '.Buckets[]|.Name'
                if [[ -n "$backend_folder" ]]
                then
                    aws s3api put-object --bucket "$bucket" --key "$backend_folder" > /dev/null
                fi
                aws s3 ls "s3://$bucket"	
             
                # Initialize dynamodb table vvvvv
                aws dynamodb create-table \
                --table-name "$dynamodb_table" \
                --attribute-definitions AttributeName="$key_name",AttributeType=S \
                --key-schema AttributeName="$key_name",KeyType=HASH \
                --provisioned-throughput ReadCapacityUnits=$capacity_units,WriteCapacityUnits=$capacity_units \
                --region "$region" \
                > /dev/null
                aws dynamodb wait table-exists --table-name "$dynamodb_table" --region "$region"
                aws dynamodb describe-table --table-name "$dynamodb_table" --region "$region" \
                | jq -r '.Table|[.TableName, ":", .KeySchema[].AttributeName] | @tsv'

                terraform init -reconfigure
            fi            
            echo "Remote backend appears in effect."
			;;
         *) echo "Supported: l[ocal], r[emote]. \"$mode\" unsupported."
		    ;;
    esac
}

function ws {
    # Using the argument as a left-justified wildcard, find the matching var names and return the name=value list
    # --- Usage: ws <current environment variable name pattern>
    for _name_pattern in $@
    do
        declare -p | cut -d ' ' -f 3- | grep "^$_name_pattern" | sed "s~=\"~=~;s~\"$~~" | grep "^$_name_pattern"
    done
}

function read_s3_backend_settings {
    # From $infra_source file (e.g., backend.tf), retrieve all the definitive backend settings 
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
}

main $@


