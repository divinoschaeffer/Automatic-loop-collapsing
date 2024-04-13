#!/bin/bash

set -e
export TRAHRHE_INSTALL_DIR="$1"
echo "Using trahrhe at $TRAHRHE_INSTALL_DIR"
make TRAHRHE_INSTALL_DIR=$TRAHRHE_INSTALL_DIR -j4
make install
