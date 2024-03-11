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
    char *scoped = (char *)malloc(100 * sizeof(char));
    char *collapse_parameters = (char *)malloc(100 * sizeof(char));

    getcwd(pwd, 100);
    strcpy(scoped, "scoped.c");
    strcpy(collapse_parameters, "parameters.txt");

    sprintf(bash_command, "%s/extractor.sh %s %s %s", pwd, inputFilename, scoped, collapse_parameters);
    system(bash_command);

    tcdFlowData->entryFile = scoped;
    tcdFlowData->outputFile = outputFilename;
    tcdFlowData->scop = NULL;

    FILE *parameters = fopen(collapse_parameters, "r");
    FILE *copy = fopen(collapse_parameters, "r");

    int scop_count;
    fscanf(copy, "%d", &scop_count);

    tcdFlowData->collapseParameters = (int *)malloc(scop_count * sizeof(int));

    for (int i = 0; i < scop_count; i++)
    {
        fscanf(parameters, "%d", &tcdFlowData->collapseParameters[i]);
    }

    fclose(parameters);
    free(bash_command);
}

void endTcdFlow(void)
{
    free(tcdFlowData);
}
