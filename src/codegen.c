/**
 * @file codegen.c
 * @author SORGHO Nongma
 * @brief Edits an OpenSCoP representation to generate an output code where loops are collapsed.
 * @version 0.1
 * @date 2024-02-09
 * @copyright Copyright (c) 2024
 */

#include "codegen.h"

extern TCD_FlowData *tcdFlowData;

void generateCode(TCD_BoundaryList boundaryList)
{
    osl_scop_p scop = tcdFlowData->scop;
    osl_statement_p statement;

    CloogState *state;
    CloogInput *input;
    CloogOptions *options;
    struct clast_stmt *root;

    FILE *outputFile = fopen(tcdFlowData->outputFile, "w");

    if (outputFile == NULL)
    {
        fprintf(stderr, "Error: Unable to open file %s\n", tcdFlowData->outputFile);
        exit(EXIT_FAILURE);
    }

    state = cloog_isl_state_malloc(isl_ctx_alloc());
    options = cloog_options_malloc(state);

    input = cloog_input_from_osl_scop(state, scop);

    if (input == NULL)
    {
        fprintf(stderr, "Error: Unable to generate input from scop\n");
        exit(EXIT_FAILURE);
    }

    cloog_input_dump_cloog(stdout, input, options);

    root = cloog_clast_create_from_input(input, options);

    if (root == NULL)
    {
        fprintf(stderr, "Error: Unable to generate clast from input\n");
        exit(EXIT_FAILURE);
    }
}