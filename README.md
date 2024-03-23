# Automatic-loop-collapsing

## Dependencies

- [GMP](https://gmplib.org/)
- [NTL](http://www.shoup.net/ntl/)
- [Polylib](https://www.irisa.fr/polylib/)
- [isl](https://repo.or.cz/isl.git)
- [ntl](https://github.com/libntl/ntl.git)
- [Barvinok](https://repo.or.cz/barvinok.git)
- [trahrhe](https://webpages.gitlabpages.inria.fr/trahrhe/download)
- [osl](https://icps.u-strasbg.fr/people/bastoul/public_html/development/openscop/)
- [clan](https://github.com/periscop/clan.git)
- [cloog](http://www.cloog.org/)

To install Barvinok, you need to follow these steps:

1. Get GMP using the procedure described in https://libntl.org/doc/tour-gmp.html (note the $HOME/sw)
2. Get NTL using the info in this same page
3. Get ISL
4. You should now be able to get Barvinok 
```bash
. ./configure --with-isl=bundled
make
make install
```


Powerful commands:
---
If you are having trouble with the installation of the library, you can try the following commands to copy the library to the `/usr/lib` directory (assuming you have the library in `/usr/local/lib` directory):

`sudo cp /usr/local/lib/lib<LIB_NAME>*   /usr/lib`

---
If your machine is missing `autoreconf` command, you can install it by running the following command:

`apt-get install dh-autoreconf`

---
You may need to create a symbolic link to the library in the `/usr/lib` directory. You can do this by running the following command:

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
