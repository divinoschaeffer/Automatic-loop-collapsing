CC = gcc
ROOTDIR = $(shell pwd)

# CFLAGS  = -g -Wall -I$(ROOTDIR)/clan/include -L$(ROOTDIR)/clan -I$(ROOTDIR)/clan/osl/include -L$(ROOTDIR)/clan/osl
CFLAGS  = -losl -lclan -lisl -Iinclude -Lcloog -Icloog/include -lcloog-isl -g
OUTPUT_DIR = .dist

TARGET = collapse

# Source and header files
SRC_FILES = $(wildcard src/*.c)
HEADER_FILES = $(wildcard include/*.h) 

all: $(TARGET)

$(TARGET): main.c main.h $(SRC_FILES) $(HEADER_FILES)
	$(CC) main.c main.h $(SRC_FILES) $(HEADER_FILES) $(CFLAGS) -o $(OUTPUT_DIR)/$(TARGET) 

clean:
	$(RM) $(TARGET)