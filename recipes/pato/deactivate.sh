#!/usr/bin/env bash
echo deactivate PATO
if [ "$(uname)" = "Darwin" ]; then
    LOCALMOUNTPOINT="$CONDA_PREFIX/src/volume_pato"
    if [ -d $LOCALMOUNTPOINT ]; then
	if mount | grep "on $LOCALMOUNTPOINT " > /dev/null; then
	    if [ -f $CONDA_PREFIX/src/volume_pato/PATO/PATO-dev_2.3.1/bashrc ] && [ ! -z "${PATO_DIR}" ]; then
		unset PATO_DIR
		unset LIB_PATO
		unset PATO_UNIT_TESTING
		unset PATO_TUTORIALS
		unset MPP_DIRECTORY
		unset MPP_DATA_DIRECTORY
		unalias pato 2>/dev/null
		unalias solo 2>/dev/null
		unalias utio 2>/dev/null
		unalias libo 2>/dev/null
		unalias tuto 2>/dev/null
		unalias 1D 2>/dev/null
		unalias 1 2>/dev/null
		unalias 2D 2>/dev/null
		unalias 3D 2>/dev/null
		unalias muto 2>/dev/null
            fi
	    cd $CONDA_PREFIX
	    hdiutil detach $LOCALMOUNTPOINT
	fi
    fi
fi

if [ "$(uname)" = "Linux" ]; then
    if [ -f $CONDA_PREFIX/src/volume_pato/PATO/PATO-dev_2.3.1/bashrc ] && [ ! -z "${PATO_DIR}" ]; then
	unset PATO_DIR
	unset LIB_PATO
	unset PATO_UNIT_TESTING
	unset PATO_TUTORIALS
	unset MPP_DIRECTORY
	unset MPP_DATA_DIRECTORY
	unalias pato 2>/dev/null
	unalias solo 2>/dev/null
	unalias utio 2>/dev/null
	unalias libo 2>/dev/null
	unalias tuto 2>/dev/null
	unalias 1D 2>/dev/null
	unalias 1 2>/dev/null
	unalias 2D 2>/dev/null
	unalias 3D 2>/dev/null
	unalias muto 2>/dev/null
	# LD_LIBRARY_PATH
	for old_path in $CONDA_PREFIX/src/volume_pato/PATO/PATO-dev-2.3.1/src/thirdParty/mutation++/install/lib $CONDA_PREFIX/src/volume_pato/PATO/PATO-dev-2.3.1/install/lib
	do
	    LD_LIBRARY_PATH="${LD_LIBRARY_PATH/${old_path}:/}" # to be improved if last without :
	done
	export LD_LIBRARY_PATH
    fi
fi
