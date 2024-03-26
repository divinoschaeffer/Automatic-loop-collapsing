/**
 * @file format_helper.h
 * @author Nongma SORGHO
 * @version 0.1
 * @date 2024-02-13
 */

#ifndef __FORMAT_HELPER_H
#define __FORMAT_HELPER_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/**
 * @brief Adds a tabulation to the beginning of each line of a string
 * and writes it to a file
 * @param file
 * @param string
 * @param fsize
 */
void tabString(FILE *file, char *string, long fsize);

/**
 * @brief Adds a tabulation to the beginning of each line of a string
 * and returns the new string
 * @param index
 * @param string
 * @return char*
 */
char *tabStringReturn(char *string, long fsize);

/**
 * @brief Says if a string is a digit
 * @param key
 * @return int
 */
int digit_check(char key[]);

/**
 * @brief Returns the nth token of a string
 * @param index
 * @param string
 * @return char*
 */
char *take(int index, char *string);

#endif