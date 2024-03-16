/**
 * @file fs.h
 * @brief File System
 */
#ifndef _FS_H_
#define _FS_H_

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

/**
 * @brief Open file for writing
 *
 * @param filename
 */
void fs_open(char *filename);

/**
 * @brief Close file
 *
 */
void fs_close();

/**
 * @brief Write string to file with new line with format
 *
 * @param str
 */
void fs_writef(char *str, ...);

/**
 * @brief Write string to file with new line and tabular with format
 *
 * @param str
 */
void fs_writeft(char *str, ...);

/**
reads the file's content and positions the stream at the beginning of the file
returns the content file inside a buffer
*/
char *fs_rewind();

/**
 * @brief Write a tabular to file before each line till the opposite is called
 *
 */
void fs_tabular();

/**
 * @brief Write a tabular to file before each line till the opposite is called
 *
 */
void fs_untabular();

void fs_writefl(char *str, ...);
#endif
