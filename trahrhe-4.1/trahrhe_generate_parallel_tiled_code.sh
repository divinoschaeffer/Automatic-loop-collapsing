#===--- trahrhe_generate_parallel_tiled_code.sh --------------------------===#
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

generate_parallel_tiling_code() {
    typeset i j
    typeset TBlist
    typeset param
    typeset indent
    typeset mapping
    typeset code
    typeset maskparams
    typeset vars
    typeset mask
    typeset nbvars
    typeset borne
    typeset nb_tiling_levels

    exec 3>&1
    exec >"trahrhe_tiling_parallel.c"

    echo "#include <stdio.h>"
    echo "#include <stdlib.h>"
    echo "#include <sys/sysinfo.h>"
    echo "#include <math.h>"
    echo "#include <omp.h>"

    nb_tiling_levels=$1

    echo "#include \"trahrhe_tiling_header.h\""
    echo " "
    echo "#define ceild(n,d)  ceil(((double)(n))/((double)(d)))"
    echo "#define floord(n,d) floor(((double)(n))/((double)(d)))"
    echo "#define max(x,y)    ((x) > (y)? (x) : (y))"
    echo "#define min(x,y)    ((x) < (y)? (x) : (y))"
    echo " "
    echo "int main(int argc, char *argv[]) {"
    echo " "
    echo "  FILE* fp;"
    echo "  long int $listevar;"
    echo "  long int $params;"
    echo "  long int trahrhe, pc=0;"
    echo "  long int ltc;"
    echo "  long int nberrors=0;"
    #echo "  long int gdeviation[$((N + 1))]={$(for ((i = 1; i < $((N + 1)); i++)); do echo -n "0, "; done)0}, gdcpt[$((N + 1))]={$(for ((i = 1; i < $((N + 1)); i++)); do echo -n "0, "; done)0};"
    echo " "
    i=1
    TBlist=""
    while ((i <= nb_tiling_levels)); do
        echo "  long int T${NAME[i]}, ubT${NAME[i]}, lb${NAME[i]}, ub${NAME[i]}, TILE_VOL_L$i, NUMBER_OF_SLICES_L$i, ${NAME[i]}_pcmax;"
        TBlist="$TBlist NUMBER_OF_SLICES_L$i"
        ((i++))
    done
    echo " "

    TBlist=$(echo "$TBlist" | sed 's/^ //')

    IFS=", "
    set - $params
    nbparams=$#

    echo "  if (argc < $((nbparams + nb_tiling_levels + 1))) {"
    echo "    printf(\"Usage: %s $(echo "$params $TBlist" | sed 's/ *, */ /g')\\n\",argv[0]);"
    echo "    return 1;"
    echo "  }"
    echo " "

    i=1
    for param in $params; do
        echo "  $param = atoi(argv[$i]);"
        ((i++))
    done
    IFS=" "
    for param in $TBlist; do
        echo "  $param = atoi(argv[$i]);"
        ((i++))
    done
    echo " "
    echo "  char nproc[3];"
    echo "  sprintf(nproc,\"%d\",get_nprocs());"
    echo "  setenv(\"OMP_NUM_THREADS\",nproc,0);"
    echo "  const int NT = atoi(getenv(\"OMP_NUM_THREADS\"));"
    echo "  printf(\"Number of threads set to %d\\n\",NT);"
    echo "  printf(\"Total Number of Iterations: %ld * Perfect theoretical load balancing: TILE_VOL_L1 = %ld * Minimal Tile Volume: TILE_VOL_L1 = %ld\\n\",${NAME[1]}_Ehrhart(${Params[${NAME[1]}]}),${NAME[1]}_Ehrhart(${Params[${NAME[1]}]})/NT,TILEMIN(${Params[${NAME[1]}]}));"
    echo " "
    echo "  long int local_pc[NT], local_nberrors[NT];"
    echo "  for (int i=0; i<NT; i++) { local_pc[i]=0; local_nberrors[i]=0; }"
    #echo "  long int deviation[NT][$((N + 1))],dcpt[NT][$((N + 1))];"
    #echo "  for (int i=0; i<NT; i++) for (int j=0; j<$((N + 1)); j++) {deviation[i][j]=0; dcpt[i][j]=0;}"
    echo " "
    echo "  fp=fopen(\"trahrhe_tiling_ERRORS.txt\",\"w\");"
    echo "  setbuf(stdout, NULL);"
    echo "  putchar('[');"
    echo "  for (int i = 0;  i < 100;  i++) putchar('.');"
    echo "  putchar(']');"
    echo "  putchar('\\r');"
    echo "  putchar('[');"
    echo " "
    echo "  ltc=(${NAME[1]}_Ehrhart($params)/100);"
    echo " "
    #indentation instructions internes
    indent=""
    i=1
    while ((i <= N)); do
        indent="$indent  "
        ((i++))
    done

    mapping="$(echo "$D" | sed 's/\({.*\)\(\[.*\]\)/\1\2->\2/')"
#(>&2 echo "**** codegen $mapping;")    
    code=$(echo "codegen $mapping;" | iscc --no-barvinok-isl-ast-build-allow-else)
    if (( $(echo "$code" | grep -c "if ") > 1 )); then
      (>&2 echo " ")
      (>&2 echo "**** WARNING: Several guards with several for loops in the (iscc) generated code! The verification code will not be correct ****")
      read -s -n1 -p "Press any key to continue..."; echo
      #exit 1
    fi
    code=$(echo "$code" | sed "/if (.*/d") #suppression du if s'il y a
    code=$(echo "$code" | sed '$d' | sed '$s/\(.*\)$/\1 {/')
    code=$(echo "$code" | sed 's/for (int /for (/g')
    # substitution des noms des indices de boucles
    i=0
    while ((i < N)); do
        code=$(echo "$code" | sed "s~c$i~${NAME[$((i + 1))]}~g")
        ((i++))
    done
    echo "$code"
    maskparams=""
    i=1
    while ((i <= nbparams)); do
        maskparams=$maskparams",%ld"
        ((i++))
    done
    maskparams=$(echo "$maskparams" | sed 's/^,//')

    # à revoir
    i=1
    while ((i <= nb_tiling_levels)); do
        LevelParams[$i]="${Params[${NAME[$i]}]}"
        ((i++))
    done

    i=1
    while ((i <= nb_tiling_levels)); do
        mask=$maskparams
        j=1
        while ((j <= (i - 1))); do
            mask=$mask",%ld,%ld"
            ((j++))
        done
        mask=$(echo "$mask" | sed 's/^,//')
        echo "$indent  trahrhe = ${NAME[$i]}_trahrhe_${NAME[$i]}(${NAME[$i]}_Ranking(${listevar[${NAME[$i]}]},${Params[${NAME[$i]}]}),${LevelParams[$i]});"
        echo "$indent  if (trahrhe != ${NAME[$i]}) {"
        echo "$indent    fprintf(fp,\"ERROR: ${NAME[$i]} = %ld <-> ${NAME[$i]}_trahrhe_${NAME[$i]}(%ld,$mask) = %ld\\n\",${NAME[$i]},${NAME[$i]}_Ranking(${listevar[${NAME[$i]}]},${Params[${NAME[$i]}]}),${Params[${NAME[$i]}]},trahrhe);"
        echo "$indent    nberrors++;"
        echo "$indent  }"
        ((i++))
    done
    echo "$indent  if ((local_pc[omp_get_thread_num()]+omp_get_thread_num())%max(ltc,1) == 0) putchar('#');"
    echo "$indent  local_pc[omp_get_thread_num()]++;"
    echo "$indent}"
    echo "  putchar('\\n');"
    echo " "
    echo "  for (int i=0; i<NT; i++) { pc+=local_pc[i]; nberrors+=local_nberrors[i]; }"
    echo "  if (pc != ${NAME[1]}_pcmax) { fprintf(fp,\"ERROR: actual iteration count (%ld) different from what expected (%ld)\\n\", pc,${NAME[1]}_pcmax); nberrors++; }"
    echo " "
    echo "  printf(\"Verification complete: \");"
    echo "  if (nberrors == 0) { "
    echo "    printf(\"no errors detected, congrats!\\n\");"
    echo "    remove(\"trahrhe_tiling_ERRORS.txt\");"
    #if ((nb_tiling_levels < N)); then
    #    borne=$((nb_tiling_levels + 1))
    #else
    #    borne=$nb_tiling_levels
    #fi
    #echo "    for (int j=1; j<=$borne; j++)"
    #echo "      for (int i=0; i<NT; i++) {"
    #echo "        gdeviation[j]+=deviation[i][j];"
    #echo "        gdcpt[j]+=dcpt[i][j];"
    #echo "      }"
    #echo -n "    printf(\"Average absolute deviations: "
    #for ((i = 1; i <= $nb_tiling_levels; i++)); do
    #    echo -n "[ TILE_VOL_L$i (%ld): %.0Lf (%.2Lf%%) ] "
    #done
    #echo -n "\\n\""
    #for ((i = 1; i <= $nb_tiling_levels; i++)); do
    #    echo -n ",TILE_VOL_L$i,(long double)gdeviation[$i]/gdcpt[$i], ((long double)gdeviation[$i]/gdcpt[$i])*100/TILE_VOL_L$i"
    #done
    #echo ");"
    echo "  }"
    echo "  else printf(\"%ld error(s) detected and reported in file trahrhe_tiling_ERRORS.txt\\n\",nberrors);"
    echo "  fclose(fp);"
    echo "  return 0;"
    echo "}"

    exec >&3

    i=1
    while ((i <= nb_tiling_levels)); do
        sed -i "/for (${NAME[1]} =/i\ ${NAME[$i]}_pcmax = ${NAME[$i]}_Ehrhart(${LevelParams[$i]});" trahrhe_tiling_parallel.c
        #if ((i > 1)); then
        #    sed -i "/for (${NAME[1]} =/i\ " trahrhe_tiling_parallel.c
        #    sed -i "/for (${NAME[1]} =/i\ deviation[omp_get_thread_num()][$((i - 1))]+=abs(${NAME[$i]}_pcmax - TILE_VOL_L$((i - 1)));" trahrhe_tiling_parallel.c
        #    sed -i "/for (${NAME[1]} =/i\ dcpt[omp_get_thread_num()][$((i - 1))]++;" trahrhe_tiling_parallel.c
        #    sed -i "/for (${NAME[1]} =/i\ " trahrhe_tiling_parallel.c
        #fi
        sed -i "/for (${NAME[1]} =/i\ TILE_VOL_L$i = ${NAME[$i]}_pcmax\/NUMBER_OF_SLICES_L$i;" trahrhe_tiling_parallel.c
        if ((i == 1)); then
          IFS=","
          set - $ListeTileMin
          if (($# > 1)); then
            ListeTileMin="MAX($ListeTileMin)"
          fi
          sed -i "/for (${NAME[1]} =/i\ if (TILE_VOL_L1 < TILEMIN(${Params[${NAME[1]}]})) {" trahrhe_tiling_parallel.c
          sed -i "/for (${NAME[1]} =/i\   printf(\"TILE_VOL_L1 must be greater than %ld (greater than ${ListeTileMin}+1): lower NUMBER_OF_SLICES_L1\\\n\",TILEMIN(${Params[${NAME[1]}]}));" trahrhe_tiling_parallel.c
          sed -i "/for (${NAME[1]} =/i\   return 1;" trahrhe_tiling_parallel.c
          sed -i "/for (${NAME[1]} =/i\ }"  trahrhe_tiling_parallel.c
        fi
        sed -i "/for (${NAME[1]} =/i ubT${NAME[$i]} = max(${NAME[$i]}_pcmax\/(TILE_VOL_L$i)-1,0);" trahrhe_tiling_parallel.c
        if ((i == 1)); then
            j=1
            TBlist=""
            TileList=""
            NSList=""
            while ((j <= nb_tiling_levels)); do
                TBlist="$TBlist, lb${NAME[j]}, ub${NAME[j]}"
                if ((j > 1)); then
                    TBlist="$TBlist, T${NAME[j]}, ubT${NAME[j]}, ${NAME[j]}_pcmax"
                    TileList="$TileList, TILE_VOL_L$j"
                    NSList="$NSList, NUMBER_OF_SLICES_L$j"
                fi
                ((j++))
            done
            TBlist=$(echo "$TBlist" | sed 's/^ *, *//')
            TileList=$(echo "$TileList" | sed 's/^ *, *//')
            NSList=$(echo "$NSList" | sed 's/^ *, *//')
            #sed -i "/for (${NAME[1]} =/i #pragma omp parallel for private($listevar, $TBlist, trahrhe) firstprivate($params, ubT${NAME[1]}, ${NAME[1]}_pcmax, $TileList, ltc, fp) shared(local_pc,local_nberrors,deviation,dcpt)" trahrhe_tiling_parallel.c
            if [ "$TileList" = "" ]; then
              sed -i "/for (${NAME[1]} =/i #pragma omp parallel for private($listevar, $TBlist, trahrhe) firstprivate($params, ubT${NAME[1]}, ${NAME[1]}_pcmax, TILE_VOL_L1, ltc, fp) shared(local_pc,local_nberrors)" trahrhe_tiling_parallel.c
            else
              sed -i "/for (${NAME[1]} =/i #pragma omp parallel for private($listevar, $TBlist, $TileList, trahrhe) firstprivate($params, ubT${NAME[1]}, ${NAME[1]}_pcmax, TILE_VOL_L1, $NSList, ltc, fp) shared(local_pc,local_nberrors)" trahrhe_tiling_parallel.c
            fi
        fi
        sed -i "/for (${NAME[1]} =/i for (T${NAME[$i]} = 0; T${NAME[$i]} <= ubT${NAME[$i]}; T${NAME[$i]}++) {" trahrhe_tiling_parallel.c

        sed -i "/for (${NAME[1]} =/i\  lb${NAME[$i]} = ${NAME[$i]}_trahrhe_${NAME[$i]}(max(T${NAME[$i]}*(TILE_VOL_L$i),1),${LevelParams[$i]});" trahrhe_tiling_parallel.c
        sed -i "/for (${NAME[1]} =/i\  ub${NAME[$i]} = ${NAME[$i]}_trahrhe_${NAME[$i]}(min((T${NAME[$i]}+1)*(TILE_VOL_L$i),${NAME[$i]}_pcmax),${LevelParams[$i]}) - 1;" trahrhe_tiling_parallel.c
        #borne="${NAME[$i]}_trahrhe_${NAME[$i]}(${NAME[$i]}_pcmax,${LevelParams[$i]})"

        borne=$(sed -n "s~for (${NAME[$i]} =.*;.*< *\(.*\);.*).*~\1~p" trahrhe_tiling_parallel.c | tr -d ' ')
        # cas où borne sup <=
        if [[ $(echo "$borne" | sed "s/^\(=\).*/\1/") == "=" ]]; then
            borne="$(echo "$borne" | sed "s~^= *\(.*\) *~\1~")+1"
        fi
        if ((i > 1)); then
            j=1
            while ((j < i)); do
                borne=$(echo "$borne" | sed ":a; s~\(.*[^A-Za-z_0-9]\)${NAME[$j]}\([^A-Za-z_0-9].*\)~\1ub${NAME[$j]}\2~g; ta")
                borne=$(echo "$borne" | sed "s~^${NAME[$j]}\([^A-Za-z_0-9].*\)~ub${NAME[$j]}\1~g")
                borne=$(echo "$borne" | sed "s~\(.*[^A-Za-z_0-9]\)${NAME[$j]}$~\1ub${NAME[$j]}~g")
                borne=$(echo "$borne" | sed "s~^${NAME[$j]}$~ub${NAME[$j]}~g")
                ((j++))
            done
        fi
        sed -i "/for (${NAME[1]} =/i\  if (T${NAME[$i]} == ubT${NAME[$i]}) ub${NAME[$i]} = ${borne}-1;" trahrhe_tiling_parallel.c
        sed -i "/for (${NAME[1]} =/i\  " trahrhe_tiling_parallel.c
        sed -i "/for (${NAME[1]} =/i\  if (ub${NAME[$i]} < lb${NAME[$i]}) \{ fprintf(stderr, \"\\\nThe tile volume of level $i (%ld) seems too small, raise it and try again: lower NUMBER_OF_SLICES_L$i\\\n\",TILE_VOL_L$i); exit(1); \}" trahrhe_tiling_parallel.c
        sed -i "/for (${NAME[1]} =/i\  " trahrhe_tiling_parallel.c
        #if ((i == nb_tiling_levels && nb_tiling_levels == N)); then
        #    sed -i "/for (${NAME[1]} =/i\  deviation[omp_get_thread_num()][$nb_tiling_levels]+=abs((ub${NAME[$i]}-lb${NAME[$i]}+1) - TILE_VOL_L$i);" trahrhe_tiling_parallel.c
        #    sed -i "/for (${NAME[1]} =/i\  dcpt[omp_get_thread_num()][$nb_tiling_levels]++;" trahrhe_tiling_parallel.c
        #    sed -i "/for (${NAME[1]} =/i\ " trahrhe_tiling_parallel.c
        #fi
        #if ((i == nb_tiling_levels && nb_tiling_levels < N)); then
        #    sed -i "/for (${NAME[1]} =/i\ " trahrhe_tiling_parallel.c
        #    sed -i "/for (${NAME[1]} =/i\ deviation[omp_get_thread_num()][$i]+=abs(${NAME[$i]}_Ehrhart(${Params[${NAME[$i]}]}) - TILE_VOL_L$i);" trahrhe_tiling_parallel.c
        #    sed -i "/for (${NAME[1]} =/i\ dcpt[omp_get_thread_num()][$i]++;" trahrhe_tiling_parallel.c
        #    sed -i "/for (${NAME[1]} =/i\ " trahrhe_tiling_parallel.c
        #fi

        sed -i "/putchar('\\\n')/i } \/\* end for T${NAME[$((nb_tiling_levels - i + 1))]} \*\/" trahrhe_tiling_parallel.c

        sed -i "s~for (${NAME[$i]} = \(.*\);\(.*;.*)\)~for (${NAME[i]} = max(\1,lb${NAME[$i]});\2~" trahrhe_tiling_parallel.c
        sed -i "s~for (${NAME[$i]} = \(.*;.*< \)\(.*\)\(;.*)\)~for (${NAME[$i]} = \1min(\2,ub${NAME[$i]}+1)\3~" trahrhe_tiling_parallel.c
        sed -i "s~for (${NAME[$i]} = \(.*;.*<= \)\(.*\)\(;.*)\)~for (${NAME[$i]} = \1min(\2,ub${NAME[$i]})\3~" trahrhe_tiling_parallel.c
        ((i++))
    done
    sed -i "/for (${NAME[$N]}/,/local_pc\[omp_get_thread_num()\]/s/ trahrhe_/ ${NAME[1]}_trahrhe_/g" trahrhe_tiling_parallel.c
    sed -i "s~\(_trahrhe_.*(\)pc~\1${NAME[1]}_Ranking(${listevar[${NAME[1]}]},${Params[${NAME[1]}]})~g" trahrhe_tiling_parallel.c
    sed -i "s~,pc,~,${NAME[1]}_Ranking(${listevar[${NAME[1]}]},${Params[${NAME[1]}]}),~g" trahrhe_tiling_parallel.c
    exec >&3
} # fin generate_tiling_code()
