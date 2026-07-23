.PHONY: pdf clean

pdf:
	latexmk -lualatex -interaction=nonstopmode -halt-on-error book.tex

clean:
	latexmk -C
	rm -f book.bbl book.run.xml
