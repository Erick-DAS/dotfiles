---
name: validate-references
description: "Verify every reference in an academic document (TCC, thesis, paper, report) and produce a consolidated markdown review. Use this skill whenever the user asks to 'verificar referências', 'validar bibliografia', 'checar citações', 'conferir referências', 'review references', or uploads a document (.docx, .md, .tex, .pdf) and asks whether its citations are correct, whether they exist, whether the bibliographic format matches what the source actually is, or whether the text uses each reference coherently. Also trigger when the user asks to confirm conference/journal venue claims (especially 'is this really CVPR/NeurIPS/ICLR 2024-2026?'), to pull working URLs for a bibliography, or to get relevance/removal recommendations for each reference. Defaults to ABNT formatting and Portuguese output, but supports other styles on request."
---

# Reference Validation

This skill audits every reference in an academic document. For each one, it checks existence, bibliographic correctness (ABNT by default), whether and how it is cited in the body, whether the text's claims about it actually match the source, and produces a consolidated markdown report with working URLs and relevance notes.

## When to use

- User uploads a TCC/thesis/paper/chapter and asks to verify or review the references
- User asks whether a specific citation is "real" or correctly formatted
- User wants to confirm that a paper really was published at the conference/journal claimed (common issue for recent 2024-2026 papers where arXiv preprints get misattributed)
- User wants working URLs for every entry in a bibliography
- User wants to know which references could be expanded on, reworded, or removed

If the user is Brazilian or the document is in Portuguese, default to ABNT formatting and Portuguese output. Otherwise match the document's language and ask about the citation style.

## Workflow

1. **Extract the document content** — convert the source file to markdown so references and in-text citations are both searchable. See "Extraction" below.
2. **Identify the reference list and the in-text citations** — locate the bibliography section and map each entry to where it appears in the body.
3. **Gather parameters** — confirm citation style (default ABNT), language for the report (default Portuguese), and anything specific the user wants flagged (e.g., "conferência apenas", "não quero preprints").
4. **Verify each reference** — run through the per-reference checklist below, using `web_search` liberally. Budget multiple searches per reference; don't skip classics assuming they're fine.
5. **Compile the consolidated report** as a single markdown file in `/mnt/user-data/outputs/`.
6. **Deliver** via `present_files`, with a short cover message highlighting the top issues.

## Extraction

Documents arrive in different formats. Extract to markdown before verifying:

- **.docx** — use `pandoc` or mammoth. Example: `pandoc input.docx -t markdown -o /home/claude/extracted.md`. Keep the output in `/home/claude/` (scratch space), not in `/mnt/user-data/outputs/`.
- **.md / .tex** — read directly.
- **.pdf** — consult `/mnt/skills/public/pdf-reading/SKILL.md` first. For born-digital PDFs, `pdftotext -layout` works; for scanned PDFs, OCR may be needed.

After extraction, skim the text to find:
- The **reference list** (usually titled "Referências", "References", "Bibliography").
- The **in-text citations** (author-date like "Wei et al. (2024)" for ABNT, or numeric `[12]` for IEEE-style). Keep a mental map of which reference appears in which section.

## Per-Reference Verification Checklist

For every entry in the reference list, verify all six items below. Don't shortcut any of them — each catches a different class of error.

### 1. Existence

Does the paper/book/resource actually exist? Search for `"<exact title>" <first author>` and confirm you see it indexed on at least one reputable source (official conference/journal site, arXiv, Semantic Scholar, DOI resolver, publisher site, dblp, OpenReview, author homepage).

For classics (pre-2010, widely-cited books like CLRS, or foundational papers like Karp 1972), existence is rarely the issue — but still pull a URL to include in the report.

### 2. Bibliographic correctness

Check every field against the source:
- **Authors** — order, initials, no missing names. For ≥6 authors, the TCC may legitimately use "et al." or "...; et al." under ABNT.
- **Title** — exact match, including subtitle after the colon.
- **Venue** — conference or journal name. **This is the single most common error for 2024-2026 papers.** People cite "CVPR 2026" or "NeurIPS 2025" when only an arXiv preprint exists. See "Common Pitfalls" below.
- **Year** — publication year (not submission year). For online resources that evolve (lecture notes, living docs), note the ambiguity.
- **Pages / volume / issue** — check when the source format requires them (journals, LNCS chapters, edited volumes).
- **Edition** (for books) — the user may have cited an older edition than they own. Flag but don't force a change.
- **DOI / ISBN** — include when available.

