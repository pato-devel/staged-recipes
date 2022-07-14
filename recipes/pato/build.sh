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

PATO_VERSION=PATO-v3.0
curr_dir=${PWD}

# Create soft links for the compilers
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
    cd $curr_dir
fi

# Create volume_pato folder
if [ ! -d ${PREFIX}/src/volume_pato ]; then
    mkdir -p ${PREFIX}/src/volume_pato
fi
# Create and attach volume_pato
if [ "$(uname)" = "Darwin" ]; then
    if [ ! -d $PREFIX/src/volume_pato.sparsebundle ]; then
        cd ${PREFIX}/src
        hdiutil create -size 32g -type SPARSEBUNDLE -fs HFSX -volname volume_pato -fsargs -s volume_pato.sparsebundle
	hdiutil attach -mountpoint volume_pato volume_pato.sparsebundle
    fi
fi

# Download PATO
cd ${PREFIX}/src/volume_pato
echo Download ${PATO_VERSION}
curl http://pato.ac/wp-content/uploads/${PATO_VERSION}.tar.gz --output ${PATO_VERSION}.tar.gz
tar xvf ${PATO_VERSION}.tar.gz

# Compile PATO
cd ${PATO_VERSION}
export PATO_DIR=${PWD}
source ${PATO_DIR}/bashrc
${PATO_DIR}/Allwmake
cd ${curr_dir}

# Archive volume_pato
if [ "$(uname)" = "Linux" ]; then
    cd ${PREFIX}/src
    tar czvf volume_pato.tar volume_pato > /dev/null
    rm -rf volume_pato
    cd ${curr_dir}
fi

# Detach volume_pato
if [ "$(uname)" = "Darwin" ]; then
    cd ${PREFIX}/src
    hdiutil detach volume_pato
    cd ${curr_dir}
fi

