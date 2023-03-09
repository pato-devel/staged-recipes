#!/usr/bin/env bash
echo deactivate openfoam_for_pato
if [ "$(uname)" = "Darwin" ]; then
    LOCALMOUNTPOINT="$CONDA_PREFIX/src/volume_openfoam_for_pato"
    if [ -d $LOCALMOUNTPOINT ]; then
	if mount | grep "on $LOCALMOUNTPOINT " > /dev/null; then
	    if [ -f $CONDA_PREFIX/src/volume_openfoam_for_pato/OpenFOAM/OpenFOAM-10/etc/config.sh/unset ] && [ ! -z "${WM_PROJECT_DIR}" ]; then
		source $CONDA_PREFIX/src/volume_openfoam_for_pato/OpenFOAM/OpenFOAM-10/etc/config.sh/unset
		#DYLD_LIBRARY_PATH
		for old_path in $CONDA_PREFIX/src/volume_openfoam_for_pato/OpenFOAM/ThirdParty-10/platforms/linux64Gcc/gperftools-svn/lib \
				    $CONDA_PREFIX/src/volume_openfoam_for_pato/OpenFOAM/OpenFOAM-10/platforms/linux64GccDPInt32Opt/lib/openmpi-system \
				    $CONDA_PREFIX/src/volume_openfoam_for_pato/OpenFOAM/ThirdParty-10/platforms/linux64GccDPInt32/lib/openmpi-system \
				    $CONDA_PREFIX/lib \
				    $HOME/OpenFOAM/$USER-7/platforms/linux64GccDPInt32Opt/lib \
				    $CONDA_PREFIX/src/volume_openfoam_for_pato/OpenFOAM/site/7/platforms/linux64GccDPInt32Opt/lib \
				    $CONDA_PREFIX/src/volume_openfoam_for_pato/OpenFOAM/OpenFOAM-10/platforms/linux64GccDPInt32Opt/lib \
				    $CONDA_PREFIX/src/volume_openfoam_for_pato/OpenFOAM/ThirdParty-10/platforms/linux64GccDPInt32/lib \
				    $CONDA_PREFIX/src/volume_openfoam_for_pato/OpenFOAM/OpenFOAM-10/platforms/linux64GccDPInt32Opt/lib/dummy
		do
                    if [[ $DYLD_LIBRARY_PATH == *"$old_path:"* ]]; then
			DYLD_LIBRARY_PATH="${DYLD_LIBRARY_PATH/${old_path}:/}"
                    else
			if [[ $DYLD_LIBRARY_PATH == *"$old_path"* ]]; then
                            DYLD_LIBRARY_PATH="${DYLD_LIBRARY_PATH/${old_path}/}"
			fi
                    fi
		done
		export DYLD_LIBRARY_PATH
	    fi
	    cd $CONDA_PREFIX
	    hdiutil detach $LOCALMOUNTPOINT
	fi
    fi
fi

if [ "$(uname)" = "Linux" ]; then
    if [ -f $CONDA_PREFIX/src/volume_openfoam_for_pato/OpenFOAM/OpenFOAM-10/etc/config.sh/unset ] && [ ! -z "${WM_PROJECT_DIR}" ]; then
        source $CONDA_PREFIX/src/volume_openfoam_for_pato/OpenFOAM/OpenFOAM-10/etc/config.sh/unset
        #LD_LIBRARY_PATH
        for old_path in $CONDA_PREFIX/src/volume_openfoam_for_pato/OpenFOAM/ThirdParty-10/platforms/linux64Gcc/gperftools-svn/lib \
			    $CONDA_PREFIX/src/volume_openfoam_for_pato/OpenFOAM/OpenFOAM-10/platforms/linux64GccDPInt32Opt/lib/openmpi-system \
			    $CONDA_PREFIX/src/volume_openfoam_for_pato/OpenFOAM/ThirdParty-10/platforms/linux64GccDPInt32/lib/openmpi-system \
			    $CONDA_PREFIX/lib \
			    $HOME/OpenFOAM/$USER-7/platforms/linux64GccDPInt32Opt/lib \
			    $CONDA_PREFIX/src/volume_openfoam_for_pato/OpenFOAM/site/7/platforms/linux64GccDPInt32Opt/lib \
			    $CONDA_PREFIX/src/volume_openfoam_for_pato/OpenFOAM/OpenFOAM-10/platforms/linux64GccDPInt32Opt/lib \
			    $CONDA_PREFIX/src/volume_openfoam_for_pato/OpenFOAM/ThirdParty-10/platforms/linux64GccDPInt32/lib \
			    $CONDA_PREFIX/src/volume_openfoam_for_pato/OpenFOAM/OpenFOAM-10/platforms/linux64GccDPInt32Opt/lib/dummy
        do
            if [[ $LD_LIBRARY_PATH == *"$old_path:"* ]]; then
		LD_LIBRARY_PATH="${LD_LIBRARY_PATH/${old_path}:/}"
            else
                if [[ $LD_LIBRARY_PATH == *"$old_path"* ]]; then
                    LD_LIBRARY_PATH="${LD_LIBRARY_PATH/${old_path}/}"
                fi
            fi
        done
        export LD_LIBRARY_PATH
    fi
fi
