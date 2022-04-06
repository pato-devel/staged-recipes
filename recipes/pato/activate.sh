#!/usr/bin/env bash
echo activate PATO
if [ "$(uname)" = "Darwin" ]; then
    if [ ! -d $CONDA_PREFIX/src/volume_pato ]; then
	mkdir -p $CONDA_PREFIX/src/volume_pato
    fi
    for i in "$PREFIX" "$BUILD_PREFIX"
    do
        if mount | grep "on $i/src/volume_pato " > /dev/null; then
            curr_dit=$PWD
            cd $i/src
            hdiutil detach volume_pato
            cd $curr_dir
        fi
    done
    LOCALMOUNTPOINT="$CONDA_PREFIX/src/volume_pato"
    if ! mount | grep "on $LOCALMOUNTPOINT " > /dev/null; then
	hdiutil attach -mountpoint $CONDA_PREFIX/src/volume_pato $CONDA_PREFIX/src/pato_conda.sparsebundle
    fi
fi
if [ "$(uname)" = "Linux" ]; then
    if [ ! -d $CONDA_PREFIX/src/volume_pato ]; then
	tar xvf $CONDA_PREFIX/src/volume_pato.tar -C $CONDA_PREFIX/src > /dev/null
	rm -f $CONDA_PREFIX/src/volume_pato.tar
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
if [ -f $CONDA_PREFIX/src/volume_pato/PATO/PATO-dev-2.3.1/bashrc ]; then
    export PATO_DIR=$CONDA_PREFIX/src/volume_pato/PATO/PATO-dev-2.3.1
    source $PATO_DIR/bashrc
fi
if [ "$(uname)" = "Darwin" ]; then
    if [ -f $CONDA_PREFIX/src/volume_pato/PATO/PATO-dev-2.3.1/data/Environments/RawData/Earth/environmentComposition ]; then
	if [ -f $CONDA_PREFIX/src/environmentComposition ]; then
	    cp $CONDA_PREFIX/src/environmentComposition $CONDA_PREFIX/src/volume_pato/PATO/PATO-dev-2.3.1/data/Environments/RawData/Earth/environmentComposition
	    rm -f $CONDA_PREFIX/src/environmentComposition
	fi
    fi
fi
