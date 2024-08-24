#!/usr/bin/env bash

# This script copies the runtime-environment-specific terraform configuration files
# to the root folder by running:       .terraform/modules/ec2/scripts/init.sh

# Also propagates the terraform variables and outputs
# from the root submodule to the current directory
 
target="$( pwd )"
to_update="main.tf"
this_module="$(
    egrep -e "^[[:space:]]*module[[:space:]]+[\"][^\"]+[\"][[:space:]]*{" "$to_update" \
    | head -1 | cut -d\" -f2
    )"

origin="$( dirname "${BASH_SOURCE[0]}" )"
my_root="$( dirname "$origin" )"

# Extra custom scripts developed so far and hosted in the same directory as this script:
players=(
    retain_aws_secret.sh
    destroy_aws_secret.sh
)

pushd "$origin" > /dev/null
for x in ${players[@]}
do
    if [[ -s "$x" ]]; then cp "$x" "$target"; fi
done

# Up to the parent directory for terraform config files:
cd ..

if [[ "$my_root" != "." ]]
then
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
    if [[ -s "$orig_vars_file" ]]
    then
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
        for v in $( grep "variable" "$orig_vars_file" | tr -d '"' | awk '{print $2}' )
        do
            if [[ ${cfgmap[$v]+_} ]]
            then
                echo $v=\"$( aws configure get ${cfgmap[$v]} )\" >> "$tfv"
            fi
        done
    fi

    for x in ${players[@]}
    do
        if [[ -s "$x" ]]
        then
            y="$target/$x"
            if [[ -s "$y" ]]    # If the target file exists, append it rather than override
            then
                echo -e "\n" >> "$y"
                cat "$x" >> "$y"
            else                # Replicate the new file to the "new root" module as is
                cp "$x" "$target"
            fi
        fi
    done

    if [[ "$target/README.md" ]]
    then
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
    for vname in $( grep "variable" "$my_root/variables.tf" | grep -v "scripts_home" | cut -d\" -f2 )
    do
        echo "  $vname = var.$vname\\\\" >> "$tempf_sedf"
    done
    # vvv Make sure that the target sed script will not add extra blank line at file end:
    # sed -i '' '$s/\\$//' "$tempf_sedf"
    IFS_SAVE=$IFS; IFS=$'\n'
    for line in $( cat "$from_main" | egrep -e "^[[:space:]]*[^=]+=[[:space:]]*local.[[:print:]]+$" )
    do
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
        for y in ${x[@]}
        do
            echo "$y" | egrep -q -e "^[[:space:]]*output[[:space:]]+[\"][^\"]+[\"][[:space:]]*{"
            if [[ $? -eq 0 ]]
            then
                name="$( echo "$y" | cut -d\" -f2 )"
            fi
            echo $y
        done
        echo -e "  value = module.$this_module.$name\n}\n"
        IFS=$'\}'
    done > "$output"

    terraform fmt > /dev/null
fi

if [[ -s "README.md" ]]
then
    echo "Refer to README.md file for instructions and suggestions."
else
    echo "Initialization complete."
fi

