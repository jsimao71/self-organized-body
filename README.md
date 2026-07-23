# The Self-Organizing Body

Version 0.3 is a full structural rewrite organized as a coherent systems-biology narrative.

## Read

- `docs/BOOK.md` — merged Markdown manuscript
- `docs/chapters/` — one Markdown file per chapter
- `docs/latex/book.tex` — LaTeX edition
- `docs/latex/book.pdf` — compiled book
- `docs/latex/references.bib` — reusable BibTeX database
- `docs/figures/` — actual SVG figures used by both editions
- `docs/archive/v0.2.1/` — previous manuscript preserved

## Build

```bash
cd docs/latex
python3 sync_from_markdown.py
latexmk -lualatex book.tex
```

The manuscript is a conceptual and research framework, not medical advice.
