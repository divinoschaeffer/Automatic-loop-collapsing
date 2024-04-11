#!/bin/bash

build_script="./build_test.sh"
parent_directory="build/cases/"

if [ -f "$build_script" ]; then

    chmod +x "build_test.sh"
    
    "$build_script"
else
    echo "Le fichier build_test.sh n'existe pas."
    exit 1
fi

cd "$tests_folder"

for sub_directory in "$parent_directory"/*; do
    if [ -d "$sub_directory" ]; then
        echo "Traitement du sous-dossier $(basename "$sub_directory") :"
        
        executable1="$sub_directory/symm"
        executable2="$sub_directory/symm_collapsed"
        
        executable1_absolute=$(realpath "$executable1")
        executable2_absolute=$(realpath "$executable2")
        
        exit1=$("$executable1_absolute")
        exit2=$("$executable2_absolute")
        
        if [ "$exit1" = "$exit2" ]; then
            echo "Les sorties des exécutables sont identiques."
        else
            echo "Les sorties des exécutables sont différentes."
        fi
        
        echo
    fi
done