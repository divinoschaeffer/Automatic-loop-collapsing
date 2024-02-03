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
    if [[ "$masque" =~ [m\&] ]]; then
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
        # if [[ "$masque" =~ [m\&] ]]; then
        #     echo "$(echo "${ehrhart[x$cpt]};" | "$MPC")"
        #     echo " "
        #     echo "    return mpc_result;"
        # else
        echo "    return $(echo "${ehrhart[x$cpt]};" | "$M2Cint");"
        # fi
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
        # if [[ "$masque" =~ [m\&] ]]; then
        #     echo "$(echo "${RS[x$cpt]};" | "$MPC")"
        #     echo " "
        #     echo "    return mpc_result;"
        # else
        echo "    return $(echo "${RS[x$cpt]};" | "$M2Cint");"
        # fi
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
            # if [[ "$masque" =~ [m\&] ]]; then
            #     echo "$(echo "${pcmin[x${cpt}${npc}]};" | "$MPC")"
            #     echo " "
            #     echo "    return mpc_result;"
            # else
            echo "    return $(echo "${pcmin[x${cpt}${npc}]};" | "$M2Cint");"
            # fi
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
            # if [[ "$masque" =~ [m\&] ]]; then
            #     echo "$(echo "${pcmax[x$cpt$npc]};" | "$MPC")"
            #     echo " "
            #     echo "    return mpc_result;"
            # else
            echo "    return $(echo "${pcmax[x$cpt$npc]};" | "$M2Cint");"
            # fi
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

    if [[ "$masque" =~ [dDgGp\&] ]]; then
        # extraction des bornes inf et sup pour chaque indice à l'aide de codegen et sed --> lbound[$CVAR$dim], ubound[$CVAR$dim]

        code=$(echo "D:=$D;codegen ({[${listevar[$CVAR]}]->[${listevar[$CVAR]}]}*D);" | iscc --no-barvinok-isl-ast-build-allow-else)

        if [ "${code:0:2}" = "if" ]; then
            ignore_first_line=1
        else
            ignore_first_line=0
        fi

        typeset -A lbound ubound
        for (( dim = 1; dim <= $N; dim++ )); do
            var="${VAR[${CVAR}${dim}]}"

            lbound[$CVAR$dim]=$(echo "$code" | sed -n "$((dim+ignore_first_line))p" | sed "s/ *for (int .* = *\(.*\);.*;.*)/\1/")
            ubound[$CVAR$dim]=$(echo "$code" | sed -n "$((dim+ignore_first_line))p" | sed "s/ *for (.*; .* < \(.*\);.*)/\1/" | sed "s/ *for (.*; .* <= \(.*\);.*)/\1+1/")

            for (( d = 1; d < $dim; d++ )); do
                v="${VAR[${CVAR}${d}]}"
                lbound[$CVAR$dim]=$(echo "${lbound[$CVAR$dim]}" | sed "s/\([^a-zA-Z0-9]\|^\)c$((d - 1))\([^(a-zA-Z0-9]\|$\)/\1$v\2/g")
                ubound[$CVAR$dim]=$(echo "${ubound[$CVAR$dim]}" | sed "s/\([^a-zA-Z0-9]\|^\)c$((d - 1))\([^(a-zA-Z0-9]\|$\)/\1$v\2/g")
            done
        done
    fi

    dim=1
    for var in ${VAR[*]}; do
        # variables in VAR[*] are not in the correct order. Below is a hack (does it always work?)
        var="${VAR[${CVAR}${dim}]}"

        echo "/******************************** trahrhe_$var ********************************/"
        if [[ "${masque:$((dim - 1)):1}" =~ [DG] ]]; then
            echo "long int trahrhe_${var}_last_pc = -1;"
            for (( d = 1; d < $dim; d++ )); do
                v="${VAR[$CVAR$d]}"
                echo "long int trahrhe_${var}_last_${v};"
            done
            params=$(echo "${Params[x]}" | sed 's/ //g')
            IFS=","
            for param in $params
            do
                echo "long int trahrhe_${var}_last_$param;"
            done
            echo "long int trahrhe_${var}_last_$var;"
            echo ""
        fi

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

        if [[ "${masque:$((dim - 1)):1}" =~ [dDgGp\&] ]]; then
            ### Générer la chaîne de caractères pour l'appel à Ranking :        ###
            ### "Ranking(m, lexmin_j(m), lexmin_k(m,lexmin_j(m)), ..., PARAMS)" ###
            typeset -A ranking_call_str
            for v in m "$var" "$var+1"; do
                ranking_call_str[$v]="Ranking("
                if (( dim > 1 )); then
                    ranking_call_str[$v]+="${listevar1[${CVAR}11$((dim - 1))]}, "
                fi
                ranking_call_str[$v]+="$v"
                for (( d = $((dim+1)); d <= $N; d++ )); do
                    # Il ne suffit pas de remplacer la d-ième variable par sa borne inf,
                    # car celle-ci peut dépendre de variables d'ordre plus grand que dim.
                    # Pour cette raison, on remplace la d-ième variable par sa borne inf,
                    # puis dans l'expression résultante on remplace la (d-1)-ième variable
                    # par sa borne inf, etc., jusqu'à ce que la d-ième variable ne dépende plus
                    # que de variables d'ordre au plus dim.
                    expr="${lbound[$CVAR$d]}"
                    for (( d2 = $((d - 1)); d2 >= $((dim + 1)); d2-- )); do
                        expr=$(echo "$expr" | sed "s/\([^a-zA-Z0-9]\|^\)${VAR[$CVAR$d2]}\([^(a-zA-Z0-9]\|$\)/\1${lbound[$CVAR$d2]}\2/g")
                    done
                    # Enfin, on remplace $var (la variable d'ordre dim) par $v.
                    expr=$(echo "$expr" | sed "s/\([^a-zA-Z0-9]\|^\)$var\([^(a-zA-Z0-9]\|$\)/\1$v\2/g")
                    ranking_call_str[$v]+=", $expr"
                done
                if (echo "${Params[x]}" | grep -q "NOT_A_PARAMETER"); then
                    # Aucun paramètre
                    ranking_call_str[$v]+=")"
                else
                    # Au moins un paramètre
                    ranking_call_str[$v]+=", ${Params[x]})"
                fi
            done
        fi

        if [[ "${masque:$((dim - 1)):1}" =~ [dD] ]]; then
            ### Méthode dichotomique ###
            if [ "${masque:$((dim - 1)):1}" = "D" ]; then
                condition="pc > trahrhe_${var}_last_pc && trahrhe_${var}_last_pc != -1"
                for (( d = 1; d < $dim; d++ )); do
                    v="${VAR[$CVAR$d]}"
                    condition+=" && $v == trahrhe_${var}_last_$v"
                done
                for param in $params
                do
                    condition+=" && $param == trahrhe_${var}_last_$param"
                done
                echo "  long int $var;"
                echo "  if ($condition)"
                echo "    $var = trahrhe_${var}_last_${var};"
                echo "  else"
                echo "    $var = ${lbound[$CVAR$dim]};"
            else
                echo "  long int $var = ${lbound[$CVAR$dim]};"
            fi
            echo "  long int upper_bound = ${ubound[$CVAR$dim]};"
            echo "  long int m;"
            echo ""
            echo "  while ($var+1 < upper_bound) {"
            echo "    m = ($var + upper_bound)/2;"
            echo "    if (${ranking_call_str[m]} <= pc)"
            echo "      $var = m;"
            echo "    else"
            echo "      upper_bound = m;"
            echo "  }"
            echo ""
            if [ "${masque:$((dim - 1)):1}" = "D" ]; then
                echo "  trahrhe_${var}_last_pc = pc;"
                for (( d = 1; d < $dim; d++ )); do
                    v="${VAR[$CVAR$d]}"
                    echo "  trahrhe_${var}_last_$v = $v;"
                done
                for param in $params
                do
                    echo "  trahrhe_${var}_last_$param = $param;"
                done
                echo "  trahrhe_${var}_last_$var = $var;"
                echo ""
            fi
            echo "  return $var;"
        else
            ### Résolution directe ###
            if [[ "${masque:$((dim - 1)):1}" =~ [p\&] ]]; then
                # Code pour régler les problèmes de précision
                code_precision=""; code_precision+=$'\n'
                code_precision+="  long int depart=$var;"; code_precision+=$'\n'
                code_precision+="  if ($var<${lbound[$CVAR$dim]}) $var=${lbound[$CVAR$dim]};"; code_precision+=$'\n'
                code_precision+="  if ($var>${ubound[$CVAR$dim]}-1) $var=${ubound[$CVAR$dim]}-1;"; code_precision+=$'\n'
                code_precision+="  while ($var>${lbound[$CVAR$dim]} && ${ranking_call_str[$var]} > pc) $var--;"; code_precision+=$'\n'
                code_precision+="  while ($var<${ubound[$CVAR$dim]}-1 && ${ranking_call_str[$var+1]} <= pc) $var++;"; code_precision+=$'\n'
                code_precision+="  // if (depart!=$var) fprintf(stderr,\"********************** DIFF ****************************** depart= %ld ** $var=%ld\\n\", depart, $var);  "; code_precision+=$'\n'
                code_precision+=$'\n'
            else
                code_precision=""
            fi
            # Calcul de $var
            cpt=1
            while ((cpt <= nsol[x])); do

                if ((VarPeriodic[x${cpt}${var}] == 1)); then
                    for ((Period = 1; $((NPeriod[x${cpt}] + 1)) - ${Period}; Period++)); do

                        if ((NPCMININT[x${cpt}${Period}${dim}] == 1)); then
                            if (((dim < N) && (Period == 1))); then
                                trans=$(echo "${dlexminint[x${cpt}${Period}${dim}1]}" | sed 's/\(.*{.*\)\(\[.*\]\)\(.*\)/\2->\1\3/')
                                trans=$(echo "$trans" | sed "s/\(\[.*\), *$var\(.*\]\)/\1\2/" | sed "s/\(.*\)\(:.*\)/\1\[$var\]\2/")
                                # PB si pas de if
                                trans=$(echo "codegen ({[$var]->[$var]}*$trans);" | iscc)
                                if (echo $trans | grep -q "if "); then
                                    trans=$(echo "$trans" | sed -n "1p" | sed "s/if (\(.*\))$/\1/" | sed "s/\&\&/and/g" | sed "s/||/or/g" | sed "s/==/=/g")
                                    condition=$(echo "${trans};" | "$D2C")
                                    echo " "
                                    if (echo "${Params[x]}" | grep -q "NOT_A_PARAMETER"); then
                                        echo "  if ( $condition && (PCMin_$cpt() <= pc) && (pc <= PCMax_$cpt()) ) {"
                                    else
                                        echo "  if ( $condition && (PCMin_$cpt(${Params[x]}) <= pc) && (pc <= PCMax_$cpt(${Params[x]})) ) {"
                                    fi
                                else
                                    echo " "
                                    if (echo "${Params[x]}" | grep -q "NOT_A_PARAMETER"); then
                                        echo "  if ( (PCMin_$cpt() <= pc) && (pc <= PCMax_$cpt()) ) {"
                                    else
                                        echo "  if ( (PCMin_$cpt(${Params[x]}) <= pc) && (pc <= PCMax_$cpt(${Params[x]})) ) {"
                                    fi
                                fi
                                echo " "
                                echo "    long int $var[${NPeriod[x${cpt}]}], rank[${NPeriod[x${cpt}]}];"
                                echo "    int MaxPC=0;"
                                echo " "
                            else
                                if ((Period == 1)); then
                                    trans=$(echo "${DSA[VxN${cpt}P${Period}]}" | sed 's/\(.*\[.*\)\(\].*\[\)\(.*\)\(\].*\)/\1,\3\2\3\4/')
                                    trans=$(echo "$trans" | sed "s/\(.*\[.*\), *$var\(.*\].*\[.*\].*\)/\1\2/" | sed "s/.*\(\[.*\].*\)\[.*\]\(.*\)/\1\[$var\]\2/")
                                    trans=$(echo "codegen ({[$var]->[$var]}*$trans);" | iscc)
                                    if (echo $trans | grep -q "if "); then
                                        trans=$(echo "$trans" | sed -n "1p" | sed "s/if (\(.*\))$/\1/" | sed "s/\&\&/and/g" | sed "s/||/or/g" | sed "s/==/=/g")
                                        condition=$(echo "${trans};" | "$D2C")
                                        echo " "
                                        if (echo "${Params[x]}" | grep -q "NOT_A_PARAMETER"); then
                                            echo "  if ( $condition && (PCMin_$cpt() <= pc) && (pc <= PCMax_$cpt()) ) {"
                                        else
                                            echo "  if ( $condition && (PCMin_$cpt(${Params[x]}) <= pc) && (pc <= PCMax_$cpt(${Params[x]})) ) {"
                                        fi
                                    else
                                        echo " "
                                        if (echo "${Params[x]}" | grep -q "NOT_A_PARAMETER"); then
                                            echo "  if ( (PCMin_$cpt() <= pc) && (pc <= PCMax_$cpt()) ) {"
                                        else
                                            echo "  if ( (PCMin_$cpt(${Params[x]}) <= pc) && (pc <= PCMax_$cpt(${Params[x]})) ) {"
                                        fi
                                    fi
                                    echo " "
                                    echo "    long int $var[${NPeriod[x${cpt}]}], rank[${NPeriod[x${cpt}]}];"
                                    echo "    int MaxPC=0;"
                                    echo " "
                                fi
                            fi
                            if [[ "${masque:$((dim - 1)):1}" =~ [m\&] ]]; then
                                echo "{"
                                echo "$(echo "${trahrhe[x${cpt}${Period}${dim}1]};" | "$MPC")"
                                echo "    $var[$((${Period} - 1))] = mpc_result;"
                                echo "}"
                            else
                                echo "    $var[$((${Period} - 1))] = $(echo "${trahrhe[x${cpt}${Period}${dim}1]};" | "$M2Cfloat");"
                            fi

                        else # NPCMININT[${cpt}${Period}${dim}] != 1
                            (echo >&2 "FATAL ERROR: multiple lexmins/trahrhe expressions with periods! => can be fixed")
                            exit 1
                        fi
                    done # for ((Period=1 ; $(( NPeriod[${cpt}]+1 )) - ${Period} ; Period++))

                    echo "    for (int i=0; i<${NPeriod[$CVAR$cpt]}; i++) {"

                    for ((Period = 1; $((NPeriod[x${cpt}] + 1)) - ${Period}; Period++)); do
                        if ((dim < N)); then
                            condition=$(echo "${dlexminint[x${cpt}${Period}${dim}1]}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
                        else
                            condition=$(echo "${DSA[VxN${cpt}P${Period}]}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
                        fi
                        condition=$(echo "${condition};" | "$D2C")
                        condition=$(echo "${condition}" | sed "s/${var}/${var}\[i\]/g")
                        if ((Period == 1)); then
                            echo -n "      if "
                        else
                            echo -n "      else if "
                        fi
                        echo "${condition}"
                        if ((dim < N)); then
                            cible=$(echo "${vlexminint[x${cpt}${Period}${dim}1]}" | sed "s/${var}/${var}\[i\]/g")
                        else
                            cible="${listevar1[x11$((dim - 1))]},$var[i]"
                        fi
                        if (echo "${Params[x]}" | grep -q "NOT_A_PARAMETER"); then
                            echo "        rank[i] = Ranking(${cible});"
                        else
                            echo "        rank[i] = Ranking(${cible},${Params[x]});"
                        fi

                    done # for ((Period=1 ; $(( NPeriod[${cpt}]+1 )) - ${Period} ; Period++))
                    echo "      else rank[i]=-1;"
                    echo "    }"

                    #new return
                    echo "    for (int i=1; i<${NPeriod[x${cpt}]}; i++) {"
                    echo "      if ((rank[i]<=pc) && (rank[i]>=rank[MaxPC])) MaxPC=i;"
                    echo "    }"
                    echo -n "$code_precision"
                    echo "    return ${var}[MaxPC];"
                    echo "  }"
                else # not VarPeriodic
                    for ((Period = 1; $((NPeriod[x${cpt}] + 1)) - ${Period}; Period++)); do

                        if ((NPCMININT[x${cpt}${Period}${dim}] == 1)); then
                            if ((dim < N)); then
                                trans=$(echo "${dlexminint[x${cpt}${Period}${dim}1]}" | sed 's/\(.*{.*\)\(\[.*\]\)\(.*\)/\2->\1\3/')
                                trans=$(echo "$trans" | sed "s/\(\[.*\), *$var\(.*\]\)/\1\2/" | sed "s/\(.*\)\(:.*\)/\1\[$var\]\2/")
                                # PB si pas de if
                                trans=$(echo "codegen ({[$var]->[$var]}*$trans);" | iscc)
                                if (echo "$trans" | grep -q "if "); then
                                    trans=$(echo "$trans" | sed -n "1p" | sed "s/if (\(.*\))$/\1/" | sed "s/\&\&/and/g" | sed "s/||/or/g" | sed "s/==/=/g")
                                    condition=$(echo "${trans};" | "$D2C")
                                    echo " "
                                    if (echo "${Params[x]}" | grep -q "NOT_A_PARAMETER"); then
                                        echo "  if ( $condition && (PCMin_$cpt() <= pc) && (pc <= PCMax_$cpt()) ) {"
                                    else
                                        echo "  if ( $condition && (PCMin_$cpt(${Params[x]}) <= pc) && (pc <= PCMax_$cpt(${Params[x]})) ) {"
                                    fi
                                else
                                    echo " "
                                    if (echo "${Params[x]}" | grep -q "NOT_A_PARAMETER"); then
                                        echo "  if ( (PCMin_$cpt() <= pc) && (pc <= PCMax_$cpt()) ) {"
                                    else
                                        echo "  if ( (PCMin_$cpt(${Params[x]}) <= pc) && (pc <= PCMax_$cpt(${Params[x]})) ) {"
                                    fi
                                fi
                            else
                                trans=$(echo "${DSA[VxN${cpt}P${Period}]}" | sed 's/\(.*\[.*\)\(\].*\[\)\(.*\)\(\].*\)/\1,\3\2\3\4/')
                                trans=$(echo "$trans" | sed "s/\(.*\[.*\), *$var\(.*\].*\[.*\].*\)/\1\2/" | sed "s/.*\(\[.*\].*\)\[.*\]\(.*\)/\1\[$var\]\2/")
                                trans=$(echo "codegen ({[$var]->[$var]}*$trans);" | iscc)
                                if (echo "$trans" | grep -q "if "); then
                                    trans=$(echo "$trans" | sed -n "1p" | sed "s/if (\(.*\))$/\1/" | sed "s/\&\&/and/g" | sed "s/||/or/g" | sed "s/==/=/g")
                                    condition=$(echo "${trans};" | "$D2C")
                                    echo " "
                                    if (echo "${Params[x]}" | grep -q "NOT_A_PARAMETER"); then
                                        echo "  if ( $condition && (PCMin_$cpt() <= pc) && (pc <= PCMax_$cpt()) ) {"
                                    else
                                        echo "  if ( $condition && (PCMin_$cpt(${Params[x]}) <= pc) && (pc <= PCMax_$cpt(${Params[x]})) ) {"
                                    fi
                                else
                                    echo " "
                                    if (echo "${Params[x]}" | grep -q "NOT_A_PARAMETER"); then
                                    echo "  if ( (PCMin_$cpt() <= pc) && (pc <= PCMax_$cpt()) ) {"
                                    else
                                    echo "  if ( (PCMin_$cpt(${Params[x]}) <= pc) && (pc <= PCMax_$cpt(${Params[x]})) ) {"
                                    fi
                                fi
                            fi
                            if ((dim < N)); then
                                condition=$(echo "${dlexminint[x${cpt}${Period}${dim}1]}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
                                condition=$(echo "${condition};" | "$D2C")
                            else
                                condition=$(echo "${DSA[VxN${cpt}P${Period}]}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
                                condition=$(echo "${condition};" | "$D2C")
                            fi
                            echo " "
                            if [[ "${masque:$((dim - 1)):1}" =~ [m\&] ]]; then
                                echo "  long int $var;"
                                echo "{"
                                echo "$(echo "${trahrhe[x${cpt}${Period}${dim}1]};" | "$MPC")"
                                echo "  $var = mpc_result;"
                                echo "}"
                            else
                                echo "  long int $var = $(echo "${trahrhe[x${cpt}${Period}${dim}1]};" | "$M2Cfloat");"
                            fi
                            echo -n "$code_precision"
                            echo "  if $condition {"
                            echo "    return $var;"
                            echo "  }"
                            echo "  }"
                        else
                            nmin=1
                            while ((nmin <= NPCMININT[x${cpt}${Period}${dim}])); do
                                if ((dim < N)); then
                                    trans=$(echo "${dlexminint[x${cpt}${Period}${dim}${nmin}]}" | sed 's/\(.*{.*\)\(\[.*\]\)\(.*\)/\2->\1\3/')
                                    trans=$(echo "$trans" | sed "s/\(\[.*\), *$var\(.*\]\)/\1\2/" | sed "s/\(.*\)\(:.*\)/\1\[$var\]\2/")
                                    trans=$(echo "codegen ({[$var]->[$var]}*$trans);" | iscc)
                                    if (echo $trans | grep -q "if "); then
                                        trans=$(echo "$trans" | sed -n "1p" | sed "s/if (\(.*\))$/\1/" | sed "s/\&\&/and/g" | sed "s/||/or/g" | sed "s/==/=/g")
                                        condition=$(echo "${trans};" | "$D2C")
                                        echo " "
                                        if (echo "${Params[x]}" | grep -q "NOT_A_PARAMETER"); then
                                            echo "  if ( $condition && (PCMin_$cpt() <= pc) && (pc <= PCMax_$cpt()) ) {"
                                        else
                                            echo "  if ( $condition && (PCMin_$cpt(${Params[x]}) <= pc) && (pc <= PCMax_$cpt(${Params[x]})) ) {"
                                        fi
                                    else
                                        echo " "
                                        if (echo "${Params[x]}" | grep -q "NOT_A_PARAMETER"); then
                                            echo "  if ( (PCMin_$cpt() <= pc) && (pc <= PCMax_$cpt()) ) {"
                                        else
                                            echo "  if ( (PCMin_$cpt(${Params[x]}) <= pc) && (pc <= PCMax_$cpt(${Params[x]})) ) {"
                                        fi
                                    fi
                                else
                                    trans=$(echo "${DSA[VxN${cpt}P${Period}]}" | sed 's/\(.*\[.*\)\(\].*\[\)\(.*\)\(\].*\)/\1,\3\2\3\4/')
                                    trans=$(echo "$trans" | sed "s/\(.*\[.*\), *$var\(.*\].*\[.*\].*\)/\1\2/" | sed "s/.*\(\[.*\].*\)\[.*\]\(.*\)/\1\[$var\]\2/")
                                    trans=$(echo "codegen ({[$var]->[$var]}*$trans);" | iscc)
                                    if (echo $trans | grep -q "if "); then
                                        trans=$(echo "$trans" | sed -n "1p" | sed "s/if (\(.*\))$/\1/" | sed "s/\&\&/and/g" | sed "s/||/or/g" | sed "s/==/=/g")
                                        condition=$(echo "${trans};" | "$D2C")
                                        echo " "
                                        if (echo "${Params[x]}" | grep -q "NOT_A_PARAMETER"); then
                                            echo "  if ( $condition && (PCMin_$cpt() <= pc) && (pc <= PCMax_$cpt()) ) {"
                                        else
                                            echo "  if ( $condition && (PCMin_$cpt(${Params[x]}) <= pc) && (pc <= PCMax_$cpt(${Params[x]})) ) {"
                                        fi
                                    else
                                        echo " "
                                        if (echo "${Params[x]}" | grep -q "NOT_A_PARAMETER"); then
                                            echo "  if ( (PCMin_$cpt() <= pc) && (pc <= PCMax_$cpt()) ) {"
                                        else
                                            echo "  if ( (PCMin_$cpt(${Params[x]}) <= pc) && (pc <= PCMax_$cpt(${Params[x]})) ) {"
                                        fi
                                    fi
                                fi
                                if ((dim < N)); then
                                    condition=$(echo "${dlexminint[x${cpt}${Period}${dim}${nmin}]}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
                                    condition=$(echo "${condition};" | "$D2C")
                                else
                                    condition=$(echo "${DSA[VxN${cpt}P${Period}]}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
                                    condition=$(echo "${condition};" | "$D2C")
                                fi
                                echo " "
                                if [[ "${masque:$((dim - 1)):1}" =~ [m\&] ]]; then
                                    echo "  long int $var;"
                                    echo "{"
                                    echo "$(echo "${trahrhe[${cpt}${Period}${dim}${nmin}]};" | "$MPC")"
                                    echo "  $var = mpc_result;"
                                    echo "}"
                                else
                                    echo "  long int $var = $(echo "${trahrhe[x${cpt}${Period}${dim}${nmin}]};" | "$M2Cfloat");"
                                fi
                                echo -n "$code_precision"
                                echo "  if $condition {"
                                echo "    return $var;"
                                echo "  }"
                                echo "  }"
                                ((nmin++))
                            done
                        fi
                    done # for ((Period=1 ; $(( NPeriod[${cpt}]+1 )) - ${Period} ; Period++))
                fi # VarPeriodic
                ((cpt++))
            done
            echo " "
            if ((dim > 1)); then
                if (echo "${Params[x]}" | grep -q "NOT_A_PARAMETER"); then
                    echo "  fprintf(stderr,\"Error trahrhe_$var: no corresponding domain: (pc, ${listevar1[x11$((dim - 1))]}) = (%ld,$format)\\n\",pc,${listevar1[x11$((dim - 1))]});"
                else
                    echo "  fprintf(stderr,\"Error trahrhe_$var: no corresponding domain: (pc, ${listevar1[x11$((dim - 1))]}, ${Params[x]}) = (%ld,$format)\\n\",pc,${listevar1[x11$((dim - 1))]},${Params[x]});"
                fi
            else
                if (echo "${Params[x]}" | grep -q "NOT_A_PARAMETER"); then
                    echo "  fprintf(stderr,\"Error trahrhe_$var: no corresponding domain: (pc) = (%ld)\\n\",pc);"
                else
                    echo "  fprintf(stderr,\"Error trahrhe_$var: no corresponding domain: (pc, ${Params[x]}) = (%ld,$format)\\n\",pc,${Params[x]});"
                fi
            fi
            echo "  exit(1);"
        fi

        echo "} /* end trahrhe_$var */"
        echo " "
        ((dim++))
    done
    exec >&3
}
