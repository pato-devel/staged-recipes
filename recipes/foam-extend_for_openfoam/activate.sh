#!/usr/bin/env bash
echo activate foam-extend_for_openfoam
if [ "$(uname)" = "Darwin" ]; then
    CURRENT_DIR=$PWD
    LOCALMOUNTPOINT="$CONDA_PREFIX/src/volume_foam-extend_for_openfoam"
    if [ -d $LOCALMOUNTPOINT ]; then
        if mount | grep "on $LOCALMOUNTPOINT " > /dev/null; then
	    cd $CONDA_PREFIX
            hdiutil detach $LOCALMOUNTPOINT
	    cd $CURRENT_DIR
	fi
    fi	
    if [ ! -d $CONDA_PREFIX/src/volume_foam-extend_for_openfoam ]; then
	mkdir -p $CONDA_PREFIX/src/volume_foam-extend_for_openfoam
    fi
    hdiutil attach -mountpoint $CONDA_PREFIX/src/volume_foam-extend_for_openfoam $CONDA_PREFIX/src/foam-extend_for_openfoam_conda.sparsebundle
fi
if [ "$(uname)" = "Linux" ]; then
    CURRENT_DIR=$PWD
    cd $CONDA_PREFIX/src/volume_foam-extend_for_openfoam
    zip_files=`find . -path '*/*.zip' -type f`
    if [[ $zip_files ]]; then
	for file in $zip_files
	do
	    dir=$(dirname $file) # directory
	    dir=${dir#"./"} # remove ./
	    filename=$(basename $file)
	    curr_dir=$PWD
	    cd $dir
	    unzip $filename
	    rm -f $filename
	    cd $curr_dir
	done
    fi
    cd $CURRENT_DIR
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
if [ -f $CONDA_PREFIX/src/volume_foam-extend_for_openfoam/foam-extend-4.1_for_openfoam-7/etc/bashrc ]; then
    export FOAM_EXTEND_WM_OPTIONS=`ls $CONDA_PREFIX/src/volume_foam-extend_for_openfoam/foam-extend-4.1_for_openfoam-7/lib`
    export FOAM_EXTEND_SRC=$CONDA_PREFIX/src/volume_foam-extend_for_openfoam/foam-extend-4.1_for_openfoam-7/src
    export FOAM_EXTEND_LIB=$CONDA_PREFIX/src/volume_foam-extend_for_openfoam/foam-extend-4.1_for_openfoam-7/lib/$FOAM_EXTEND_WM_OPTIONS
    unset FOAM_EXTEND_WM_OPTIONS
fi
