#!/bin/bash
begin_string="#pragma trahrhe collapse("
end_string="#pragma endtrahrhe"
exit_file="scoped_loop.c"

# get number of collapse loops
nb_collapse=$(grep -oP '#pragma trahrhe collapse\(\K[0-9]+' "$1")

sed -i "s/${begin_string}[0-9]\+/$(echo ${begin_string}${nb_collapse})/g" "$1"

# get for loops
extracted_loop=$(sed -n "/${begin_string}/,/${end_string}/{ /${begin_string}/! { /${end_string}/! p } }" "$1")

# add scop and endscop
scoped_loop=$(echo -e "#pragma scop\n${extracted_loop}\n#pragma endscop")

echo "$scoped_loop" > "$exit_file"
#echo "$nb_collapse"

