#!/usr/bin/env bash
echo activate OpenFOAM and PATO
if [ "$(uname)" = "Darwin" ]; then
    if [ ! -d $CONDA_PREFIX/src/volume ]; then
	mkdir -p $CONDA_PREFIX/src/volume
    fi
    hdiutil attach -mountpoint $CONDA_PREFIX/src/volume $CONDA_PREFIX/src/pato_releases_conda.sparsebundle
fi
if [ "$(uname)" = "Linux" ]; then
    if [ ! -d $CONDA_PREFIX/src/volume ] && [ -z "${CONDA_ROOT}" ]; then
	tar xvf $CONDA_PREFIX/src/volume.tar -C $CONDA_PREFIX/src > /dev/null
    fi
    dir_gcc=$(dirname `which x86_64-conda-linux-gnu-gcc`)
    cd $dir_gcc
    files=`find . -name "x86_64-conda-linux-gnu-*" -type f`
    for x in $files
    do
        old_name=${x#"./"}
        new_name=${x#"./x86_64-conda-linux-gnu-"}
	if [ ! -f $new_name ]; then
            ln -s $old_name $new_name
	fi
    done
fi
if [ -f $CONDA_PREFIX/src/volume/OpenFOAM/OpenFOAM-7/etc/bashrc ]; then
    if [ "$(uname)" = "Linux" ]; then
	alias wmRefresh=""
    fi
    source $CONDA_PREFIX/src/volume/OpenFOAM/OpenFOAM-7/etc/bashrc
fi
if [ -f $CONDA_PREFIX/src/volume/PATO/PATO-dev-2.3.1/bashrc ]; then
    export PATO_DIR=$CONDA_PREFIX/src/volume/PATO/PATO-dev-2.3.1
    source $PATO_DIR/bashrc
fi
