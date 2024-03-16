##########################################################
# Author: Nongma SORGHO
# File: Makefile
# This Makefile is used to build the tests for the project.
##########################################################

# Compiler
CC := gcc

# Compiler flags
CFLAGS := -lm -fopenmp -DPOLYBENCH_TIME -I utilities

# Directories
SRC_DIR := cases
BIN_DIR := ../build/tests

# Source files
SRC := $(wildcard $(SRC_DIR)/*.c)

# Target binaries
BIN := $(patsubst $(SRC_DIR)/%.c,$(BIN_DIR)/%,$(SRC))

.PHONY: all clean

all: $(BIN)

$(BIN_DIR)/%: $(SRC_DIR)/%.c | $(BIN_DIR)
	@echo "Building test: $*"
	$(CC) $< -o $@ $(CFLAGS)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

clean:
	rm -rf $(BIN_DIR)

