%{
//===--- Maxima2MPC/expression.y ------------------------------------------===//
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

  typedef struct entree_tab {
    char lexval[10];
    long int tag;
    char tagop;
    int value;
    char id[10];
    int status; // 0=unused, 1=used
  } entree_tab;

  struct entree_tab* tsymb[4000];

  int indsymb=0;
  int indtemp=0;
  int tagcpt=1;

  typedef struct ligne_code {
    char* operation;
    char* cible;
    char* op1;
    char* op2;
    int opnum;
  } ligne_code;

  struct ligne_code* code[8000];

  int num_ligne=0;

  typedef struct tags {
    int tag;
    char operation;
    char* op1;
    char* op2;
  } tags;

  struct tags* tags_array[8000];

  int cpt_tags=0;

  int cptsup=0;

  int newtemp();
  int addsymb(char*);
  int search_value(int);
  int search_id(char*);
  int search_tag(char,int);
  long int hash(char, char* ,char*);
  void detect_collision();
  void reduce_var();
  void update_status();
  void renumerotation();
  void print_code_header();
  void print_code();
  void print_code_footer();
  int yylex();
  void yyerror(char*);
%}

%union {
  char* string;
  int value;
  int ptr;
}

%token IMAG
%token <string> ID SQRT FLOOR CEILING MOD
%token <value> NUMBER
%type <ptr> expr

%left '+' '-'
%left '*' '/'
%left UMOINS
%left '^'

%%

axiom:
  expr ';' { printf("\n/**** MPC CODE ****/\n");
              printf("/*    ********    */\n\n");
	      //print_code();
              //for (int i=0; i<num_ligne; i++) printf("%s\n",code[i]->cible);
              detect_collision();
	      reduce_var();
              update_status();
              renumerotation();
	      print_code_header();
              print_code();
              print_code_footer();
	      printf("/**** END OF MPC CODE ****/\n");
              printf("/* %d variables supprimées / %d : %d variables */\n",cptsup,indsymb,indsymb-cptsup);
	      exit(0);
            }
  ;

