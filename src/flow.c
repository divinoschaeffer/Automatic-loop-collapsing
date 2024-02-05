/**
 * @file flow.c
 * @author Nongma SORGHO
 * @brief Flow module implementation
 * @version 0.1
 * @date 2024-02-03
 */

#include "flow.h"

/**
 * @brief TCD_Flow is global - all C sources that use it must declare it as extern.
 */
TCD_FlowData *tcdFlowData;

void initTcdFlow(char* inputFilename, char* outputFilename)
{
    tcdFlowData = (TCD_FlowData *)malloc(sizeof(TCD_FlowData));
    tcdFlowData->entryFile = inputFilename;
    tcdFlowData->outputFile = outputFilename;
    tcdFlowData->scop = NULL;
}

void endTcdFlow(void)
{
    free(tcdFlowData);
}

void exportTcdFlow(char *filename) {
}

void importTcdFlow(char *filename) {
}