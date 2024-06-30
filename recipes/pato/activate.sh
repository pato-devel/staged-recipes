#!/usr/bin/env bash
echo activate PATO

curr_dir=$PWD

# PATO version
CONDA_PATO_VERSION=3.1

# create volume_pato folder and detach/attach the volume
if [ "$(uname)" = "Darwin" ]; then
    if [ ! -d $CONDA_PREFIX/src/volume_pato ]; then
	mkdir -p $CONDA_PREFIX/src/volume_pato
    fi
    for i in "$PREFIX" "$BUILD_PREFIX"
    do
        if mount | grep "on $i/src/volume_pato " > /dev/null; then
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
    # untar volume_pato
    if [ ! -d $CONDA_PREFIX/src/volume_pato ]; then
	tar xvf $CONDA_PREFIX/src/volume_pato.tar -C $CONDA_PREFIX/src > /dev/null
	rm -f $CONDA_PREFIX/src/volume_pato.tar
    fi
    # create soft links for the gnu tools (gcc, g++, ...)
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

# compile and source PATO
if [ -f $CONDA_PREFIX/src/volume_pato/pato-$CONDA_PATO_VERSION/bashrc ]; then
    export PATO_DIR=$CONDA_PREFIX/src/volume_pato/pato-$CONDA_PATO_VERSION
    source $PATO_DIR/bashrc
fi

# Change the codesign author if the runtests executable is zsh killed
set +e # for run_test.sh during conda build
if [ "$(uname)" = "Darwin" ]; then
    for dir_i in "$CONDA_PREFIX" "$PREFIX"
    do
	if [ -f $dir_i/src/volume_pato/pato-$CONDA_PATO_VERSION/install/bin/runtests ]; then
	    output=$($dir_i/src/volume_pato/pato-$CONDA_PATO_VERSION/install/bin/runtests -h 2>&1)
	    output_len=${#output}
	    if [ ! $output_len -gt 0 ]; then
		echo "$dir_i: codesign executables and libraries in OpenFOAM, foam-extend, and PATO."
		of_dir=$dir_i/src/volume_openfoam_for_pato/OpenFOAM/OpenFOAM-7/platforms/darwin64ClangDPInt32Opt
		find $of_dir/lib -type f -name "*.dylib" -exec /usr/bin/codesign -f -d -s - {} \; > /dev/null 2>&1
		find $of_dir/bin -type f -exec /usr/bin/codesign -f -d -s - {} \; > /dev/null 2>&1
		fe_dir=$dir_i/src/volume_foam-extend_for_pato/foam-extend-4.1_for_openfoam-7/lib/darwinArm64GccDPInt32Opt
		find $fe_dir -type f -name "*.dylib" -exec /usr/bin/codesign -f -d -s - {} \; > /dev/null 2>&1
		mu_dir=$dir_i/src/volume_pato/pato-$CONDA_PATO_VERSION/src/thirdParty/mutation++/install
		find $mu_dir/lib -type f -name "*.dylib" -exec /usr/bin/codesign -f -d -s - {} \; > /dev/null 2>&1
		find $mu_dir/bin -type f -exec /usr/bin/codesign -f -d -s - {} \; > /dev/null 2>&1
		pa_dir=$dir_i/src/volume_pato/pato-$CONDA_PATO_VERSION/install
		find $pa_dir/lib -type f -name "*.dylib" -exec /usr/bin/codesign -f -d -s - {} \; > /dev/null 2>&1
      		find $pa_dir/bin -type f -exec /usr/bin/codesign -f -d -s - {} \; > /dev/null 2>&1
	    fi
	fi
    done
fi
