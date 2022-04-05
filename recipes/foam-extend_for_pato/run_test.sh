#!/bin/bash
set -e  # exit when any command fails
set -x # show the commands

echo -e "\n### TESTING FOAM-EXTEND_FOR_OPENFOAM ###\n"

if [ "$(uname)" = "Darwin" ]; then
    if [ ! -f $PREFIX/src/volume_foam-extend_for_openfoam/foam-extend-4.1_for_openfoam-7/lib/darwinIntel64GccDPInt32Opt/lib_extend_foam.dylib ]; then
        exit 1 # error
    fi
    cd $PREFIX/src
    # detach volume
    hdiutil detach volume
else
    if [ ! -f $PREFIX/src/volume_foam-extend_for_openfoam/foam-extend-4.1_for_openfoam-7/lib/linux64GccDPInt32Opt/lib_extend_foam.so ]; then
        exit 1 # error
    fi
fi
