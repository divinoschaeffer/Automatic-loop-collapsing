#ifndef __HASHTABLE_H
#define __HASHTABLE_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

struct nlist
{                       /* table entry: */
    struct nlist *next; /* next entry in chain */
    char *name;         /* defined name */
    char *defn;         /* replacement text */
};

#define HASHSIZE 101
static struct nlist *hashtab[HASHSIZE]; /* pointer table */

unsigned hash(char *s);

char *strdup2(char *s); /* make a duplicate of s */

struct nlist *lookup(char *s);

struct nlist *install(char *name, char *defn);

void undef(char *name);

void print_hashtab();

void free_hashtab();

struct nlist *mergeByNames(struct nlist *a, struct nlist *b);

#endif // __HASHTABLE_H