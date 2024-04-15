#===--- trahrhe_print_math_results.sh ------------------------------------===#
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

print_math_results() {
    bold=$(tput bold)
    normal=$(tput sgr0)
    echo " "
    echo "${bold}******************************** Math results ********************************${normal}"
    echo " "
    echo "${bold}Ehrhart Polynomials of the initial domain (maximum value of the Ranking Polynomials):${normal}"
    echo "-------------------------------------------------------------------------------------"
    npc=1
    while ((npc <= nehrhart[x])); do
        echo "Validity Domain for the next Ehrhart Polynomial: ${dehrhart[x$npc]}"
        if (echo "${Params[x]}" | grep -v -q "NOT_A_PARAMETER"); then
          echo "    ${bold}Ehrhart(${Params[x]}):=${ehrhart[x$npc]}${normal}"
        else
          echo "    ${bold}Ehrhart():=${ehrhart[x$npc]}${normal}"
        fi
        ((npc++))
    done
    cpt=1
    while ((cpt <= nsol[x])); do
        echo " "
        echo "${bold}Case no. $cpt${normal}"
        echo "-------------"
        echo "${bold}Ranking Polynomial $cpt:${normal}"
        echo "------------------------"
        echo "Validity Domain:"
        echo "    ${bold}D$cpt:=${DS[x$cpt]}${normal}" | sed "s/\[NOT_A_PARAMETER\] -> //"
        echo "Ranking Polynomial:"
        if (echo "${Params[x]}" | grep -v -q "NOT_A_PARAMETER"); then
          echo "    ${bold}r$cpt(${listevar[x]},${Params[x]}):=${RS[x${cpt}]}${normal}"
        else
          echo "    ${bold}r$cpt(${listevar[x]}):=${RS[x${cpt}]}${normal}"
        fi
        echo " "
        echo "${bold}PCMin (minimum value(s) of the Ranking Polynomial):${normal}"
        echo "---------------------------------------------------"
        if ((NPCMIN[x$cpt] == 1)); then
            if (echo "${Params[x]}" | grep -v -q "NOT_A_PARAMETER"); then
              echo "Validity Domain for PCMin: ${dlexmin[x$cpt"1"]}"
              echo "    ${bold}PCMin(${Params[x]}) := ${pcmin[x$cpt"1"]}${normal}"
            else
              echo "    ${bold}PCMin() := ${pcmin[x$cpt"1"]}${normal}"
            fi
        else
            npc=1
            while ((npc <= NPCMIN[x$cpt])); do
                echo "Validity Domain for PCMin$npc: ${dlexmin[x$cpt$npc]}"
                if (echo "${Params[x]}" | grep -v -q "NOT_A_PARAMETER"); then
                  echo "    ${bold}PCMin$npc(${Params[x]}) := ${pcmin[x$cpt$npc]}${normal}"
                else
                  echo "    ${bold}PCMin$npc() := ${pcmin[x$cpt$npc]}${normal}"
                fi
                ((npc++))
            done
        fi
        echo " "

        echo "${bold}PCMax (maximum value(s) of the Ranking Polynomial):${normal}"
        echo "---------------------------------------------------"
        if ((NPCMAX[x$cpt] == 1)); then
            if (echo "${Params[x]}" | grep -v -q "NOT_A_PARAMETER"); then
              echo "Validity Domain for PCMax: ${dlexmax[x${cpt}1]}"
              echo "    ${bold}PCMax(${Params[x]}) := ${pcmax[x${cpt}1]}${normal}"
            else
              echo "    ${bold}PCMax() := ${pcmax[x${cpt}1]}${normal}"
            fi
        else
            npc=1
            while ((npc <= NPCMAX[x$cpt])); do
                echo "Validity Domain for PCMax$npc: ${dlexmax[x$cpt$npc]}"
                if (echo "${Params[x]}" | grep -v -q "NOT_A_PARAMETER"); then
                  echo "    ${bold}PCMax$npc(${Params[x]}) := ${pcmax[x$cpt$npc]}${normal}"
                else
                  echo "    ${bold}PCMax$npc() := ${pcmax[x$cpt$npc]}${normal}"
                fi
                ((npc++))
            done
        fi
        echo " "
        echo "${bold}Trahrhe Expressions:${normal}"
        echo "--------------------"
        dim=1
        while ((dim <= N)); do

            for ((Period = 1; $((NPeriod[x${cpt}] + 1)) - ${Period}; Period++)); do
                if ((NPCMININT[x${cpt}${Period}${dim}] == 1)); then
                    if ((Period == 1 || VarPeriodic[x${cpt}${VAR[x$dim]}] == 0)); then
                        if ((dim < N)); then
                            condition=$(echo "${dlexminint[x${cpt}${Period}${dim}1]}" | sed 's/\(.*{.*\)\(\[.*\]\)\(.*\)/\2->\1\3/')
                            condition=$(echo "$condition" | sed "s/\(\[.*\), *${VAR[x$dim]}\(.*\]\)/\1\2/" | sed "s/\(.*\)\(:.*\)/\1\[${VAR[x$dim]}\]\2/")
                            condition=$(echo "codegen ({[${VAR[x$dim]}]->[${VAR[x$dim]}]}*$condition);" | iscc)
                            if (echo $condition | grep -q "if "); then
                                condition=$(echo "$condition" | sed -n "1p" | sed "s/if (\(.*\))$/\1/" | sed "s/\&\&/and/g" | sed "s/||/or/g" | sed "s/==/=/g")
                                if (echo "${Params[x]}" | grep -v -q "NOT_A_PARAMETER"); then
                                  condition="$condition and PCMin(${Params[x]}) <= pc <= PCMax(${Params[x]})"
                                else
                                  condition="$condition and PCMin() <= pc <= PCMax()"
                                fi
                            else
                                if (echo "${Params[x]}" | grep -v -q "NOT_A_PARAMETER"); then
                                  condition="PCMin(${Params[x]}) <= pc <= PCMax(${Params[x]})"
                                else
                                  condition="PCMin() <= pc <= PCMax()"
                                fi
                            fi
                        else
                            condition=$(echo "${DSA[VxN${cpt}P${Period}]}" | sed "s/.*: *\(.*\) *\}/\1/")
                            if (echo "${Params[x]}" | grep -v -q "NOT_A_PARAMETER"); then
                              condition="${condition} and PCMin(${Params[x]}) <= pc <= PCMax(${Params[x]})"
                            else
                              condition="${condition} and PCMin() <= pc <= PCMax()"
                            fi
                        fi
                        if ((dim > 1)); then
                            echo " "
                        fi
                        echo "Validity Domain for the next Trahrhe Expression: $condition"
                    fi
                    echo "    ${bold}${VAR[x$dim]} := floor(realpart( ${trahrhe[x${cpt}${Period}${dim}1]} ))${normal}"
                    if ((NPeriod[x${cpt}] > 1 && Period != NPeriod[x${cpt}] && VarPeriodic[x${cpt}${VAR[x$dim]}] == 1)); then
                        echo "               **** OR ****"
                    fi
                else
                    nmin=1
                    while ((nmin <= NPCMININT[x${cpt}${Period}${dim}])); do
                        if ((dim < N)); then
                            echo -n "Validity Domain for the next Trahrhe Expression $nmin: ${dlexminint[x${cpt}${Period}${dim}${nmin}]}"
                        else
                            echo -n "Validity Domain for the next Trahrhe Expressions $nmin: ${DS[x${cpt}]}"
                        fi
                        if (echo "${Params[x]}" | grep -v -q "NOT_A_PARAMETER"); then
                          echo " and PCMin(${Params[x]}) <= pc <= PCMax(${Params[x]})"
                        else
                          echo " and PCMin() <= pc <= PCMax()"
                        fi
                        echo " "
                        echo "    ${bold}${VAR[x$dim]} := floor(realpart( ${trahrhe[x${cpt}${Period}${dim}${nmin}]} ))${normal}"
                        echo " "
                        ((nmin++))
                    done
                fi
            done # for ((Period=1 ; $(( NPeriod[${cpt}]+1 )) - ${Period} ; Period++))
            ((dim++))
        done
        ((cpt++))
    done
}
