#!/bin/sh
cd clan
./get_submodules.sh
./autogen.sh
./configure
make