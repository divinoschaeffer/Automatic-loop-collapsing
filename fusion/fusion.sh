#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_file> <new_file> <output_file>"
    exit 1
fi

input_file="$1"
new_file="$2"
output_file="$3"

if [ ! -f "$input_file" ]; then
    echo "Erreur: Le fichier input '$input_file' n'existe pas."
    exit 1
fi

if [ ! -f "$new_file" ]; then
    echo "Erreur: Le fichier new '$new_file' n'existe pas."
    exit 1
fi

temp_dir=$(mktemp -d)

block_number=0

awk -v temp_dir="$temp_dir" '
    BEGIN { in_block=0 }
    /\/\/start\/\// {
        in_block=1
        block_number++
        next
    }
    /\/\/end\/\// {
        in_block=0
        next
    }
    in_block {
        block_file = temp_dir "/" block_number
        print $0 > block_file
    }
' "$new_file"

block_index=0

echo '#include "new.h"' > "$output_file"

awk -v d="#pragma scop" -v f="#pragma endscop" -v temp_dir="$temp_dir" '
    BEGIN {
        block_index = 1
        inside = 0
    }
    $0 ~ d {
        block_file = temp_dir "/" block_index
        inside = 1
        while (getline < block_file > 0) {
            print
        }
        block_index++
        next
    }
    $0 ~ f {
        inside = 0
        next
    }
    inside{
        next
    }
    {
        print
    }
' "${input_file}" >> "${output_file}"

echo "Le fichier de sortie '$output_file' a été généré avec succès."

rm -rf "$temp_dir"
