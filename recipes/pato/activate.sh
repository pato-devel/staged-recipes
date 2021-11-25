#!/usr/bin/env bash
hdiutil attach -mountpoint $CONDA_PREFIX/src/volume $CONDA_PREFIX/src/pato_releases_conda.sparsebundle
source $CONDA_PREFIX/src/volume/OpenFOAM/OpenFOAM-7/etc/bashrc
export PATO_DIR=$CONDA_PREFIX/src/volume/PATO/PATO-dev-2.3.1
source $PATO_DIR/bashrc