### 3. Usage in text

Where in the document is this reference cited? List the section(s) and quote the sentence(s) that introduce it. If a reference is in the list but never cited in the body, flag it — the user may want to remove it.

### 4. Coherence between text and source

This is the highest-value check and the most commonly skipped one. Read what the TCC says *about* the reference and compare to the source:

- **Numeric claims** — "57 tasks", "400M image-text pairs", "52%/57% accuracy", "61.8% gap". Verify each number against the paper. A wrong number is embarrassing even if the reference is otherwise perfect.
- **Method descriptions** — does the TCC describe the method the paper actually proposes? (e.g., claiming CLIP uses cross-attention when it's actually contrastive.)
- **Attribution of ideas** — is the credited author the actual originator? It's common to attribute a concept to a survey rather than its origin.
- **Version drift** — arXiv preprints evolve. A claim that was true in v1 may be wrong in the published version (e.g., MMMU says "32 image types" in the first preprint but "30" in the CVPR version). Flag these.

### 5. Working URL

Provide at least one working URL, preferably to the authoritative version (in order of preference):
1. Official conference/journal publisher page (ACL Anthology, NeurIPS proceedings, openaccess.thecvf.com, IEEE Xplore, Springer Link, ACM Digital Library, PMLR)
2. OpenReview page (for ICLR/NeurIPS/ICML)
3. DOI resolver link
4. arXiv (as a secondary/fallback link)
5. Author's institutional page (for lecture notes, living docs)

**Verify URLs resolve.** If in doubt, use `web_fetch` on the URL to make sure it isn't a dead link.

### 6. Relevance / insight

For each reference, briefly note:
- **What it adds to the work** — foundational (e.g., Transformer paper), contextual (related work), methodological (a technique the TCC uses), comparative (a baseline).
- **Opportunities to expand** — a specific dataset, method, or number from the paper that could strengthen the TCC's argument if cited explicitly.
- **Candidates for removal** — references that are cited once, don't add much, or are redundant with a stronger reference already present. Frame as a suggestion, never a demand.

## Common Pitfalls (check these every time)

These come up again and again. Check them deliberately for every reference:

**arXiv preprint masquerading as a conference paper.** For any 2024-2026 paper cited as CVPR/NeurIPS/ICLR/ECCV/ICML/ACL, verify acceptance by finding the paper on the official proceedings site. The arXiv paper's claim on its own first page is *not* evidence of acceptance — authors sometimes tag a paper "CVPR 2026" on arXiv before the acceptance list is out, and sometimes the paper isn't accepted. If you can't find it on the official proceedings site, flag it and recommend citing as `arXiv preprint arXiv:XXXX.XXXXX`.

**Wrong conference year.** NeurIPS 2022 papers are about Transformers-era work; a 2024-2026 multimodal paper claiming to be at NeurIPS 2022 should be treated with suspicion.

**Book editions.** CLRS 3rd (2009) vs 4th (2022), Sedgewick 3rd vs 4th, Russell & Norvig editions. All are fine choices, but the citation should match the edition the user actually uses.

**Online resources without access date.** ABNT NBR 6023 requires access date for online materials. Recommend adding `Disponível em: <URL>. Acesso em: DD mmm. AAAA.` for lecture notes, living docs, preprint URLs used as primary source, etc.

**Numeric drift between preprint and published version.** Common numbers that change: benchmark sizes, task counts, accuracy percentages, image type counts. Verify against the *published* version, not just the preprint, and flag discrepancies.

**Author lists in the wrong order.** Some venues reorder authors (e.g., alphabetical in math, contribution-based elsewhere). ABNT expects the order from the title page of the publication.

**"et al." when the TCC should list more authors.** ABNT allows "et al." after the first author in the body, but the reference list typically expects all authors up to a limit (varies by the institution's ABNT interpretation — USP/Poli typically lists up to 3 and uses "et al." for more). Flag if unsure.

**Misattributed concepts.** Chain-of-thought is Wei et al. 2022, not Brown et al. 2020. RLHF in LLMs is Ouyang et al. 2022 (InstructGPT), not InstructGPT's parent GPT-3 paper. Double-check when the TCC credits a concept.

## Search Strategy

To verify a reference efficiently:

1. **First search**: `"<exact title>" <first author>` — confirms existence.
2. **If venue is questionable**: `"<first author>" "<shortened title>" <claimed venue> <year>` — e.g., `"Wei" "DynamicGTR" CVPR 2026`. If the first page of results is mostly arXiv, the paper probably isn't in the official proceedings.
3. **If numeric claim is in the TCC**: `"<title>" "<specific number>"` — e.g., `"MMLU" "57 tasks"` — catches version drift.
4. **For books**: include publisher and edition — e.g., `"Cormen" "Introduction to Algorithms" 3rd edition MIT Press`.
5. **For Brazilian/USP lecture notes**: include "IME-USP" or the author's institution.

Budget 1-3 searches per reference for most entries, and 4-6 for recent (2024-2026) or contentious ones. Don't skimp on the ones the user's work leans heavily on.

## Report Structure

Produce a single markdown file at `/mnt/user-data/outputs/revisao_referencias_<short-id>.md` (or `reference_review_<id>.md` if English). Use this exact structure:

```markdown
# Revisão das Referências — <Short Work Title>

**Trabalho:** <Full title>
**Autor:** <Author name> (<Student ID if present>)
**Total de referências avaliadas:** <N>

---

## Resumo Executivo

<2-4 sentence summary of overall health of the bibliography>

| Problema | Referência | Gravidade |
|---|---|---|
| <Issue description> | <Reference short name> | **Alta** / Média / Baixa |
| ... | ... | ... |

Recomendação imediata: <one line on what to fix first>.

---

## 1. <FIRST AUTHOR SURNAME> et al. (YEAR) — <Short title>

- **Existência:** sim/não/parcial.
- **Citação correta (ABNT):** sim/não/parcial. <If not, what's wrong>
- **Uso no texto:** § <section>. "<short quoted passage or paraphrase>"
- **Coerência:** total / parcial / problemática. <Short justification with numbers verified>
- **Link:** <primary URL> | <secondary URL if relevant>
- **Insight potencial:** <what could be expanded OR "ok as is" OR "candidate for removal because..."> (optional)

## 2. <Next reference>
...
```

Every reference gets its own numbered section. Keep each entry **under 10 lines** — the report should be scannable, not exhaustive. End with an "Ações recomendadas" section prioritizing fixes by severity.

**Important style notes for the report:**
- Mirror Andrew's concise, point-by-point academic style. No filler, no restating what's obvious from the TCC.
- Use check marks sparingly (✓) for numeric claims that matched.
- Use ⚠️ only for genuine problems, not for minor formatting preferences.
- When flagging a problem, propose a concrete fix ("Proposto: arXiv preprint arXiv:XXXX.XXXXX").
- When there's nothing wrong with a reference, keep it to 3-4 lines.

## Parameters to Gather (if not obvious from context)

- **Citation style** — default ABNT. Ask if the document uses IEEE, APA, Chicago, or other.
- **Language for the report** — default Portuguese. Match the document's language if clearly something else.
- **Scope** — default all references. User may want only a subset ("só as de 2024 em diante").
- **Depth** — default full six-item check per reference. User may ask for a quick pass ("só me diga se todas existem").
- **Special flags** — e.g., "quero só referências de conferência" means flag all preprints for discussion, "inglês" means switch the report language.

Collect missing parameters in one consolidated question if possible.

## Example (abbreviated)

**User uploads a TCC and says:** "Pode verificar todas as referências e me dizer se estão certas? Tem alguma coisa que preocupa?"

**Claude should:**
1. Extract the .docx to markdown in `/home/claude/`.
2. Identify the reference list (e.g., 27 entries) and locate each in-text citation.
3. For each reference, run the six-item checklist — existence, ABNT format, usage in text, coherence (especially numbers), working URL, insight. Use `web_search` 1-6 times per reference depending on confidence.
4. Compile the report at `/mnt/user-data/outputs/revisao_referencias_<id>.md` with executive summary table + one section per reference + recommended actions.
5. Call `present_files` with a brief cover message: "Verifiquei 27 referências. 1 problema alto (<ref>), 2 menores. Relatório completo anexo."

## Iteration

After the first report, the user may ask follow-ups like:
- "Pode checar só a XYZ de novo?" — redo the verification for that one entry and update only that section.
- "Adiciona a data de acesso em todas as URLs online" — regenerate with ABNT NBR 6023 compliance notes added.
- "Faz também uma sugestão de ordem das referências" — append a section with alphabetical ordering per ABNT.

For these, update the existing report in-place rather than producing a new one, unless the user asks for a clean version.
