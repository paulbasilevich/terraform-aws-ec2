#!/usr/bin/env bash

# This script copies the runtime-environment-specific terraform configuration files
# to the root folder by running:       .terraform/modules/ec2/scripts/init.sh
#
# Sets up terraform workspace, the name based on the local hosting directory name
# Creates and initializes AWS S3/Dynamodb-based remote state infrastructure
# Provides API for toggling between remote and local terraform state

# Also propagates the terraform variables and outputs
# from the root submodule to the current directory
#
# Expects no arguments

__min_bash_version=4
if [[ $( bash --version | head -1 | awk '{print $4}' | cut -d '.' -f 1 ) -lt $__min_bash_version ]]
then
    bash --version
    echo
    echo "### This process needs bash version $__min_bash_version or higher to work. ###"
    exit 1
fi

state_type="${1:-remote_state}"
state_type="${state_type,,}"
if [[ -n "$1" && "${state_type::1}" != "l" ]]; then
    echo "Invalid argument \"$1\". Allowed arguments: l[ocal_state] | r[emote_state] (defaulted)"
    exit 1
fi
target="$( pwd )"
# Set up directory for script links
targs="..."
targets="$target/$targs"
rm -rf "$targets"; mkdir -p "$targets"
aws_account="$( aws sts get-caller-identity | jq -r '.Account' 2> /dev/null )"
if [[ -z "$aws_account" ]]; then
    echo "AWS account needs to be set up first"
    exit 1
fi

