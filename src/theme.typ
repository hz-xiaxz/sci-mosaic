// The sci-mosaic theme: a passive Mosaic definition and the `setup` a deck
// applies.
//
// The definition is data, as Mosaic asks: colors, defaults, options, the
// three configured layouts, and one `apply` function holding every set and
// show rule the theme owns, for Mosaic's own cell vocabulary and for the
// `<sci-*>` labels the components emit. Mosaic's engine does the rest.
#import "@preview/mosaic:0.0.1" as m
#import "palettes.typ" as palettes
#import "colors.typ": publish
#import "components.typ": clock

#let fail(message) = assert(false, message: "sci-mosaic: " + message)

// Whether a canvas reads as dark, by relative luminance.
#let is-dark(colors) = {
  let parts = rgb(colors.canvas).components()
  0.2126 * parts.at(0) + 0.7152 * parts.at(1) + 0.0722 * parts.at(2) < 50%
}

#let apply(body, colors: (:), options: (:)) = {
  // Base type. The deck sets its own size after setup with an ordinary
  // `set text(size: ..)`; everything below is an em of that.
  set text(font: options.font, size: 20pt, fill: colors.text, fallback: true)
  show math.equation: set text(font: options.font-math)
  show raw: set text(font: options.font-mono)
  set raw(theme: none) if is-dark(colors)
  set par(leading: 0.65em)
  set list(indent: 0pt, body-indent: 0.7em, spacing: 0.65em, marker: text(fill: colors.accent)[•])
  set enum(indent: 0pt, body-indent: 0.7em, spacing: 0.65em)
  set terms(spacing: 0.65em)
  set table(stroke: 0.8pt + colors.line)
  show link: set text(fill: colors.accent)
  show figure.caption: set text(size: 0.7em, fill: colors.muted)

  // Headings. A level-two heading opens a content slide and sits in the
  // header cell, ruled beneath like the original sci-brain header. Level one
  // is the section title; the section cell states the display size, so the
  // heading itself stays at the cell's size rather than compounding with it.
  show heading.where(depth: 1): set text(size: 1em, weight: "bold")
  show heading.where(depth: 2): set text(size: 1.2em, weight: "bold")
  show heading.where(depth: 2): it => block(
    width: 100%,
    inset: (bottom: 0.4em),
    stroke: (bottom: 0.7pt + colors.line),
    it,
  )
  show heading: set block(below: 0.5em)

  // Mosaic's cells.
  show label("mosaic-title-display"): set text(size: 1.8em, weight: "bold")
  show label("mosaic-cell-title"): set par(leading: 0.45em)
  show label("mosaic-cell-section"): set align(left + horizon)
  show label("mosaic-cell-section"): set text(size: 1.8em, weight: "bold")
  show label("mosaic-cell-footer"): set text(size: 0.55em, fill: colors.muted)
  show label("mosaic-cell-authors"): set text(size: 0.8em, weight: "medium")
  show label("mosaic-cell-details"): set text(size: 0.62em, fill: colors.muted)

  // The sci grids.
  show label("mosaic-cell-commentary"): set text(size: 0.85em)
  show label("mosaic-cell-hero"): set align(center + horizon)
  show label("mosaic-cell-hero"): set text(size: 1.15em)
  show label("mosaic-cell-focus"): set align(left + horizon)
  show label("mosaic-cell-focus"): set text(size: 1.6em, weight: "bold")

  // The sci components.
  show label("sci-figbox-title"): it => block(
    width: 100%,
    inset: (bottom: 0.3em),
    stroke: (bottom: 0.5pt + colors.line),
    it,
  )
  show label("sci-figbox-caption"): set text(size: 0.7em, fill: colors.muted)
  show label("sci-stat"): set text(size: 1.15em)
  show label("sci-stat-value"): set text(weight: "bold", fill: colors.accent)
  show label("sci-punch-statement"): set text(size: 1.6em)
  show label("sci-punch-value"): set text(weight: "bold", fill: colors.accent)
  show label("sci-punch-source"): set text(size: 0.7em, fill: colors.muted)
  show label("sci-spec-number"): set text(weight: "bold", fill: colors.accent)
  show label("sci-spec-desc"): set text(fill: colors.muted)
  show label("sci-spec-tag"): set text(size: 0.7em)
  show label("sci-table"): set table(
    stroke: (x: none, y: 0.5pt + colors.line),
    inset: (x: 0.45em, y: 0.35em),
  )
  show label("sci-table-header"): set text(weight: "bold", fill: colors.muted)
  show label("sci-table-value"): set text(font: options.font-mono)
  show label("sci-table-highlight"): set text(weight: "bold", fill: colors.accent)
  show label("sci-conclusion-label"): set text(size: 0.7em, fill: colors.muted)
  show label("sci-conclusion-body"): set text(size: 0.85em)
  show label("sci-key-links-label"): set text(weight: "bold", fill: colors.muted)
  show label("sci-pacing"): set text(size: 0.6em, fill: colors.muted)

  publish(colors)
  body
}

