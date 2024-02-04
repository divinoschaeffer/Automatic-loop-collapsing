#include "main.h"

extern TCD_Flow *tcdFlow;

void cliMiddleware(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: <collapse> <inputFilename> [<outputFilename>]\n");
        exit(EXIT_FAILURE);
    }
}

int main(int argc, char** argv) {
    cliMiddleware(argc, argv);

    /* Initialize */
    char *inputFilename = argv[1];
    char *outputFilename = argc > 2 ? argv[2] : "out.c";
    initTcdFlow(inputFilename, outputFilename);
    
    tcdGoToNextStep(); // TODO: for now, we consider we have passed the first step.

    #pragma region Step1

    /* Step 1: Extract loops polytope representation */
    tcdPrintStep();

    osl_scop_p scop;
    clan_options_p options;
    /* Default option setting. */
    options = clan_options_malloc() ;
    /* Extraction of the SCoP. */
    FILE *entryFile = fopen(tcdFlow->flowData->entryFile.vanilla, "r");
    scop = clan_scop_extract(entryFile, options);
    printf("Language: %s\n", scop->language);

    #pragma endregion

    tcdGoToNextStep();

    #pragma region Step2

    /* Step 2: Extract loops terminals */
    tcdPrintStep();

    

    #pragma endregion

    /* Save the planet. */
    clan_options_free(options);
    osl_scop_free(scop);

    return 0;
}