expr:
    expr '+' expr { 
			$$=search_tag('+',hash('+',tsymb[$1]->lexval,tsymb[$3]->lexval));
			if ($$<0) {
				$$ = newtemp();
				tsymb[$$]->tagop = '+';
				tsymb[$$]->tag = hash('+',tsymb[$1]->lexval,tsymb[$3]->lexval);
//printf("tag=%d\n",tsymb[$$]->tag);
//printf("SUCCESS %s %s %d\n",tsymb[$1]->lexval,tsymb[$3]->lexval,hash('+',tsymb[$1]->lexval,tsymb[$3]->lexval));
				tsymb[$$]->value = -9999;
				tsymb[$$]->id[0] = ' ';
				//printf("mpc_add(%s,%s,%s,MPC_RNDZZ);\n",tsymb[$$]->lexval,tsymb[$1]->lexval,tsymb[$3]->lexval);
                                code[num_ligne]=(ligne_code*)malloc(sizeof(ligne_code));
				code[num_ligne]->operation="mpc_add";
				code[num_ligne]->cible=tsymb[$$]->lexval;
				code[num_ligne]->op1=tsymb[$1]->lexval;
				code[num_ligne]->op2=tsymb[$3]->lexval;
				num_ligne++;
			}
		  }
  | expr '-' expr { 
			$$=search_tag('-',hash('-',tsymb[$1]->lexval,tsymb[$3]->lexval));
			if ($$<0) {
				$$ = newtemp();
				tsymb[$$]->tagop = '-';
				tsymb[$$]->tag = hash('-',tsymb[$1]->lexval,tsymb[$3]->lexval);
//printf("tag=%d\n",tsymb[$$]->tag);
				tsymb[$$]->value = -9999;
				tsymb[$$]->id[0] = ' ';
				//printf("mpc_sub(%s,%s,%s,MPC_RNDZZ);\n",tsymb[$$]->lexval,tsymb[$1]->lexval,tsymb[$3]->lexval);
                                code[num_ligne]=(ligne_code*)malloc(sizeof(ligne_code));
				code[num_ligne]->operation="mpc_sub";
				code[num_ligne]->cible=tsymb[$$]->lexval;
				code[num_ligne]->op1=tsymb[$1]->lexval;
				code[num_ligne]->op2=tsymb[$3]->lexval;
				num_ligne++;
			}
		  }
  | expr '*' expr { 
			$$=search_tag('*',hash('*',tsymb[$1]->lexval,tsymb[$3]->lexval));
			if ($$<0) {
				$$ = newtemp();
				tsymb[$$]->tagop = '*';
				tsymb[$$]->tag = hash('*',tsymb[$1]->lexval,tsymb[$3]->lexval);
//printf("tag=%d\n",tsymb[$$]->tag);
				tsymb[$$]->value = -9999;
				tsymb[$$]->id[0] = ' ';
				//printf("mpc_mul(%s,%s,%s,MPC_RNDZZ);\n",tsymb[$$]->lexval,tsymb[$1]->lexval,tsymb[$3]->lexval);
                                code[num_ligne]=(ligne_code*)malloc(sizeof(ligne_code));
				code[num_ligne]->operation="mpc_mul";
				code[num_ligne]->cible=tsymb[$$]->lexval;
				code[num_ligne]->op1=tsymb[$1]->lexval;
				code[num_ligne]->op2=tsymb[$3]->lexval;
				num_ligne++;
			}
//else printf("SUCCESS %s %s %d\n",tsymb[$1]->lexval,tsymb[$3]->lexval,hash('*',tsymb[$1]->lexval,tsymb[$3]->lexval));
		  }
  | expr '/' expr { 
			$$=search_tag('/',hash('/',tsymb[$1]->lexval,tsymb[$3]->lexval));
			if ($$<0) {
				$$ = newtemp();
				tsymb[$$]->tagop = '/';
				tsymb[$$]->tag = hash('/',tsymb[$1]->lexval,tsymb[$3]->lexval);
//printf("tag=%d\n",tsymb[$$]->tag);
				tsymb[$$]->value = -9999;
				tsymb[$$]->id[0] = ' ';
				//printf("mpc_div(%s,%s,%s,MPC_RNDZZ);\n",tsymb[$$]->lexval,tsymb[$1]->lexval,tsymb[$3]->lexval);
                                code[num_ligne]=(ligne_code*)malloc(sizeof(ligne_code));
				code[num_ligne]->operation="mpc_div";
				code[num_ligne]->cible=tsymb[$$]->lexval;
				code[num_ligne]->op1=tsymb[$1]->lexval;
				code[num_ligne]->op2=tsymb[$3]->lexval;
				num_ligne++;
			}
		  }
  | expr '^' expr { 
			$$=search_tag('^',hash('^',tsymb[$1]->lexval,tsymb[$3]->lexval));
			if ($$<0) {
				$$ = newtemp();
				tsymb[$$]->tagop = '^';
				tsymb[$$]->tag = hash('^',tsymb[$1]->lexval,tsymb[$3]->lexval);
				tsymb[$$]->value = -9999;
				tsymb[$$]->id[0] = ' ';
                                code[num_ligne]=(ligne_code*)malloc(sizeof(ligne_code));
				code[num_ligne]->operation="mpc_pow";
				code[num_ligne]->cible=tsymb[$$]->lexval;
				code[num_ligne]->op1=tsymb[$1]->lexval;
				code[num_ligne]->op2=tsymb[$3]->lexval;
				num_ligne++;
			}
		  }
  | '-' expr      { 
			char* temp="  ";
			$$=search_tag('-',hash('-',tsymb[$2]->lexval,temp));
			if ($$<0) {
				$$ = newtemp();
				tsymb[$$]->tagop = '-';
				tsymb[$$]->tag = hash('-',tsymb[$2]->lexval,temp);
//printf("tag=%d\n",tsymb[$$]->tag);
				tsymb[$$]->value = -9999;
				tsymb[$$]->id[0] = ' ';
				//printf("mpc_neg(%s,%s,MPC_RNDZZ);\n",tsymb[$$]->lexval,tsymb[$2]->lexval);
                                code[num_ligne]=(ligne_code*)malloc(sizeof(ligne_code));
				code[num_ligne]->operation="mpc_neg";
				code[num_ligne]->cible=tsymb[$$]->lexval;
				code[num_ligne]->op1=tsymb[$2]->lexval;
				code[num_ligne]->op2="  ";
				num_ligne++;
			}
		  } %prec UMOINS
  | '(' expr ')'  { $$ = $2; }
  | SQRT '(' expr ')' { 
			char* temp="qrt";
			$$=search_tag('s',hash('s',tsymb[$3]->lexval,temp));
			if ($$<0) {
				$$ = newtemp();
				tsymb[$$]->tagop = 's';
				tsymb[$$]->tag = hash('s',tsymb[$3]->lexval,temp);
//printf("tag=%d\n",tsymb[$$]->tag);
				tsymb[$$]->value = -9999;
				tsymb[$$]->id[0] = ' ';
				//printf("mpc_sqrt(%s,%s,MPC_RNDZZ);\n",tsymb[$$]->lexval,tsymb[$3]->lexval);
                                code[num_ligne]=(ligne_code*)malloc(sizeof(ligne_code));
				code[num_ligne]->operation="mpc_sqrt";
				code[num_ligne]->cible=tsymb[$$]->lexval;
				code[num_ligne]->op1=tsymb[$3]->lexval;
				code[num_ligne]->op2="  ";
				num_ligne++;
			}
		  } %prec UMOINS
  | FLOOR '(' expr ')' { 
			char* temp="oor";
			$$=search_tag('s',hash('s',tsymb[$3]->lexval,temp));
			if ($$<0) {
				$$ = newtemp();
				tsymb[$$]->tagop = 's';
				tsymb[$$]->tag = hash('s',tsymb[$3]->lexval,temp);
//printf("tag=%d\n",tsymb[$$]->tag);
				tsymb[$$]->value = -9999;
				tsymb[$$]->id[0] = ' ';
                                code[num_ligne]=(ligne_code*)malloc(sizeof(ligne_code));
				code[num_ligne]->operation="mpfr_floor";
				code[num_ligne]->cible=tsymb[$$]->lexval;
				code[num_ligne]->op1=tsymb[$3]->lexval;
				code[num_ligne]->op2="  ";
				num_ligne++;
			}
		  } %prec UMOINS	
  | CEILING '(' expr ')' { 
			char* temp="ing";
			$$=search_tag('s',hash('s',tsymb[$3]->lexval,temp));
			if ($$<0) {
				$$ = newtemp();
				tsymb[$$]->tagop = 's';
				tsymb[$$]->tag = hash('s',tsymb[$3]->lexval,temp);
//printf("tag=%d\n",tsymb[$$]->tag);
				tsymb[$$]->value = -9999;
				tsymb[$$]->id[0] = ' ';
                                code[num_ligne]=(ligne_code*)malloc(sizeof(ligne_code));
				code[num_ligne]->operation="mpfr_ceil";
				code[num_ligne]->cible=tsymb[$$]->lexval;
				code[num_ligne]->op1=tsymb[$3]->lexval;
				code[num_ligne]->op2="  ";
				num_ligne++;
			}
		  } %prec UMOINS	
  | expr '%' expr {
                        $$=search_tag('%',hash('%',tsymb[$1]->lexval,tsymb[$3]->lexval));
			if ($$<0) {
				$$ = newtemp();
				tsymb[$$]->tagop = '%';
				tsymb[$$]->tag = hash('%',tsymb[$1]->lexval,tsymb[$3]->lexval);
				tsymb[$$]->value = -9999;
				tsymb[$$]->id[0] = ' ';
                                code[num_ligne]=(ligne_code*)malloc(sizeof(ligne_code));
				code[num_ligne]->operation="mpfr_fmod";
				code[num_ligne]->cible=tsymb[$$]->lexval;
				code[num_ligne]->op1=tsymb[$1]->lexval;
				code[num_ligne]->op2=tsymb[$3]->lexval;
				num_ligne++;
			}
                  } %prec UMOINS
  | MOD '(' expr ',' expr ')' {
                        $$=search_tag('%',hash('%',tsymb[$3]->lexval,tsymb[$5]->lexval));
			if ($$<0) {
				$$ = newtemp();
				tsymb[$$]->tagop = '%';
				tsymb[$$]->tag = hash('%',tsymb[$3]->lexval,tsymb[$5]->lexval);
				tsymb[$$]->value = -9999;
				tsymb[$$]->id[0] = ' ';
                                code[num_ligne]=(ligne_code*)malloc(sizeof(ligne_code));
				code[num_ligne]->operation="mpfr_fmod";
				code[num_ligne]->cible=tsymb[$$]->lexval;
				code[num_ligne]->op1=tsymb[$3]->lexval;
				code[num_ligne]->op2=tsymb[$5]->lexval;
				num_ligne++;
			}
                  } %prec UMOINS	                  		  	  	  
  | ID            { 	$$ = search_id($1);
			if ($$<0) {
  				$$ = newtemp(); 
				tsymb[$$]->tagop = ' ';
  				tsymb[$$]->tag = tagcpt;
//printf("tag=%d\n",tsymb[$$]->tag);
  				tagcpt++;
				for (int j=0; (j<10) && ($1!='\0'); j++) (tsymb[$$]->id)[j]=$1[j];
                  		//printf("mpc_set_si(%s,%s,MPC_RNDZZ);\n",tsymb[$$]->lexval,$1);
                                code[num_ligne]=(ligne_code*)malloc(sizeof(ligne_code));
				code[num_ligne]->operation="mpc_set_si";
				code[num_ligne]->cible=tsymb[$$]->lexval;
				code[num_ligne]->op1=$1;
				code[num_ligne]->op2="  ";
				num_ligne++;
			}
		  }
  | NUMBER        { 
			$$ = search_value($1);
			if ($$<0) {
  				$$ = newtemp(); 
				tsymb[$$]->tagop = ' ';
  				tsymb[$$]->tag = tagcpt;
//printf("tag=%d\n",tsymb[$$]->tag);
  				tagcpt++;
  				tsymb[$$]->value = $1;
				//printf("mpc_set_si(%s,%d,MPC_RNDZZ);\n",tsymb[$$]->lexval,$1);
                                code[num_ligne]=(ligne_code*)malloc(sizeof(ligne_code));
				code[num_ligne]->operation="mpc_set_si";
				code[num_ligne]->cible=tsymb[$$]->lexval;
				//for (int j=0; (j<10) && (str[j]!='\0'); j++) (code[num_ligne]->op1)[j]=str[j];
				code[num_ligne]->opnum=$1;
				code[num_ligne]->op1="  ";
				code[num_ligne]->op2="  ";
				num_ligne++;
			}
		  }
  | IMAG          { 
			char* temp="IMAG";
			$$ = search_id(temp);
			if ($$<0) {
  				$$ = newtemp(); 
				tsymb[$$]->tagop = ' ';
  				tsymb[$$]->tag = tagcpt;
//printf("tag=%d\n",tsymb[$$]->tag);
  				tagcpt++;
				for (int j=0; j<4; j++) (tsymb[$$]->id)[j]=temp[j];
                  		//printf("mpc_set_ui_ui(%s,0,1,MPC_RNDZZ);\n",tsymb[$$]->lexval);
                                code[num_ligne]=(ligne_code*)malloc(sizeof(ligne_code));
				code[num_ligne]->operation="mpc_set_ui_ui";
				code[num_ligne]->cible=tsymb[$$]->lexval;
				code[num_ligne]->op1="0";
				code[num_ligne]->op2="1";
				num_ligne++;
			}
//else printf("SUCCESS\n");

		  }
  ;

