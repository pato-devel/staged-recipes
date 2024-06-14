#!/bin/bash
set -e  # exit when any command fails
set -x

echo -e "\n### INSTALLING OPENFOAM ###\n"

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.     
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done

# Create soft links for the compilers
if [ "$(uname)" = "Linux" ]; then
    current_dir=$PWD
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
    cd $current_dir
fi

# create volume_openfoam_for_pato folder
if [ ! -d $PREFIX/src/volume_openfoam_for_pato ]; then
    mkdir -p $PREFIX/src/volume_openfoam_for_pato
fi
cd $PREFIX/src
    
if [ "$(uname)" = "Linux" ]; then
    # move src to volume_openfoam_for_pato
    mv $SRC_DIR/src/Linux/* $PREFIX/src/volume_openfoam_for_pato/
    mv $SRC_DIR/src/Both/* $PREFIX/src/volume_openfoam_for_pato/
    rm -rf $SRC_DIR/src
    sed_cmd=sed
fi

if [ "$(uname)" = "Darwin" ]; then
    # create volume: openfoam_for_pato_conda.sparsebundle
    hdiutil create -size 16g -type SPARSEBUNDLE -fs HFSX -volname openfoam_for_pato_conda -fsargs -s openfoam_for_pato_conda.sparsebundle
    # attach volume_openfoam_for_pato
    hdiutil attach -mountpoint volume_openfoam_for_pato openfoam_for_pato_conda.sparsebundle
    # move src to volume_openfoam_for_pato
    mv $SRC_DIR/src/MacOS/* $PREFIX/src/volume_openfoam_for_pato/
    mv $SRC_DIR/src/Both/* $PREFIX/src/volume_openfoam_for_pato/
    rm -rf $SRC_DIR/src
    mv $SRC_DIR/change_lib_path_macos.py $PREFIX/src/
    cp $PREFIX/bin/sed $PREFIX/bin/gsed
    sed_cmd=$PREFIX/bin/gsed
fi

# compile ParMGridGen
cd $PREFIX/src/volume_openfoam_for_pato/parmgridgen
tar xvf ParMGridGen-0.0.2.tar.gz
cd ParMGridGen-0.0.2
if [ "$(uname)" = "Linux" ]; then
    cd $PREFIX/src/volume_openfoam_for_pato/parmgridgen/ParMGridGen-0.0.2
    $sed_cmd -i "s/clang/gcc/g" Makefile.in
    $sed_cmd -i "s/COPTIONS =/COPTIONS = -fPIC/g" Makefile.in
    export C_INCLUDE_PATH=$BUILD_PREFIX/include
    export CPLUS_INCLUDE_PATH=$BUILD_PREFIX/include
fi
make
cp bin/mgridgen $PREFIX/bin/mgridgen
cp MGridGen/IMlib/libIMlib.a .
cp libmgrid.a libMGridGen.a

# get OpenFOAM src
cd $PREFIX/src/volume_openfoam_for_pato/OpenFOAM
tar xvf OpenFOAM-7.tar
tar xvf ThirdParty-7.tar
# compile OpenFOAM-7
if [ "$(uname)" = "Linux" ]; then
    export WM_NCOMPPROCS=`nproc` # parallel build
fi
if [ "$(uname)" = "Darwin" ]; then
    export WM_NCOMPPROCS=`sysctl -n hw.ncpu` # parallel build
fi
cd $PREFIX/src/volume_openfoam_for_pato/OpenFOAM/OpenFOAM-7
#if [ "$(uname)" = "Linux" ]; then
alias wmRefresh=""
#fi
source etc/bashrc
./Allwmake -j

# Change the libraries paths to $PREFIX
cd $PREFIX/src
export SRC_DIR=$PWD # for the python scripts
if [ "$(uname)" = "Darwin" ]; then
    python change_lib_path_macos.py
    rm -f change_lib_path_macos.py
fi

# Archive volume_openfoam_for_pato
if [ "$(uname)" = "Linux" ]; then
    cd $PREFIX/src
    tar czvf volume_openfoam_for_pato.tar volume_openfoam_for_pato > /dev/null
    rm -rf volume_openfoam_for_pato
fi

if [ "$(uname)" = "Darwin" ]; then
    # detach volume_openfoam_for_pato
    hdiutil detach volume_openfoam_for_pato
fi

