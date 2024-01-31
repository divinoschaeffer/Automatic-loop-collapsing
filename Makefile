CC = gcc
ROOTDIR = $(shell pwd)

# CFLAGS  = -g -Wall -I$(ROOTDIR)/clan/include -L$(ROOTDIR)/clan -I$(ROOTDIR)/clan/osl/include -L$(ROOTDIR)/clan/osl
CFLAGS  = -Wall -lclan -losl
OUTPUT_DIR = .dist
TARGET = collapse

all: $(TARGET)

$(TARGET): main.c main.h
	$(CC) main.c main.h $(CFLAGS) -o $(OUTPUT_DIR)/$(TARGET) 

clean:
	$(RM) $(TARGET)