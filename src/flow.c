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

void initTcdFlow(char *inputFilename, char *outputFilename)
{
    tcdFlowData = (TCD_FlowData *)malloc(sizeof(TCD_FlowData));

    char *bash_command = (char *)malloc(100 * sizeof(char));
    char *pwd = (char *)malloc(100 * sizeof(char));

    getcwd(pwd, 100);

    sprintf(bash_command, "%s/extractor.sh %s %s %s", pwd, inputFilename, SCOPED_FILENAME, COLLAPSE_PARAMETERS_FILENAME);
    system(bash_command);

    tcdFlowData->entryFile = SCOPED_FILENAME;
    tcdFlowData->outputFile = outputFilename;
    tcdFlowData->scop = NULL;

    FILE *parameters = fopen(COLLAPSE_PARAMETERS_FILENAME, "r");

    int scop_count;
    fscanf(parameters, "%d", &scop_count);

    tcdFlowData->collapseParameters = (int *)malloc(scop_count * sizeof(int));

    for (int i = 0; i < scop_count; i++)
    {
        fscanf(parameters, "%d", &tcdFlowData->collapseParameters[i]);
        printf("Parameter %d: %d\n", i, tcdFlowData->collapseParameters[i]);
    }

    fclose(parameters);
    free(bash_command);
}

void endTcdFlow(void)
{
    free(tcdFlowData);
}