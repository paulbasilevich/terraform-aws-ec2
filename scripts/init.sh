#!/usr/bin/env bash

# Copy the example files to the root folder by running:
#       .terraform/modules/ec2/examples/init.sh

master="$( basename "${BASH_SOURCE[0]}" )"
origin="$( dirname "${BASH_SOURCE[0]}" )"
target="$( pwd )"
to_update="main.tf"
this_module="ec2"
output="outputs.tf"

players=(
    retain_aws_secret.sh
    destroy_aws_secret.sh
)

# Get inside the module where the example files are stored
pushd "$origin" > /dev/null
for x in ${players[@]}; do cp "$x" "$target"; done

# Up to the parent directory for terraform config files:
cd ..
players=(
    README.md
    terraform.tfvars
    variables.tf
    outputs.tf
)

for x in ${players[@]}; do cp "$x" "$target"; done

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
sed -E -i '' -e "s~(=[[:space:]]+module.)([^.]+)(.[[:print:]]+)~\1$this_module\3~" "$output"

terraform fmt > /dev/null

echo "Refer to README.md file for instructions and suggestions."

