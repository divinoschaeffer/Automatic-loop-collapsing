/**
 * @file flow.h
 * @author Nongma SORGHO
 * @brief Data structures that represent the progress of the trahrhe collapsing process.
 * @version 0.1
 * @date 2024-02-03
 */

#ifndef __FLOW_H
#define __FLOW_H

#include <stdio.h>
#include <stdlib.h>

#include <osl/osl.h>

/**
 * @brief Computational data to be transported during the collapsing
 */
typedef struct
{
    /**
     * @brief Entry file for the next step.
     */
    char *entryFile;

    /**
     * @brief Output file.
     */
    char *outputFile;

    /**
     * @brief Pointer on the current polyedral representation of the source code.
     */
    osl_scop_p scop;
} TCD_FlowData;

/**
 * @brief Inits the Tcd_Flow structure
 */
void initTcdFlow(char* inputFilename, char* outputFilename);

/**
 * @brief Destruct the Tcd_Flow and frees all memories spaces linked to it.
 */
void endTcdFlow();

#endif