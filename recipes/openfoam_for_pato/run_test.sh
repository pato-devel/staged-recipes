#!/bin/bash
set -e  # exit when any command fails
set -x # show the commands

echo -e "\n### TESTING OpenFOAM ###\n"

if [ ! -f $CONDA_PREFIX/src/volume_pato_releases_conda/OpenFOAM/OpenFOAM-7/platforms/linux64GccDPInt32Opt/bin/blockMesh ]; then
     exit 1 # error
fi

if [ "$(uname)" = "Darwin" ]; then
    cd $PREFIX/src
    # detach volume
    hdiutil detach volume
fi
