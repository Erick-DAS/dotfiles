#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Compile an academic LaTeX paper, render page images, and report layout problems.

.DESCRIPTION
  Windows PowerShell port of compile.sh. Does the same four things:
    1. Picks an engine (auto: xelatex if fontspec/xeCJK/polyglossia is used, else pdflatex).
    2. Runs latexmk, which handles multi-pass compilation AND bibtex automatically.
    3. Renders page images to <basename>_preview\ so you can LOOK at the layout.
    4. Prints a layout report that says WHICH PAGE each problem is on, so you can
       re-render and re-inspect only the pages that actually need a second look.

  -Pages controls which pages get rendered. This is the main cost lever: reading
  page images is by far the most expensive part of the write-compile-look loop,
  and it scales with the length of the paper rather than with what changed.

    -Pages all    every page (default; right for the first build and the final check)
    -Pages auto   ONLY the pages the layout report flagged. Renders nothing when the
                  report is clean - which is the common case mid-loop, and the whole
                  point: a clean report means there is nothing to look at.
    -Pages 3,7    an explicit list
    -Pages 2-5    a range (lists and ranges may be combined: 2-5,9)

  -NoPreview skips rendering entirely. Use it for edits that cannot change layout
  (fixing prose, a citation key, a typo): the log still catches undefined refs and
  overfull boxes, so you get the safety check without the image cost.

  Requires a TeX distribution (MiKTeX or TeX Live) that puts latexmk + pdflatex on
  PATH. Page previews need Poppler's pdftoppm on PATH; if it is absent, previews are
  skipped (everything else still works). Exit code is non-zero if compilation fails.

.PARAMETER TexFile
  Path to the .tex file to compile.
.PARAMETER Pages
  Which pages to render: all (default) | auto | an explicit spec like 2-5,9.
.PARAMETER Dpi
  Resolution for the PNG page previews (default 110 - enough to see a table cross
  the margin; 150 costs ~2x the pixels for detail that changes no layout decision).
.PARAMETER NoPreview
  Skip rendering page images.
.PARAMETER Engine
  Force an engine: pdflatex | xelatex | lualatex. Auto-detected if omitted.

.EXAMPLE
  pwsh scripts/compile.ps1 paper.tex
.EXAMPLE
  pwsh scripts/compile.ps1 paper.tex -Pages auto
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File scripts\compile.ps1 paper.tex -NoPreview
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$TexFile,
    [string]$Pages = 'all',
    [int]$Dpi = 110,
    [switch]$NoPreview,
    [ValidateSet('pdflatex', 'xelatex', 'lualatex')]
    [string]$Engine
)

