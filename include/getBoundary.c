#include "data.h"


TCD_Boundary getBoundary(osl_statement_p statement, osl_names_p names) {
    int i, j;
  int part, nb_parts;
  int generated_names = 0;
  int is_access_array;
  size_t high_water_mark = OSL_MAX_STRING;
  int start_row;  // for removing the first line in the access matrix
  int index_output_dims;
  int index_input_dims;
  int index_params;
  char* string = NULL;
  char buffer[OSL_MAX_STRING];
  char** name_array = NULL;
  char* scolumn;
  char* comment;
  osl_names_t* local_names = NULL;

  int print_nth_part = 1;
  int add_fakeiter = 1;
  if (statement == NULL) return osl_util_strdup("# NULL relation\n");
  if (statement->domain == NULL)
    return osl_util_strdup("# NULL relation\n");

  OSL_malloc(string, char*, high_water_mark * sizeof(char));
  string[0] = '\0';

  // Generates the names for the comments if necessary.
  // if (names == NULL) {
  //   generated_names = 1;
  //   local_names = osl_relation_names(statement->domain);
  //   names = local_names;
  // }

  nb_parts = osl_relation_nb_components(statement->domain);
  if (nb_parts > 1) {
    snprintf(buffer, OSL_MAX_STRING, "# Union with %d parts\n%d\n", nb_parts,
             nb_parts);
    osl_util_safe_strcat(&string, buffer, &high_water_mark);
  }

  is_access_array =
      (statement->domain->type == OSL_TYPE_READ || statement->domain->type == OSL_TYPE_WRITE ? 1
                                                                           : 0);

  // Print each part of the union.

  for (part = 1; part <= nb_parts; part++) {
    index_output_dims = 1;
    index_input_dims = index_output_dims + statement->domain->nb_output_dims;
    index_params = index_input_dims + statement->domain->nb_input_dims;

    // Prepare the array of strings for comments.
    name_array = osl_relation_strings(statement->domain, names);

    if (nb_parts > 1) {
      snprintf(buffer, OSL_MAX_STRING, "# Union part No.%d\n", part);
      osl_util_safe_strcat(&string, buffer, &high_water_mark);
    }

    if (print_nth_part) {
      snprintf(buffer, OSL_MAX_STRING, "%d\n", part);
      osl_util_safe_strcat(&string, buffer, &high_water_mark);
    }

    // Don't print the array size for access array
    // (the total size is printed in
    // osl_relation_list_pprint_access_array_scoplib)
    if (!is_access_array) {
      // Print array size
      if (statement->domain->type == OSL_TYPE_DOMAIN) {
        if (add_fakeiter) {
          snprintf(buffer, OSL_MAX_STRING, "%d %d\n", statement->domain->nb_rows + 1,
                   statement->domain->nb_columns - statement->domain->nb_input_dims + 1);
          osl_util_safe_strcat(&string, buffer, &high_water_mark);

          // add the fakeiter line
          snprintf(buffer, OSL_MAX_STRING, "   0 ");
          osl_util_safe_strcat(&string, buffer, &high_water_mark);
          snprintf(buffer, OSL_MAX_STRING, "   1 ");  // fakeiter
          osl_util_safe_strcat(&string, buffer, &high_water_mark);

          for (i = 0; i < statement->domain->nb_parameters; i++) {
            snprintf(buffer, OSL_MAX_STRING, "   0 ");
            osl_util_safe_strcat(&string, buffer, &high_water_mark);
          }

          snprintf(buffer, OSL_MAX_STRING, "    0  ## fakeiter == 0\n");
          osl_util_safe_strcat(&string, buffer, &high_water_mark);

        } else {
          snprintf(buffer, OSL_MAX_STRING, "%d %d\n", statement->domain->nb_rows,
                   statement->domain->nb_columns - statement->domain->nb_input_dims);
          osl_util_safe_strcat(&string, buffer, &high_water_mark);
        }

      }

      // Print column names in comment
      // if (statement->domain->nb_rows > 0) {
      //   scolumn = osl_relation_column_string_scoplib(statement->domain, name_array);
      //   snprintf(buffer, OSL_MAX_STRING, "%s", scolumn);
      //   osl_util_safe_strcat(&string, buffer, &high_water_mark);
      //   free(scolumn);
      // }

      start_row = 0;

    } else {
      if (statement->domain->nb_rows == 1)  // for non array variables
        start_row = 0;
      else  // Remove the 'Arr' line
        start_row = 1;
    }

    // Print the array
    for (i = start_row; i < statement->domain->nb_rows; i++) {
      // First column
      if (!is_access_array) {
        // array index name for scoplib
        osl_int_sprint(buffer, statement->domain->precision, statement->domain->m[i][0]);
        osl_util_safe_strcat(&string, buffer, &high_water_mark);
        snprintf(buffer, OSL_MAX_STRING, " ");
        osl_util_safe_strcat(&string, buffer, &high_water_mark);

      } else {
        // The first column represents the array index name in openscop
        if (i == start_row)
          osl_int_sprint(buffer, statement->domain->precision,
                         statement->domain->m[0][statement->domain->nb_columns - 1]);
        else
          snprintf(buffer, OSL_MAX_STRING, "   0 ");

        osl_util_safe_strcat(&string, buffer, &high_water_mark);
        snprintf(buffer, OSL_MAX_STRING, " ");
        osl_util_safe_strcat(&string, buffer, &high_water_mark);
      }

      // Rest of the array
      if (statement->domain->type == OSL_TYPE_DOMAIN) {
        for (j = 1; j < index_input_dims; j++) {
          osl_int_sprint(buffer, statement->domain->precision, statement->domain->m[i][j]);
          osl_util_safe_strcat(&string, buffer, &high_water_mark);
          snprintf(buffer, OSL_MAX_STRING, " ");
          osl_util_safe_strcat(&string, buffer, &high_water_mark);
        }

        // Jmp input_dims
        for (j = index_params; j < statement->domain->nb_columns; j++) {
          osl_int_sprint(buffer, statement->domain->precision, statement->domain->m[i][j]);
          osl_util_safe_strcat(&string, buffer, &high_water_mark);
          snprintf(buffer, OSL_MAX_STRING, " ");
          osl_util_safe_strcat(&string, buffer, &high_water_mark);
        }

      } else {
        // Jmp output_dims
        for (j = index_input_dims; j < index_params; j++) {
          if (is_access_array && statement->domain->nb_rows == 1 &&
              j == statement->domain->nb_columns - 1) {
            snprintf(buffer, OSL_MAX_STRING, "   0 ");
            osl_util_safe_strcat(&string, buffer, &high_water_mark);
          } else {
            osl_int_sprint(buffer, statement->domain->precision, statement->domain->m[i][j]);
            osl_util_safe_strcat(&string, buffer, &high_water_mark);
            snprintf(buffer, OSL_MAX_STRING, " ");
            osl_util_safe_strcat(&string, buffer, &high_water_mark);
          }
        }

        if (add_fakeiter) {
          snprintf(buffer, OSL_MAX_STRING, "   0 ");
          osl_util_safe_strcat(&string, buffer, &high_water_mark);
        }

        for (; j < statement->domain->nb_columns; j++) {
          if (is_access_array && statement->domain->nb_rows == 1 &&
              j == statement->domain->nb_columns - 1) {
            snprintf(buffer, OSL_MAX_STRING, "  0 ");
            osl_util_safe_strcat(&string, buffer, &high_water_mark);
          } else {
            osl_int_sprint(buffer, statement->domain->precision, statement->domain->m[i][j]);
            osl_util_safe_strcat(&string, buffer, &high_water_mark);
            snprintf(buffer, OSL_MAX_STRING, " ");
            osl_util_safe_strcat(&string, buffer, &high_water_mark);
          }
        }
      }

      // equation in comment
      // if (name_array != NULL) {
      //   comment = osl_relation_sprint_comment(statement->domain, i, name_array,
      //                                         names->arrays->string);
      //   osl_util_safe_strcat(&string, comment, &high_water_mark);
      //   free(comment);
      //   snprintf(buffer, OSL_MAX_STRING, "\n");
      //   osl_util_safe_strcat(&string, buffer, &high_water_mark);
      // }

      // add the lines in the scattering if we need the fakeiter
      if (statement->domain->nb_rows > 0 && add_fakeiter &&
          statement->domain->type == OSL_TYPE_SCATTERING) {
        for (i = 0; i < 2; i++) {
          for (j = 0; j < statement->domain->nb_columns; j++) {
            if (j == index_output_dims && i == 0)
              snprintf(buffer, OSL_MAX_STRING, "   1 ");  // fakeiter
            else
              snprintf(buffer, OSL_MAX_STRING, "   0 ");
            osl_util_safe_strcat(&string, buffer, &high_water_mark);
          }
          snprintf(buffer, OSL_MAX_STRING, "\n");
          osl_util_safe_strcat(&string, buffer, &high_water_mark);
        }
      }
    }

    // Free the array of strings.
    if (name_array != NULL) {
      for (i = 0; i < statement->domain->nb_columns; i++)
        free(name_array[i]);
      free(name_array);
    }

    statement->domain = statement->domain->next;
  }

  if (generated_names)
    osl_names_free(local_names);

    TCD_Boundary boundary = (TCD_Boundary)malloc(sizeof(struct boundary));
    
    int variableCount = statement->domain->nb_output_dims;

    printf("Variable count: %d\n", variableCount);
    char **nameArray = names->iterators->string;

    // osl_relation_expression(statement, i, nameArray);
    // osl_relation_expression(statement, i + 1, nameArray);

    boundary->iterationDomain = string;

    return boundary;
}
