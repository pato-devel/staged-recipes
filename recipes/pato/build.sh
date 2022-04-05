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

# create volume_pato folder
if [ ! -d $PREFIX/src/volume_pato ]; then
    mkdir -p $PREFIX/src/volume_pato
fi
cd $PREFIX/src
    
if [ "$(uname)" = "Linux" ]; then
    # move src to volume_pato
    mv $SRC_DIR/src/Linux/* $PREFIX/src/volume_pato/
    mv $SRC_DIR/src/Both/* $PREFIX/src/volume_pato/
    rm -rf $SRC_DIR/src
    sed_cmd=sed
fi

if [ "$(uname)" = "Darwin" ]; then
    # create volume_pato
    hdiutil create -size 16g -type SPARSEBUNDLE -fs HFSX -volname pato_conda -fsargs -s pato_conda.sparsebundle
    # attach volume_pato
    hdiutil attach -mountpoint volume_pato pato_conda.sparsebundle
    # move src to volume_pato
    mv $SRC_DIR/src/MacOS/* $PREFIX/src/volume_pato/
    mv $SRC_DIR/src/Both/* $PREFIX/src/volume_pato/
    rm -rf $SRC_DIR/src
    mv $SRC_DIR/change_lib_path_macos.py $PREFIX/src/
    # compile gsed
    cd $PREFIX/src/volume_pato/sed
    tar xvf sed-4.8.tar.gz
    cd $PREFIX/src/volume_pato/sed/sed-4.8
    ./configure --prefix=$PREFIX
    make; make install
    mv $PREFIX/bin/sed $PREFIX/bin/gsed
    sed_cmd=$PREFIX/bin/gsed
fi

# get PATO-2.3.1
cd $PREFIX/src/volume_pato/PATO
tar xvf PATO-dev-2.3.1.tar.gz
# Patch PATO-dev-2.3.1
$sed_cmd -i '12 a\    if [ "$(uname)" = "Darwin" ]; then' $PREFIX/src/volume_pato/PATO/PATO-dev-2.3.1/Allwmake
$sed_cmd -i '13 a\        lib_name=$PATO_DIR/src/thirdParty/mutation++/install/lib/libmutation++.dylib' $PREFIX/src/volume_pato/PATO/PATO-dev-2.3.1/Allwmake
$sed_cmd -i '14 a\        install_name_tool -id $lib_name $lib_name\n    fi' $PREFIX/src/volume_pato/PATO/PATO-dev-2.3.1/Allwmake
$sed_cmd -i 's/endTime_factor \+[0-9]*/endTime_factor 15/g' $PREFIX/src/volume_pato/PATO/PATO-dev-2.3.1/src/applications/utilities/tests/testframework/runtests_options
$sed_cmd -i 's/\$(PATO_DIR)\/install\/lib\/libPATOx.so//g' $PREFIX/src/volume_pato/PATO/PATO-dev-2.3.1/src/applications/solvers/basics/heatTransfer/Make/options
$sed_cmd -i 's/-I\$(LIB_PATO)\/libPATOx\/lnInclude//g' $PREFIX/src/volume_pato/PATO/PATO-dev-2.3.1/src/applications/solvers/basics/heatTransfer/Make/options
$sed_cmd -i 's/==/=/g' $PREFIX/src/volume_pato/PATO/PATO-dev-2.3.1/bashrc
# source PATO
cd PATO-dev-2.3.1
export PATO_DIR=$PWD
source bashrc
# Compile PATO-dev-2.3.1
./Allwmake

# Change the libraries paths to $PREFIX
cd $PREFIX/src
export SRC_DIR=$PWD # for the python scripts
if [ "$(uname)" = "Darwin" ]; then
    python change_lib_path_macos.py
    rm -f change_lib_path_macos.py
fi

# Archive volume_pato
if [ "$(uname)" = "Linux" ]; then
    cd $PREFIX/src
    tar czvf volume_pato.tar volume_pato > /dev/null
    rm -rf volume_pato
fi

if [ "$(uname)" = "Darwin" ]; then
    # copy environmentComposition
    cp $PREFIX/src/volume_pato/PATO/PATO-dev-2.3.1/data/Environments/RawData/Earth/environmentComposition $PREFIX/src/environmentComposition
    # detach volume_pato
    hdiutil detach volume_pato
fi

