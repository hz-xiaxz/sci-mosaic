// Five palettes, each the flat eight-color dictionary a Mosaic theme paints
// from. Six keys are the deck's chrome (`canvas`, `surface`, `text`, `muted`,
// `line`, `accent`) and two are the status colors components paint with
// (`warning`, `error`). A palette is plain data: extend one by addition,
//
//   sci.palettes.academic + (accent: rgb("#b91c1c"))
//
// and hand the result to `setup(palette: ..)`.

// Restrained indigo on white. The conference-talk default: serious,
// projector-safe, prints well in greyscale. The accent is the original
// sci-brain primary, which paints headings, the progress line, emphasized
// quantities, and the ground of an inverted focus slide.
#let academic = (
  canvas: rgb("#ffffff"),
  surface: rgb("#f7f7fb"),
  text: rgb("#1c1c2e"),
  muted: rgb("#56566e"),
  line: rgb("#d4d4de"),
  accent: rgb("#2f2f7f"),
  warning: rgb("#b45309"),
  error: rgb("#c62828"),
)

// Light text and a gold accent on deep slate, for dim rooms where a white
// ground glares.
#let dark = (
  canvas: rgb("#1b2138"),
  surface: rgb("#242b4a"),
  text: rgb("#e8ecff"),
  muted: rgb("#a6adcb"),
  line: rgb("#38406b"),
  accent: rgb("#e0b341"),
  warning: rgb("#e09a4a"),
  error: rgb("#f28b82"),
)

// Black ink on white with one grey rule, for handouts and venues that punish
// decoration.
#let minimal = (
  canvas: rgb("#ffffff"),
  surface: rgb("#f4f4f4"),
  text: rgb("#111111"),
  muted: rgb("#555555"),
  line: rgb("#cccccc"),
  accent: rgb("#222222"),
  warning: rgb("#7a5c10"),
  error: rgb("#9a2222"),
)

// Saturated teal on white, for teaching and outreach.
#let vibrant = (
  canvas: rgb("#ffffff"),
  surface: rgb("#effcf9"),
  text: rgb("#1c2b2a"),
  muted: rgb("#5b6b6a"),
  line: rgb("#99e6d8"),
  accent: rgb("#0d8a7f"),
  warning: rgb("#d97706"),
  error: rgb("#db2777"),
)

// Derives a coherent light palette from one house color, so a lab or a
// product drops in its primary and gets a matching deck. Text is a very dark
// shade of the primary, the surface a faint wash of it, the line a grey with
// a trace of it; the primary itself is the accent.
#let brand(primary) = {
  assert(type(primary) == color, message: "sci-mosaic: brand expects a color")
  let ink = color.mix((primary, 12%), (rgb("#10101a"), 88%))
  (
    canvas: rgb("#ffffff"),
    surface: color.mix((primary, 5%), (white, 95%)),
    text: ink,
    muted: color.mix((ink, 62%), (white, 38%)),
    line: color.mix((primary, 18%), (rgb("#cfcfcf"), 82%)),
    accent: primary,
    warning: rgb("#b45309"),
    error: rgb("#c62828"),
  )
}

// The named palettes `setup(palette: "..")` selects from.
#let named = (
  academic: academic,
  dark: dark,
  minimal: minimal,
  vibrant: vibrant,
)
