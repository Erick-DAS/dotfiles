---
name: validate-references
description: "Verify references in an academic document (TCC, thesis, paper, report) against Zotero, local files, and the web, report what is right or wrong in the chat, and file any missing reference into Zotero. Works at either scale: a quick check of one specific citation the user names ('essa citação tá certa?', 'o CARES é mesmo ACL 2026?', 'esse paper existe?'), or a full audit of an entire bibliography. Use this skill whenever the user asks to 'verificar referências', 'validar bibliografia', 'checar citações', 'conferir referências', 'review references', or points at a document (.docx, .md, .tex, .pdf, .bib) and asks whether its citations are correct, whether they exist, whether the bibliographic format matches what the source actually is, or whether the text uses each reference coherently. Also trigger when the user asks to confirm conference/journal venue claims (especially 'is this really CVPR/NeurIPS/ICLR 2024-2026?'), to pull working URLs for a bibliography, to check which references are already in Zotero or to add the missing ones, or to get relevance/removal recommendations. Follows the document's own citation style (a LaTeX project's .bst, ABNT for Brazilian institutional documents) and answers in the user's language."
---

# Reference Validation

This skill checks references in an academic document: whether they exist, whether the bibliographic fields are right, whether and how they're cited in the body, and whether the text's claims about them actually match the source. Findings are reported **in the chat**.

It works at two scales - a single citation the user asks about, or a full bibliography audit. Pick the right one before doing anything else; see "Two modes" below.

The user manages references in Zotero, so verification and the library go together: whatever gets verified here should end up in Zotero, correctly filed.

## When to use

- User points at a TCC/thesis/paper/chapter and asks to verify or review the references
- User asks whether a specific citation is "real" or correctly formatted
- User wants to confirm a paper really was published at the conference/journal claimed (common issue for recent 2024-2026 papers where arXiv preprints get misattributed)
- User wants working URLs for every entry in a bibliography
- User wants to know which references are missing from Zotero, or which could be expanded on, reworded, or removed

**Report language and citation style are two different questions - don't let one decide the other.** The report language follows the user: if they wrote to you in Portuguese, answer in Portuguese. The citation style follows the *document*: a LaTeX project's `.bst` file (`icml2024.bst`, `IEEEtran.bst`, `abntex2-alf.bst`) is the ground truth, and a `.bib` + `.bst` pair means the style is whatever that `.bst` renders, not ABNT. ABNT is the right default only for a Brazilian institutional document (TCC, dissertação, tese) that isn't built from a `.bst`. A Portuguese-speaking user writing an English ICML paper is a normal case, and judging that paper by ABNT rules produces noise.

## Two modes: one reference, or the whole bibliography

**Match the work to what was asked.** Most of this skill describes a full bibliography audit, which carries real setup cost - extracting the document, mapping every in-text citation, the opening question, the domain probe, the batch proposal. That cost amortizes over thirty references and is pure overhead for one.

Use the **fast path** when the user names a specific reference or a small handful: "essa citação do Wei tá certa?", "o CARES é mesmo ACL 2026?", "verifica se esse paper existe", or they paste a single `.bib` entry. Then:

1. **Run the cascade on that reference only** - Zotero, local files, web. Skip the opening question and the domain probe; a single `zotero_search_items` or `zotero_search_by_citation_key` call answers the filing question directly.
2. **Check what's actually in question, not all six items.** "Is this real?" needs existence and a URL. "Is this really CVPR 2026?" needs the proceedings check. "Does the paper say 57 tasks?" needs the source's full text. Running the whole checklist on a reference the user asked one question about is the same waste in miniature.
3. **Answer inline, conversationally.** No executive summary, no report scaffolding, no severity table - just what's right, what's wrong, and the concrete fix.
4. **If it's missing from Zotero, say so in one line and offer to add it** - a single confirmation, not the batch machinery.

**The fast path explicitly overrides these full-audit moves.** They earn their cost across a whole bibliography and are traps for a single question - don't run them unless the user's question actually turns on them:

- hunting for a second, richer bibliography in the project
- counting `\bibitem` in the `.bbl` to find orphaned entries
- grepping the `.tex` for where the reference is cited (checklist item 3)
- the relevance / expand / remove commentary (checklist item 6)

