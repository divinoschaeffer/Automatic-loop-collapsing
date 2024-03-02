/**
 * @file hashtable.c
 * @author SORGHO Nongma
 * @brief Ref to https://stackoverflow.com/a/4384446
 * @version 0.1
 * @date 2024-02-20
 *
 * @copyright Copyright (c) 2024
 *
 */

#include "hashtable.h"

/* hash: form hash value for string s */
unsigned hash(char *s)
{
    unsigned hashval;
    for (hashval = 0; *s != '\0'; s++)
        hashval = *s + 31 * hashval;
    return hashval % HASHSIZE;
}

char *strdup2(char *s) /* make a duplicate of s */
{
    char *p;
    p = (char *)malloc(strlen(s) + 1); /* +1 for ’\0’ */
    if (p != NULL)
        strcpy(p, s);
    return p;
}

/* lookup: look for s in hashtab */
struct nlist *lookup(char *s)
{
    struct nlist *np;
    for (np = hashtab[hash(s)]; np != NULL; np = np->next)
        if (strcmp(s, np->name) == 0)
            return np; /* found */
    return NULL;       /* not found */
}

/* install: put (name, defn) in hashtab */
struct nlist *install(char *name, char *defn)
{
    struct nlist *np;
    unsigned hashval;
    if ((np = lookup(name)) == NULL)
    { /* not found */
        np = (struct nlist *)malloc(sizeof(*np));
        if (np == NULL || (np->name = strdup2(name)) == NULL)
            return NULL;
        hashval = hash(name);
        np->next = hashtab[hashval];
        hashtab[hashval] = np;
    }
    else                        /* already there */
        free((void *)np->defn); /*free previous defn */
    if ((np->defn = strdup2(defn)) == NULL)
        return NULL;
    return np;
}

void undef(char *name)
{
    struct nlist *np;
    unsigned hashval;
    if ((np = lookup(name)) != NULL)
    {
        hashval = hash(name);
        hashtab[hashval] = np->next;
        free((void *)np->name);
        free((void *)np->defn);
        free((void *)np);
    }
}

void print_hashtab()
{
    printf("\nHASH TABLE:\n");
    struct nlist *np;
    for (int i = 0; i < HASHSIZE; i++)
    {
        for (np = hashtab[i]; np != NULL; np = np->next)
        {
            printf("%s: %s\n", np->name, np->defn);
        }
    }
}

void free_hashtab()
{
    struct nlist *np;
    for (int i = 0; i < HASHSIZE; i++)
    {
        for (np = hashtab[i]; np != NULL; np = np->next)
        {
            free((void *)np->name);
            free((void *)np->defn);
            free((void *)np);
        }
    }
}

struct nlist *mergeByNames(struct nlist *np1, struct nlist *np2)
{
    struct nlist *np;
    for (np = np1; np != NULL; np = np->next)
    {
        if (np->next == NULL)
        {
            np->next = np2;
            break;
        }
    }
    return np1;
}