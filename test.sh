#!/bin/bash

build_script="./build_test.sh"

if [ -f "$build_script" ]; then

    chmod +x "$build_script"
    
    "$build_script"
else
    echo "Le fichier build_test.sh n'existe pas."
    exit 1
fi