# ---- args / preflight ----------------------------------------------------
if (-not (Test-Path -LiteralPath $TexFile)) {
    Write-Host "ERROR: pass a .tex file. Usage: compile.ps1 paper.tex [-Pages SPEC] [-Dpi N] [-NoPreview]"
    exit 2
}
if (-not (Get-Command latexmk -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: 'latexmk' not found on PATH. Install MiKTeX or TeX Live first."
    exit 2
}

$texItem = Get-Item -LiteralPath $TexFile
$dir  = $texItem.DirectoryName
$base = [System.IO.Path]::GetFileNameWithoutExtension($texItem.Name)

# ---- engine auto-detection ----------------------------------------------
if (-not $Engine) {
    $content = Get-Content -LiteralPath $texItem.FullName -Raw
    if ($content -match '(?m)^[^%\r\n]*\\usepackage(\[[^\]]*\])?\{(fontspec|xeCJK|polyglossia)\}') {
        $Engine = 'xelatex'
    } else {
        $Engine = 'pdflatex'
    }
}
switch ($Engine) {
    'pdflatex' { $lmkFlag = '-pdf' }
    'xelatex'  { $lmkFlag = '-xelatex' }
    'lualatex' { $lmkFlag = '-lualatex' }
}

Write-Host "==> Compiling $base.tex with $Engine (via latexmk)"

Push-Location $dir
try {
    $log = "$base.log"
    $pdf = "$base.pdf"

    # -interaction=nonstopmode: never block on an error prompt.
    # latexmk reruns the engine until cross-references settle and runs bibtex
    # whenever a .bib is cited, so no manual multi-pass juggling is needed. It
    # also skips work when nothing changed, so small-edit rebuilds are cheap.
    & latexmk $lmkFlag -interaction=nonstopmode -halt-on-error -file-line-error `
              -synctex=0 "$base.tex" 2>&1 | Out-Null
    $status = $LASTEXITCODE

    # ---- compile failure: surface the real errors -----------------------
    if ($status -ne 0 -or -not (Test-Path -LiteralPath $pdf)) {
        Write-Host ""
        Write-Host "[FAILED] COMPILATION FAILED. First errors from ${log}:"
        Write-Host "------------------------------------------------------------"
        if (Test-Path -LiteralPath $log) {
            Select-String -LiteralPath $log -Pattern '^(.*:[0-9]+:|! )' |
                Select-Object -First 15 | ForEach-Object { $_.Line }
        }
        Write-Host "------------------------------------------------------------"
        Write-Host "Tips: 'Undefined control sequence' = unknown command or missing \usepackage."
        Write-Host "      'Missing `$ inserted'        = math symbol used outside `$...`$."
        Write-Host "      'File X.sty not found'       = missing package."
        exit 1
    }

    $pageCount = '?'
    if (Get-Command pdfinfo -ErrorAction SilentlyContinue) {
        $line = & pdfinfo $pdf 2>$null | Select-String '^Pages:'
        if ($line) { $pageCount = (($line.Line) -split '\s+')[1] }
    }
    Write-Host "[OK] Built $base.pdf ($pageCount pages)"

    # ---- attribute overfull boxes to page numbers -----------------------
    # TeX writes a shipout marker "[N" to the log as each page is finished, and
    # emits a box warning while building the page it belongs to. So a warning
    # seen after the marker for page N is on page N+1. Knowing the page is what
    # makes targeted re-rendering possible - without it the only safe move is to
    # look at every page on every iteration, which is the expensive habit this
    # avoids. Matching over the raw log keeps markers and warnings in order.
    $raw = Get-Content -LiteralPath $log -Raw -ErrorAction SilentlyContinue
    $boxes = @()
    if ($raw) {
        $page = 1
        $combined = '\[\d+|Overfull \\([hv])box \(([0-9.]+)pt[^)]*\)([^\r\n]*)'
        foreach ($m in [regex]::Matches($raw, $combined)) {
            if ($m.Value -match '^\[(\d+)') {
                $page = [int]$Matches[1] + 1
            } else {
                $at = ''
                if ($m.Groups[3].Value -match 'at lines? (\d+(?:--\d+)?)') { $at = $Matches[1] }
                $boxes += [pscustomobject]@{
                    Page  = $page
                    Type  = $m.Groups[1].Value
                    Pt    = [double]$m.Groups[2].Value   # PS casts use invariant culture (dot decimal)
                    PtStr = $m.Groups[2].Value
                    At    = $at
                }
            }
        }
    }

    # Pages worth a second look: anything overflowing enough to be visible (>5pt),
    # plus any page showing a ?? / [?] marker.
    $undefRef = @(Select-String -LiteralPath $log -Pattern "Reference ``[^']+' on page \d+ undefined" |
                  ForEach-Object { $_.Matches.Value } | Sort-Object -Unique)
    $undefCit = @(Select-String -LiteralPath $log -Pattern "Citation ``[^']+' on page \d+ undefined" |
                  ForEach-Object { $_.Matches.Value } | Sort-Object -Unique)

    $flagged = @()
    $flagged += ($boxes | Where-Object { $_.Pt -gt 5 } | ForEach-Object { $_.Page })
    foreach ($u in ($undefRef + $undefCit)) {
        if ($u -match 'on page (\d+)') { $flagged += [int]$Matches[1] }
    }
    $flagged = @($flagged | Sort-Object -Unique)
    $flaggedStr = ($flagged -join ',')

    # ---- render page images for visual inspection -----------------------
    function Expand-PageSpec([string]$spec) {
        $out = @()
        foreach ($part in ($spec -split ',')) {
            $p = $part.Trim()
            if ($p -match '^(\d+)-(\d+)$') {
                [int]$Matches[1]..[int]$Matches[2] | ForEach-Object { $out += $_ }
            } elseif ($p -match '^\d+$') {
                $out += [int]$p
            }
        }
        return @($out | Sort-Object -Unique)
    }

    $outdir = "${base}_preview"
    if ($NoPreview) {
        Write-Host "[.] Preview skipped (-NoPreview). The layout report below still applies."
    } elseif (-not (Get-Command pdftoppm -ErrorAction SilentlyContinue)) {
        Write-Host "[warn] pdftoppm not found (install Poppler); skipping image preview."
    } else {
        $spec = $Pages
        if ($Pages -eq 'auto') { $spec = $flaggedStr }

        if ($Pages -eq 'auto' -and [string]::IsNullOrWhiteSpace($flaggedStr)) {
            if (Test-Path -LiteralPath $outdir) { Remove-Item -LiteralPath $outdir -Recurse -Force }
            Write-Host "[.] -Pages auto: report is clean, so no pages rendered. Nothing to inspect."
        } else {
            # Only ever leave freshly-rendered images behind. A stale PNG from an
            # earlier build that silently disagrees with the current PDF is worse
            # than no image at all.
            if (Test-Path -LiteralPath $outdir) { Remove-Item -LiteralPath $outdir -Recurse -Force }
            New-Item -ItemType Directory -Path $outdir | Out-Null
            $prefix = Join-Path $outdir 'page'
            if ($spec -eq 'all') {
                & pdftoppm -png -r $Dpi $pdf $prefix 2>$null
                $n = @(Get-ChildItem -LiteralPath $outdir).Count
                Write-Host "[OK] Rendered all $n page(s) to $outdir\ at ${Dpi}dpi - VIEW THESE to confirm the layout."
            } else {
                # pdftoppm names output by real page number, so filenames stay
                # aligned with the PDF either way.
                foreach ($p in (Expand-PageSpec $spec)) {
                    & pdftoppm -png -r $Dpi -f $p -l $p $pdf $prefix 2>$null
                }
                Write-Host "[OK] Rendered page(s) $spec to $outdir\ at ${Dpi}dpi - only these need a look."
            }
        }
    }

    # ---- layout report --------------------------------------------------
    Write-Host ""
    Write-Host "================= LAYOUT REPORT ================="

    if ($boxes.Count -gt 0) {
        Write-Host ""
        Write-Host "OVERFULL BOXES (content past the margin):"
        foreach ($b in ($boxes | Sort-Object Pt -Descending)) {
            $sev = if ($b.Pt -gt 5) { '[VISIBLE]' } else { '[minor]  ' }
            $at  = if ($b.At) { "  (lines $($b.At))" } else { '' }
            Write-Host ("  - p.{0,-3} {1,8}pt {2}box  {3}{4}" -f $b.Page, $b.PtStr, $b.Type, $sev, $at)
        }
        Write-Host "  -> Fix VISIBLE ones: shrink/resize wide tables & images (width=\linewidth),"
        Write-Host "     wrap long URLs (\url{}), or break long display equations."
    } else {
        Write-Host "  [OK] No overfull boxes."
    }

    $underfull = (Select-String -LiteralPath $log -Pattern 'Underfull \\([hv])box').Count
    if ($underfull -gt 0) {
        Write-Host "  - $underfull underfull box(es) (loose spacing -- usually cosmetic)."
    }

    if ($undefRef.Count -gt 0 -or $undefCit.Count -gt 0) {
        Write-Host ""
        Write-Host "UNDEFINED CROSS-REFERENCES / CITATIONS:"
        $undefRef | ForEach-Object { Write-Host "  - \ref -> $_" }
        $undefCit | ForEach-Object { Write-Host "  - \cite -> $_" }
        Write-Host "  -> A '??' or '[?]' is showing in the PDF. Check the \label / .bib key."
    } else {
        Write-Host "  [OK] All \ref and \cite resolved."
    }

    if (Select-String -LiteralPath $log -Pattern 'Missing character' -Quiet) {
        Write-Host "  - Missing characters detected -- a glyph isn't in the current font."
    }

    # The one line to act on: which pages actually need eyes. Everything else in
    # the report is diagnosis; this is the instruction.
    Write-Host ""
    if ($flagged.Count -gt 0) {
        Write-Host "PAGES TO INSPECT: $flaggedStr"
        Write-Host "  -> Re-render just these after fixing:  pwsh compile.ps1 $base.tex -Pages auto"
    } else {
        Write-Host "PAGES TO INSPECT: none - no visible overflow, no unresolved refs."
    }
    Write-Host "================================================="
    exit 0
}
finally {
    Pop-Location
}