%%

int newtemp() {
  int i=indsymb,j;
  char str[4]="    ";
  char truc[3]="T";
  char* temp="    ";

  tsymb[i]=(entree_tab*)malloc(sizeof(entree_tab));

  sprintf(str,"%d",indtemp);
  temp=strcat(truc,str);

  for (j=0; (j<10) && (temp[j]!='\0'); j++) (tsymb[i]->lexval)[j]=temp[j];
  indtemp++;
  indsymb++;
  return i;
}

int cherche_symb(char* id) {
  int i;
  for (i=0; i<indsymb; i++) if (strcmp(tsymb[i]->lexval, id) == 0) {return i;}
  return -1;
}

int addsymb(char* id) {
  int i,j;
  i=cherche_symb(id);
  if (i<0) {
    i=indsymb;
    tsymb[i]=(entree_tab*)malloc(sizeof(entree_tab));
    for (j=0; (j<10) && (id[j]!='\0'); j++) tsymb[i]->lexval[j]=id[j];
    tsymb[i]->tag=-1;
    indsymb++;
  }
  return i;
}

int search_value(int val) {
  int i;

  for (i=0; i<indsymb; i++) {
    if (tsymb[i]->value == val) return i;
  }
  return -1;
}

int search_id(char* ident) {
  int i;
  for (i=0; i<indsymb; i++) if (strcmp(tsymb[i]->id, ident) == 0) {return i;}
  return -1;
}

