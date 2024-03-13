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

char *
write_init_section(TCD_Boundary boundary)
{
    char *outputString = (char *)malloc(1024 * sizeof(char));

    char *outer_var = boundary->outerLoopVar;
    char *outer_var_bounds = boundary->outerLoopUpperBound;
    char *iteration_domains = boundary->iterationDomainsString;
    char **name_array = boundary->nameArray;

    outputString[0] = '\0';

    char *tmp = (char *)malloc(1024 * sizeof(char));
    // include trahrhe header
    char *header_file = (char *)malloc(1024 * sizeof(char));
    strcpy(header_file, tcdFlowData->outputFile);
    strcat(header_file, ".h");
    sprintf(tmp, "#include \"%s\"\n\n", header_file);
    strcat(outputString, tmp);

    sprintf(tmp, "//start//\n");
    strcat(outputString, tmp);

    sprintf(tmp, "\nunsigned pc_%d;\n", boundary_index);
    strcat(outputString, tmp);
    // we need to index ehrhart calls as they may be outer vars with the same name among different boundaries
    sprintf(tmp, "unsigned upper_bound_%d = Ehrhart%d(%s);\n", boundary_index, boundary_index, outer_var_bounds);
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

    int max_depth = tcdFlowData->collapseParameters[boundary_index];
    int curr_depth = 0;
    while (curr_depth < max_depth)
    {
        // Construct variables on which the iteration variable depends
        char *vars = (char *)malloc(1024 * sizeof(char));
        char *tmp = (char *)malloc(1024 * sizeof(char));

        strcpy(tmp, outer_var_bounds);
        sprintf(vars, "pc_%d", boundary_index);

        // add iteration variables from start to curr_depth
        for (int i = 0; i < curr_depth; i++)
        {
            strcat(vars, ",");
            strcat(vars, name_array[i + 1]);
        }

        // take only first curr_depth parameters
        char *token = strtok(tmp, ",");
        int token_count = 0;
        do
        {
            if (token_count <= curr_depth)
            {
                strcat(vars, ",");
                strcat(vars, token);
            }
            else
            {
                break;
            }
            token_count++;
            token = strtok(NULL, ",");
        } while (token != NULL);

        sprintf(tmp, "\t\t%s = trahrhe_%s%d(%s);\n", name_array[curr_depth + 1], name_array[curr_depth + 1], boundary_index, vars);
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

char *take(int index, char *string)
{
    char *tmp = (char *)malloc(1024 * sizeof(char));
    strcpy(tmp, string);
    char *token = strtok(tmp, ",");
    for (int i = 0; i < index; i++)
    {
        token = strtok(NULL, ",");
    }
    return token;
}

void increment(int curr_depth,
               char *outer_var_bounds,
               char **name_array,
               char *outputString,
               struct clast_expr *stop_conditions[],
               int *stop_conditions_int,
               CloogOptions *options)
{
    if (curr_depth == 0)
    {
        return;
    }
    // the innermost loop is incremented first, then when it reaches its upper bound, the next loop is incremented  etc.
    char *tmp = (char *)malloc(1024 * sizeof(char));
    strcat(outputString, "\n");
    // sprintf(tmp, "\tif (%s >= %s)\n", name_array[curr_depth], take(curr_depth, outer_var_bounds));
    FILE *tmpFile = fopen("tmp2.c", "w+");
    if (tmpFile == NULL)
    {
        fprintf(stderr, "Error: Unable to open file tmp.c\n");
        exit(EXIT_FAILURE);
    }
    clast_pprint_expr(options, tmpFile, stop_conditions[curr_depth - 1]);
    fseek(tmpFile, 0, SEEK_END);
    long fsize = ftell(tmpFile);
    fseek(tmpFile, 0, SEEK_SET);
    char *string = (char *)malloc(fsize + 1);
    fread(string, 1, fsize, tmpFile);
    fclose(tmpFile);
    string[fsize] = 0;
    tabString(tmpFile, string, fsize);
    if (stop_conditions_int[curr_depth - 1] == 0)
    {
        sprintf(tmp, "\tif (%s > %s)\n", name_array[curr_depth + 1], string);
    }
    else
    {
        sprintf(tmp, "\tif (%s < %s)\n", name_array[curr_depth + 1], string);
    }
    // remove tmp2.c
    remove("tmp2.c");
    strcat(outputString, tmp);
    strcat(outputString, "\t{\n");
    sprintf(tmp, "\t\t%s++;\n", name_array[curr_depth]);
    strcat(outputString, tmp);
    if (stop_conditions_int[curr_depth - 1] == 0)
    {
        sprintf(tmp, "\t\t%s = %s - 1;\n", name_array[curr_depth + 1], name_array[curr_depth]);
    }
    else
    {
        sprintf(tmp, "\t\t%s = %s + 1;\n", name_array[curr_depth + 1], name_array[curr_depth]);
    }
    strcat(outputString, tmp);
    increment(curr_depth - 1, outer_var_bounds, name_array, outputString, stop_conditions, stop_conditions_int, options);
    strcat(outputString, "\t}\n");
    free(tmp);
}

char *
write_increment_section(TCD_Boundary boundary, struct clast_expr *stop_conditions[], int *stop_conditions_int, CloogOptions *options)
{
    char *outputString = (char *)malloc(1024 * sizeof(char));

    char *outer_var = boundary->outerLoopVar;
    char *outer_var_bounds = boundary->outerLoopUpperBound;
    char *iteration_domains = boundary->iterationDomainsString;
    char **name_array = boundary->nameArray;

    outputString[0] = '\0';

    int max_depth = tcdFlowData->collapseParameters[boundary_index];
    sprintf(outputString, "\n\t%s++;", name_array[max_depth]);
    increment(max_depth - 1, outer_var_bounds, name_array, outputString, stop_conditions, stop_conditions_int, options);

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
    int loop_nest_depth = tcdFlowData->collapseParameters[boundary_index];
    struct clast_expr *stop_conditions[loop_nest_depth];
    int *stop_conditions_int = (int *)malloc(loop_nest_depth * sizeof(int));
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
            if (for_stmt->UB != NULL)
            {
                stop_conditions[loop_nest_depth - 1] = for_stmt->UB;
                stop_conditions_int[loop_nest_depth - 1] = 1;
            }
            else
            {
                stop_conditions[loop_nest_depth - 1] = for_stmt->LB;
                stop_conditions_int[loop_nest_depth - 1] = 0;
            }
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

    // Increment
    char *increment = write_increment_section(boundary, stop_conditions, stop_conditions_int, options);
    fprintf(outputFile, "%s", increment);

    // Finalisation code
    fprintf(outputFile, "}\n\n");

    fprintf(outputFile, "//end//\n");
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

    char *outputFilename = (char *)malloc(1024 * sizeof(char));
    strcpy(outputFilename, INTERMEDIATE_FILENAME);
    strcat(outputFilename, ".c");

    FILE *outputFile = fopen(outputFilename, "w+");

    if (outputFile == NULL)
    {
        fprintf(stderr, "Error: Unable to open file %s\n", outputFilename);
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

void generateBoundaryHeader(TCD_Boundary boundary, FILE *outputFile)
{
    char *isl_domain = boundary->firstIterDomainOfUnion->first->iterationDomain;

    printf("isl_domain: %s\n", isl_domain);

    char *bash_command = (char *)malloc(1024 * sizeof(char));
    sprintf(bash_command, "cd trahrhe-4.1 && ./trahrhe -d\"%s\" -s\"%d\" -e", isl_domain, boundary_index);
    // output file is trahrhe-4.1/trahrhe_header.h
    FILE *tmp = fopen("tmp.sh", "w+");
    if (tmp == NULL)
    {
        fprintf(stderr, "Error: Unable to open file tmp.sh\n");
        exit(EXIT_FAILURE);
    }
    fprintf(tmp, "%s", bash_command);
    fclose(tmp);
    system("chmod +x tmp.sh && ./tmp.sh");
    remove("tmp.sh");

    FILE *headerFile = fopen("trahrhe-4.1/trahrhe_header.h", "r");
    if (headerFile == NULL)
    {
        fprintf(stderr, "Error: Unable to open file trahrhe-4.1/trahrhe_header.h\n");
        exit(EXIT_FAILURE);
    }

    fseek(headerFile, 0, SEEK_END);
    long fsize = ftell(headerFile);
    fseek(headerFile, 0, SEEK_SET);

    char *string = (char *)malloc(fsize + 1);
    fread(string, 1, fsize, headerFile);
    fclose(headerFile);

    string[fsize] = 0;

    fprintf(outputFile, "%s", string);

    remove("trahrhe-4.1/trahrhe_header.h");

    free(bash_command);
}

void generateHeaderFile(TCD_BoundaryList boundaryList)
{
    char *headerFilename = (char *)malloc(1024 * sizeof(char));
    strcpy(headerFilename, INTERMEDIATE_FILENAME);
    strcat(headerFilename, ".h");
    FILE *outputFile = fopen(headerFilename, "w+");
    if (outputFile == NULL)
    {
        fprintf(stderr, "Error: Unable to open file %s\n", headerFilename);
        exit(EXIT_FAILURE);
    }

    TCD_Boundary boundary = boundaryList->first;
    while (boundary != NULL)
    {
        generateBoundaryHeader(boundary, outputFile);

        boundary = boundary->next;
    }
}

void mergeGeneratedCode()
{
    char *command = (char *)malloc(1024 * sizeof(char));
    char *pwd = (char *)malloc(100 * sizeof(char));

    getcwd(pwd, 100);
    sprintf(command, "%s/fusion/fusion.sh %s %s.c %s", pwd, tcdFlowData->entryFile, INTERMEDIATE_FILENAME, tcdFlowData->outputFile);

    system(command);

    free(command);
    free(pwd);
}