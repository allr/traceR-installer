ifdef PREFIX
all: real-all
REALPREFIX := $(abspath $(PREFIX))
else
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

TRACER_JAR=tracer-0.0.1-SNAPSHOT-jar-with-dependencies.jar

# default target
real-all: install-timer install-instrumented install-tracer
	@echo "=== all done! ==="

#
# traceR
#
.PHONY : build-tracer install-tracer

build-tracer: traceR/$(TRACER_JAR)

install-tracer: $(REALPREFIX)/tracer.jar

$(REALPREFIX)/tracer.jar: traceR/$(TRACER_JAR) | $(REALPREFIX)
	$(E) ===== installing traceR =====
# traceR itself
	$(Q)cp $< $@
# sample queries
	$(Q)mkdir -p $(REALPREFIX)/queries
	$(Q)cp traceR/queries/* $(REALPREFIX)/queries
# shell script
	$(Q)sed '/^BASEDIR=/ s!=.*!=$(REALPREFIX)!' traceR/tracer.sh > $(REALPREFIX)/tracer.sh
	$(Q)chmod +x $(REALPREFIX)/tracer.sh

traceR/$(TRACER_JAR): traceR/.git/HEAD
	$(E) ===== building traceR =====
	$(Q)cd traceR ; ./build.sh


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

# error message if no REALPREFIX is specified
error:
	@echo ERROR: No target directory has been specified!
	@echo ""
	@echo Please use \"$(MAKE) REALPREFIX=/where/you/want/it/installed\"
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


# FIXME: Add
clean:
	@echo Sorry, the \"clean\" target is currently not supported.

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
