#!/bin/bash
# Setup environment variables for Keykit
#
# GridMusic assumes that it is installed under
# ${KEYROOT}/contrib/GridMusic

# Use local environment file if available. Use this file as template, but do not add the local file to git repository.
LOCAL_FILE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )""/environment.local.sh"
if [ -e "${LOCAL_FILE}" -a "$AVOID_INF_LOOP" != "1" ] ; then
  AVOID_INF_LOOP=1
  source "${LOCAL_FILE}"
  AVOID_INF_LOOP=0
else

  export KEYROOT=$(pwd)/../../..

  # Linux
  export KEYKIT=key_alsa
  export LOWKEYKIT=${KEYKIT}

  # Windows
  #export KEYKIT=key.exe
  #export LOWKEYKIT=lowkey.exe


  # Set KEYPATH to parse Pyconsole files at startup.
  # Alternatively, you can place '#include contrib/Pyconsole/start.k'
  # into the keyrc.k file, see below.
  DEFAULT_KEYPATH=".:${KEYROOT}/lib:${KEYROOT}/liblocal" # could be differ on Windows?!
  THIS_DIR=$(pwd)
  export KEYPATH="${DEFAULT_KEYPATH}:${THIS_DIR%/scripts}:${KEYPATH}"

  # Copy lib/keyrc.k into KEYROOT if file not exists
  if [ ! -e ${KEYROOT}/keyrc.k ] ; then
    echo "keyrc.k not found in ${KEYROOT}! Copy default keyrc.k from lib subdirectory..."
    cp ${KEYROOT}/lib/keyrc.k ${KEYROOT}
  fi

fi
