# Introduction

The introduction is the most important and the hardest part of the paper. It is where you make promises to the reader. Get it right and the reviewer wants to read on; get it wrong and nothing else matters.

## What the introduction must do

- Present the importance of the research line.
- Show where efforts in the field are being concentrated.
- Point to existing solutions and their limitations, if any.
- Identify gaps in the literature and why filling them matters.
- Argue the importance of the current work.
- Present the contributions as key insights.

Overall: the introduction makes promises that the rest of the paper must keep.

## Questions to answer before you start writing

- Are the decisions of this work aligned with the evidence in the literature?
- Is the emphasis more practical or more theoretical?
- Is the work proposing a method, a dataset, an improvement to existing solutions, or an innovation for a specific task?
- Does the literature support the proposal? When you propose a method, it is a bundle of choices (architecture, activation, learning rate, and so on). The literature should support *each* of those choices; an unsupported choice is a hole a reviewer can question. The same applies to a new dataset: what problems of existing datasets does it solve?
- What are the problems and challenges of the current state of the art?
- Does the proposal fill gaps in the literature? Which gaps?
- Is the work a literature review? If so, what does it add over existing reviews?

## The core architecture

Across strong papers, the introduction follows a recognizable arc. Not every paper uses every move, and the order can shift, but the DNA is:

1. **Topic + importance.** Open by introducing the research topic and why it matters.
2. **Context.** Explain the phenomenon, or show where the field's efforts concentrate. Optionally categorize existing solutions.
3. **Gap.** Identify what is missing or unexplored, and why it matters to fill it. This is the hinge of the whole introduction.
4. **Motivation / research question / hypothesis.** State what drives the work ("we aim", "we hypothesize", "this raises the question").
5. **Proposed work.** State what you do ("In this work, we propose", "Here we develop").
6. **Contributions.** List them as key insights, phrased as findings, not activities.

Below are the worked patterns, each from a real published paper. Use them as templates. The numbered moves are the teaching value; the short phrases show the rhetorical signal that performs each move.

## Pattern A: gap-driven empirical paper

*Jayalath et al. No Double Descent in Self-supervised Learning. ICLR, 2023.*

1. **Topic + importance.** Name the phenomenon and assert its significance ("Double descent is a hallmark phenomenon of deep learning ...").
2. **Context.** Explain the phenomenon so the reader understands it before the argument starts.
3. **Gap.** "However, previous works study almost only supervised settings. This raises the question, what happens in the self-supervised case?" The pair *however + almost only* signals room for improvement.
4. **Confirming examples.** Cite the few works that already probed the question, showing the gap is real and live.
5. **Motivation.** The motivation grows directly out of those findings ("Following these findings, we hypothesize that ...").
6. **Contributions.** State the hypothesis and the evidence provided, and the hoped-for impact ("We provide evidence ... We hope that our findings will help elucidate ...").

## Pattern B: counterintuitive observation -> mechanism -> contributions

*Evci et al. Head2Toe: Utilizing Intermediate Representations for Better Transfer Learning. ICML, 2022.*

1. **Topic + importance.** Transfer learning matters because it gives strong performance when data is scarce.
2. **Context.** Describe the well-known recipe (pretrain on a large source task).
3. **Foundational questions that motivate the work.** Surface a counterintuitive fact and a conjecture ("FINETUNING's superior generalization in the low-data regime is counterintuitive ... We conjecture that ..."). These are the points that motivate the work.
4. **Research object.** State what you explore ("In this work, we propose and explore methods for selecting useful features from all layers ...").
5. **Contributions, as an explicit list.** Lead each with a finding verb: *We observe ... We introduce ... we show that ... outperforms ...*.

**Critical lesson from this example:** running experiments on a dataset is **not** a contribution. "We conduct experiments on the VTAB collection" only becomes a contribution when completed by "... we show that ...". The contribution is the finding, particularized on the dataset, not the act of running on it. (The only exception is a dataset so challenging or unusual that simply operating on it is itself the result.) Always pair the activity with the insight, and lead with the insight.

## Pattern C: research-question paper with explicit scope

*Masarczyk et al. The Tunnel Effect: Building Data Representations in Deep Neural Networks. NeurIPS, 2023.*

1. **Topic + importance.** Neural networks have powered ML for a decade.
2. **Context.** Present the consensus and concrete examples of the field's efforts.
3. **Where efforts concentrate.** Show the established direction (depth increases capacity).
4. **Motivation + objective.** "Motivated by these findings, we aim to investigate ..." The phrase *we aim* states the objective.
5. **Formalized research question.** Pose it explicitly and in italics ("How do representations depend on the depth of a layer?").
6. **Scope.** Define what the investigation focuses on ("Our investigation focuses on severely overparameterized networks ...").
7. **Contributions.** Bulleted findings ("We conceptualize ... We show that ...").

