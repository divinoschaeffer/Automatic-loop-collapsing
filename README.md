<!-- Title -->
<div align="center">

# Trahrhe Collapse - Automatic Collapsing of Non Rectangular Loops

A tool to collapse loops in C, C++, C# and Java code automatically using Ehrhart polynomials and the polyhedral model.

</div>

## Installation

To install the library, you need to follow these steps:
- Clone the repository
- Ensure you have the necessary [prerequisites](#prerequisites)
- Run the install script with
```bash
sudo bash install.sh
```

Then, specify the path to Trahrhe's root directory. This is the directory where the `trahrhe` binary is located. The default path is `/usr/local/bin`. If you have installed Trahrhe in a different directory, you can specify the path by running the following command:
    
```bash
export TRAHRHE_INSTALL_DIR=<path_to_trahrhe>
```

Finally, add the utility folder to the PATH environment variable by running the following command:

```bash
export PATH=$PATH:<PATH_TO_TRAHRHE_COLLAPSE>/utility
```

To make the changes permanent, add the above commands to the `.bashrc` file.

## Uninstalling

Run 
```bash
sudo bash uninstall.sh
```

## Prerequisites

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

---
You may need to create a symbolic link to the library in the `/usr/lib` directory. You can do this by running the following command:

`sudo ln -s /usr/local/lib/libbarvinok.so.0 /usr/lib/libbarvinok.so.0`


## Troubleshooting
---
If you are having trouble with the installation of the library, you can try the following commands to copy the library to the `/usr/lib` directory (assuming you have the library in `/usr/local/lib` directory):

`sudo cp /usr/local/lib/lib<LIB_NAME>*   /usr/lib`

---
If your machine is missing `autoreconf` command, you can install it by running the following command:

`apt-get install dh-autoreconf`

## Feature Definitions
Refer to the [feature definitions](./docs/FEATURE_DEFINITIONS.md).

## Usage
This section provides a guide on how to use the Automatic Loop Collapsing tool.

### Prerequisites

Before using the Automatic Loop Collapsing tool, ensure that you have the following prerequisites:

- Installed all the dependencies as described in the [installation guide](./INSTALL.md).
- Installed the Automatic Loop Collapsing tool as described in the [installation guide](./INSTALL.md).
- Familiarized yourself with the [feature definitions](./FEATURE_DEFINITIONS.md).
- Ensure that your input file is in the correct format i.e., it should contain the loops that you want to collapse along with the `#pragma trahrhe collapse(N)` directive.

### Steps

To use the Automatic Loop Collapsing tool, follow these steps:

1. Run the following command:

   ```bash
   trahrhe-collapse [input.c] -o [output.c]
   ```

   You can also specify additional options that are:
   - `-h` or `--help`: Display the help message.
   - `-v` or `--version`: Display the version of the tool.
   - `-o` or `--output`: Specify the output file.

2. The tool will automatically collapse the loops in the input file and generate the output file.

### Example

Consider the following example:
```c
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
```

After running the tool, the output file would be:
```c
unsigned int pc_0;
unsigned upper_bound_0 = i_Ehrhart0(N);
unsigned int first_iteration_0 = 1;
#pragma omp parallel for private(i, j, k) firstprivate(first_iteration_0) schedule(static)
for(pc_0 = 1; pc_0 <= upper_bound_0; pc_0++) {
    if(first_iteration_0) {
        i = i_trahrhe0(pc_0, N);
        j = j_trahrhe0(pc_0, N, i);
        first_iteration_0 = 0;
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
```

## License
TBD
