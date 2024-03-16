/**
 * @file fs.c
 * @brief File System
 */
#include "fs.h"

extern FILE *fs;
int tabular = 0;
char *outputname;

void fs_open(char *filename)
{
    tabular = 0;
    outputname = filename;
    fs = fopen(filename, "w+");
}

void fs_close()
{
    fclose(fs);
}

char *fs_rewind()
{
    FILE *fs_read = fopen(outputname, "r");
    if (fs_read == NULL)
    {
        return NULL;
    }
    // Move to the end of the file to determine its size
    fseek(fs_read, 0, SEEK_END);
    long size = ftell(fs_read);
    rewind(fs_read);
    // Allocate memory for the existing content
    char *buffer = malloc(size + 1);
    if (buffer == NULL)
    {
        // Handle error
        fclose(fs_read);
        return NULL;
    }
    fread(buffer, size, 1, fs_read);
    buffer[size] = '\0'; // Null-terminate the string
    fclose(fs_read);
    return buffer;
}

void fs_writef(char *str, ...)
{
    for (int i = 0; i < tabular; i++)
    {
        fprintf(fs, "\t");
    }
    va_list args;
    va_start(args, str);
    vfprintf(fs, str, args);
    fprintf(fs, "\n");
    va_end(args);
}

void fs_writefl(char *str, ...)
{
    va_list args;
    va_start(args, str);
    vfprintf(fs, str, args);
    va_end(args);
}

void fs_writeft(char *str, ...)
{
    for (int i = 0; i < tabular; i++)
    {
        fprintf(fs, "\t");
    }
    va_list args;
    va_start(args, str);
    vfprintf(fs, "\t", args);
    vfprintf(fs, str, args);
    fprintf(fs, "\n");
    va_end(args);
}

void fs_tabular()
{
    tabular++;
}

void fs_untabular()
{
    tabular--;
}
