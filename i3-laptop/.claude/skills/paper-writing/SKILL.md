---
name: paper-writing
description: "Draft, structure, review, and polish scientific papers for top ML/CV venues (ICLR, NeurIPS, ICML, CVPR, PAMI, ICCV), following Prof. Artur Jordão's writing guidelines. Use whenever the user writes or improves any part of an ML/DL/CV paper, thesis, or TCC: introduction, related work / state of the art, problem definition / preliminaries, experiments, teaser figure, abstract, or conclusion; or asks to 'review my paper', 'improve this section', 'polish my writing', 'check passive voice / flow / references', 'frame my contributions', or prepare a conference submission. Also trigger when the user pastes a paragraph and asks if it reads well, or how to structure an introduction, motivate a gap, present results, or write a self-contained teaser caption. Carries the move-by-move section structures and the full pre-submission checklist; consult it even for seemingly generic writing help, since the venue-specific conventions encoded here are not obvious."
---

# Scientific Paper Writing (Machine Learning bias)

A skill for writing and reviewing scientific papers aimed at the strongest ML/CV venues. It encodes the guidelines taught by **Prof. Artur Jordão** (Escola Politécnica, USP), built from worked examples extracted from papers published at ICLR, NeurIPS, ICML, PAMI, CVPR, and ICCV. The goal is to help produce text that a reviewer finds hard to reject: a paper whose introduction makes clear promises, whose experiments keep them, and whose prose is tight, well-referenced, and smooth.

The approach is deliberately example-driven. The point is not to list which sections a paper has and what goes in each; it is to internalize, from real published excerpts, the *moves* that strong writing makes, and then reproduce those moves. The chosen venues were picked because their writing is consistently impeccable, so the theoretical content of an example never matters here, only how the authors phrase and structure it. When applying a pattern, do not worry about understanding the underlying method; focus on the rhetoric.

## When to use

Use this whenever the task touches the *content, structure, rhetoric, or polish* of an academic paper in machine learning, deep learning, or computer vision, including:

- Drafting a section from scratch (introduction, related work, problem definition, experiments, teaser, abstract, conclusion).
- Reviewing or rewriting an existing draft against publication standards.
- Running the pre-submission checklist (passive voice, flow, claims-without-references, repeated words, figures, references).
- Framing contributions, motivating a gap, or structuring an argument.

This skill is about *what to write and how to write it*. It is not a document generator. If the deliverable must be a `.docx`, `.pdf`, or LaTeX file, first read the relevant public skill (`/mnt/skills/public/docx/SKILL.md`, `/mnt/skills/public/pdf/SKILL.md`) and then apply the writing guidance here to the content.

## Core philosophy

Internalize these six principles; everything else follows from them.

1. **Do not write the paper until you have the main results.** The narrative of the whole paper rests on what the experiments show. If you write the abstract, introduction, related work, and problem definition assuming your method beats the baselines, and the results then say otherwise, every section collapses and has to be redone. Get the experiments that confirm (or refute) your central claim first; only then write.
2. **The introduction makes promises; the experiments keep them.** Every research question or hypothesis raised (ideally in the introduction) must have at least one experiment that addresses it, and every experiment should trace back to a promise.
3. **Every claim needs a reference or a demonstration.** A statement with no citation and no supporting experiment is a gap a reviewer will use to reject the paper. Either cite the literature or show it yourself.
4. **Perfection is reached when there is nothing left to remove**, not when there is nothing left to add (Saint-Exupéry). The reader has limited attention. If they start skipping sentences because some are unnecessary, they may skip the ones that matter.
5. **Always mark the difference.** Mentioning related or concurrent work without stating how *your* work differs is pointless and invites the question "then why should this be accepted?"
6. **Polish is a weapon.** A clean paper forces the reviewer to hunt for serious flaws. Grammar errors, ugly figures, and rough flow are easy reasons to reject.

## Workflow

1. **Identify the task type.** Is the user (a) drafting a section, (b) reviewing/improving a draft, (c) running the final polish/checklist, or (d) planning the structure of the whole paper? More than one may apply.
2. **Identify the section** in play. Map it to a reference file (see the section map below) and **read that file** before writing or critiquing. Read more than one when the request spans sections.
3. **Draft or diagnose:**
   - *Drafting:* follow the move-by-move structures and signal-phrase patterns in the reference file. The professor's own method: take the numbered move list for a section, imagine the prose does not exist yet, and write one sentence (or short passage) per move, in order. Build the argument move by move, not paragraph by paragraph. Write and polish each small sentence first, then aggregate it with its neighbors and check the flow.
   - *Reviewing:* diagnose the draft against the playbook, name each issue concretely, and propose a specific rewrite (refine, do not rewrite from scratch unless asked).
