#!/bin/bash

# theme.sh
#
# When placed in the ../scripts/custom directory this script will be automatically invoked by
# ../scripts/custom to load and configure a Drupal theme (using Git or Drush) and set it as
# the guest's default theme.
#
# This script, authored by Mark McFate on 25-March-2016, was patterned
# after https://github.com/Islandora-Labs/islandora_vagrant/blob/master/scripts/islandora_modules.sh.
#
# Usage: Define and export an ISLANDORA_VAGRANT_THEME variable in the
#   host's ../configs/custom_variables script, and set its value to a complete Drupal
#   theme path from a Git repository or to a valid Drupal theme machine name.
#   Examples:
#     export ISLANDORA_VAGRANT_THEME=https://github.com/DigitalGrinnell/Digital_Grinnell_Theme
#     export ISLANDORA_VAGRANT_THEME=bootstrap
#
# Changes:
# 27-Mar-2016 - Initial script.
#

echo "This is the theme.sh shell provisioner script."
echo "It adds to the guest, via Git or Drush (from Drupal.org),
 a Drupal theme defined by ISLANDORA_VAGRANT_THEME in ../configs/custom_variables."

SHARED_DIR=$1

if [ -f "$SHARED_DIR/configs/variables" ]; then
  # shellcheck source=/dev/null
  . "$SHARED_DIR"/configs/variables
fi

# Looking for a custom theme?  Via Git (value begins with "http") or from Drupal?
if [[ $ISLANDORA_VAGRANT_THEME == "http"* ]]
then
  git=1
  drupal=0
elif [[ $ISLANDORA_VAGRANT_THEME != "" ]]
then
  drupal=1
  git=0
else
  echo "No custom theme specified."
  exit
fi

if [ ! -d "$DRUPAL_HOME"/sites/default/themes ]; then
  mkdir "$DRUPAL_HOME"/sites/default/themes || exit
fi

# Apply a custom theme using Git if one is defined by ISLANDORA_VAGRANT_THEME
# (if the value starts with "http").
if [[ $git -eq 1 ]]
then
  echo "Cloning custom theme using Git from 'ISLANDORA_VAGRANT_THEME'."
  cd "$DRUPAL_HOME"/sites/default/themes || exit
  git clone $ISLANDORA_VAGRANT_THEME
  cd */ || exit
  git config core.filemode false
  info=`ls *.info`
  echo "The theme's .info file is: $info."
  filename=$(basename "$info")
  theme="${filename%.*}"
  cd "$DRUPAL_HOME"/sites/default || exit
  echo "The custom theme '$theme' will be enabled and set as the default."
  drush -y -u 1 en $theme
  drush -u 1 vset theme_default $theme
fi

# Apply a custom Drupal.org theme if one is defined by ISLANDORA_VAGRANT_THEME
# (if the value does not begin with "http").
if [[ $drupal -eq 1 ]]
then
  echo "Downloading and enabling Drupal theme '$ISLANDORA_VAGRANT_THEME'."
  cd "$DRUPAL_HOME"/sites/default/themes || exit
  drush -y -u 1 dl $ISLANDORA_VAGRANT_THEME
  cd "$DRUPAL_HOME"/sites/default || exit
  echo "The custom theme '$ISLANDORA_VAGRANT_THEME' will be enabled and set as the default."
  drush -y -u 1 en $ISLANDORA_VAGRANT_THEME
  drush -u 1 vset theme_default $ISLANDORA_VAGRANT_THEME
fi

