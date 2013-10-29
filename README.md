This repository contains a Makefile that will install the complete
traceR framework, i.e. timeR, r-instrumented and traceR.

To use it, enter "make PREFIX=/foo/bar", replacing /foo/bar with the
directory where you want to install everything.

When the compilation and installation process has finished, the target
directory should contain a script "tracer.sh" which can be used to run
an R script under traceR. The output database db.db will be generated
in the current directory. If the R script needs additional R packages,
they must be installed for both included R interpreters which are in
$PREFIX/timed and $PREFIX/instrumented respectively.

If you update this repository (using git pull), a new invocation of
"make PREFIX=..." should rebuild everything as needed.
Please be aware that the Makefile is currently considered to be
"experimental", so it may not work correctly in every situation and it
may rebuild more than strictly necessary. If in doubt, try "make clean"
before building; if there are still issues try a fresh checkout of
traceR-installer in a new directory.