int search_tag(char top, int intag) {
  int i;
  for (i=0; i<indsymb; i++) if ((tsymb[i]->tag == intag) && (tsymb[i]->tagop == top)) {return i;}
  return -1;
}

/* long int hash(char operation, char* operand1 ,char* operand2) {
  int i,cumul=0;
  for (i=0; i<10 && operand1[i]!='\0'; i++) cumul+=((i+1)*operand1[i]+floor(sin(cumul)*sqrt(cumul)+atan(cumul))+3*operand1[i]);
  for (i=0; i<10 && operand2[i]!='\0'; i++) cumul+=((118-i)*operand2[i]+floor(cos(cumul)+sqrt(cumul)+tan(cumul))+operand2[i]);
  cumul+=operation;
  cumul+=3*operand1[0]+2*operand2[0]+5*operand1[1]+7*operand2[1]+sin(operand1[0])*sqrt(operand1[1]+tan(operand2[1]))+sin(operand1[2])*sqrt(operand1[0]+atan(operand2[2])+sqrt(operand1[1])*sqrt(operand2[0])+sqrt(operand1[1])*sqrt(operand2[0]))+sqrt((10+operand2[0])*(11+operand1[1]))+sqrt((12+operand2[1])*(13+operand1[0])*(13+operand1[0])*(7+operand2[2]));
//  printf("hash=%d operation=%c op1=%s op2=%s\n",cumul,operation,operand1,operand2);
  tags_array[cpt_tags] = (tags*)malloc(sizeof(tags));
  tags_array[cpt_tags]->tag = cumul;
  tags_array[cpt_tags]->operation = operation;
  tags_array[cpt_tags]->op1 = operand1;
  tags_array[cpt_tags]->op2 = operand2;
  cpt_tags++;
  return cumul;
} */

 long int hash(char operation, char* operand1 ,char* operand2) {
  int i;
  long int cumul=13;
  for (i=0; i<10 && operand1[i]!='\0'; i++) cumul = (cumul<<4)^(cumul>>28)^operand1[i];
  for (i=0; i<10 && operand2[i]!='\0'; i++) cumul = (cumul<<4)^(cumul>>28)^operand2[i];
  cumul = (cumul<<4)^(cumul>>28)^operation;
//  printf("hash=%d operation=%c op1=%s op2=%s\n",cumul,operation,operand1,operand2);
  tags_array[cpt_tags] = (tags*)malloc(sizeof(tags));
  tags_array[cpt_tags]->tag = cumul;
  tags_array[cpt_tags]->operation = operation;
  tags_array[cpt_tags]->op1 = operand1;
  tags_array[cpt_tags]->op2 = operand2;
  cpt_tags++;
//printf("hash=%ld\n",cumul);
  return cumul;
}

