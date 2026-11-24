#!/usr/bin/env bash
#
# compile.sh - Compile an academic LaTeX paper, render page images, and report
#              layout problems (overfull boxes, undefined refs/citations).
#
# Usage:
#   bash compile.sh paper.tex [--pages SPEC] [--dpi N] [--no-preview]
#                             [--engine pdflatex|xelatex|lualatex]
#
# What it does:
#   1. Picks an engine (auto: xelatex if fontspec/xeCJK is used, else pdflatex).
#   2. Runs latexmk, which handles multi-pass compilation AND bibtex automatically.
#   3. Renders page images to <basename>_preview/ so you can LOOK at the layout.
#   4. Prints a layout report that says WHICH PAGE each problem is on, so you can
#      re-render and re-inspect only the pages that actually need a second look.
#
# --pages SPEC controls which pages get rendered. This is the main cost lever:
# reading page images is by far the most expensive part of the write-compile-look
# loop, and it scales with the length of the paper rather than with what changed.
#
#   --pages all    every page (default; right for the first build and the final check)
#   --pages auto   ONLY the pages the layout report flagged. Renders nothing when
#                  the report is clean - which is the common case mid-loop, and
#                  the whole point: a clean report means there is nothing to look at.
#   --pages 3,7    an explicit list
#   --pages 2-5    a range (lists and ranges may be combined: 2-5,9)
#
# --no-preview skips rendering entirely. Use it for edits that cannot change
# layout (fixing prose, a citation key, a typo): the log still catches undefined
# refs and overfull boxes, so you get the safety check without the image cost.
#
# Exit code is non-zero if compilation fails. Layout warnings do NOT fail the
# build - they are for you to review against the rendered pages.

set -uo pipefail

# ---- args ----------------------------------------------------------------
TEX=""
DPI=110          # enough to see a table crossing the margin; 150 costs ~2x the
                 # pixels for detail that does not change any layout decision.
PREVIEW=1
ENGINE=""
PAGES="all"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dpi)        DPI="$2"; shift 2 ;;
    --pages)      PAGES="$2"; shift 2 ;;
    --no-preview) PREVIEW=0; shift ;;
    --engine)     ENGINE="$2"; shift 2 ;;
    -h|--help)    grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)            TEX="$1"; shift ;;
  esac
done

if [[ -z "$TEX" || ! -f "$TEX" ]]; then
  echo "ERROR: pass a .tex file. Usage: bash compile.sh paper.tex [--pages SPEC] [--dpi N] [--no-preview]" >&2
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
# whenever a .bib is cited, so no manual multi-pass juggling is needed. It also
# skips work when nothing changed, so recompiling after a small edit is cheap.
latexmk $LMK_FLAG -interaction=nonstopmode -halt-on-error -file-line-error \
        -synctex=0 "$BASE.tex" > /dev/null 2>&1
STATUS=$?

LOG="$BASE.log"

# ---- compile failure: surface the real errors ---------------------------
if [[ $STATUS -ne 0 || ! -f "$BASE.pdf" ]]; then
  echo ""
  echo "❌ COMPILATION FAILED. First errors from $LOG:"
  echo "------------------------------------------------------------"
  grep -nE '^(.*:[0-9]+:|! )' "$LOG" 2>/dev/null | head -n 15
  echo "------------------------------------------------------------"
  echo "Tips: 'Undefined control sequence' = unknown command or missing \\usepackage."
  echo "      'Missing \$ inserted'        = math symbol used outside \$...\$."
  echo "      'File X.sty not found'       = missing package."
  exit 1
fi

PAGECOUNT="?"
command -v pdfinfo >/dev/null 2>&1 && PAGECOUNT="$(pdfinfo "$BASE.pdf" 2>/dev/null | awk '/^Pages:/{print $2}')"
echo "✓ Built $BASE.pdf ($PAGECOUNT pages)"

