# Usage

This section provides a guide on how to use the Automatic Loop Collapsing tool.

## Prerequisites

Before using the Automatic Loop Collapsing tool, ensure that you have the following prerequisites:

- Installed all the dependencies as described in the [installation guide](./INSTALL.md).
- Familiarized yourself with the [feature definitions](./FEATURE_DEFINITIONS.md).
- Ensure that your input file is in the correct format i.e., it should contain the loops that you want to collapse along with the `#pragma trahrhe collapse(N)` directive.

## Steps

To use the Automatic Loop Collapsing tool, follow these steps:

1. Clone the repository:

   ```bash
   git clone
    ```

2. Navigate to the `Automatic-loop-collapsing` directory:
   
3. Run the following command:

   ```bash
   (collapse) [input.c] -o [output.c]
   ```

   You can also specify additional options that are:
   - `-h` or `--help`: Display the help message.
   - `-v` or `--version`: Display the version of the tool.
   - `-o` or `--output`: Specify the output file.

4. The tool will automatically collapse the loops in the input file and generate the output file.

## Example

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