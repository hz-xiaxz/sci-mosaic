// Three grids with semantically named cells: the shapes a research talk keeps
// reaching for, and nothing a plain `m.grids.columns` already says.
//
// Every cell renders under `<mosaic-cell-ID>`, so the look follows the name:
//
//   #show label("mosaic-cell-commentary"): set text(size: 0.85em)
//
// Each grid opens with a content-sized `header` cell, because an explicit
// `m.slide` does not absorb a preceding `== Heading`; the heading goes in the
// first body instead:
//
//   #m.slide(sci.grids.spread)[== Standard error][#sci.figbox(..)][Commentary.]
#import "@preview/mosaic:0.0.1" as m

// The heading band. The inset matches what Mosaic's own content layout gives
// its header: the deck inset across, a little over half of it above and below.
#let header = m.grids.track(
  auto,
  m.grids.cell("header", inset: (x: 1.25em, y: 0.69em)),
)

/// Figure beside interpretation: a wide `figure` cell and a narrower
/// `commentary` cell under a `header`. The default research slide.
#let spread = m.grids.rows(
  header,
  m.grids.columns(
    gutter: 0.7em,
    m.grids.track(2fr, "figure"),
    "commentary",
  ),
)

/// One centered equation or claim: a `hero` cell under a `header`.
#let hero = m.grids.rows(header, "hero")

/// One sentence, alone on the slide, in a single `focus` cell. Pair it with
/// `invert: true` for the closing statement.
#let focus = m.grids.rows("focus")
