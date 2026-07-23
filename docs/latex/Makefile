.PHONY: pdf clean verify

pdf:
	latexmk -lualatex -interaction=nonstopmode -halt-on-error book.tex

verify: pdf
	@test -s book.pdf
	@pdfinfo book.pdf | grep -E 'Pages|Page size|Title'
	@test -s book.toc
	@test -s book.bbl

clean:
	latexmk -C
	rm -f book.bbl book.run.xml book.bcf-SAVE-ERROR book.bbl-SAVE-ERROR
