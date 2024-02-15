/**
 * @file format_helper.c
 * @brief This file contains the functions that help to format the output code.
 * @version 0.1
 * @date 2024-02-13
 */

#include "format_helper.h"

void tabString(FILE *file, char *string, long fsize)
{
    char *tabbedString = (char *)malloc((fsize + 1) * sizeof(char));
    tabbedString[0] = '\0';
    char *line = strtok(string, "\n");
    while (line != NULL)
    {
        strcat(tabbedString, "\t");
        strcat(tabbedString, line);
        strcat(tabbedString, "\n");
        line = strtok(NULL, "\n");
    }

    fprintf(file, "%s", tabbedString);
}