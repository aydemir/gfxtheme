BINDIR    := /usr/sbin/

PRODUCT   = $(shell perl -ne 'print if s/^product=//' ../config)

HELP2TXT  = /usr/share/gfxboot/bin/help2txt

HELPFILES = $(addsuffix .hlp,$(basename $(wildcard *.html)))

%.hlp: %.html
	$(HELP2TXT) --product='$(PRODUCT)' $< >$@

all: .ready

.ready:	$(HELPFILES)
	@touch .ready

clean:
	rm -f .ready *.hlp *~

