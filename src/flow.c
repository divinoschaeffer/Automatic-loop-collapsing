/**
 * @file flow.c
 * @author Nongma SORGHO
 * @brief Flow module implementation
 * @version 0.1
 * @date 2024-02-03
 */

#include "flow.h"

extern TCD_Flow *tcdFlow;

void initTdcFlow(void)
{
    tcdFlow->stepIndex = TCD_REWRITE_TRAHRHE_COLLAPSE;
    tcdFlow->flowData = (TCD_FlowData *)malloc(sizeof(TCD_FlowData));
    tcdFlow->flowData->entryFile.vanilla = NULL;
    tcdFlow->flowData->outputFile = NULL;
    tcdFlow->flowData->scop = NULL;
}

void endTdcFlow(void)
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

void exportTcdFlow(char *fileName) {
}

void importTcdFlow(char *fileName) {
}