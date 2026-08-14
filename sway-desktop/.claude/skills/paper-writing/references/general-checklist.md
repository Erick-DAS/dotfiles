# General Checklist (pre-submission polish)

This is the polish phase. A well-polished paper makes the reviewer's job hard: they have to hunt for serious flaws instead of rejecting on surface problems. Run these checks before any internal review and again before submission.

Work through the list top to bottom. For each item, report concrete, line-level findings, not vague advice.

## Content integrity

### Every claim needs a reference or a demonstration

Every statement must be followed by a reference, except the ones the paper itself demonstrates. Example: "Parameter count is also not well correlated with latency." Who confirms this, the literature or an experiment in this paper? An unsupported, undemonstrated claim is a gap, and a reviewer can use it to reject the work. For each unreferenced claim, decide: cite a source, point to the experiment that shows it, or cut it.

### Cut unnecessary sentences

Assume the reader has a limited budget of attention. If they start skipping sentences because some are unnecessary, they may skip the ones that matter. "Perfection is reached not when there is nothing left to add, but when there is nothing left to remove" (Saint-Exupery). Delete any sentence that can go without loss.

## Style and grammar

### Eliminate passive voice

Rewrite passive constructions into active ones, and state claims, contributions, and what tables and figures show in the present tense:

- "experiments were conducted" -> "We conduct experiments"
- "can be solved in O(N) complexity" -> "an algorithm solves it in O(N) complexity"
- "values are presented in Table 2" -> "Table 2 presents the values"
- "results are shown in Figure 1" -> "Figure 1 shows the results"

Use present tense for what the paper, method, table, or figure does. Past tense is fine only when narrating a procedure you actually ran ("we trained 339 networks", "we ran five seeds"). Strong venues (ICLR, ICML, NeurIPS) contain almost no passive voice, so any passive construction stands out.

The word **"can"** typically precedes passive voice. To sweep a finished draft, open the PDF or source, Ctrl+F for "can", and rewrite each passive hit. A few constructions genuinely cannot drop the passive, but the examples above must be converted before the draft moves on.

### No excess of that / which / this / these, and no repeated words nearby

- Never two of *that / which / this / these* in the same sentence. Two in one sentence is a signal the sentence is too long: break it in two.
- Strongly avoid them in adjacent sentences.
- More generally, do not repeat any content word close to itself; repeated words give the impression of a limited vocabulary. If "provide" appears in one clause, switch the next instance to "leads to" or "promotes" (for example, "our analysis provides ..." -> "our analysis leads to ..."). Swapping the word can also let you shade the meaning slightly.

### Smooth the flow between sentences

Take sentences i-1, i, i+1 and check that the ideas transition smoothly. Good flow is one of the hardest cognitive tasks in writing, and a model is least reliable here, so check it by hand. Often a few small linking words fix a rough flow: adding *However, these ... may ... also ...* can turn choppy text into smooth text without changing the content.

A diagnostic (not foolproof): cast the three sentences as bullet points. If they read *too* well as bullets, the flow may be poor, because bullets jump abruptly between ideas and good prose should not. This is the one checklist item where an LLM is not a reliable substitute; do it yourself.

### Check grammar densely

- Focus on writing and improving small sentences first, then aggregate them with the i-1, i, i+1 rule and recheck the flow.
- The checklist items interact: fixing one can break another. After improving a sentence in isolation, re-check its flow with the neighbors; after any edit, re-run the affected checks.

### Using an LLM to refine

**Confidentiality.** You may use an LLM to polish your own review wording, but you must never show a paper you are **reviewing** to an LLM. ICLR, NeurIPS, and CVPR treat showing a submission to an LLM as a confidentiality violation that can ban a reviewer for up to two years. Polishing your own paper is fine; pasting someone else's submission is not.

## Figures

