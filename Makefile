ifdef PREFIX
all: | .git
all: real-all
REALPREFIX := $(abspath $(PREFIX))
else
all: | .git
all: error
endif

# Enable verbose compilation with "make V=1"
ifdef V
 Q :=
 E := @:
else
 Q := @
 E := @echo
endif

# default target
real-all: install-timer install-instrumented install-tracer
	@echo "=== all done! ==="

#
# traceR
#
.PHONY : install-tracer

install-tracer: $(REALPREFIX)/tracer.pl

$(REALPREFIX)/tracer.pl: traceR/tracer.pl | $(REALPREFIX)
	$(E) ===== installing traceR =====
	$(Q)cd traceR ; $(MAKE) install PREFIX=$(REALPREFIX)


#
# timeR
#
.PHONY : build-timer install-timer

build-timer: timeR/bin/R

install-timer: $(REALPREFIX)/timed/bin/R

$(REALPREFIX)/timed/bin/R: timeR/bin/R | $(REALPREFIX)
	$(E) ===== installing timeR =====
	$(Q)cd timeR ; $(MAKE) install

timeR/bin/R: .last-modupdate .old_installprefix | $(REALPREFIX)
	$(E) ===== building timeR =====
	$(Q)cd timeR ; ./configure --prefix=$(REALPREFIX)/timed --enable-timeR $(COMMON_CONFIGOPTS) $(TIMER_CONFIGOPTS)
	$(Q)cd timeR ; $(MAKE) $(MAKEOPTS)


#
# r-instrumented
#
.PHONY : build-instrumented install-instrumented

build-instrumented: r-instrumented/bin/R | $(REALPREFIX)

install-instrumented: $(REALPREFIX)/instrumented/bin/R

$(REALPREFIX)/instrumented/bin/R: r-instrumented/bin/R | $(REALPREFIX)
	$(E) ===== installing r-instrumented =====
	$(Q)cd r-instrumented ; $(MAKE) install

r-instrumented/bin/R: .last-modupdate .old_installprefix | $(REALPREFIX)
	$(E) ===== building r-instrumented =====
	$(Q)cd r-instrumented ; ./configure --prefix=$(REALPREFIX)/instrumented --disable-debugscopes $(COMMON_CONFIGOPTS) $(INSTRUMENTED_CONFIGOPTS)
	$(Q)cd r-instrumented ; $(MAKE) $(MAKEOPTS)
	$(Q)touch $@


#
# other rules
#

# error message if no REFIX is specified
error:
	@echo ERROR: No target directory has been specified!
	@echo ""
	@echo Please use \"$(MAKE) PREFIX=/where/you/want/it/installed\"
	@echo to specify a target directory.
	@echo ""
	@echo You can also use \"make help\" to see a list of
	@echo variables available.


# help message
help:
	@echo "Available variables:"
	@echo "  REALPREFIX"
	@echo "    sets the directory where the traceR framework will be installed"
	@echo ""
	@echo "  COMMON_CONFIGOPTS"
	@echo "    sets the options passed to configure for both timeR and r-instrumented"
	@echo ""
	@echo "  TIMER_CONFIGOPTS"
	@echo "    sets the options passed to configure for just timeR"
	@echo ""
	@echo "  INSTRUMENTED_CONFIGOPTS"
	@echo "    sets the options passed to configure for just r-instrumented"


# sanity check
.git:
	@echo "ERROR: No .git directory found"
	@echo ""
	@echo "This Makefile only works if you use a clone of the traceR-install"
	@echo "repository and not if you just have an archive of its contents."
	@echo ""
	@echo "Please clone the traceR-install repository and try again."
	@false

# run "make clean" in the subrepositories
clean:
	$(E) ===== cleaning timeR =====
	$(Q)cd timeR ; $(MAKE) clean
	$(E) ===== cleaning r-instrumented =====
	$(Q)cd r-instrumented ; $(MAKE) clean
	$(E) ===== cleaning traceR =====
	$(Q)cd traceR ; $(MAKE) clean
	$(Q)rm -f .old_installprefix .last-modupdate


# create target directory
$(REALPREFIX):
	$(Q)mkdir -p $(REALPREFIX)

.last-modupdate: .git/HEAD .git/FETCH_HEAD .git/refs/heads/master
	$(Q)git submodule update --init
	$(Q)touch $@

# Workaround for freshly-cloned repos that don't have this file yet
.git/FETCH_HEAD:
#	@git fetch   would work too, but fails if there are no remotes
	$(Q)touch $@

# helper target for the maintainer
updateall:
	git submodule foreach git pull origin master

# check for change of target prefix
-include .old_installprefix

ifdef PREFIX
.old_installprefix:
	$(Q)echo OLD_PREFIX=$(REALPREFIX) > .old_installprefix
else
.old_installprefix:
endif

# conditionally add a force-rebuild dependency if OLD_PREFIX does not exist or differs
ifndef OLD_PREFIX
.old_installprefix: FORCE
else
  ifeq ($(OLD_PREFIX), $(REALPREFIX))
.old_installprefix:
  else
.old_installprefix: FORCE
  endif
endif

# empty no-rule target for forcing other targets to always rebuild
.PHONE : FORCE
FORCE:
