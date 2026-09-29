# Problem Definition and Preliminaries

A formal description of the problem is an essential part of the paper. Mathematical formalism removes ambiguity and stops the reader from misunderstanding what you are doing. This section describes the variables of the problem and the objective of the work in formal terms.

## Where it can go

Depending on how heavy the formalism is, this section can live:

- inside the introduction (as a subsection),
- before related work, or
- after related work.

Choose based on complexity: light notation can sit in the introduction; a heavier formal setup deserves its own section near the front.

## Patterns

### Pattern A: define the task, then state the objective formally

*Lei et al. A Comprehensive Survey of Dataset Distillation. PAMI, 2024.*

1. Introduce how to view the topic through a mathematical formalism ("Given a target dataset T = {(x_i, y_i)} ...").
2. Using that formalism, state the objective of the topic ("the objective of dataset distillation is to extract the knowledge of T into a small synthetic dataset S ... where n << m").

### Pattern B: define variables, then state exactly what you are interested in

*Davari et al. Reliability of CKA as a Similarity Measure in Deep Learning. ICLR, 2023.*

1. Define the variables and what they represent ("Let X in R^{n x d1} denote a set of internal representations ... Let Y in R^{n x d2} be another set ...").
2. From the formalism, state the objective ("We are interested in representation similarity measures, which try to capture a certain notion of similarity between X and Y").

Lesson: explicitly stating what you are interested in closes the loophole "why didn't you also do this?". It fences the scope. A second lesson: the moment you introduce a variable, describe everything about it (here, n is the number of input examples and d1 the number of neurons). A symbol left partly undefined reintroduces the very ambiguity the formalism exists to remove.

### Pattern C: state the objective in formulas, define the terms, and keep using the notation

*Fang et al. DepGraph: Towards Any Structural Pruning. CVPR, 2023.*

1. State the objective in terms of formulas ("Formally, our goal is to find a grouping matrix G in R^{L x L} ...").
2. Describe what each term represents in the paper's context (L is the number of layers).
3. Return to the defined formalism later and actually use it ("Leveraging this notation, we resketch the network as Equation 2 ...").

Lesson: always come back to the formalism you defined. If you are not going to use it, do not formalize it.

### Pattern D: definitions, then constraints, then focus

*Kolossov et al. Towards a Statistical Theory of Data Selection Under Weak Supervision. ICLR, 2024 (oral).*

1. Introduce the formal definitions of the topic ("Given a sample of size N, it is often useful to select a subsample of smaller size n < N ...").
2. Describe the constraints imposed during the exploration, delimiting the scope ("We assume to be given N unlabeled samples ... and access to a surrogate model that can predict labels better than random guessing").
3. After the notation and constraints, state the focus of the work ("Our goal is to select a subset ... of size |G| = n < N. We then acquire labels for this set ...").

Note the formalism here is light, just a few simple variables, yet it pins the problem down completely. In this paper the same compact setup actually appears in the *abstract*, which shows that a clean, light formal statement can live near the front of the paper, not only in a dedicated section.

### Pattern E: formalism, focus, then particularities

*Gorishniy et al. TabR: Tabular Deep Learning Meets Nearest Neighbors in 2023. ICLR, 2024.*

1. Introduce the problem formalism ("we denote the dataset as {(x_i, y_i)} where x_i are features and y_i is the label ...").
2. Point to the focus of the work according to the formalism (the three task types: binary, multiclass, regression).
3. From the presented formalism, explain the work and its particularities ("Let's consider a generic feed-forward retrieval-free network f(x) = P(E(x)) ... To incrementally make it retrieval-based ...").

### Pattern F: definitions, then a research question built from them

*Duong et al. Representational Dissimilarity Metric Spaces for Stochastic Neural Networks. ICLR, 2023.*

1. Introduce the definitions and variables needed (the distance invariance, the preprocessing function, the set of nuisance transformations G).
2. After the definitions, raise a research question using the formalism ("How can Equation (2) be generalized to measure representational distances in this case?").

Note: there are no definitions that go unused (G is used later). Define only what you will use.

## Definitions to avoid

- **Do not introduce formalism you never use.** Every symbol you define must appear again. Never add formulas to pad the paper toward a page limit; padding with unused formalism badly damages credibility.
- **Never describe obvious formulas.** Mean, standard deviation, max-min normalization, z-score, and the like are assumed known. The only exception is a modification or variation specific to your problem, for example a customized or incremental mean, or a statistic adapted using prior knowledge; in that case, describe the variant.
- **For well-known metrics** (for example accuracy), do not write the formula; cite a paper that defines it, preferably a survey or benchmark.

### Obvious and verbose vs concise and refined

The same idea, written badly and well:

- **Verbose (avoid):** a multi-line definition of the mean, then the standard deviation, then the normalization step, spelling out "after estimating these metrics, we normalize the data ... before analyzing them."
- **Concise (prefer):** "It is standard practice to center the data column-wise (z-score) before analyzing them."

If the operation is standard, name it and move on. Save formal machinery for what is genuinely new.

## Checklist for the section

- Is every symbol you define used later?
- Did you state explicitly what you are interested in / your objective, to fence the scope?
- Did you avoid spelling out standard formulas, citing a survey or benchmark for known metrics instead?
- Does the formalism actually reduce ambiguity, or is it decoration?

Then apply the global writing rules from `SKILL.md`.
