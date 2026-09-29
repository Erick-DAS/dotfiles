# Zotero recipes

Exact tool-call patterns for the Zotero MCP during reference validation.
Read this before your first `zotero_search_items` or `zotero_semantic_search` call - the search-query section in particular, since getting it wrong looks like "the reference isn't in the library" when it is. Also read it before writing to the library.

You don't need it for a single `zotero_search_by_citation_key` lookup: that call is exact, returns a clean binary answer, and hits none of the traps below.

## Contents

- [Finding a reference](#finding-a-reference) - read this first; a miss can look like a hit
- [Reading an item](#reading-an-item)
- [Scoping to a collection](#scoping-to-a-collection)
- [Adding a missing reference](#adding-a-missing-reference)
- [Fixing a wrong record](#fixing-a-wrong-record)
- [When Zotero is unreachable](#when-zotero-is-unreachable)

---

## Finding a reference

### The one thing that trips everyone up

`zotero_search_items` is **substring matching over title/creators/year** - not a search engine. Every extra word is an additional AND constraint, so a longer query returns *fewer* results, not better ones. This is backwards from web search instinct, and it's why a paper that is sitting in the library comes back "not found".

```
✗ zotero_search_items(query='Chain-of-Thought Prompting Elicits Reasoning in Large Language Models Wei 2022')
✓ zotero_search_items(query='Wei 2022')
✓ zotero_search_items(query='Chain-of-Thought')
```

Start with `Surname Year`, or a single distinctive title word. Only add a second term if the first returns too many hits.

### A miss can look exactly like a hit

`zotero_search_items` **silently falls back to semantic search** when the substring match finds nothing. It then returns a block of plausible-looking papers - correct topic, right field, wrong paper - preceded by a caveat paragraph. Skimmed quickly, that reads as success.

The tell is in the output:

> *Note: Original search for 'Reimers' returned no results. The following 5 item(s) are semantically related papers found via AI-powered search...*

**If you see "Original search for X returned no results", that is a miss.** The items below it are suggestions, not the reference. Never verify a document's citation against one of them without confirming title and authors match.

This also changes how much evidence a single call carries: one `zotero_search_items` already exercised *two* strategies (substring, then semantic), so a clean miss there is worth more than it looks.

### Beware false positives

Substring matching on a short surname is genuinely dangerous: `query='Bai 2025'` matches an item authored by **Baich** - a real result, no caveat note, nothing to signal it's wrong. For surnames under ~6 characters, prefer a distinctive title word. Always confirm the title matches the document's entry before treating a hit as the same work; a near-miss silently becoming the record you verify against is worse than finding nothing.

### Cascade within Zotero

Try these in order; stop at a confident match.

1. **Citation key** - `zotero_search_by_citation_key(citation_key='vaswani2017attention')`.
   **Go here first whenever the document is a `.tex`/`.bib` pair.** It's the only lookup that returns an unambiguous binary answer: no substring noise, no semantic fallback, no false positives. `No item found with citation key: 'Bai:2025'` means exactly what it says. (Requires the user to keep Better BibTeX keys, which is the norm for LaTeX projects.)
2. **One distinctive title word** - `zotero_search_items(query='TabMeta')`.
   Pick a word unlikely to appear elsewhere. "Attention" matches dozens of items; "TabMeta" matches one.
3. **Author + year** - `zotero_search_items(query='Vaswani 2017')`. Watch for the short-surname trap above.
4. **Abstract too** - `zotero_search_items(query='Vaswani', qmode='everything')` when the title in the document was paraphrased or translated.
5. **Semantic search**, when you know the topic but not the exact title - `zotero_semantic_search(query='chain-of-thought prompting for arithmetic reasoning', limit=5)`.
   Requires the embedding database to be populated. If it errors, check `zotero_get_search_database_status`; suggest `zotero_update_search_database` to the user rather than running it unprompted, since indexing a whole library is slow.
6. **Structured fields**, for edge cases like date ranges or type filters - `zotero_advanced_search(conditions=[{'field': 'itemType', 'operation': 'is', 'value': 'preprint'}], join_mode='all')`.

Two or three failed lookups across different strategies is reasonable evidence the reference isn't in the library. One failed lookup is not - especially if it was a long query.

### The domain probe: don't re-derive the same negative 30 times

Before working through a bibliography reference by reference, ask whether the library covers the document's field at all:

```
zotero_semantic_search(query='<the document’s core topic>', limit=8)
```

Read the relevance scores. **All-negative scores mean nothing in the library is close** - the tool returns its best matches regardless, so the scores, not the presence of results, carry the signal. A library of tabular-data papers probed for "multimodal LLM image resolution" returns eight items at -0.25 to -0.35: that's a clean "this domain isn't here".

When the probe comes back empty like that, report it once - *"nenhuma das N referências está no Zotero; a biblioteca cobre outro domínio"* - and skip the per-reference Zotero lookups entirely. The per-reference rule above is calibrated for deciding about *one* reference; this is the library-level override, and it turns 30 searches into one.

## Reading an item

```
zotero_get_item_metadata(item_key='RUSGYXXJ')                    # readable summary
zotero_get_item_metadata(item_key='RUSGYXXJ', format='bibtex')   # field-by-field diff against the document's .bib entry
```

`format='bibtex'` is the right call when the document is a LaTeX project - you can compare the two entries directly instead of eyeballing prose.

For coherence checks against an attached PDF:

```
zotero_get_item_children(item_key='RUSGYXXJ')     # find the PDF attachment
zotero_get_item_fulltext(item_key='RUSGYXXJ')     # full text - 10K+ tokens, so only when a claim needs it
zotero_get_attachment_path(item_key='...')        # or read the file directly with pdftotext
```

Full text is expensive. Reach for it to settle a specific numeric or method claim, not to browse.

## Scoping to a collection

When the user says the references live in a particular collection, scope the search - it removes false positives and is much faster:

```
zotero_search_collections(query='tabular')            # name → 8-char key
zotero_search_items(query='Chen 2023', collection_key='DS3TMF3I')
zotero_get_collection_items(collection_key='DS3TMF3I', detail='summary', limit=100)
```

For a bibliography of 20-40 references against a scoped collection, pulling the collection once with `zotero_get_collection_items` and matching locally is cheaper than 40 individual searches. Note that `collection_key` on `zotero_search_items` bypasses the automatic fallback cascade, so a miss there is a miss - re-check library-wide before concluding the item is absent.

`zotero_get_collections` lists the whole tree with keys; use it to offer the user real options in the opening question.

## Adding a missing reference

`zotero_add_item` handles DOI, URL, ISBN, BibTeX, CSL JSON, and local files. Source quality varies a lot:

| Source | Route | Quality |
|---|---|---|
| DOI | CrossRef | Best - use whenever you have one |
| arXiv URL / doi.org URL | Full metadata | Good |
| Other URL | Bare `webpage` item | Poor, often not citable - resolve to a DOI first |
| BibTeX / CSL JSON | One item per entry, citation key kept in Extra | Good - ideal when the document already has a `.bib` |
| ISBN | Open Library, then Google Books | Noisy - verify after adding |
| Local PDF (absolute path) | Extracts the PDF's DOI → CrossRef, else guesses from filename/text, then attaches the file | Good when the PDF carries a DOI |

### The standard call

```
zotero_add_item(
    source='10.48550/arXiv.2201.11903',
    collections=['DS3TMF3I'],       # the collection agreed in the opening question
    if_exists='file',               # idempotent: reuse a matching item, add collections/tags, never remove
)
```

**Always pass `if_exists='file'`.** The default is `'duplicate'`, which creates a second copy every time - and this skill gets re-run on the same document. `'file'` makes re-runs safe.

### Choosing the source

- Have a DOI → use it. Prefer it over everything else.
- arXiv-only preprint → `10.48550/arXiv.XXXX.XXXXX` resolves through CrossRef.
- Verified from a local PDF with no DOI → pass the **absolute path**; the file gets attached, which also makes future coherence checks cheap.
- The document is a LaTeX project with a `.bib` → pass the BibTeX entry text directly. It preserves the citation key in Extra, keeping `\cite{}` keys aligned with the library.
- Book → ISBN works, but verify the result; Open Library metadata is frequently incomplete.

### Collections

`collections` accepts keys, names, or `/`-separated paths. An unknown or ambiguous name **fails the call** rather than leaving an unfiled item - which is the safe behavior, so don't work around it by dropping the argument. Pass `create_missing_collections=True` only if the user asked for a new collection.

### After a batch of additions

Mention (don't silently run) `zotero_update_search_database` so the new items become semantically searchable. It's slow, and it's the user's call.

If duplicates are suspected after a large batch: `zotero_find_duplicates(method='doi', limit=20)` is the safe method for automated review; `zotero_merge_duplicates` needs an explicit keeper and should only run with the user's approval.

## Fixing a wrong record

When Zotero's metadata is the thing that's wrong - a preprint filed as `conferencePaper`, a missing DOI, a wrong year - offer the fix rather than only reporting it:

```
zotero_update_item(item_key='RUSGYXXJ', fields={'item_type': 'preprint', 'doi': '10.48550/arXiv.2503.12345'})
```

Field-name traps:
- `tags` **replaces** the entire tag list. Use `add_tags` / `remove_tags` for incremental changes.
- `collections` / `collection_names` likewise **replace** membership. For incremental moves use `zotero_set_item_collections(item_keys=['KEY'], add_to=['DS3TMF3I'])` - note `item_keys` must be an array.
- `item_type` migrates the item: overlapping fields survive, type-specific ones are dropped. Say so before running it, since data is lost.

Never batch-update records without showing the user what changes.

## When Zotero is unreachable

Two distinct failure modes, both seen in practice:

- **`Connection refused`** - Zotero desktop isn't running (or is still starting up). Metadata search may work while collection listing fails, since some reads hit the SQLite file directly and others need the local HTTP API on port 23119. Retrying once after a moment is worth it; asking the user to open Zotero is the real fix.
- **Write failures** - report the error verbatim rather than assuming a cause.

Either way, degrade gracefully: say once that Zotero is unavailable, continue the review through local files and the web, and offer to file the additions in a later pass. A broken library connection shouldn't cost the user the reference review.
