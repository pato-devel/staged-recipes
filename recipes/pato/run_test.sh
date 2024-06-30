#!/bin/bash
set -e  # exit when any command fails
set -x # show the commands

curr_dir=$PWD
echo -e "\n### TESTING PATO ###\n"
cd $PREFIX
# Source PATO run functions
. $PATO_DIR/src/applications/utilities/runFunctions/RunFunctions
# Initialize the script
alias wmRefresh="" # needed before to source openfoam bashrc
pato_init
# run tests
which runtests
runtests
# detach volume
if [ "$(uname)" = "Darwin" ]; then
    cd $PREFIX/src
    # detach volume_openfoam_for_pato
    hdiutil detach volume_openfoam_for_pato
    # detach volume_foam-extend_for_pato
    hdiutil detach volume_foam-extend_for_pato
    # detach volume_pato
    hdiutil detach volume_pato
fi
cd $curr_dir