# Construct workspace name from path to the top-level directory of this deployment
# N.B.  "_" character is unacceptable in bucket name; using "-"
workspace_name="$( echo "${PWD#$HOME/}" | tr '/' '_' )"

# Construct the ssh key name
# as concatenation of first character of each "-"-delimited substring of the workspace name
unset workspace_key
IFS_SAVE=$IFS
IFS='_'; for x in $workspace_name; do workspace_key+=${x: :1}; done
IFS=$IFS_SAVE

# Evaluate path to the top directory of this module - apex
apex="$( realpath "$( dirname "$( dirname "$0" )" )" )"
tfvars="$apex/terraform.tfvars"

# Update tfvars file with the evaluated Name tag, ssh_key_name, and aws_profile
tag_block="\~^[[:space:]]*tags_bootstrap[[:space:]]*=[[:space:]]*\{~,\~^\}~"
name_entry="~(^[[:space:]]*Name[[:space:]]=[[:space:]]*\")([^\"]+)(\")~"
if [[ -s "$tfvars" ]]; then
    sed -E -i '' -e "
              ${tag_block}s${name_entry}\1${workspace_name^}\3~;
              s~(^ssh_key_name[[:space:]]*=[[:space:]]*\")([^\"]+)(\")~\1$workspace_key\3~;
              s~(^aws_profile[[:space:]]*=[[:space:]]*\")([^\"]+)(\")~\1${AWS_PROFILE:-default}\3~;
              " "$tfvars"
fi

# Generate remote backend
# N.B.  region is restricted to us-east-1
backend_file_name="backend"
s3_file="$apex/${backend_file_name}.ft"
state_file_name="terraform.tfstate"
cat > "$s3_file" << BEND
terraform {
  backend "s3" {
    bucket         = "${aws_account}-${workspace_name//_/-}-terraform-backend"
    key            = "${aws_account}-${workspace_name}/$state_file_name"
    region         = "us-east-1"
    dynamodb_table = "${aws_account}-${workspace_name}-terraform-state-locking"
  }
}
BEND

# Create s3/dynamodb backend infrastructure
"$( dirname "$0" )"/terraform_backend.sh "$state_type"

to_update="main.tf"
this_module="$(
    egrep -e "^[[:space:]]*module[[:space:]]+[\"][^\"]+[\"][[:space:]]*{" "$to_update" \
    | head -1 | cut -d\" -f2
    )"

origin="$( dirname "${BASH_SOURCE[0]}" )"
my_root="$( dirname "$origin" )"

# Extra custom scripts developed so far and hosted in the same directory as this script:
players=(
    "retain_aws_secret.sh=autonomize security manager=zas"
    "destroy_aws_secret.sh=destroy security manager=zds"
    "terraform_backend.sh=view remote<->local state source=zrl"
)

IFS_SAVE=$IFS
IFS=$'\n'; IFS_SAVEL=$IFS
pushd "$origin" > /dev/null
for l in ${players[@]}; do
    IFS=$'='
    read x y z <<< $( echo "$l" )
    IFS=$IFS_SAVEL
    xr="$( realpath "$x" )"
    pushd "$targets" > /dev/null
    ln -s "$xr" "$y"
    popd > /dev/null
    pushd "$target" > /dev/null
    ln -s "$targs/$y" "$z"
    popd > /dev/null
done
IFS=$IFS_SAVE

# Up to the parent directory for terraform config files:
cd ..

if [[ "$my_root" != "." ]]; then
    from_output="$( pwd )/outputs.tf"
    from_main="$( pwd )/main.tf"

    # Bring the "original" top-level config files up to the root directory:
    players=(
        README.md
        terraform.tfvars
        variables.tf
        locals.tf
    )

    # Define config variables
    orig_vars_file="$target/variables.tf"
    egrep -q -e "^aws_profile[[:space:]]+=[[:space:]]+[[:graph:]]*pilot[[:graph:]]*\"" "$orig_vars_file" 2> /dev/null
    is_pilot=$?
    if [[ $is_pilot -ne 0 ]]
    then
        current_aws_profile="$( { grep -B 1 $( aws configure get aws_access_key_id ) ~/.aws/credentials 2> /dev/null \
        | tr '\n' ' ' | sed -E -e "s~[[:space:]]+--[[:space:]]+~\n~g" \
        | grep -v __default__ \
        | tr -d '[]' \
        | sed -E -e "s~aws_access_key_id[[:space:]]+=[[:space:]]+[[:graph:]]{20}[[:space:]]*~~" \
        2> /dev/null; } || { echo default; } )"
        echo "$current_aws_profile" | grep -q "pilot"
        is_pilot=$?
    fi

    if [[ -s "$orig_vars_file" && $is_pilot -eq 0 ]]; then
        # Map AWS config variables to the respective tags used in config file:
        declare -A cfgmap=(
            [AWS_ACCESS_KEY_ID]="aws_access_key_id" \
            [AWS_SECRET_ACCESS_KEY]="aws_secret_access_key" \
            [AWS_SESSION_TOKEN]="aws_session_token" \
            [AWS_REGION]="region" \
            [ACCOUNT_ID]="sso_account_id" \
        )

        # Look up the "master" variable.tf file for AWS config variables
        # For each such one, retrieve the value via "aws configure get"
        # and persist it to terraform.tfvars.
        # From security perspective, it is better off to use "export TV_VAR_<var name>=..." technique.
        tfv="terraform.tfvars"
        for v in $( grep "variable" "$orig_vars_file" | tr -d '"' | awk '{print $2}' ); do
            if [[ ${cfgmap[$v]+_} ]]
            then
                echo $v=\"$( aws configure get ${cfgmap[$v]} )\" >> "$tfv"
            fi
        done
    fi

    for x in ${players[@]}; do
        if [[ -s "$x" ]]; then
            y="$target/$x"
            if [[ -s "$y" ]]; then  # If the target file exists, append it rather than override
                echo -e "\n" >> "$y"
                cat "$x" >> "$y"
            else                # Replicate the new file to the "new root" module as is
                cp "$x" "$target"
            fi
        fi
    done

    if [[ "$target/README.md" ]]; then
        sed -i '' -e "\~Run the following~,\~^$~d; s~After that, r~R~" "$target/README.md"
    fi
    # Return to the root folder
    popd > /dev/null

    # Helper function that finds all the env variable
    # with wildcard names matching the given prefix pattern.
    # Multiple patterns passed through the command line signature
    # as a space-delimited list.
    # Simulates Windows CMD "SET [name pattern]" command.
    ws(){
        for _name_pattern in $@
        do
            declare -p | cut -d ' ' -f 3- | grep "^$_name_pattern" | sed "s~=\"~=~;s~\"$~~" | grep "^$_name_pattern"
        done
    }

    # On exit from this script, this block deletes all the temp files, if any, created by the script.
    file_name_prefix="tempf_"
    trap 'for fname in $( ws "$file_name_prefix" ); do rm -f "${fname#*=}"; done' EXIT

    # Update main.tf file to expose the variables defined in the root module:
    # Create a SED script that replicates each variable definition from "original" root module
    # prepending each value with "var." and injects the generated statement
    # into the "module" clause of the bootstrap main.tf file.
    tempf_sedf=$( mktemp )
    cat > "$tempf_sedf" << HEAD
#!/usr/bin/env bash
sed -E -i '' -e "/}/i\\\\
HEAD
    for vname in $( grep "variable" "$my_root/variables.tf" | grep -v "scripts_home" | cut -d\" -f2 ); do
        echo "  $vname = var.$vname\\\\" >> "$tempf_sedf"
    done
    # vvv Make sure that the target sed script will not add extra blank line at file end:
    # sed -i '' '$s/\\$//' "$tempf_sedf"
    IFS_SAVE=$IFS; IFS=$'\n'
    for line in $( cat "$from_main" | egrep -e "^[[:space:]]*[^=]+=[[:space:]]*local.[[:print:]]+$" ); do
        echo "$line" >> "$tempf_sedf"
    done
    IFS=$IFS_SAVE
    cat >> "$tempf_sedf" << FOOT
" "$to_update"
FOOT
    chmod +x "$tempf_sedf"
    "$tempf_sedf"

    # Propagate the output from the original root module to this module, namely:
    # replicate the "original" output, replace each "value"
    # by prepending it with "module.<new root module name, e.g., ec2>".
    # Replicate "description", if any, set for each "original" output.
    output="outputs.tf"
    IFS=$'\}'
    for x in $(
        sed -E -n "\~^output[[:space:]]+[[:graph:]]+[[:space:]]*{$~,\~^}$~p" "$from_output" \
            | egrep -e "^}$|^[[:space:]]*(output[[:space:]]+[\"][^\"]+[\"][[:space:]]*{)|(description[[:space:]]+=)"
        )
    do
        IFS=$'\n'
        for y in ${x[@]}; do
            echo "$y" | egrep -q -e "^[[:space:]]*output[[:space:]]+[\"][^\"]+[\"][[:space:]]*{"
            if [[ $? -eq 0 ]]; then
                name="$( echo "$y" | cut -d\" -f2 )"
            fi
            echo $y
        done
        echo -e "  value = module.$this_module.$name\n}\n"
        IFS=$'\}'
    done > "$output"

    if [[ "${state_type::1}" == "r" ]]; then  # Activate remote state
        s3_target="$( basename "$s3_file" )"
        # If 'zrl v' is used after initialization, s3_file may have been moved by zrl
        [[ -s "$s3_file" ]] && mv "$s3_file" ./"${s3_target%.*}.tf"
        cd "$target"
    fi
    terraform init -migrate-state -force-copy > /dev/null
    qry_workspace="$( terraform workspace list | grep -o "$workspace_name" )"
    if [[ "$qry_workspace" == "$workspace_name" ]]; then
        terraform workspace select default > /dev/null
        terraform workspace delete "$workspace_name" > /dev/null
    fi
    terraform workspace new "$workspace_name"
    terraform fmt > /dev/null
fi

if [[ -s "README.md" ]]; then
    echo -e "\nRefer to README.md file for instructions and suggestions."
else
    echo "Initialization complete."
fi

