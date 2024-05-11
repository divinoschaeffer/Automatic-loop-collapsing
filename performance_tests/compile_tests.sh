PROJECT_ROOT_DIR=$(pwd)

#compile the file
compile() {
    local file="$1"
    local filebase=$(basename $file .c)
    local filedir=$(dirname $file)
    gcc -O3 $file -o "$filedir/$filebase" \
        -lm -fopenmp
}

basic_schedule_static="omp_schedule_static";
for file in $basic_schedule_static/*.c; do
    compile $file
done

basic_schedule_dynamic="omp_schedule_dynamic";
for file in $basic_schedule_dynamic/*.c; do
    compile $file
done

trahrhe_collapsed="trahrhe_collapsed";
for file in $trahrhe_collapsed/*.c; do
    compile $file
done
