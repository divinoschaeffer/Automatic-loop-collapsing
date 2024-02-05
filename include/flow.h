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

/**
 * At some point, we may want to transit our data structure through terminal scripts.
 * In this purpose, it is interesting to have the following functions.
 */

/**
 * @brief Writes a JSON representing the current structure of the collapsing flow.
 * @param filename the name of the flow's JSON file to generate.
 */
void exportTcdFlow(char *filename);

/**
 * @brief Reads a JSON representing the a collapsing flow and loads it in the
 * current states.
 * @note This operation overrides the current flow it there is one.
 * @param filename the name of the flow's JSON file.
 */
void importTcdFlow(char *filename);

#endif