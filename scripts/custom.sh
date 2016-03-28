#!/bin/bash

# custom.sh
#
# When placed in the ../scripts directory this bash script is automatically invoked by
# Vagrant (see Vagrantfile for details).  To make the Vagrant and shell provisioning process
# infinitely extendable, this script will scan the ../scripts/custom/ directory for other *.sh
# bash scripts and provision the VM from them.
#
# Changes:
# 26-Mar-2016 - Initial script.
#

echo "Installing customizations per ../scripts/custom.sh."

# Pull variables from ../config/variables.
SHARED_DIR=$1

if [ -f "$SHARED_DIR/configs/variables" ]; then
  # shellcheck source=/dev/null
  . "$SHARED_DIR"/configs/variables
fi

# Now, check for a ../config/custom_variables and pull definitions from it if found.
if [ -f "$SHARED_DIR/configs/custom_variables" ]; then
  echo "Invoking ../configs/custom_variables."
  . "$SHARED_DIR"/configs/custom_variables
fi

# Run all the scripts (*.sh) found in ../scripts/custom/.
for SCRIPT in ${SHARED_DIR}/scripts/custom/*.sh
do
  if [ -f $SCRIPT ]
  then
    echo "Custom.sh is invoking script '$SCRIPT'..."
	source $SCRIPT
  fi
done

