#!/usr/bin/env python3
from pathlib import Path
import subprocess, re
root = Path(__file__).resolve().parent
md_dir = root.parent / 'chapters'
out_dir = root / 'chapters'
out_dir.mkdir(exist_ok=True)
for old in out_dir.glob('*.tex'): old.unlink()
for md in sorted(md_dir.glob('*.md')):
    out = out_dir / f'{md.stem}.tex'
    subprocess.run([
        'pandoc', str(md), '-f', 'markdown+smart+citations+tex_math_dollars+tex_math_single_backslash', '-t', 'latex',
        '--biblatex', '--top-level-division=chapter', '--wrap=none', '-o', str(out)
    ], check=True)
    text = out.read_text(encoding='utf-8')
    text = text.replace('{figures/', '{../figures/')
    text = text.replace('.svg}', '.pdf}')
    text = text.replace('\\includesvg', '\\includegraphics')
    text = text.replace(',height=\\textheight', '')
    out.write_text(f'% Generated from ../chapters/{md.name}\n' + text, encoding='utf-8')
    print(out.relative_to(root))
