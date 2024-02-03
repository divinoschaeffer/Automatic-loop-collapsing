#===--- trahrhe_generate_tiling_header.sh --------------------------------===#
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

generate_tiling_header() {

    #dépend de la profondeur de tiling tprof
    typeset tprof npc CVAR

    tprof="$1"

    typeset cpt var parms vars dim nmin lvar ignore_first_line

    exec 3>&1
    exec >"trahrhe_tiling_header.h"

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

    echo "/******************************** TILEMIN ********************************/"
    parms=$(echo "${Params[${NAME[1]}]}" | sed 's/\([A-Za-z_][A-Za-z_0-9]*\)/long int \1/g')
    if (echo "$parms" | grep -v -q "NOT_A_PARAMETER"); then
        echo "static inline long int TILEMIN(${parms}) {"
    else
        echo "static inline long int TILEMIN() {"
    fi
    echo "  long int TMIN=0,TMP;"
    ListeTileMin=""
    cpt=1
    while ((cpt <= ${nsol[${NAME[1]}]})); do
        nmax=1
        while ((nmax <= ${ntilemax})); do
            IFS=","
            for LMAX in ${TILEMAX[${cpt}${nmax}]}; do # si ub/iscc donne un max de plusieurs argts
                expression="$LMAX"
                MinLong
                LMAX="$expression"
                ListeTileMin="${ListeTileMin}, ${LMAX}"
                # if [[ "$masque" =~ [m\&] ]]; then
                #     echo "{"
                #     echo "$(echo "$LMAX;" | "$MPC")"
                #     echo " "
                #     echo "  if (mpc_result > TMIN) TMIN=mpc_result;"
                #     echo "} "
                # else
                echo "  TMP=$(echo "$LMAX;" | "$M2Cint");"
                echo "  if (TMP > TMIN) TMIN=TMP;"
                echo " "
                # fi
            done
            ((nmax++))
        done
        ((cpt++))
    done
    ListeTileMin=$(echo "$ListeTileMin" | sed "s/^ *, *//")
    echo " "
    echo "  return TMIN+1;"
    echo "} /* end TILEMIN */"
    echo " "
    nheader=1
    while ((nheader <= tprof)); do
        CVAR="${NAME[$nheader]}" #nom de la variable en cours
        parms=$(echo "${Params[${CVAR}]}" | sed 's/\([A-Za-z_][A-Za-z_0-9]*\)/long int \1/g')
        vars=$(echo "${listevar[${CVAR}]}" | sed 's/\([A-Za-z_][A-Za-z_0-9]*\)/long int \1/g')
        echo "/******************************** ${CVAR} Ehrhart Polynomials ********************************/"
        if (echo "$parms" | grep -v -q "NOT_A_PARAMETER"); then
          echo "static inline long int ${CVAR}_Ehrhart($parms) {"
        else
          if [[ ${nheader} == 1 ]]; then
            echo "static inline long int ${CVAR}_Ehrhart() {"
          else
            echo "static inline long int ${CVAR}_Ehrhart($parms) {" | sed "s/long int NOT_A_PARAMETER, //"
          fi
        fi
        echo " "
        cpt=1
        while ((cpt <= nehrhart[${CVAR}])); do
            condition=$(echo "${dehrhart[${CVAR}${cpt}]}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
            #(>&2 echo "D ${condition};")
            if [[ ${condition} != "" ]]; then
              condition=$(echo "${condition};" | "$D2C")
              echo "  if $condition {"
            fi
            # if [[ "$masque" =~ [m\&] ]]; then
            #     echo "$(echo "${ehrhart[${CVAR}${cpt}]};" | "$MPC")"
            #     echo " "
            #     echo "    return mpc_result;"
            # else
            echo "    return $(echo "${ehrhart[${CVAR}${cpt}]};" | "$M2Cint");"
            # fi
            if [[ ${condition} != "" ]]; then
              echo "  }"
            fi
            ((cpt++))
        done
        IFS=","
        set - ${Params[${CVAR}]}
        nb_parms=$#
        if (echo "${Params[${CVAR}]}" | grep -q "NOT_A_PARAMETER"); then
          (( nb_parms-- ))
        fi
        format="%ld"
        nld=2
        while ((nld <= nb_parms)); do
            format="$format, %ld"
            ((nld++))
        done
        if (echo "${Params[${CVAR}]}" | grep -v -q "NOT_A_PARAMETER"); then
          echo "  fprintf(stderr,\"Error ${CVAR}_Ehrhart: no corresponding domain: (${Params[${CVAR}]}) = ($format)\\n\",${Params[${CVAR}]});"
        else
          if [[ ${nheader} == 1 ]]; then
            echo "  fprintf(stderr,\"Error ${CVAR}_Ehrhart: no corresponding domain\\n\");"
          else
            echo "  fprintf(stderr,\"Error ${CVAR}_Ehrhart: no corresponding domain: (${Params[${CVAR}]}) = ($format)\\n\",${Params[${CVAR}]});" | sed "s/NOT_A_PARAMETER, //g"
          fi
        fi
        echo "  exit(1);"
        echo "}  /* end ${CVAR}_Ehrhart */"
        echo " "
        echo "/******************************** ${CVAR} Ranking Polynomials ********************************/"
        if (echo "$parms" | grep -v -q "NOT_A_PARAMETER"); then
          echo "static inline long int ${CVAR}_Ranking($vars,$parms) {"
        else
          if [[ ${nheader} == 1 ]]; then
            echo "static inline long int ${CVAR}_Ranking($vars) {"
          else
            echo "static inline long int ${CVAR}_Ranking($vars,$parms) {" | sed "s/long int NOT_A_PARAMETER, //g"
          fi
        fi
        echo " "
        cpt=1
        while ((cpt <= nsol[${CVAR}])); do
            condition=$(echo "${DS[${CVAR}${cpt}]}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
            #(>&2 echo "E ${condition};")
            if [[ ${condition} != "" ]]; then
                condition=$(echo "${condition};" | "$D2C")
                echo "  if $condition {"
            fi
            # if [[ "$masque" =~ [m\&] ]]; then
            #     echo "$(echo "${RS[${CVAR}${cpt}]};" | "$MPC")"
            #     echo " "
            #     echo "    return mpc_result;"
            # else
            echo "    return $(echo "${RS[${CVAR}${cpt}]};" | "$M2Cint");"
            # fi
            if [[ ${condition} != "" ]]; then
                echo "  }"
            fi
            ((cpt++))
        done
        IFS=","
        set - $(echo "${listevar[${CVAR}]},${Params[${CVAR}]}")
        nb_parms=$#
        if (echo "${Params[${CVAR}]}" | grep -q "NOT_A_PARAMETER"); then
            (( nb_parms-- ))
        fi
        format="%ld"
        nld=2
        while ((nld <= nb_parms)); do
            format="$format, %ld"
            ((nld++))
        done
        if (echo "${Params[${CVAR}]}" | grep -v -q "NOT_A_PARAMETER"); then
          echo "  fprintf(stderr,\"Error ${CVAR}_Ranking: no corresponding domain: (${listevar[${CVAR}]}, ${Params[${CVAR}]}) = ($format)\\n\",${listevar[${CVAR}]},${Params[${CVAR}]});"
        else
          if [[ ${nheader} == 1 ]]; then
            echo "  fprintf(stderr,\"Error ${CVAR}_Ranking: no corresponding domain: (${listevar[${CVAR}]}) = ($format)\\n\",${listevar[${CVAR}]});"
          else
            echo "  fprintf(stderr,\"Error ${CVAR}_Ranking: no corresponding domain: (${listevar[${CVAR}]}, ${Params[${CVAR}]}) = ($format)\\n\",${listevar[${CVAR}]},${Params[${CVAR}]});" | sed "s/,NOT_A_PARAMETER//g" | sed "s/ NOT_A_PARAMETER,//g"
          fi
        fi
        echo "  exit(1);"
        echo "} /* end ${CVAR}_Ranking */"

# No pcmin/max in case of dichotomy search
if  ! [[ "${m_flag}" = "true" && "${masque:$((${nheader} - 1)):1}" = [Dd] ]]; then

        echo " "
        echo "/******************************** ${CVAR}_PCMin ********************************/"
        cpt=1
        while ((cpt <= nsol[${CVAR}])); do
            echo "/******************************** ${CVAR}_PCMin_$cpt ********************************/"
            if (echo "$parms" | grep -v -q "NOT_A_PARAMETER"); then
              echo "static inline long int ${CVAR}_PCMin_$cpt($parms) {"
            else
              if [[ ${nheader} == 1 ]]; then
                echo "static inline long int ${CVAR}_PCMin_$cpt() {"
              else
                echo "static inline long int ${CVAR}_PCMin_$cpt($parms) {" | sed "s/long int NOT_A_PARAMETER, //g"
              fi
            fi
            npc=1
            while ((npc <= NPCMIN[${CVAR}${cpt}])); do
                condition=$(echo "${dlexmin[${CVAR}${cpt}${npc}]}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
                #(>&2 echo "F D${condition}F;")
                if [[ ${condition} != "  " ]]; then
                    condition=$(echo "${condition};" | "$D2C")
                    echo " "
                    echo "  if $condition {"
                fi
                # if [[ "$masque" =~ [m\&] ]]; then
                #     echo "$(echo "${pcmin[${CVAR}${cpt}${npc}]};" | "$MPC")"
                #     echo " "
                #     echo "    return mpc_result;"
                # else
                #pcmin[${CVAR}${cpt}${npc}]=$(echo "${pcmin[${CVAR}${cpt}${npc}]};" | sed "s/mod(\(.*\),\([1-9][0-9]*\)) *\([+*\/_]\|$\)/(\1)%(\2) \3/g")
                #DEBUG (>&2 echo "ICIIIIIIII2 ${pcmin[${CVAR}${cpt}${npc}]};")
                #DEBUG (>&2 echo "    return $(echo "${pcmin[${CVAR}${cpt}${npc}]};" |"$M2C");")
                echo "    return $(echo "${pcmin[${CVAR}${cpt}${npc}]};" | "$M2Cint");"
                # fi
                if [[ ${condition} != "" ]]; then
                  echo "  }"
                fi
                ((npc++))
            done
            if (echo "${Params[${CVAR}]}" | grep -v -q "NOT_A_PARAMETER"); then
              echo "  return ${CVAR}_Ehrhart(${Params[${CVAR}]});"
            else
              if [[ ${nheader} == 1 ]]; then
                echo "  return ${CVAR}_Ehrhart();"
              else
                echo "  return ${CVAR}_Ehrhart(${Params[${CVAR}]});" | sed "s/NOT_A_PARAMETER, //g"
              fi
            fi
            #IFS=","
            #set - ${Params[${CVAR}]}
            #nb_parms=$#
            #format="%ld"
            #nld=2
            #while ((nld <= nb_parms)); do
                #format="$format, %ld"
                #((nld++))
            #done
            #echo "  fprintf(stderr,\"Error ${CVAR}_PCMin_$cpt: domain not corresponding: (${Params[${CVAR}]}) = ($format)\\n\",${Params[${CVAR}]});"
            #echo "  exit(1);"
            echo "} /* end ${CVAR}_PCMin_$cpt */"
            echo " "
            ((cpt++))
        done
        echo "/******************************** ${CVAR}_PCMax ********************************/"

        cpt=1
        while ((cpt <= nsol[${CVAR}])); do
            echo "/******************************** ${CVAR}_PCMax_$cpt ********************************/"
            if (echo "$parms" | grep -v -q "NOT_A_PARAMETER"); then
              echo "static inline long int ${CVAR}_PCMax_$cpt($parms) {"
            else
              if [[ ${nheader} == 1 ]]; then
                echo "static inline long int ${CVAR}_PCMax_$cpt() {"
              else
                echo "static inline long int ${CVAR}_PCMax_$cpt($parms) {" | sed "s/long int NOT_A_PARAMETER, //g"
              fi
            fi
            npc=1
            while ((npc <= NPCMAX[${CVAR}${cpt}])); do
                condition=$(echo "${dlexmax[${CVAR}${cpt}${npc}]}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
                #(>&2 echo "G ${condition};")
                if [[ ${condition} != "  " ]]; then
                    condition=$(echo "${condition};" | "$D2C")
                    echo " "
                    echo "  if $condition {"
                fi
                # if [[ "$masque" =~ [m\&] ]]; then
                #     echo "$(echo "${pcmax[${CVAR}${cpt}${npc}]};" | "$MPC")"
                #     echo " "
                #     echo "    return mpc_result;"
                # else
                echo "    return $(echo "${pcmax[${CVAR}${cpt}${npc}]};" | "$M2Cint");"
                # fi
                if [[ ${condition} != "" ]]; then
                    echo "  }"
                fi
                ((npc++))
            done
            echo "  return 0;"
            #echo "  fprintf(stderr,\"Error ${CVAR}_PCMax_$cpt: domain not corresponding: (${Params[${CVAR}]}) = ($format)\\n\",${Params[${CVAR}]});"
            #echo "  exit(1);"
            echo "} /* end ${CVAR}_PCMax_$cpt */"
            echo " "
            ((cpt++))
        done
        
fi # en of No pcmin/max in case of dichotomy search        
        
        lvar=""
        cpt=1
        while ((cpt <= N)); do
            lvar="${lvar} ${VAR[${CVAR}${cpt}]}"
            ((cpt++))
        done
        IFS=$OLDIFS

        if [[ "$masque" =~ [dDgGp\&] ]]; then
            # extraction des bornes inf et sup pour chaque indice à l'aide de codegen et sed --> lbound[dim], ubound[dim]

            code=$(echo "D:=${lD[$CVAR]};codegen ({[${listevar[$CVAR]}]->[${listevar[$CVAR]}]}*D);" | iscc --no-barvinok-isl-ast-build-allow-else)

            if [ "${code:0:2}" = "if" ]; then
                ignore_first_line=1
            else
                ignore_first_line=0
            fi

            typeset -A lbound ubound
            for (( dim = 1; dim <= $N; dim++ )); do
                var="${VAR[$CVAR$dim]}"

                lbound[$CVAR$dim]=$(echo "$code" | sed -n "$((dim+ignore_first_line))p" | sed "s/ *for (int .* = *\(.*\);.*;.*)/\1/")
                ubound[$CVAR$dim]=$(echo "$code" | sed -n "$((dim+ignore_first_line))p" | sed "s/ *for (.*; .* < \(.*\);.*)/\1/" | sed "s/ *for (.*; .* <= \(.*\);.*)/\1+1/")

                for (( d = 1; d < $dim; d++ )); do
                    v="${VAR[$CVAR$d]}"
                    lbound[$CVAR$dim]=$(echo "${lbound[$CVAR$dim]}" | sed "s/\([^a-zA-Z0-9]\|^\)c$((d - 1))\([^(a-zA-Z0-9]\|$\)/\1$v\2/g")
                    ubound[$CVAR$dim]=$(echo "${ubound[$CVAR$dim]}" | sed "s/\([^a-zA-Z0-9]\|^\)c$((d - 1))\([^(a-zA-Z0-9]\|$\)/\1$v\2/g")
                done
            done
        fi

        dim=1
        for var in $lvar; do
            echo "/******************************** ${CVAR}_trahrhe_$var ********************************/"
            if [[ "${masque:$((nheader - 1)):1}" =~ [DG] ]]; then
                echo "long int ${CVAR}_trahrhe_${var}_last_pc = -1;"
                for (( d = 1; d < $dim; d++ )); do
                    v="${VAR[$CVAR$d]}"
                    echo "long int ${CVAR}_trahrhe_${var}_last_${v};"
                done
                parametres=$(echo "${Params[$CVAR]}" | sed 's/ //g')
                IFS=","
                for param in $parametres
                do
                    echo "long int ${CVAR}_trahrhe_${var}_last_$param;"
                done
                echo "long int ${CVAR}_trahrhe_${var}_last_$var;"
                echo ""
            fi

            vars=$(echo "${listevar1[${CVAR}11$((dim - 1))]}" | sed 's/\([A-Za-z_][A-Za-z_0-9]*\)/long int \1/g')
            parms=$(echo "${Params[${CVAR}]}" | sed 's/\([A-Za-z_][A-Za-z_0-9]*\)/long int \1/g')

            if ((dim > 1)); then
                if (echo "$parms" | grep -v -q "NOT_A_PARAMETER"); then
                  echo "static inline long int ${CVAR}_trahrhe_$var(long int pc, $vars, $parms) {"
                else
                  if [[ ${nheader} == 1 ]]; then
                    echo "static inline long int ${CVAR}_trahrhe_$var(long int pc, $vars) {"
                  else
                    echo "static inline long int ${CVAR}_trahrhe_$var(long int pc, $vars, $parms) {" | sed "s/long int NOT_A_PARAMETER, //g"
                  fi
                fi
                IFS=","
                set - $(echo "${listevar1[${CVAR}11$((dim - 1))]},${Params[${CVAR}]}")
                nb_parms=$#
                if (echo "${Params[${CVAR}]}" | grep -q "NOT_A_PARAMETER"); then
                  (( nb_parms-- ))
                fi
                format="%ld"
                nld=2
                while ((nld <= nb_parms)); do
                    format="$format, %ld"
                    ((nld++))
                done
            else
                if (echo "$parms" | grep -v -q "NOT_A_PARAMETER"); then
                  echo "static inline long int ${CVAR}_trahrhe_$var(long int pc, $parms) {"
                else
                  if [[ ${nheader} == 1 ]]; then
                    echo "static inline long int ${CVAR}_trahrhe_$var(long int pc) {"
                  else
                    echo "static inline long int ${CVAR}_trahrhe_$var(long int pc, $parms) {" | sed "s/long int NOT_A_PARAMETER, //g"
                  fi
                fi
                IFS=","
                set - ${Params[${CVAR}]}
                nb_parms=$#
                if (echo "${Params[${CVAR}]}" | grep -q "NOT_A_PARAMETER"); then
                  (( nb_parms-- ))
                fi
                format="%ld"
                nld=2
                while ((nld <= nb_parms)); do
                    format="$format, %ld"
                    ((nld++))
                done
            fi

            if [[ "${masque:$((nheader - 1)):1}" =~ [dDgGp\&] ]]; then
                ### Générer la chaîne de caractères pour l'appel à Ranking :        ###
                ### "Ranking(m, lexmin_j(m), lexmin_k(m,lexmin_j(m)), ..., PARAMS)" ###
                typeset -A ranking_call_str
                for v in m "$var" "$var+1"; do
                    ranking_call_str[$v]="${CVAR}_Ranking("
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
                        ranking_call_str[$v]+=", ${Params[$CVAR]})"
                    fi
                done
            fi

            if [[ "${masque:$((nheader - 1)):1}" =~ [dD] ]]; then
                ### Méthode dichotomique ###
                if [ "${masque:$((nheader - 1)):1}" = "D" ]; then
                    condition="pc > ${CVAR}_trahrhe_${var}_last_pc && ${CVAR}_trahrhe_${var}_last_pc != -1"
                    for (( d = 1; d < $dim; d++ )); do
                        v="${VAR[$CVAR$d]}"
                        condition+=" && $v == ${CVAR}_trahrhe_${var}_last_$v"
                    done
                    for param in $parametres
                    do
                        condition+=" && $param == ${CVAR}_trahrhe_${var}_last_$param"
                    done
                    echo "  long int $var;"
                    echo "  if ($condition)"
                    echo "    $var = ${CVAR}_trahrhe_${var}_last_${var};"
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
                if [ "${masque:$((nheader - 1)):1}" = "D" ]; then
                    echo "  ${CVAR}_trahrhe_${var}_last_pc = pc;"
                    for (( d = 1; d < $dim; d++ )); do
                        v="${VAR[$CVAR$d]}"
                        echo "  ${CVAR}_trahrhe_${var}_last_$v = $v;"
                    done
                    for param in $parametres
                    do
                        echo "  ${CVAR}_trahrhe_${var}_last_$param = $param;"
                    done
                    echo "  ${CVAR}_trahrhe_${var}_last_$var = $var;"
                    echo ""
                fi
                echo "  return $var;"
            else
                ### Résolution directe ###
                if [[ "${masque:$((nheader - 1)):1}" =~ [p\&] ]]; then
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
                while ((cpt <= nsol[${CVAR}])); do

                    if ((VarPeriodic[${CVAR}${cpt}${var}] == 1)); then
                        ##############################################################
                        for ((Period = 1; $((NPeriod[${CVAR}${cpt}] + 1)) - ${Period}; Period++)); do

                            if ((NPCMININT[${CVAR}${cpt}${Period}${dim}] == 1)); then
                                if (((dim < N) && (Period == 1))); then
                                    trans=$(echo "${dlexminint[${CVAR}${cpt}${Period}${dim}1]}" | sed 's/\(.*{.*\)\(\[.*\]\)\(.*\)/\2->\1\3/')
                                    trans=$(echo "$trans" | sed "s/\(\[.*\), *$var\(.*\]\)/\1\2/" | sed "s/\(.*\)\(:.*\)/\1\[$var\]\2/")
                                    trans=$(echo "codegen ({[$var]->[$var]}*$trans);" | iscc)
                                    if (echo $trans | grep -q "if "); then
                                        trans=$(echo "$trans" | sed -n "1s/if (\(.*\))$/\1/p" | tr -d ' ' | sed "s/\&\&/ and /g" | sed "s/||/or/g" | sed "s/==/=/g" | sed "s/\(.*\)/{ : \1 }/")
                                        condition=$(echo "${trans}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
                                        #(>&2 echo "condition0=$condition")
                                        condition=$(echo "${condition};" | "$D2C")
                                        echo " "
                                        if (echo "${Params[${CVAR}]}" | grep -v -q "NOT_A_PARAMETER"); then
                                        echo "  if ( $condition && (${CVAR}_PCMin_$cpt(${Params[${CVAR}]}) <= pc) && (pc <= ${CVAR}_PCMax_$cpt(${Params[${CVAR}]})) ) {"
                                        else
                                        if [[ ${nheader} == 1 ]]; then
                                            echo "  if ( $condition && (${CVAR}_PCMin_$cpt() <= pc) && (pc <= ${CVAR}_PCMax_$cpt()) ) {"
                                        else
                                            echo "  if ( $condition && (${CVAR}_PCMin_$cpt(${Params[${CVAR}]}) <= pc) && (pc <= ${CVAR}_PCMax_$cpt(${Params[${CVAR}]})) ) {" | sed "s/NOT_A_PARAMETER, //g"
                                        fi
                                        fi
                                    else
                                        echo " "
                                        if (echo "${Params[${CVAR}]}" | grep -v -q "NOT_A_PARAMETER"); then
                                        echo "  if ( (${CVAR}_PCMin_$cpt(${Params[${CVAR}]}) <= pc) && (pc <= ${CVAR}_PCMax_$cpt(${Params[${CVAR}]})) ) {"
                                        else
                                        if [[ ${nheader} == 1 ]]; then
                                            echo "  if ( (${CVAR}_PCMin_$cpt() <= pc) && (pc <= ${CVAR}_PCMax_$cpt()) ) {"
                                        else
                                            echo "  if ( (${CVAR}_PCMin_$cpt(${Params[${CVAR}]}) <= pc) && (pc <= ${CVAR}_PCMax_$cpt(${Params[${CVAR}]})) ) {" | sed "s/NOT_A_PARAMETER, //g"
                                        fi
                                        fi
                                    fi
                                    echo " "
                                    echo "    long int $var[${NPeriod[${CVAR}${cpt}]}], rankmin[${NPeriod[${CVAR}${cpt}]}], rankmax[${NPeriod[${CVAR}${cpt}]}];"
                                    echo "    int MaxPC=0;"
                                    echo " "
                                else # (((dim < N) && (Period == 1)))
                                    if ((Period == 1)); then
                                        trans=$(echo "${DSA[V${CVAR}N${cpt}P${Period}]}" | sed 's/\(.*\[.*\)\(\].*\[\)\(.*\)\(\].*\)/\1,\3\2\3\4/')
                                        trans=$(echo "$trans" | sed "s/\(.*\[.*\), *$var\(.*\].*\[.*\].*\)/\1\2/" | sed "s/.*\(\[.*\].*\)\[.*\]\(.*\)/\1\[$var\]\2/")
                                        trans=$(echo "codegen ({[$var]->[$var]}*$trans);" | iscc)
                                        if (echo $trans | grep -q "if "); then
                                            trans=$(echo "$trans" | sed -n "1s/if (\(.*\))$/\1/p" | tr -d ' ' | sed "s/\&\&/ and /g" | sed "s/||/or/g" | sed "s/==/=/g" | sed "s/floord(\([^,]*\),\([^)]*\))/floor((\1)\/(\2))/g" | sed "s/\(.*\)/{ : \1 }/")
                                            condition=$(echo "${trans}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
                                            #(>&2 echo "A ${condition};")
                                            condition=$(echo "${condition};" | "$D2C")
                                            echo " "
                                            if (echo "${Params[${CVAR}]}" | grep -v -q "NOT_A_PARAMETER"); then
                                            echo "  if ( $condition && (${CVAR}_PCMin_$cpt(${Params[${CVAR}]}) <= pc) && (pc <= ${CVAR}_PCMax_$cpt(${Params[${CVAR}]})) ) {"
                                            else
                                            if [[ ${nheader} == 1 ]]; then
                                                echo "  if ( $condition && (${CVAR}_PCMin_$cpt() <= pc) && (pc <= ${CVAR}_PCMax_$cpt()) ) {"
                                            else
                                                echo "  if ( $condition && (${CVAR}_PCMin_$cpt(${Params[${CVAR}]}) <= pc) && (pc <= ${CVAR}_PCMax_$cpt(${Params[${CVAR}]})) ) {" | sed "s/NOT_A_PARAMETER, //g"
                                            fi
                                            fi
                                        else
                                            echo " "
                                            if (echo "${Params[${CVAR}]}" | grep -v -q "NOT_A_PARAMETER"); then
                                            echo "  if ( (${CVAR}_PCMin_$cpt(${Params[${CVAR}]}) <= pc) && (pc <= ${CVAR}_PCMax_$cpt(${Params[${CVAR}]})) ) {"
                                            else
                                            if [[ ${nheader} == 1 ]]; then
                                                echo "  if ( (${CVAR}_PCMin_$cpt() <= pc) && (pc <= ${CVAR}_PCMax_$cpt()) ) {"
                                            else
                                                echo "  if ( (${CVAR}_PCMin_$cpt(${Params[${CVAR}]}) <= pc) && (pc <= ${CVAR}_PCMax_$cpt(${Params[${CVAR}]})) ) {" | sed "s/NOT_A_PARAMETER, //g"
                                            fi
                                            fi
                                        fi
                                        echo " "
                                        echo "    long int $var[${NPeriod[${CVAR}${cpt}]}], rankmin[${NPeriod[${CVAR}${cpt}]}], rankmax[${NPeriod[${CVAR}${cpt}]}];"
                                        echo "    int MaxPC=0;"
                                        echo " "
                                    fi
                                fi
                                if [[ "${masque:$((nheader - 1)):1}" =~ [m\&] ]]; then
                                    echo "{"
                                    echo "$(echo "${trahrhe[${CVAR}${cpt}${Period}${dim}1]};" | "$MPC")"
                                    echo "    $var[$((${Period} - 1))] = mpc_result;"
                                    echo "}"
                                else
                                    echo "    $var[$((${Period} - 1))] = $(echo "${trahrhe[${CVAR}${cpt}${Period}${dim}1]};" | "$M2Cfloat");"
                                fi
                            else # NPCMININT[${cpt}${Period}${dim}] != 1
                                (echo >&2 "FATAL ERROR: multiple lexmins/trahrhe expressions with periods! => can be fixed")
                                exit 1
                            fi
                        done # Period

                        echo "    for (int i=0; i<${NPeriod[$CVAR$cpt]}; i++) {"

                        for ((Period = 1; $((NPeriod[${CVAR}${cpt}] + 1)) - ${Period}; Period++)); do
                            for (( nmin=1; nmin<=NPCMININT[${CVAR}${cpt}${Period}${dim}]; nmin++ )); do
                                if ((dim < N)); then
                                    condition=$(echo "${dlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
                                else
                                    condition=$(echo "${DSA[V${CVAR}N${cpt}P${Period}]}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
                                fi
                                #(>&2 echo "B ${condition};")
                                condition=$(echo "${condition};" | "$D2C")
                                condition=$(echo "${condition}" | sed "s/${var}/${var}\[i\]/g")
                                if (( (Period==1) && (nmin==1) )); then
                                    echo -n "      if "
                                else
                                    echo -n "      else if "
                                fi
                                echo "${condition}"
                                if ((dim < N)); then
                                    cible=$(echo "${vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}" | sed "s/${var}/${var}\[i\]/g")
                                else
                                    cible="${listevar1[${CVAR}11$((dim - 1))]},$var[i]"
                                fi
                                if (echo "${Params[${CVAR}]}" | grep -v -q "NOT_A_PARAMETER"); then
                                echo "        rankmin[i] = ${CVAR}_Ranking(${cible},${Params[${CVAR}]});"
                                else
                                    if [[ ${nheader} == 1 ]]; then
                                        echo "        rankmin[i] = ${CVAR}_Ranking(${cible});"
                                    else
                                        echo "        rankmin[i] = ${CVAR}_Ranking(${cible},${Params[${CVAR}]});" | sed "s/NOT_A_PARAMETER, //g"
                                    fi
                                fi
                            done # for (( nmin = 1; nmin <= NPCMININT[${CVAR}${cpt}${Period}${dim}]; nmin++ ))
                        done # for ((Period=1 ; $(( NPeriod[${cpt}]+1 )) - ${Period} ; Period++))
                        echo "      else rankmin[i]=-1;"
                        echo "    }"


                        echo "    for (int i=0; i<${NPeriod[${CVAR}${cpt}]}; i++) {"
                        for ((Period = 1; $((NPeriod[${CVAR}${cpt}] + 1)) - ${Period}; Period++)); do
                            for (( nmax=1; nmax<=NPCMAXINT[${CVAR}${cpt}${Period}${dim}]; nmax++ )); do
                                if ((dim < N)); then
                                    condition=$(echo "${dlexmaxint[${CVAR}${cpt}${Period}${dim}${nmax}]}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
                                else
                                    condition=$(echo "${DSA[V${CVAR}N${cpt}P${Period}]}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
                                fi
                                #(>&2 echo "C ${condition};")
                                condition=$(echo "${condition};" | "$D2C")
                                condition=$(echo "${condition}" | sed "s/${var}/${var}\[i\]/g")
                                if (( (Period==1) && (nmax==1) )); then
                                    echo -n "      if "
                                else
                                    echo -n "      else if "
                                fi
                                echo "${condition}"
                                if ((dim < N)); then
                                    cible=$(echo "${vlexmaxint[${CVAR}${cpt}${Period}${dim}${nmax}]}" | sed "s/${var}/${var}\[i\]/g")
                                else
                                    cible="${listevar1[${CVAR}11$((dim - 1))]},$var[i]"
                                fi
                                if (echo "${Params[${CVAR}]}" | grep -v -q "NOT_A_PARAMETER"); then
                                echo "        rankmax[i] = ${CVAR}_Ranking(${cible},${Params[${CVAR}]});"
                                else
                                if [[ ${nheader} == 1 ]]; then
                                    echo "        rankmax[i] = ${CVAR}_Ranking(${cible});"
                                else
                                    echo "        rankmax[i] = ${CVAR}_Ranking(${cible},${Params[${CVAR}]});" | sed "s/NOT_A_PARAMETER, //g"
                                fi
                                fi
                            done # for (( nmax=1; nmax<=NPCMININT[${CVAR}${cpt}${Period}${dim}]; nmax++ ))
                        done # for ((Period=1 ; $(( NPeriod[${cpt}]+1 )) - ${Period} ; Period++))
          echo "  long int $var;"
                                    echo "{"
                                    echo "$(echo "${trahrhe[${CVAR}${cpt}${Period}${dim}1]};" | "$MPC");"
                                    echo "  $var = mpc_result;"
                                    echo "}"                        echo "      else rankmax[i]=-1;"
                        echo "    }"

                        #new return
                        echo "    for (int i=0; i<${NPeriod[${CVAR}${cpt}]}; i++) {"
                        echo "      if ((rankmin[i]<=pc) && (pc<=rankmax[i])) MaxPC=i;"
                        echo "    }"
                        echo -n "$code_precision"
                        echo "    return ${var}[MaxPC];"
                        echo "  }"
                        ##############################################################
                    else # not VarPeriodic

                        for ((Period = 1; $((NPeriod[${CVAR}${cpt}] + 1)) - ${Period}; Period++)); do

                            if ((NPCMININT[${CVAR}${cpt}${Period}${dim}] == 1)); then
                                if ((dim < N)); then
                                    #(>&2 echo "dlexminint[${CVAR}${cpt}${Period}${dim}1]=${dlexminint[${CVAR}${cpt}${Period}${dim}1]}")
                                    trans=$(echo "${dlexminint[${CVAR}${cpt}${Period}${dim}1]}" | sed 's/\(.*{.*\)\(\[.*\]\)\(.*\)/\2->\1\3/')
                                    trans=$(echo "$trans" | sed "s/\(\[.*\), *$var\(.*\]\)/\1\2/" | sed "s/\(.*\)\(:.*\)/\1\[$var\]\2/")
                                    trans=$(echo "codegen ({[$var]->[$var]}*$trans);" | iscc)
                                    if (echo $trans | grep -q "if "); then
                                        trans=$(echo "$trans" | sed -n "1s/if (\(.*\))$/\1/p" | tr -d ' ' | sed "s/\&\&/ and /g" | sed "s/||/or/g" | sed "s/==/=/g" | sed "s/floord(\([^,]*\),\([^)]*\))/floor((\1)\/(\2))/g" | sed "s/\(.*\)/{ : \1 }/")
                                        condition=$(echo "${trans}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
                                        #(>&2 echo "condition3=$condition")
                                        condition=$(echo "${condition};" | "$D2C")
                                        echo " "
                                        if (echo "${Params[${CVAR}]}" | grep -v -q "NOT_A_PARAMETER"); then
                                        echo "  if ( $condition && (${CVAR}_PCMin_$cpt(${Params[${CVAR}]}) <= pc) && (pc <= ${CVAR}_PCMax_$cpt(${Params[${CVAR}]})) ) {"
                                        else
                                        if [[ ${nheader} == 1 ]]; then
                                            echo "  if ( $condition && (${CVAR}_PCMin_$cpt() <= pc) && (pc <= ${CVAR}_PCMax_$cpt()) ) {"
                                        else
                                            echo "  if ( $condition && (${CVAR}_PCMin_$cpt(${Params[${CVAR}]}) <= pc) && (pc <= ${CVAR}_PCMax_$cpt(${Params[${CVAR}]})) ) {" | sed "s/NOT_A_PARAMETER, //g"
                                        fi
                                        fi
                                    else
                                        echo " "
                                        if (echo "${Params[${CVAR}]}" | grep -v -q "NOT_A_PARAMETER"); then
                                        echo "  if ( (${CVAR}_PCMin_$cpt(${Params[${CVAR}]}) <= pc) && (pc <= ${CVAR}_PCMax_$cpt(${Params[${CVAR}]})) ) {"
                                        else
                                        if [[ ${nheader} == 1 ]]; then
                                            echo "  if ( (${CVAR}_PCMin_$cpt() <= pc) && (pc <= ${CVAR}_PCMax_$cpt()) ) {"
                                        else
                                            echo "  if ( (${CVAR}_PCMin_$cpt(${Params[${CVAR}]}) <= pc) && (pc <= ${CVAR}_PCMax_$cpt(${Params[${CVAR}]})) ) {" | sed "s/NOT_A_PARAMETER, //g"
                                        fi
                                        fi
                                    fi
                                else
                                    trans=$(echo "${DSA[V${CVAR}N${cpt}P${Period}]}" | sed 's/\(.*\[.*\)\(\].*\[\)\(.*\)\(\].*\)/\1,\3\2\3\4/')
                                    trans=$(echo "$trans" | sed "s/\(.*\[.*\), *$var\(.*\].*\[.*\].*\)/\1\2/" | sed "s/.*\(\[.*\].*\)\[.*\]\(.*\)/\1\[$var\]\2/")
                                    trans=$(echo "codegen ({[$var]->[$var]}*$trans);" | iscc)
                                    if (echo $trans | grep -q "if "); then
                                        trans=$(echo "$trans" | sed -n "1s/if (\(.*\))$/\1/p" | tr -d ' ' | sed "s/\&\&/ and /g" | sed "s/||/or/g" | sed "s/==/=/g" | sed "s/floord(\([^,]*\),\([^)]*\))/floor((\1)\/(\2))/g" | sed "s/\(.*\)/{ : \1 }/")
                                        condition=$(echo "${trans}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
                                        #(>&2 echo "condition4=$condition")
                                        condition=$(echo "${condition};" | "$D2C")
                                        echo " "
                                        if (echo "${Params[${CVAR}]}" | grep -v -q "NOT_A_PARAMETER"); then
                                        echo "  if ( $condition && (${CVAR}_PCMin_$cpt(${Params[${CVAR}]}) <= pc) && (pc <= ${CVAR}_PCMax_$cpt(${Params[${CVAR}]})) ) {"
                                        else
                                        if [[ ${nheader} == 1 ]]; then
                                            echo "  if ( $condition && (${CVAR}_PCMin_$cpt() <= pc) && (pc <= ${CVAR}_PCMax_$cpt()) ) {"
                                        else
                                            echo "  if ( $condition && (${CVAR}_PCMin_$cpt(${Params[${CVAR}]}) <= pc) && (pc <= ${CVAR}_PCMax_$cpt(${Params[${CVAR}]})) ) {" | sed "s/NOT_A_PARAMETER, //g"
                                        fi
                                        fi
                                    else
                                        echo " "
                                        if (echo "${Params[${CVAR}]}" | grep -v -q "NOT_A_PARAMETER"); then
                                        echo "  if ( (${CVAR}_PCMin_$cpt(${Params[${CVAR}]}) <= pc) && (pc <= ${CVAR}_PCMax_$cpt(${Params[${CVAR}]})) ) {"
                                        else
                                        if [[ ${nheader} == 1 ]]; then
                                            echo "  if ( (${CVAR}_PCMin_$cpt() <= pc) && (pc <= ${CVAR}_PCMax_$cpt()) ) {"
                                        else
                                            echo "  if ( (${CVAR}_PCMin_$cpt(${Params[${CVAR}]}) <= pc) && (pc <= ${CVAR}_PCMax_$cpt(${Params[${CVAR}]})) ) {" | sed "s/NOT_A_PARAMETER, //g"
                                        fi
                                        fi
                                    fi
                                fi
                                if ((dim < N)); then
                                    condition=$(echo "${dlexminint[${CVAR}${cpt}${Period}${dim}1]}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
                                    #(>&2 echo "condition5=$condition")
                                    condition=$(echo "${condition};" | "$D2C")
                                else
                                    condition=$(echo "${DSA[V${CVAR}N${cpt}P${Period}]}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
                                    #(>&2 echo "condition6=$condition")
                                    condition=$(echo "${condition};" | sed "s/ mod / % /g" | sed 's/\([ +(-][0-9][0-9]*\)\([A-Z_a-z]\)/\1*\2/g' | "$D2C")
                                fi
                                echo " "
                                #DEBUG (>&2 echo "M2C HERE: ${trahrhe[${CVAR}${cpt}${dim}1]};")
                                if [[ "${masque:$((nheader - 1)):1}" =~ [m\&] ]]; then
                                    echo "  long int $var;"
                                    echo "{"
                                    echo "$(echo "${trahrhe[${CVAR}${cpt}${Period}${dim}1]};" | "$MPC");"
                                    echo "  $var = mpc_result;"
                                    echo "}"
                                else
                                    echo "  long int $var = $(echo "${trahrhe[${CVAR}${cpt}${Period}${dim}1]};" | "$M2Cfloat");"
                                fi
                                echo -n "$code_precision"
                                echo "  if $condition {"
                                echo "    return $var;"
                                echo "  }"
                                echo "  }"
                            else
                                nmin=1
                                while ((nmin <= NPCMININT[${CVAR}${cpt}${Period}${dim}])); do
                                    if ((dim < N)); then
                                        trans=$(echo "${dlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}" | sed 's/\(.*{.*\)\(\[.*\]\)\(.*\)/\2->\1\3/')
                                        trans=$(echo "$trans" | sed "s/\(\[.*\), *$var\(.*\]\)/\1\2/" | sed "s/\(.*\)\(:.*\)/\1\[$var\]\2/")
                                        trans=$(echo "codegen ({[$var]->[$var]}*$trans);" | iscc)
                                        if (echo $trans | grep -q "if "); then
                                            trans=$(echo "$trans" | sed -n "1s/if (\(.*\))$/\1/p" | tr -d ' ' | sed "s/\&\&/ and /g" | sed "s/||/or/g" | sed "s/==/=/g" | sed "s/floord(\([^,]*\),\([^)]*\))/floor((\1)\/(\2))/g" | sed "s/\(.*\)/{ : \1 }/")
                                            condition=$(echo "${trans}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
                                            #(>&2 echo "condition7=$condition")
                                            condition=$(echo "${condition};" | "$D2C")
                                            echo " "
                                            if (echo "${Params[${CVAR}]}" | grep -v -q "NOT_A_PARAMETER"); then
                                            echo "  if ( $condition && (${CVAR}_PCMin_$cpt(${Params[${CVAR}]}) <= pc) && (pc <= ${CVAR}_PCMax_$cpt(${Params[${CVAR}]})) ) {"
                                            else
                                            if [[ ${nheader} == 1 ]]; then
                                                echo "  if ( $condition && (${CVAR}_PCMin_$cpt() <= pc) && (pc <= ${CVAR}_PCMax_$cpt()) ) {"
                                            else
                                                echo "  if ( $condition && (${CVAR}_PCMin_$cpt(${Params[${CVAR}]}) <= pc) && (pc <= ${CVAR}_PCMax_$cpt(${Params[${CVAR}]})) ) {" | sed "s/NOT_A_PARAMETER, //g"
                                            fi
                                            fi
                                        else
                                            echo " "
                                            if (echo "${Params[${CVAR}]}" | grep -v -q "NOT_A_PARAMETER"); then
                                            echo "  if ( (${CVAR}_PCMin_$cpt(${Params[${CVAR}]}) <= pc) && (pc <= ${CVAR}_PCMax_$cpt(${Params[${CVAR}]})) ) {"
                                            else
                                            if [[ ${nheader} == 1 ]]; then
                                                echo "  if ( (${CVAR}_PCMin_$cpt() <= pc) && (pc <= ${CVAR}_PCMax_$cpt()) ) {"
                                            else
                                                echo "  if ( (${CVAR}_PCMin_$cpt(${Params[${CVAR}]}) <= pc) && (pc <= ${CVAR}_PCMax_$cpt(${Params[${CVAR}]})) ) {" | sed "s/NOT_A_PARAMETER, //g"
                                            fi
                                            fi
                                        fi
                                    else
                                        trans=$(echo "${DSA[V${CVAR}N${cpt}P${Period}]}" | sed 's/\(.*\[.*\)\(\].*\[\)\(.*\)\(\].*\)/\1,\3\2\3\4/')
                                        trans=$(echo "$trans" | sed "s/\(.*\[.*\), *$var\(.*\].*\[.*\].*\)/\1\2/" | sed "s/.*\(\[.*\].*\)\[.*\]\(.*\)/\1\[$var\]\2/")
                                        trans=$(echo "codegen ({[$var]->[$var]}*$trans);" | iscc)
                                        if (echo $trans | grep -q "if "); then
                                            trans=$(echo "$trans" | sed -n "1s/if (\(.*\))$/\1/p" | tr -d ' ' | sed "s/\&\&/ and /g" | sed "s/||/or/g" | sed "s/==/=/g" | sed "s/floord(\([^,]*\),\([^)]*\))/floor((\1)\/(\2))/g" | sed "s/\(.*\)/{ : \1 }/")
                                            condition=$(echo "${trans}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
                                            #(>&2 echo "condition8=$condition")
                                            condition=$(echo "${condition};" | "$D2C")
                                            echo " "
                                            if (echo "$Params" | grep -v -q "NOT_A_PARAMETER"); then
                                                echo "  if ( $condition && (${CVAR}_PCMin_$cpt($Params) <= pc) && (pc <= ${CVAR}_PCMax_$cpt($Params)) ) {"
                                            else
                                                if [[ ${nheader} == 1 ]]; then
                                                    echo "  if ( $condition && (${CVAR}_PCMin_$cpt() <= pc) && (pc <= ${CVAR}_PCMax_$cpt()) ) {"
                                                else
                                                    echo "  if ( $condition && (${CVAR}_PCMin_$cpt($Params) <= pc) && (pc <= ${CVAR}_PCMax_$cpt($Params)) ) {" | sed "s/NOT_A_PARAMETER, //g"
                                                fi
                                            fi
                                        else
                                            echo " "
                                            if (echo "$Params" | grep -v -q "NOT_A_PARAMETER"); then
                                                echo "  if ( (${CVAR}_PCMin_$cpt($Params) <= pc) && (pc <= ${CVAR}_PCMax_$cpt($Params)) ) {"
                                            else
                                                if [[ ${nheader} == 1 ]]; then
                                                    echo "  if ( (${CVAR}_PCMin_$cpt() <= pc) && (pc <= ${CVAR}_PCMax_$cpt()) ) {"
                                                else
                                                    echo "  if ( (${CVAR}_PCMin_$cpt($Params) <= pc) && (pc <= ${CVAR}_PCMax_$cpt($Params)) ) {" | sed "s/NOT_A_PARAMETER, //g"
                                                fi
                                            fi
                                        fi
                                    fi
                                    if ((dim < N)); then
                                        condition=$(echo "${dlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
                                        #(>&2 echo "condition9=$condition")
                                        condition=$(echo "${condition};" | "$D2C")
                                    else
                                        condition=$(echo "${DSA[V${CVAR}N${cpt}P${Period}]}" | sed 's/.*:\(.*\)/\1/' | tr -d '}')
                                        #(>&2 echo "condition10=$condition")
                                        condition=$(echo "${condition};" | "$D2C")
                                    fi
                                    echo " "
                                    #DEBUG (>&2 echo "M2C HERE: ${trahrhe[${CVAR}${cpt}${dim}${nmin}]};")
                                    if [[ "${masque:$((nheader - 1)):1}" =~ [m\&] ]]; then
                                        echo "  long int $var;"
                                        echo "{"
                                        echo "$(echo "${trahrhe[${CVAR}${cpt}${Period}${dim}${nmin}]};" | "$MPC");"
                                        echo "  $var = mpc_result;"
                                        echo "}"
                                    else
                                        echo "  long int $var = $(echo "${trahrhe[${CVAR}${cpt}${Period}${dim}${nmin}]};" | "$M2Cfloat");"
                                    fi
                                    echo -n "$code_precision"
                                    echo "  if $condition {"
                                    echo "    return $var;"
                                    echo "  }"
                                    echo "  }"
                                    ((nmin++))
                                done
                            fi
                        done # Period

                    fi # VarPeriodic

                    ((cpt++))
                done
                echo " "
                if ((dim > 1)); then
                    if (echo "${Params[${CVAR}]}" | grep -v -q "NOT_A_PARAMETER"); then
                        echo "  fprintf(stderr,\"Error ${CVAR}_trahrhe_$var: no corresponding domain: (pc, ${listevar1[${CVAR}11$((dim - 1))]}, ${Params[${CVAR}]}) = (%ld,$format)\\n\",pc,${listevar1[${CVAR}11$((dim - 1))]},${Params[${CVAR}]});"
                    else
                        if [[ ${nheader} == 1 ]]; then
                            echo "  fprintf(stderr,\"Error ${CVAR}_trahrhe_$var: no corresponding domain: (pc, ${listevar1[${CVAR}11$((dim - 1))]}) = (%ld,$format)\\n\",pc,${listevar1[${CVAR}11$((dim - 1))]});"
                        else
                            echo "  fprintf(stderr,\"Error ${CVAR}_trahrhe_$var: no corresponding domain: (pc, ${listevar1[${CVAR}11$((dim - 1))]}, ${Params[${CVAR}]}) = (%ld,$format)\\n\",pc,${listevar1[${CVAR}11$((dim - 1))]},${Params[${CVAR}]});" | sed "s/NOT_A_PARAMETER, //g"
                        fi
                    fi
                else
                    if (echo "${Params[${CVAR}]}" | grep -v -q "NOT_A_PARAMETER"); then
                        echo "  fprintf(stderr,\"Error ${CVAR}_trahrhe_$var: no corresponding domain: (pc, ${Params[${CVAR}]}) = (%ld,$format)\\n\",pc,${Params[${CVAR}]});"
                    else
                        if [[ ${nheader} == 1 ]]; then
                            echo "  fprintf(stderr,\"Error ${CVAR}_trahrhe_$var: no corresponding domain: pc = %ld\\n\",pc);"
                        else
                            echo "  fprintf(stderr,\"Error ${CVAR}_trahrhe_$var: no corresponding domain: (pc, ${Params[${CVAR}]}) = (%ld,$format)\\n\",pc,${Params[${CVAR}]});" | sed "s/NOT_A_PARAMETER, //g"
                        fi
                    fi
                fi
                echo "  exit(1);"
            fi
            echo "} /* end ${CVAR}_trahrhe_$var */"
            echo " "
            ((dim++))
            #### begin OPTIM TILING
            if (( dim > 1 )); then
                break
            fi
            #### end OPTIM TILING
        done
        ((nheader++))
    done # end while (( nheader <= tprof ))
    exec >&3
} # end generate_tiling_header_in_C()