4. **Always finish with the global checklist subset** (passive voice, flow, repeated words, claims-need-references, unnecessary sentences). For a near-complete paper, run the full checklist in `references/general-checklist.md`.
5. **Verify references.** Never cite arXiv for a paper that was peer-reviewed; cite the venue. For a full reference audit, use the `validate-references` skill.

When reviewing, prefer specific, surgical feedback ("sentence 3 uses passive voice and repeats 'provide' from sentence 2; rewrite as ...") over vague praise.

## Section map: which reference to read

| Section / task | Read this reference |
|---|---|
| Introduction (motivation, gap, contributions) | `references/introduction.md` |
| Related Work / State of the Art | `references/related-work.md` |
| Problem Definition / Preliminaries / formalism | `references/problem-definition.md` |
| Experiments (setup, results, figures, conclusions) | `references/experiments.md` |
| Teaser figure and its caption | `references/teaser.md` |
| Final polish, references, figures, submission | `references/general-checklist.md` |
| Quick rhetorical patterns for any section | `references/signal-phrases.md` |
| Choosing a connective that adds meaning (conjunctions/transitions by function) | `references/connectors.md` |

Abstract and conclusion are not separate playbooks: the abstract is a compressed promise (mirror the introduction's topic, gap, and contributions, and define any abbreviation the teaser uses), and the conclusion restates which promises the experiments kept and what remains open.

## Global writing rules (apply to every section, every time)

These come from the general checklist and are non-negotiable defaults. The full set lives in `references/general-checklist.md`; the always-on subset is here.

- **Kill passive voice; default to present-tense active.** The professor does not accept passive voice. Convert it to active, and state claims, contributions, and what tables and figures show in the present tense: "experiments were conducted" becomes "We conduct experiments"; "values are presented in Table 2" becomes "Table 2 presents the values"; "can be solved in O(N)" becomes "an algorithm solves it in O(N)"; "it was observed that" becomes "We observe that". Use present tense for what the paper, method, table, or figure does ("We show that", "our method outperforms", "Figure 3 reveals"); past tense is acceptable only when narrating a procedure you actually ran ("we trained 339 networks", "we ran five seeds"). The word **"can"** typically precedes hidden passive voice: search the draft for every "can" and inspect it. To sweep a finished draft, Ctrl+F "can" and rewrite each passive hit.
- **No repeated words close together**, and never the same content word twice in one sentence. If "provide" already appears, switch the next instance to "leads to" or "promotes". Watch especially for overusing *that / which / this / these*; never two in the same sentence.
- **Smooth the flow.** Read sentences i-1, i, i+1 together and check the transition reads naturally. Often four small linking words (However, these, may, also) turn a rough flow into a smooth one. Good flow is one of the hardest things to get right, and it is where a model is least reliable, so check it deliberately.
- **Every claim gets a citation or a demonstration.** No exceptions except the claims the paper itself will demonstrate.
- **Cut anything removable.** If a sentence can go without loss, it goes.
- **Running experiments is not a contribution.** "We conduct experiments on VTAB" is a setup statement; the contribution is what follows: "...and we show that ...".
- **Author preferences (Andrew):** see the always-on red-flags list below and, for choosing connectives, `references/connectors.md`.

### Andrew's recurring red flags (always on)

These are the fixes Andrew asks for most; treat each as a default, not a suggestion.

- **No em dash (—) in Andrew's prose.** Use commas, parentheses, semicolons, or restructure. Keep verbatim quotations from cited papers faithful even if they contain em dashes.
- **Never the word "canonical."** Name the specific thing instead.
- **No "X: a, b, and c" colon-then-list constructions.** Write the enumeration as an ordinary sentence. Not "three stages separate here: reading, holding, and running"; instead "a model reads the graph, holds that reading, and runs the algorithm."
- **Precise words only; no analogies, metaphors, or vague verbs.** This must read as top-venue prose, not AI slop. Replace loose or figurative verbs ("bite", "sit before", "talks itself out of") with the literal mechanism. If a phrase cannot be read literally, rewrite it.
- **Hand-pick every conjunction to add meaning, never just to connect.** A connective states the logical relation between two ideas (cause, consequence, contrast, concession, condition, addition), so choose the one that names the actual relation and let it carry weight. Do not drop in a generic "and", "also", "moreover", or "thus" as filler, and do not reuse the same connective repeatedly; diversity is welcome. When linking two sentences or clauses, pick the connective from `references/connectors.md` whose meaning is exactly right, and prefer a subordinator that builds the relation into the sentence ("since", "because", "whereas", "once") over a bolt-on sentence-initial adverb when it reads more tightly.
- **No orphan sentences.** A short declarative dropped without connective tissue ("Both sweeps agree.") reads as a lost phrase; fold it into its neighbor with a hand-picked conjunction that says why it matters.
- **Say each point once.** Do not restate a result, number, or idea made earlier, and do not repeat a content word across nearby sentences ("structure ... structure ... structure"). Before writing a sentence, check it is not re-explaining what an earlier paragraph already settled.
- **Never circle.** Every sentence adds new information or is cut. A sentence that restates its predecessor in new words is deletion bait.
- **No unexplained cleverisms.** A compressed phrase ("a change of representation, not decoration") must be immediately intelligible or spelled out in the same breath. If a reader could write "what does this mean?" beside it, it fails.
- **Write for the reviewer's first read.** Prefer concrete, named referents over abstract or set-theoretic phrasing ("the lower of the two rates", not "the smaller member"). Imagine a reviewer meeting the sentence cold.
- **Do not announce methodology.** State what happened through the numbers, not by pre-declaring the procedure. Give a rate where it does explanatory work rather than promising to report it first.
- **Do not narrate what a figure or table already shows.** Give the general message and the takeaway; leave the case-by-case detail to the float. The reader should only need the figure for the specifics.
- **Keep each experiment on its own result.** Do not re-explain a prior experiment's effect when reporting the next one; report what the current manipulation adds.
- **Push secondary detail to the supplement.** Keep the main text lean and point to the supplement for the mechanics ("following each provider's recommended configuration, App. X").
- **Lean off baseline/floor comparisons.** State the behavior directly rather than repeatedly measuring it against a chance floor. One statement that a curve sits at chance is enough.
- **Give matching specs together.** When you state one bound or parameter, give its counterpart (node range with edge range, original rate with disguised rate); a half-stated spec reads as an omission.

## Writing process

The order of operations matters as much as the prose.

1. **Results first.** Do not start writing until the experiments that confirm or refute the central claim exist (see principle 1).
2. **Write small, then aggregate.** Compose and refine one short sentence at a time. Then place it among its neighbors (the i-1, i, i+1 window) and re-check that the ideas flow. Good flow is one of the hardest parts of writing, and it is the one place an LLM is least reliable, so do it by hand.
3. **Standardize as you go.** Format every reference the moment you add it (see the reference workflow in `references/general-checklist.md`). Standardizing incrementally keeps the whole bibliography consistent for free.
4. **Re-check across the checklist.** Fixing one thing can break another: a sentence may read well in isolation but flow badly with its neighbors, so after any edit re-run the affected checks.
5. **Rest, then reread.** Before circulating a draft for internal review, step away from the text for a day or two, then reread. Distance exposes problems you cannot see while still close to the writing. Then run the full checklist again.
6. **Read widely.** Roughly one paper per day, read closely (not diagonally). You cannot tell whether your results corroborate or refute the literature, or whether your choices are supported, without knowing the literature.

## LLM confidentiality policy (read before reviewing anyone else's work)

You may use an LLM to **refine** your own sentences; refine is not the same as write from scratch. Major venues explicitly allow this: CVPR and ICPR permit referees to use an LLM to polish their review *wording*. What is forbidden is showing a paper you are **reviewing** to an LLM, which ICLR, NeurIPS, and CVPR treat as a confidentiality violation that can ban a referee for up to two years. So: helping the user write or polish *their own* paper is fine; if the user is a referee and asks to paste a *submission they are reviewing*, decline and explain the policy.

## Venue priorities

When choosing what to read, model after, or cite (in order of preference): ICLR / NeurIPS, then ICML, then CVPR / PAMI, then ICCV. Prefer recent, peer-reviewed, conference-published work (2024-2026 when possible). For ICLR and NeurIPS papers, check OpenReview: reviewer weaknesses and the author rebuttals reveal exactly what graders look for and often surface technical discussion found nowhere else.

## Worked task examples

**User:** "Help me write the introduction for my benchmark paper on graph reasoning in MLLMs."
Read `references/introduction.md`. Build the intro move by move: open with why structured reasoning in multimodal models matters; contextualize current efforts; identify the gap (do models reason about structure or pattern-match?); raise the research question; state the proposed benchmark; close with contributions framed as key insights (not "we built a dataset"). Then run the global rules.

**User:** "Is this related work paragraph good?" (pastes a paragraph)
Read `references/related-work.md`. Check the decisive move: does it state how the user's work *differs* from each cited line? If it only describes prior work, that is the main fix. Then check for grouping opportunities, citation-as-subject misuse, repeated words, and passive voice. Propose a concrete rewrite.

**User:** "Polish my whole paper before I submit to NeurIPS."
Read `references/general-checklist.md` and run the full checklist top to bottom: claims-need-references, cut unnecessary sentences, passive voice, that/which/this/these and repeated words, flow, grammar, figures (vector, one-column, all cited, same language), no tables/equations as images, references standardized and not pointing to arXiv when published, acknowledgments present. Report findings grouped by checklist item with specific line-level fixes.
