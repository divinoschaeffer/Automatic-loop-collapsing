#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_file> <output_file> <collapse_count_file>"
    exit 1
fi

input_file="$1"
exit_file="$2"
collapse_count_file="$3"

if [ ! -f "$input_file" ]; then
    echo "Erreur: Le fichier input '$input_file' n'existe pas."
    exit 1
fi

cp "$input_file" "$exit_file"

grep -c "#pragma endtrahrhe" "$input_file" > "$collapse_count_file"

awk '/#pragma trahrhe collapse\([0-9]+\)/ { match($0, /[0-9]+/); print substr($0, RSTART, RLENGTH) }' "$input_file" >> "$collapse_count_file"

awk '{ gsub(/#pragma trahrhe collapse\([0-9]+\)/, "#pragma scop"); print }' "$exit_file" > tmpfile && mv tmpfile "$exit_file"

awk '{ gsub(/#pragma endtrahrhe/, "#pragma endscop"); print }' "$exit_file" > tmpfile && mv tmpfile "$exit_file"
