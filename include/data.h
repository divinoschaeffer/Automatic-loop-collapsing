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
#include <stdio.h>
#include <ctype.h>

#include "flow.h"
#include "hashtable.h"
#include "format_helper.h"

/**
 * @brief Iteration domain representation
 */
struct iterationDomain
{
  /**
   * @brief The iteration domain under the ISL format
   * to pass to Trahrhe
   */
  char *iterationDomain;
  struct iterationDomain *next;
};
typedef struct iterationDomain *TCD_IterationDomain;

/**
 * @brief Copy an iteration domain
 * @param original
 * @return TCD_IterationDomain
 */
TCD_IterationDomain copyIterationDomain(TCD_IterationDomain original);

struct iterationDomainList
{
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
   * @brief Outer loop variable
   */
  char *outerLoopVar;
  /**
   * @brief Outer loop upper bound
   */
  char *outerLoopUpperBound;
  /**
   * @brief Iteration domains string
   */
  char *iterationDomainsString;
  /**
   * @brief An array of string representing the list of dependencies
   * of the iterators in the same order as the iterators in the domain
   */
  char ***iteratorDependenciesArray;
  /**
   * @brief The array of the iterator names
   */
  char **nameArray;
  /**
   * @deprecated
   * @brief Dependencies hashtable
   */
  struct nlist *hashTable;
  /**
   * @brief Next loop boundaries
   */
  struct boundary *next;
  /**
   * @brief The number of parameters
   */
  int parametersCount;
};
typedef struct boundary *TCD_Boundary;

struct boundaryList
{
  TCD_Boundary first;
};
typedef struct boundaryList *TCD_BoundaryList;

/**
 * @brief Get a boundary given a domain
 * @param statement
 * @param iteratorStrings
 * @return TCD_Boundary
 */
TCD_Boundary getBoundary(osl_statement_p statement, osl_names_p iteratorStrings);

/**
 * @brief Get the Boundaries object from the current scop
 * @return TCD_BoundaryList
 */
TCD_BoundaryList getBoundaries();

/**
 * @brief Print the boundaries
 * @param boundaryList
 */
void printBoundaries(TCD_BoundaryList boundaryList);

/**
 * @brief Copy a boundary
 * @param original
 * @return TCD_Boundary
 */
TCD_Boundary copyBoundary(TCD_Boundary original);

static char **osl_relation_strings(osl_relation_p relation, osl_names_p names)
{
  char **strings;
  char temp[OSL_MAX_STRING];
  int i, offset;

  if ((relation == NULL) || (names == NULL))
  {
    OSL_debug("no names or relation to build the name array");
    return NULL;
  }

  OSL_malloc(strings, char **, (relation->nb_columns + 1) * sizeof(char *));
  strings[relation->nb_columns] = NULL;

  // 1. Equality/inequality marker.
  OSL_strdup(strings[0], "e/i");
  offset = 1;

  // 2. Output dimensions.
  if (osl_relation_is_access(relation))
  {
    // The first output dimension is the array name.
    OSL_strdup(strings[offset], "Arr");
    // The other ones are the array dimensions [1]...[n]
    for (i = offset + 1; i < relation->nb_output_dims + offset; i++)
    {
      sprintf(temp, "[%d]", i - 1);
      OSL_strdup(strings[i], temp);
    }
  }
  else if ((relation->type == OSL_TYPE_DOMAIN) ||
           (relation->type == OSL_TYPE_CONTEXT))
  {
    for (i = offset; i < relation->nb_output_dims + offset; i++)
    {
      OSL_strdup(strings[i], names->iterators->string[i - offset]);
    }
  }
  else
  {
    for (i = offset; i < relation->nb_output_dims + offset; i++)
    {
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

#endif