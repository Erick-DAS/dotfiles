---
name: latex-paper
description: "Write, compile, and visually verify academic papers in LaTeX (PDF output). Use whenever the user wants to produce or edit a scholarly paper, conference/journal submission, preprint, thesis chapter, or report with proper typesetting — i.e. anything with an abstract, sections, figures, tables, equations, algorithms, or a bibliography. Triggers include 'write a paper', 'LaTeX paper', '.tex', 'make a PDF of this paper', 'add a figure/table/equation', 'fix my references', 'compile my paper', or pasting a .tex file. This skill produces a compiled PDF and renders pages to PNG so the layout (figures fitting the margins, no overfull boxes, resolved citations) can be checked by eye, reporting which page each problem is on so only the affected pages need a second look. Do NOT use for slide decks (beamer/pptx), Word documents, resumes, posters, or generic non-academic PDFs."
---

# Academic papers in LaTeX

Produce professional academic papers as compiled PDFs. LaTeX gives the
typography readers expect from a paper, vector figures that scale cleanly, and a
plain-text `.tex` source that is easy to edit and version. The job here is not
just "make a PDF" — it is to make a *correct, well-fitting paper*: figures and
tables inside the margins, equations that don't overflow, and every `\ref` and
`\cite` resolved.

## MANDATORY: always start from the template

`assets/paper-template.tex` is the canonical baseline for every paper. **Always
copy it into the working directory and build on top of it** — keep its
`\documentclass`, preamble, package set, font choice, and conventions
(`booktabs`, `cleveref`, `natbib`, captions above tables / below figures,
`width=\linewidth` images). Add the content *inside* that structure. Do **not**
invent a different preamble or document class on your own.

The only reason to deviate from the template's `article` class is a
venue/format the user **explicitly** requires (e.g. IEEEtran, acmart, a NeurIPS
style, or ABNT for a Brazilian thesis). Never silently switch to one — see below.

## STOP and ask if anything is unclear

If the request does not clearly specify the points below, **ask the user before
generating anything** (ask the genuinely-missing ones, briefly — don't
interrogate over things already stated or obvious from context):

- **Content / source.** What is the paper about, or which material (notes,
  draft, data, uploaded file) should it be built from?
- **Format / venue.** Use the template's standard `article` class unless the
  user needs a specific venue style. If it's unclear whether a venue style is
  required, ask — do not pick one yourself, and do not assume plain `article`
  silently replaces a style the user may need.
- **Language.** Portuguese or English (affects `babel`/`polyglossia`, and the
  engine).
- **Title, authors, affiliations** — if a real, non-placeholder paper is wanted.

When these are clear (or the user says "just use your defaults"), proceed with
the template. When in doubt, one short clarifying question beats guessing.

## The loop: write → compile → look → fix

Always finish by **looking at the rendered pages**, not just trusting that it
compiled. A document can compile with zero errors and still have a table
bleeding into the margin or a `[?]` where a citation should be.

But looking is the expensive step, and its cost scales with the length of the
paper rather than with the size of your edit. Reading ten page images to check a
fixed typo is most of what makes this loop feel slow. So look deliberately, at
the pages that can actually have changed.

1. **Write or edit the `.tex` file.** When creating a new paper, copy
   `assets/paper-template.tex` into the working directory and build on it (see
   the mandatory rule above). When the user supplies their own `.tex`, edit
   that file in place instead. Either way, confirm the open questions above are
   resolved first. For specific constructs, consult `references/latex-patterns.md`.

2. **Compile with the script, choosing the mode that fits the edit.** It runs
   the right engine, handles multi-pass compilation and bibtex automatically,
   renders page images, and reports layout problems *with page numbers*.

   ```bash
   bash scripts/compile.sh paper.tex                 # first build & final check: render everything
   bash scripts/compile.sh paper.tex --pages auto    # mid-loop: render ONLY the flagged pages
   bash scripts/compile.sh paper.tex --no-preview    # text-only edit: no images at all
   ```

   Pick by asking *could this edit move anything on the page?*

   - **Prose, a citation key, a typo, a reworded caption** → `--no-preview`.
     These can't create an overfull box, and the log still catches undefined
     refs and citations, so you keep the safety check and skip the cost.
   - **A new or resized float, a table, a display equation, a package or
     margin change** → render. Layout can shift, so it needs eyes.
   - **After fixing reported problems** → `--pages auto`. It renders only the
     pages the report flagged, and renders *nothing* when the report is clean,
     because a clean report means there is nothing left to look at.

   On Windows PowerShell there is a port with the same report:
   `pwsh scripts/compile.ps1 paper.tex` (see the file list for its flags).
   Put `references.bib` next to the `.tex`. If compilation fails, the script
   prints the real errors from the log — fix them and recompile.

