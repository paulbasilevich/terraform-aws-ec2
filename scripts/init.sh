#!/usr/bin/env bash

# Copy the runtime-environment-specific files to the root folder by running:
#       .terraform/modules/ec2/scripts/init.sh

target="$( pwd )"
to_update="main.tf"
this_module="$(
    egrep -e "^[[:space:]]*module[[:space:]]+[\"][^\"]+[\"][[:space:]]*{" "$to_update" \
    | head -1 | cut -d\" -f2
    )"

path_pad_to_this_module=".$(
    egrep -e "^[[:space:]]*source[[:space:]]*=[[:space:]]*[\"][^\"]+[\"]" "$to_update" \
    | head -1 | cut -d\" -f2
    )"

origin="$( dirname "${BASH_SOURCE[0]}" )"

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
cd "$path_pad_to_this_module"

from_output="$( pwd )/outputs.tf"

# Bring the "original" top-level config files up to the root directory:
players=(
    README.md
    terraform.tfvars
    variables.tf
)

for x in ${players[@]}
do
    if [[ -s "$x" ]]; then cp "$x" "$target"; fi
done
# Return to the root folder
popd > /dev/null

# Update main.tf file to expose the variables defined in the root module
sedf=".sed"
cat > "$sedf" << HEAD
#!/usr/bin/env bash
sed -E -i '' -e "/}/i\\\\
HEAD
for vname in $( grep variable variables.tf | cut -d\" -f2 )
do
    echo "  $vname = var.$vname\\\\" >> "$sedf"
done
# vvv Make sure that the target sed script will not add extra blank line at file end:
sed -i '' '$s/\\$//' "$sedf"
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

if [[ -s "README.md" ]]
then
    echo "Refer to README.md file for instructions and suggestions."
else
    echo "Initialization complete."
fi

