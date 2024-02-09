/**
 * @file data.h
 * @author Nongma SORGHO
 * @brief Data structures and helper functions to structure the collapsing flow
 * @version 0.1
 * @date 2024-02-04
 */

#ifndef __DATA_H
#define __DATA_H

#include <stdlib.h>
#include <string.h>
#include <clan/clan.h>

#include "flow.h"

struct iterationDomain {
    char* iterationDomain;
    struct iterationDomain *next;
};
typedef struct iterationDomain *TCD_IterationDomain;
TCD_IterationDomain copyIterationDomain(TCD_IterationDomain original);

struct iterationDomainList {
  TCD_IterationDomain first;
};
typedef struct iterationDomainList *TCD_IterationDomainList;


/**
 * @brief Boundary list
 */
struct boundary
{
    /**
     * @brief The iteration domain unions to pass to Trhahre
     */
    TCD_IterationDomainList firstIterDomainOfUnion;
    /**
     * @brief Next loop boundaries
     */
    struct boundary *next;
};
typedef struct boundary *TCD_Boundary;

/**
 * @brief Get a boundary given a domain
 * @param statement
 * @param iteratorStrings
 * @return TCD_Boundary
 */
TCD_Boundary getBoundary(osl_statement_p statement, osl_names_p iteratorStrings);

/**
 * @brief Get the Boundaries object from the current scop
 * @return TCD_Boundary
 */
TCD_Boundary getBoundaries();


static
char ** osl_relation_strings(osl_relation_p relation, osl_names_p names) {
  char ** strings;
  char temp[OSL_MAX_STRING];
  int i, offset;
  
  if ((relation == NULL) || (names == NULL)) {
    OSL_debug("no names or relation to build the name array");
    return NULL;
  }

  OSL_malloc(strings, char **, (relation->nb_columns + 1)*sizeof(char *));
  strings[relation->nb_columns] = NULL;

  // 1. Equality/inequality marker.
  OSL_strdup(strings[0], "e/i");
  offset = 1;

  // 2. Output dimensions.
  if (osl_relation_is_access(relation)) {
    // The first output dimension is the array name.
    OSL_strdup(strings[offset], "Arr");
    // The other ones are the array dimensions [1]...[n]
    for (i = offset + 1; i < relation->nb_output_dims + offset; i++) {
      sprintf(temp, "[%d]", i - 1);
      OSL_strdup(strings[i], temp);
    }
  }
  else
  if ((relation->type == OSL_TYPE_DOMAIN) ||
      (relation->type == OSL_TYPE_CONTEXT)) {
    for (i = offset; i < relation->nb_output_dims + offset; i++) {
      OSL_strdup(strings[i], names->iterators->string[i - offset]);
    }
  }
  else {
    for (i = offset; i < relation->nb_output_dims + offset; i++) {
      OSL_strdup(strings[i], names->scatt_dims->string[i - offset]);
    }
  }
  offset += relation->nb_output_dims;

  // 3. Input dimensions.
  for (i = offset; i < relation->nb_input_dims + offset; i++)
    OSL_strdup(strings[i], names->iterators->string[i - offset]);
  offset += relation->nb_input_dims;

  // 4. Local dimensions.
  for (i = offset; i < relation->nb_local_dims + offset; i++)
    OSL_strdup(strings[i], names->local_dims->string[i - offset]);
  offset += relation->nb_local_dims;

  // 5. Parameters.
  for (i = offset; i < relation->nb_parameters + offset; i++)
    OSL_strdup(strings[i], names->parameters->string[i - offset]);
  offset += relation->nb_parameters;

  // 6. Scalar.
  OSL_strdup(strings[offset], "1");

  return strings;
}

static
osl_names_p osl_statement_names(osl_statement_p statement) {
  int nb_parameters = OSL_UNDEFINED;
  int nb_iterators  = OSL_UNDEFINED;
  int nb_scattdims  = OSL_UNDEFINED;
  int nb_localdims  = OSL_UNDEFINED;
  int array_id      = OSL_UNDEFINED;

  osl_statement_get_attributes(statement, &nb_parameters, &nb_iterators,
                               &nb_scattdims,  &nb_localdims, &array_id);
  
  return osl_names_generate("P", nb_parameters,
                            "i", nb_iterators,
                            "c", nb_scattdims,
                            "l", nb_localdims,
                            "A", array_id);
}

static
osl_names_p osl_relation_names(osl_relation_p relation) {
  int nb_parameters = OSL_UNDEFINED;
  int nb_iterators  = OSL_UNDEFINED;
  int nb_scattdims  = OSL_UNDEFINED;
  int nb_localdims  = OSL_UNDEFINED;
  int array_id      = OSL_UNDEFINED;

  osl_relation_get_attributes(relation, &nb_parameters, &nb_iterators,
                              &nb_scattdims, &nb_localdims, &array_id);
  
  return osl_names_generate("P", nb_parameters,
                            "i", nb_iterators,
                            "c", nb_scattdims,
                            "l", nb_localdims,
                            "A", array_id);
}


#endif