void detect_collision() {
  int i,j;
  for (i=0; i<cpt_tags; i++) {
    for (j=i+1; j<cpt_tags; j++) {
      if ((tags_array[i]->tag == tags_array[j]->tag) && (tags_array[i]->operation == tags_array[j]->operation)
         && 
         ((strcmp(tags_array[i]->op1,tags_array[j]->op1) != 0) || (strcmp(tags_array[i]->op2,tags_array[j]->op2) != 0))) {
        printf("DETECTED COLLISION in CSE elimination with tag %d and operation %c: (%s,%s) vs (%s,%s)\n",tags_array[i]->tag,tags_array[i]->operation,tags_array[i]->op1,tags_array[i]->op2,tags_array[j]->op1,tags_array[j]->op2);
        exit(1);
      }
    }
  }
}

void reduce_var() {
  int i,j,last_access;
  char* source;
  char* to_be_changed;
  for (i=0; i<num_ligne-1; i++) {
    source = (char*)(code[i]->cible);
    last_access=-1;
    for (j=i+1; j<num_ligne; j++) {
      if ( (strcmp(code[j]->op1,source)==0)||(strcmp(code[j]->op2,source)==0) ) last_access = j;
    }
//    printf("source=%s, last_access=%d\n",source,last_access);
//    if (last_access>0) {
      to_be_changed = (char*)(code[last_access]->cible);
//printf("to_be_changed=%s to %s\n",to_be_changed,source);
      code[last_access]->cible = source;
      for (j=last_access+1; j<num_ligne; j++) {
        if (strcmp(code[j]->cible,to_be_changed) == 0) {code[j]->cible = source;}
        if (strcmp(code[j]->op1,to_be_changed) == 0) {code[j]->op1 = source;}
        if (strcmp(code[j]->op2,to_be_changed) == 0) {code[j]->op2 = source;}
      }
//    }
  }
}

