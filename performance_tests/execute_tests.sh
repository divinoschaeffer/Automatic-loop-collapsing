
execute_and_save_exec_time() {
    local executable="$1"
    local exec_time_file="${executable}_exec_time.txt"
    $executable >> $exec_time_file
    
}

# clear former results
rm -f */*_exec_time.txt

# execute the tests 100 times
for i in {1..100}; do
    basic_schedule_static="omp_schedule_static";
    for executable in $basic_schedule_static/*; do
        # check if the file is executable
        if [ ! -x "$executable" ]; then
            continue
        fi
        execute_and_save_exec_time $executable
    done

    basic_schedule_dynamic="omp_schedule_dynamic";
    for executable in $basic_schedule_dynamic/*; do
        if [ ! -x "$executable" ]; then
            continue
        fi
        execute_and_save_exec_time $executable
    done

    trahrhe_collapsed="trahrhe_collapsed";
    for executable in $trahrhe_collapsed/*; do
        if [ ! -x "$executable" ]; then
            continue
        fi
        execute_and_save_exec_time $executable
    done
done
