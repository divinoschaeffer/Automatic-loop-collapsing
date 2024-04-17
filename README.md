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
Refer to the [usage guide](./docs/USAGE.md).

## License
TBD
