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

char *write_init_section(TCD_Boundary boundary)
{
    char *outputString = (char *)malloc(1024 * sizeof(char));

    char *outer_var = boundary->outerLoopVar;
    char *outer_var_bound = boundary->outerLoopUpperBound;
    char *iteration_domains = boundary->iterationDomainsString;

    outputString[0] = '\0';

    strcat(outputString, "unsigned pc;\n");
    char *tmp = (char *)malloc(1024 * sizeof(char));
    sprintf(tmp, "unsigned upperBound = %s_Ehrhart(%s);\n", outer_var, outer_var_bound);
    strcat(outputString, tmp);
    strcat(outputString, "unsigned first_iteration = 1;\n");
    sprintf(tmp, "#pragma omp for private(%s) firstprivate(first_iteration) schedule(static)\n", iteration_domains);
    strcat(outputString, tmp);
    strcat(outputString, "for (pc = 1; pc <= upperBound; pc++)\n");
    strcat(outputString, "{\n");
    strcat(outputString, "\tif (first_iteration)\n");
    strcat(outputString, "\t{\n");
    // TODO: for every iteration variables, do the trahrhe function call here
    strcat(outputString, "\t\tfirst_iteration = 0;\n");
    strcat(outputString, "\t}\n");
    strcat(outputString, "\t\n");

    free(tmp);

    return outputString;
}

void generateCode(TCD_BoundaryList boundaryList)
{
    osl_scop_p scop = tcdFlowData->scop;
    osl_statement_p statement;

    CloogState *state;
    CloogInput *input;
    CloogOptions *options;
    struct clast_stmt *root;

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
    FILE *outputFile = fopen(tcdFlowData->outputFile, "w+");

    if (outputFile == NULL)
    {
        fprintf(stderr, "Error: Unable to open file %s\n", tcdFlowData->outputFile);
        exit(EXIT_FAILURE);
    }

    // Initialisation code
    fprintf(outputFile, "%s", write_init_section(boundaryList->first));

    // Insert the actual unchanged code
    // TODO: Remove from scop the part that is not in the iteration domain (ie handled by manual code generation)
    // TODO: Get and put the actual statement code here (for now, they are displayed as functions)
    FILE *tmp = fopen("tmp.c", "w+");
    clast_pprint(tmp, root, 0, options);

    fseek(tmp, 0, SEEK_END);
    long fsize = ftell(tmp);
    fseek(tmp, 0, SEEK_SET);

    char *string = (char *)malloc(fsize + 1);
    fread(string, 1, fsize, tmp);
    fclose(tmp);

    string[fsize] = 0;

    tabString(outputFile, string, fsize);

    // Iteration code
    // TODO: Insert the iteration code here

    // Finalisation code
    fprintf(outputFile, "}\n");

    fclose(outputFile);
}