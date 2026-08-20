# Experiments

The experiments section is where the introduction's promises get cashed. Its job is to confirm the hypotheses and research questions you raised (ideally in the introduction), show what you promised, and corroborate or refute insights in the literature.

**Before anything else: have the results before you write.** The whole paper's narrative depends on what these experiments show, so the main results must exist before you write any section (see principle 1 in `SKILL.md`). Corroborating or refuting the literature is also valuable here, but it is not strictly the section's job; the section's job is to keep the introduction's promises.

## Questions to ask after the experiments are done

- Does every research question you raised have at least one experiment associated with it?
- For every hypothesis you raised, which experiment shows it is true?
- Does every claim in the text that has no reference have an experiment supporting it?
- Did any experiment leave open questions (room for improvement)? If so, why not answer them in this paper? It is perfectly acceptable to leave a question open, as long as you say so explicitly and note that answering it is outside the current scope.

## Start with the experimental setup

A good practice is to open the experiments with the setup so the reader can trust and reproduce the work:

- datasets and benchmarks,
- machine setup,
- training setup and parameter calibration,
- architectures used.

Justify the setup with the literature whenever possible. Two real openings:

- *Pham et al. Towards Data-Agnostic Pruning at Initialization. NeurIPS, 2023.* "We conduct experiments on three standard datasets ... Following [42], we use ResNet-20 for CIFAR-10, VGG-19 for CIFAR-100 ... We run five seeds ... More details ... are in Appendix A." Note *Following [42]* anchors the architecture choice in prior work.
- *Evci et al. Head2Toe. ICML, 2022.* "We evaluate HEAD2TOE on the VTAB-1k benchmark using two popular vision architectures ... both pretrained on ImageNet-2012 ... We perform five-fold cross validation ... We repeat each evaluation using 3 different seeds and report median values ...". The word *popular* justifies the architecture choice; seeds and cross-validation signal rigor.

## State the central idea of each experiment

Ideally, each experiment section or subsection states the central idea behind it: which research question does it explore or answer, and which promise from the introduction does it fulfill?

- *Mirzasoleiman et al. Coresets ... ICML, 2020.* "In our experimental evaluation we wish to address the following questions: (1) How do loss and accuracy of IG applied to the subsets returned by CRAIG compare to ... the entire data? (2) How small ...? (3) How well does CRAIG scale ...?". A numbered question list maps experiments to promises.
- *Lyle et al. Understanding Plasticity in Neural Networks. ICML, 2023.* "The experiments in Sections 4 and 5 aim to answer a fundamental question: what happens when neural networks lose plasticity? ... Section 5 asks what properties cause plasticity loss? ... Section 6.2 addresses: how can we mitigate plasticity loss?". Each section is tied to a question.

## Open an experiment with its motivation

*Duong et al. Representational Dissimilarity Metric Spaces ... ICLR, 2023.*

1. Give a brief introduction to the topic the experiment relates to ("Despite the success of artificial neural networks ... they are still susceptible to small input perturbations ...").
2. Define the setup, and make it defensible ("A simple and popular approach to induce robustness ..."). A setup that is *simple and popular* is easy to justify.
3. Conduct the experiment to investigate the motivation from move 1 ("To investigate, we trained a collection of 339 ResNet-18 networks ... sweeping over 16 values of W, 7 values of sigma, and 3 seeds ...").

Because of the motivation in move 1, the experiment becomes important.

## Experiments that motivate experiments

A chain where one experiment's open question launches the next. The power of this move is that it anticipates a doubt: you name the gap or confounder the previous experiment left, often before the reader had even noticed it, and then resolve it with the next experiment. The reader's penny drops ("the earlier experiment really did leave that open") at the same moment you answer it.

- *Maini et al. Can Neural Network Memorization Be Localized? ICML, 2023.* (1) Briefly describe the insight the previous experiment produced ("The experiment on layer rewinding helps us determine which layers are critical ..."). (2) Describe a question it left open ("However, we note that the layers important for ... mislabeled examples were also important for ... clean examples. Further, the rate of learning may be an additional confounder ..."). (3) Run the current experiment to remove that confounder ("To remove such a confounder, we study ... by retraining individual layers ...").
- *Nguyen et al. On the Origins of the Block Structure Phenomenon ... TMLR, 2022.* Two variants:
  - Summarize an evidence a prior experiment produced ("Motivated by previous evidence that the block structure propagates a dominant principal component ..."), motivate what comes next ("we examine the distribution of the projections ..."), then state the conclusions ("We find that the distribution is bimodal ...").
  - Summarize what prior experiments demonstrated ("In the previous section, we characterize the signals ..."), motivate the next set ("Informed by these findings, we next explore what happens to the block structure ... over time ..."), then conclude with the discovery ("Overall these findings suggest that ... can be attributed to both initialization parameters and the image minibatches ...").

