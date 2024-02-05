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
#include <clan/clan.h>

#include "flow.h"


/**
 * @brief Returns the iterators names from a domain given a set of names?
 * @param domain 
 * @param names 
 * @return char** 
 */
char **domain_strings(osl_relation_p domain, osl_names_t* names);


/**
 * @brief Loop variable structure
 */
typedef struct Variable {
    /**
     * @brief The name of the variable
     */
    char *name;
    /**
     * @brief Upper boundary
     */
    char* upperBound;
    /**
     * @brief Lower boundary
     */
    char* lowerBound;
    /**
     * @brief Next variable
     */
    struct Variable *next;
} *TCD_Variable;

/**
 * @brief Boundary list
 */
typedef struct Boundary
{
    /**
     * @brief List of variables of the current loops node
     */
    TCD_Variable variables;
    /**
     * @brief Next loop boundaries
     */
    struct Boundary *next;
} *TCD_Boundary;


/**
 * @brief Get a boundary given a domain
 * @param domain 
 * @return TCD_Boundary 
 */
TCD_Boundary getBoundary(osl_relation_p domain);

/**
 * @brief Get the Boundaries object from the current scop
 * @return TCD_Boundary
 */
TCD_Boundary getBoundaries();

#endif