﻿all: pdf html

html:
	racket	-l	racket/gui	-l-	scribble/run	++xref-in	setup/xref	load-collections-xref	--htmls	--redirect-main	http://docs.racket-lang.org/	script.scrbl
	chmod a+rw ./script/*

pdf:
	racket	-l	racket/gui -l-	scribble/run	++xref-in	setup/xref	load-collections-xref	--prefix scribble-prefix.tex --pdf	script.scrbl
	chmod a+rw script.pdf
	mkdir -p script
	mv ./script.pdf ./script