**Incidental errors in the same entry: report, don't hunt.** If you're checking a venue claim and the author list is visibly wrong on the page you already fetched, say so in one line - withholding a known error in the exact entry the user is looking at would be perverse. But don't go looking for extra problems the question didn't raise. The rule is *free findings get reported, paid findings need a reason*.

Scale up only when the answer warrants it. If checking one reference turns up something that implies a broader problem - a `.bib` that lost its DOIs, a stale dossier, a venue error likely repeated across the recent entries - say so and offer the full pass. Don't silently start one.

Everything below describes the full audit. Read the parts the current request needs.

## Workflow (full audit)

1. **Extract the document content** so references and in-text citations are both searchable. See "Extraction".
2. **Identify the reference list and the in-text citations** - locate the bibliography and map each entry to where it appears in the body.
3. **Ask the opening question** (one consolidated message) - see "Opening question".
4. **Resolve each reference through the search cascade** - Zotero, then local files, then the web. See "Search cascade".
5. **Verify each reference** against the six-item checklist.
6. **Report in the chat** using the structure in "Reporting". On claude.ai, also write the report to `/mnt/user-data/outputs/` and deliver it with `present_files`.
7. **Propose the Zotero additions** as one batch at the end and add them once the user approves. See "Filing into Zotero".

## Extraction

Extract to markdown before verifying:

- **.docx** - use `pandoc` or mammoth. Example: `pandoc input.docx -t markdown -o /home/claude/extracted.md`. Keep the output in scratch space (`/home/claude/` on claude.ai), not in `/mnt/user-data/outputs/` and not in the user's project.
- **.md / .tex / .bib** - read directly. For LaTeX projects the `.bib` file is the reference list and `\cite{key}` calls are the in-text citations; map by citation key.
- **.pdf** - consult `/mnt/skills/public/pdf-reading/SKILL.md` first when it exists. For born-digital PDFs, `pdftotext -layout` works; for scanned PDFs, OCR may be needed.

After extraction, find the **reference list** ("Referências", "References", "Bibliography") and the **in-text citations** (author-date like "Wei et al. (2024)" for ABNT, numeric `[12]` for IEEE-style, `\cite{}` for LaTeX). Keep a map of which reference appears in which section.

## Opening question

Before the cascade, ask once - in a single message - anything that changes how the whole run behaves. Ask only what you can't infer:

- **Where to search.** The cascade below is the default. The user may want it narrowed ("só o Zotero", "não precisa procurar na internet") or pointed somewhere specific ("as referências estão todas na coleção Tabular Data", "os PDFs estão em ~/poli/tcc/pdfs"). A named Zotero collection is worth asking about because it turns a fuzzy library-wide search into an exact one.
- **Which Zotero collection** new items should go into.
- **Citation style** and **report language**, if the document doesn't settle them (see above).

**Run the domain probe before you ask the collection question.** One `zotero_semantic_search` on the document's core topic tells you whether the library covers this field at all, and `zotero_get_collections` then lets you offer real, *relevant* options. Asking first and probing later wastes the question: if the library turns out not to cover the document's domain, none of the existing collections are the right answer and you'll have to come back to the user anyway. Reuse the answer for every addition in the run.

Don't ask about anything you can determine yourself, and don't ask again mid-run - a verification pass over 30 references should interrupt the user once, not thirty times.

## Search cascade

For each reference, search in this order and stop as soon as you have a confident identification:

1. **Zotero** - the user's own library. A hit is authoritative about *filing* (the reference is already in the library) and gives you clean metadata plus, often, an attached PDF.
2. **Local files** - the project directory: `.bib` and `.tex` files, and PDF folders next to the document (`pdfs/`, `papers/`, `references_pdfs/`, or whatever the project uses). A PDF on disk is the strongest possible evidence, since you can read the actual paper.
3. **The web** - `web_search` / `web_fetch`, and the PubMed / Consensus MCPs when the field fits.

### Do the Zotero pass in one sweep, not per reference

Zotero comes first, but "first" is about precedence, not about spending the most calls there. Running a separate lookup for each of 30 references is the expensive way to learn one fact - which references are already filed.

Instead, resolve Zotero presence as a **single batched pass** up front:

