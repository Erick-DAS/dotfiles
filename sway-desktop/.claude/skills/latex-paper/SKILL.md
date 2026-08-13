---
name: latex-paper
description: "Write, compile, and visually verify academic papers in LaTeX (PDF output). Use whenever the user wants to produce or edit a scholarly paper, conference/journal submission, preprint, thesis chapter, or report with proper typesetting — i.e. anything with an abstract, sections, figures, tables, equations, algorithms, or a bibliography. Triggers include 'write a paper', 'LaTeX paper', '.tex', 'make a PDF of this paper', 'add a figure/table/equation', 'fix my references', 'compile my paper', or pasting a .tex file. This skill produces a compiled PDF and renders every page to PNG so the layout (figures fitting the margins, no overfull boxes, resolved citations) can be checked by eye. Do NOT use for slide decks (beamer/pptx), Word documents, resumes, posters, or generic non-academic PDFs."
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

1. **Write or edit the `.tex` file.** When creating a new paper, copy
   `assets/paper-template.tex` into the working directory and build on it (see
   the mandatory rule above). When the user supplies their own `.tex`, edit
   that file in place instead. Either way, confirm the open questions above are
   resolved first. For specific constructs, consult `references/latex-patterns.md`.

2. **Compile with the script.** It runs the right engine, handles multi-pass
   compilation and bibtex automatically, renders page images, and reports
   layout problems. On macOS/Linux (and WSL/Git Bash):
   ```bash
   bash scripts/compile.sh paper.tex
   ```
   On Windows PowerShell, use the equivalent port (same behavior and report):
   ```powershell
   pwsh scripts/compile.ps1 paper.tex
   ```
   Put `references.bib` next to the `.tex`. If compilation fails, the script
   prints the real errors from the log — fix them and recompile.

3. **View the rendered pages.** They land in `paper_preview/page-1.png`, etc.
   Open them and actually check: do figures and tables fit the text width? Are
   captions present and correct? Any `??` or `[?]` markers? Is a float stranded
   on its own page?

4. **Fix and repeat** until the LAYOUT REPORT is clean and the pages look right.

5. **Deliver the PDF** (use `present_files` on the `.pdf`).

## Reading the layout report

The script ends with a report covering the things that most often go wrong:

- **Overfull boxes** — content past the margin. Anything flagged `[VISIBLE]`
  (> 5pt) a reader will notice; fix it. Usual culprits and fixes are in
  `references/latex-patterns.md` (shrink/`\resizebox` a wide table, use a
  `p{}` wrapping column, `width=\linewidth` on an image, `\url{}` a long link,
  or break a long equation across lines).
- **Undefined `\ref`/`\cite`** — a `??`/`[?]` is showing in the PDF. The label
  or `.bib` key is wrong.
- **Underfull boxes** — loose spacing, usually cosmetic; address overfull first.

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
  macOS/Linux/WSL/Git Bash). Run it for every build. Options: `--dpi N`
  (preview resolution), `--no-preview`, `--engine pdflatex|xelatex|lualatex`.
- `scripts/compile.ps1` — Windows PowerShell port with identical behavior and
  report. Options: `-Dpi N`, `-NoPreview`, `-Engine pdflatex|xelatex|lualatex`.
  Needs MiKTeX or TeX Live (latexmk + pdflatex) on PATH; Poppler's `pdftoppm`
  enables the page previews (skipped gracefully if absent).
- `assets/paper-template.tex` — a clean, self-contained starting paper
  (abstract, sections, figure, vector plot, subfigures, booktabs+siunitx table,
  equation, algorithm, citations). Compiles as-is.
- `assets/references.bib` — sample bibliography for the template.
- `references/latex-patterns.md` — copy-paste snippets for figures, tables,
  math, citations, cross-references, algorithms, plus fixes for content that
  doesn't fit and a troubleshooting table. Read it when building any of these.
