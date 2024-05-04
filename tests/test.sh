#!/bin/bash

build_script="./../build_test.sh"

# Chemin vers les dossiers "cases" et "build"
cases_path="cases"
build_path="build"

# Vérification de l'existence du script de construction
if [ -f "$build_script" ]; then
    chmod +x "$build_script"
    "$build_script"
else
    echo "Le fichier build_test.sh n'existe pas."
    exit 1
fi

# Parcourir chaque sous-dossier dans le dossier "cases"
for subfolder in "$cases_path"/*; do
    if [ -d "$subfolder" ]; then
        subfolder_name=$(basename "$subfolder")

        # Chemin vers les exécutables dans le dossier "build"
        executable1_path="$build_path/$subfolder_name/$subfolder_name"
        executable2_path="$build_path/$subfolder_name/${subfolder_name}_collapsed"

        # Vérifier si les exécutables existent
        if [ -x "$executable1_path" ] && [ -x "$executable2_path" ]; then
            # Exécuter les deux exécutables et obtenir leur sortie
            output1=$("$executable1_path")
            output2=$("$executable2_path")

            # Vérifier si les sorties sont identiques
            if [ "$output1" = "$output2" ]; then
                echo -e "\e[32mTest réussi\e[0m"
            else
                echo -e "\e[31mÉchec du test\e[0m"
            fi
        else
            echo "Les exécutables pour '$subfolder_name' n'existent pas dans le dossier 'build'."
        fi
    fi
done
