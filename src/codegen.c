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

unsigned boundary_index = 0;

char ***getIterationDependencies(TCD_Boundary boundary)
{
    TCD_IterationDomain iterationDomain = boundary->firstIterDomainOfUnion->first;
    TCD_IteratorDependencyList iteratorDependencyList = iterationDomain->firstIteratorDependency;
    TCD_IteratorDependency iteratorDependency = iteratorDependencyList->first;
    char ***iteration_dependencies_array = (char ***)calloc(1024, sizeof(char **));
    int i = 0;
    int j = 0;
    while (iteratorDependency != NULL)
    {
        iteration_dependencies_array[i] = (char **)calloc(1024, sizeof(char *));
        iteration_dependencies_array[i][0] = (char *)calloc(1024, sizeof(char));
        strcpy(iteration_dependencies_array[i][0], iteratorDependency->iterator);
        for (j = 0; j < iteratorDependency->dependsOnCount; j++)
        {
            iteration_dependencies_array[i][1] = (char *)calloc(1024, sizeof(char));
            strcat(iteration_dependencies_array[i][1], iteratorDependency->dependsOnList[j]);
        }
        i++;
        iteratorDependency = iteratorDependency->next;
    }
    return iteration_dependencies_array;
}

char *
write_init_section(TCD_Boundary boundary)
{
    char *outputString = (char *)malloc(1024 * sizeof(char));

    char *outer_var = boundary->outerLoopVar;
    char *outer_var_bound = boundary->outerLoopUpperBound;
    char *iteration_domains = boundary->iterationDomainsString;
    char ***iteration_dependencies_array = getIterationDependencies(boundary);

    outputString[0] = '\0';

    char *tmp = (char *)malloc(1024 * sizeof(char));
    sprintf(tmp, "unsigned pc_%d;\n", boundary_index);
    strcat(outputString, tmp);
    // we need to index ehrhart calls as they may be outer vars with the same name among different boundaries
    sprintf(tmp, "unsigned upper_bound_%d = %s_Ehrhart%d(%s);\n", boundary_index, outer_var, boundary_index, outer_var_bound);
    strcat(outputString, tmp);
    sprintf(tmp, "unsigned first_iteration_%d = 1;\n", boundary_index);
    strcat(outputString, tmp);
    sprintf(tmp, "#pragma omp parallel for private(%s) firstprivate(first_iteration_%d) schedule(static)\n", iteration_domains, boundary_index);
    strcat(outputString, tmp);
    sprintf(tmp, "for (pc_%d = 1; pc_%d <= upper_bound_%d; pc_%d++)\n", boundary_index, boundary_index, boundary_index, boundary_index);
    strcat(outputString, tmp);
    strcat(outputString, "{\n");
    sprintf(tmp, "\tif (first_iteration_%d)\n", boundary_index);
    strcat(outputString, tmp);
    strcat(outputString, "\t{\n");
    // DONE: for every iteration variables, do the trahrhe function call here

    // int max_depth = boundary->depth;
    int max_depth = 2;
    int curr_depth = 0;
    while (curr_depth <= max_depth)
    {
        // Construct variables on which the iteration variable depends
        char *iterator_dependent_vars = (char *)malloc(1024 * sizeof(char));
        char *tmp = (char *)malloc(1024 * sizeof(char));
        sprintf(tmp, "pc_%d", boundary_index);
        strcpy(iterator_dependent_vars, tmp);
        strcat(iterator_dependent_vars, ",");
        strcat(iterator_dependent_vars, outer_var_bound);
        for (int i = 0; i < curr_depth; i++)
        {
            // TODO: check if the variable is a parameter or a local variable
            strcat(iterator_dependent_vars, ",");
            strcat(iterator_dependent_vars, iteration_dependencies_array[i][1]);
        }

        sprintf(tmp, "\t\t%s = %s_trahrhe%d(%s);\n", iteration_dependencies_array[curr_depth][0], iteration_dependencies_array[curr_depth][1], boundary_index, iterator_dependent_vars);
        strcat(outputString, tmp);

        curr_depth++;
    }
    sprintf(tmp, "\t\tfirst_iteration_%d = 0;\n", boundary_index);
    strcat(outputString, tmp);
    strcat(outputString, "\t}\n");
    strcat(outputString, "\t\n");

    free(tmp);

    return outputString;
}