## Experiments that corroborate experiments

When a finding lines up with an earlier result *in the same paper*, say so. This shows the experiments interlock and that every one of them points the reader toward the same conclusion, which both strengthens the claim and makes the section read as a coherent whole rather than a list.

*Masarczyk et al. The Tunnel Effect ... NeurIPS, 2023.* Two variants:

- Present the finding (in particular from a figure) ("Figure 3 reveals that for VGG-19 the inter-class representations variation decreases ..."), then reinforce that it aligns with earlier observations ("This view aligns with the observation from Figure 2, where the rank ... drops ...").
- Present the finding ("In all tested scenarios, we observe a consistent relationship ..."), then reinforce alignment with prior results ("This observation aligns with our earlier findings suggesting that the tunnel is a prevalent characteristic of the model ...").

## Refute or corroborate the literature

- *Davari et al. Reliability of CKA ... ICLR, 2023.* Contrast a finding with prior work ("This is surprising and contradictory to the previous findings (Kornblith et al., 2019; Raghu et al., 2021) ...") and also corroborate where appropriate ("Similarly we observe that ...").
- *Touvron et al. ResMLP ... PAMI, 2023.* "We observe that similar to DeiT models, ResMLP greatly benefits from distilling from a convnet. This result concurs with the observations made by d'Ascoli et al. [19] ...".

This is impossible to do well without knowing the literature, which is why wide, careful reading matters.

## Revisit research questions

*Pham et al. Towards Data-Agnostic Pruning at Initialization ... NeurIPS, 2023.* After covering the main aspects of an experiment, close by stating which research question the figure helps answer, even if only partially ("Results of all settings in Figure 5 provide evidence to support our Node-Path Balancing principle ...").

## Justify your choices, reminding the reader of the focus

*Fang et al. DepGraph ... CVPR, 2023.* Remind the reader of the focus, especially when the goal is not to beat the state of the art ("The target of this work is not to provide state-of-the-art results for various models, thus we only use the most basic importance criterion ...). Move 1 (the focus) makes the experimental choice in move 2 defensible.

## Explaining figures

State what the reader should notice; do not just repeat the caption.

- *Maini et al. ... ICML, 2023.* "Dominant datapoints are visually similar. In the left column of Figure 3, we observe that all datapoints have a blue background ... The right column ... shows ... a different seed, where the dominant datapoints share white backgrounds instead." It tells the reader exactly what to see, without duplicating the caption.
- *Chen et al. Which Layer is Learning Faster? ... ICLR, 2023.* "Two observations can be obtained from the plots: 1) The gradient of Hidden layer 1 is nearly always smaller than ... layer 2. 2) Although shallower layers have smaller gradients, they seem to converge faster." Enumerate the key takeaways. Note that "can be obtained" is passive; the active fix is "The plots highlight two observations: ...".

Two cautions when narrating a figure: do not overlap heavily with the caption (the caption already states the basics), and remember the figure must still be self-contained on its own. You are telling the reader which information to extract, not restating the caption.

## Concluding an experiment

The most important rule of this section: **never conclude an experiment with "Table 2 shows the results"**. Ending there effectively tells the reader "go to Table 2 and conclude whatever you like"; you must instead tell them what to take away. Mention where the results live, then state what you found.

- *Maini et al. ... ICML, 2023.* (1) Introduce the objective ("To assess the impact of the choice of values of p_gen and p_mem ..."). (2) Mention where the results are ("Results ... are presented in Table 2"). (3) Conclude the experiment ("We find that the method is robust to a large range of values ... In general, we observe the trend that ..."). Move 3 is mandatory.
- *Gorishniy et al. TabR ... ICLR, 2024.* (1) Discuss the results ("The obtained results highlight the retrieval technique and embeddings ... as two powerful architectural elements ... Interestingly, the two techniques are not fully orthogonal ..."). (2) Conclude with the main message ("The main takeaway. TabR becomes a new strong deep learning solution ... and achieves the new state-of-the-art on several datasets.").

## Checklist for the section

- Does the section open with a defensible setup (datasets, machine, training, architectures), justified by the literature?
- Does each experiment state the research question or promise it addresses?
- Does each experiment end with a takeaway, not a pointer to a table?
- When you explain a figure, do you tell the reader what to notice without echoing the caption?
- Are corroborations and refutations of the literature explicit (and correctly attributed)?

Then apply the global writing rules from `SKILL.md`.
