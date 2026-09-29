# Related Work / State of the Art

The related work section is not a catalog of what exists. It is an argument about where the frontier is and how your paper advances it. The single most common failure is describing prior work without ever stating how your work differs.

## What this section must do

- Go beyond describing what already exists: elaborate on the contribution of *your* paper relative to existing knowledge.
- Establish what the state of the art is and where and how the frontier is being advanced.
- Describe how existing solutions address the problem and how your paper innovates on that.
- Corroborate or refute insights already in the literature.
- Support your methodological and experimental decisions (baselines, benchmarks, architectures, experimental configuration).

## The decisive move: always state the difference

Mentioning that similar work exists without explaining the difference makes no sense. If your paper answers questions that were already answered, there is no contribution, and no reason to accept it. So every time you bring up a related line of work, immediately mark how you differ.

Signal phrases that perform this move: *We distinguish ourselves from these papers by ...*, *In contrast, we focus on ...*, *Unlike existing ...*, *In comparison to our approach ...*, *The most notable difference between [X] and our work is ...*.

## Patterns

### Pattern A: compare against a concurrent or competing work, point by point

*He et al. Deep Residual Learning for Image Recognition. CVPR, 2016 (best paper).*

1. State explicitly that a concurrent work exists ("Concurrent with our work, highway networks ...").
2. Explain a particularity of the cited work (its gates are data-dependent and parameterized).
3. Mark a distinction from your work, tied to move 2 (your identity shortcuts are parameter-free).
4. Detail another particularity of the same work.
5. Mark another distinction, tied to move 4.
6. Conclude the comparison by pointing to additional advantages beyond those in moves 3 and 5 ("In addition, highway networks have not demonstrated accuracy gains with extremely increased depth").

The rhythm is: their property -> our difference, repeated, then a closing advantage. Note what the closing "In addition" achieves: every contrast in moves 3 and 5 is already a point in your favor, and the "In addition" move says "on top of all those differences, we also win on accuracy." It stacks one more advantage onto a comparison that was already favorable.

### Pattern B: name the closest work and immediately differentiate

*Davari et al. Reliability of CKA as a Similarity Measure in Deep Learning. ICLR, 2023.*

1. Make explicit that a closely aligned work exists ("Most closely related to our work, Ding et al. (2021) ...").
2. Describe the difference, right away ("We distinguish ourselves from these papers by providing theoretical justifications ..."), and add a second distinction ("Secondly, we do not only ... but we also ...").

Lesson: move 2 is essential. Never mention a similar work and leave the difference unstated.

### Pattern C: concurrent works that complement you

*Touvron et al. ResMLP: Feedforward Networks for Image Classification With Data-Efficient Training. PAMI, 2023.*

1. Point to a work that complements one of your contributions ("The MLP-Mixer model ... brings complementary insights to ours ...").
2. Immediately contrast to mark your novelty ("In contrast, we focus on faster models ... and provide more architectural ablations").
3. Introduce another concurrent work briefly (general idea only).
4. Again mark your novelty against it ("In comparison to our approach ...").

Moves 2 and 4 are the point: if the current paper answers questions already answered, what is the contribution?

### Pattern D: group a body of work, then contrast against the group

*Mirzasoleiman et al. Coresets for Data-efficient Training of Machine Learning Models. ICML, 2020.* (three variants)

Grouping a series of works avoids describing each one too specifically.

- **Variant 1.** Open by describing a *category* of studies ("Convergence of IG methods has been long studied under various conditions (many citations)"), specify just *one* representative work to give the reader a concrete idea (if you are summarizing, do not give many examples), then contrast your work with the *category*, not with a single paper ("While these works provide convergence on the full dataset, our analysis provides the same rates on subsets ..."). Note that "provide ... provides" repeats a word too close together; the polish pass would swap the second to "leads to" or "promotes" (see the repeated-words rule in the checklist).
- **Variant 2.** Describe where efforts concentrate by naming the category the cited works belong to ("Techniques for speeding up SGD are mostly focused on variance reduction ..."), introduce your complement using that category, then note your work not only complements but can be combined ("CRAIG can be applied to all these methods as well ...").
- **Variant 3.** Briefly describe how related solutions operate ("Coreset construction methods traditionally perform importance sampling ..."), then contrast ("Unlike existing coreset construction algorithms, our method is not problem specific ...").

### Pattern E: topic -> recent strategies -> examples -> disadvantages -> open problem

*Li et al. AM-LFS: AutoML for Loss Function Search. ICCV, 2019.*

1. Introduce the general idea of the topic.
2. Highlight recent strategies in the topic.
3. Give examples of existing solutions.
4. Point out the disadvantages of the solutions in move 3.
5. Highlight solutions to that problem, with examples. (Do **not** use a citation number as the subject of a sentence.)
6. Close by raising open questions covering everything above, ideally framing the current paper as a step toward answering them.

### Pattern F: efforts -> gap -> we bridge it

*Jordão et al. When Layers Play the Lottery, all Tickets Win at Initialization. ICCV, 2023.*

1. Point to where some efforts are being dedicated ("many studies have focused on removing layers ...").
2. Note that despite those efforts, questions remain: a gap ("Unfortunately, none of these efforts have been done in the direction of ...").
3. Close by explicitly stating which gap the work fills, referring back to move 2 ("To bridge this gap, we take a step towards ...").

## Use related work to warm up your methodological choices

*Davari et al. Reliability of CKA ... ICLR, 2023.*

You can use related work to pre-justify methodological and experimental choices. Handle this carefully: it is delicate, because justifying choices in detail is not the main role of related work. Keep it to a *warm-up*; the heavy justification belongs in the experiments section. Over-specifying here makes related work lose its primary job (situating your contribution).

1. Show which setups the literature has been using ("all subsequent papers ... have used linear CKA (many citations)").
2. Define your choice, motivated by that literature ("Consequently, we largely focus our analysis on linear CKA, which is the most popular method and the one actually used in practice").

This matters because there are always n options for any setup. Anchoring your choice in the literature sends the message: "we know other options exist, but we follow the state of the art."

## Highlight contribution against existing knowledge

- *Lei et al. A Comprehensive Survey of Dataset Distillation. PAMI, 2024.* Introduce a correlated work ("We note that there is a concurrent survey ..."), describe the difference ("The most notable difference between [it] and our survey is the taxonomy"), explain the singularity briefly (a hierarchical taxonomy), and conclude by making the difference explicit and the contribution evident ("Therefore, our taxonomy provides a more systematic ...").
- *Maini et al. Can Neural Network Memorization Be Localized? ICML, 2023.* State what the literature contributes on the topic, specify the direction of those efforts, contextualize with a concrete work in that line, then mark your difference ("In our experiments ... we investigate the opposite idea ...").

## Checklist for the section

- Did every related line get a stated difference from your work?
- Could several works be grouped into a category instead of described one by one?
- Is any citation number used as a sentence subject? (Fix it.)
- Do the methodological-choice justifications stay brief, leaving detail for the experiments section?

## How to draft from these patterns

Same recipe as the introduction: pick the closest pattern, imagine its prose does not exist, and write your related work one numbered move at a time. For example, start by explicitly flagging a concurrent work, explain a particularity, state your difference, add another particularity and difference, and close with any extra advantage. The moves are the template, not the borrowed sentences.

Then apply the global writing rules from `SKILL.md`.
