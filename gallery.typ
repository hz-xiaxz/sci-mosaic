// The sci-mosaic gallery: every palette, grid, and component on its own slide.
// Compile with `--input theme=dark` to see another palette.
#import "@preview/sci-mosaic:0.1.0" as sci
#import "@preview/mosaic:0.0.1" as m

#show: sci.setup.with(
  palette: sys.inputs.at("theme", default: "academic"),
  overflow: sys.inputs.at("overflow", default: "off"),
  footer: [sci-mosaic · component gallery],
  title: [A place for every idea],
  subtitle: [The sci-mosaic component gallery],
  authors: [Version 0.1.0],
  date: [Scientific talks · Lectures · Briefings],
)
#set text(size: float(sys.inputs.at("text-size", default: "20")) * 1pt)

#m.slide(layout: "title")

= Palettes

#let swatches(p) = grid(
  columns: (1fr,) * 4, column-gutter: 0.7em, row-gutter: 0.5em,
  ..("accent", "text", "muted", "line", "surface", "warning", "error", "canvas").map(key => [
    #rect(width: 100%, height: 1.8em, radius: 3pt, fill: p.at(key), stroke: 0.5pt + p.line)
    #text(size: 0.6em)[#key #h(1fr) #raw(p.at(key).to-hex())]
  ]),
)
#let sample(p, description) = block(
  width: 100%, inset: 0.9em, radius: 4pt, fill: p.canvas, stroke: 0.7pt + p.line,
)[
  #set text(fill: p.text)
  #swatches(p)
  #v(0.6em)
  #text(size: 1.1em, weight: "bold")[#description]
  #h(1em)
  #text(fill: p.muted)[Body text stays readable. Emphasis follows the palette.]
]

== Academic / the default research talk
#sample(sci.palettes.academic, [Indigo on white.])

== Dark / a low-light presentation
#sample(sci.palettes.dark, [Slate, pale ink, and gold.])

== Minimal / a printable lecture
#sample(sci.palettes.minimal, [Black ink. Quiet rules.])

== Vibrant / teaching and outreach
#sample(sci.palettes.vibrant, [Teal, with the status pair kept loud.])

== Brand / start with a house color
#sample(sci.palettes.brand(rgb("#aa1e2b")), [A palette derived from one primary.])

= Grids

// A placeholder figure painted from the deck's resolved palette.
#let placeholder(label, height: 5em) = context {
  let c = sci.colors()
  rect(width: 100%, height: height, radius: 3pt, fill: c.surface, stroke: 0.7pt + c.line)[
    #align(center + horizon, text(fill: c.muted, label))
  ]
}

#m.slide(sci.grids.spread)[
  == Spread / evidence beside interpretation
][
  #sci.figbox([The evidence], placeholder([Your figure]),
    caption: [Tell the reader what to compare.])
][
  One claim belongs beside the figure.

  #sci.callout(title: [Interpretation])[Name what changes.]
]

#m.slide(sci.grids.hero)[
  == Hero / one statement to remember
][
  #sci.punch([4×], [lower standard error], source: [16 independent samples instead of one])
]

#m.slide(columns: 2)[
  == Two columns / a direct comparison
][
  #m.components.card(width: 100%)[*Before* \ Describe the baseline in one short paragraph.]
][
  #m.components.card(width: 100%)[*After* \ Explain what the new method changes.]
]

#m.slide(columns: 3)[
  == Three columns / parallel concepts
][
  *01 · Question* \ What remains unknown?
][
  *02 · Method* \ What can we measure?
][
  *03 · Evidence* \ What would settle it?
]

#m.slide(sci.grids.focus, invert: true)[
  Leave the audience with one clear claim.
]

= Components

== Callouts / a consistent visual language
#grid(columns: (1fr, 1fr), gutter: 0.6em,
  sci.callout(title: [Context])[State what the audience needs to know.],
  sci.callout(kind: "warning", title: [Limitation])[Explain where the result stops.],
  sci.callout(kind: "danger", title: [Pitfall])[Name the mistake to avoid.],
  sci.callout(kind: "plain", title: [Aside])[Keep the supporting note quiet.],
)

== Stats / quantities with their meaning
#grid(columns: (1fr,) * 3, column-gutter: 0.7em, align: center + top,
  sci.stat([16], [samples averaged together], unit: [independent]),
  sci.stat([4×], [lower standard error]),
  sci.stat([0.25], [remaining uncertainty], unit: [$sigma$]),
)
#v(1.2em)
#align(center, sci.stat([1], [assumption to check], unit: [critical]))

== Specifications / short, numbered statements
#sci.spec-list(
  (term: [Collect], desc: [Repeat the same measurement.], tag: [data]),
  (term: [Check], desc: [Test for correlated errors.], tag: [model]),
  (term: [Report], desc: [Show units and uncertainty.]),
)

