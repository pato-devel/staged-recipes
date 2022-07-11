#!/bin/bash
set -e  # exit when any command fails
set -x # show the commands


if [ "$(uname)" = "Darwin" ]; then
    cd $PREFIX/src
    # detach volume_openfoam_for_pato
    hdiutil detach volume_openfoam_for_pato
    # detach volume_foam-extend_for_pato 
    hdiutil detach volume_foam-extend_for_pato
    # detach volume_pato
    hdiutil detach volume_pato
else
