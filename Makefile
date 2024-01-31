CC = gcc

CFLAGS  = -g -Wall -I/mnt/c/Users/23544/Documents/Uni/m2/TER/Automatic-loop-collapsing/clan/include -L/mnt/c/Users/23544/Documents/Uni/m2/TER/Automatic-loop-collapsing/clan -I/mnt/c/Users/23544/Documents/Uni/m2/TER/Automatic-loop-collapsing/clan/include
OUTPUT_DIR = .dist
TARGET = collapse

all: $(TARGET)

$(TARGET): main.c main.h
	$(CC) $(CFLAGS) -o $(OUTPUT_DIR)/$(TARGET) main.c main.h

clean:
	$(RM) $(TARGET)