void update_status() {
  int i,j,found;
  for (i=0; i<indsymb; i++) {
    found=0;
    for (j=0; j<num_ligne; j++) {
      if (strcmp(code[j]->cible,tsymb[i]->lexval) == 0) {tsymb[i]->status=1;found=1;}
    }
    if (found == 0) tsymb[i]->status=0;
  }
}

void print_code_header() {
  int i;
  for (i=0; i<indsymb; i++) {
    if (tsymb[i]->status == 1) {printf("mpc_t %s; ",tsymb[i]->lexval); printf("mpc_init2(%s,MPC_PRECISION);\n",tsymb[i]->lexval); }
    else cptsup++;
  }
  printf("\n");
}

 void renumerotation() {
  int i,j,k,indaremplacer=-1;
  for (i=0; i<indsymb; i++) {
    if (tsymb[i]->status == 0) {
      indaremplacer=i;
    }
    else {
      if (indaremplacer>=0) {
        tsymb[i]->status = 0;
        tsymb[indaremplacer]->status = 1;
        for (j=0; j<num_ligne; j++) {
          if (strcmp(code[j]->cible,tsymb[i]->lexval) == 0) {
            code[j]->cible = tsymb[indaremplacer]->lexval;
          }
          if (strcmp(code[j]->op1,tsymb[i]->lexval) == 0) {
            code[j]->op1 = tsymb[indaremplacer]->lexval;
          }
          if (strcmp(code[j]->op2,tsymb[i]->lexval) == 0) {
            code[j]->op2 = tsymb[indaremplacer]->lexval;
          }
        }
        indaremplacer=-1;
        i=0;
      }
    }
  }
}

