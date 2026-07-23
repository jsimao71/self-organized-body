# LaTeX edition

This directory contains the professional LaTeX edition of the book. The Markdown manuscript remains the editorial source of truth; each Markdown chapter has a corresponding generated `.tex` chapter.

## Structure

- `book.tex` - main book entry point
- `cover.tex` - custom TikZ cover
- `frontmatter.tex` - title, safety note, copyright, and preface
- `selforganizingbody.sty` - reusable professional typesetting style
- `references.bib` - reusable BibTeX database
- `chapters/*.tex` - one LaTeX file per Markdown chapter
- `Makefile` - PDF build commands

## Build

Requires a reasonably complete TeX Live installation with LuaLaTeX, Biber, and latexmk.

```bash
cd docs/latex
make pdf
```

The build sequence is handled by `latexmk` and includes bibliography generation through Biber.

## Editorial workflow

1. Edit the Markdown chapter.
2. Regenerate the matching `.tex` file with Pandoc:

```bash
pandoc ../chapters/01-example.md \
  -f markdown+smart \
  -t latex \
  --top-level-division=chapter \
  --wrap=none \
  -o chapters/01-example.tex
```

3. Build and visually inspect the PDF.
4. Commit both the `.md` and `.tex` versions.

## Typography

The edition uses KOMA-Script, Noto Serif, Inter, microtypography, a compact 6x9-inch trade-book page, restrained color, custom chapter openings, professional running heads, and a TikZ-generated cover. No external font files are required.
