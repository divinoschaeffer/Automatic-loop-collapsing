#include "main.h"

extern TCD_FlowData *tcdFlowData;

void cliMiddleware(int argc, char **argv)
{
    if (2 < argc && argc < 3)
    {
        fprintf(stderr, "Usage: <collapse> <inputFilename> [-o <outputFilename>]\n");
        exit(EXIT_FAILURE);
    }
}

int main(int argc, char **argv)
{
    cliMiddleware(argc, argv);

    /* Initialize */
    char *inputFilename = argv[1];
    char *outputFilename = argc > 3 ? argv[3] : "out";

    initTcdFlow(inputFilename, outputFilename);

#pragma region Step1

    /* Step 1: Extract loops polytope representation */
    osl_scop_p scop;
    clan_options_p options;
    /* Default option setting. */
    options = clan_options_malloc();
    /* Extraction of the SCoP. */
    FILE *entryFile = fopen(tcdFlowData->entryFile, "r");
    scop = clan_scop_extract(entryFile, options);
    printf("Language: %s\n", scop->language);

    tcdFlowData->scop = scop;

#pragma endregion

#pragma region Step2

    /* Step 2: Extract loops domains */
    TCD_BoundaryList boundaryList = getBoundaries();
    printBoundaries(boundaryList);

#pragma endregion

#pragma region Step3

    /* Step 3: Generate header file */
    generateHeaderFile(boundaryList);

#pragma endregion

#pragma region Step4

    /* Step 4: Generate output code */
    generateCode(boundaryList);

#pragma region Step5

    /* Step 5: Merge generated code with untouched parts */
    mergeGeneratedCode();

#pragma endregion

    /* Save the planet. */
    removeTemporaryFiles();
    clan_options_free(options);
    osl_scop_free(scop);

    return 0;
}