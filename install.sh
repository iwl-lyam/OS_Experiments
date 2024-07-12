#!/bin/bash
#
# buildcomp script: this is the script that you use to build i386-elf-*
# Author: Dani Rodríguez <danirod@outlook.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Versions of the packages to build
BINUTILS_VERSION=2.25.1
GCC_VERSION=5.2.0

# Location of the packages to build
BINUTILS_PKG=http://ftpmirror.gnu.org/binutils/binutils-$BINUTILS_VERSION.tar.gz
GCC_PKG=http://ftpmirror.gnu.org/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz

# Required packages in host
HOST_PACKAGES="wget gcc g++ make bison flex info"

# Execute a command, probably quietly, probably saving to a file.
function execute {
    if [ -z $VERBOSE ]; then
        # We have been told to be quiet.
        if [ ! -z $LOGFILE ]; then
            # Still print to a file.
            $* 2>&1 | tee -a $LOGFILE >/dev/null 2>&1; return ${PIPESTATUS[0]};
        else
            # Don't even print to a file.
            $* >/dev/null 2>&1
        fi
    else
        # Don't be quiet, then
        if [ ! -z $LOGFILE ]; then
            # Tee the output to a file
            $* 2>&1 | tee -a $LOGFILE; return ${PIPESTATUS[0]};
        else
            # Just print to stdout
            $* || return 1
        fi
    fi
}

# Execute a command without considering save to a file.
function exec_nolog {
    if [ -z $VERBOSE ]; then
        $* >/dev/null 2>&1
    else
        $*
    fi
}

# Print a title to stdout and if logging an ASCII title to log
function title {
    if [ ! -z $LOGFILE ]; then
        echo >> $LOGFILE
        echo "****************************" >> $LOGFILE
        echo "$* " >> $LOGFILE
        echo "****************************" >> $LOGFILE
    fi
    # Print to stdout as well. This time we print even without verbose.
    echo "* $*"
}

# Print usage
function usage {
    echo "Usage: $1 -p <prefix> [-l <log_file>] [-v]"
    echo "  -p <prefix>: install the software in <prefix> (required>)"
    echo "  -l <log_file>: save output to <log_file> (optional)"
    echo "  -v: print output; if not present will be quiet (optional)"
    echo "Example: $1 -p /opt/local -l logfile.log -v"
}

# Check for arguments
while getopts ":p:vl:" opt; do
    case $opt in
        p)
            PREFIX=$OPTARG
            ;;
        v)
            VERBOSE=1
            ;;
        l)
            first_char=$(echo $OPTARG | head -c 1)
            if [ $first_char == "/" ]; then
                LOGFILE=$OPTARG
            else
                LOGFILE=$PWD/$OPTARG
            fi
            ;;
        \?):
            usage $0
            exit 1
            ;;
        :)
            usage $0
            exit 1
            ;;
    esac
done

# Check that a PREFIX has been provided
if [ -z $PREFIX ]; then
    usage $0
    exit 1
fi

# Check that PREFIX points to a directory
if [ ! -d $PREFIX ]; then
    echo "Error: $PREFIX is not a directory." >&2
    exit 1
fi

# Check that PREFIX is writable
if [ ! -w $PREFIX ]; then
    echo "Error: $PREFIX is not writable." >&2
    exit 1
fi

# Check that the host machine has all the required software
for package in $HOST_PACKAGES; do
    hash $package >/dev/null 2>&1 || MISSING="$MISSING $package"
done
if [ ! -z "$MISSING" ]; then
    echo "Error: missing the following packages:$MISSING"
    exit 1
fi

title "Downloading GNU Binutils..."
execute wget $BINUTILS_PKG || { echo "Aborting due to errors"; exit 1; }
execute tar -xf binutils-$BINUTILS_VERSION.tar.gz || { echo "Aborting due to errors"; exit 1; }

title "Downloading GNU GCC..."
execute wget $GCC_PKG || { echo "Aborting due to errors"; exit 1; }
execute tar -xf gcc-$GCC_VERSION.tar.gz || { echo "Aborting due to errors"; exit 1; }

title "Downloading aditional dependencies..."
exec_nolog pushd gcc-$GCC_VERSION
    execute contrib/download_prerequisites || { echo "Aborting due to errors"; exit 1; }
exec_nolog popd

exec_nolog mkdir binutils-build
exec_nolog pushd binutils-build
    title "Configuring GNU Binutils..."
    execute ../binutils-$BINUTILS_VERSION/configure --prefix=$PREFIX \
        --target=i386-elf --disable-multilib --disable-nls \
        --disable-werror || { echo "Aborting due to errors"; exit 1; }
    title "Building GNU Binutils..."
    execute make || { echo "Aborting due to errors"; exit 1; }
    title "Installing GNU Binutils..."
    execute make install || { echo "Aborting due to errors"; exit 1; }
exec_nolog popd

exec_nolog mkdir gcc-build
exec_nolog pushd gcc-build
    title "Configuring GNU GCC..."
    execute ../gcc-$GCC_VERSION/configure --prefix=$PREFIX \
        --target=i386-elf --disable-multilib --disable-nls \
        --disable-werror --without-headers \
        --enable-languages=c,c++ || { echo "Aborting due to errors"; exit 1; }
    title "Building GNU GCC..."
    execute make all-gcc || { echo "Aborting due to errors"; exit 1; }
    title "Installing GNU GCC..."
    execute make install-gcc || { echo "Aborting due to errors"; exit 1; }
    title "Building GNU libgcc..."
    execute make all-target-libgcc || { echo "Aborting due to errors"; exit 1; }
    title "Installing GNU libgcc..."
    execute make install-target-libgcc || { echo "Aborting due to errors"; exit 1; }
exec_nolog popd