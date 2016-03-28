#!/bin/bash

# scg.sh
#
# When placed in the ../scripts/custom directory this script will is automatically invoked by
# ../scripts/custom to load and configure Mark Jordan's Sample Content Generator
# (https://github.com/mjordan/islandora_scg) module.
#
# This script, authored by Peter MacDonald and Mark McFate on 24-March-2016, was patterned
# after https://github.com/Islandora-Labs/islandora_vagrant/blob/master/scripts/islandora_modules.sh.
# Several parts of the original script remain here (commented out) for reference.
#
# Usage: This script will automatically generate Islandora objects (content) if there are NONE or if
#   if ISLANDORA_VAGRANT_FORCE_CONTENT variable in the host's ../configs/custom_variables is defined.
#   Example:
#     export ISLANDORA_VAGRANT_FORCE_CONTENT=TRUE
#   Set ISLANDORA_VAGRANT_FORCE_CONTENT to "" (null) in order to disable content generation.
#
# Changes:
# 28-Mar-2016 - Added check for existing content and the ISLANDORA_VAGRANT_FORCE_CONTENT variable.
# 24-Mar-2016 - Added Mark Jordan's islandora_scg (Sample Content Generator) module with
#   representative content.
#

echo "Installing Mark Jordan's SCG per scg.sh."

SHARED_DIR=$1

if [ -f "$SHARED_DIR/configs/variables" ]; then
  # shellcheck source=/dev/null
  . "$SHARED_DIR"/configs/variables
fi

# Permissions and ownership
#sudo chown -hR vagrant:www-data "$DRUPAL_HOME"/sites/all/modules
#sudo chmod -R 755 "$DRUPAL_HOME"/sites/all/modules

# Clone custom modules from GitHub
echo "Cloning Mark Jordan's islandora_scg Module."
cd "$DRUPAL_HOME"/sites/all/modules || exit
git clone https://github.com/mjordan/islandora_scg
cd islandora_scg
git config core.filemode false

# Move pdf.js drush file to user's .drush folder
#if [ -d "$HOME_DIR/.drush" ] && [ -f "$DRUPAL_HOME/sites/all/modules/islandora_pdfjs/islandora_pdfjs.drush.inc" ]; then
#  mv "$DRUPAL_HOME/sites/all/modules/islandora_pdfjs/islandora_pdfjs.drush.inc" "$HOME_DIR/.drush"
#fi

# Enable the custom modules
drush -y -u 1 en islandora_scg

cd "$DRUPAL_HOME"/sites/all/modules || exit

# Set variables for Islandora modules
#drush eval "variable_set('islandora_audio_viewers', array('name' => array('none' => 'none', 'islandora_videojs' => 'islandora_videojs'), 'default' => 'islandora_videojs'))"

# Now, execute a Solr query to return a response for all PID:* values (basically counts all the
# Fedora objects, pass the result to sed and output only the numFound attribute of the response.
numFound=$(curl -s "http://localhost:8080/solr/collection1/select?q=PID:*&rows=0&wt=xml" | sed -n 's/.*numFound="\([^"]*\).*/\1/p')

echo "There are $numFound objects already in Fedora."

# Adding in Peter's SCG drush commands to create the content IF fewer than 20 objects already exists, or
# if the ISLANDORA_VAGRANT_FORCE CONTENT variable is set.
if [[ $numFound < 20 || $ISLANDORA_VAGRANT_FORCE_CONTENT ]]; then
  cd "$DRUPAL_HOME"/sites/all/modules/islandora_scg || exit
  echo "Generating content using the islandora_scg module."
  drush -u 1 iscgl --user=admin --quantity=2 --content_model=islandora:collectionCModel --parent=islandora:root --namespace=icg-collection
  drush -u 1 iscgl --user=admin --quantity=7 --content_model=islandora:sp_basic_image --parent=islandora:sp_basic_image_collection --namespace=icg-basic-image
  drush -u 1 iscgl --user=admin --quantity=2 --content_model=islandora:sp_large_image_cmodel --parent=islandora:sp_large_image_collection --namespace=icg-large-image
  drush -u 1 iscgl --user=admin --quantity=7 --content_model=islandora:sp_pdf --parent=islandora:sp_pdf_collection --namespace=icg-pdf
  drush -u 1 iscgl --user=admin --quantity=2 --content_model=islandora:bookCModel --parent=islandora:bookCollection --namespace=icg-book
  drush -u 1 iscgl --user=admin --quantity=2 --content_model=islandora:newspaperCModel --parent=islandora:newspaper_collection --namespace=icg-newspaper2
  drush -u 1 iscgl --user=admin --quantity=2 --content_model=islandora:newspaperPageCModel --parent=icg-newspaper2:1 --namespace=icg-newspaper-page
  drush -u 1 iscgl --user=admin --quantity=2 --content_model=islandora:newspaperPageCModel --parent=icg-newspaper2:2 --namespace=icg-newspaper-page
else
  echo "No additional content was generated."
fi

# Permissions and ownership
#sudo chown -hR vagrant:www-data "$DRUPAL_HOME"/sites/all/modules
#sudo chmod -R 755 "$DRUPAL_HOME"/sites/all/modules

