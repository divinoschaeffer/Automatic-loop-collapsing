#!/bin/bash

input_file="$1"
exit_file="$2"
collapse_count_file="$3"

cp "$input_file" "$exit_file"

awk '/#pragma trahrhe collapse\([0-9]+\)/ { match($0, /[0-9]+/); print substr($0, RSTART, RLENGTH) }' "$input_file" > "$collapse_count_file"

awk '{ gsub(/#pragma trahrhe collapse\([0-9]+\)/, "#pragma scop"); print }' "$exit_file" > tmpfile && mv tmpfile "$exit_file"

awk '{ gsub(/#pragma endtrahrhe/, "#pragma endscop"); print }' "$exit_file" > tmpfile && mv tmpfile "$exit_file"
