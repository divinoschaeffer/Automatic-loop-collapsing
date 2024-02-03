/**
 * @file flow.h
 * @author Nongma SORGHO
 * @brief Data structures that represent the progress of the trahrhe collapsing process.
 * @version 0.1
 * @date 2024-02-03
 */

#include <stdio.h>
#include <stdlib.h>

#include <osl/osl.h>

/**
 * @brief Indexes that define the next step of the collapsing process.
 * Starts at @param TCD_REWRITE_TRAHRHE_COLLAPSE (0).
 */
enum TCD_NextStep
{
    /**
     * @brief Next step is to rewrite the #pragma trharhe collapse(N) directive into a
     * #pragma scop directive covering the right scope.
     */
    TCD_REWRITE_TRAHRHE_COLLAPSE,
    /**
     * @brief Next step is to extract the polyedral representation of the "scoped"
     * loops using clan parser.
     */
    TCD_EXTRACT_LOOPS_POLYTOPE_REPRESENTATION,
    /**
     * @brief Next step is to extract the loops terminals using the the precedently
     * generated polyedral representation.
     */
    TCD_EXTRACT_LOOPS_TERMINALS,
    /**
     * @brief Next step is to retrieve the reverse Ehrhart polynomials for the loops
     * indexes.
     */
    TCD_GET_TRAHRHE_FUNCTIONS,
    /**
     * @brief Next step is to build the collapsed source using Cloog after we have
     * updated the former polyedral reprensation adding the newly generated paths.
     */
    TCD_BUILD_COLLAPSED
};

/**
 * @brief Computational data to be transported during the collapsing
 */
typedef struct
{
    /**
     * @brief Entry file for the next step.
     */
    union
    {
        FILE vanilla;
        FILE scoped;
    } entryFile;

    /**
     * @brief Output file.
     */
    FILE outputFile;

    /**
     * @brief Pointer on the current polyedral representation of the source code.
     */
    osl_scop_p scop;
} TCD_FlowData;

/**
 * @brief TCD_Flow is a data structure we want to keep in track during all the
 * collapsing process.
 * @details It defines
 * @param stepIndex as the next step to perform
 * @param flowData as the persistent data we want to save in memory for computations.
 */
typedef struct
{
    TCD_NextStep stepIndex;
    TCD_FlowData *flowData;
} TCD_Flow;

/**
 * @brief TCD_Flow is global - all C sources that use it must declare it as extern.
 */
TCD_Flow *tcdFlow;

/**
 * At some point, we may want to transit our data structure through terminal scripts.
 * In this purpose, it is interesting to have the following functions.
 */

/**
 * @brief Writes a JSON representing the current structure of the collapsing flow.
 * @param fileName the name of the flow's JSON file to generate.
 */
void exportTcdFlow(char *fileName);

/**
 * @brief Reads a JSON representing the a collapsing flow and loads it in the
 * current states.
 * @note This operation overrides the current flow it there is one.
 * @param fileName the name of the flow's JSON file.
 */
void importTcdFlow(char *fileName);