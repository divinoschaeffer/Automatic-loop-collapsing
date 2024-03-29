#include "data.h"
#define MAX_VARIABLES 20

extern TCD_FlowData *tcdFlowData;

/**
 * @brief given an operation as a string
 * returns the variable names in the operation
 * @param operation
 * @return char**
 */
char **extractVariables(char *operation)
{
  char **variables = (char **)malloc(MAX_VARIABLES * sizeof(char *));
  for (int i = 0; i < MAX_VARIABLES; i++)
  {
    variables[i] = (char *)calloc(1024, sizeof(char));
  }

  int i = 0;
  char *token = strtok(operation, "+-*/");
  while (token != NULL)
  {
    strcpy(variables[i], token);
    token = strtok(NULL, "+-*/");
    i++;
  }
  return variables;
}

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

/// @brief Returns the boundary of an OSL statement
/// @param statement
/// @param names
/// @return
TCD_Boundary getBoundary(osl_statement_p statement, osl_names_p names)
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

  boundary->firstIterDomainOfUnion = (TCD_IterationDomainList)malloc(sizeof(struct iterationDomainList));
  boundary->firstIterDomainOfUnion->first = NULL;

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
  boundary->parametersCount = len;

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
  for (int _i = 1; _i <= statement->domain->nb_output_dims; _i++)
  {
    if (name_array == NULL)
      continue;

    strcat(unionList, name_array[_i]);
    if (_i != statement->domain->nb_output_dims)
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

  boundary->iteratorDependenciesArray = (char ***)malloc(sizeof(char *));

  for (int depth = start_row; depth < statement->domain->nb_rows; depth++)
  {
    if (name_array == NULL)
      continue;

    char *relation_buffer = (char *)malloc(sizeof(char));
    sprintf(relation_buffer, "%s", osl_relation_expression(statement->domain, depth, name_array));

    strcat(unuaryUnion, relation_buffer);
    strcat(unuaryUnion, " >= 0");
    if (depth != statement->domain->nb_rows - 1)
      strcat(unuaryUnion, " and ");

    boundary->iteratorDependenciesArray[depth] = (char **)calloc(statement->domain->nb_rows, sizeof(char *));
    boundary->iteratorDependenciesArray[depth] = extractVariables(relation_buffer);
#pragma endregion
  }

  strcat(unuaryUnion, " }");

  TCD_IterationDomain iterationDomainsUnion = (TCD_IterationDomain)malloc(sizeof(struct iterationDomain));
  iterationDomainsUnion->next = NULL;

  iterationDomainsUnion->iterationDomain = (char *)malloc(statement->domain->nb_rows * (OSL_MAX_STRING + 1) * sizeof(char));
  strcpy(iterationDomainsUnion->iterationDomain, unuaryUnion);

  boundary->nameArray = name_array;

  if (boundary->firstIterDomainOfUnion->first == NULL)
  {
    boundary->firstIterDomainOfUnion->first = iterationDomainsUnion;
  }
  else
  {
    TCD_IterationDomain current = boundary->firstIterDomainOfUnion->first;
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
 * @brief Get the Boundaries object
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
    TCD_Boundary currentBoundary = getBoundary(statement, names);

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

  copy->firstIterDomainOfUnion = (TCD_IterationDomainList)malloc(sizeof(struct iterationDomainList));
  copy->firstIterDomainOfUnion->first = copyIterationDomain(original->firstIterDomainOfUnion->first);

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
    TCD_IterationDomain unions = boundary->firstIterDomainOfUnion->first;
    int i = 0;
    printf("%s\n", unions->iterationDomain);
    boundary = boundary->next;
  }
  return;
}