3. **View the rendered pages** in `paper_preview/`. The filenames carry real
   page numbers (`page-4.png` is page 4), and the directory only ever holds
   freshly-rendered images, so nothing in it is stale. Check: do figures and
   tables fit the text width? Are captions present and correct? Any `??` or
   `[?]` markers? Is a float stranded on its own page?

   Do a **full visual pass twice**: once on the first successful build, and
   once before delivering. In between, trust the report's page list — a page
   you already checked and did not edit does not need looking at again.

4. **Fix everything the report listed, in one editing pass, then recompile
   once.** The report is complete: it shows every overfull box and every
   unresolved reference in the document, not just the first. Fixing one problem
   and recompiling to find the next turns a single cycle into five, and each
   cycle costs another round of rendering and reading. Batch the fixes.

   If the same overfull box survives two attempted fixes, stop repeating and
   change approach — a wide table that resists `\resizebox` usually needs a
   different structure (a `p{}` wrapping column, `\small`, landscape, or
   splitting it), and a third identical attempt will fail the same way. If it
   still resists, say so and ask rather than looping.

5. **Deliver the PDF** — tell the user its path. (On claude.ai, where
   `present_files` exists, use it; in Claude Code there is no such tool, so
   just report where the file is.)

## Reading the layout report

The script ends with a report covering the things that most often go wrong:

- **Overfull boxes** — content past the margin, listed as `p.<page> <amount>pt`
  and sorted worst-first. Anything flagged `[VISIBLE]` (> 5pt) a reader will
  notice; fix it. Usual culprits and fixes are in `references/latex-patterns.md`
  (shrink/`\resizebox` a wide table, use a `p{}` wrapping column,
  `width=\linewidth` on an image, `\url{}` a long link, or break a long
  equation across lines).
- **Undefined `\ref`/`\cite`** — a `??`/`[?]` is showing in the PDF. The label
  or `.bib` key is wrong.
- **Underfull boxes** — loose spacing, usually cosmetic; address overfull first.

The last line, **`PAGES TO INSPECT`**, is the one to act on: it lists exactly
the pages carrying a visible problem, and it is what `--pages auto` renders.
Everything above it is diagnosis; that line is the instruction. When it says
`none`, the document is clean and there is no reason to open an image at all.

## Defaults that keep papers clean

- `width=\linewidth` (or a fraction) for every image, so it never overflows.
- `booktabs` rules (`\toprule`/`\midrule`/`\bottomrule`); never `\hline` or `|`.
- Captions **above** tables, **below** figures.
- Label every float/equation and reference it with `cleveref` (`\cref{...}`),
  not a hard-coded "Figure 1".
- Bibliography via `natbib` + `bibtex` (this environment has no biber).
- Always give floats a placement specifier, e.g. `\begin{figure}[ht]`.

## Environment notes

- Engines available: `pdflatex` (default), `xelatex`, `lualatex`. The script
  auto-selects `xelatex` when `fontspec`/`xeCJK`/`polyglossia` is used.
- `latexmk` drives compilation (multi-pass + bibtex); `pdftoppm` renders the
  PNG previews. `biber`/`biblatex` are **not** installed — use `natbib`+`bibtex`.
- If a package is missing: `tlmgr install <pkg>` (prefix with `sudo` if needed).

## Files in this skill

- `scripts/compile.sh` — compile + render previews + layout report (bash, for
  macOS/Linux/WSL/Git Bash). Run it for every build. Options:
  `--pages all|auto|2-5,9` (which pages to render — the main cost lever),
  `--no-preview`, `--dpi N` (default 110, enough to see a table cross the
  margin), `--engine pdflatex|xelatex|lualatex`.
- `scripts/compile.ps1` — Windows PowerShell port. Options: `-Pages`, `-Dpi N`,
  `-NoPreview`, `-Engine pdflatex|xelatex|lualatex`. Needs MiKTeX or TeX Live
  (latexmk + pdflatex) on PATH; Poppler's `pdftoppm` enables the page previews
  (skipped gracefully if absent).
- `assets/paper-template.tex` — a clean, self-contained starting paper
  (abstract, sections, figure, vector plot, subfigures, booktabs+siunitx table,
  equation, algorithm, citations). Compiles as-is.
- `assets/references.bib` — sample bibliography for the template.
- `references/latex-patterns.md` — copy-paste snippets for figures, tables,
  math, citations, cross-references, algorithms, plus fixes for content that
  doesn't fit and a troubleshooting table. Read it when building any of these.
