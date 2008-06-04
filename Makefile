BINDIR      := /usr/sbin/

BASED_ON     = $(shell perl -ne 'print if s/^based_on=//' config)

ifeq ($(BASED_ON),)
PREPARED     = 1
else
PREPARED     = $(shell [ -f .prepared ] && echo 1)
endif

ADDDIR       = /usr/share/gfxboot/bin/adddir
BFLAGS       = -O -v -L ../..

SUBDIRS      = fonts help-boot help-install po src

DEFAULT_LANG = tr_TR
DEFAULT_LANGUAGES = ca de en es fr it nl pl pt_BR tr

.PHONY: all clean distclean themes $(SUBDIRS)

ifeq ($(PREPARED), 1)

  all: bootlogo message

else

  all:
	$(ADDDIR) ../$(BASED_ON) .
	make clean
	touch .prepared
	make

endif

themes: all

%/.ready: %
	make -C $*

src/main.bin: src
	make -C src

bootlogo: src/main.bin help-install/.ready po/.ready fonts/.ready
	@rm -rf bootlogo.dir
	@mkdir bootlogo.dir
	cp -rL data-install/* fonts/*.fnt bootlogo.dir
ifdef DEFAULT_LANGUAGES
	@for i in $(DEFAULT_LANGUAGES); do \
		cp -rL po/$$i.tr bootlogo.dir; \
		cp -rL help-install/$$i.hlp bootlogo.dir; \
	done;
else
	cp -rL po/*.tr bootlogo.dir
	cp -rL help-install/*.hlp bootlogo.dir
endif
	cp src/main.bin bootlogo.dir/init
ifdef DEFAULT_LANG
	@echo $(DEFAULT_LANG) >bootlogo.dir/lang
endif
	@sh -c 'cd bootlogo.dir; chmod +t * ; chmod -t init languages'
	@sh -c 'cd bootlogo.dir; echo * | sed -e "s/ /\n/g" | cpio --quiet -o >../bootlogo'

message: src/main.bin help-boot/.ready po/.ready fonts/.ready
	@rm -rf message.dir
	@mkdir message.dir
	cp -rL data-boot/* fonts/*.fnt message.dir
	cp -rL po/en.tr help-boot/en.hlp message.dir
	cp src/main.bin message.dir/init
ifdef DEFAULT_LANG
	@echo $(DEFAULT_LANG) >message.dir/lang
ifdef DEFAULT_LANGUAGES
	@for i in $(DEFAULT_LANGUAGES); do \
		cp -rL po/$$i.tr help-boot/$$i.hlp message.dir; \
		echo $$i >> message.dir/languages; \
	done;
else
	cp -rL po/$(DEFAULT_LANG).tr help-boot/$(DEFAULT_LANG).hlp message.dir
	@echo $(DEFAULT_LANG) >>message.dir/languages
endif
endif
	@sh -c 'cd message.dir; echo * | sed -e "s/ /\n/g" | cpio --quiet -o >../message'

clean:
	@for i in $(SUBDIRS) ; do [ ! -f $$i/Makefile ] ||  make -C $$i clean || break ; done
	rm -rf bootlogo bootlogo.dir message message.dir *~

distclean: clean
ifneq ($(BASED_ON),)
	rm -f .prepared
	rm -f `find -type l \! -wholename ./Makefile`
	rmdir `find -depth -type d \! -name . \! -name .svn \! -wholename './.svn/*' \! -wholename './*/.svn/*'` 2>/dev/null || true
endif

	
