# LaTeX patterns for academic papers

Copy-paste snippets for the common building blocks, plus the fixes for when
something doesn't fit. Keep `width=\linewidth` (or a fraction) as the default
for anything that might be too wide.

---

## Figures

### External image (most common)
```latex
\begin{figure}[ht]
  \centering
  \includegraphics[width=0.8\linewidth]{plots/accuracy.pdf}
  \caption{Always describe what the reader should take away.}
  \label{fig:acc}
\end{figure}
```
- `[ht]` = put it here or at the top of a page. Use `[t]` for top-only, `[!ht]`
  to fight aggressive floating. Never leave the placement off.
- Prefer vector formats (`.pdf`, `.eps`) over `.png`/`.jpg` for plots/diagrams.
- `width=\linewidth` makes the image exactly the text width; never hard-code `cm`
  for something that must fit the column.

### Side-by-side subfigures
```latex
\usepackage{subcaption}
...
\begin{figure}[ht]
  \centering
  \begin{subfigure}{0.48\linewidth}
    \includegraphics[width=\linewidth]{a.pdf}\caption{}\label{fig:a}
  \end{subfigure}\hfill
  \begin{subfigure}{0.48\linewidth}
    \includegraphics[width=\linewidth]{b.pdf}\caption{}\label{fig:b}
  \end{subfigure}
  \caption{Shared caption.}\label{fig:both}
\end{figure}
```
Two figures at `0.48\linewidth` + `\hfill` fit a row. Three? Use `0.32\linewidth`.

### Vector figure drawn in LaTeX (no image file)
Great for simple plots and diagrams — scales perfectly, fonts match the paper.
```latex
\usepackage{pgfplots}\pgfplotsset{compat=1.18}
...
\begin{tikzpicture}
  \begin{axis}[width=0.8\linewidth,height=5cm,xlabel={x},ylabel={y},grid=major]
    \addplot coordinates {(1,2)(2,4)(3,8)(4,16)};
  \end{axis}
\end{tikzpicture}
```

---

## Tables

### Clean table (booktabs — the academic standard)
```latex
\usepackage{booktabs}
...
\begin{table}[ht]
  \centering
  \caption{Caption goes ABOVE the table in papers.}
  \label{tab:main}
  \begin{tabular}{l r r}
    \toprule
    Method & Acc. (\%) & Time (s) \\
    \midrule
    Baseline & 88.0 & 1.24 \\
    Ours     & 93.2 & 0.87 \\
    \bottomrule
  \end{tabular}
\end{table}
```
Rules: only `\toprule`/`\midrule`/`\bottomrule`. **Never** `\hline` or vertical
bars (`|`) — they look dated and crowd the columns.

### Align numbers on the decimal point (siunitx)
```latex
\usepackage{siunitx}
\begin{tabular}{l S[table-format=2.2] S[table-format=1.3]}
  \toprule
  Method & {Acc.} & {Time} \\   % brace text headers in S columns
  \midrule
  Ours & 93.20 & 0.870 \\
  \bottomrule
\end{tabular}
```

### When a table is too wide (overfull box) — pick ONE
```latex
% 1. Shrink the font for this table only
{\small \begin{tabular}{...}...\end{tabular}}     % or \footnotesize

% 2. Auto-fit by scaling (last resort; can make text tiny)
\resizebox{\linewidth}{!}{\begin{tabular}{...}...\end{tabular}}

% 3. Let a column wrap text to a fixed width
\begin{tabular}{l p{6cm} r}  % the p{} column wraps instead of overflowing

% 4. Rotate a very wide table to landscape
\usepackage{rotating}
\begin{sidewaystable} ... \end{sidewaystable}
```

---

## Math

```latex
\usepackage{amsmath,amssymb,mathtools}

Inline: $E = mc^2$.

\begin{equation}            % numbered + referenceable
  a^2 + b^2 = c^2. \label{eq:pyth}
\end{equation}

\begin{align}               % multi-line, aligned at &
  f(x) &= (x+1)^2 \\
       &= x^2 + 2x + 1.
\end{align}

\begin{equation*} ... \end{equation*}   % unnumbered
```
A display equation too wide for the line is an overfull box — break it with
`\\` inside `align`, or use `\resizebox` only as a last resort.

---

## Citations & bibliography (natbib + bibtex)

`references.bib`:
```bibtex
@inproceedings{vaswani2017,
  title={Attention is all you need},
  author={Vaswani, Ashish and others},
  booktitle={NeurIPS}, year={2017}
}
```
In the document:
```latex
\usepackage[numbers,sort&compress]{natbib}  % numeric [1,2,5]
...
\citet{vaswani2017}   % "Vaswani et al. [1]"  (subject of sentence)
\citep{vaswani2017}   % "[1]"                 (parenthetical)
...
\bibliographystyle{plainnat}   % or IEEEtran, unsrtnat, abbrvnat
\bibliography{references}
```
The compile script runs bibtex automatically (via latexmk). If `[?]` appears,
the cite key doesn't match a `.bib` entry.

To get author–year style ("Vaswani et al., 2017") instead of numbers, drop the
`[numbers]` option: `\usepackage{natbib}`.

---

## Cross-references (cleveref)

```latex
\usepackage{hyperref}   % load BEFORE cleveref
\usepackage{cleveref}   % load AFTER hyperref
...
\cref{fig:acc}    % -> "Fig. 1"
\cref{tab:main}   % -> "Tab. 1"
\cref{eq:pyth}    % -> "Eq. (1)"
\Cref{sec:intro}  % -> "Section 1" (capitalised, e.g. at sentence start)
```
Let cleveref supply the word + number. Don't write "Figure~\ref{...}" by hand.

---

## Algorithms

```latex
\usepackage{algorithm}
\usepackage{algpseudocode}
...
\begin{algorithm}[ht]
  \caption{Name}\label{alg:x}
  \begin{algorithmic}[1]
    \State \textbf{Input:} ...
    \For{$i = 1$ to $n$}
      \State ...
    \EndFor
    \State \textbf{return} ...
  \end{algorithmic}
\end{algorithm}
```

---

## Troubleshooting (common compile errors)

| Message | Cause / fix |
|---|---|
| `Undefined control sequence \xyz` | Unknown command — typo, or missing `\usepackage`. |
| `Missing $ inserted` | A math symbol (`_`, `^`, `\alpha`) used outside `$...$`. |
| `Missing \begin{document}` | A stray character before `\documentclass`, or a broken preamble. |
| `File 'foo.sty' not found` | Missing package: `tlmgr install foo` (or `sudo` it). |
| `Too many }'s` / runaway argument | Unbalanced `{ }` — count braces around the cited line. |
| `! LaTeX Error: \begin{...} ended by \end{...}` | Mismatched environment names. |
| Citation/Reference `[?]` or `??` in PDF | Undefined `\cite`/`\ref`; the compile script lists these. |
| `Package pgfplots Warning: running in backwards compatibility mode` | Add `\pgfplotsset{compat=1.18}`. |

### Gotchas worth remembering
- **Captions:** above tables, below figures (academic convention).
- **Floats drift:** `[ht]` is a *request*, not a command. Figures may land on the
  next page — that's normal. Don't fight it with `[H]` (`float` package) unless
  position genuinely matters; forced placement causes huge whitespace gaps.
- **TikZ width math leaks:** never write `\textwidth-1cm` raw inside a node — it
  can literally print "-1cm". Use `text width=0.9\textwidth` in the node style.
- **Underfull boxes** are usually cosmetic (loose spacing); fix overfull first.
- **hyperref loads near-last**, `cleveref` strictly after it.