# ---- attribute overfull boxes to page numbers ---------------------------
# TeX writes a shipout marker "[N" to the log as each page is finished, and
# emits a box warning while building the page it belongs to. So a warning seen
# after the marker for page N is on page N+1. Knowing the page is what makes
# targeted re-rendering possible - without it the only safe move is to look at
# every page on every iteration, which is the expensive habit this avoids.
# (perl is guaranteed here: latexmk is itself a perl script.)
OVERFULL_TSV="$(perl -e '
my $log = shift;
open(my $fh, "<", $log) or exit 0;
my $page = 1;
my @out;
while (my $line = <$fh>) {
  # Walk each line in order so a marker and a warning on the same line are
  # attributed correctly.
  while ($line =~ /(\[\d+|Overfull \\[hv]box \([\d.]+pt[^)]*\)[^\n]*)/g) {
    my $tok = $1;
    if ($tok =~ /^\[(\d+)/) {
      $page = $1 + 1;
    } elsif ($tok =~ /^Overfull \\([hv])box \(([\d.]+)pt/) {
      my ($kind, $amt) = ($1, $2);
      my $at = ($tok =~ /at lines? ([\d]+(?:--[\d]+)?)/) ? $1 : "";
      push @out, [$page, $amt, $kind, $at];
    }
  }
}
# Worst overflow first: that is the one a reader notices.
for my $r (sort { $b->[1] <=> $a->[1] } @out) {
  printf("%d\t%s\t%s\t%s\n", @$r);
}
' "$LOG" 2>/dev/null)"

# Pages worth a second look: anything overflowing enough to be visible (>5pt),
# plus any page showing a ?? / [?] marker.
FLAGGED_PAGES="$(
  {
    [[ -n "$OVERFULL_TSV" ]] && awk -F'\t' '$2+0 > 5 {print $1}' <<< "$OVERFULL_TSV"
    grep -oE "(Reference|Citation) \`[^']+' on page [0-9]+ undefined" "$LOG" 2>/dev/null \
      | grep -oE 'page [0-9]+' | awk '{print $2}'
  } 2>/dev/null | sort -n -u | paste -sd, -
)"

# ---- render page images for visual inspection ---------------------------
render_pages() {
  local spec="$1" outdir="$2"
  # Only ever leave freshly-rendered images behind. A stale PNG from an earlier
  # build that silently disagrees with the current PDF is worse than no image.
  rm -rf "$outdir"; mkdir -p "$outdir"

  if [[ "$spec" == "all" ]]; then
    pdftoppm -png -r "$DPI" "$BASE.pdf" "$outdir/page" >/dev/null 2>&1
    return
  fi
  # Expand "2-5,9" into individual pages. pdftoppm names output by real page
  # number, so filenames stay aligned with the PDF either way.
  local part first last p
  IFS=',' read -ra PARTS <<< "$spec"
  for part in "${PARTS[@]}"; do
    if [[ "$part" == *-* ]]; then
      first="${part%%-*}"; last="${part##*-}"
    else
      first="$part"; last="$part"
    fi
    [[ "$first" =~ ^[0-9]+$ && "$last" =~ ^[0-9]+$ ]] || continue
    for (( p=first; p<=last; p++ )); do
      pdftoppm -png -r "$DPI" -f "$p" -l "$p" "$BASE.pdf" "$outdir/page" >/dev/null 2>&1
    done
  done
}

OUTDIR="${BASE}_preview"
if [[ $PREVIEW -eq 0 ]]; then
  echo "· Preview skipped (--no-preview). The layout report below still applies."
elif ! command -v pdftoppm >/dev/null 2>&1; then
  echo "⚠ pdftoppm not found; skipping image preview."
else
  RENDER_SPEC="$PAGES"
  if [[ "$PAGES" == "auto" ]]; then
    RENDER_SPEC="$FLAGGED_PAGES"
  fi

  if [[ "$PAGES" == "auto" && -z "$FLAGGED_PAGES" ]]; then
    rm -rf "$OUTDIR"
    echo "· --pages auto: report is clean, so no pages rendered. Nothing to inspect."
  else
    render_pages "$RENDER_SPEC" "$OUTDIR"
    NRENDERED="$(ls "$OUTDIR" 2>/dev/null | wc -l | tr -d ' ')"
    if [[ "$RENDER_SPEC" == "all" ]]; then
      echo "✓ Rendered all $NRENDERED page(s) to $OUTDIR/ at ${DPI}dpi - VIEW THESE to confirm the layout."
    else
      echo "✓ Rendered page(s) $RENDER_SPEC to $OUTDIR/ at ${DPI}dpi - only these need a look."
    fi
  fi
fi

# ---- layout report -------------------------------------------------------
echo ""
echo "================= LAYOUT REPORT ================="

if [[ -n "$OVERFULL_TSV" ]]; then
  echo ""
  echo "OVERFULL BOXES (content past the margin):"
  awk -F'\t' '{
    sev = ($2+0 > 5 ? "[VISIBLE]" : "[minor]  ")
    at  = ($4 == "" ? "" : "  (lines " $4 ")")
    printf("  • p.%-3s %8spt %sbox  %s%s\n", $1, $2, $3, sev, at)
  }' <<< "$OVERFULL_TSV"
  echo "  → Fix VISIBLE ones: shrink/resize wide tables & images (width=\\linewidth),"
  echo "    wrap long URLs (\\url{}), or break long display equations."
else
  echo "  ✓ No overfull boxes."
fi

UNDERFULL_N="$(grep -cE 'Underfull \\(hbox|vbox)' "$LOG" 2>/dev/null)"
[[ "${UNDERFULL_N:-0}" -gt 0 ]] && echo "  • $UNDERFULL_N underfull box(es) (loose spacing - usually cosmetic)."

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

if grep -q 'Missing character' "$LOG" 2>/dev/null; then
  echo "  • Missing characters detected - a glyph isn't in the current font."
fi

# The one line to act on: which pages actually need eyes. Everything else in the
# report is diagnosis; this is the instruction.
echo ""
if [[ -n "$FLAGGED_PAGES" ]]; then
  echo "PAGES TO INSPECT: $FLAGGED_PAGES"
  echo "  → Re-render just these after fixing:  bash compile.sh $BASE.tex --pages auto"
else
  echo "PAGES TO INSPECT: none - no visible overflow, no unresolved refs."
fi
echo "================================================="
exit 0
