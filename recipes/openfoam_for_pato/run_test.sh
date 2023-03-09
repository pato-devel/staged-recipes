#!/bin/bash
set -e  # exit when any command fails
set -x # show the commands

echo -e "\n### TESTING OpenFOAM ###\n"

if [ "$(uname)" = "Darwin" ]; then
    if [ ! -f $PREFIX/src/volume_openfoam_for_pato/OpenFOAM/OpenFOAM-10/platforms/darwin64ClangDPInt32Opt/bin/blockMesh ]; then
	exit 1 # error
    fi
    cd $PREFIX/src
    # detach volume_openfoam_for_pato
    hdiutil detach volume_openfoam_for_pato
else
    if [ ! -f $PREFIX/src/volume_openfoam_for_pato/OpenFOAM/OpenFOAM-10/platforms/linux64GccDPInt32Opt/bin/blockMesh ]; then
	exit 1 # error
    fi
fi