- If the user named a collection, pull it once with `zotero_get_collection_items(detail='summary', limit=100)` and match locally against the bibliography.
- If the document is a `.tex`/`.bib` project, sweep the citation keys with `zotero_search_by_citation_key` - unambiguous, no substring noise.
- Otherwise, run the domain probe (`zotero_semantic_search` on the document's core topic). **If it returns nothing relevant, the library doesn't cover this field.** Report that once and stop searching Zotero per reference - continuing to query for each entry just re-derives the same negative at 30x the cost.

Then spend the real effort where the errors actually live: local PDFs (cheapest, richest) and the web (where venue and coherence problems surface).

### The cascade decides where you look, not what you trust

Finding a reference somewhere means you found a record quickly; it does not mean the record is right. **Every tier can be the wrong one:**

- **Zotero** carries whatever metadata its import brought in. Bulk Scopus/database exports are especially noisy, and an item can name the wrong venue as easily as the document can. If the user added the item from their own draft, Zotero will happily confirm their mistake.
- **A local `.bib` or notes file** is a snapshot of when someone wrote it. Curated dossiers go stale in a specific, predictable way: a paper marked `[PREPRINT]` may have been accepted since, and its numbers may have changed between preprint and camera-ready. Treat any local annotation older than the venue's acceptance list as presumptively stale, and re-check the arXiv comments field rather than trusting the note.
- **The document** may simply be wrong, which is why you're here.

So for any 2024-2026 paper cited as a conference publication, confirm the venue on the official proceedings site even when Zotero *and* a local file agree with the document. Two sources repeating each other is not verification when one was copied from the other.

When sources disagree, work out which one is wrong instead of assuming it's the document - on a recent paper the freshly-fetched web result usually beats both the library and the local note. If Zotero is the wrong one, offer to fix it with `zotero_update_item`; a bad record will otherwise keep producing bad citations in future work.

`references/zotero-recipes.md` has the exact tool-call patterns, including the search-query gotcha that wastes the most time (Zotero's text search is substring matching, so extra words *narrow* the result set instead of widening it). Read it before your first `zotero_search_items` or `zotero_semantic_search` call - that's where the traps are. A single `zotero_search_by_citation_key` lookup needs no preparation: it's exact by construction, and reading a file about substring pitfalls to make a call that can't hit them is pure overhead. Read it before writing to the library too.

### Local file search

The project directory is where a paper's own reference PDFs live, and it's the highest value per call of any tier:

```bash
# .bib entries and \cite keys
grep -ril "<first author surname>" <project>/*.bib <project>/**/*.tex
# PDFs by filename
find <project> -iname "*<author>*.pdf" -o -iname "*<title keyword>*.pdf"
# PDFs by content, when the filename is opaque (2409.12345v2.pdf)
pdftotext -l 1 <file>.pdf - | head -40
```

Opaque filenames are common, so when a directory of PDFs is in scope and filename matching fails, read the first page of the candidates rather than concluding the paper isn't there.

**Get the cited set from the `.bbl`, not by eye.** For a LaTeX project, the compiled `.bbl` contains exactly the entries that were actually cited:

```bash
grep -c '^@' <project>/main.bib          # entries in the bibliography
grep -c '\\bibitem' <project>/main.bbl   # entries actually cited
grep -o '\\bibitem[^ ]*{[^}]*}' <project>/main.bbl   # which ones
```

A gap between the two counts is your orphan list, obtained in one command instead of thirty greps.

**Look for a second, richer bibliography.** Projects often carry a reference dossier next to the PDFs - another `.bib`, or a `.md` with per-paper notes - that is more complete than the one the document builds from (DOIs, page ranges, publisher, claim summaries). Diff the two. This is frequently the single most valuable artifact in the project: it tells you what the compiled `.bib` lost, and where two parallel bibliographies with different citation keys have started to drift apart. Just remember it's a snapshot and may be stale on recent papers.

## Per-Reference Verification Checklist

For every entry in the reference list, verify all six items. Each catches a different class of error.

### 1. Existence

Does the source actually exist? A Zotero hit or a local PDF settles this. Otherwise search `"<exact title>" <first author>` and confirm it's indexed on a reputable source (official conference/journal site, arXiv, Semantic Scholar, DOI resolver, publisher site, dblp, OpenReview, author homepage).

**Fast path for classics.** For pre-2010 foundational work (CLRS, Karp 1972, Lloyd 1982), existence, venue and coherence are all settled history - running the full six-item checklist on them is ceremony that produces no findings. Confirm the bibliographic fields, pull the DOI/URL, check whether it's actually cited, and move on. Spend the saved effort on the 2024-2026 entries, where every real error lives.

### 2. Bibliographic correctness

Check every field against the source:
- **Authors** - order, initials, no missing names. For ≥6 authors, ABNT may legitimately use "et al."
- **Title** - exact match, including subtitle after the colon.
- **Venue** - conference or journal name. **The single most common error for 2024-2026 papers.** See "Common Pitfalls".
- **Year** - publication year, not submission year. For evolving online resources, note the ambiguity.
- **Pages / volume / issue** - when the source format requires them (journals, LNCS chapters, edited volumes).
- **Edition** (books) - the user may have cited a different edition than they own. Flag, don't force.
- **DOI / ISBN** - include when available.

When the reference is in Zotero, `zotero_get_item_metadata(item_key, format='bibtex')` gives a clean field-by-field comparison against the document's entry.

### 3. Usage in text

Where is this reference cited? List the section(s) and quote the sentence(s) that introduce it.

**Uncited entries are a content finding, not a formatting one - and the fix usually isn't deletion.** An entry sitting in the bibliography with no `\cite` means the author *meant* to engage with that work. Before recommending removal, read the paper and ask whether the text has a gap where it belongs: a foundational precedent missing from Related Work is a far more serious problem than a stray `.bib` entry, and the entry is the evidence that the author already knows it matters. Recommend removal only when the work genuinely adds nothing the document doesn't already cover.

Check the inverse too: **claims in the text that should carry a citation and don't.** A named method ("we cluster the embeddings with k-means"), a benchmark, or a borrowed number with no `\cite` is the same defect seen from the other side - and often the orphan entry is sitting in the `.bib` waiting to be used.

### 4. Coherence between text and source

The highest-value check and the most commonly skipped one. Compare what the document says *about* the reference to what the source actually says:

- **Numeric claims** - "57 tasks", "400M image-text pairs", "52%/57% accuracy". Verify each number. A wrong number is embarrassing even when the reference is otherwise perfect.
- **Method descriptions** - does the document describe the method the paper actually proposes? (e.g. claiming CLIP uses cross-attention when it's contrastive.)
- **Attribution of ideas** - is the credited author the actual originator? Concepts often get attributed to a survey rather than their origin.
- **Version drift** - arXiv preprints evolve; a claim true in v1 may be wrong in the published version (MMMU says "32 image types" in the first preprint, "30" in the CVPR version). Flag these.

A local PDF or a Zotero attachment makes this check far stronger than web snippets do. When the PDF is available, use it: `zotero_get_item_fulltext` for Zotero attachments, `pdftotext` for local files. It's the difference between checking a number and guessing at it.

**Know when to stop.** The most common coherence failure isn't a number that contradicts the source - it's a number that *isn't in the source at all*, often because the author measured it themselves from the released dataset and wrote it as if the paper said it. No amount of searching proves an absence, so once you've read the paper's full text and its abstract and the claim isn't there, stop and report exactly that: "a fonte não afirma isso". That's a finding, not a failed search. Then propose the honest fix - usually attributing the number to the author's own measurement rather than to the cited work.

### 5. Working URL

Provide at least one working URL, preferring the authoritative version:
1. Official conference/journal publisher page (ACL Anthology, NeurIPS proceedings, openaccess.thecvf.com, IEEE Xplore, Springer Link, ACM DL, PMLR)
2. OpenReview page (ICLR/NeurIPS/ICML)
3. DOI resolver link
4. arXiv (secondary/fallback)
5. Author's institutional page (lecture notes, living docs)

Verify URLs resolve - `web_fetch` anything you're unsure about.

**For the current conference cycle, the proceedings site may not exist yet.** `papers.nips.cc` and `openaccess.thecvf.com` lag acceptance by months, so for a paper accepted this year the authoritative acceptance record is the virtual site (`neurips.cc/virtual/<year>/poster/<id>`, `icml.cc/virtual/...`) or the OpenReview forum page. Treat those as proceedings-grade evidence, not as arXiv-grade. Absence from `papers.nips.cc` alone is not evidence a recent paper was rejected.

### 6. Relevance / insight

Briefly note:
- **What it adds** - foundational, contextual, methodological, comparative.
- **Opportunities to expand** - a specific dataset, method, or number that would strengthen the argument if cited explicitly.
- **Candidates for removal** - cited once, adds little, or redundant with a stronger reference already present. A suggestion, never a demand.

## Common Pitfalls (check these every time)

**arXiv preprint masquerading as a conference paper.** For any 2024-2026 paper cited as CVPR/NeurIPS/ICLR/ECCV/ICML/ACL, verify acceptance on the official proceedings site. The arXiv page's own claim is not evidence - authors tag papers "CVPR 2026" before acceptance lists are out, and sometimes the paper isn't accepted. A Zotero record saying `conferencePaper` is not evidence either. If it isn't in the official proceedings, recommend citing it as `arXiv preprint arXiv:XXXX.XXXXX`.

**Wrong conference year.** A 2024-2026 multimodal paper claiming NeurIPS 2022 deserves suspicion.

**Book editions.** CLRS 3rd (2009) vs 4th (2022), Sedgewick, Russell & Norvig. All fine choices; the citation should match the edition the user actually uses.

**Blog posts and model release announcements.** Increasingly cited (Qwen, Llama, GPT release posts) and rarely checked. The title gets paraphrased from memory, and the post names a *family* while the experiments used one specific variant. Verify the exact post title, and flag when the document cites a model family without naming the variant and size it actually ran - the whole result depends on it.

**Online resources without access date.** ABNT NBR 6023 requires it: `Disponível em: <URL>. Acesso em: DD mmm. AAAA.` *(ABNT documents only - skip for `.bst`-built papers.)*

**Numeric drift between preprint and published version.** Benchmark sizes, task counts, accuracy percentages. Verify against the *published* version and flag discrepancies.

**Author lists in the wrong order.** ABNT expects the order from the publication's title page.

**"et al." when the reference list should name more authors.** ABNT allows "et al." in the body; the reference list typically expects all authors up to a limit (USP/Poli typically lists up to 3). *ABNT documents only* - in a `.bib`, author truncation is the `.bst`'s job and a full author list is correct.

**Two bibliographies drifting apart.** A project with both `main.bib` and a curated `references.bib` under different citation keys (`Kimhi:2026` vs `kimhi2025cares`) will diverge, and the one the document builds from is usually the poorer of the two. Flag the duplication itself, not just the missing fields.

**Misattributed concepts.** Chain-of-thought is Wei et al. 2022, not Brown et al. 2020. RLHF in LLMs is Ouyang et al. 2022 (InstructGPT), not the GPT-3 paper.

**A Zotero record inheriting the document's error.** If the user added the item from their own draft, Zotero will happily confirm a mistake. Treat matching-but-unverified venue claims as unverified.

## Search Strategy

1. **Zotero first**: `zotero_search_items(query='<Surname> <Year>')` - short queries only. See `references/zotero-recipes.md`.
2. **Local**: grep the `.bib`, then the PDF folders.
3. **Web, first search**: `"<exact title>" <first author>` - confirms existence.
4. **Web, venue check**: `"<first author>" "<short title>" <claimed venue> <year>`. If the first page is mostly arXiv, the paper probably isn't in the official proceedings.
5. **Numeric claims**: `"<title>" "<specific number>"` - catches version drift.
6. **Books**: include publisher and edition.
7. **Brazilian/USP lecture notes**: include "IME-USP" or the author's institution.

Budget 1-3 searches per reference for most entries, 4-6 for recent (2024-2026) or contentious ones. Don't skimp on the ones the work leans on hardest.

## Filing into Zotero

Any reference verified from local files or the web but absent from Zotero is a gap worth closing - that's the whole point of keeping the library.

Collect these as you go, then present them **as one batch at the end** with what you'd add and where, and add them only after the user approves. Batching matters: the user gets to see the full picture and reject individual entries before anything is written, instead of being interrupted per reference.

```
Encontrei 4 referências que não estão no Zotero:

1. Wei et al. (2022), "Chain-of-Thought Prompting..." - DOI 10.48550/arXiv.2201.11903 → coleção "Tabular Data"
2. ...

Adiciono todas? (ou diga quais pular)
```

Prefer a DOI as the source - it routes through CrossRef and gives by far the cleanest metadata. Use `if_exists='file'` so re-running the skill never duplicates. The recipes file covers the source-type routing and the traps (a non-DOI URL produces a bare, often non-citable `webpage` item).

**When no existing collection fits.** The opening question settles the destination before the run, but the run is what reveals that a bibliography belongs to a domain the library doesn't cover yet. Don't force the items into the least-wrong existing collection, and don't quietly drop the argument to make the call succeed - unfiled items are how libraries rot. Say plainly that none of the existing collections fit, propose a name, and create it with `create_missing_collections=True` once the user agrees.

Report what actually happened - added, skipped, failed - rather than assuming success.

If Zotero is unreachable (the MCP fails or Zotero desktop is closed), don't let it block the review: say so once, continue through local files and the web, and offer to file the additions later.

## Reporting

Report **in the chat**. The user wants to read what's right and wrong directly in the conversation, so that is the deliverable everywhere.

**On claude.ai**, additionally write the full audit to a single markdown file at `/mnt/user-data/outputs/revisao_referencias_<short-id>.md` (or `reference_review_<id>.md` if English) and call `present_files` with a short cover message highlighting the top issues - e.g. *"Verifiquei 27 referências. 1 problema alto (<ref>), 2 menores. Relatório completo anexo."* That's how a long report gets delivered there. In Claude Code those paths and that tool don't exist, so the chat report is the whole deliverable and a file is written only if the user asks. Either way the chat gets the findings; the file is a claude.ai delivery mechanism, not a substitute.

The structure below is for a **full audit**. On the fast path, drop it entirely and just answer the question - a template wrapped around a single reference is noise, and it needs no file in any environment.

Lead with the problems. A reference with nothing wrong needs one line; a reference with a real error needs enough detail to fix it.

**Identify each reference the way the user does.** For a LaTeX project that means the citation key (`Kimhi:2026`) - it's what they'll type to find it, and a bibliography ordinal like `[3]` is meaningless in a `.bib`. Use the rendered number only when the document actually has stable numbering.

```markdown
## Revisão das Referências - <Short Title>

**<N> referências avaliadas** · <N> problemas altos · <N> médios · <N> ausentes do Zotero

### ⚠️ Problemas

**`Wei:2026`** - venue incorreta
Citado como CVPR 2026; só existe como preprint arXiv:2503.12345. Não consta nos proceedings oficiais.
→ Corrigir para: `arXiv preprint arXiv:2503.12345`
Zotero: item `RUSGYXXJ` também está como conferencePaper - corrijo?

**`Liu:2024`** - número divergente
O texto diz "57 tarefas"; o paper publicado diz 30. Divergência entre preprint v1 e versão final.

### ✓ Sem problemas

- **`Vaswani:2017`** - ok. NeurIPS 2017. https://papers.nips.cc/paper/7181
- **`Cormen:2009`** - ok, 3ª ed. MIT Press.
...

### Ausentes do Zotero

<the batch proposal - see "Filing into Zotero">

### Ações recomendadas

1. <highest-severity fix first>
```

When you couldn't check everything - a large bibliography, a bounded pass - say exactly where the full check stopped and which entries got only a shallow look. Silence there reads as "all verified", which is the one thing a reference review must never falsely imply.

Style notes:
- Concise and point-by-point. No filler, no restating what's obvious from the document.
- ⚠️ only for genuine problems, not minor formatting preferences.
- Always propose a concrete fix, not just a diagnosis.
- For a long bibliography, the clean entries can collapse into a compact list - the problems are what deserve space.
- Mention a reference's Zotero status only when it's actionable (missing, or the record is wrong).

## Iteration

Follow-ups the user may ask:
- "Pode checar só a XYZ de novo?" - redo that one entry.
- "Adiciona a data de acesso em todas as URLs online" - regenerate the affected entries with ABNT NBR 6023 notes.
- "Arruma o Zotero também" - apply the proposed `zotero_update_item` fixes.
- "Salva isso num arquivo" - only then write the report to disk, next to the document.