void generateCodeSegment(struct clast_stmt *root, CloogOptions *options, TCD_Boundary boundary, FILE *outputFile)
{
    // Initialisation code
    fprintf(outputFile, "%s", write_init_section(boundary));

    // Insert the actual unchanged code
    FILE *tmp = fopen("tmp.c", "w+");

    if (tmp == NULL)
    {
        fprintf(stderr, "Error: Unable to open file tmp.c\n");
        exit(EXIT_FAILURE);
    }

    // DONE - Remove from scop the part that is not in the iteration domain (ie handled by manual code generation)
    // while we are have not hit the depth of parallelism of the boundary, we need to go deeper in the loop nest
    // int loop_nest_depth = boundary->depth;
    int loop_nest_depth = 2;
    while (loop_nest_depth > 0)
    {
        if (CLAST_STMT_IS_A(root, stmt_root))
        {
            struct clast_root *root_stmt = (struct clast_root *)root;
            // equation, n, then
            root = root_stmt->stmt.next;
        }

        else if (CLAST_STMT_IS_A(root, stmt_for))
        {
            struct clast_for *for_stmt = (struct clast_for *)root;
            root = for_stmt->body;
            loop_nest_depth--;
        }
        else if (CLAST_STMT_IS_A(root, stmt_block))
        {
            struct clast_block *block_stmt = (struct clast_block *)root;
            root = block_stmt->body;
        }
        else if (CLAST_STMT_IS_A(root, stmt_user))
        {
            struct clast_user_stmt *user_stmt = (struct clast_user_stmt *)root;
            root = user_stmt->substitutions;
        }
        else if (CLAST_STMT_IS_A(root, stmt_guard))
        {
            struct clast_guard *guard_stmt = (struct clast_guard *)root;
            root = guard_stmt->then;
        }
        else if (CLAST_STMT_IS_A(root, stmt_ass))
        {
            struct clast_assignment *assign = (struct clast_assignment *)root;
            root = assign->stmt.next;
        }
        else
        {
            fprintf(stderr, "Error: Unable to find the loop nest depth\n");
            exit(EXIT_FAILURE);
        }
    }
    // DONE: Get and put the actual statement code here (for now, they are displayed as functions)

    // Write the output
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
    fprintf(outputFile, "}\n\n");
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
    options->openscop = 1;
    options->scop = scop;
    options->compilable = 1;

    FILE *outputFile = fopen(tcdFlowData->outputFile, "w+");

    if (outputFile == NULL)
    {
        fprintf(stderr, "Error: Unable to open file %s\n", tcdFlowData->outputFile);
        exit(EXIT_FAILURE);
    }

    // generation
    TCD_Boundary boundary = boundaryList->first;
    while (boundary != NULL)
    {
        input = cloog_input_from_osl_scop(state, scop);

        if (input == NULL)
        {
            fprintf(stderr, "Error: Unable to generate input from scop\n");
            exit(EXIT_FAILURE);
        }

        // cloog_input_dump_cloog(stdout, input, options);

        root = cloog_clast_create_from_input(input, options);

        if (root == NULL)
        {
            fprintf(stderr, "Error: Unable to generate clast from input\n");
            exit(EXIT_FAILURE);
        }

        generateCodeSegment(root, options, boundary, outputFile);

        // Next boundary
        boundary = boundary->next;
        scop = scop->next;
        boundary_index++;
    }

    fclose(outputFile);
}