This example carries a subtle lesson: it never literally writes the words "objective" or "contributions". Both are *implicit* in the sentences. You do not need a heading that says "Our objectives are" or "Our contributions are"; the objective and the contributions must appear somewhere in the text, but they can be woven in implicitly. Doing this well is not easy, so when in doubt an explicit contributions list is safer.

## Pattern D: two-gap paper protected against scooping

*Duong et al. Representational Dissimilarity Metric Spaces for Stochastic Neural Networks. ICLR, 2023.*

1. **Importance of the topic.** State that the problem is fundamental.
2. **Existing lines of research.** Describe what methods already exist.
3. **Gap (first).** "However, these methods only compare deterministic representations ...". The combination of **however + only** carries the "room for improvement" message.
4. **Sub-topic with examples.** Explain a second angle (stochastic networks) with supporting literature.
5. **Importance of that sub-topic.** Stress why it matters.
6. **Gap (second), scoop-protected.** "However, to our knowledge, no studies have compared ...". The phrase **to our knowledge** protects the author from the criticism "a paper just came out doing this".
7. **Contribution.** Because the topic is fundamental (move 1) and important (move 5) and genuinely unaddressed (move 6), the contribution is, by construction, important.

## Pattern E: categorize the field, then place your work

*Fang et al. DepGraph: Towards Any Structural Pruning. CVPR, 2023.*

1. **Problem + where efforts concentrate.** Edge computing calls for compression.
2. **Candidate solutions.** Present the existing paradigms (pruning among them).
3. **Highlight one category and its advantage.** Single out the category your topic belongs to, making its relevance explicit to the reader.
4. **Explain that category's general idea** briefly.
5. **Sub-categorize the topic** (here: structural vs unstructural pruning).
6. **Advantages of the specific group** your work belongs to.
7. **Close by placing the contribution** as a step in the direction you incrementally motivated ("In sum, our contribution is a generic pruning scheme towards any structural pruning ...").

## Pattern F: solution that mitigates every raised issue

*Mirzasoleiman et al. Coresets for Data-efficient Training of Machine Learning Models. ICML, 2020.*

1. **Topic + relevance.** Optimization is central to training at scale.
2. **Problems in the topic.** Success requires large compute, cost, and energy.
3. **Importance and challenges** of mitigating those problems.
4. **What the literature has tried** (variance reduction for IG methods).
5. **Gap.** "However, the direction that remains largely unexplored is ..." and why filling it matters ("this would directly lead to a speedup").
6. **The proposed solution**, described so it visibly mitigates *every* issue raised in moves 2, 5, and 7.
7. **General idea of the solution** ("Our key idea is to ...").

The lesson: design the introduction so the proposed solution clearly answers each problem you raised. Nothing should be raised and left unanswered.

## Pattern G: efforts that ignore a problem -> your contribution is relevant

*Vasu et al. MobileOne: An Improved One millisecond Mobile Backbone. CVPR, 2023.*

1. **Where efforts concentrate.** Efficient mobile architectures have progressed (lower FLOPs and parameters).
2. **The blind spot.** "However, these metrics may not correlate well with ... latency." Highlight what the field's efforts ignore or are biased toward.
3. **Consequence.** Spell out the problems created by that blind spot.
4. **Contribution.** Introduce the goal ("Our goal is to improve the latency cost ..."). Because of move 1 (an active, important field) the contribution is, by construction, highly relevant.

## How to choose a pattern

- Proposing a **method/solution**: Pattern E or F (categorize or mitigate).
- An **empirical study / new finding**: Pattern A or C (gap-driven, research-question).
- Reframing a **counterintuitive observation**: Pattern B.
- Fighting a field's **blind spot or bias**: Pattern G.
- Worried about **being scooped**: borrow the *to our knowledge* move from Pattern D.

Most introductions are hybrids. Pick the closest skeleton, then borrow individual moves.

## Contribution-list rules

- Phrase each contribution as an insight, led by a finding verb: *We observe, We introduce, We show that, We conceptualize, We propose, We demonstrate*.
- Never list "we ran experiments on dataset X" as a contribution by itself.
- If the introduction raises a hypothesis or research question, make sure a contribution (and later an experiment) answers it.

## How to draft from these patterns

The professor's recipe: pick the closest pattern, then imagine its prose does not exist, leaving only the numbered moves. Write your introduction one move at a time, in order, filling each with your own content. Looking at the matching example while you do this makes it far easier. The numbered moves, not the borrowed sentences, are the template.

After drafting, apply the global writing rules from `SKILL.md` and, if polishing, the full `references/general-checklist.md`.
