/**
 * @file data.c
 * @author SORGHO Nongma
 * @brief Data structures and helper functions to structure the collapsing flow
 * @version 0.9
 * @date 2024-04-04
 *
 * @copyright Copyright (c) 2024
 *
 */

#include "data.h"
#define MAX_VARIABLES 20

extern TCD_FlowData *tcdFlowData;

/**
 * @brief given an operation as a string
 * returns the variable names in the operation
 * @param operation
 * @return char**
 */
char **extractVariables(const char *operation)
{
  char *operation_copy = strdup(operation);
  char **variables = (char **)malloc(MAX_VARIABLES * sizeof(char *));
  for (int i = 0; i < MAX_VARIABLES; i++)
  {
    variables[i] = (char *)calloc(1024, sizeof(char));
  }

  int i = 0;
  char *token = strtok(operation_copy, "+-*/,");
  while (token != NULL)
  {
    strcpy(variables[i], token);
    token = strtok(NULL, "+-*/,");
    i++;
  }
  return variables;
}

/**
 * @brief Copy an iteration domain
 * @param original
 * @return TCD_IterationDomain
 */
TCD_IterationDomain copyIterationDomain(TCD_IterationDomain original)
{
  if (original == NULL)
    return NULL;

  TCD_IterationDomain copy = (TCD_IterationDomain)malloc(sizeof(struct iterationDomain));
  if (copy == NULL)
    return NULL;

  copy->iterationDomain = strdup(original->iterationDomain);
  if (copy->iterationDomain == NULL)
  {
    free(copy);
    return NULL;
  }

  copy->next = copyIterationDomain(original->next);

  return copy;
}

/**
 * @brief Returns the boundary of an OSL statement
 * @param statement
 * @param names
 * @return
 */
TCD_Boundary getBoundary(osl_statement_p statement, osl_names_p names, int loop_nest_depth)
{
  int i;
  int part, nb_parts;
  int is_access_array;
  int start_row;
  int index_output_dims;
  int index_input_dims;
  int index_params;

  TCD_IterationDomain iterationDomainsFirst = NULL;
  char **name_array = NULL;

  TCD_Boundary boundary = (TCD_Boundary)malloc(sizeof(struct boundary));

  boundary->firstIterationDomainOfUnion = (TCD_IterationDomainList)malloc(sizeof(struct iterationDomainList));
  boundary->firstIterationDomainOfUnion->first = NULL;

  if (statement == NULL)
    return boundary;
  if (statement->domain == NULL)
    return boundary;

  nb_parts = osl_relation_nb_components(statement->domain);
  is_access_array = (statement->domain->type == OSL_TYPE_READ || statement->domain->type == OSL_TYPE_WRITE ? 1 : 0);

  if (nb_parts > 1)
  {
    fprintf(stderr, "Error: the domain has %d parts, but only one is expected.\n", nb_parts);
    exit(EXIT_FAILURE);
  }
#pragma region osl stuff init
  index_output_dims = 1;
  index_input_dims = index_output_dims + statement->domain->nb_output_dims;
  index_params = index_input_dims + statement->domain->nb_input_dims;

  // Prepare the array of strings for comments.
  name_array = osl_relation_strings(statement->domain, names);

  if (!is_access_array)
  {
    start_row = 0;
  }
  else
  {
    if (statement->domain->nb_rows == 1) // for non array variables
      start_row = 0;
    else // Remove the 'Arr' line
      start_row = 1;
  }
#pragma endregion
#pragma region unuaryUnion init stuff
  // Initialize unuaryUnion
  char *unuaryUnion = (char *)malloc(statement->domain->nb_rows * 2 * (OSL_MAX_STRING + 1) * sizeof(char));
  char *unionList = (char *)malloc((OSL_MAX_STRING + 1) * sizeof(char));
  strcpy(unionList, "");
  strcpy(unuaryUnion, "[");
  char *string;

  string = osl_strings_sprint(names->parameters);
  size_t len = strcspn(string, "\n");

  string[len] = '\0';

  // replace string spaces with commas
  for (i = 0; i < len; i++)
  {
    if (string[i] == ' ')
    {
      string[i] = ',';
    }
  }
#pragma endregion

  // first elem of "string" is the outer loop var, elems are separated by commas
  // get first elem of "string" and store it in boundary->outerLoopVar
  boundary->outerLoopUpperBound = (char *)malloc(1024 * sizeof(char));
  strcpy(boundary->outerLoopUpperBound, string);

  strcat(unuaryUnion, string);
  strcat(unuaryUnion, "] -> { [");

#pragma region output_dims
  for (int _i = 1; _i <= loop_nest_depth; _i++)
  {
    if (name_array == NULL)
      continue;

    strcat(unionList, name_array[_i]);
    if (_i != loop_nest_depth)
      strcat(unionList, ",");
    if (_i == 1)
    {
      boundary->outerLoopVar = (char *)malloc(strlen(name_array[_i]) * sizeof(char));
      strcpy(boundary->outerLoopVar, name_array[_i]);
    }
  }
#pragma endregion

#pragma region isl domain string generation
  boundary->iterationDomainsString = (char *)malloc(len * sizeof(char));
  strcpy(boundary->iterationDomainsString, unionList);
  strcat(unuaryUnion, unionList);
  strcat(unuaryUnion, "] : ");

  for (int depth = start_row; depth < statement->domain->nb_rows; depth++)
  {
    if (name_array == NULL)
      continue;

    char *relation_buffer = (char *)malloc(sizeof(char));
    sprintf(relation_buffer, "%s", osl_relation_expression(statement->domain, depth, name_array));

    char **relation_buffer_variables = extractVariables(relation_buffer);

    // if a variable of the relation buffer is not in the unionList,
    // it is not in the iteration domain. So we skip it
    char **unionList_variables = extractVariables(unionList);
    int is_in_union = 0;
    for (int i = 0; i < MAX_VARIABLES; i++)
    {
      if (strcmp(relation_buffer_variables[i], "") == 0)
        break;
      for (int j = 0; j < MAX_VARIABLES; j++)
      {
        if (strcmp(unionList_variables[j], "") == 0)
          break;
        if (strcmp(relation_buffer_variables[i], unionList_variables[j]) == 0)
        {
          is_in_union = 1;
          break;
        }
      }
      if (!is_in_union)
        break;
    }
    if (!is_in_union)
      continue;
    if (depth != statement->domain->nb_rows - 1 && depth != start_row)
      strcat(unuaryUnion, " and ");

    strcat(unuaryUnion, relation_buffer);
    strcat(unuaryUnion, " >= 0");

#pragma endregion
  }

  strcat(unuaryUnion, " }");

  TCD_IterationDomain iterationDomainsUnion = (TCD_IterationDomain)malloc(sizeof(struct iterationDomain));
  iterationDomainsUnion->next = NULL;

  iterationDomainsUnion->iterationDomain = (char *)malloc(statement->domain->nb_rows * (OSL_MAX_STRING + 1) * sizeof(char));
  strcpy(iterationDomainsUnion->iterationDomain, unuaryUnion);

  boundary->nameArray = name_array;

  if (boundary->firstIterationDomainOfUnion->first == NULL)
  {
    boundary->firstIterationDomainOfUnion->first = iterationDomainsUnion;
  }
  else
  {
    TCD_IterationDomain current = boundary->firstIterationDomainOfUnion->first;
    while (current->next != NULL)
    {
      current = current->next;
    }
    current->next = iterationDomainsUnion;
  }
  statement->domain = statement->domain->next;

  return boundary;
}

