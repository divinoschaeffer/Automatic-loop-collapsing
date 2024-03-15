#===--- trahrhe_math.sh --------------------------------------------------===#
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

trahrhe_math() {

    typeset i cpt

    Entete[$CVAR]=$(echo "$DT" | sed "s/\(\[.*\].*:\).*/\1/")

    EnteteParams[$CVAR]=$(echo "$DT" | sed "s/\(\[.*\]\).*->.*/\1/")

    Params[$CVAR]=$(echo "${EnteteParams[$CVAR]}" | sed "s/\[//" | sed "s/\]//")

    listevar[$CVAR]=$(echo "$DT" | sed 's/.*\[.*\].*\[\(.*\)\].*/\1/' | sed 's/ *= *[^,]*//g')

    #Prepare Maxima declarations
    IFS=","
    Maxima_declare="declare("
    for var in ${listevar[$CVAR]} ${Params[$CVAR]}; do
        Maxima_declare="${Maxima_declare}""${var}"", integer,"
    done
    Maxima_declare=$(echo "${Maxima_declare}" | sed "s/\(.*\),$/\1/")
    Maxima_declare="${Maxima_declare}"")\$"

    listevar0[$CVAR]=$(echo "${listevar[$CVAR]}" | sed 's/,/0,/g')0

    listevar_blancs[$CVAR]=$(echo "${listevar[$CVAR]}" | sed 's/,/ /g')

    echo "---- Computation of Ehrhart Polynomials"
    card=$(echo "card $DT;" | iscc)

    card=$(echo "$card" | sed 's/.*{ *\(.*\) *}/\1/')
    #OLDIFS=$IFS
    IFS=';'
    cpt=1
    for dcard in $card; do
        echo "------ Ehrhart Polynomial n°$cpt"
        ehrhart[${CVAR}${cpt}]=$(echo "$dcard" | sed 's/\(.*\):.*/\1/' | sed 's/\([ +(-][0-9][0-9]*\)\([A-Z_a-z]\)/\1\*\2/g')
        expression=${ehrhart[${CVAR}${cpt}]}
        MinLong
        ehrhart[${CVAR}${cpt}]=$expression
        if (echo $dcard | grep -q ":"); then
            dehrhart[${CVAR}${cpt}]=$(echo "$dcard" | sed "s/.*:\(.*\)/{[${Params[$CVAR]}]:\1}/" | sed 's/\([ +(-][0-9][0-9]*\)\([A-Z_a-z]\)/\1\*\2/g')
        else
            dehrhart[${CVAR}${cpt}]=""
        fi
        ((cpt++))
    done
    nehrhart[$CVAR]=$((cpt - 1))

    # Décomposition lexicographique
    echo "---- Ranking Polynomials"
    echo "------ Building the domains for computing the ranking polynomials"
    IFS=$OLDIFS
    N=0
    equations=$(echo "$DT" | sed "s/.*:\(.*\)}/\1/")
    for var in ${listevar_blancs[$CVAR]}; do
        ((N++))
        VAR[${CVAR}${N}]=$var
        equations=$(echo "$equations" | sed "s/\([^a-zA-Z0-9_]\)$(echo $var)\([^a-zA-Z0-9_]\)/\1$(echo $var)0\2/g")
        equations=$(echo "$equations" | sed "s/\([^a-zA-Z0-9_]\)$(echo $var)$/\1$(echo $var)0/g")
        equations=$(echo "$equations" | sed "s/^$(echo $var)\([^a-zA-Z0-9_]\)/$(echo $var)0\1/g")
    done
    cpt=0
    ajout=""
    for var in ${listevar_blancs[$CVAR]}; do
        ((cpt++))
        echo "-------- Domain n°$cpt"
        P[$cpt]=$(echo "$DT" | sed "s/\(.*\[.*\].*\[\).*\(\].*\)/\1$(echo ${listevar0[$CVAR]})\2/")
        P[$cpt]=$(echo "${P[$cpt]}" | sed "s/\[\(.*\)/\[$(echo ${listevar[$CVAR]}),\1/")
        P[$cpt]=$(echo "${P[$cpt]}" | sed "s~\(.*\)}~\1 and $(echo ${equations})}~")
        if [[ "$cpt" < "$N" ]]; then
            P[$cpt]=$(echo "${P[$cpt]}" | sed "s/\(.*\)}/\1 and ${var}0 < $var}/")
        else
            P[$cpt]=$(echo "${P[$cpt]}" | sed "s/\(.*\)}/\1 and ${var}0 <= $var}/")
        fi
        if [[ "$cpt" > 1 ]]; then
            ajout="$ajout and "$prev_var"0 = $prev_var"
            P[$cpt]=$(echo "${P[cpt]}" | sed "s/\(.*\)}/\1 $(echo $ajout)}/")
        fi
        prev_var=$var
    done

    echo "------ Computing the ranking polynomials"
    cpt=1
    while ((cpt <= N)); do
        Resultat=$(echo "coalesce card ${P[$cpt]};" | iscc)
        Resultat=$(echo "$Resultat" | sed "s/.*{\(.*\)}/\1/")
        IFS=";"
        nbre_domaines=0
        for domsol in $Resultat; do
            ((nbre_domaines++))
            echo "-------- Ranking polynomial n°${nbre_domaines} -- domain ${cpt}"
            R[${CVAR}${cpt}${nbre_domaines}]=$(echo "$domsol" | sed "s/\(.*\):.*/\1/")
            Dom[${CVAR}${cpt}${nbre_domaines}]="${Entete[${CVAR}]} $(echo $domsol | sed "s/.*:\(.*\)/\1/" | sed 's/\([ +(-][0-9][0-9]*\)\([A-Z_a-z]\)/\1\*\2/g') }"
            Equations=$(echo "${Dom[${CVAR}${cpt}${nbre_domaines}]}" | sed "s/.*:\(.*\)}/\1/")
            Equations=$(echo "$Equations;" | "$D2C" | sed "s/\&\&/and/g" | sed "s/||/or/g" | sed "s/==/=/g")
            Equations=$(echo "$Equations" | sed "s/( *\([A-Za-z0-9_-][A-Za-z0-9_+*/-]*\) *= *\([A-Za-z0-9_-][A-Za-z0-9_+*/-]*\) *)/(\1<=\2) and (\1>=\2)/g")
            CEquations=$(echo "display2d:false$ ${Maxima_declare} load(\"logic.mac\")$ zhegalkin_form(${Equations});" | maxima --very-quiet | tr -d '\n')
            if (echo "$CEquations" | grep -q " xor "); then #if [[ $(echo "poly(${Dom[${cpt}${nbre_domaines}]})=${Dom[${cpt}${nbre_domaines}]};" | iscc) == "True" ]]
                #DEBUG echo "Dom[${cpt}${nbre_domaines}] est convexe : ${Dom[${cpt}${nbre_domaines}]}"
                #DEBUG else
                #DEBUG echo "Dom[${cpt}${nbre_domaines}] n'est pas convexe : ${Dom[${cpt}${nbre_domaines}]}"
                # Mémorisation des indices du domaine de départ
                StartDomain="${CVAR}${cpt}${nbre_domaines}"
                # découpage en domaines convexes
                #Equations=$(echo "${Dom[${cpt}${nbre_domaines}]}" | sed "s/.*:\(.*\)}/\1/")
                #Equations=$(echo "$Equations;" | "$D2C" | sed "s/\&\&/and/g" | sed "s/||/or/g" | sed "s/==/=/g")
                #Equations=$(echo "$Equations" | sed "s/( *\([A-Za-z0-9_-][A-Za-z0-9_+*/-]*\) *= *\([A-Za-z0-9_-][A-Za-z0-9_+*/-]*\) *)/(\1<=\2) and (\1>=\2)/g")
                #CEquations=$(echo "display2d:false$ load(\"logic.mac\")$ zhegalkin_form(${Equations});" | maxima --very-quiet | tr -d '\n')
                CEquations=$(echo "$CEquations" | sed "s/xor/:/g")
                IFS=":"
                for Equations in $CEquations; do
                    echo "-------- Ranking polynomial n°${nbre_domaines} -- domain ${cpt}"
                    Equations=$(echo "$Equations" | sed "s/  */ /g" | sed "s/(\(-[1-9][0-9]*\))/\1/g" | sed "s/+-/-/g")
                    Dom[${CVAR}${cpt}${nbre_domaines}]="${Entete[${CVAR}]} ${Equations} }"
                    # ils ont le même ranking que le domaine de départ (?)
                    R[${CVAR}${cpt}${nbre_domaines}]="${R[${StartDomain}]}"
                    #DEBUG echo "==> Dom[${cpt}${nbre_domaines}] rendu convexe : ${Dom[${cpt}${nbre_domaines}]}"
                    ((nbre_domaines++))
                done
                ((nbre_domaines--))
                IFS=";"
            fi

        done
        NDOM[${CVAR}${cpt}]=$nbre_domaines
        ((cpt++))
    done

    echo "------ Ranking polynomials' domains completion to cover the whole initial domain (may take time)"
    cpt=1
    while ((cpt <= N)); do
        if [[ ${NDOM[${CVAR}${cpt}]} == 1 ]]; then
            Dom[${CVAR}${cpt}1]="$DT"
        else
            #echo "Global Domain=$DT"
            U="{ }"
            ndom=1
            while ((ndom <= NDOM[${CVAR}${cpt}])); do
                U=$(echo "coalesce ($U+${Dom[${CVAR}${cpt}${ndom}]});" | iscc | sed 's/\([ +(-][0-9][0-9]*\)\([A-Z_a-z]\)/\1\*\2/g')
                echo -n "."
                ((ndom++))
            done
            M=$(echo "coalesce ($DT-$U);" | iscc | sed 's/\([ +(-][0-9][0-9]*\)\([A-Z_a-z]\)/\1\*\2/g')
            echo -n "."
            #echo " "
            #echo "M=$M"

            MEntete=$(echo "$M" | sed "s/\(\[.*\]\) ->.*/\1/")
            #echo "MEntete=$MEntete"
            MSet=$(echo "$M" | sed "s/.*{\(.*\)}/\1/")

            NIterations=0
            Reste="$MSet"
            while [ "$NIterations" -lt "3" ]; do
                ((NIterations++))
                #DEBUG echo "Itération n°${NIterations}"
                MSet="$Reste"
                Reste="  "
                #DEBUG echo "ICIIIIIIIIIII Mset=$MSet"

                if [ "$MSet" != "  " ]; then
                    IFS=";"
                    for CaseM in $MSet; do
                        CurSet="$MEntete -> { $CaseM }"
                        #DEBUG echo "CurSet=$CurSet"
                        #ndom=1
                        #while (( ndom <= NDOM[$cpt] ))
                        #do
                        #echo "Dom[$cpt$ndom]=${Dom[$cpt$ndom]}"
                        #echo "coalesce (${Dom[$cpt$ndom]}+$CurSet);"
                        #if [[ $(echo "poly (${Dom[$cpt$ndom]}+$CurSet) = coalesce (${Dom[$cpt$ndom]}+$CurSet);" | iscc) == "True" ]]
                        #then
                        #echo "YES"
                        #Dom[$cpt$ndom]=$(echo "coalesce (${Dom[$cpt$ndom]}+$CurSet);" | iscc | sed 's/\([ +-][0-9][0-9]*\)\([A-Z_a-z]\)/\1\*\2/g')
                        #break
                        #fi
                        #(( ndom++ ))
                        #done
                        #if (( ndom > NDOM[$cpt] ))
                        #then
                        # Méthode plus avancée : Découpage/fusion de M par domaine
                        #DEBUG echo "Méthode plus avancée : Découpage/fusion de M par domaine"
                        #DEBUG echo "CurSet=$CurSet"
                        ndom=1
                        while ((ndom <= NDOM[${CVAR}${cpt}])); do # zhegalkin inutile grâce à la convexification ? voir éventuelt trahrhe_math_tiling
                            Equations=$(echo "${Dom[${CVAR}${cpt}${ndom}]}" | sed "s/.*:\(.*\)}/\1/")
                            Equations=$(echo "$Equations;" | "$D2C" | sed "s/^(\(.*\))$/\1/" | sed "s/((*/(/g" | sed "s/))*/)/g" | sed "s/==/=/g")
                            Equations=$(echo "$Equations" | sed "s/\&\&/;/g" | sed "s/||/;/g")
                            MT="$CurSet"
                            IFS=";"
                            for C in $Equations; do
                                T=$(echo "$MT" | sed "s/\(.*\)}/\1 and $C}/")
                                Empty=$(echo "P:=$T; card P;" | iscc)
                                Empty=$(echo $Empty | sed "s/.*-> *\(.*\)/\1/")
                                echo -n "."
                                if [ $Empty != "{  }" ]; then
                                    MT="$T"
                                    #echo "MT changed to $MT"
                                fi
                            done

                            #Equations=$(echo "coalesce(${Dom[$cpt$ndom]}+$MT);" | iscc | sed 's/\([ +-][0-9][0-9]*\)\([A-Z_a-z]\)/\1\*\2/g')
                            #Equations=$(echo "$Equations" | sed "s/.*:\(.*\)}/\1/")
                            #Equations=$(echo "$Equations;" | "$D2C" | sed "s/\&\&/and/g" | sed "s/||/or/g" | sed "s/==/=/g")
                            #Equations=$(echo "$Equations" | sed "s/( *\([A-Za-z0-9_-][A-Za-z0-9_+*/-]*\) *= *\([A-Za-z0-9_-][A-Za-z0-9_+*/-]*\) *)/(\1<=\2) and (\1>=\2)/g")
                            #CEquations=$(echo "display2d:false$ load(\"logic.mac\")$ zhegalkin_form(${Equations});" | maxima --very-quiet | tr -d '\n')
                            #if ( ! echo "$CEquations" | grep -q " xor ")
                            if [[ $(echo "poly(${Dom[${CVAR}${cpt}${ndom}]}+$MT)=coalesce(${Dom[${CVAR}${cpt}${ndom}]}+$MT);" | iscc) == "True" ]]; then
                                echo "."
                                echo "-------- Completion OK"
                                #DEBUG echo "YES"
                                # Domain courant étendu avec MT
                                #DEBUG echo "Fusion avec Dom[$cpt$ndom]"
                                Dom[${CVAR}${cpt}${ndom}]=$(echo "coalesce (${Dom[${CVAR}${cpt}${ndom}]}+$MT);" | iscc | sed 's/\([ +(-][0-9][0-9]*\)\([A-Z_a-z]\)/\1\*\2/g')
                                #echo "New Domain: Dom[$cpt$ndom]=${Dom[$cpt$ndom]}"
                                CurSet=$(echo "$CurSet-$MT;" | iscc | sed 's/\([ +(-][0-9][0-9]*\)\([A-Z_a-z]\)/\1*\2/g')
                                echo -n "."
                                #echo "remaining CurSet=$CurSet"
                                Empty=$(echo "P:=$CurSet; card P;" | iscc)
                                Empty=$(echo $Empty | sed "s/.*-> *\(.*\)/\1/")
                                echo -n "."
                                if [ $Empty = "{  }" ]; then # all M has been fused
                                    ndom=${NDOM[${CVAR}${cpt}]}
                                    break
                                fi
                                #DEBUG else
                                #DEBUG echo "NO"
                            fi
                            ((ndom++))
                        done
                        Empty=$(echo "P:=$CurSet; card P;" | iscc)
                        echo -n "."
                        Empty=$(echo $Empty | sed "s/.*-> *\(.*\)/\1/")
                        if [ $Empty != "{  }" ]; then
                            #DEBUG echo "PAS DE FUSION POSSIBLE, reste = $CurSet"
                            if [ "$Reste" = "  " ]; then
                                Reste=$(echo "$CurSet" | sed "s/.*{\(.*\)}/\1/")
                            else
                                Reste="$Reste;$(echo "$CurSet" | sed 's/.*{\(.*\)}/\1/')"
                            fi
                            if [ $NIterations -ge "3" ]; then
                                echo "ERROR: Unsuccessful completion!"
                                exit 1
                            fi
                            #DEBUG else
                            #DEBUG echo "On doit arrêter ! Reste=$Reste"
                            #NIterations=4
                        else
                            echo "."
                            echo "-------- Domain covered"
                        fi
                        #fi
                    done
                fi

            done # while (( $Niterations <= 3 ))

        fi
        ((cpt++))
    done

    # Fonction récursive de construction des combinaisons de domaines et de polynômes dimension par dimension
    Solutions() {
        typeset ndom=1
        typeset Profondeur=$1
        typeset Domaine=$2
        typeset Polynome=$3
        typeset Dt
        typeset Rt
        typeset ProfTemp
        if [[ $Profondeur == $((N + 1)) ]]; then
            sortie=$(echo "$Domaine" | sed "s/ *\[.*\] *-> *\(.*\)/\1/")
            if [[ $sortie != "{  }" ]]; then
                echo "-------- Ranking polynomial n°${nsol[${CVAR}]}"
                DS[${CVAR}${nsol[${CVAR}]}]=$Domaine
                RS[${CVAR}${nsol[${CVAR}]}]=$Polynome
                # égalités dans les équations
                liste=$(echo "${DS[${CVAR}${nsol[${CVAR}]}]}" | sed "s/ *\[[^\]*\].*\[\(.*\)\].*/\1/")
                IFS=","
                for elt in $liste; do
                    if (echo $elt | grep -q "="); then
                        DS[${CVAR}${nsol[${CVAR}]}]=$(echo "${DS[${CVAR}${nsol[${CVAR}]}]}" | sed "s/\(.*\)}/\1 and $elt}/")
                    fi
                done

                ((nsol[${CVAR}]++))
            fi
            return 0
        fi
        while [[ $ndom -le ${NDOM[${CVAR}${Profondeur}]} ]]; do
            Dt=$(echo "coalesce ($Domaine*${Dom[${CVAR}${Profondeur}${ndom}]});" | iscc | sed 's/\([ +(-][0-9][0-9]*\)\([A-Z_a-z]\)/\1\*\2/g')
            if (echo "${Dt}" | grep -q ";"); then
                #echo "WARNING: several domains in an intersection"
                Dt=$(echo "${Dt}" | sed "s/\[.*\] *-> *{\(.*\)}/\1/")
                IFS=";"
                DC=""
                for C in ${Dt}; do
                    DC="${DC}+${EnteteParams[$CVAR]}->{$C}"
                done
                DC=$(echo "${DC}" | sed "s/^+//")
                if [[ $(echo "poly (${DC}) = coalesce (${DC});" | iscc) == "True" ]]; then
                    Dt=$(echo "poly (${DC});" | iscc | sed 's/\([ +(-][0-9][0-9]*\)\([A-Z_a-z]\)/\1\*\2/g')
                else
                    echo "ERROR: several domains in an intersection"
                    exit 1
                fi
            fi
            sortie=$(echo "$Dt" | sed "s/ *\[.*\] *-> *\(.*\)/\1/")
            if [[ $sortie != "{  }" ]]; then
                R[${CVAR}${Profondeur}${ndom}]=$(echo "${R[${CVAR}${Profondeur}${ndom}]}" | sed 's/\([ +(-][0-9][0-9]*\)\([A-Z_a-z]\)/\1\*\2/g')
                Rt=$(echo "display2d:false$ ${Maxima_declare} factor(${Polynome}+${R[${CVAR}${Profondeur}${ndom}]});" | maxima --very-quiet | tr -d '\n' | tr -d ' ')
            else
                Rt=0
            fi
            ((ProfTemp = Profondeur + 1))
            Solutions "$ProfTemp" "$Dt" "$Rt"
            ((ndom++))
        done
        return 0
    }

    IndDomEgal=0
    nbegal=0
    # Appel de la fonction récursive
    echo "------ Summing ranking polynomials and joining domains over lexicographic dimensions (recursive)"
    nsol[${CVAR}]=1
    Solutions "1" "$DT" "0"
    ((nsol[${CVAR}]--))

    #echo " "
    #echo "Number of cases: ${nsol[$CVAR]}"
    #echo " "

    # Calcul des lexmin et lexmax et de leurs domaines

    # Computing the lexmin and lexmax is useless in case of dichotomy search
    if ! [[ "${m_flag}" = "true" && "${masque:$(($1 - 1)):1}" = [Dd] ]]; then

        echo "---- Computing lexmin and lexmax values and their domains"
        cpt=1
        while ((cpt <= nsol[${CVAR}])); do
            all_slexmin="$(echo "coalesce lexmin ${DS[${CVAR}${cpt}]};" | iscc | sed 's/\([ +(-][0-9][0-9]*\)\([A-Z_a-z]\)/\1\*\2/g' | sed "s/^\[.*\] *-> *{\(.*\)}/\1/")"
            ##################################
            IFS=";"
            nmin=1
            for slexmin in $all_slexmin; do
                #PB: slexmax (ou slexmin) non convexes!! plusieurs if, plusieurs (..)
                # il faut parser les conditions if...else
                #DEBUG echo "new slexmin"
                code=$(echo "codegen ({[${listevar[$CVAR]}]->[${listevar[$CVAR]}]}*${EnteteParams[$CVAR]} -> {$slexmin});" | iscc --no-barvinok-isl-ast-build-allow-or --no-barvinok-isl-ast-build-allow-else)
                code=$(echo "$code" | sed 's/^ *\(.*\)/\1/g') #remove blanks starting lines
                if (echo "$code" | sed -n "1p" | grep -q "^{"); then
                    code=$(echo "$code" | sed "1d")
                    code=$(echo "$code" | sed "$d")
                fi
                AO=0
                AF=0
                NbLines=$(echo "$code" | wc -l)
                Line=1
                while ((Line <= NbLines)); do
                    if ((AO == AF)); then
                        j=1
                    fi
                    if (echo "$code" | sed -n "${Line}p" | grep -q "^if "); then
                        cond[${nmin}$j]=$(echo "$code" | sed -n "${Line}p" | sed "s/.*if [^(]*(\(.*\))[^)]*/\1/")
                        ((j++))
                    fi
                    if (echo "$code" | sed -n "${Line}p" | grep -q "{"); then
                        ((AO++))
                    fi
                    if (echo "$code" | sed -n "${Line}p" | grep -q "}"); then
                        ((AF++))
                    fi

                    if (echo "$code" | sed -n "${Line}p" | grep -q "^("); then
                        echo "------ lexmin n°$nmin -- domain $cpt/${nsol[${CVAR}]}"
                        vlexmin[${CVAR}${cpt}${nmin}]=$(echo "$code" | sed -n "${Line}p" | sed 's/(\(.*\));/\1/' | tr -d ' ')
                        vlexmin[${CVAR}${cpt}${nmin}]=$(echo "${vlexmin[${CVAR}${cpt}${nmin}]};" | "$F2F")
                        vlexmin[${CVAR}${cpt}${nmin}]=$(echo "${vlexmin[${CVAR}${cpt}${nmin}]};" | "$P2M")
                        dlexmin[${CVAR}${cpt}${nmin}]="${cond[${nmin}1]}"
                        for ((k = 2; k < j; k++)); do
                            dlexmin[${CVAR}${cpt}${nmin}]="${dlexmin[${CVAR}${cpt}${nmin}]} and ${cond[${nmin}$k]}"
                        done
                        #echo "AVANT : dlexmin[${CVAR}${cpt}${nmin}]=${dlexmin[${CVAR}${cpt}${nmin}]}"
                        dlexmin[${CVAR}${cpt}${nmin}]=$(echo "${dlexmin[${CVAR}${cpt}${nmin}]}" | sed "s/\&\&/ and /g" | sed "s/==/=/g" | sed "s/floord(\([^,]*\),\([^)]*\)) *\([<>=+*\/-]\|and\|or\|$\)/floor((\1)\/(\2)) \3/g" | sed "s/\(.*\)/{ ${EnteteParams[$CVAR]} : \1 }/")
                        #echo "APRES : dlexmin[${CVAR}${cpt}${nmin}]=${dlexmin[${CVAR}${cpt}${nmin}]}"
                        ((nmin++))
                        ((j--))
                    fi

                    ((Line++))
                done
            done # for slexmin in $all_slexmin
            NPCMIN[${CVAR}${cpt}]=$((nmin - 1))
            ##################################
            #        nmin=0
            #        IFS=";"
            #        for slexmin in $all_slexmin; do
            #            ((nmin++))
            #            echo "------ lexmin n°${nmin} -- domain ${cpt}/${nsol}"

            #            dlexmin[$cpt$nmin]=$(echo "codegen ({[$listevar]->[$listevar]}*$EnteteParams -> {$slexmin});" | iscc | tr -d ' ' | sed -n "1s/if(\(.*\))/\1/p" | sed "s/\&\&/ and /g" | sed "s/==/=/g" | sed "s/floord(\(.*\),\(.*\))/floor(\1\/\2)/g" | sed "s/\(.*\)/{ $EnteteParams : \1 }/")

            #            vlexmin[$cpt$nmin]=$(echo "codegen ({[$listevar]->[$listevar]}*$EnteteParams -> {$slexmin});" | iscc | sed -n "\$p" | sed "s/(\(.*\));/\1/" | tr -d ' ')

            #            vlexmin[$cpt$nmin]=$(echo "${vlexmin[$cpt$nmin]};" | ${F2F})

            #        done
            #        NPCMIN[$cpt]=$nmin

            all_slexmax="$(echo "coalesce lexmax ${DS[${CVAR}${cpt}]};" | iscc | sed 's/\([ +(-][0-9][0-9]*\)\([A-Z_a-z]\)/\1\*\2/g' | sed "s/^\[.*\] *-> *{\(.*\)}/\1/")"
            ##################################
            IFS=";"
            nmax=1
            for slexmax in $all_slexmax; do
                code=$(echo "codegen ({[${listevar[$CVAR]}]->[${listevar[$CVAR]}]}*${EnteteParams[$CVAR]} -> {$slexmax});" | iscc --no-barvinok-isl-ast-build-allow-or --no-barvinok-isl-ast-build-allow-else)
                code=$(echo "$code" | sed 's/^ *\(.*\)/\1/g') #remove blanks starting lines
                if (echo "$code" | sed -n "1p" | grep -q "^{"); then
                    code=$(echo "$code" | sed "1d")
                    code=$(echo "$code" | sed "$d")
                fi
                AO=0
                AF=0
                NbLines=$(echo "$code" | wc -l)
                Line=1
                while ((Line <= NbLines)); do
                    if ((AO == AF)); then
                        j=1
                    fi
                    if (echo "$code" | sed -n "${Line}p" | grep -q "^if "); then
                        cond[${nmax}$j]=$(echo "$code" | sed -n "${Line}p" | sed "s/.*if [^(]*(\(.*\))[^)]*/\1/")
                        ((j++))
                    fi
                    if (echo "$code" | sed -n "${Line}p" | grep -q "{"); then
                        ((AO++))
                    fi
                    if (echo "$code" | sed -n "${Line}p" | grep -q "}"); then
                        ((AF++))
                    fi

                    if (echo "$code" | sed -n "${Line}p" | grep -q "^("); then
                        echo "------ lexmax n°$nmax -- domain $cpt/${nsol[${CVAR}]}"
                        vlexmax[${CVAR}${cpt}${nmax}]=$(echo "$code" | sed -n "${Line}p" | sed 's/(\(.*\));/\1/' | tr -d ' ')
                        vlexmax[${CVAR}${cpt}${nmax}]=$(echo "${vlexmax[${CVAR}${cpt}${nmax}]};" | "$F2F")
                        vlexmax[${CVAR}${cpt}${nmax}]=$(echo "${vlexmax[${CVAR}${cpt}${nmax}]};" | "$P2M")
                        dlexmax[${CVAR}${cpt}${nmax}]="${cond[${nmax}1]}"
                        for ((k = 2; k < j; k++)); do
                            dlexmax[${CVAR}${cpt}${nmax}]="${dlexmax[${CVAR}${cpt}${nmax}]} and ${cond[${nmax}$k]}"
                        done
                        #echo "AVANT : dlexmax[${CVAR}${cpt}${nmax}]=${dlexmax[${CVAR}${cpt}${nmax}]}"
                        dlexmax[${CVAR}${cpt}${nmax}]=$(echo "${dlexmax[${CVAR}${cpt}${nmax}]}" | sed "s/\&\&/ and /g" | sed "s/==/=/g" | sed "s/floord(\([^,]*\),\([^)]*\)) *\([<>=+*\/-]\|and\|or\|$\)/floor((\1)\/(\2)) \3/g" | sed "s/\(.*\)/{ ${EnteteParams[$CVAR]} : \1 }/")
                        #echo "APRES : dlexmax[${CVAR}${cpt}${nmax}]=${dlexmax[${CVAR}${cpt}${nmax}]}"
                        ((nmax++))
                        ((j--))
                    fi

                    ((Line++))
                done
            done # for slexmax in $all_slexmax
            NPCMAX[${CVAR}${cpt}]=$((nmax - 1))
            ##################################
            nbegal=0
            #        nmax=0
            #        IFS=";"
            #        for slexmax in $all_slexmax; do
            #            ((nmax++))
            #            echo "------ lexmax n°${nmax} -- domain ${cpt}/${nsol}"

            #            dlexmax[$cpt$nmax]=$(echo "codegen ({[$listevar]->[$listevar]}*$EnteteParams -> {$slexmax});" | iscc | tr -d ' ' | sed -n "1s/if(\(.*\))/\1/p" | sed "s/\&\&/ and /g" | sed "s/==/=/g" | sed "s/floord(\(.*\),\(.*\))/floor(\1\/\2)/g" | sed "s/\(.*\)/{ $EnteteParams : \1 }/")
            #           vlexmax[$cpt$nmax]=$(echo "codegen ({[$listevar]->[$listevar]}*$EnteteParams -> {$slexmax});" | iscc | sed -n "\$p" | sed "s/(\(.*\));/\1/" | tr -d ' ')
            #            vlexmax[$cpt$nmax]=$(echo "${vlexmax[$cpt$nmax]};" | $F2F)

            #Test s'il s'agit d'un domaine avec une égalité
            #            egal=$(echo "${dlexmax[$cpt$nmax]}" | sed "s/.* \(=\) .*/\1/")
            #            if [[ $egal == "=" ]]; then
            #                IndDomEgal=$nmax
            #                ((nbegal++))
            #                echo "détection d'une égalité indice $IndDomEgal"
            #                echo "dlexmax[$cpt$nmax]=${dlexmax[$cpt$nmax]}"
            #            fi

            #        done
            #        NPCMAX[$cpt]=$nmax

            if ((nbegal == 1)); then
                nmax=1
                while ((nmax <= NPCMAX[$cpt])); do
                    if [[ "$cpt$nmax" != "$cpt$IndDomEgal" ]]; then
                        if [[ $(echo "poly (${dlexmax[$cpt$IndDomEgal]}+${dlexmax[$cpt$nmax]}) = coalesce (${dlexmax[$cpt$IndDomEgal]}+${dlexmax[$cpt$nmax]});" | iscc) == "True" ]]; then
                            dlexmax[$cpt$nmax]=$(echo "coalesce (${dlexmax[$cpt$IndDomEgal]}+${dlexmax[$cpt$nmax]});" | iscc | sed 's/\([ +(-][0-9][0-9]*\)\([A-Z_a-z]\)/\1\*\2/g')
                            #vlexmax[$cpt$nmax]=${vlexmax[$cpt$IndDomEgal]}
                            echo "Fusion : dlexmax[$cpt$nmax]=${dlexmax[$cpt$nmax]}"
                            #une sol en moins, compression des indices
                            j=$((IndDomEgal + 1))
                            while ((j <= NPCMAX[$cpt])); do
                                dlexmax[$cpt$((j - 1))]="${dlexmax[$cpt$j]}"
                                vlexmax[$cpt$((j - 1))]="${vlexmax[$cpt$j]}"
                                ((j++))
                            done
                            ((NPCMAX[$cpt]--))
                            break
                        fi
                    fi
                    ((nmax++))
                done
            else
                if ((nbegal > 1)); then
                    echo "ERROR: several domains with equalities!"
                    exit 1
                fi
            fi

            ((cpt++))
        done

        # Calcul des pcmin et pcmax

    fi # en of Computing the lexmin and lexmax is useless in case of dichotomy search

    # Computing the pcmin and pcmax is useless in case of dichotomy search
    if ! [[ "${m_flag}" = "true" && "${masque:$(($1 - 1)):1}" = [Dd] ]]; then

        echo "---- Min and Max values of ranking polynomials over each of their domains: pcmin and pcmax"
        cpt=1
        while ((cpt <= nsol[${CVAR}])); do
            npc=1
            while ((npc <= NPCMIN[${CVAR}${cpt}])); do
                echo "------ pcmin n°$npc/${NPCMIN[${CVAR}${cpt}]} -- domain $cpt/${nsol[${CVAR}]}"
                pcmin[${CVAR}${cpt}${npc}]=$(echo "display2d:false$ ${Maxima_declare} r(${listevar[${CVAR}]}):=${RS[${CVAR}${cpt}]}$ factor(r(${vlexmin[${CVAR}${cpt}${npc}]}));" | maxima --very-quiet | tr -d '\n' | tr -d ' ')
                pcmin[${CVAR}${cpt}${npc}]=$(echo ${pcmin[${CVAR}${cpt}${npc}]} | tr -d '\n' | tr -d ' ')
                #echo "pcmin[$cpt$npc]=${pcmin[$cpt$npc]}"
                #echo "dlexmin[$cpt$npc]=${dlexmin[$cpt$npc]}"
                #echo "vlexmin[$cpt$npc]=${vlexmin[$cpt$npc]}"
                #echo " "
                ((npc++))
            done
            npc=1
            while ((npc <= NPCMAX[${CVAR}${cpt}])); do
                echo "------ pcmax n°$npc/${NPCMAX[${CVAR}${cpt}]} -- domain $cpt/${nsol[${CVAR}]}"
                pcmax[${CVAR}${cpt}${npc}]=$(echo "display2d:false$ ${Maxima_declare} r(${listevar[${CVAR}]}):=${RS[${CVAR}${cpt}]}$ factor(r(${vlexmax[${CVAR}${cpt}${npc}]}));" | maxima --very-quiet | tr -d '\n' | tr -d ' ')
                pcmax[${CVAR}${cpt}${npc}]=$(echo ${pcmax[${CVAR}${cpt}${npc}]} | tr -d '\n' | tr -d ' ')
                #echo "dlexmax[$cpt$npc]=${dlexmax[$cpt$npc]}"
                #echo " "
                ((npc++))
            done
            ((cpt++))
        done

        # Minimisations des longueurs
        echo "---- Minimizing the lengths of algebraic expressions"
        cpt=1
        while ((cpt <= nsol[${CVAR}])); do
            expression=${RS[${CVAR}${cpt}]}
            MinLong
            RS[${CVAR}${cpt}]=$expression
            npc=1
            while ((npc <= NPCMIN[${CVAR}${cpt}])); do
                echo -n "."
                expression=${pcmin[${CVAR}${cpt}${npc}]}
                MinLong
                pcmin[${CVAR}${cpt}${npc}]=$expression
                ((npc++))
            done
            npc=1
            while ((npc <= NPCMAX[${CVAR}${cpt}])); do
                echo -n "."
                expression=${pcmax[${CVAR}${cpt}${npc}]}
                MinLong
                pcmax[${CVAR}${cpt}${npc}]=$expression
                ((npc++))
            done
            ((cpt++))
        done
        echo " done"
    fi # en of Computing the pcmin and pcmax is useless in case of dichotomy search

    # periode par periode ici, puis lexmin internes par période
    # Prise en compte des périodes
    echo "---- Computing Ranking Polynomials per Periods"
    PeriodicSplit() {
        typeset nsol="$1"
        typeset Ranking="$2"
        typeset Domain="$3"
        typeset k Frac Num Denom DRanking DMod PRanking PDomain
        Frac=$(echo "$Ranking;" | "$EFC")
        if [ ${Frac} != "0" ]; then
            Frac=$(echo "${Frac}" | tr -d ' ')
            Num=$(echo "${Frac}" | sed "s/\(.*\)\/[1-9][0-9]*/\1/" | tr -d ' ')
            Denom=$(echo "${Frac}" | sed "s/.*\/\([1-9][0-9]*\)/\1/")

            # de quelle variable dépend Num?
            for ((i = 1; $((N + 1)) - ${i}; i++)); do
                if (echo "${Num}" | grep -q "[^A-Za-z0-9]${VAR[${CVAR}${i}]}[^A-Za-z0-9]\|^${VAR[${CVAR}${i}]}[^A-Za-z0-9]\|[^A-Za-z0-9]${VAR[${CVAR}${i}]}$\|^${VAR[${CVAR}${i}]}$"); then
                    VarPeriodic[${CVAR}${nsol}${VAR[${CVAR}${i}]}]=1
                fi
            done

            Ranking=$(echo "${Ranking}" | sed "s/\(.*)\)\/\([1-9][0-9]*\)/\1*1\/\2/g")
            Ranking=$(echo "${Ranking}" | sed "s/\//\\\\\//g")
            DRanking=$(echo "${Domain}" | sed "s/\(\[.*\)\] *-> *{ *\[\(.*\)\] *:\(.*\)/\1, \2\] -> { : \3/")
            DRanking=$(echo "${DRanking}" | sed "s/\(.*\)-> { : \(.*\)/\1-> { $(echo "${Ranking}") : \2/")
            for ((k = 0; $Denom - $k; k++)); do
                DMod=$(echo "${DRanking}" | sed "s/\(\[.*\]\) -> {.*/\1-> { : ${Num}%${Denom}=$k }/")
                PRanking=$(echo "${DRanking}%${DMod};" | iscc | sed "s/.*{ *\(.*\) *:.*/\1/" | sed 's/\([ +(-][0-9][0-9]*\)\([A-Z_a-z]\)/\1\*\2/g')
                #echo "PRanking=$PRanking"
                PDomain=$(echo "${Domain};" | sed "s/\(.*\)};$/\1 and ${Num}\%${Denom}=$k};/" | iscc | sed 's/\([ +(-][0-9][0-9]*\)\([A-Z_a-z]\)/\1\*\2/g')
                if [[ "$(echo ${PDomain} | sed "s/.*->.*: *\(.*\) \}/\1/")" != "false" ]]; then
                    PeriodicSplit "$nsol" "${PRanking}" "${PDomain}"
                fi
            done
        else
            ((Period++))
            echo "------ Ranking Polynomial: domain ${nsol} -- period ${Period}"
            RSA[V${CVAR}N${nsol}P${Period}]="${Ranking}"
            DSA[V${CVAR}N${nsol}P${Period}]="${Domain}"
            DSA[V${CVAR}N${nsol}P${Period}]=$(echo "${DSA[V${CVAR}N${nsol}P${Period}]}" | sed "s/ mod / % /g" | sed 's/\([ +(-][0-9][0-9]*\)\([A-Z_a-z]\)/\1\*\2/g')
            TMP1=$(echo "${DSA[V${CVAR}N${nsol}P${Period}]}" | sed "s/\[.*\] *-> *{ *\[\(.*\)\] *:.*}/\1/")
            IFS=","
            for TMP2 in $TMP1; do
                if (echo $TMP2 | grep -q "="); then
                    #supprimer les égalités de la liste des variables: s/TMP2/... ?
                    TMP3=$(echo "$TMP2" | sed "s/ *\(.*\) *=.*/\1/")
                    TMP4=$(echo "$TMP2" | sed "s/\*/\\\*/g")
                    DSA[V${CVAR}N${nsol}P${Period}]=$(echo "${DSA[V${CVAR}N${nsol}P${Period}]}" | sed "s/\(.*\)${TMP4}\(.*\] *:.*\)/\1${TMP3}\2/")
                    DSA[V${CVAR}N${nsol}P${Period}]=$(echo "${DSA[V${CVAR}N${nsol}P${Period}]}" | sed "s/\(.*\)}/\1 and $TMP2}/")
                fi
            done
        fi
        return 0
    }

    for ((cpt = 1; $((nsol[${CVAR}] + 1)) - $cpt; cpt++)); do
        for ((i = 1; $((N + 1)) - ${i}; i++)); do
            VarPeriodic[${CVAR}${cpt}${VAR[${CVAR}${i}]}]=0
        done
        Period=0
        PeriodicSplit "${cpt}" "${RS[${CVAR}${cpt}]}" "${DS[${CVAR}${cpt}]}"
        NPeriod[${CVAR}${cpt}]="${Period}"
        #for ((i=1 ; $(( N+1 )) - ${i} ; i++))
        #do
        #echo "sol num. ${cpt}: ${VAR[$i]}: ${VarPeriodic[${cpt}${VAR[${i}]}]}"
        #done
    done

    # Calcul des lexmin internes

    # Computing deep lexmin is useless in case of dichotomy search
    if ! [[ "${m_flag}" = "true" && "${masque:$(($1 - 1)):1}" = [Dd] ]]; then

        echo "---- Computing deep (inner dimensions) lexicographic minimums"
        cpt=1
        while ((cpt <= nsol[${CVAR}])); do
            # Pour chaque periode
            for ((Period = 1; $((NPeriod[${CVAR}${cpt}] + 1)) - ${Period}; Period++)); do
                # Pour chaque dimension
                #dim=1
                dim=0
                while ((dim <= N - 1)); do
                    #### begin OPTIM TILING
                    if [ "${dim}" -gt 1 -a "${t_flag}" = 'true' ]; then
                        #if (( (dim > 1) && (t_flag == 'true') )); then
                        break
                    fi
                    #### end OPTIM TILING
                    if ((dim >= 1)); then
                        # préparation des domaines pour calculs des lexmin
                        listevar1[${CVAR}${cpt}${Period}${dim}]=""
                        i=1
                        while ((i <= dim)); do
                            if ((i == 1)); then
                                listevar1[${CVAR}${cpt}${Period}${dim}]=,${VAR[${CVAR}${i}]}
                            else
                                listevar1[${CVAR}${cpt}${Period}${dim}]="${listevar1[${CVAR}${cpt}${Period}${dim}]}, ${VAR[${CVAR}${i}]}"
                            fi
                            ((i++))
                        done

                        domaine=$(echo "${DSA[V${CVAR}N${cpt}P${Period}]}" | sed "s/\(.*\[.*\)\(\].*\[.*\].*\)/\1${listevar1[${CVAR}${cpt}${Period}${dim}]}\2/")
                        listevar2=""
                        i=$((dim + 1))
                        while ((i <= N)); do
                            if ((i == dim + 1)); then
                                listevar2=${VAR[${CVAR}${i}]}
                            else
                                listevar2="${listevar2},${VAR[${CVAR}${i}]}"
                            fi
                            ((i++))
                        done
                        domaine=$(echo "$domaine" | sed "s/\(.*\[.*\].*\[\).*\(\].*\)/\1${listevar2}\2/")
                    else # dim=0
                        listevar2="${listevar[${CVAR}]}"
                        domaine="${DSA[V${CVAR}N${cpt}P${Period}]}"
                        #listevar2=$(echo "$domaine" | sed "s/ *\[.*\] *-> *{ *\[\(.*\)\].*/\1/")
                        #listevar2=$(echo "${listevar2}" | sed "s/[=+-] *[A-Za-z0-9_-][A-Za-z0-9_+-]*//g")
                    fi
                    EnteteP=$(echo "$domaine" | sed "s/\(\[.*\]\).*->.*/\1/")
                    # calcul du lexmin sur le domaine courant
                    all_slexmin=$(echo "coalesce lexmin $domaine;" | iscc | sed 's/\([ +(-][0-9][0-9]*\)\([A-Z_a-z]\)/\1\*\2/g' | sed "s/^\[.*\] *-> *{\(.*\)}/\1/")
                    nmin=0
                    nbegal=0
                    IFS=";"
                    for slexmin in $all_slexmin; do
                        ((nmin++))
                        echo "------ lexmin n°$nmin: domain $cpt -- dimension $dim -- period ${Period}"
                        dlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]=$(echo "codegen ({[$listevar2]->[$listevar2]}*$EnteteP -> {$slexmin});" | iscc | tr -d ' ' | sed -n "1s/if *(\(.*\)) *{* */\1/p" | sed "s/\&\&/ and /g" | sed "s/==/=/g" | sed "s/floord(\([^,]*\),\([^)]*\))/floor((\1)\/(\2))/g" | sed "s/ mod / % /g" | sed 's/\([ +(-][0-9][0-9]*\)\([A-Z_a-z]\)/\1\*\2/g' | sed "s/\(.*\)/{ $EnteteP : \1 }/")
                        #vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]=$(echo "codegen ({[$listevar2]->[$listevar2]}*$EnteteP -> {$slexmin});" | iscc | grep ";" | sed "s/^ *//" | sed "s/(\(.*\));/\1/")
                        vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]=$(echo "codegen ({[$listevar2]->[$listevar2]}*$EnteteP -> {$slexmin});" | iscc)
                        ## sometimes iscc introduces an int variable (int c0, or int c1, ...) into lexmins in order to express a condition and 2 possible substitutions of variable cx. This case must be handled. Below it starts with a test if there is an "int c".
                        if ! (echo "${vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}" | grep -q "int c"); then
                            vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]=$(echo "${vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}" | grep ";" | sed "s/^ *//" | sed "s/(\(.*\));/\1/")
                            if ((dim >= 1)); then
                                listevar1[${CVAR}${cpt}${Period}${dim}]=$(echo "${listevar1[${CVAR}${cpt}${Period}${dim}]}" | sed "s/^,//")
                                vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]="${listevar1[${CVAR}${cpt}${Period}${dim}]}, ${vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}"
                            else
                                vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]=$(echo "${vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}" | sed "s/^ *,//")
                            fi
                            vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]=$(echo "${vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}" | sed "s/floord(\([^,]*\),\([^)]*\))/floor((\1)\/(\2))/g")
                            #vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]=$(echo "${vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]};" | "$F2F")
                            #vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]=$(echo "${vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]};" | "$P2M")
                            #Test s'il s'agit d'un domaine avec une égalité
                            egal=$(echo "${dlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}" | sed "s/.* \(=\) .*/\1/")
                            if [[ $egal == "=" ]]; then
                                IndDomEgal=$nmin
                                ((nbegal++))
                                echo "détection d'une égalité indice $IndDomEgal"
                                echo "dlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]=${dlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}"
                            fi
                        else # (echo ${vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]} | grep -v -q "int c") ==> there is an "int c" in the lexmin
                            condition2=$(echo "${vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}" | grep "int c" | sed "s/int c. = *\(.*\) *?.*/\1/")
                            dlex="${dlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}"
                            vlex="${vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}"
                            dlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]=$(echo "${dlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}" | sed "s/\(.*\)}/\1 and ${condition2}\}/")
                            c0=$(echo "${vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}" | grep "int c" | sed "s/.*? *\(.*\) *:.*;/\1/")
                            realnamec0=$(echo "${vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}" | grep "int c" | sed "s/ *int \(c.\).*/\1/")
                            vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]=$(echo "${vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}" | grep "(.*);" | sed "s/ *(\(.*\));/\1/" | sed "s/${realnamec0}/${c0}/g")
                            if ((dim >= 1)); then
                                listevar1[${CVAR}${cpt}${Period}${dim}]=$(echo "${listevar1[${CVAR}${cpt}${Period}${dim}]}" | sed "s/^,//")
                                vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]="${listevar1[${CVAR}${cpt}${Period}${dim}]}, ${vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}"
                            else
                                vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]=$(echo "${vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}" | sed "s/^ *,//")
                            fi
                            vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]=$(echo "${vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}" | sed "s/floord(\([^,]*\),\([^)]*\))/floor((\1)\/(\2))/g")

                            ((nmin++))
                            dlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]=$(echo "${dlex}" | sed "s/\(.*\)}/\1 and not (${condition2})\}/")
                            c0=$(echo "${vlex}" | grep "int c" | sed "s/.*?.*: *\(.*\);/\1/")
                            vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]=$(echo "${vlex}" | grep "(.*);" | sed "s/ *(\(.*\));/\1/" | sed "s/${realnamec0}/${c0}/g")
                            if ((dim >= 1)); then
                                listevar1[${CVAR}${cpt}${Period}${dim}]=$(echo "${listevar1[${CVAR}${cpt}${Period}${dim}]}" | sed "s/^,//")
                                vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]="${listevar1[${CVAR}${cpt}${Period}${dim}]}, ${vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}"
                            else
                                vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]=$(echo "${vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}" | sed "s/^ *,//")
                            fi
                            vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]=$(echo "${vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}" | sed "s/floord(\([^,]*\),\([^)]*\))/floor((\1)\/(\2))/g")

                        fi
                    done
                    NPCMININT[${CVAR}${cpt}${Period}${dim}]=$nmin

                    #fusion
                    if ((nbegal == 1)); then
                        nmin=1
                        while ((nmin <= NPCMININT[${CVAR}${cpt}${Period}${dim}])); do
                            if [[ "${CVAR}${cpt}${Period}${dim}${nmin}" != "${CVAR}${cpt}${Period}${dim}${IndDomEgal}" ]]; then
                                if [[ $(echo "poly (${dlexminint[${CVAR}${cpt}${Period}${dim}${IndDomEgal}]}+${dlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}) = coalesce (${dlexminint[${CVAR}${cpt}${Period}${dim}${IndDomEgal}]}+${dlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]});" | iscc) == "True" ]]; then
                                    dlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]=$(echo "coalesce (${dlexminint[${CVAR}${cpt}${dim}${IndDomEgal}]}+${dlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]});" | iscc | sed 's/\([ +(-][0-9][0-9]*\)\([A-Z_a-z]\)/\1\*\2/g')
                                    echo "Fusion : dlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]=${dlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]}"
                                    #une sol en moins, compression des indices
                                    j=$((IndDomEgal + 1))
                                    while ((j <= NPCMININT[${CVAR}${cpt}${Period}${dim}])); do
                                        dlexminint[${CVAR}${cpt}${Period}${dim}$((j - 1))]="${dlexminint[${CVAR}${cpt}${Period}${dim}$j]}"
                                        vlexminint[${CVAR}${cpt}${Period}${dim}$((j - 1))]="${vlexminint[${CVAR}${cpt}${Period}${dim}$j]}"
                                        ((j++))
                                    done
                                    ((NPCMININT[${CVAR}${cpt}${Period}${dim}]--))
                                    break
                                fi
                            fi
                            ((nmin++))
                        done
                    else
                        if ((nbegal > 1)); then
                            echo "ERROR: several domains with equalities!"
                            exit 1
                        fi
                    fi # LEXMAX int
                    if [ "${CVAR}" = "${NAME[1]}" -a "$dim" = "1" ]; then
                        all_slexmax="$(echo "coalesce lexmax $domaine;" | iscc | sed 's/\([ +(-][0-9][0-9]*\)\([A-Z_a-z]\)/\1*\2/g' | sed "s/^\[.*\] *-> *{\(.*\)}/\1/")"
                        nmax=0
                        IFS=";"
                        for slexmax in $all_slexmax; do
                            ((nmax++))
                            echo "------ lexmax n°$nmax: domain $cpt -- dimension $dim -- period ${Period}"
                            #          dlexmaxint[${CVAR}${cpt}${dim}${nmax}]=$(echo "params $slexmax;" | iscc | sed "s/.*{ *: *\(.*\) *}/{ $EnteteP : \1 }/" | sed 's/\([ +-][0-9][0-9]*\)\([A-Z_a-z]\)/\1\*\2/g')

                            dlexmaxint[${CVAR}${cpt}${Period}${dim}${nmax}]=$(echo "codegen ({[$listevar2]->[$listevar2]}*$EnteteP -> {$slexmax});" | iscc | tr -d ' ' | sed -n "1s/if(\(.*\))/\1/p" | sed "s/\&\&/ and /g" | sed "s/==/=/g" | sed "s/floord(\([^,]*\),\([^)]*\))/floor((\1)\/(\2))/g" | sed "s/ mod / % /g" | sed 's/\([ +(-][0-9][0-9]*\)\([A-Z_a-z]\)/\1\*\2/g' | sed "s/\(.*\)/{ $EnteteP : \1 }/")

                            vlexmaxint[${CVAR}${cpt}${Period}${dim}${nmax}]=$(echo "codegen ({[$listevar2]->[$listevar2]}*$EnteteP -> {$slexmax});" | iscc | sed -n "/$/s/(\(.*\));/\1/p")

                            vlexmaxint[${CVAR}${cpt}${Period}${dim}${nmax}]=$(echo "${vlexmaxint[${CVAR}${cpt}${Period}${dim}${nmax}]};" | $F2F)

                            #vlexmaxint[${CVAR}${cpt}${dim}${nmax}]=$(echo ${vlexmaxint[${CVAR}${cpt}${dim}${nmax}]} | sed "s/\([A-Z_a-z0-9()][A-Z_a-z0-9()]* *\/ *[A-Z_a-z0-9()][A-Z_a-z0-9()]*\)/floor(\1)/g")
                            listevar1[${CVAR}${cpt}${Period}${dim}]=$(echo "${listevar1[${CVAR}${cpt}${Period}${dim}]}" | sed "s/^,//")
                            vlexmaxint[${CVAR}${cpt}${Period}${dim}${nmax}]="${listevar1[${CVAR}${cpt}${Period}${dim}]}, ${vlexmaxint[${CVAR}${cpt}${Period}${dim}${nmax}]}"
                        done
                        NPCMAXINT[${CVAR}${cpt}${Period}${dim}]=$nmax
                    fi

                    ((dim++))
                done
                NPCMININT[${CVAR}${cpt}${Period}$N]=1
            done # for ((Period=1 ; $(( NPeriod[${cpt}]+1 )) - ${Period} ; Period++))
            ((cpt++))
        done
    else # do not compute deep lexmin in case of dichotomy search, but build listevar1

        cpt=1
        while ((cpt <= nsol[${CVAR}])); do
            # Pour chaque periode
            for ((Period = 1; $((NPeriod[${CVAR}${cpt}] + 1)) - ${Period}; Period++)); do
                # Pour chaque dimension
                #dim=1
                dim=0
                while ((dim <= N - 1)); do
                    #### begin OPTIM TILING
                    if [ "${dim}" -gt 1 -a "${t_flag}" = 'true' ]; then
                        #if (( (dim > 1) && (t_flag == 'true') )); then
                        break
                    fi
                    #### end OPTIM TILING
                    if ((dim >= 1)); then

                        listevar1[${CVAR}${cpt}${Period}${dim}]=""
                        i=1
                        while ((i <= dim)); do
                            if ((i == 1)); then
                                listevar1[${CVAR}${cpt}${Period}${dim}]=,${VAR[${CVAR}${i}]}
                            else
                                listevar1[${CVAR}${cpt}${Period}${dim}]="${listevar1[${CVAR}${cpt}${Period}${dim}]}, ${VAR[${CVAR}${i}]}"
                            fi
                            ((i++))
                        done
                        listevar1[${CVAR}${cpt}${Period}${dim}]=$(echo "${listevar1[${CVAR}${cpt}${Period}${dim}]}" | sed "s/^,//")
                    fi
                    ((dim++))
                done
            done # for ((Period=1 ; $(( NPeriod[${cpt}]+1 )) - ${Period} ; Period++))
            ((cpt++))
        done

    fi # end of Computing deep lexmin is useless in case of dichotomy search
    # Computing Trahrhe expressions is useless in case of dichotomy search
    if ! [[ "${m_flag}" = "true" && "${masque:$(($1 - 1)):1}" = [Dd] ]]; then
        #######################################################
        # Calcul des pcmin par période
        echo "---- Min values of ranking polynomials over each of their domains and periods: pcmin"
        cpt=1
        while ((cpt <= nsol[${CVAR}])); do

            for ((Period = 1; $((NPeriod[${CVAR}${cpt}] + 1)) - ${Period}; Period++)); do
                npc=1
                while ((npc <= NPCMININT[${CVAR}${cpt}${Period}0])); do
                    echo "------ pcmin n°$npc/${NPCMININT[${CVAR}${cpt}${Period}0]} -- domain $cpt/${nsol[${CVAR}]} -- period ${Period}"
                    TMP1=$(echo "${vlexminint[${CVAR}${cpt}${Period}0${npc}]};" | "$P2M")
                    pcminPeriod[${CVAR}${cpt}${Period}${npc}]=$(echo "display2d:false$ ${Maxima_declare} r(${listevar[${CVAR}]}):=${RSA[V${CVAR}N${cpt}P${Period}]}$ factor(r(${TMP1}));" | maxima --very-quiet | tr -d '\n' | tr -d ' ')
                    ((npc++))
                done
            done # for ((Period=1 ; $(( NPeriod[${cpt}]+1 )) - ${Period} ; Period++))
            ((cpt++))
        done

        ########################################################

        # Résolution des équations
        echo "---- Computing the Trahrhe expressions"
        cpt=1
        while ((cpt <= nsol[${CVAR}])); do
            # Pour chaque periode
            for ((Period = 1; $((NPeriod[${CVAR}${cpt}] + 1)) - ${Period}; Period++)); do
                # Pour chaque dimension
                dim=1
                while ((dim <= N)); do
                    #### begin OPTIM TILING
                    if [ "${dim}" -gt 1 -a "${t_flag}" = 'true' ]; then
                        break
                    fi
                    #### end OPTIM TILING
                    if [ "$e_flag" = "true" -a "$t_flag" = "" ] && [[ "${masque:$((dim - 1)):1}" =~ [dDgG] ]]; then
                        ((dim++))
                        continue
                    fi
                    nmin=1
                    while ((nmin <= NPCMININT[${CVAR}${cpt}${Period}${dim}])); do
                        if ((dim == N)); then
                            variables="${listevar[${CVAR}]}"
                        else
                            variables=$(echo "${vlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]};" | "$P2M")
                        fi
                        nbsol=$(echo "display2d:false\$ solveradcan:true\$ ${Maxima_declare} r(${listevar[${CVAR}]}):=${RSA[V${CVAR}N${cpt}P${Period}]}\$ sols:solve(r($variables)-pc,${VAR[${CVAR}${dim}]})\$ length(sols);" | maxima --very-quiet | tr -d '\n' | tr -d ' ')
                        nbsol=$(echo "$nbsol" | tr -d '\n')
                        # si plusieurs solutions
                        if ((nbsol > 1)); then
                            # recherche de la bonne solution
                            i=1
                            while ((i <= nbsol)); do
                                sol[$i]=$(echo "display2d:false\$ solveradcan:true\$ ${Maxima_declare} r(${listevar[${CVAR}]}):=${RSA[V${CVAR}N${cpt}P${Period}]}\$ sols:solve(r($variables)-pc,${VAR[${CVAR}${dim}]})\$ sols[$i];" | maxima --very-quiet | tr -d '\n' | tr -d ' ')
                                sol[$i]=$(echo "${sol[$i]}" | sed "s/.*=\(.*\)/\1/" | tr -d '\n' | tr -d ' ')
                                # roots must not be simplified => yields wrong expressions and evaluations (complex numbers)
                                #expression=$sol
                                #MinLong
                                #sol=$expression
                                if ((dim > 1)); then
                                    IFS=","
                                    l=1
                                    for c in ${vlexminint[${CVAR}${cpt}${Period}0${nmin}]}; do
                                        if ((l == dim)); then
                                            lmin=$c
                                            break
                                        fi
                                        ((l++))
                                    done
                                    lmin=$(echo "$lmin;" | "$P2M")
                                    sample=$(echo "sample ${dlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]};" | iscc)
                                    sample=$(echo "$sample" | tr -d '{' | tr -d '}' | tr -d '[' | tr -d ']')
                                    IFS=","
                                    subst=""
                                    set - $sample
                                    nb=$#
                                    ne=1
                                    for elt in $sample; do
                                        if ((ne < nb)); then
                                            elt=$(echo "$elt" | sed 's/=/:/')
                                            subst=${subst}$elt\$
                                        fi
                                        ((ne++))
                                    done

                                    # test if maxima insufficient precision results in a value close to 0
                                    test=$(echo "display2d:false\$ ${Maxima_declare} f(pc,${Params[$CVAR]},${listevar1[${CVAR}${cpt}${Period}$((dim - 1))]}):=${sol[$i]}\$ ${subst} is(abs(f(${pcminPeriod[${CVAR}${cpt}${Period}${nmin}]},${Params[$CVAR]},${listevar1[${CVAR}${cpt}${Period}$((dim - 1))]}))<1E-13);" | maxima --very-quiet | tr -d '\n' | tr -d ' ')
                                    if [ "$test" = "true" ]; then
                                        test=$(echo "display2d:false\$ ${Maxima_declare} ${subst} is(equal(0,$lmin));" | maxima --very-quiet | tr -d '\n' | tr -d ' ')
                                    else
                                        #test=$(echo "display2d:false\$ ${Maxima_declare} f(pc,${Params[$CVAR]},${listevar1[${CVAR}${cpt}${Period}$((dim - 1))]}):=$sol\$ $subst is(equal(float(realpart(f(${pcminPeriod[${CVAR}${cpt}${Period}${nmin}]},${Params[$CVAR]},${listevar1[${CVAR}${cpt}${Period}$((dim - 1))]}))),float($lmin)));" | maxima --very-quiet | tr -d '\n' | tr -d ' ')
                                        test=$(echo "display2d:false\$ ${Maxima_declare} f(pc,${Params[$CVAR]},${listevar1[${CVAR}${cpt}${Period}$((dim - 1))]}):=${sol[$i]}\$ ${subst} is(abs(bfloat(realpart(f(${pcminPeriod[${CVAR}${cpt}${Period}${nmin}]},${Params[$CVAR]},${listevar1[${CVAR}${cpt}${Period}$((dim - 1))]})))-bfloat(floor($lmin)))<1E-13) and is(equal(bfloat(imagpart(f(${pcminPeriod[${CVAR}${cpt}${Period}${nmin}]},${Params[$CVAR]},${listevar1[${CVAR}${cpt}${Period}$((dim - 1))]}))),bfloat(0)));" | maxima --very-quiet | tr -d '\n' | tr -d ' ')
                                    fi
                                    test=$(echo "$test" | tr -d '\n' | tr -d ' ')
                                    if [ "$test" = "true" ]; then
                                        echo "------ Trahrhe expression n°$nmin: domain $cpt -- dimension $dim -- period ${Period}"
                                        trahrhe[${CVAR}${cpt}${Period}${dim}${nmin}]="${sol[$i]}"
                                        nocode=0
                                        break
                                    else
                                        trahrhe[${CVAR}${cpt}${Period}${dim}${nmin}]="**** Unable to find the Trahrhe Expression ****"
                                        nocode=1
                                    fi
                                else
                                    ########################################################################
                                    IFS=","
                                    l=1
                                    for c in ${vlexminint[${CVAR}${cpt}${Period}0${nmin}]}; do
                                        if ((l == dim)); then
                                            lmin=$c
                                            break
                                        fi
                                        ((l++))
                                    done
                                    lmin=$(echo "$lmin;" | "$P2M")
                                    sample=$(echo "sample ${dlexminint[${CVAR}${cpt}${Period}${dim}${nmin}]};" | iscc)
                                    sample=$(echo "$sample" | tr -d '{' | tr -d '}' | tr -d '[' | tr -d ']')
                                    IFS=","
                                    subst=""
                                    set - $sample
                                    nb=$#
                                    ne=1
                                    for elt in $sample; do
                                        if ((ne < nb)); then
                                            elt=$(echo "$elt" | sed 's/=/:/')
                                            subst="${subst}$elt\$"
                                        fi
                                        ((ne++))
                                    done
                                    # test if maxima insufficient precision results in a value close to 0
                                    test=$(echo "display2d:false\$ ${Maxima_declare} f(pc,${Params[$CVAR]}):=${sol[$i]}\$ ${subst} is(abs(f(${pcminPeriod[${CVAR}${cpt}${Period}${nmin}]},${Params[$CVAR]}))<1E-13);" | maxima --very-quiet | tr -d '\n' | tr -d ' ')
                                    if [ "$test" = "true" ]; then
                                        test=$(echo "display2d:false\$ ${Maxima_declare} ${subst} is(equal(0,$lmin));" | maxima --very-quiet | tr -d '\n' | tr -d ' ')
                                    else
                                        #test=$(echo "display2d:false\$ ${Maxima_declare} f(pc,${Params[$CVAR]}):=$sol\$ $subst is(equal(float(realpart(f(${pcminPeriod[${CVAR}${cpt}${Period}${nmin}]},${Params[$CVAR]}))),float($lmin)));" | maxima --very-quiet | tr -d '\n' | tr -d ' ')
                                        test=$(echo "display2d:false\$ ${Maxima_declare} f(pc,${Params[$CVAR]}):=${sol[$i]}\$ ${subst} is(abs(bfloat(realpart(f(${pcminPeriod[${CVAR}${cpt}${Period}${nmin}]},${Params[$CVAR]})))-bfloat(floor($lmin)))<1E-13) and is(equal(bfloat(imagpart(f(${pcminPeriod[${CVAR}${cpt}${Period}${nmin}]},${Params[$CVAR]}))),bfloat(0)));" | maxima --very-quiet | tr -d '\n' | tr -d ' ')
                                    fi
                                    test=$(echo "$test" | tr -d '\n' | tr -d ' ')
                                    if [ "${test}" = "true" ]; then
                                        echo "------ Trahrhe expression n°$nmin: domain $cpt -- dimension $dim -- period ${Period}"
                                        trahrhe[${CVAR}${cpt}${Period}${dim}${nmin}]="${sol[$i]}"
                                        nocode=0
                                        break
                                    else
                                        trahrhe[${CVAR}${cpt}${Period}${dim}${nmin}]="**** Unable to find the Trahrhe Expression ****"
                                        nocode=1
                                    fi
                                    #######################################
                                fi
                                ((i++))
                            done
                            if [ "${test}" = "false" ]; then
                                trahrhe[${CVAR}${cpt}${Period}${dim}${nmin}]="**** Unable to find the Trahrhe Expression ****"
                                nocode=1
                            fi
                        else
                            if ((nbsol != 0)); then # une seule solution
                                echo "------ Trahrhe expression n°$nmin: domain $cpt -- dimension $dim -- period ${Period}"
                                sol=$(echo "display2d:false\$ solveradcan:true\$ ${Maxima_declare} r(${listevar[$CVAR]}):=${RSA[V${CVAR}N${cpt}P${Period}]}\$ sols:solve(r($variables)-pc,${VAR[${CVAR}${dim}]})\$ sols[1];" | maxima --very-quiet | tr -d '\n' | tr -d ' ')
                                sol=$(echo "$sol" | sed "s/.*=\(.*\)/\1/" | tr -d '\n' | tr -d ' ')
                                expression=$sol
                                MinLong
                                sol=$expression
                                trahrhe[${CVAR}${cpt}${Period}${dim}${nmin}]="$sol"
                            else # no solution
                                #echo "NO SOLUTION"
                                echo "------ Trahrhe expression n°$nmin: domain $cpt -- dimension $dim -- period ${Period}"
                                domain=$(echo "${DSA[V${CVAR}N${cpt}P${Period}]}" | sed "s/\] *:/\]-> ${VAR[${CVAR}${dim}]} :/")
                                trahrhe[${CVAR}${cpt}${Period}${dim}${nmin}]=$(echo "lb ${domain};" | iscc | sed "s/.*min(\(.*\)) :.*/\1/" | sed "s/(\(.*\))/\1/")
                                #trahrhe[${CVAR}${cpt}${Period}${dim}${nmin}]=$(echo "display2d:false\$ factor(${trahrhe[${CVAR}${cpt}${Period}${dim}${nmin}]=});" | maxima --very-quiet | tr -d '\n' | tr -d ' ')
                                expression="${trahrhe[${CVAR}${cpt}${Period}${dim}${nmin}]}"
                                MinLong
                                trahrhe[${CVAR}${cpt}${Period}${dim}${nmin}]="${expression}"
                                #echo "trahrhe[${CVAR}${cpt}${Period}${dim}${nmin}]=${trahrhe[${CVAR}${cpt}${Period}${dim}${nmin}]}"
                            fi
                            #if [ "${trahrhe[${CVAR}${cpt}${Period}${dim}${nmin}]}" = "**** Unable to find the Trahrhe Expression ****" ]; then
                            #echo "-------- **** Unable to find the Trahrhe Expression ****"
                            #nocode=1
                            #fi
                        fi

                        if [ "${trahrhe[${CVAR}${cpt}${Period}${dim}${nmin}]}" = "**** Unable to find the Trahrhe Expression ****" ]; then
                            echo -n "------ **** Unable to find the Trahrhe Expression: "
                            echo "Manual selection of the right root ****"
                            for ((i = 1; i <= nbsol; i++)); do
                                echo "($i) ${VAR[${CVAR}${dim}]} = ${sol[$i]}"
                            done
                            for ((priod = 1; priod <= NPeriod[${CVAR}${cpt}]; priod++)); do
                                for ((nbmin = 1; nbmin <= NPCMININT[${CVAR}${cpt}${priod}${dim}]; nbmin++)); do
                                    IFS=","
                                    l=1
                                    for c in ${vlexminint[${CVAR}${cpt}${priod}0${nbmin}]}; do
                                        if ((l == dim)); then
                                            lmin=$c
                                            break
                                        fi
                                        ((l++))
                                    done
                                    lmin=$(echo "$lmin;" | "$P2M")
                                    sample=$(echo "sample ${dlexminint[${CVAR}${cpt}${priod}${dim}${nbmin}]};" | iscc)
                                    sample=$(echo "$sample" | tr -d '{' | tr -d '}' | tr -d '[' | tr -d ']')
                                    IFS=","
                                    subst=""
                                    set - $sample
                                    nb=$#
                                    ne=1
                                    for elt in $sample; do
                                        if ((ne < nb)); then
                                            elt=$(echo "$elt" | sed 's/=/:/')
                                            subst="${subst}$elt\$"
                                        fi
                                        ((ne++))
                                    done
                                    echo "-- valid parameter values (sample): ${subst} -- pcmin: pc : ${pcminPeriod[${CVAR}${cpt}${priod}${nbmin}]}\$ -- lexmin of ${VAR[${CVAR}${dim}]}: ${lmin}"
                                done # for (( nbmin=1; nbmin<=NPCMININT[${CVAR}${cpt}${priod}${dim}]; nbmin++ ))
                            done     # for (( priod=1; priod<=NPeriod[${CVAR}${cpt}]; priod++ ))
                            echo -n "Select the right root (0 to cancel): "
                            read i
                            if (((i >= 1) && (i <= nbsol))); then
                                trahrhe[${CVAR}${cpt}${Period}${dim}${nmin}]="${sol[$i]}"
                                echo "--YES- Trahrhe expression n°$nmin: domain $cpt -- dimension $dim -- period ${Period}"
                                nocode=0
                            else
                                echo "--N0-- Trahrhe expression n°$nmin: domain $cpt -- dimension $dim -- period ${Period}"
                                nocode=1
                            fi
                        fi

                        ((nmin++))
                    done
                    ((dim++))
                done
            done # ((Period=1 ; $(( NPeriod[${cpt}]+1 )) - ${Period} ; Period++))
            ((cpt++))
        done

        # boucle de fusion des périodes si les expressions trahrhe sont égales
        PeriodMerge() {
            cpt=1
            while ((cpt <= nsol[${CVAR}])); do
                dim=1
                while ((dim <= N)); do
                    egal[${CVAR}${cpt}${dim}]=1
                    for ((Period = 2; $((NPeriod[${CVAR}${cpt}] + 1)) - ${Period}; Period++)); do
                        if [ "${NPCMININT[${CVAR}${cpt}${Period}${dim}]}" = "1" ]; then
                            if [ "${trahrhe[${CVAR}${cpt}1${dim}1]}" != "${trahrhe[${CVAR}${cpt}${Period}${dim}1]}" ]; then
                                egal[${CVAR}${cpt}${dim}]=0
                                break
                            fi
                            if ((dim < N)); then
                                echo "---- Merging OK"
                                dlexminint[${CVAR}${cpt}1${dim}1]=$(echo "${dlexminint[${CVAR}${cpt}1${dim}1]}+${dlexminint[${CVAR}${cpt}${Period}${dim}1]};" | iscc | sed "s/\&\&/ and /g" | sed "s/==/=/g" | sed "s/floord(\([^,]*\),\([^)]*\))/floor((\1)\/(\2))/g" | sed "s/ mod / % /g" | sed 's/\([ +(-][0-9][0-9]*\)\([A-Z_a-z]\)/\1\*\2/g')
                            fi
                        else
                            egal[${CVAR}${cpt}${dim}]=0
                            break
                        fi
                    done # for ((Period=2 ; $(( NPeriod[${cpt}]+1 )) - ${Period} ; Period++))
                    #echo "egal[${cpt}${dim}]=${egal[${cpt}${dim}]}"
                    #echo "dlexminint[${cpt}1${dim}1]=${dlexminint[${cpt}1${dim}1]}"
                    if [ "${egal[${CVAR}${cpt}${dim}]}" = "1" ]; then
                        NPeriod[${CVAR}${cpt}]=1
                        RSA[V${CVAR}N${cpt}P1]="${RS[${CVAR}${cpt}]}"
                        DSA[V${CVAR}N${cpt}P1]="${DS[${CVAR}${cpt}]}"
                    fi
                    ((dim++))
                done
                ((cpt++))
            done
        }
        #echo "---- Merging periods of identical Trahrhe expressions"
        #PeriodMerge
    fi # end of Computing Trahrhe expressions is useless in case of dichotomy search
}      # end trahrhe_math()

#Fin partie mathématique
