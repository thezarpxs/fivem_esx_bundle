#!/bin/bash

# save the script directory
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

# run server
exec /opt/cfx-server/ld-musl-x86_64.so.1 \
    --library-path "/usr/lib/v8/:/lib/:/usr/lib/" -- \
    /opt/cfx-server/FXServer +set citizen_dir /opt/cfx-server/citizen/ $*
