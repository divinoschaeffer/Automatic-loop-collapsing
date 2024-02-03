#===--- trahrhe_generate_header.sh ---------------------------------------===#
#
# TRAHRHE - Computation of Trahrhe Expressions and related functions
#           Application code generation
#
#===----------------------------------------------------------------------===#
#
# The BSD 3-Clause License
#
# Copyright (c) 2019. INRIA, CNRS and University of Strasbourg
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# Main Contributor:
#     Philippe Clauss     <clauss@unistra.fr>
#
#===----------------------------------------------------------------------===#

generate_header() {
    exec 3>&1
    exec >"trahrhe_header.h"

    echo "#include <stdio.h>"
    echo "#include <stdlib.h>"
    echo "#include <math.h>"
    echo "#include <complex.h>"
    if [ "${m_flag}" = "true" ]; then
      echo "#include <mpc.h>"
      echo " "
      echo "#define MPC_PRECISION 128"
    fi
    echo " "
    if (echo "${Params[x]}" | grep -q "NOT_A_PARAMETER"); then
      parms=""
    else
      parms=$(echo "${Params[x]}" | sed 's/\([A-Za-z_][A-Za-z_0-9]*\)/long int \1/g')
    fi
    vars=$(echo "${listevar[x]}" | sed 's/\([A-Za-z_][A-Za-z_0-9]*\)/long int \1/g')
    echo "/******************************** Ehrhart Polynomials ********************************/"
    echo "static inline long int Ehrhart($parms) {"
    echo " "
    cpt=1
    while ((cpt <= nehrhart[x])); do
      if [[ ${dehrhart=${dehrhart[x$cpt]}} == "" ]]; then
        condition="(1)"
      else
        condition=$(echo "${dehrhart[x$cpt]}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
        condition=$(echo "${condition};" | "$D2C")
      fi
        #  Ccond
        echo "  if $condition {"
        if [ "${m_flag}" = "true" ]; then        
          echo "$(echo "${ehrhart[x$cpt]};" | "$MPC")"
          echo " "
          echo "    return mpc_result;"
        else
          echo "    return $(echo "${ehrhart[x$cpt]};" | "$M2Cint");"
        fi
        echo "  }"
        ((cpt++))
    done
    IFS=","
    set - ${Params[x]}
    nb_parms=$#
    format="%ld"
    nld=2
    while ((nld <= nb_parms)); do
        format="$format, %ld"
        ((nld++))
    done
    if (echo "${Params[x]}" | grep -v -q "NOT_A_PARAMETER"); then
      echo "  fprintf(stderr,\"Error Ehrhart: no corresponding domain: (${Params[x]}) = ($format)\\n\",${Params[x]});"
    fi
    echo "  exit(1);"
    echo "}  /* end Ehrhart */"
    echo " "
    echo "/******************************** Ranking Polynomials ********************************/"
    if [[ "${parms}" == "" ]]; then
      echo "static inline long int Ranking($vars) {"
    else
      echo "static inline long int Ranking($vars,$parms) {"
    fi
    echo " "
    cpt=1
    while ((cpt <= nsol[x])); do
        condition=$(echo "${DS[x$cpt]}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
        condition=$(echo "${condition};" | "$D2C")
        #  Ccond
        echo "  if $condition {"
        if [ "${m_flag}" = "true" ]; then
          echo "$(echo "${RS[x$cpt]};" | "$MPC")"
          echo " "
          echo "    return mpc_result;"
        else
          echo "    return $(echo "${RS[x$cpt]};" | "$M2Cint");"
        fi
        echo "  }"
        ((cpt++))
    done
    IFS=","
    set - $(echo "${listevar[x]},${Params[x]}")
    nb_parms=$#
    format="%ld"
    nld=2
    while ((nld <= nb_parms)); do
        format="$format, %ld"
        ((nld++))
    done
    if (echo "${Params[x]}" | grep -v -q "NOT_A_PARAMETER"); then
      echo "  fprintf(stderr,\"Error Ranking: no corresponding domain: (${listevar[x]}, ${Params[x]}) = ($format)\\n\",${listevar[x]},${Params[x]});"
    fi
    echo "  exit(1);"
    echo "} /* end Ranking */"

    echo " "
    echo "/******************************** PCMin ********************************/"
    cpt=1
    while ((cpt <= nsol[x])); do
        echo "/******************************** PCMin_$cpt ********************************/"
        if [[ "${parms}" == "" ]]; then
          echo "static inline long int PCMin_$cpt() {"
        else
          echo "static inline long int PCMin_$cpt($parms) {"
        fi
        npc=1
        while ((npc <= NPCMIN[x$cpt])); do
          if (echo "${dlexmin[x${cpt}${npc}]}" | grep -q "NOT_A_PARAMETER"); then  
            condition="(1)"
          else
            condition=$(echo "${dlexmin[x${cpt}${npc}]}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
            condition=$(echo "${condition};" | "$D2C")
          fi
            #    Ccond
            echo " "
            echo "  if $condition {"
            if [ "${m_flag}" = "true" ]; then
	      echo "$(echo "${pcmin[x${cpt}${npc}]};" | "$MPC")"
              echo " "
              echo "    return mpc_result;"
	    else
              echo "    return $(echo "${pcmin[x${cpt}${npc}]};" | "$M2Cint");"
	    fi
            echo "  }"
            ((npc++))
        done
        if (echo "${Params[x]}" | grep -v -q "NOT_A_PARAMETER"); then
          echo "  return Ehrhart(${Params[x]});"
        fi
        #IFS=","
        #set - ${Params[x]}
        #nb_parms=$#
        #format="%ld"
        #nld=2
        #while ((nld <= nb_parms)); do
            #format="$format, %ld"
            #((nld++))
        #done
        #echo "  fprintf(stderr,\"Error PCMin_$cpt: domain not corresponding: (${Params[x]}) = ($format)\\n\",${Params[x]});"
        #echo "  exit(1);"
        echo "} /* end PCMin_$cpt */"
        echo " "
        ((cpt++))
    done

    echo "/******************************** PCMax ********************************/"
    cpt=1
    while ((cpt <= nsol[x])); do
        echo "/******************************** PCMax_$cpt ********************************/"
        if [[ "${parms}" == "" ]]; then
          echo "static inline long int PCMax_$cpt() {"
        else
          echo "static inline long int PCMax_$cpt($parms) {"
        fi
        npc=1
        while ((npc <= NPCMAX[x$cpt])); do
          if (echo "${dlexmax[x${cpt}${npc}]}" | grep -q "NOT_A_PARAMETER"); then  
            condition="(1)"
          else
            condition=$(echo "${dlexmax[x${cpt}${npc}]}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
            condition=$(echo "${condition};" | "$D2C")
          fi
            #    Ccond
            echo " "
            echo "  if $condition {"
	    if [ "${m_flag}" = "true" ]; then
	      echo "$(echo "${pcmax[x$cpt$npc]};" | "$MPC")"
              echo " "
              echo "    return mpc_result;"
	    else
              echo "    return $(echo "${pcmax[x$cpt$npc]};" | "$M2Cint");"
            fi
            echo "  }"
            ((npc++))
        done
        echo "  return 0;"
        #echo "  fprintf(stderr,\"Error PCMax_$cpt: domain not corresponding: (${Params[x]}) = ($format)\\n\",${Params[x]});"
        #echo "  exit(1);"
        echo "} /* end PCMax_$cpt */"
        echo " "
        ((cpt++))
    done
    
 # 1. extraction des bornes inf et sup de l'indice recherché. Utilisation de codegen + sed --> lbound[dim], ubound[dim]    

    dim=1
    for var in ${VAR[*]}; do
    
#variables in VAR[*] are not in the correct order. Below is a hack (does it always work?)
        var="${VAR[${CVAR}${dim}]}"
        
        echo "/******************************** trahrhe_$var ********************************/"
        vars=$(echo "${listevar1[x11$((dim - 1))]}" | sed 's/\([A-Za-z_][A-Za-z_0-9]*\)/long int \1/g')
        if (echo "${Params[x]}" | grep -q "NOT_A_PARAMETER"); then
          parms=""
        else
          parms=$(echo "${Params[x]}" | sed 's/\([A-Za-z_][A-Za-z_0-9]*\)/long int \1/g')
        fi
        if ((dim > 1)); then
            if [[ "${parms}" == "" ]]; then
              echo "static inline long int trahrhe_$var(long int pc, $vars) {"
            else
              echo "static inline long int trahrhe_$var(long int pc, $vars, $parms) {"
            fi
            IFS=","
            set - $(echo "${listevar1[x11$((dim - 1))]},${Params[x]}")
            nb_parms=$#
            if (echo "${Params[x]}" | grep -q "NOT_A_PARAMETER"); then
              (( nb_parms-- ))
            fi
            format="%ld"
            nld=2
            while ((nld <= nb_parms)); do
                format="$format, %ld"
                ((nld++))
            done
        else
            if [[ "${parms}" == "" ]]; then
              echo "static inline long int trahrhe_$var(long int pc) {"
            else
              echo "static inline long int trahrhe_$var(long int pc, $parms) {"
            fi
            IFS=","
            set - ${Params[x]}
            nb_parms=$#
            format="%ld"
            nld=2
            while ((nld <= nb_parms)); do
                format="$format, %ld"
                ((nld++))
            done
            if (echo "${Params[x]}" | grep -q "NOT_A_PARAMETER"); then
              format=""
            fi
        fi
 
 # pc : position en entrée pour laquelle il faut calculer l'indice      
 # nsol[x] : number of ranking polynomials
 # Params[x] : liste des paramètres du domaine (ex: N,M,P)
 
 # variables d'importance lexico supérieure : vars="${listevar1[x11$((dim - 1))]}"
 
 # Ranking($vars, $parms) --> WARNING: liste des variables à construire (voir partie math)
 #
 # if (echo "${Params[x]}" | grep -q "NOT_A_PARAMETER"); then
 #     parms=""
 #   else
 #     parms="${Params[x]}"
 #   fi
 #   vars="${listevar[x]}"
 

 echo "$var = ${lbound[dim]}; int upper_bound = ${ubound[dim]}+1;"
 echo "while ($var+1 < upper_bound) {"
 echo "  long int m=($var+upper_bound)/2;"
 if (dim == 1) {   
   echo "if (Ranking(m, ${lbound[dim+1]}, ${lbound[dim+2]}), ..., PARAMS) <= pc) i=m; else ubound=m;"
 else  
   lvar=
   echo "if (Ranking($lvar,m, ${lbound[dim+1]}, ${lbound[dim+2]}), ..., PARAMS) <= pc) i=m; else ubound=m;"
 fi
 echo "}"
 echo "return $var;"
        

        echo "  exit(1);"
        echo "} /* end trahrhe_$var */"
        echo " "
        ((dim++))
    done
    exec >&3
}
