#include "data.h"

extern TCD_FlowData *tcdFlowData;

TCD_IterationDomain copyIterationDomain(TCD_IterationDomain original) {
    if (original == NULL)
        return NULL;

    // Allocate memory for the new structure
    TCD_IterationDomain copy = (TCD_IterationDomain)malloc(sizeof(struct iterationDomain));
    if (copy == NULL)
        return NULL;

    // Copy iterationDomain string
    copy->iterationDomain = strdup(original->iterationDomain);
    if (copy->iterationDomain == NULL) {
        free(copy);
        return NULL;
    }

    // Copy next pointer recursively
    copy->next = copyIterationDomain(original->next);

    return copy;
}


TCD_Boundary getBoundary(osl_statement_p statement, osl_names_p names) {
  int i;
  int part, nb_parts;
  int is_access_array;
  int start_row;
  int index_output_dims;
  int index_input_dims;
  int index_params;
  
  TCD_IterationDomain iterationDomainsFirst = NULL;
  char **name_array = NULL;

  TCD_Boundary boundary = (TCD_Boundary) malloc (sizeof(struct boundary));

  boundary->firstIterDomainOfUnion = (TCD_IterationDomainList)malloc(sizeof(struct iterationDomainList));
  boundary->firstIterDomainOfUnion->first = NULL;

  if (statement == NULL) return boundary;
  if (statement->domain == NULL) return boundary;

  nb_parts = osl_relation_nb_components(statement->domain);
  is_access_array = (statement->domain->type == OSL_TYPE_READ || statement->domain->type == OSL_TYPE_WRITE ? 1 : 0);

  printf("Nb parts: %d\n", nb_parts);

  // Print each part of the union.
  for (part = 1; part <= nb_parts; part++) {
    index_output_dims = 1;
    index_input_dims = index_output_dims + statement->domain->nb_output_dims;
    index_params = index_input_dims + statement->domain->nb_input_dims;

    // Prepare the array of strings for comments.
    name_array = osl_relation_strings(statement->domain, names);

    if (!is_access_array) {
      start_row = 0;
    } else {
      if (statement->domain->nb_rows == 1)  // for non array variables
        start_row = 0;
      else  // Remove the 'Arr' line
        start_row = 1;
    }
    // Print the array
    

    // Initialize unuaryUnion
    char *unuaryUnion = (char*)malloc(statement->domain->nb_rows * (OSL_MAX_STRING + 1) * sizeof(char));
    char *unionList = (char*)malloc((OSL_MAX_STRING + 1) * sizeof(char));
    strcpy(unionList, "");
    strcpy(unuaryUnion, "[");
    char* string;

    string = osl_strings_sprint(tcdFlowData->scop->parameters->data);
    size_t len = strcspn(string, "\n");

    string[len] = '\0';
    strcat(unuaryUnion, string);
    strcat(unuaryUnion, "] -> { [");

    for (int _i = 1; _i <= statement->domain->nb_output_dims; _i++) {
      if (name_array != NULL) {
        strcat(unionList, name_array[_i]);
        if (_i != statement->domain->nb_output_dims) 
          strcat(unionList, ",");
      }
    }
    strcat(unuaryUnion, unionList);
    strcat(unuaryUnion, "] : ");

    for (i = start_row; i < statement->domain->nb_rows; i++) {
      if (name_array != NULL) {
        char *equation_inequation_builder_buffer = (char*)malloc(sizeof(char));
        sprintf(equation_inequation_builder_buffer, "%s >= 0", osl_relation_expression(statement->domain, i, name_array));
        strcat(unuaryUnion, equation_inequation_builder_buffer);
        if (i != statement->domain->nb_rows - 1)
          strcat(unuaryUnion, " and ");
      }
    }

    strcat(unuaryUnion, " }");

    printf("here3");
    TCD_IterationDomain iterationDomainsUnion = (TCD_IterationDomain) malloc (sizeof(struct iterationDomain));
    iterationDomainsUnion->next = NULL;
    iterationDomainsUnion->iterationDomain = (char*)malloc(statement->domain->nb_rows * (OSL_MAX_STRING + 1) * sizeof(char));
    strcpy(iterationDomainsUnion->iterationDomain, unuaryUnion);
    
    // Free the array of strings.
    if (name_array != NULL) {
      for (i = 0; i < statement->domain->nb_columns; i++)
        free(name_array[i]);
      free(name_array);
    }
    free(unionList);
    free(unuaryUnion);

    if (boundary->firstIterDomainOfUnion->first == NULL) {
      boundary->firstIterDomainOfUnion->first = iterationDomainsUnion;
    } else {
      TCD_IterationDomain current = boundary->firstIterDomainOfUnion->first;
      while (current->next != NULL) {
          current = current->next;
      }
      current->next = iterationDomainsUnion;
    }
    statement->domain = statement->domain->next;
  }

  return boundary;
}

TCD_Boundary getBoundaries() {
    TCD_Boundary boundaryHead = (TCD_Boundary)malloc(sizeof(struct boundary));
    TCD_Boundary currentBoundary = boundaryHead;

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

  if (scop == NULL) {
    fprintf(stdout, "# NULL scop\n");
    return boundaryHead;
  } else {
    fprintf(stdout,
            "# [File generated by the OpenScop Library %s]\n"
            "# [SCoPLib format]\n",
            OSL_RELEASE);
  }

  // if (osl_scop_check_compatible_scoplib(scop) == 0) {
  //   OSL_error("SCoP integrity check failed. Something may go wrong.");
  //   exit(1);
  // }

  // Generate the names for the various dimensions.
  
    osl_statement_p statement;

  while (scop != NULL) {
    names = osl_scop_names(scop);
    // If possible, replace parameter names with scop parameter names.
    if (osl_generic_has_URI(scop->parameters, OSL_URI_STRINGS)) {
      parameters_backedup = 1;
      parameters_backup = names->parameters;
      names->parameters = scop->parameters->data;
    }

    // If possible, replace array names with arrays extension names.
    arrays = osl_generic_lookup(scop->extension, OSL_URI_ARRAYS);
    if (arrays != NULL) {
      arrays_backedup = 1;
      arrays_backup = names->arrays;
      names->arrays = osl_arrays_to_strings(arrays);
    }

    osl_util_print_provided(
        stdout, osl_generic_has_URI(scop->parameters, OSL_URI_STRINGS),
        "Parameters are");

    if (scop->parameters) {
      fprintf(stdout, "# Parameter names\n");
      osl_strings_print(stdout, scop->parameters->data);
    }

    fprintf(stdout, "\n# Number of statements\n");
    fprintf(stdout, "%d\n\n", osl_statement_number(scop->statement));

    osl_statement_pprint_scoplib(stdout, scop->statement, names);

    statement = scop->statement;

    currentBoundary = currentBoundary->next;

    currentBoundary = getBoundary(statement, names);
    printf("\n\n\nIteration domain union: -----\n");
    TCD_IterationDomain unions = currentBoundary->firstIterDomainOfUnion->first;
    int union_counter = 1;
    while (unions != NULL) {
      printf ("%d. %s\n", union_counter, unions->iterationDomain);
      unions = unions->next;
      union_counter++;
    }

    // If necessary, switch back parameter names.
    if (parameters_backedup) {
      parameters_backedup = 0;
      names->parameters = parameters_backup;
    }

    // If necessary, switch back array names.
    if (arrays_backedup) {
      arrays_backedup = 0;
      osl_strings_free(names->arrays);
      names->arrays = arrays_backup;
    }

    scop = scop->next;
  }

  osl_names_free(names);
    


    return boundaryHead;
}