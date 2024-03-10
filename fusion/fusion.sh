#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_file> <new_file> <output_file>"
    exit 1
fi

input_file="$1"
new_file="$2"
output_file="$3"
start_pattern_input="#pragma scop"
end_pattern_input="#pragma endscop"

start_pattern_new="//start//"
end_pattern_end="//end//"


if [ ! -f "$input_file" ]; then
    echo "Erreur: Le fichier input '$input_file' n'existe pas."
    exit 1
fi

if [ ! -f "$new_file" ]; then
    echo "Erreur: Le fichier new '$new_file' n'existe pas."
    exit 1
fi

extract_content() {
    file="$1"
    debut="$2"
    fin="$3"
    awk -v d="$debut" -v f="$fin" '$0 ~ d {flag=1; next} $0 ~ f {flag=0} flag' "$file"
}

contenu_new=$(extract_content "$new_file" "$start_pattern_new" "$end_pattern_new")

awk -v debut="$start_pattern_input" -v fin="$end_pattern_input" -v contenu="$contenu_new" '
    {
        if ($0 ~ debut) {
            print $0
            print contenu
            in_block = 1
            next
        }
        if ($0 ~ fin) {
            in_block = 0
            next
        }
        if (!in_block) print
    }
' "$input_file" > "$output_file"

echo "Le fichier de sortie '$output_file' a été généré avec succès."
