/**
 * @file codegen.h
 * @author SORGHO Nongma
 * @brief This file contains the code generation functions
 * @version 0.1
 * @date 2024-02-09
 * @copyright Copyright (c) 2024
 */

#ifndef __TCD_CODEGEN_H
#define __TCD_CODEGEN_H

#include <osl/osl.h>
#include <cloog/isl/cloog.h>
#include <cloog/cloog.h>
#include <isl/ctx.h>
#include <isl/set.h>

#include "flow.h"
#include "data.h"

/**
 * @brief Computes the new SCoP structure using the scop in global flow and the boundary list
 * @param boundaryList The boundary list
 */
void generateCode(TCD_BoundaryList boundaryList);

#endif