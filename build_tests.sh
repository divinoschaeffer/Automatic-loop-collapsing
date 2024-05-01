#!/bin/bash

##########################################################
# Author: Nongma SORGHO
# File: build_tests.sh
# This script is used to build the tests for the project.
##########################################################

set -e

# Set project root directory
PROJECT_ROOT_DIR=$(pwd)

# Set directories for tests and test binaries
TESTS_DIR="$PROJECT_ROOT_DIR/tests/cases"
TESTS_BIN_DIR="$PROJECT_ROOT_DIR/tests/build"
BIN_DIR="$PROJECT_ROOT_DIR/build"

# Create test binary directory if it doesn't exist
mkdir -p "$TESTS_BIN_DIR"

# Function to compile a test
compile_test() {
    local test_folder="$1"
    local test_name=$(basename "$test_folder")
    local entry_point="$test_folder/${test_name}_trahrhe.c"
    local collapsed="$test_folder/${test_name}_collapsed"

    gcc "$test_folder/$test_name.c" \
        -o "$TESTS_BIN_DIR/$test_name" -lm -fopenmp -DPOLYBENCH_DUMP_ARRAYS -DMINI_DATASET \
        -I "$PROJECT_ROOT_DIR/tests/utilities" "$PROJECT_ROOT_DIR/tests/utilities/polybench.c"

    local binary_file="./trahrhe-collapse"
    chmod +x ./trahrhe-collapse

    # get shorter path name
    entry_point=$(realpath --relative-to="$PROJECT_ROOT_DIR" "$entry_point")
    # collapsed=$(realpath --relative-to="$PROJECT_ROOT_DIR/fusion" "$collapsed")

    # skip if entry point does not exist
    if [ ! -f "$entry_point" ]; then
        echo "Entry point not found: $entry_point"
        return
    fi

    # Check if the binary file exists
    if [ -x "$binary_file" ]; then
        echo "Collapsing loops for test: $test_name"
        echo "Entry point: $entry_point"
        echo "Collapsed: $collapsed"
        (exec "$binary_file" "$entry_point" -o "$collapsed")
    else
        echo "Binary file not found or not executable."
    fi

    # Check if the collapsed file exists
    if [ -f "${collapsed}.c" ]; then
        echo "Building collapsed test: $test_name"
        gcc "${collapsed}.c" -o "$TESTS_BIN_DIR/${test_name}_collapsed" -lm -fopenmp -DPOLYBENCH_DUMP_ARRAYS -DMINI_DATASET  \
            -I . -I "$PROJECT_ROOT_DIR/tests/utilities" "$PROJECT_ROOT_DIR/tests/utilities/polybench.c"
    else
        echo "Collapsed file not found: $collapsed"
    fi
}

# Build tests
echo "Building tests..."

for test_folder in "$TESTS_DIR"/*; do
    if [ -d "$test_folder" ]; then
        echo "Building test: $(basename "$test_folder")"
        compile_test "$test_folder"
    fi
done

echo "All tests built successfully."