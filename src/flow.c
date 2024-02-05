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
TCD_Flow *tcdFlow;

void initTcdFlow(char* inputFilename, char* outputFilename)
{
    tcdFlow = (TCD_Flow *)malloc(sizeof(TCD_Flow));
    tcdFlow->stepIndex = TCD_REWRITE_TRAHRHE_COLLAPSE;
    tcdFlow->flowData = (TCD_FlowData *)malloc(sizeof(TCD_FlowData));
    tcdFlow->flowData->entryFile.vanilla = inputFilename;
    tcdFlow->flowData->outputFile = outputFilename;
    tcdFlow->flowData->scop = NULL;
}

void endTcdFlow(void)
{
    free(tcdFlow->flowData);
    free(tcdFlow);
}

int tcdGoToNextStep(void)
{
    if (tcdFlow->stepIndex < TCD_END)
    {
        tcdFlow->stepIndex++;
        return 0;
    }
    return -1;
}

void tcdPrintStep(void) {
    printf("---------------\n");
    printf("TCD:: Step:: %d\n", tcdFlow->stepIndex);
    printf("---------------\n");
}

void exportTcdFlow(char *filename) {
}

void importTcdFlow(char *filename) {
}