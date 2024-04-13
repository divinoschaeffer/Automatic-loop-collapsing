CC = gcc

CFLAGS  = -losl -lclan -lisl -Iinclude -lcloog-isl -DTRAHRHE_INSTALL_DIR="$(TRAHRHE_INSTALL_DIR)"
OUTPUT_DIR = .

TARGET = trahrhe-collapse

# Source and header files
SRC_FILES = $(wildcard src/*.c)
HEADER_FILES = $(wildcard include/*.h) 

all: $(TARGET)

install:
	@echo "Installing $(TARGET) to /usr/local/bin"
	@cp $(OUTPUT_DIR)/$(TARGET) /usr/local/bin
	@echo "$(TARGET) has successfully been installed to /usr/local/bin"

uninstall:
	@echo "Uninstalling $(TARGET) from /usr/local/bin"
	@rm -f /usr/local/bin/$(TARGET)
	@echo "$(TARGET) has successfully been uninstalled from /usr/local/bin"

$(TARGET): $(SRC_FILES) $(HEADER_FILES)
	$(CC) $(SRC_FILES) -Iinclude $(CFLAGS) -o $(OUTPUT_DIR)/$(TARGET)

$(SRC_FILES): $(HEADER_FILES)

clean:
	$(RM) $(TARGET)
	$(RM) *.source.*