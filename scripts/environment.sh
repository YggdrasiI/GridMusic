#!/bin/bash
# Setup environment variables for Keykit
#
# GridMusic assumes that it is installed under
# ${KEYROOT}/contrib/GridMusic

#export KEYROOT=/opt/kinect/keykit/
export KEYROOT=$(pwd)/../../..
export KEYROOT=$HOME/software/keykit

# Linux
export KEYKIT=key_alsa
export LOWKEYKIT=${KEYKIT}

# Windows
#export KEYKIT=key.exe
#export LOWKEYKIT=lowkey.exe

# Set KEYPATH to parse GridMusic files at startup.
# Alternatively, you can place '#include contrib/GridMusic/start.k'
# into the keyrc.k file, see below.
DEFAULT_KEYPATH=".:${KEYROOT}/lib:${KEYROOT}/liblocal" # could be differ on Windows?!
THIS_DIR=$(pwd)
export KEYPATH="${DEFAULT_KEYPATH}:${THIS_DIR%/scripts}:${KEYPATH}"

# Copy lib/keyrc.k into KEYROOT if file not exists
if [ ! -e ${KEYROOT}/keyrc.k ] ; then
	echo "keyrc.k not found in ${KEYROOT}! Copy default keyrc.k from lib subdirectory..."
	cp ${KEYROOT}/lib/keyrc.k ${KEYROOT}
fi