- **Always use vector figures (.pdf), never raster (png, jpg).** A vector figure stays sharp at any zoom; a raster one pixelates into blocks. Tools like matplotlib export vector directly, and the quality difference is large. A good figure size is one column wide: `\includegraphics[width=\columnwidth]` works well in a two-column layout; in a single-column layout, set a `scale` and test values that look right.
- **Every figure must be cited and discussed in the text.** A figure exists to clarify a point being made; if it is never referenced, either discuss it or remove it. The same applies to tables and equations: everything gets referenced.
- **Keep figure elements in the paper's language.** If the text is in Portuguese, the axes and caption must not be in English, and vice versa. Matching them shows care.
- **Never put equations or tables as images** (png, jpg, screenshots). Build them in the native environment: equations and tables in LaTeX (use https://www.tablesgenerator.com/ and always `\renewcommand{\arraystretch}{1.2}` for readable row spacing); in slides, build tables and equations in the presentation tool itself rather than pasting a screenshot, which pixelates.

## Code

- Avoid code in general; do not assume the reader knows a given language (Python, C/C++, ...).
- Exception: a short snippet that demonstrates the simplicity of the strategy (for example, a method expressible in a few lines).

## References

- **Do not cite arXiv when the paper is published** in a peer-reviewed venue; cite the venue.
- **Standardize references** (https://dblp.uni-trier.de helps). For conference papers keep only the tags *author, title, year, booktitle/journal*. Write the venue as the full name followed by the acronym in parentheses, for example "International Conference on Learning Representations (ICLR)". For a thesis or other non-paper submission, also keep DOI, volume, and pages.
- **Standardize incrementally.** Format each reference the moment you add it. If every new entry is standardized on the way in, the whole bibliography stays consistent at no extra cost, and consistency itself signals care.
- Inconsistency is a tell: if two entries are the same conference but one has an editor, volume, and publisher and the other does not, or one is abbreviated and the other is not, or one notes "virtual-only", or one is missing the year (a "timeless" entry), a reviewer notices. Make every entry uniform.
- For a full reference audit (existence, correct venue, ABNT or other format, working URLs, in-text usage), use the `validate-references` skill.

### Standardizing a reference, step by step

1. Take the paper title and search it on dblp (https://dblp.uni-trier.de).
2. Pick the **venue** entry, never the arXiv one. If the paper is very recent (for example 2024) and dblp does not yet list the venue, find it on OpenReview, still not arXiv.
3. Export the BibTeX and paste it into your `.bib`.
4. Delete every tag except *author, title, year, booktitle/journal* (drop publisher, editor, volume, pages, url, ... for a conference paper). If the entry already carries the year inside `booktitle`, remove the duplicate so you do not end up with two years.
5. Rewrite the venue as full name plus acronym in parentheses, for example `International Conference on Machine Learning (ICML)`.
6. Create a citation key, usually `Author:Year` (for example `He:2016`). Watch for collisions: if several `2016` entries share an author surname, disambiguate (add the venue or a suffix). Before committing the key, Ctrl+F for it in the `.bib` to make sure it is not already used; a duplicate key is a serious problem.

Example of a clean conference entry (only the four standard tags):

```bibtex
@inproceedings{He:2016,
  author    = {Kaiming He and Xiangyu Zhang and Shaoqing Ren and Jian Sun},
  title     = {Deep Residual Learning for Image Recognition},
  booktitle = {Conference on Computer Vision and Pattern Recognition (CVPR)},
  year      = {2016}
}
```

Never use a different standard, unless the user the user explicitly tell you to. If the template being used presents a different standard, ask the user which one to use.

## Submission hygiene

- Before sending to arXiv or camera-ready, make sure **all acknowledgments are inserted**. This is mandatory when the work is tied to funding agencies (FAPESP, CNPq, ...). When in doubt, ask the advisor whether an acknowledgment must be added; a missing one causes real headaches.
- Some venues do not allow free distribution of the paper. Mind the copyright terms; when in doubt, do not post it on arXiv or a homepage.

## Process

- Confirm all earlier checklists were applied before circulating the draft. Reviewing a bad paper only improves it slightly, and internal review among coauthors is costly, so circulate the best possible version.
- A well-polished paper makes the reviewer's job hard: they must find a *serious* flaw to justify rejection. Grammar errors, ugly figures, and rough flow are easy reasons to reject, so removing them forces a substantive review.

## What rejection looks like (real reviewer comments, OpenReview ICLR 2024)

These are the surface problems this checklist prevents:

- "lacks descriptions and justifications of the baselines and how tuned the baseline methods are."
- "The paper is not very well written. E.g. the authors write 'was wildly interpreted', they probably mean widely."
- "Figure 1 is not referenced in the text."
- "some notation seems not to be defined, such as p_theta, mu_z."
- "inaccurate claims ... which were not justified and references were not provided."
- "Could you explain how one should read Figure 1? What is the x-axis? What is the y-axis?"
- "the term 'grokking tickets' is used 12 times before its formal definition is presented."
- "Excessive space is devoted to some trivial aspects, such as formulas for weight initialization."
- "Figures are of low resolution."

Every one of these maps to a checklist item above. Clearing the checklist removes the easy reasons to reject.

## Further reading on writing

Books:

- *On Writing Well*, William Zinsser. The first half is the strong part.
- *The Elements of Style*, Strunk and White. Good for grammar, avoiding passive voice, and comma usage.

Papers worth studying as writing templates (chosen for the quality of their prose):

- *Deep Residual Learning for Image Recognition* (CVPR, 2016), best paper, written before the LLM era by authors who sell the work well.
- *Can Neural Network Memorization Be Localized?* (ICML, 2023).
- *Understanding Plasticity in Neural Networks* (ICML, 2023).
- *Towards a Statistical Theory of Data Selection Under Weak Supervision* (ICLR, 2024, oral), read up to Section 2; it becomes mathematically dense afterward.
