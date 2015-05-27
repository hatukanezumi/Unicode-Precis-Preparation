#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "precis_preparation.h"

/* for Win32 with Visual Studio (MSVC) */
#ifdef _MSC_VER
#  define strcasecmp _stricmp
#endif /* _MSC_VER */

MODULE = Unicode::Precis::Preparation		PACKAGE = Unicode::Precis::Preparation		

int
_lookup_prop(cp)
	U32 cp;
    PROTOTYPE: $
    CODE:
	RETVAL = (int)precis_prop_lookup(cp);
    OUTPUT:
	RETVAL

int
_lookup_ctx(cp)
	U32 cp;
    PROTOTYPE: $
    CODE:
	RETVAL = (int)precis_ctx_lookup(cp);
    OUTPUT:
	RETVAL

int
_propname()
    ALIAS:
	UNASSIGNED = PRECIS_UNASSIGNED
	PVALID     = PRECIS_PVALID
	ID_DIS     = PRECIS_ID_DIS
	CONTEXTJ   = PRECIS_CONTEXTJ
	CONTEXTO   = PRECIS_CONTEXTO
	DISALLOWED = PRECIS_DISALLOWED
    CODE:
	RETVAL = ix;
    OUTPUT:
	RETVAL

int
prepare(string, stringclassstr)
	SV *string;
	char *stringclassstr;
    PROTOTYPE: $;$
    PREINIT:
	char *buf;
	STRLEN buflen;
	int stringclass;
    CODE:
	if (SvOK(string))
	    buf = SvPV(string, buflen);
	else
	    XSRETURN_UNDEF;

	if (stringclassstr == NULL || *stringclassstr == '\0')
	    stringclass = 0;
	else if (strcasecmp(stringclassstr, "IdentifierClass") == 0)
	    stringclass = PRECIS_IDENTIFIER_CLASS;
	else if (strcasecmp(stringclassstr, "FreeFormClass") == 0)
	    stringclass = PRECIS_FREE_FORM_CLASS;
	else if (strcasecmp(stringclassstr, "ValidUTF8") == 0)
	    stringclass = 0;
	else
	    croak("Malformed value");

	RETVAL = precis_prepare(stringclass, (U8 *)buf, buflen);
    OUTPUT:
	RETVAL

