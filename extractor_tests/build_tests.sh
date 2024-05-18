#!/bin/bash

# Fonction pour exécuter la commande pour chaque test
run_command() {
    local test_name="$1"
    local input_file="${test_name}/${test_name}.c"
    local output_file="${test_name}/output.c"
    local count_file="${test_name}/count"

    # Exécution de la commande
    ./../extractor.sh "$input_file" "$output_file" "$count_file"
}

# Liste des tests
tests=("test1" "test2")

# Exécution pour chaque test
for test in "${tests[@]}"; do
    echo "Exécution de la commande pour le test $test"
    run_command "$test"
done
