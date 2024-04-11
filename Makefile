CC = gcc
ROOTDIR = $(shell pwd)
TRAHRHE_INSTALL_DIR_VALUE = $(TRAHRHE_INSTALL_DIR)

# CFLAGS  = -g -Wall -I$(ROOTDIR)/clan/include -L$(ROOTDIR)/clan -I$(ROOTDIR)/clan/osl/include -L$(ROOTDIR)/clan/osl
CFLAGS  = -losl -lclan -lisl -Iinclude -Lcloog -Icloog/include -lcloog-isl -g -DTRAHRHE_INSTALL_DIR=TRAHRHE_INSTALL_DIR_VALUE
OUTPUT_DIR = .

TARGET = trahrhe-collapse

# Source and header files
SRC_FILES = $(wildcard src/*.c)
HEADER_FILES = $(wildcard include/*.h) 

all: $(TARGET)

install:
	@echo "Installing $(TARGET) to /usr/local/bin"
	@cp $(OUTPUT_DIR)/$(TARGET) /usr/local/bin

uninstall:
	@echo "Uninstalling $(TARGET) from /usr/local/bin"
	@rm -f /usr/local/bin/$(TARGET)

$(TARGET): $(SRC_FILES) $(HEADER_FILES)
	$(CC) $(SRC_FILES) $(HEADER_FILES) $(CFLAGS) -o $(OUTPUT_DIR)/$(TARGET) 

clean:
	$(RM) $(TARGET)
	$(RM) *.source.*