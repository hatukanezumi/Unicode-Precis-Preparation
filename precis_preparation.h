
#include "EXTERN.h"
#include "perl.h"

typedef enum {
    PRECIS_IDENTIFIER_CLASS = 1,
    PRECIS_FREE_FORM_CLASS
} precis_string_class_t;

typedef enum {
    PRECIS_UNASSIGNED = 0,
    PRECIS_PVALID,
    PRECIS_ID_DIS,
    PRECIS_CONTEXTJ,
    PRECIS_CONTEXTO,
    PRECIS_DISALLOWED
} precis_prop_t;

extern U8 precis_prop_lookup(U32);
extern U8 precis_ctx_lookup(U32);
extern STRLEN precis_prepare(int, U8 *, const STRLEN);

