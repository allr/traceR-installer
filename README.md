Intro
=====
This repository contains a Makefile that will install the complete
traceR framework, i.e. timeR, r-instrumented and traceR.

To use it, enter `make PREFIX=/foo/bar`, replacing /foo/bar with the
directory where you want to install everything.

When the compilation and installation process has finished, the target
directory should contain a script `tracer.pl` which can be used to run
an R script under traceR. The output database db.db will be generated
in the current directory. If the R script needs additional R packages,
they must be installed for both included R interpreters which are in
$PREFIX/timed and $PREFIX/instrumented respectively.

If you update this repository (using git pull), a new invocation of
`make PREFIX=...` should rebuild everything as needed.
Please be aware that the Makefile may rebuild more or less than
strictly necessary. If in doubt, try `make clean` before building; if
there are still issues try a fresh checkout of traceR-installer in a
new directory.

More details about the installed programs can be found in their
respective repositories/subdirectories. If you just want a very quick
demonstration, run `demos/rundemos.sh` from the installation
directory, wait until it has completed and then check the `plots`
subdirectory.


Legalese
========
Copyright (C) 2013-2017 TU Dortmund Informatik LS XII

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, a copy is available at
[http://www.r-project.org/Licenses/](http://www.r-project.org/Licenses/)
