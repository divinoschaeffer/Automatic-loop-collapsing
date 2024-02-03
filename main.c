#include "main.h"

int main() {
    osl_scop_p scop;
    clan_options_p options;
    
    /* Default option setting. */
    options = clan_options_malloc() ;
    /* Extraction of the SCoP. */
    scop = clan_scop_extract(stdin, options);
    printf("Language: %s\n", scop->language);

    /* Save the planet. */
    clan_options_free(options);
    osl_scop_free(scop);

    return 0;
}