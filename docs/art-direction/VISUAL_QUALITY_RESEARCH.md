# Visual quality research and applied cleanup

October 23, 2026. Requested during the Milestone 1 visual pass after the first
generated asset set was judged too busy and generic. This note informs the
implementation; it does not turn generated assets into human-authored artwork.

## What the sources support

- The [AAAI study on image preferences](https://ojs.aaai.org/index.php/AAAI/article/view/39666) evaluates aesthetics, artifacts, anatomy, composition, subject adherence and style separately. It reports that anatomical judgment is harder for multimodal models than for people. A fluent visual approval is therefore insufficient evidence of correct anatomy.
- [Nelson-Atkins: Expressions of Brush and Ink](https://www.nelson-atkins.org/art/exhibitions/expressions-of-brush-and-ink/) describes how outlines, texture strokes, dots and washes serve different representational purposes, and discusses restrained brushwork. This supports deliberate marks that explain form rather than a uniform surface treatment.
- The [Asian Art Museum's landscape history](https://education.asianart.org/resources/the-development-of-landscape-painting-in-china-the-song-through-the-ming-dynasties/) describes expressive ink techniques and sparse, pale-ink approaches. Detailed rendering is one historical approach, not the definition of ink painting.
- The [Patterns study of autonomous image-language loops](https://pmc.ncbi.nlm.nih.gov/articles/PMC12827715/) found convergence to conventional visual motifs in the tested iterative systems. Its scope is those loops, not proof that every generated image has the same defect. For this project, it motivates specific art direction and review rather than accepting familiar fantasy imagery automatically.

## Project-specific judgment

These are design decisions inferred from the references and actual renders,
not universal tests for detecting AI images:

| First-pass weakness | Applied correction |
| --- | --- |
| Repeated peaks and vegetation compete with the face | Fewer mountain groups and a quieter central field |
| Speckled fabric shading obscures robe construction | Larger washes with selected folds following the garment |
| Excess hair loops and mottled platform detail | Fewer locks and a simpler coherent stone base |
| Decorative framing risks becoming a second focal point | No generated frame texture; thin native ink separators |
| Pale display lettering weakens prices | Heavier serif headings, Lato prices, clearer unavailable states |
| Title/milestone labels describe the build instead of play | Removed corner branding and development copy; realm joins the resource HUD |

The quality bar is a readable silhouette, credible anatomy and construction,
selective detail, consistent marks and a clear focal hierarchy. More texture,
more ornaments, a longer prompt or a larger source image does not establish any
of those qualities. The final running screenshots remain open to the user's
visual judgment. No further gameplay systems were authorized.
