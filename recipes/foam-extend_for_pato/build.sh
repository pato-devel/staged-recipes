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

# create volume_foam-extend_for_pato folder
if [ ! -d $PREFIX/src/volume_foam-extend_for_pato ]; then
    mkdir -p $PREFIX/src/volume_foam-extend_for_pato
fi
cd $PREFIX/src
    
if [ "$(uname)" = "Linux" ]; then
    # move src to volume_foam-extend_for_pato
    mv $SRC_DIR/src/* $PREFIX/src/volume_foam-extend_for_pato/
    rm -rf $SRC_DIR/src
    export sed_cmd=sed
fi

if [ "$(uname)" = "Darwin" ]; then
    # create volume_foam-extend_for_pato
    hdiutil create -size 16g -type SPARSEBUNDLE -fs HFSX -volname foam-extend_for_pato_conda -fsargs -s foam-extend_for_pato_conda.sparsebundle
    # attach volume_foam-extend_for_pato
    hdiutil attach -mountpoint volume_foam-extend_for_pato foam-extend_for_pato_conda.sparsebundle
    # move src to volume_foam-extend_for_pato
    mv $SRC_DIR/src/* $PREFIX/src/volume_foam-extend_for_pato/
    rm -rf $SRC_DIR/src
    export sed_cmd=gsed
fi

# compile ParMGridGen
cd $PREFIX/src/volume_foam-extend_for_pato/parmgridgen
tar xvf ParMGridGen-0.0.2.tar.gz
cd ParMGridGen-0.0.2
if [ "$(uname)" = "Linux" ]; then
    cd $PREFIX/src/volume_foam-extend_for_pato/parmgridgen/ParMGridGen-0.0.2
    $sed_cmd -i "s/clang/gcc/g" Makefile.in
    $sed_cmd -i "s/COPTIONS =/COPTIONS = -fPIC/g" Makefile.in
    export C_INCLUDE_PATH=$BUILD_PREFIX/include
    export CPLUS_INCLUDE_PATH=$BUILD_PREFIX/include
fi
make
cp MGridGen/IMlib/libIMlib.a .
cp libmgrid.a libMGridGen.a

# get foam-extend src
cd $PREFIX/src/volume_foam-extend_for_pato
tar xvf foam-extend-4.1_for_openfoam-7.tar
# compile foam-extend 4.1
if [ "$(uname)" = "Linux" ]; then
    export WM_NCOMPPROCS=`nproc` # parallel build
fi
if [ "$(uname)" = "Darwin" ]; then
    export WM_NCOMPPROCS=`sysctl -n hw.ncpu` # parallel build
fi
cd $PREFIX/src/volume_foam-extend_for_pato/foam-extend-4.1_for_openfoam-7/etc
if [ "$(uname)" = "Linux" ]; then
    alias wmRefresh=""
fi
set +e
cp prefs.sh-build prefs.sh # using PREFIX
if [ "$(uname)" = "Linux" ]; then
    export WM_PROJECT_DIR=$PREFIX/src/volume_foam-extend_for_pato/foam-extend-4.1_for_openfoam-7
fi
source bashrc
cp prefs.sh-run prefs.sh # using CONDA_PREFIX
set -e
cd $PREFIX/src/volume_foam-extend_for_pato/foam-extend-4.1_for_openfoam-7
./Allwmake -j

# Archive volume_foam-extend_for_pato
if [ "$(uname)" = "Linux" ]; then
    cd $PREFIX/src/volume_foam-extend_for_pato
    rm -f foam-extend-4.1_for_openfoam-7.tar
    rm -f parmgridgen/ParMGridGen-0.0.2.tar.gz
    zip -r parmgridgen.zip parmgridgen
    rm -rf parmgridgen
    for dir in $PREFIX/src/volume_foam-extend_for_pato/foam-extend-4.1_for_openfoam-7/*/
    do
	dir=${dir%*/}
	dir="${dir##*/}"
	if [ $dir != "src" ]; then
	    cd $PREFIX/src/volume_foam-extend_for_pato/foam-extend-4.1_for_openfoam-7
	    zip -r $dir.zip $dir
	    rm -rf $dir
	    cd $PREFIX/src/volume_foam-extend_for_pato
	fi
    done
    for dir in $PREFIX/src/volume_foam-extend_for_pato/foam-extend-4.1_for_openfoam-7/src/*/
    do
        dir=${dir%*/}
        dir="${dir##*/}"
        cd $PREFIX/src/volume_foam-extend_for_pato/foam-extend-4.1_for_openfoam-7/src
        zip -r $dir.zip $dir
        rm -rf $dir
        cd $PREFIX/src/volume_foam-extend_for_pato/foam-extend-4.1_for_openfoam-7
    done
    cd $PREFIX/src/volume_foam-extend_for_pato
fi

if [ "$(uname)" = "Darwin" ]; then
    cd $PREFIX/src
    # detach volume_foam-extend_for_pato
    hdiutil detach volume_foam-extend_for_pato
fi