== Table / make the comparison explicit
#sci.data-table(
  ("Samples", "Standard error", "Relative gain"),
  ("1", "1.00 σ", "1×"),
  ("4", "0.50 σ", "2×"),
  ("16", "0.25 σ", "4×"),
  highlight: (2,),
)
#text(size: 0.7em)[Analytical values for independent samples with variance $sigma^2$.]

== Definition and theorem / separate their jobs
#sci.definition(title: [Sample mean])[$ hat(mu) = 1/N sum_(i=1)^N x_i $]
#sci.theorem(title: [Unbiasedness])[If every sample has mean $mu$, then $EE[hat(mu)] = mu$.]

== Lemma, example, and proof / one job each
#sci.lemma[Variances of independent variables add.]
#sci.example(title: [Sixteen measurements])[
  With unit-variance noise, $"SE"(hat(mu)) = 1 \/ sqrt(16) = 0.25$.
]
#sci.proof[Expand the squared centered sum; independence removes the cross terms.]

== Mosaic's own components / nothing to re-invent
#m.components.badge(role: "accent")[result]
#m.components.badge[independent samples]
#m.components.badge(role: "warning")[draft]
#v(0.6em)
#m.components.quote(attribution: [Example text])[
  A claim becomes useful when we know how to test it.
]
#v(0.6em)
#m.components.divider(title: text(size: 0.7em)[Robustness checks])

= Reveals

== Reveal one step at a time
#sci.pacing(2)
The question comes first.
#m.steps.pause

Then the evidence.
#m.steps.pause

#sci.callout[Each reveal is another page in the PDF; the clock counts the slide once.]

== Pacing counts slides, not frames
#sci.pacing(3)
The cumulative time is five minutes.

= Diagrams

== Tensor network / structure before detail
#sci.figbox([Nodes are tensors, edges are contracted indices], align(center,
  sci.diagrams.canvas(length: 1.4cm, {
    sci.diagrams.tensor((0, 0), "A", [$A$])
    sci.diagrams.tensor((2.5, 1.2), "B", [$B$])
    sci.diagrams.tensor((2.5, -1.2), "C", [$C$])
    sci.diagrams.tensor((5, 0), "D", [$D$])
    sci.diagrams.edge("A", "B"); sci.diagrams.edge("A", "C"); sci.diagrams.edge("B", "D"); sci.diagrams.edge("C", "D")
  }),
))

== State machine / label the transitions
#align(center, sci.diagrams.canvas(length: 1.5cm, {
  sci.diagrams.state((0, 0), "q0", [$q_0$])
  sci.diagrams.state((3, 0), "q1", [$q_1$])
  sci.diagrams.state((6, 0), "q2", [$q_2$], accept: true)
  sci.diagrams.edge("q0", "q1", mark: (end: "straight"))
  sci.diagrams.edge("q1", "q2", mark: (end: "straight"))
}))
#text(size: 0.7em)[The double ring marks the accepting state.]

== Flow / connect the sides of the boxes
#align(center, sci.diagrams.canvas(length: 1.2cm, {
  sci.diagrams.flowbox((0, 0), "data", [Data])
  sci.diagrams.flowbox((5, 0), "model", [Model])
  sci.diagrams.flowbox((10, 0), "check", [Check])
  sci.diagrams.edge("data.east", "model.west", mark: (end: "straight"))
  sci.diagrams.edge("model.east", "check.west", mark: (end: "straight"))
}))
#text(size: 0.7em)[Arrows stop at the box borders.]

= Annotations

== Point to the phrase that _matters_
#v(1em)
The estimate assumes #sci.diagrams.pin(1)independent samples#sci.diagrams.pin(2).
#sci.diagrams.highlight(1, 2)
#sci.diagrams.note(2, dx: 0pt, dy: 65pt)[Check this assumption.]

= Closing

== Conclusion / a result and a next step
#sci.conclusion-grid(
  (label: [Question], title: [What did we ask?], body: [Name the uncertainty.]),
  (label: [Evidence], title: [What did we learn?], body: [Point to the result.]),
  (label: [Scope], title: [Where does it hold?], body: [State the assumptions.]),
  (label: [Next], title: [What should we test?], body: [Propose one experiment.]),
  highlight: 3,
)

== Where to go next
#sci.key-links(
  ("Code", link("https://github.com/hz-xiaxz/sci-mosaic")[github.com/hz-xiaxz/sci-mosaic]),
  ("Origin", link("https://github.com/GiggleLiu/sci-brain-slides")[GiggleLiu/sci-brain-slides]),
  ("Base", link("https://vincentarelbundock.github.io/mosaic")[Mosaic for Typst]),
)
