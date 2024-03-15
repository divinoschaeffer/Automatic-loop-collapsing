/**
 * @file codegen.h
 * @author SORGHO Nongma
 * @brief This file contains the code generation functions
 * @version 0.1
 * @date 2024-02-09
 * @copyright Copyright (c) 2024
 */

#ifndef __CODEGEN_H
#define __CODEGEN_H

#include <osl/osl.h>
#include <cloog/isl/cloog.h>

#include "flow.h"
#include "data.h"
#include "format_helper.h"

/**
 * @brief Computes the new SCoP structure using the scop in global flow and the boundary list
 * @param boundaryList The boundary list
 */
void generateCode(TCD_BoundaryList boundaryList);

void generateHeaderFile(TCD_BoundaryList boundaryList);

void mergeGeneratedCode();

void removeTemporaryFiles();

CloogState *cloog_isl_state_malloc(struct isl_ctx *ctx);

#endif