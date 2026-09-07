#import "@preview/sci-mosaic:0.1.0" as sci
#import "@preview/mosaic:0.0.1" as m

// Choose a palette before composing the talk. Compile with
// `--input theme=dark` or `--input text-size=22` to try another look.
#show: sci.setup.with(
  palette: sys.inputs.at("theme", default: "academic"),
  overflow: sys.inputs.at("overflow", default: "off"),
  title: [Finding structure in noise],
  subtitle: [What repeated measurements can tell us],
  authors: [Your name],
  date: [Conference · 2026],
)
#set text(size: float(sys.inputs.at("text-size", default: "20")) * 1pt)

#m.slide(layout: "title")

// Two equal columns connect the measurement model to the estimator.
#m.slide(columns: 2)[
  == How precisely can we measure the signal?
][
  *One measurement*
  $ x_i = mu + epsilon_i $
  A fixed signal $mu$, disturbed by zero-mean noise $epsilon_i$.
][
  *The sample mean*
  $ hat(mu) = 1/N sum_(i=1)^N x_i $
  How much uncertainty remains after averaging $N$ measurements?
]

// One equation with the slide's full attention.
#m.slide(sci.grids.hero)[
  == Averaging reduces independent noise
][
  #text(size: 1.6em)[$ "SE"(hat(mu)) = sigma / sqrt(N) $]
  Independent samples, each with variance $sigma^2$.
  Their variances add: $"Var"(hat(mu)) = sigma^2 / N$.
]

// A wide figure and a narrower interpretation stay together.
#let bars = context {
  let c = sci.colors()
  let bar(width) = rect(width: width, height: 1.2em, fill: c.accent, stroke: none)
  grid(
    columns: (auto, 1fr, auto), column-gutter: 0.7em, row-gutter: 0.9em,
    align: horizon,
    [$N = 1$], bar(100%), [1.00],
    [$N = 4$], bar(50%), [0.50],
    [$N = 16$], bar(25%), [0.25],
  )
}
#m.slide(sci.grids.spread)[
  == Four times the samples halves the error
][
  #sci.figbox([Standard error / $sigma$], bars,
    caption: [Model prediction for independent samples.])
][
  Each twofold improvement in precision costs four times as many samples.

  More data helps, with diminishing returns.
]

// Two matching cards, then a full-width note: a grid composed in place.
#m.slide(m.grids.rows(
  sci.grids.header,
  m.grids.columns(gutter: 0.7em, "left", "right"),
  m.grids.track(auto, "note"),
))[
  == Shared errors can survive averaging
][
  #m.components.card(width: 100%)[
    *Independent errors*
    $ "SE"(hat(mu)) = sigma / sqrt(N) $
    Different errors cancel in the average.
  ]
][
  #m.components.card(width: 100%)[
    *Identical errors*
    $ "SE"(hat(mu)) = sigma $
    Every sample carries the same error.
  ]
][
  #text(size: 0.7em)[Identical errors are the limiting case of perfect positive correlation.]
]

// Close with one takeaway, inverted, with no competing panels.
#m.slide(sci.grids.focus, invert: true)[
  Check the noise before collecting more samples.
]
