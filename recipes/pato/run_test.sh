#!/bin/bash
set -e  # exit when any command fails
set -x # show the commands

curr_dir=$PWD
echo -e "\n### TESTING PATO ###\n"
cd $PREFIX
# run tests
which runtests
runtests

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
