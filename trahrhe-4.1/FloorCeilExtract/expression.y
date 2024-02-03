%{
//===--- FloorCeilExtract/expression.y ------------------------------------===//
//
// TRAHRHE - Computation of Trahrhe Expressions and related functions
//           Application code generation
//
//===----------------------------------------------------------------------===//
//
// The BSD 3-Clause License
//
// Copyright (c) 2019. INRIA, CNRS and University of Strasbourg
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors
//    may be used to endorse or promote products derived from this software
//    without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Main Contributor:
//     Philippe Clauss     <clauss@unistra.fr>
//
//===----------------------------------------------------------------------===//

  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <math.h>

  char* concat(const char*, const char*);
  int yylex();
  void yyerror(char*);
%}

%union {
  char* string;
  int value;
  int ptr;
}

%token IMAG SQRT FLOOR CEILING MOD
%token <string> ID NUMBER
%type <string> E T F G H

%left '+' '-'
%left '*' '/'
%left '^'
%left UMOINS

%%

axiom:
  E ';' { printf("0");
	  exit(0);
        }
  ;

E:  E '+' T 	  { $$=concat(concat($1,"+"),$3); }
  | E '-' T 	  { $$=concat(concat($1,"-"),$3); }
  | T		  { $$=$1; }
  ;
T:  T '*' F       { $$=concat(concat($1,"*"),$3); }
  | T '/' F       { $$=concat(concat($1,"/"),$3); }
  | F		  { $$=$1; }
  ;
F:  F '^' G 	  { $$=concat(concat($1,"^"),$3); }
  | G		  { $$=$1; }
  ;
G:  G '%' NUMBER  { $$=concat(concat(concat(concat("mod(",$1),","),$3),")"); }
  | MOD '(' E ',' NUMBER ')' { $$=concat(concat(concat(concat("mod(",$3),","),$5),")"); }
  | H             { $$=$1; }
  ;  
H:  '-' E         { $$=concat("-",$2); } %prec UMOINS
  | SQRT '(' E ')' {$$=concat(concat("csqrtl(",$3),")"); } %prec UMOINS
  | FLOOR '(' E ')' { printf("%s",$3); 
                      exit(0);
                    } %prec UMOINS
                    
  | CEILING '(' E ')' { printf("%s",$3); 
                        exit(0);
                      } %prec UMOINS
  | '(' E ')'  { $$ = concat(concat("(",$2),")"); }
  | ID            { $$=$1; }
  | NUMBER        { $$=$1; }
  | IMAG          { $$="I";}
  ;

%%

char *concat(const char *s1, const char *s2) {
    char *res = malloc(strlen(s1) + strlen(s2) + 1);
    if (res) {
        strcpy(res, s1);
        strcat(res, s2);
    }
    return res;
}

int main() {
  return yyparse();
}
