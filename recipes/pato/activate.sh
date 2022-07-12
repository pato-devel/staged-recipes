#!/usr/bin/env bash
echo activate PATO

# create volume_pato folder
if [ ! -d $CONDA_PREFIX/src/volume_pato ]; then
    mkdir -p $CONDA_PREFIX/src/volume_pato
fi

# create volume_pato.sparsebundle volume
if [ "$(uname)" = "Darwin" ]; then
    if [ ! -d $CONDA_PREFIX/src/volume_pato.sparsebundle ]; then
	curr_dir=$PWD
	cd $CONDA_PREFIX/src
	hdiutil create -size 32g -type SPARSEBUNDLE -fs HFSX -volname volume_pato -fsargs -s volume_pato.sparsebundle
	cd $curr_dir
    fi
fi

# detach and attach the volume
if [ "$(uname)" = "Darwin" ]; then
    for i in "$PREFIX" "$BUILD_PREFIX"
    do
        if mount | grep "on $i/src/volume_pato " > /dev/null; then
            curr_dir=$PWD
            cd $i/src
            hdiutil detach volume_pato
            cd $curr_dir
        fi
    done
    LOCALMOUNTPOINT="$CONDA_PREFIX/src/volume_pato"
    if ! mount | grep "on $LOCALMOUNTPOINT " > /dev/null; then
        hdiutil attach -mountpoint $CONDA_PREFIX/src/volume_pato $CONDA_PREFIX/src/volume_pato.sparsebundle
    fi
fi

# create soft links for the gnu tools (gcc, g++, ...)
if [ "$(uname)" = "Linux" ]; then
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

# compile and source PATO
if [ ! -d $CONDA_PREFIX/src/volume_pato/PATO-dev ]; then
    curr_dir=$PWD
    cd $CONDA_PREFIX/src/volume_pato
    echo Compiling PATO-dev
    git clone git@gitlab.com:PATO/PATO-dev.git
    if [ ! -d $CONDA_PREFIX/src/volume_pato/PATO-dev ]; then
        echo 1>&2 "Error: You need access to PATO-dev git. Check out \"https://pato.ac/\"."
        return
    fi
    export PATO_DIR=$PWD/PATO-dev
    source $PATO_DIR/bashrc
    $PATO_DIR/Allwmake
    cd $curr_dir
else
    if [ -f $CONDA_PREFIX/src/volume_pato/PATO-dev/bashrc ]; then
        export PATO_DIR=$CONDA_PREFIX/src/volume_pato/PATO-dev
        source $PATO_DIR/bashrc
    fi
fi

