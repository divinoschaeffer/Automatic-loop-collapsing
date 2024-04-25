#===--- trahrhe_generate_parallel_verification_code.sh -------------------===#
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

generate_parallel_verification_code() {
    typeset mapping
    typeset code
    typeset i
    typeset j
    typeset nbparams
    typeset param
    typeset indent
    typeset vars
    typeset mask
    typeset maskparams

    exec 3>&1
    exec >"trahrhe_verification_parallel.c"

    echo "#include <stdio.h>"
    echo "#include <stdlib.h>"
    echo "#include <sys/sysinfo.h>"
    echo "#include <math.h>"
    echo "#include <omp.h>"
    echo "#include \"trahrhe_header.h\""
    echo " "
    echo "#define ceild(n,d)  ceil(((double)(n))/((double)(d)))"
    echo "#define floord(n,d) floor(((double)(n))/((double)(d)))"
    echo "#define max(x,y)    ((x) > (y)? (x) : (y))"
    echo "#define min(x,y)    ((x) < (y)? (x) : (y))"
    echo " "
    echo "int main(int argc, char *argv[]) {"
    echo " "
    echo "  FILE* fp;"
    echo "  long int ${listevar[x]};"
    if (echo "${Params[x]}" | grep -v -q "NOT_A_PARAMETER"); then
      echo "  long int ${Params[x]};"
    fi
    echo "  long int trahrhe, pc;"
    echo "  long int ltc;"
    echo "  long int nberrors=0;"
    echo "  unsigned char first_iteration=1;"
    echo " "

    IFS=","
    set - ${Params[x]}
    nbparams=$#
    if (echo "${Params[x]}" | grep -v -q "NOT_A_PARAMETER"); then
      echo "  if (argc < $((nbparams + 1))) {"
      echo "    printf(\"Usage: %s $(echo "${Params[x]}" | sed 's/ *, */ /g')\\n\",argv[0]);"
      echo "    return 1;"
      echo "  }"
      echo " "
    else
      nbparams=0
    fi

    if (echo "${Params[x]}" | grep -v -q "NOT_A_PARAMETER"); then
      i=1
      for param in ${Params[x]}; do
          echo "  $param = atoi(argv[$i]);"
          ((i++))
      done
      echo " "
    fi
    echo "  char nproc[3];"
    echo "  sprintf(nproc,\"%d\",get_nprocs());"
    echo "  setenv(\"OMP_NUM_THREADS\",nproc,0);"
    echo "  const int NT = atoi(getenv(\"OMP_NUM_THREADS\"));"
    echo "  printf(\"Number of threads set to %d\\n\",NT);"
    echo " "
    echo "  long int local_nberrors[NT];"
    echo "  for (int _i=0; _i<NT; _i++) local_nberrors[_i]=0;"
    echo " "

    echo "  fp=fopen(\"trahrhe_ERRORS.txt\",\"w\");"
    echo "  setbuf(stdout, NULL);"
    echo "  putchar('[');"
    echo "  for (int _i = 0;  _i < 100;  _i++) putchar('.');"
    echo "  putchar(']');"
    echo "  putchar('\\r');"
    echo "  putchar('[');"
    echo " "
    if (echo "${Params[x]}" | grep -v -q "NOT_A_PARAMETER"); then
      echo "  ltc=(Ehrhart(${Params[x]})/100);"
    else
      echo "  ltc=(Ehrhart()/100);"
    fi
    echo " "
    #indentation instructions internes
    indent=""
    i=1
    while ((i <= N)); do
        indent="$indent  "
        ((i++))
    done

    mapping="$(echo "$D" | sed 's/\({.*\)\(\[.*\]\)/\1\2->\2/')"
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
        code=$(echo "$code" | sed "s/c$i/${VAR[x$((i + 1))]}/g")
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

    i=1
    while ((i <= N)); do
        vars="${listevar1[x11$((i - 1))]}"
        mask=$maskparams
        nbvars=$((i - 1))
        j=1
        while ((j <= (i - 1))); do
            mask=$mask",%ld"
            ((j++))
        done
        mask=$(echo "$mask" | sed 's/^,//')
        if ((i == 1)); then
            if (echo "${Params[x]}" | grep -v -q "NOT_A_PARAMETER"); then
              echo "$indent  if (first_iteration == 1) { pc=Ranking(${listevar[x]}, ${Params[x]}); first_iteration=0; }"
              echo "$indent  trahrhe = trahrhe_${VAR[x$i]}(pc,${Params[x]});"
              echo "$indent  if (trahrhe != ${VAR[x$i]}) {"
              echo "$indent    fprintf(fp,\"ERROR: ${VAR[x$i]} = %ld <-> trahrhe_${VAR[x$i]}(%ld,$mask) = %ld\\n\",${VAR[x$i]},pc,${Params[x]},trahrhe);"
              echo "$indent    local_nberrors[omp_get_thread_num()]++;"
              echo "$indent  }"
            else
              echo "$indent  if (first_iteration == 1) { pc=Ranking(${listevar[x]}); first_iteration=0; }"
              echo "$indent  trahrhe = trahrhe_${VAR[x$i]}(pc);"
              echo "$indent  if (trahrhe != ${VAR[x$i]}) {"
              echo "$indent    fprintf(fp,\"ERROR: ${VAR[x$i]} = %ld <-> trahrhe_${VAR[x$i]}(%ld,$mask) = %ld\\n\",${VAR[x$i]},pc,trahrhe);"
              echo "$indent    local_nberrors[omp_get_thread_num()]++;"
              echo "$indent  }"
            fi
        else
            if (echo "${Params[x]}" | grep -v -q "NOT_A_PARAMETER"); then
              echo "$indent  trahrhe = trahrhe_${VAR[x$i]}(pc,$vars,${Params[x]});"
              echo "$indent  if (trahrhe != ${VAR[x$i]}) {"
              echo "$indent    fprintf(fp,\"ERROR: ${VAR[x$i]} = %ld <-> trahrhe_${VAR[x$i]}(%ld,$mask) = %ld\\n\",${VAR[x$i]},pc,$vars,${Params[x]},trahrhe);"
            else
              echo "$indent  trahrhe = trahrhe_${VAR[x$i]}(pc,$vars);"
              echo "$indent  if (trahrhe != ${VAR[x$i]}) {"
              echo "$indent    fprintf(fp,\"ERROR: ${VAR[x$i]} = %ld <-> trahrhe_${VAR[x$i]}(%ld,$mask) = %ld\\n\",${VAR[x$i]},pc,$vars,trahrhe);"
            fi
            echo "$indent    local_nberrors[omp_get_thread_num()]++;"
            echo "$indent  }"
        fi
        ((i++))
    done
    echo "$indent  if (pc%max(ltc,1) == 0) putchar('#');"
    echo "$indent  pc++;"
    echo "$indent}"
    echo "  putchar('\\n');"
    echo " "
    echo "  for (int _i=0; _i<NT; _i++) nberrors+=local_nberrors[_i];"
    echo " "
    echo "  printf(\"Verification complete: \");"
    echo "  if (nberrors == 0) { printf(\"no errors detected, congrats!\\n\"); remove(\"trahrhe_ERRORS.txt\"); }"
    echo "  else printf(\"%ld errors detected and reported in file trahrhe_ERRORS.txt\\n\",nberrors);"
    echo "  fclose(fp);"
    echo "  return 0;"
    echo "}"
    if (echo "${Params[x]}" | grep -v -q "NOT_A_PARAMETER"); then
      sed -i "/for (${NAME[1]} *=/i #pragma omp parallel for private($(echo "${listevar[x]}" | sed "s/^ *${NAME[1]} *, *\(.*\)/\1/"), trahrhe, pc) firstprivate(${Params[x]},ltc, fp, first_iteration) shared(local_nberrors)" trahrhe_verification_parallel.c
    else
      sed -i "/for (${NAME[1]} *=/i #pragma omp parallel for private($(echo "${listevar[x]}" | sed "s/^ *${NAME[1]} *, *\(.*\)/\1/"), trahrhe, pc) firstprivate(ltc, fp, first_iteration) shared(local_nberrors)" trahrhe_verification_parallel.c
    fi
    exec >&3
}
