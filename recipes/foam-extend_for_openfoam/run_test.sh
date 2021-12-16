#!/bin/bash
set -e  # exit when any command fails
set -x # show the commands

echo -e "\n### TESTING FOAM-EXTEND_FOR_OPENFOAM ###\n"

if [ "$(uname)" = "Darwin" ]; then
    cd $PREFIX/src
    # detach volume
    hdiutil detach volume
fi
