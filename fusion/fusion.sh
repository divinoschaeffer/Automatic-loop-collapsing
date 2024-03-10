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
    d="$2"
    f="$3"
    contenu=$(awk -v d="$d" -v f="$f" '
        {
            if ($0 ~ d) {
                flag=1
                next
            }
            if ($0 ~ f) {
                flag=0
                print ""
                next
            }
            if (flag) {
                printf "%s%s", sep, $0
                sep="\n"
            }
        }
    ' "$file")
    echo "$contenu"
}

extract_content "$new_file" "//start//" "//end//" > temp_file

awk -v debut="$start_pattern_input" -v fin="$end_pattern_input" 'BEGIN { print "" }
    $0 ~ debut { 
        in_block = 1
        while ((getline < "temp_file") > 0) {
            print
        }
        close("temp_file")
        next
    }
    $0 ~ fin { in_block = 0 }
    !in_block { print }
    END { if (in_block) print "" }
' "$input_file" > "$output_file"

rm temp_file

echo "Le fichier de sortie '$output_file' a été généré avec succès."
