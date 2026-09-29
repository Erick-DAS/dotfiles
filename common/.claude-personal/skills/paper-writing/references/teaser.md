# Teaser

The teaser is the figure that appears at the very start of the paper, typically beside the abstract or on the first page. It is the first thing a reviewer really looks at, and its job is to convince them, visually, that the work is interesting and relevant.

## What a teaser must do

- Appear at the start (beside the abstract or on page one). Some styles place it right after the title, before the abstract; CVPR papers sometimes do this. It is a matter of taste, and not everyone likes the before-abstract placement, but it exists. You must always use the "beside the abstract" style, unless prompted otherwise.
- Present results, quantitative and qualitative.
- Show the central idea of the work, giving the reader an overview of how the method works before they reach the formal problem-definition section.
- Visually convince the reader that the work is interesting and relevant. This is the most important job.
- Be self-contained through its caption: the reader should understand the figure by looking at it and reading the caption alone.

## Two jobs a teaser can take

### Job 1: present results

The teaser can lead with results so strong that, after seeing them, reading the paper feels mandatory.

- *He et al. Deep Residual Learning ... CVPR, 2016.* Training and test error curves for 20-layer vs 56-layer plain networks. For someone who knows the field, the behavior (the deeper plain network has higher training error) is arresting. The caption reinforces what the figure illustrates and adds that the same phenomenon occurs in other settings not shown.
- *EfficientNet (Tan and Le).* A Pareto plot of accuracy vs parameters. The teaser highlights that the proposed method is not surpassed on both axes at once (it dominates), and a small embedded table gives the quantitative gains so the reader sees the numbers.
- *ALOFT (Guo et al.).* A Pareto plot with an explicit *Ideal Point*; the proposed method sits closest to it. Crucially, competing methods are annotated with their venues (CVPR, NeurIPS, PAMI, ...), signaling that the work beats papers from top venues.
- *PixMix (Hendrycks et al.).* A grid of radar plots with a shared legend; the proposed method visibly dominates across several quality axes at once. The axis labels are written only on the first plot, since the axes are identical across all of them; this keeps the figure uncluttered.
- *Visualizing the Loss Landscape (Li et al., NeurIPS 2018).* Shows the proposed visualization on two architectures, one known to collapse during training and one that avoids it, reinforcing that the method captures the intended behavior.

### Job 2: show the central idea

The teaser can communicate the method's core concept. Here the abstract and teaser must work together.

- *Deep Double Descent (Nakkiran et al.).* The figure is not trivial on its own, but the abstract carries the key phrase ("performance first gets worse and then gets better"), which decodes the figure.
- *GDAS / Searching for a Robust Neural Architecture in Four GPU Hours (Dong and Yang).* The abstract defines the abbreviations used in the teaser; the teaser reads as a visual continuation of the abstract.
- *A Comprehensive Survey of Dataset Distillation (Lei and Tao, PAMI, 2024).* A clean schematic (real data -> distillation -> synthetic data; both train to comparable models) conveys the whole idea at a glance.

## The abstract-teaser contract

The combination of abstract and teaser must be harmonic. Use the abstract to define abbreviations and phrases the teaser relies on, and treat the teaser as a visual continuation of the abstract. If the figure needs a sentence from the abstract to be understood, make sure that sentence is actually there.

## Writing the caption

The caption must make the figure self-contained. It should reinforce what the figure illustrates and may add context the picture cannot show (for example, that the behavior holds in other scenarios not plotted). A reader who only reads the caption should still grasp the point.

## Design notes (carry over from the general checklist)

- Use a vector format (.pdf), not a raster image.
- A Pareto framing with an explicit ideal point reads well for results that trade off two axes.
- Annotate competing methods with their venues to underline that you beat strong baselines.
- Keep figure text in the same language as the paper.

## Checklist for the teaser

- Does it sit at the front, near the abstract?
- Does it show results, the central idea, or both, and does it actually convince?
- Is the caption self-contained?
- Does the abstract define everything the teaser assumes?
- Is it a vector figure with text in the paper's language?

Then apply the global writing rules from `SKILL.md` to the caption.
