
UNICODE_VERSION = 6.3.0

../precis_preparation.c: precis_preparation.pl precis_preparation.c.in
	perl precis_preparation.pl \
		precis-tables-$(UNICODE_VERSION).csv \
		UnicodeData-$(UNICODE_VERSION).txt \
		ArabicShaping-$(UNICODE_VERSION).txt \
		Scripts-$(UNICODE_VERSION).txt \
		> ../precis_preparation.c