// Deck chrome, drawn on the foreground plane of every numbered slide so it
// follows any layout, including the sci grids and a raw `m.grids` tree. The
// ink is read live rather than taken from the palette, so an inverted slide
// knocks it out with the rest of the type.
#let chrome(footer: none, progress: true) = context {
  let deck = m.info()
  if not deck.slide.numbered { return }
  let ink = text.fill.transparentize(40%)
  place(bottom, block(
    width: 100%,
    inset: (x: 1.25em, bottom: 0.55em),
    text(size: 0.55em, fill: ink, grid(
      columns: (1fr, auto),
      align: (left, right),
      if footer == none { [] } else { footer },
      [#deck.slide.number],
    )),
  ))
  if progress {
    place(bottom, m.components.progress(
      variant: "line", count: "slides", width: 100%, thickness: 2.5pt,
    ))
  }
}

/// The passive theme definition, exported so a variation can start from it:
/// `m.themes.setup(sci.theme + (colors: my-palette))`.
#let theme = (
  name: "sci-mosaic",
  colors: palettes.academic,
  defaults: (:),
  options: (
    font: "DejaVu Sans",
    font-mono: "DejaVu Sans Mono",
    font-math: "New Computer Modern Math",
  ),
  layouts: (
    content: m.layouts.content(variant: "header-body"),
    title: m.layouts.title(variant: "ruled"),
    section: m.layouts.section(variant: "baseline"),
  ),
  apply: apply,
)

#let themed-setup = m.themes.setup(theme)

/// Sets up a scientific deck. Apply it once as a document show rule.
///
/// ```typ
/// #show: sci.setup.with(
///   palette: "academic",
///   title: [Measuring a noisy signal],
///   authors: [Your name],
/// )
/// #set text(size: 22pt)
/// ```
///
/// `palette` is one of `"academic"`, `"dark"`, `"minimal"`, `"vibrant"`, or a
/// palette dictionary such as `sci.palettes.brand(rgb("#aa1e2b"))`. `footer`
/// is text repeated at the bottom left of every numbered slide and `progress`
/// toggles the progress line along the bottom edge. `font`, `font-mono`, and
/// `font-math` name the families. Every other named argument is an ordinary
/// Mosaic `setup` option: `title`, `subtitle`, `authors`, `date`, `colors`,
/// `handout`, `output`, `overflow`, `cells`, and the rest.
///
/// -> content
#let setup(
  body,
  palette: "academic",
  footer: none,
  progress: true,
  ..options,
) = {
  if options.pos().len() > 0 {
    fail("setup accepts only its document body positionally")
  }
  let named = options.named()
  let base = if type(palette) == str {
    if palette not in palettes.named {
      fail(
        "palette must be one of "
          + palettes.named.keys().map(repr).join(", ")
          + ", or a palette dictionary",
      )
    }
    palettes.named.at(palette)
  } else if type(palette) == dictionary {
    palette
  } else {
    fail("palette must be a name or a palette dictionary")
  }
  let overrides = named.at("colors", default: (:))
  if type(overrides) != dictionary {
    fail("colors must be a dictionary of palette overrides")
  }
  let frozen = named.at("frozen-states", default: ())
  if type(frozen) != array {
    fail("frozen-states must be an array of states")
  }
  if "foreground" not in named {
    named.insert("foreground", chrome(footer: footer, progress: progress))
  }
  named.insert("colors", base + overrides)
  named.insert("frozen-states", (clock,) + frozen)
  themed-setup(body, ..named)
}
