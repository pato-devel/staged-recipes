#!/usr/bin/env bash
echo deactivate foam-extend
if [ "$(uname)" = "Darwin" ]; then
    LOCALMOUNTPOINT="$CONDA_PREFIX/src/volume"
    if [ -d $LOCALMOUNTPOINT ]; then
	if mount | grep "on $LOCALMOUNTPOINT" > /dev/null; then
	    if [ -f $CONDA_PREFIX/src/volume/foam-extend-4.1_for_openfoam_7/etc/bashrc ] && [ ! -z "${WM_PROJECT_DIR}" ]; then
                unset WM_ARCH
                unset WM_ARCH_OPTION
                unset WM_CC
                unset WM_CFLAGS
                unset WM_COMPILER
                unset WM_COMPILER_TYPE
                unset WM_COMPILER_LIB_ARCH
                unset WM_COMPILE_OPTION
                unset WM_CXX
                unset WM_CXXFLAGS
                unset WM_DIR
                unset WM_HOSTS
                unset WM_LABEL_OPTION
                unset WM_LABEL_SIZE
                unset WM_LDFLAGS
                unset WM_LINK_LANGUAGE
                unset WM_MPLIB
                unset WM_NCOMPPROCS
                unset WM_OPTIONS
                unset WM_OSTYPE
                unset WM_PRECISION_OPTION
                unset WM_PROJECT
                unset WM_PROJECT_DIR
                unset WM_PROJECT_INST_DIR
                unset WM_PROJECT_SITE
                unset WM_PROJECT_USER_DIR
                unset WM_PROJECT_VERSION
                unset WM_SCHEDULER
                unset WM_THIRD_PARTY_DIR
                unset FOAM_APPBIN
                unset FOAM_APP
                unset FOAM_CODE_TEMPLATES
                unset FOAM_ETC
                unset FOAM_EXT_LIBBIN
                unset FOAM_INST_DIR
                unset FOAM_JOB_DIR
                unset FOAM_LIBBIN
                unset FOAM_MPI
                unset FOAM_RUN
                unset FOAM_SETTINGS
                unset FOAM_SIGFPE
                unset FOAM_SIGNAN
                unset FOAM_SITE_APPBIN
                unset FOAM_SITE_LIBBIN
                unset FOAM_SOLVERS
                unset FOAM_SRC
                unset FOAM_TUTORIALS
                unset FOAM_USER_APPBIN
                unset FOAM_USER_LIBBIN
                unset FOAM_UTILITIES
	    fi
	    hdiutil detach $LOCALMOUNTPOINT
	    rm -rf $CONDA_PREFIX/src/volume
	fi
    fi
fi

if [ "$(uname)" = "Linux" ]; then
    if [ -f $CONDA_PREFIX/src/volume/foam-extend-4.1_for_openfoam_7/etc/bashrc ] && [ ! -z "${WM_PROJECT_DIR}" ]; then
        unset WM_ARCH
        unset WM_ARCH_OPTION
        unset WM_CC
        unset WM_CFLAGS
        unset WM_COMPILER
        unset WM_COMPILER_TYPE
        unset WM_COMPILER_LIB_ARCH
        unset WM_COMPILE_OPTION
        unset WM_CXX
        unset WM_CXXFLAGS
        unset WM_DIR
        unset WM_HOSTS
        unset WM_LABEL_OPTION
        unset WM_LABEL_SIZE
        unset WM_LDFLAGS
        unset WM_LINK_LANGUAGE
        unset WM_MPLIB
        unset WM_NCOMPPROCS
        unset WM_OPTIONS
        unset WM_OSTYPE
        unset WM_PRECISION_OPTION
        unset WM_PROJECT
        unset WM_PROJECT_DIR
        unset WM_PROJECT_INST_DIR
        unset WM_PROJECT_SITE
        unset WM_PROJECT_USER_DIR
        unset WM_PROJECT_VERSION
        unset WM_SCHEDULER
        unset WM_THIRD_PARTY_DIR
        unset FOAM_APPBIN
        unset FOAM_APP
        unset FOAM_CODE_TEMPLATES
        unset FOAM_ETC
        unset FOAM_EXT_LIBBIN
        unset FOAM_INST_DIR
        unset FOAM_JOB_DIR
        unset FOAM_LIBBIN
        unset FOAM_MPI
        unset FOAM_RUN
        unset FOAM_SETTINGS
        unset FOAM_SIGFPE
        unset FOAM_SIGNAN
        unset FOAM_SITE_APPBIN
        unset FOAM_SITE_LIBBIN
        unset FOAM_SOLVERS
        unset FOAM_SRC
        unset FOAM_TUTORIALS
        unset FOAM_USER_APPBIN
        unset FOAM_USER_LIBBIN
        unset FOAM_UTILITIES
    fi
fi
