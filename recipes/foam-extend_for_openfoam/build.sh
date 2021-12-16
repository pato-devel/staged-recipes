#!/bin/bash
set -e  # exit when any command fails
set -x

echo -e "\n### INSTALLING PATO ###\n"

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.     
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done

# create volume folder
if [ ! -d $PREFIX/src/volume ]; then
    mkdir -p $PREFIX/src/volume
fi
cd $PREFIX/src
    
if [ "$(uname)" = "Linux" ]; then
    # move src to volume
    mv $SRC_DIR/src/* $PREFIX/src/volume/
    rm -rf $SRC_DIR/src
fi

if [ "$(uname)" = "Darwin" ]; then
    # create volume
    hdiutil create -size 16g -type SPARSEBUNDLE -fs HFSX -volname foam-extend_for_openfoam_conda -fsargs -s foam-extend_for_openfoam_conda.sparsebundle
    # attach volume
    hdiutil attach -mountpoint volume foam-extend_for_openfoam_conda.sparsebundle
    # move src to volume
    mv $SRC_DIR/src/* $PREFIX/src/volume/
    rm -rf $SRC_DIR/src
fi

# compile ParMGridGen
cd $PREFIX/src/volume/parmgridgen
tar xvf ParMGridGen-0.0.2.tar.gz
cd ParMGridGen-0.0.2
if [ "$(uname)" = "Linux" ]; then
    dir_gcc=$(dirname `which x86_64-conda-linux-gnu-gcc`)
    cd $dir_gcc
    files=`find . -name "x86_64-conda-linux-gnu-*" -type f`
    for x in $files
    do
        old_name=${x#"./"}
        new_name=${x#"./x86_64-conda-linux-gnu-"}
        ln -s $old_name $new_name
    done
    cd $PREFIX/src/volume/parmgridgen/ParMGridGen-0.0.2
    $sed_cmd -i "s/clang/gcc/g" Makefile.in
    export C_INCLUDE_PATH=$BUILD_PREFIX/include
    export CPLUS_INCLUDE_PATH=$BUILD_PREFIX/include
fi
make
cp MGridGen/IMlib/libIMlib.a .
cp libmgrid.a libMGridGen.a

# get foam-extend src
cd $PREFIX/src/volume
tar xvf foam-extend-4.1_for_openfoam-7.tar
# compile foam-extend 4.1
export WM_NCOMPPROCS=`nproc` # parallel build
cd $PREFIX/src/volume/foam-extend-4.1_for_openfoam-7/etc
if [ "$(uname)" = "Linux" ]; then
    alias wmRefresh=""
fi
set +e
source bashrc
set -e
cd $PREFIX/src/volume/foam-extend-4.1_for_openfoam-7
./Allwmake -j

# Archive volume
if [ "$(uname)" = "Linux" ]; then
    cd $PREFIX/src
    tar czvf volume.tar volume < /dev/null
    rm -rf volume
fi

if [ "$(uname)" = "Darwin" ]; then
    cd $PREFIX/src
    # detach volume
    hdiutil detach volume
fi

