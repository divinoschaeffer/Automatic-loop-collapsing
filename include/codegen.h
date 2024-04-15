/**
 * @file codegen.h
 * @author SORGHO Nongma
 * @brief This file contains the code generation functions
 * @version 0.1
 * @date 2024-02-09
 */

#ifndef __CODEGEN_H
#define __CODEGEN_H

#include <osl/osl.h>
#include <cloog/isl/cloog.h>
#include <stdlib.h>

#include "flow.h"
#include "data.h"
#include "format_helper.h"
#include "fs.h"

/**
 * @brief Computes the new SCoP structure using the scop in global flow and the boundary list
 * @param boundaryList The boundary list
 */
void generateCode(TCD_BoundaryList boundaryList);

/**
 * @brief Generates the header file
 * @param boundaryList The boundary list
 */
void generateHeaderFile(TCD_BoundaryList boundaryList);

/**
 * @brief Generates the source file
 * @param boundaryList The boundary list
 */
void mergeGeneratedCode();

/**
 * @brief Removes the temporary files
 */
void removeTemporaryFiles();

CloogState *cloog_isl_state_malloc(struct isl_ctx *ctx);

#endif