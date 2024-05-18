#!/bin/bash

# Fonction pour exécuter la commande pour chaque test
run_command() {
    local test_name="$1"
    local input_file="${test_name}/input.c"
    local new_file="${test_name}/new.c"
    local include_statement="#include 'new.h'"
    local output_file="${test_name}/output.c"

    # Exécution de la commande
    ./../fusion.sh "$input_file" "$new_file" "$include_statement" "$output_file"
}

# Liste des tests
tests=("test1" "test2")

# Exécution pour chaque test
for test in "${tests[@]}"; do
    echo "Exécution de la commande pour le test $test"
    run_command "$test"
done
