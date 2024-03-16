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

char *tabStringReturn(char *string, long fsize)
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

    return tabbedString;
}

int digit_check(char key[])
{
    for (int i = 0; i < strlen(key); i++)
    {
        if (!(key[i] >= '0' && key[i] <= '9'))
        {
            return 0;
        }
    }
    return 1;
}