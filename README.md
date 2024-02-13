# Automatic-loop-collapsing

## Dependencies

In order
- [GMP]
- (https://gmplib.org/)
- [NTL](http://www.shoup.net/ntl/)
- Polylib
- [isl](http://isl.gforge.inria.fr/)
- Barvinok
- trahrhe
- osl
- clan
- [cloog](http://www.cloog.org/)

Powerful commands:
---
missing libs stuff after install from third party

`sudo cp /usr/local/lib/lib<LIB_NAME>*   /usr/lib`

---
barvinok

`./configure NTL_STD_CXX=on NTL_GMP_LIP=on PREFIX=/usr/local GMP_PREFIX=$HOME/sw SHARED=on`

---
autoreconf stuff

`apt-get install dh-autoreconf`

---
creating symbolic links stuff

`sudo ln -s /usr/local/lib/libbarvinok.so.0 /usr/lib/libbarvinok.so.0`

## Liens utiles

- Benchmarks: polybench <https://web.cs.ucla.edu/~pouchet/software/polybench/>
- Openscop: <https://icps.u-strasbg.fr/people/bastoul/public_html/development/openscop/docs/openscop.html>
- Clan: <https://icps.u-strasbg.fr/~bastoul/development/clan/>
- Trahrhe: <https://webpages.gitlabpages.inria.fr/trahrhe/documentation>
- Cloog: <http://www.bastoul.net/cloog/>
- (Atiling: <https://github.com/Zetsyog/atiling>)

## Use case

```bash
# exemple d'usage
(collapse) [input.c] -o [output.c] # des options supplémentaires sont envisageables
```

Avec `input.c` de la forme

```c
/*
...
...
*/
#pragma trahrhe collapse(2)
for(i = 0; i < N - 1; i++) {
    for(j = i + 1; j < N; j++) {
        for(k = 0; k < N; k++) {
            A[i][j] += B[k][i] * C[k][j];
        }
        A[j][i] = A[i][j];
    }
}
#pragma endtrahrhe
/*
...
...
*/
```

Et `output.c` serait

```c
/*
...
...
*/
unsigned int pc;
unsigned upper_bound = i_Ehrhart(N);
unsigned int first_iteration = 1;
#pragma omp parallel for private(i, j, k) firstprivate(first_iteration) schedule(static)
for(pc = 1; pc <= upper_bound; pc++) {
    if(first_iteration) {
        i = i_trahrhe(pc, N);
        j = j_trahrhe(pc, N, i);
        first_iteration = 0;
    }
    for(k = 0; k < N; k++) {
        A[i][j] += B[k][i] * C[k][j];
    }
    A[j][i] = A[i][j];
    j++;
    if(j >= N) {
        i++;
        j = i + 1;
    }
}
/*
...
...
*/
```

## Todo list (non-exhaustive)

Pré-requis: installation et familiarisation avec les librairies requises.

- [ ] Extraire le code entre pragma
- [ ] Parser le pragma et récupérer l'argument
- [ ] Appeler clan sur ce code
  - [ ] Ecrire le code dans un fichier temporaire avec les pragma scop?
- [ ] Récupérer les bornes depuis la représentation openscop
- [ ] Appeler trahrhe
  - [ ] Ecrire le domaine en syntaxe isl `[N] -> { [i, j, k] : 0 < i < N - 1 and i + 1 <= j < N and 0 < k < N  }`
  - [ ] Récupérer le header c généré
  - [ ] Ajouter l'include
- [ ] Génération de code
  - [ ] Combinaison de cloog et de generation à la main
  - [ ] Penser au pragma omp
  - [ ] Besoin de connaitre les bornes et les dépendances des itérateurs
