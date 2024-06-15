#!/usr/bin/env bash
echo activate openfoam_for_pato
curr_dir=$PWD
if [ "$(uname)" = "Darwin" ]; then
    if [ ! -d $CONDA_PREFIX/src/volume_openfoam_for_pato ]; then
        mkdir -p $CONDA_PREFIX/src/volume_openfoam_for_pato
    fi
    for i in "$PREFIX" "$BUILD_PREFIX"
    do
        if mount | grep "on $i/src/volume_openfoam_for_pato " > /dev/null; then
            cd $i/src
            hdiutil detach volume_openfoam_for_pato
            cd $curr_dir
        fi
    done
    LOCALMOUNTPOINT="$CONDA_PREFIX/src/volume_openfoam_for_pato"
    if ! mount | grep "on $LOCALMOUNTPOINT " > /dev/null; then
	hdiutil attach -mountpoint $CONDA_PREFIX/src/volume_openfoam_for_pato $CONDA_PREFIX/src/openfoam_for_pato_conda.sparsebundle
    fi
fi

if [ "$(uname)" = "Linux" ]; then
    if [ ! -d $CONDA_PREFIX/src/volume_openfoam_for_pato ]; then
	tar xvf $CONDA_PREFIX/src/volume_openfoam_for_pato.tar -C $CONDA_PREFIX/src > /dev/null
	rm -f $CONDA_PREFIX/src/volume_openfoam_for_pato.tar
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
    cd $curr_dir
fi

if [ -f $CONDA_PREFIX/src/volume_openfoam_for_pato/OpenFOAM/OpenFOAM-7/etc/bashrc ]; then
    alias wmRefresh=""
    source $CONDA_PREFIX/src/volume_openfoam_for_pato/OpenFOAM/OpenFOAM-7/etc/bashrc
fi

# Change the codesign author if the checkMesh executable is zsh killed
#if [ "$(uname)" = "Darwin" ]; then
#    output=$(checkMesh -help 2>&1)
#    output_len=${#output}
#    if [ ! $output_len -gt 0 ]; then
#	platforms_folder=$CONDA_PREFIX/src/volume_openfoam_for_pato/OpenFOAM/OpenFOAM-7/platforms/darwin64ClangDPInt32Opt
#	find $platforms_folder/lib -type f -name "*.dylib" -exec /usr/bin/codesign -f -d -s - {} \; > /dev/null 2>&1
#	find $platforms_folder/bin -type f -exec /usr/bin/codesign -f -d -s - {} \; > /dev/null	2>&1
#    fi
#fi
