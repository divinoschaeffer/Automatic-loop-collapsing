/**
 * @file main.c
 */

#include "main.h"

extern TCD_FlowData *tcdFlowData;

/**
 * @brief Exposed main function to collapse loops using Trhahre
 * @details This function reads the input file, parses it, and collapses the loops
 * Returns 0 if the operation is successful, 1 otherwise
 * @param inputFilename
 * @param outputFilename
 * @return int
 */
int collapse(char *inputFilename, char *outputFilename)
{
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

    exit(EXIT_SUCCESS);
}

/**
 * @brief Middleware for the command line interface
 *
 * @param argc
 * @param argv
 */
void cliMiddleware(int argc, char **argv)
{
    if (2 < argc && argc < 3)
    {
        fprintf(stderr, "Usage: <collapse> <inputFilename> [-o <outputFilename>]\n");
        exit(EXIT_FAILURE);
    }
}

/**
 * @brief Main function
 * @param argc
 * @param argv
 * @return int
 */
int main(int argc, char **argv)
{
    cliMiddleware(argc, argv);

    /* Initialize */
    char *inputFilename = argv[1];
    char *outputFilename = argc > 3 ? argv[3] : "out";

    return collapse(inputFilename, outputFilename);
}