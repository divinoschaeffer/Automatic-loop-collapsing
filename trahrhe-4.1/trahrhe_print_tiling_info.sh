#===--- trahrhe_print_tiling_info.sh -------------------------------------===#
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

print_tiling_info() {

    bold=$(tput bold)
    normal=$(tput sgr0)

    #dépend de la profondeur de tiling tprof
    typeset tprof npc CVAR

    tprof="$1"

    typeset cpt var parms vars dim nmin lvar
    echo " "
    echo "${bold}******************************** TILING INFOS ********************************${normal}"

    ListeTileMin=""
    cpt=1
    PREV_LMAX=""
    while ((cpt <= nsol[${NAME[1]}])); do
        nmax=1
        while ((nmax <= ${ntilemax})); do
            IFS=","
            for LMAX in ${TILEMAX[${cpt}${nmax}]}; do # si ub/iscc donne un max de plusieurs argts
                expression="$LMAX"
                MinLong
                LMAX="$expression"
                if [ "$LMAX" != "$PREV_LMAX" ]; then
                    ListeTileMin="${ListeTileMin}, ${LMAX}"
                fi
                PREV_LMAX="$LMAX"
            done
            ((nmax++))
        done
        ((cpt++))
    done
    ListeTileMin=$(echo "$ListeTileMin" | sed "s/^ *, *//")
    IFS=","
    set - $ListeTileMin
    if (($# > 1)); then
        ListeTileMin="MAX($ListeTileMin)"
    fi

    echo " "
    echo "${bold}TILE_VOL_L1 must be greater than ${ListeTileMin}${normal}"

    nheader=1
    while ((nheader <= tprof)); do
        echo " "
        echo "${bold}******************************** TILING DEPTH ${nheader} ********************************${normal}"
        echo " "
        CVAR="${NAME[${nheader}]}" #nom de la variable en cours
        parms="${Params[${CVAR}]}"
        vars="${listevar[${CVAR}]}"
        echo "${bold}Ehrhart Polynomials of the initial domain (maximum value of the Ranking Polynomials):${normal}"
        echo "-------------------------------------------------------------------------------------"
        npc=1
        while ((npc <= nehrhart[${CVAR}])); do
            if (echo "$parms" | grep -v -q "NOT_A_PARAMETER"); then
              echo "Validity Domain for the next Ehrhart Polynomial: ${dehrhart[${CVAR}${npc}]}"
              echo "    ${bold}${CVAR}_Ehrhart($parms):=${ehrhart[${CVAR}${npc}]}${normal}"
            else
              if [[ ${nheader} == 1 ]]; then
                echo "    ${bold}${CVAR}_Ehrhart():=${ehrhart[${CVAR}${npc}]}${normal}"
              else
                echo "Validity Domain for the next Ehrhart Polynomial: ${dehrhart[${CVAR}${npc}]}" | sed "s/\[NOT_A_PARAMETER, //"
                echo "    ${bold}${CVAR}_Ehrhart($parms):=${ehrhart[${CVAR}${npc}]}${normal}" | sed "s/NOT_A_PARAMETER, //"
              fi
            fi
            ((npc++))
        done
        cpt=1
        while ((cpt <= nsol[${CVAR}])); do
            echo " "
            echo "${bold}Case no. $cpt${normal}"
            echo "-------------"
            echo "${bold}Ranking Polynomial $cpt:${normal}"
            echo "------------------------"
            echo "Validity Domain:"
            if [[ ${nheader} == 1 ]]; then
              echo "    ${bold}D$cpt:=${DS[${CVAR}${cpt}]}${normal}" | sed "s/\[NOT_A_PARAMETER\] -> //"
            else
              echo "    ${bold}D$cpt:=${DS[${CVAR}${cpt}]}${normal}" | sed "s/NOT_A_PARAMETER, //"
            fi
            echo "Ranking Polynomial:"
            if (echo "$parms" | grep -v -q "NOT_A_PARAMETER"); then
              echo "    ${bold}${CVAR}_Ranking($vars,$parms):=${RS[${CVAR}${cpt}]}${normal}"
            else
              if [[ ${nheader} == 1 ]]; then
                echo "    ${bold}${CVAR}_Ranking($vars):=${RS[${CVAR}${cpt}]}${normal}"
              else
                echo "    ${bold}${CVAR}_Ranking($vars,$parms):=${RS[${CVAR}${cpt}]}${normal}" | sed "s/NOT_A_PARAMETER,//"
              fi
            fi
            echo " "
            echo "${bold}PCMin (minimum value(s) of the Ranking Polynomial):${normal}"
            echo "---------------------------------------------------"
            if ((NPCMIN[${CVAR}${cpt}] == 1)); then
                if (echo "${dlexmin[${CVAR}${cpt}1]}" | grep -v -q "NOT_A_PARAMETER"); then
                  echo "Validity Domain for ${CVAR}_PCMin: ${dlexmin[${CVAR}${cpt}1]}"
                  echo "    ${bold}${CVAR}_PCMin($parms) := ${pcmin[${CVAR}${cpt}1]}${normal}"
                else
                  if [[ ${nheader} == 1 ]]; then
                    echo "    ${bold}${CVAR}_PCMin() := ${pcmin[${CVAR}${cpt}1]}${normal}"
                  else
                    echo "Validity Domain for ${CVAR}_PCMin: ${dlexmin[${CVAR}${cpt}1]}" | sed "s/NOT_A_PARAMETER, //"
                    echo "    ${bold}${CVAR}_PCMin($parms) := ${pcmin[${CVAR}${cpt}1]}${normal}" | sed "s/NOT_A_PARAMETER, //"
                  fi
                fi
            else
                npc=1
                while ((npc <= NPCMIN[${CVAR}${cpt}])); do
                    echo "Validity Domain for ${CVAR}_PCMin_$npc: ${dlexmin[${CVAR}${cpt}${npc}]}"
                    echo "    ${bold}${CVAR}_PCMin_$npc($parms) := ${pcmin[${CVAR}${cpt}${npc}]}${normal}"
                    ((npc++))
                done
            fi
            echo " "

            echo "${bold}PCMax (maximum value(s) of the Ranking Polynomial):${normal}"
            echo "---------------------------------------------------"
            if ((NPCMAX[${CVAR}${cpt}] == 1)); then
                if (echo "${dlexmax[${CVAR}${cpt}1]}" | grep -v -q "NOT_A_PARAMETER"); then
                  echo "Validity Domain for ${CVAR}_PCMax: ${dlexmax[${CVAR}${cpt}1]}"
                  echo "    ${bold}${CVAR}_PCMax($parms) := ${pcmax[${CVAR}${cpt}1]}${normal}"
                else
                  if [[ ${nheader} == 1 ]]; then
                    echo "    ${bold}${CVAR}_PCMax() := ${pcmax[${CVAR}${cpt}1]}${normal}"
                  else
                    echo "Validity Domain for ${CVAR}_PCMax: ${dlexmax[${CVAR}${cpt}1]}" | sed "s/NOT_A_PARAMETER, //"
                    echo "    ${bold}${CVAR}_PCMax($parms) := ${pcmax[${CVAR}${cpt}1]}${normal}" | sed "s/NOT_A_PARAMETER, //"
                  fi
                fi
            else
                npc=1
                while ((npc <= NPCMAX[${CVAR}${cpt}])); do
                    echo "Validity Domain for ${CVAR}_PCMax_$npc: ${dlexmax[${CVAR}${cpt}${npc}]}"
                    echo "    ${bold}${CVAR}_PCMax_$npc($parms) := ${pcmax[${CVAR}${cpt}${npc}]}${normal}"
                    ((npc++))
                done
            fi
            echo " "
            echo "${bold}Trahrhe Expressions:${normal}"
            echo "--------------------"
            dim=1
            while ((dim <= N)); do
#### begin OPTIM TILING
                #echo "dim = $dim -- t_flag = ${t_flag}"
                if (( dim > 1 )); then
                  break
                fi
#### end OPTIM TILING           
                for ((Period = 1; $((NPeriod[${CVAR}${cpt}] + 1)) - ${Period}; Period++)); do
                    if ((NPCMININT[${CVAR}${cpt}${Period}${dim}] == 1)); then
                        if ((Period == 1 || VarPeriodic[${CVAR}${cpt}${VAR[${CVAR}${dim}]}] == 0)); then
                            if ((dim < N)); then
                                condition=$(echo "${dlexminint[${CVAR}${cpt}${Period}${dim}1]}" | sed 's/\(.*{.*\)\(\[.*\]\)\(.*\)/\2->\1\3/')
                                condition=$(echo "$condition" | sed "s/\(\[.*\), *${VAR[${CVAR}${dim}]}\(.*\]\)/\1\2/" | sed "s/\(.*\)\(:.*\)/\1\[${VAR[${CVAR}${dim}]}\]\2/")
                                condition=$(echo "codegen ({[${VAR[${CVAR}${dim}]}]->[${VAR[${CVAR}${dim}]}]}*$condition);" | iscc)
                                if (echo $condition | grep -q "if "); then
                                    condition=$(echo "$condition" | sed -n "1p" | sed "s/if (\(.*\))$/\1/" | sed "s/\&\&/and/g" | sed "s/||/or/g" | sed "s/==/=/g")
                                    if (echo "$parms" | grep -v -q "NOT_A_PARAMETER"); then
                                      condition="$condition and ${CVAR}_PCMin($parms) <= pc <= ${CVAR}_PCMax($parms)"
                                    else
                                      if [[ ${nheader} == 1 ]]; then
                                        condition="$condition and ${CVAR}_PCMin() <= pc <= ${CVAR}_PCMax()"
                                      else
                                        condition=$(echo "${condition} and ${CVAR}_PCMin($parms) <= pc <= ${CVAR}_PCMax($parms)" | sed "s/NOT_A_PARAMETER, //g")
                                      fi
                                    fi
                                else
                                    if (echo "$parms" | grep -v -q "NOT_A_PARAMETER"); then
                                      condition="${CVAR}_PCMin($parms) <= pc <= ${CVAR}_PCMax($parms)"
                                    else
                                      if [[ ${nheader} == 1 ]]; then
                                        condition="${CVAR}_PCMin() <= pc <= ${CVAR}_PCMax()"
                                      else
                                        condition=$(echo "${CVAR}_PCMin($parms) <= pc <= ${CVAR}_PCMax($parms)" | sed "s/NOT_A_PARAMETER, //g")
                                      fi
                                    fi
                                fi
                            else
                                condition=$(echo "${DSA[V${CVAR}N${cpt}P${Period}]}" | sed "s/.*: *\(.*\) *\}/\1/")
                                if (echo "$parms" | grep -v -q "NOT_A_PARAMETER"); then
                                  condition="${condition} and ${CVAR}_PCMin($parms) <= pc <= ${CVAR}_PCMax($parms)"
                                else
                                  if [[ ${nheader} == 1 ]]; then
                                    condition="${condition} and ${CVAR}_PCMin() <= pc <= ${CVAR}_PCMax()"
                                  else
                                    condition=$(echo "${condition} and ${CVAR}_PCMin($parms) <= pc <= ${CVAR}_PCMax($parms)" | sed "s/NOT_A_PARAMETER, //g")
                                  fi
                                fi
                            fi
                            if ((dim > 1)); then
                                echo " "
                            fi
                            echo "Validity Domain for the next Trahrhe Expression: ${condition}"
                        fi
                        #echo "lexmin = ${vlexminint[${CVAR}${cpt}${Period}${dim}1]}"
                        echo "    ${bold}${VAR[${CVAR}${dim}]} := floor(realpart( ${trahrhe[${CVAR}${cpt}${Period}${dim}1]} ))${normal}"
                        if ((NPeriod[${CVAR}${cpt}] > 1 && Period != NPeriod[${CVAR}${cpt}] && VarPeriodic[${CVAR}${cpt}${VAR[${CVAR}${dim}]}] == 1)); then
                            echo "               **** OR ****"
                        fi
                    else
                        nmin=1
                        while ((nmin <= NPCMININT[${CVAR}${cpt}${Period}${dim}])); do
                            if ((dim < N)); then
                                echo -n "Validity Domain for the next Trahrhe Expression $nmin: ${dlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}"
                            else
                                echo -n "Validity Domain for the next Trahrhe Expressions $nmin: ${DS[${CVAR}${cpt}]}"
                            fi
                            if (echo "$parms" | grep -v -q "NOT_A_PARAMETER"); then
                              echo " and ${CVAR}_PCMin($parms) <= pc <= ${CVAR}_PCMax($parms)"
                            else
                              if [[ ${nheader} == 1 ]]; then
                                echo " and ${CVAR}_PCMin() <= pc <= ${CVAR}_PCMax()"
                              else
                                echo " and ${CVAR}_PCMin($parms) <= pc <= ${CVAR}_PCMax($parms)" | sed "s/NOT_A_PARAMETER, //"
                              fi
                            fi
                            echo " "
                            #echo "lexmin = ${vlexminint[${CVAR}${cpt}${Period}${dim}{nmin}]}"
                            echo "    ${bold}${VAR[${CVAR}${dim}]} := floor(realpart( ${trahrhe[${CVAR}${cpt}${Period}${dim}${nmin}]} ))${normal}"
                            echo " "
                            ((nmin++))
                        done
                    fi
                done # for ((Period=1 ; $(( NPeriod[${cpt}]+1 )) - ${Period} ; Period++))
                ((dim++))
            done
            ((cpt++))
        done
        ((nheader++))
    done # while ((nheader <= tprof))
}
