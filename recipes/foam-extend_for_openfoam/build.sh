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

# create volume_foam-extend_for_openfoam folder
if [ ! -d $PREFIX/src/volume_foam-extend_for_openfoam ]; then
    mkdir -p $PREFIX/src/volume_foam-extend_for_openfoam
fi
cd $PREFIX/src
    
if [ "$(uname)" = "Linux" ]; then
    # move src to volume_foam-extend_for_openfoam
    mv $SRC_DIR/src/* $PREFIX/src/volume_foam-extend_for_openfoam/
    rm -rf $SRC_DIR/src
    export sed_cmd=sed
fi

if [ "$(uname)" = "Darwin" ]; then
    # create volume_foam-extend_for_openfoam
    hdiutil create -size 16g -type SPARSEBUNDLE -fs HFSX -volname foam-extend_for_openfoam_conda -fsargs -s foam-extend_for_openfoam_conda.sparsebundle
    # attach volume_foam-extend_for_openfoam
    hdiutil attach -mountpoint volume_foam-extend_for_openfoam foam-extend_for_openfoam_conda.sparsebundle
    # move src to volume_foam-extend_for_openfoam
    mv $SRC_DIR/src/* $PREFIX/src/volume_foam-extend_for_openfoam/
    rm -rf $SRC_DIR/src
    export sed_cmd=gsed
fi

# compile ParMGridGen
cd $PREFIX/src/volume_foam-extend_for_openfoam/parmgridgen
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
    cd $PREFIX/src/volume_foam-extend_for_openfoam/parmgridgen/ParMGridGen-0.0.2
    $sed_cmd -i "s/clang/gcc/g" Makefile.in
    $sed_cmd -i "s/COPTIONS =/COPTIONS = -fPIC/g" Makefile.in
    export C_INCLUDE_PATH=$BUILD_PREFIX/include
    export CPLUS_INCLUDE_PATH=$BUILD_PREFIX/include
fi
make
cp MGridGen/IMlib/libIMlib.a .
cp libmgrid.a libMGridGen.a

# get foam-extend src
cd $PREFIX/src/volume_foam-extend_for_openfoam
tar xvf foam-extend-4.1_for_openfoam-7.tar
# compile foam-extend 4.1
export WM_NCOMPPROCS=`nproc` # parallel build
cd $PREFIX/src/volume_foam-extend_for_openfoam/foam-extend-4.1_for_openfoam-7/etc
if [ "$(uname)" = "Linux" ]; then
    alias wmRefresh=""
fi
set +e
cp prefs.sh-build prefs.sh # using PREFIX
source bashrc
cp prefs.sh-run prefs.sh # using CONDA_PREFIX
set -e
cd $PREFIX/src/volume_foam-extend_for_openfoam/foam-extend-4.1_for_openfoam-7
./Allwmake -j

# Archive volume_foam-extend_for_openfoam
if [ "$(uname)" = "Linux" ]; then
    cd $PREFIX/src
    tar czvf volume_foam-extend_for_openfoam.tar volume_foam-extend_for_openfoam > /dev/null
    rm -rf volume_foam-extend_for_openfoam
fi

if [ "$(uname)" = "Darwin" ]; then
    cd $PREFIX/src
    # detach volume_foam-extend_for_openfoam
    hdiutil detach volume_foam-extend_for_openfoam
fi