/**
 * @brief Get the Boundaries object list
 * @return TCD_BoundaryList
 */
TCD_BoundaryList getBoundaries()
{
  TCD_BoundaryList boundaryHead = (TCD_BoundaryList)malloc(sizeof(struct boundaryList));
  boundaryHead->first = NULL;

  osl_scop_p scop = osl_scop_clone(tcdFlowData->scop);

  int parameters_backedup = 0;
  int arrays_backedup = 0;
  osl_strings_p parameters_backup = NULL;
  osl_strings_p arrays_backup = NULL;
  osl_names_p names;
  osl_arrays_p arrays;
  int iterators_backedup = 0;
  int nb_ext = 0;
  osl_body_p body = NULL;
  osl_strings_p iterators_backup = NULL;

  if (scop == NULL)
  {
    fprintf(stdout, "# NULL scop\n");
    return boundaryHead;
  }

  osl_statement_p statement;
  int boundary_index = 0;

  while (scop != NULL)
  {
    names = osl_scop_names(scop);
    // If possible, replace parameter names with scop parameter names.
    if (osl_generic_has_URI(scop->parameters, OSL_URI_STRINGS))
    {
      parameters_backedup = 1;
      parameters_backup = names->parameters;
      names->parameters = scop->parameters->data;
    }

    // If possible, replace array names with arrays extension names.
    arrays = osl_generic_lookup(scop->extension, OSL_URI_ARRAYS);
    if (arrays != NULL)
    {
      arrays_backedup = 1;
      arrays_backup = names->arrays;
      names->arrays = osl_arrays_to_strings(arrays);
    }

    body = (osl_body_p)osl_generic_lookup(scop->statement->extension, OSL_URI_BODY);
    if (body && body->iterators != NULL)
    {
      iterators_backedup = 1;
      iterators_backup = names->iterators;
      names->iterators = body->iterators;
    }

    statement = scop->statement;
    TCD_Boundary currentBoundary = getBoundary(statement, names, tcdFlowData->collapseParameters[boundary_index]);

    if (boundaryHead->first == NULL)
    {
      boundaryHead->first = currentBoundary;
    }
    else
    {
      TCD_Boundary current = boundaryHead->first;
      while (current->next != NULL)
      {
        current = current->next;
      }
      current->next = currentBoundary;
    }

    // If necessary, switch back parameter names.
    if (parameters_backedup)
    {
      parameters_backedup = 0;
      names->parameters = parameters_backup;
    }

    // If necessary, switch back array names.
    if (arrays_backedup)
    {
      arrays_backedup = 0;
      osl_strings_free(names->arrays);
      names->arrays = arrays_backup;
    }
    scop = scop->next;
    boundary_index++;
  }

  osl_names_free(names);

  return boundaryHead;
}

/**
 * @brief Copies a boundary
 * @param original
 * @return TCD_Boundary
 */
TCD_Boundary copyBoundary(TCD_Boundary original)
{
  if (original == NULL)
    return NULL;

  TCD_Boundary copy = (TCD_Boundary)malloc(sizeof(struct boundary));
  if (copy == NULL)
    return NULL;

  copy->firstIterationDomainOfUnion = (TCD_IterationDomainList)malloc(sizeof(struct iterationDomainList));
  copy->firstIterationDomainOfUnion->first = copyIterationDomain(original->firstIterationDomainOfUnion->first);

  copy->next = copyBoundary(original->next);

  return copy;
}

/**
 * @brief Prints the boundaries
 * @param boundaryList
 */
void printBoundaries(TCD_BoundaryList boundaryList)
{
  TCD_Boundary boundary = copyBoundary(boundaryList->first);
  while (boundary != NULL)
  {
    printf("Boundary: -----\n");
    TCD_IterationDomain unions = boundary->firstIterationDomainOfUnion->first;
    int i = 0;
    printf("%s\n", unions->iterationDomain);
    boundary = boundary->next;
  }
  return;
}