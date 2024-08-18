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

    for x in ${players[@]}
    do
        if [[ -s "$x" ]]; then cp "$x" "$target"; fi
    done

    if [[ "$target/README.md" ]]
    then
        sed -i '' -e "\~Run the following~,\~^$~d; s~After that, r~R~" "$target/README.md"
    fi
    # Return to the root folder
    popd > /dev/null

    # Update main.tf file to expose the variables defined in the root module
    sedf=".sed"
    cat > "$sedf" << HEAD
#!/usr/bin/env bash
sed -E -i '' -e "/}/i\\\\
HEAD
    for vname in $( grep variable variables.tf | grep -v "scripts_home" | cut -d\" -f2 )
    do
        echo "  $vname = var.$vname\\\\" >> "$sedf"
    done
    # vvv Make sure that the target sed script will not add extra blank line at file end:
    # sed -i '' '$s/\\$//' "$sedf"
    IFS_SAVE=$IFS; IFS=$'\n'
    for line in $( cat "$from_main" | egrep -e "^[[:space:]]*[^=]+=[[:space:]]*local.[[:print:]]+$" )
    do
        echo "$line" >> "$sedf"
    done
    IFS=$IFS_SAVE
    cat >> "$sedf" << FOOT
" "$to_update"
FOOT
    chmod +x "$sedf"
    ./"$sedf"
    rm "$sedf"

    # Propagate the output from the original root module to this module:
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

