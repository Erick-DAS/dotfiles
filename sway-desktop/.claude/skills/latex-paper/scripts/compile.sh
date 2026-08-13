#!/usr/bin/env bash
#
# compile.sh — Compile an academic LaTeX paper, render page images, and report
#              layout problems (overfull boxes, undefined refs/citations).
#
# Usage:
#   bash compile.sh paper.tex [--dpi N] [--no-preview] [--engine pdflatex|xelatex|lualatex]
#
# What it does:
#   1. Picks an engine (auto: xelatex if fontspec/xeCJK is used, else pdflatex).
#   2. Runs latexmk, which handles multi-pass compilation AND bibtex automatically.
#   3. Renders every page to a PNG in <basename>_preview/ so you can LOOK at the
#      layout and confirm figures/tables fit inside the margins.
#   4. Prints a layout report: overfull/underfull boxes (with overflow in pt),
#      undefined references, and undefined citations.
#
# Exit code is non-zero if compilation fails. Layout warnings do NOT fail the
# build — they are for you to review against the rendered pages.

set -uo pipefail

# ---- args ----------------------------------------------------------------
TEX=""
DPI=150
PREVIEW=1
ENGINE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dpi)        DPI="$2"; shift 2 ;;
    --no-preview) PREVIEW=0; shift ;;
    --engine)     ENGINE="$2"; shift 2 ;;
    -h|--help)    grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)            TEX="$1"; shift ;;
  esac
done

if [[ -z "$TEX" || ! -f "$TEX" ]]; then
  echo "ERROR: pass a .tex file. Usage: bash compile.sh paper.tex [--dpi N] [--no-preview]" >&2
  exit 2
fi

DIR="$(cd "$(dirname "$TEX")" && pwd)"
BASE="$(basename "${TEX%.tex}")"
cd "$DIR"

# ---- engine auto-detection ----------------------------------------------
if [[ -z "$ENGINE" ]]; then
  if grep -Eq '^[^%]*\\usepackage(\[[^]]*\])?\{(fontspec|xeCJK|polyglossia)\}' "$BASE.tex"; then
    ENGINE="xelatex"
  else
    ENGINE="pdflatex"
  fi
fi

case "$ENGINE" in
  pdflatex) LMK_FLAG="-pdf" ;;
  xelatex)  LMK_FLAG="-xelatex" ;;
  lualatex) LMK_FLAG="-lualatex" ;;
  *) echo "ERROR: unknown engine '$ENGINE'" >&2; exit 2 ;;
esac

echo "==> Compiling $BASE.tex with $ENGINE (via latexmk)"

# -interaction=nonstopmode: never block on an error prompt.
# latexmk reruns the engine until cross-references settle and runs bibtex
# whenever a .bib is cited, so no manual multi-pass juggling is needed.
latexmk $LMK_FLAG -interaction=nonstopmode -halt-on-error -file-line-error \
        -synctex=0 "$BASE.tex" > /dev/null 2>&1
STATUS=$?

LOG="$BASE.log"

# ---- compile failure: surface the real errors ---------------------------
if [[ $STATUS -ne 0 || ! -f "$BASE.pdf" ]]; then
  echo ""
  echo "❌ COMPILATION FAILED. First errors from $LOG:"
  echo "------------------------------------------------------------"
  # Show lines that look like real errors plus a little context.
  grep -nE '^(.*:[0-9]+:|! )' "$LOG" 2>/dev/null | head -n 15
  echo "------------------------------------------------------------"
  echo "Tips: 'Undefined control sequence' = unknown command or missing \\usepackage."
  echo "      'Missing \$ inserted'        = math symbol used outside \$...\$."
  echo "      'File X.sty not found'       = missing package."
  exit 1
fi

PAGES="?"
command -v pdfinfo >/dev/null 2>&1 && PAGES="$(pdfinfo "$BASE.pdf" 2>/dev/null | awk '/^Pages:/{print $2}')"
echo "✓ Built $BASE.pdf ($PAGES pages)"

# ---- render page images for visual inspection ---------------------------
if [[ $PREVIEW -eq 1 ]]; then
  if command -v pdftoppm >/dev/null 2>&1; then
    OUTDIR="${BASE}_preview"
    rm -rf "$OUTDIR"; mkdir -p "$OUTDIR"
    pdftoppm -png -r "$DPI" "$BASE.pdf" "$OUTDIR/page" >/dev/null 2>&1
    echo "✓ Rendered pages to $OUTDIR/  — VIEW THESE to confirm the layout looks right."
  else
    echo "⚠ pdftoppm not found; skipping image preview."
  fi
fi

# ---- layout report -------------------------------------------------------
echo ""
echo "================= LAYOUT REPORT ================="

# Overfull boxes = content spilling past the margin (the #1 thing to fix in a
# paper: a wide table, a long equation, or an unbreakable URL). We pull the
# overflow magnitude and flag anything a reader would actually notice (>5pt).
OVERFULL="$(grep -nE 'Overfull \\(hbox|vbox)' "$LOG" 2>/dev/null)"
if [[ -n "$OVERFULL" ]]; then
  echo ""
  echo "OVERFULL BOXES (content past the margin):"
  echo "$OVERFULL" | sed -E 's/.*Overfull \\([hv])box \(([0-9.]+)pt[^)]*\)(.*)/  \2pt \1box —\3/' \
    | sort -t' ' -k2 -rn \
    | awk '{ sev=($1+0 > 5 ? " [VISIBLE]" : " [minor]"); print "  •", $0 sev }' \
    | sed 's/  •   /  • /'
  echo "  → Fix VISIBLE ones: shrink/resize wide tables & images (width=\\linewidth),"
  echo "    wrap long URLs (\\url{}), or break long display equations."
else
  echo "  ✓ No overfull boxes."
fi

UNDERFULL_N="$(grep -cE 'Underfull \\(hbox|vbox)' "$LOG" 2>/dev/null)"
[[ "${UNDERFULL_N:-0}" -gt 0 ]] && echo "  • $UNDERFULL_N underfull box(es) (loose spacing — usually cosmetic)."

# Undefined references / citations — easy to miss, embarrassing in a paper.
UNDEF_REF="$(grep -oE "Reference \`[^']+' on page [0-9]+ undefined" "$LOG" 2>/dev/null | sort -u)"
UNDEF_CIT="$(grep -oE "Citation \`[^']+' on page [0-9]+ undefined" "$LOG" 2>/dev/null | sort -u)"
if [[ -n "$UNDEF_REF" || -n "$UNDEF_CIT" ]]; then
  echo ""
  echo "UNDEFINED CROSS-REFERENCES / CITATIONS:"
  [[ -n "$UNDEF_REF" ]] && echo "$UNDEF_REF" | sed 's/^/  • \\ref → /'
  [[ -n "$UNDEF_CIT" ]] && echo "$UNDEF_CIT" | sed 's/^/  • \\cite → /'
  echo "  → A '??' or '[?]' is showing in the PDF. Check the \\label / .bib key."
else
  echo "  ✓ All \\ref and \\cite resolved."
fi

# Missing fonts/characters
if grep -q 'Missing character' "$LOG" 2>/dev/null; then
  echo "  • Missing characters detected — a glyph isn't in the current font."
fi

echo "================================================="
exit 0
