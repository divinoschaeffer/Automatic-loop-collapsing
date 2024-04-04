#ifndef __MAIN_H
#define __MAIN_H

#include <stdio.h>
#include <osl/osl.h>
#include <clan/clan.h>

#include "flow.h"
#include "data.h"
#include "codegen.h"

/**
 * @brief Exposed main function to collapse loops using Trhahre
 * @details This function reads the input file, parses it, and collapses the loops
 * Returns 0 if the operation is successful, 1 otherwise
 * @param inputFilename
 * @param outputFilename
 * @return int
 */
int collapse(char *inputFilename, char *outputFilename);

#endif