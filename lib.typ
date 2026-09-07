// sci-mosaic: scientific talks on Mosaic.
//
// The package is two things: a Mosaic theme (`setup` plus five palettes) and a
// set of research components that go inside any cell. Three named-cell grids
// name the shapes a research talk keeps reaching for. Everything else is
// Mosaic and Typst: `m.slide`, `m.grids`, `m.steps.pause`, `set` and `show`.
//
//   #import "@preview/sci-mosaic:0.1.0" as sci
//   #import "@preview/mosaic:0.0.1" as m
//   #show: sci.setup.with(palette: "academic", title: [A talk])
//   #m.slide(layout: "title")
//   #m.slide(sci.grids.spread)[== Heading][#sci.figbox(..)][Commentary.]
#import "src/theme.typ": setup, theme
#import "src/colors.typ": colors
#import "src/palettes.typ" as palettes
#import "src/grids.typ" as grids
#import "src/components.typ": (
  callout, figbox, data-table, stat, punch, spec-list,
  theorem, definition, lemma, example, proof,
  conclusion-grid, key-links, pacing,
)
#import "src/diagrams.typ" as diagrams
