#!/bin/bash
set -e  # exit when any command fails
set -x # show the commands

curr_dir=$PWD
echo -e "\n### TESTING PATO ###\n"
cd $PREFIX
# Change the codesign author if the runtests executable is zsh killed
export PATO_VERSION=3.1
if [ "$(uname)" = "Darwin" ]; then
    for dir_i in "$PREFIX"
    do
        if [ -f $dir_i/src/volume_pato/pato-$PATO_VERSION/install/bin/runtests ]; then
	    echo "run runtests: output=$($dir_i/src/volume_pato/pato-$PATO_VERSION/install/bin/runtests -h 2>&1)"
	    set +e
            output=$($dir_i/src/volume_pato/pato-$PATO_VERSION/install/bin/runtests -h 2>&1)
	    set -e
	    echo "runtests output = \"$output\""
            output_len=${#output}
            if [ ! $output_len -gt 0 ]; then
                echo "$dir_i: codesign executables and libraries in OpenFOAM, foam-extend, and PATO."
                of_dir=$dir_i/src/volume_openfoam_for_pato/OpenFOAM/OpenFOAM-7/platforms/darwin64ClangDPInt32Opt
                find $of_dir/lib -type f -name "*.dylib" -exec /usr/bin/codesign -f -d -s - {} \; > /dev/null 2>&1
                find $of_dir/bin -type f -exec /usr/bin/codesign -f -d -s - {} \; > /dev/null 2>&1
                fe_dir=$dir_i/src/volume_foam-extend_for_pato/foam-extend-4.1_for_openfoam-7/lib/darwinArm64GccDPInt32Opt
                find $fe_dir -type f -name "*.dylib" -exec /usr/bin/codesign -f -d -s - {} \; > /dev/null 2>&1
                mu_dir=$dir_i/src/volume_pato/pato-$PATO_VERSION/src/thirdParty/mutation++/install
                find $mu_dir/lib -type f -name "*.dylib" -exec /usr/bin/codesign -f -d -s - {} \; > /dev/null 2>&1
                find $mu_dir/bin -type f -exec /usr/bin/codesign -f -d -s - {} \; > /dev/null 2>&1
                pa_dir=$dir_i/src/volume_pato/pato-$PATO_VERSION/install
                find $pa_dir/lib -type f -name "*.dylib" -exec /usr/bin/codesign -f -d -s - {} \; > /dev/null 2>&1
                find $pa_dir/bin -type f -exec /usr/bin/codesign -f -d -s - {} \; > /dev/null 2>&1
            fi
        fi
    done
fi
# Source PATO run functions
. $PATO_DIR/src/applications/utilities/runFunctions/RunFunctions
# Initialize the script
alias wmRefresh="" # needed before to source openfoam bashrc
pato_init
# run tests
which runtests
runtests -h # just check if the executable runs, issues with restart test
# detach volume
if [ "$(uname)" = "Darwin" ]; then
    cd $PREFIX/src
    # detach volume_openfoam_for_pato
    hdiutil detach volume_openfoam_for_pato
    # detach volume_foam-extend_for_pato
    hdiutil detach volume_foam-extend_for_pato
    # detach volume_pato
    hdiutil detach volume_pato
fi
cd $curr_dir
