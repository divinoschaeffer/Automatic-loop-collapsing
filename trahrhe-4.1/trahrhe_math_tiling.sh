#===--- trahrhe_math_tiling.sh -------------------------------------------===#
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

trahrhe_math_tiling() {

    # dépend d'une variable dont le nom est stocké dans CVAR
    typeset CVAR prof cpt i equations equations1 lexmin lexmax

    CVAR=$(echo "$1" | tr -d ' ')
    prof="$2"

    typeset card dcard cpt var prev_var ajout Resultat nbre_domaines domsol U ndom M all_slexmin slexmin nmin liste domaine elt all_slexmax nmax slexmax npc dim listevar2 EnteteP variables nbsol l c lmin i
    typeset sample subst nb ne test

    #Construction du nouveau domaine où CVAR est l'indice externe et où on ajoute les bornes de tiles
    echo "---- Building the tiling domain for index $CVAR"
    #DEBUG echo "ICIII D=$D"
    listevar=$(echo "$D" | sed "s/.*\[.*\].*\[\(.*\)\].*/\1/")
    DT=$D
    cpt=1
    while ((cpt <= prof)); do
        if ((cpt > 1)); then
            # 1. codegen pour avoir les bornes de l'indice sur lequel on va tiler, en respectant l'ordre lexico initial
            #DEBUG echo "ICIII codegen ({[$listevar]->[$listevar]}*$D);"
            Bornes=$(echo "codegen ({[$listevar]->[$listevar]}*$D);" | iscc | grep "int c$((cpt - 2))")
            # 2. récupération des bornes de boucles de l'indice de profondeur courante
            Binf=$(echo "$Bornes" | sed "s/.*int c$((cpt - 2)) = \([^;]*\);.*/\1/")
            Bsup=$(echo "$Bornes" | sed -n "s/^.*c$((cpt - 2)) <= \([^;]*\);.*/\1/p") # cas borne <=
            if [ -z "$Bsup" ]; then
                Bsup=$(echo "$Bornes" | sed -n "s/^.*c$((cpt - 2)) < \([^=;]*\);.*/\1-1/p") # cas borne <
            fi
            
            # 3. substitution des noms de variables de la première à la variable courante -1
            nvar=1
            while ((nvar < cpt)); do #there should not be any variable X inside lb or ub constraints when tiling => change them to lbX and ubX
                Binf=$(echo "$Binf" | sed "s/c$((nvar - 1))/lb${NAME[$nvar]}/g") 
                Bsup=$(echo "$Bsup" | sed "s/c$((nvar - 1))/ub${NAME[$nvar]}/g")
                Binf=$(echo "$Binf" | sed "s/\(- *[0-9]* *\)lb${NAME[$nvar]}/\1ub${NAME[$nvar]}/g") #Vérifier le signe de cX => lb ou ub
                Bsup=$(echo "$Bsup" | sed "s/\(- *[0-9]* *\)ub${NAME[$nvar]}/\1lb${NAME[$nvar]}/g")
                ((nvar++))
            done
            
            #DEBUG echo " "
            #echo "Binf=$Binf"
            #echo "Bsup=$Bsup"
            # 4. ajout des contraintes relatives aux bornes des tiles
            #DEBUG echo "4. ajout des contraintes relatives aux bornes des tiles"
            #DEBUG echo "$DT" | sed "s/\(\[.*\)\(\] *->.*\)/\1,lb${NAME[$(( cpt-1 ))]},ub${NAME[$(( cpt-1 ))]}\2/"
            DT=$(echo "$DT" | sed "s/\(\[.*\)\(\] *->.*\)/\1,lb${NAME[$((cpt - 1))]},ub${NAME[$((cpt - 1))]}\2/") # mise à jour de l'entête
            Binf=$(echo "$Binf" | sed "s/\//\\\\\//g")                                                            # PB pour sed d'un / dans la borne, genre t1/2
            Bsup=$(echo "$Bsup" | sed "s/\//\\\\\//g")
            
            
            #DEBUG echo "$DT" | sed "s/\(.*\)}/\1 and ${Binf}<=lb${NAME[$(( cpt-1 ))]} and ub${NAME[$(( cpt-1 ))]}<=${Bsup} and lb${NAME[$(( cpt-1 ))]}<=${NAME[$(( cpt-1 ))]}<=ub${NAME[$(( cpt-1 ))]} }/"
            DT=$(echo "$DT" | sed "s/\(.*\)}/\1 and ${Binf}<=lb${NAME[$((cpt - 1))]} and ub${NAME[$((cpt - 1))]}<=${Bsup} and lb${NAME[$((cpt - 1))]}<=${NAME[$((cpt - 1))]}<=ub${NAME[$((cpt - 1))]} }/") # ajout des contraintes
        fi
        ((cpt++))
    done
  
    # 5. Mise en 1er de la variable courante
    #DEBUG echo "5. Mise en 1er de la variable courante"
    DT=$(echo "$DT" | sed "s/\(\[.*\].*\[\) *$CVAR\(.*\]\)/\1$CVAR\2/")
    DT=$(echo "$DT" | sed "s/\(\[.*\].*\[\)\(.*\), *$CVAR *,\(.*\]\)/\1$CVAR,\2,\3/")
    DT=$(echo "$DT" | sed "s/\(\[.*\].*\[\)\(.*\), *$CVAR *\]/\1$CVAR,\2\]/")
    DT=$(echo "P:=${DT};P;" | iscc | sed 's/\([ +(-][0-9][0-9]*\)\([A-Z_a-z]\)/\1\*\2/g' | sed 's/) *(/)\*(/g')

    #echo " "
    #echo "LE DOMAINE QUE J'AI CRéé: $DT"
    #echo " "
    lD[$CVAR]="$DT"

    . trahrhe_math.sh
    trahrhe_math "${prof}"

    #recherche du volume de tile minimum pour TILE_VOL_L1
    if [ "${CVAR}" = "${NAME[1]}" ]; then
        echo "---- Computing the minimal tile volume for the outermost dimension ${NAME[1]}"
        ntilemax=0
        cpt=1
        while ((cpt <= nsol[${NAME[1]}])); do
            for ((Period = 1; $((NPeriod[${CVAR}${cpt}] + 1)) - ${Period}; Period++)); do
                nmin=1
                while ((nmin <= NPCMININT[${NAME[1]}${cpt}${Period}1])); do
                    nmax=1
                    while ((nmax <= NPCMAXINT[${NAME[1]}${cpt}${Period}1])); do
                        dlexminint[${NAME[1]}${cpt}${Period}1${nmin}]=$(echo "${dlexminint[${NAME[1]}${cpt}${Period}1${nmin}]}" | sed "s/(\([1-9][0-9]*\))/\1/g")
                        dlexmaxint[${NAME[1]}${cpt}${Period}1${nmin}]=$(echo "${dlexmaxint[${NAME[1]}${cpt}${Period}1${nmin}]}" | sed "s/(\([1-9][0-9]*\))/\1/g")
                        sortie=$(echo "coalesce (${dlexminint[${NAME[1]}${cpt}${Period}1${nmin}]}*${dlexmaxint[${NAME[1]}${cpt}${Period}1${nmin}]});" | iscc | sed 's/\([ +(-][0-9][0-9]*\)\([A-Z_a-z]\)/\1*\2/g')
                        #| sed "s/\({ \[.*\)\([A-Za-z_][A-Za-z0-9_]* = [A-Za-z0-9_][A-Za-z0-9_]*\)\(.*\].*\)}/\1\2\3 and \2}/g")
			ListeDansCrochet=$(echo "$sortie" | sed "s/.*\[\(.*\)\].*/\1/")
			IFS=","
			ListeEgalites=""
			for ElementDansListe in $ListeDansCrochet; do
			  if (echo "${ElementDansListe}" | grep -q "="); then
			    ListeEgalites="${ListeEgalites}, ${ElementDansListe}"
			  fi
			done
			sortie=$(echo "$sortie" | sed "s/\(.*\)\}/\1${ListeEgalites}\}/")
                        DOMTILEMAX[${cpt}$((ntilemax + 1))]="$sortie"
                        sortie=$(echo "$sortie" | sed "s/ *\[.*\] *-> *\(.*\)/\1/")
                        if [[ $sortie != "{  }" ]]; then
                            ((ntilemax++))
                            TILEMAX[${cpt}${ntilemax}]=$(echo "display2d:false\$ ${Maxima_declare} r(${listevar[${NAME[1]}]}):=${RSA[V${NAME[1]}N${cpt}P${Period}]}\$ r(${vlexmaxint[${NAME[1]}${cpt}${Period}1${nmin}]})-r(${vlexminint[${NAME[1]}${cpt}${Period}1${nmin}]})+1;" | maxima --very-quiet | tr -d '\n' | tr -d ' ')
                            TILEMAX[${cpt}${ntilemax}]=$(echo "${TILEMAX[${cpt}${ntilemax}]}" | tr -d ' ' | tr -d '\n')
                            TILEMAX[${cpt}${ntilemax}]=$(echo "display2d:false$ ${Maxima_declare} factor(${TILEMAX[${cpt}${ntilemax}]});" | maxima --very-quiet | tr -d '\n' | tr -d ' ')
                            TILEMAX[${cpt}${ntilemax}]=$(echo "${TILEMAX[${cpt}${ntilemax}]}" | tr -d ' ' | tr -d '\n')
                            numerator=$(echo "display2d:false$ ${Maxima_declare} num(${TILEMAX[${cpt}${ntilemax}]});" | maxima --very-quiet | tr -d '\n' | tr -d ' ')
                            denominator=$(echo "display2d:false$ ${Maxima_declare} denom(${TILEMAX[${cpt}${ntilemax}]});" | maxima --very-quiet | tr -d '\n' | tr -d ' ')
                            TILEMAX[${cpt}${ntilemax}]="(${numerator}) * 1/${denominator}"
                            TILEMAX[${cpt}${ntilemax}]=$(echo "${TILEMAX[${cpt}${ntilemax}]}" | tr -d ' ' | tr -d '\n')
                            equations=$(echo "${DOMTILEMAX[${cpt}${ntilemax}]}" | sed "s/.*:\(.*\)\}/\1/")
                            equations=$(echo "${equations}" | sed "s/ , / and /g")
                            if (echo "${Params[${NAME[1]}]}" | grep -v -q "NOT_A_PARAMETER"); then 
                              sortie=$(echo "ub [${Params[${NAME[1]}]}] -> { [${NAME[1]}] -> ${TILEMAX[${cpt}${ntilemax}]} : ${equations} };" | iscc | sed 's/\([ +(-][0-9][0-9]*\)\([A-Z_a-z]\)/\1*\2/g')
                              if (echo "$sortie" | grep -v -q "{  }, True"); then
                                TILEMAX[${cpt}${ntilemax}]="${sortie}"
                              fi
                              TILEMAX[${cpt}${ntilemax}]=$(echo "${TILEMAX[${cpt}${ntilemax}]}" | sed "s/.*max(\(.*\)).*:.*/\1/" | sed "s/) *(/)\*(/g")
                            else
                              TILEMAX[${cpt}${ntilemax}]=$(( ${TILEMAX[${cpt}${ntilemax}]} ))
                            fi
                        fi
                        ((nmax++))
                    done
                    ((nmin++))
                done
            done # Period
            ((cpt++))
        done
    fi
} # fin trahrhe_math_tiling()
