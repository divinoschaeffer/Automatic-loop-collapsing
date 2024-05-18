#!/bin/bash

# Fonction pour vérifier les fichiers
check_files() {
    local test_name="$1"

    # Vérification de count
    if diff "${test_name}/count" "${test_name}/count_verif" &> /dev/null; then
        echo "$(tput setaf 2)Test réussi$(tput sgr0): Le fichier count pour $test_name est identique à count_verif."
    else
        echo "$(tput setaf 1)Test échoué$(tput sgr0): Le fichier count pour $test_name est différent de count_verif."
    fi

    # Vérification de output.c
    if diff "${test_name}/output.c" "${test_name}/verif.c" &> /dev/null; then
        echo "$(tput setaf 2)Test réussi$(tput sgr0): Le fichier output.c pour $test_name est identique à verif.c."
    else
        echo "$(tput setaf 1)Test échoué$(tput sgr0): Le fichier output.c pour $test_name est différent de verif.c."
    fi
}

# Liste des tests
tests=("test1" "test2")

# Vérification pour chaque test
for test in "${tests[@]}"; do
    echo "Vérification des fichiers pour le test $test"
    check_files "$test"
done
