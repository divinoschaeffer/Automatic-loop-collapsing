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
#pragma region Step0

    initTcdFlow(inputFilename, outputFilename);

#pragma endregion

#pragma region Step1

    /* Step 1: Extract loops polytope representation */
    extractLoopsPolytope();

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
    endTcdFlow();

    exit(EXIT_SUCCESS);
}

const char *usageMessage = "Usage: trahrhe-collapse <inputFilename> [-o <outputFilename>]\n"
                           "Options :\n"
                           "    -o, --output <outputFilename> Specify the output filename\n"
                           "    -h, --help Display this help message\n"
                           "    -v, --version Display the version of the program\n";

/**
 * @brief Middleware for the command line interface
 *
 * @param argc
 * @param argv
 */
void cliMiddleware(int argc, char **argv)
{
    if (argc == 2)
    {
        if (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0)
        {
            fprintf(stdout, "%s", usageMessage);

            exit(EXIT_SUCCESS);
        }
        if (strcmp(argv[1], "-v") == 0 || strcmp(argv[1], "--version") == 0)
        {
            fprintf(stdout, "Trahrhe Collapse - v0.1\n");

            exit(EXIT_SUCCESS);
        }
    }
    if (argc < 2 || argc > 4)
    {
        fprintf(stderr, "%s", usageMessage);
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
    char *outputFilename = argc > 3 ? argv[3] : "out.c";

    return collapse(inputFilename, outputFilename);
}