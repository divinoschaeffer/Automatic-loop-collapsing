#!/bin/bash

build_script="./build_tests.sh"
parent_directory="tests/"

# Vérification de l'existence du script de construction
if [ -f "$build_script" ]; then
    chmod +x "$build_script"
    "$build_script"
else
    echo "Le fichier build_test.sh n'existe pas."
    exit 1
fi

# Vérification de l'existence et de l'exécution des exécutables dans chaque sous-dossier
for sub_directory in "$parent_directory"/*; do
    if [ -d "$sub_directory" ]; then
        echo "Traitement du sous-dossier $(basename "$sub_directory") :"
        
        executable1="$sub_directory/symm"
        executable2="$sub_directory/symm_collapsed"
        
        # Vérification de l'existence et de l'exécution de l'exécutable 1
        if [ -x "$executable1" ]; then
            executable1_absolute=$(realpath "$executable1")
            exit1=$("$executable1_absolute")
        else
            echo "L'exécutable $executable1 est manquant ou non exécutable."
            exit 1
        fi
        
        # Vérification de l'existence et de l'exécution de l'exécutable 2
        if [ -x "$executable2" ]; then
            executable2_absolute=$(realpath "$executable2")
            exit2=$("$executable2_absolute")
        else
            echo "L'exécutable $executable2 est manquant ou non exécutable."
            exit 1
        fi
        
        # Comparaison des sorties des exécutables
        if [ "$exit1" = "$exit2" ]; then
            echo -e "\e[32mTest réussi\e[0m"
        else
            echo -e "\e[31mÉchec du test\e[0m"
        fi
        
        echo
    fi
done
