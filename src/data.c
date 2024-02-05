#include "data.h"

extern TCD_FlowData *tcdFlowData;

char **domain_strings(osl_relation_p domain, osl_names_t* names) {
    char** strings;
  char temp[OSL_MAX_STRING];
  int i, offset;

  if ((domain == NULL) || (names == NULL)) {
    OSL_debug("no names or relation to build the name array");
    return NULL;
  }

  OSL_malloc(strings, char**,
             ((size_t)domain->nb_columns + 1) * sizeof(char*));
  strings[domain->nb_columns] = NULL;

  OSL_strdup(strings[0], "e/i");
  offset = 1;

  // 2. Output dimensions.
  if (osl_relation_is_access(domain)) {
    // The first output dimension is the array name.
    OSL_strdup(strings[offset], "Arr");
    // The other ones are the array dimensions [1]...[n]
    for (i = offset + 1; i < domain->nb_output_dims + offset; i++) {
      sprintf(temp, "[%d]", i - 1);
      OSL_strdup(strings[i], temp);
    }
  } else if ((domain->type == OSL_TYPE_DOMAIN) ||
             (domain->type == OSL_TYPE_CONTEXT)) {
    for (i = offset; i < domain->nb_output_dims + offset; i++) {
      OSL_strdup(strings[i], names->iterators->string[i - offset]);
    }
  } else {
    for (i = offset; i < domain->nb_output_dims + offset; i++) {
      OSL_strdup(strings[i], names->scatt_dims->string[i - offset]);
    }
  }
  offset += domain->nb_output_dims;

  return strings;
}

TCD_Boundary getBoundary(osl_relation_p domain) {
    
    TCD_Boundary boundary = (TCD_Boundary)malloc(sizeof(struct Boundary));
    
    int columnsCount = domain->nb_columns;
    int rowsCount = domain->nb_rows;
    int paramsCount = domain->nb_parameters;

    char *upperBuffer = (char *)malloc(sizeof(char));
    char *lowerBuffer = (char *)malloc(sizeof(char));

    int i = 0;
    TCD_Variable variable = (TCD_Variable)malloc(sizeof(struct Variable));
    
    int variableCount = domain->nb_output_dims;

    osl_names_t *strings = osl_scop_names(tcdFlowData->scop);
    char **iteratorStrings = domain_strings(domain, strings);
    printf("Variable count: %d\n", variableCount);

    while (i < domain->nb_rows) {

        variable->name = iteratorStrings[i / 2 + 1];
        variable->lowerBound = osl_relation_expression(domain, i, iteratorStrings);
        variable->upperBound = osl_relation_expression(domain, i + 1, iteratorStrings);

        printf("Variable %s: ---------\n", variable->name);
        printf("lowerBound: %s\n", variable->lowerBound);
        printf("upperBound: %s\n", variable->upperBound);

        i += 2;
    }

    return boundary;
}

TCD_Boundary getBoundaries() {
    TCD_Boundary boundaryHead = (TCD_Boundary)malloc(sizeof(struct Boundary));
    TCD_Boundary currentBoundary = boundaryHead;

    osl_scop_p scopP = tcdFlowData->scop;
    
    if (!scopP) return NULL;

    osl_relation_p domain;

    osl_scop_print(stdout, scopP);
    while (scopP) {
        domain = scopP->statement->domain;

        printf("Entering ScoP...------------------------------\n---------------------------\n");

        currentBoundary = currentBoundary->next;

        currentBoundary = getBoundary(domain);

        scopP = scopP->next;
    }

    return boundaryHead;
}