#!/usr/bin/env bash
echo "activate pato-of13"

curr_dir=$PWD

# --- macOS: create and mount sparse bundle ---
if [ "$(uname)" = "Darwin" ]; then
    if [ ! -d "$CONDA_PREFIX/src/volume_pato" ]; then
        mkdir -p "$CONDA_PREFIX/src/volume_pato"
    fi
    if [ ! -d "$CONDA_PREFIX/src/volume_pato.sparsebundle" ]; then
        cd "$CONDA_PREFIX/src"
        hdiutil create -size 32g -type SPARSEBUNDLE -fs HFSX -volname volume_pato -fsargs -s volume_pato.sparsebundle
        cd "$curr_dir"
    fi
    for i in "$PREFIX" "$BUILD_PREFIX"
    do
        if mount | grep "on $i/src/volume_pato " > /dev/null; then
            cd "$i/src"
            hdiutil detach volume_pato
            cd "$curr_dir"
        fi
    done
    LOCALMOUNTPOINT="$CONDA_PREFIX/src/volume_pato"
    if ! mount | grep "on $LOCALMOUNTPOINT " > /dev/null; then
        hdiutil attach -mountpoint "$CONDA_PREFIX/src/volume_pato" "$CONDA_PREFIX/src/volume_pato.sparsebundle"
    fi
fi

# --- Linux: create volume_pato directory and compiler symlinks ---
if [ "$(uname)" = "Linux" ]; then
    if [ ! -d "$CONDA_PREFIX/src/volume_pato" ]; then
        mkdir -p "$CONDA_PREFIX/src/volume_pato"
    fi
    dir_gcc=$(dirname "$(which x86_64-conda-linux-gnu-gcc 2>/dev/null)" 2>/dev/null)
    if [ -n "$dir_gcc" ]; then
        cd "$dir_gcc"
        files=$(find . -name "x86_64-conda-linux-gnu-*" -type f)
        for x in $files
        do
            old_name="${x#"./"}"
            new_name="${x#"./x86_64-conda-linux-gnu-"}"
            if [ ! -f "$new_name" ]; then
                ln -s "$old_name" "$new_name"
            fi
        done
        cd "$curr_dir"
    fi
fi

# --- Clone and build PATO on first activation ---
if [ ! -d "$CONDA_PREFIX/src/volume_pato/PATO-dev" ]; then
    cd "$CONDA_PREFIX/src/volume_pato"
    echo "Cloning PATO-dev (openfoam13 branch)..."
    git clone -b openfoam13 git@gitlab.com:PATO/PATO-dev.git
    if [ ! -d "$CONDA_PREFIX/src/volume_pato/PATO-dev" ]; then
        echo 1>&2 "Error: Could not clone PATO-dev. Make sure you have SSH access to gitlab.com/PATO/PATO-dev."
        cd "$curr_dir"
        return 1 2>/dev/null || exit 1
    fi
    export PATO_DIR="$CONDA_PREFIX/src/volume_pato/PATO-dev"
    source "$PATO_DIR/bashrc"
    echo "Building PATO (this may take a few minutes)..."
    "$PATO_DIR/Allwmake"
    cd "$curr_dir"
fi

# --- Source PATO on subsequent activations ---
if [ -f "$CONDA_PREFIX/src/volume_pato/PATO-dev/bashrc" ]; then
    export PATO_DIR="$CONDA_PREFIX/src/volume_pato/PATO-dev"
    source "$PATO_DIR/bashrc"
fi

# --- macOS: codesign binaries if needed ---
if [ "$(uname)" = "Darwin" ]; then
    for dir_i in "$CONDA_PREFIX" "$PREFIX"
    do
        if [ -f "$dir_i/src/volume_pato/PATO-dev/install/bin/runtests" ]; then
            output=$("$dir_i/src/volume_pato/PATO-dev/install/bin/runtests" -h 2>&1)
            output_len=${#output}
            if [ ! "$output_len" -gt 0 ]; then
                echo "Codesigning OpenFOAM 13 and PATO binaries..."
                of_dir="$dir_i/src/volume_openfoam13/OpenFOAM/OpenFOAM-13/platforms/darwin64ClangDPInt32Opt"
                find "$of_dir/lib" -type f -name "*.dylib" -exec /usr/bin/codesign -f -d -s - {} \; > /dev/null 2>&1
                find "$of_dir/bin" -type f -exec /usr/bin/codesign -f -d -s - {} \; > /dev/null 2>&1
                mu_dir="$dir_i/src/volume_pato/PATO-dev/src/thirdParty/mutation++/install"
                find "$mu_dir/lib" -type f -name "*.dylib" -exec /usr/bin/codesign -f -d -s - {} \; > /dev/null 2>&1
                find "$mu_dir/bin" -type f -exec /usr/bin/codesign -f -d -s - {} \; > /dev/null 2>&1
                pa_dir="$dir_i/src/volume_pato/PATO-dev/install"
                find "$pa_dir/lib" -type f -name "*.dylib" -exec /usr/bin/codesign -f -d -s - {} \; > /dev/null 2>&1
                find "$pa_dir/bin" -type f -exec /usr/bin/codesign -f -d -s - {} \; > /dev/null 2>&1
            fi
        fi
    done
fi