void print_code() {
  int i;
//  printf("CODE:\n");
  for (i=0; i<num_ligne; i++) {
    if (strcmp(code[i]->operation,"mpc_set_si") == 0)
      if (strcmp(code[i]->op1,"  ") == 0)
        printf("%s(%s,%d,MPC_RNDZZ);\n",code[i]->operation,code[i]->cible,code[i]->opnum);
      else
        printf("%s(%s,%s,MPC_RNDZZ);\n",code[i]->operation,code[i]->cible,code[i]->op1);
    /* mpfr code */
    else if (strcmp(code[i]->operation,"mpfr_fmod") == 0) {
           printf("{ mpfr_t mpfr_tmp1; mpfr_init2(mpfr_tmp1,MPC_PRECISION);\n");
           printf("mpfr_t mpfr_tmp2; mpfr_init2(mpfr_tmp2,MPC_PRECISION);\n");
           printf("mpfr_t mpfr_tmp3; mpfr_init2(mpfr_tmp3,MPC_PRECISION);\n");
           printf("mpc_real(mpfr_tmp1,%s,MPC_RNDZZ);\n",code[i]->op1);
           printf("mpc_real(mpfr_tmp2,%s,MPC_RNDZZ);\n",code[i]->op2);
           printf("mpfr_fmod(mpfr_tmp3,mpfr_tmp1,mpfr_tmp2,MPC_RNDZZ);\n");
           printf("mpc_set_fr(%s,mpfr_tmp3,MPC_RNDZZ);\n",code[i]->cible);
           printf("mpfr_clear(mpfr_tmp1);\n");
           printf("mpfr_clear(mpfr_tmp2);\n");
           printf("mpfr_clear(mpfr_tmp3); }\n");
         }
    else if ( (strcmp(code[i]->operation,"mpfr_floor") == 0) || (strcmp(code[i]->operation,"mpfr_ceil") == 0) ) {
           printf("{ mpfr_t mpfr_tmp1; mpfr_init2(mpfr_tmp1,MPC_PRECISION);\n");
           printf("mpfr_t mpfr_tmp2; mpfr_init2(mpfr_tmp2,MPC_PRECISION);\n");
           printf("mpc_real(mpfr_tmp1,%s,MPC_RNDZZ);\n",code[i]->op1);
           printf("%s(mpfr_tmp2,mpfr_tmp1);\n",code[i]->operation);
           printf("mpc_set_fr(%s,mpfr_tmp2,MPC_RNDZZ);\n",code[i]->cible);
           printf("mpfr_clear(mpfr_tmp1);\n");
           printf("mpfr_clear(mpfr_tmp2); }\n");
         }
    else if ((strcmp(code[i]->operation,"mpc_neg") != 0) && (strcmp(code[i]->operation,"mpc_sqrt") != 0))
      printf("%s(%s,%s,%s,MPC_RNDZZ);\n",code[i]->operation,code[i]->cible,code[i]->op1,code[i]->op2);
    else if ( (strcmp(code[i]->operation,"mpc_sqrt") == 0) || (strcmp(code[i]->operation,"mpc_neg") == 0) )
      printf("%s(%s,%s,MPC_RNDZZ);\n",code[i]->operation,code[i]->cible,code[i]->op1);
  }
}

void print_code_footer() {
  int i;
//  printf("\n\n/* INSERT HERE THE CODE FOR RETREAVING AND PROCESSING THE MPC RESULT */\n\n");
//  printf("/* maybe this:\n");
  printf("\n");
  printf("   long double complex extracted_complex_number = mpc_get_ldc(%s,MPC_RNDZZ);\n",code[num_ligne-1]->cible);
  printf("\n");
  for (i=0; i<indsymb; i++) {
    if (tsymb[i]->status == 1) {printf("mpc_clear(%s);\n",tsymb[i]->lexval);}
  }
  printf("\n");
  printf("   long int mpc_result=floorl(creall(extracted_complex_number)+0.00000001);\n\n");
//  printf("\n");
}

int main() {
/*  printf("\n-------------------------------------------\n");
  printf("Maxima Trahrhe expressions to MPC converter\n");
  printf("-------------------------------------------\n\n");
  printf("Maxima Trahrhe expression to be converted:\n"); */
  return yyparse();
}
