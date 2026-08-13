#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Compile an academic LaTeX paper, render page images, and report layout problems.

.DESCRIPTION
  Windows PowerShell port of compile.sh. Does the same four things:
    1. Picks an engine (auto: xelatex if fontspec/xeCJK/polyglossia is used, else pdflatex).
    2. Runs latexmk, which handles multi-pass compilation AND bibtex automatically.
    3. Renders every page to a PNG in <basename>_preview\ so you can LOOK at the layout.
    4. Prints a layout report: overfull/underfull boxes (with overflow in pt),
       undefined references, and undefined citations.

  Requires a TeX distribution (MiKTeX or TeX Live) that puts latexmk + pdflatex on
  PATH. Page previews need Poppler's pdftoppm on PATH; if it is absent, previews are
  skipped (everything else still works). Exit code is non-zero if compilation fails.

.PARAMETER TexFile
  Path to the .tex file to compile.
.PARAMETER Dpi
  Resolution for the PNG page previews (default 150).
.PARAMETER NoPreview
  Skip rendering page images.
.PARAMETER Engine
  Force an engine: pdflatex | xelatex | lualatex. Auto-detected if omitted.

.EXAMPLE
  pwsh scripts/compile.ps1 paper.tex
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File scripts\compile.ps1 paper.tex -Dpi 200 -NoPreview
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$TexFile,
    [int]$Dpi = 150,
    [switch]$NoPreview,
    [ValidateSet('pdflatex', 'xelatex', 'lualatex')]
    [string]$Engine
)

# ---- args / preflight ----------------------------------------------------
if (-not (Test-Path -LiteralPath $TexFile)) {
    Write-Host "ERROR: pass a .tex file. Usage: compile.ps1 paper.tex [-Dpi N] [-NoPreview]"
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
    # whenever a .bib is cited, so no manual multi-pass juggling is needed.
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

    $pages = '?'
    if (Get-Command pdfinfo -ErrorAction SilentlyContinue) {
        $line = & pdfinfo $pdf 2>$null | Select-String '^Pages:'
        if ($line) { $pages = (($line.Line) -split '\s+')[1] }
    }
    Write-Host "[OK] Built $base.pdf ($pages pages)"

    # ---- render page images for visual inspection -----------------------
    if (-not $NoPreview) {
        if (Get-Command pdftoppm -ErrorAction SilentlyContinue) {
            $outdir = "${base}_preview"
            if (Test-Path -LiteralPath $outdir) { Remove-Item -LiteralPath $outdir -Recurse -Force }
            New-Item -ItemType Directory -Path $outdir | Out-Null
            $prefix = Join-Path $outdir 'page'
            & pdftoppm -png -r $Dpi $pdf $prefix 2>$null
            Write-Host "[OK] Rendered pages to $outdir\  -- VIEW THESE to confirm the layout looks right."
        } else {
            Write-Host "[warn] pdftoppm not found (install Poppler); skipping image preview."
        }
    }

    # ---- layout report --------------------------------------------------
    Write-Host ""
    Write-Host "================= LAYOUT REPORT ================="

    # Overfull boxes = content spilling past the margin (the #1 thing to fix in a
    # paper: a wide table, a long equation, or an unbreakable URL). We pull the
    # overflow magnitude and flag anything a reader would notice (>5pt).
    $boxes = @()
    foreach ($mi in (Select-String -LiteralPath $log -Pattern 'Overfull \\([hv])box \(([0-9.]+)pt[^)]*\)(.*)' -AllMatches)) {
        foreach ($m in $mi.Matches) {
            $boxes += [pscustomobject]@{
                Type  = $m.Groups[1].Value
                Pt    = [double]$m.Groups[2].Value   # PS casts use invariant culture (dot decimal)
                PtStr = $m.Groups[2].Value
                Ctx   = $m.Groups[3].Value.Trim()
            }
        }
    }
    if ($boxes.Count -gt 0) {
        Write-Host ""
        Write-Host "OVERFULL BOXES (content past the margin):"
        foreach ($b in ($boxes | Sort-Object Pt -Descending)) {
            $sev = if ($b.Pt -gt 5) { ' [VISIBLE]' } else { ' [minor]' }
            Write-Host ("  - {0}pt {1}box -- {2}{3}" -f $b.PtStr, $b.Type, $b.Ctx, $sev)
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

    # Undefined references / citations -- easy to miss, embarrassing in a paper.
    $undefRef = @(Select-String -LiteralPath $log -Pattern "Reference ``[^']+' on page \d+ undefined" |
                  ForEach-Object { $_.Matches.Value } | Sort-Object -Unique)
    $undefCit = @(Select-String -LiteralPath $log -Pattern "Citation ``[^']+' on page \d+ undefined" |
                  ForEach-Object { $_.Matches.Value } | Sort-Object -Unique)
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

    Write-Host "================================================="
    exit 0
}
finally {
    Pop-Location
}
