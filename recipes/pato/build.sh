#!/bin/bash
set -e  # exit when any command fails
set -x

echo -e "\n### INSTALLING PATO ###\n"

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.     
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done

PATO_VERSION=PATO-v3.0
curr_dir=$PWD
cd $CONDA_PREFIX/src/volume_pato
echo Download $PATO_VERSION
wget http://pato.ac/wp-content/uploads/$PATO_VERSION.tar.gz
cd $PATO_VERSION
export PATO_DIR=$PWD/
source $PATO_DIR/bashrc
$PATO_DIR/Allwmake
cd $curr_dir
