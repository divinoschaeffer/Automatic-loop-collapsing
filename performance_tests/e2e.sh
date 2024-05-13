export OMP_PROC_BIND=true
export OMP_NUM_THREADS=12
export OMP_PLACES=cores
bash compile_tests.sh
bash execute_tests.sh
python3 make_report.py