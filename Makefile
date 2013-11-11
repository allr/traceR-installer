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
real-all: check-path install-timer install-instrumented install-tracer
	@echo "=== all done! ==="

#
# traceR
#
.PHONY : build-tracer install-tracer

build-tracer: traceR/tracer.jar

install-tracer: $(REALPREFIX)/tracer.jar

$(REALPREFIX)/tracer.jar: traceR/tracer.jar | $(REALPREFIX)
# FIXME: Move this to a Makefile in traceR
	$(E) ===== installing traceR =====
	$(Q)cd traceR ; $(MAKE) install PREFIX=$(REALPREFIX)

traceR/tracer.jar: traceR/.git/HEAD
	$(E) ===== building traceR =====
	$(Q)cd traceR ; $(MAKE)


#
# timeR
#
.PHONY : build-timer install-timer

build-timer: timeR/bin/R

install-timer: $(REALPREFIX)/timed/bin/R

$(REALPREFIX)/timed/bin/R: timeR/bin/R | $(REALPREFIX)
	$(E) ===== installing timeR =====
	$(Q)cd timeR ; $(MAKE) install

timeR/bin/R: timeR/.git/HEAD
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

r-instrumented/bin/R: r-instrumented/.git/HEAD | $(REALPREFIX)
	$(E) ===== building r-instrumented =====
	$(Q)cd r-instrumented ; ./configure --prefix=$(REALPREFIX)/instrumented $(COMMON_CONFIGOPTS) $(INSTRUMENTED_CONFIGOPTS)
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
	$(Q)rm -f .old_installprefix
# no clean target supported for traceR


# create target directory
$(REALPREFIX):
	$(Q)mkdir -p $(REALPREFIX)

# Note: This is a pattern rule because GNU make would split it
#       into multiple single-target rules otherwise
timeR/.git/% r-instrumented/.git/% traceR/.git/%: .git/% .git/FETCH_HEAD .git/refs/heads/master
	@echo ===== Updating submodules =====
	@git submodule update --init
	@touch $@

# Workaround for freshly-cloned repos that don't have this file yet
.git/FETCH_HEAD:
#	@git fetch   would work too, but fails if there are no remotes
	@touch $@

# helper target for the maintainer
updateall:
	git submodule foreach git pull origin master

# check for change of target prefix
-include .old_installprefix

.PHONY : check-path
check-path:
	$(Q)echo OLD_PREFIX=$(REALPREFIX) > .old_installprefix

# conditionally add a dependency if OLD_PREFIX does not exist or differs
ifndef OLD_PREFIX
check-path: touch-heads
else
  ifeq ($(OLD_PREFIX), $(REALPREFIX))
check-path:
  else
check-path: touch-heads
  endif
endif

.PHONY : touch-heads
touch-heads: traceR/.git/HEAD timeR/.git/HEAD r-instrumented/.git/HEAD
	$(Q)touch traceR/.git/HEAD
	$(Q)touch timeR/.git/HEAD
	$(Q)touch r-instrumented/.git/HEAD
