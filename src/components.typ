// Research components: ordinary content for any cell.
//
// A component takes content and semantic arguments (`kind: "warning"`,
// `highlight: (1,)`), never paint or size. It builds labeled structure, and the
// theme's show rules give every part its look:
//
//   #show label("sci-figbox-caption"): set text(size: 0.7em, fill: gray)
//
// Panels come from Mosaic's own components, which resolve their fill from the
// deck palette by role, so a warning callout is tinted correctly on a dark
// deck without this module knowing a single color.
#import "@preview/mosaic:0.0.1" as m

#let fail(message) = assert(false, message: "sci-mosaic: " + message)

// Labeled wrappers. Mosaic rebuilds every slide body once per frame and keeps
// a label only on the container elements it knows how to rebuild (`block`,
// `box`, `grid`, and so on); a label on a bare sequence is lost. So a short
// inline piece is a labeled `box` and a full-width piece a labeled `block`.
// Both are elements a show-set rule reaches.
#let tag(name, body) = [#box(body)#label(name)]
#let band(name, body) = [#block(width: 100%, body)#label(name)]

#let as-content(value) = if type(value) == content { value } else { [#value] }

// ── Callout ────────────────────────────────────────────────────────────
#let callout-kinds = (
  note: "accent",
  warning: "warning",
  danger: "error",
  plain: "neutral",
)

/// A remark set apart from the argument, with a semantic side stripe.
///
/// `kind` is `note` (the deck accent, the default), `warning`, `danger`, or
/// `plain`. Each maps to a Mosaic role, so the stripe and the panel tint follow
/// the active palette.
///
/// ```typ
/// #sci.callout(kind: "warning", title: [Limitation])[
///   The estimate assumes independent errors.
/// ]
/// ```
///
/// Labels: `<sci-callout>` on the whole panel.
#let callout(body, kind: "note", title: none) = {
  if kind not in callout-kinds {
    fail(
      "callout kind must be one of "
        + callout-kinds.keys().map(repr).join(", "),
    )
  }
  band("sci-callout", m.components.callout(
    role: callout-kinds.at(kind),
    title: title,
    body,
  ))
}

// ── Figure ─────────────────────────────────────────────────────────────
/// A titled figure frame: a bold title over a hairline, the figure, and an
/// optional caption. Pass the picture as ready-made content, such as
/// `image("error.svg")`, so the path resolves in the talk's own directory.
///
/// ```typ
/// #sci.figbox([Standard error], image("error.svg"), caption: [Same scale.])
/// ```
///
/// Labels: `<sci-figbox>`, `<sci-figbox-title>`, `<sci-figbox-caption>`.
#let figbox(title, body, caption: none) = band("sci-figbox", stack(
  dir: ttb,
  spacing: 0.45em,
  band("sci-figbox-title", text(weight: "bold", title)),
  body,
  ..if caption == none { () } else { (band("sci-figbox-caption", caption),) },
))

// ── Numbers ────────────────────────────────────────────────────────────
#let quantity(name, value, unit) = tag(name)[#value#if unit != none [~#unit]]

/// One quantity as a readable statement, not a dashboard numeral: the value
/// is emphasized by weight and color at the same scale as its meaning. Keep
/// the unit inside the emphasis (`unit: [weeks]` reads "13 weeks").
///
/// ```typ
/// #sci.stat([16], [samples averaged together], unit: [independent])
/// ```
///
/// Labels: `<sci-stat>` on the statement, `<sci-stat-value>` on the quantity.
#let stat(value, meaning, unit: none) = [#block[
  #quantity("sci-stat-value", value, unit) #meaning
]#label("sci-stat")]

/// A headline statement for the slide that carries one quantity, centered,
/// with an optional provenance line beneath it.
///
/// ```typ
/// #sci.punch([4×], [lower standard error], source: [16 samples instead of one])
/// ```
///
/// Labels: `<sci-punch>` on the block, `<sci-punch-statement>`,
/// `<sci-punch-value>`, `<sci-punch-source>`.
#let punch(value, meaning, unit: none, source: none) = band("sci-punch", align(center, {
  [#block[#quantity("sci-punch-value", value, unit) #meaning]#label("sci-punch-statement")]
  if source != none {
    [#block(above: 0.5em, source)#label("sci-punch-source")]
  }
}))

// ── Lists and tables ───────────────────────────────────────────────────
/// Short numbered statements. Each item is a record with `term` and `desc`
/// and an optional `tag`, which is set as a small badge.
///
/// ```typ
/// #sci.spec-list(
///   (term: [Collect], desc: [Repeat the same measurement.], tag: [data]),
///   (term: [Check], desc: [Test for correlated errors.]),
/// )
/// ```
///
/// Labels: `<sci-spec-list>`, `<sci-spec-number>`, `<sci-spec-term>`,
/// `<sci-spec-desc>`, `<sci-spec-tag>`.
#let spec-list(..items) = {
  let entries = items.pos()
  if items.named().len() > 0 or entries.len() == 0 {
    fail("spec-list takes positional records with term and desc")
  }
  band("sci-spec-list", stack(
    dir: ttb,
    spacing: 0.55em,
    ..entries.enumerate().map(((i, it)) => {
      if type(it) != dictionary or "term" not in it or "desc" not in it {
        fail("spec-list item " + str(i + 1) + " must be a record with term and desc")
      }
      grid(
        columns: (auto, auto, 1fr),
        column-gutter: 0.5em,
        align: (right + top, left + top, left + top),
        tag("sci-spec-number")[#(i + 1).],
        tag("sci-spec-term", text(weight: "bold", it.term)),
        band("sci-spec-desc")[
          #it.desc#if "tag" in it [
            #h(0.4em)#tag("sci-spec-tag", m.components.badge(it.tag, role: "neutral"))
          ]
        ],
      )
    }),
  ))
}

/// A comparison table. Positional rows; the first row is the header. The first
/// column is the row label, value columns are centered, and `highlight` names
/// zero-based body rows to emphasize.
///
/// ```typ
/// #sci.data-table(
///   ("Samples", "Standard error"),
///   ("4", "0.50 σ"),
///   ("16", "0.25 σ"),
///   highlight: (1,),
/// )
/// ```
///
/// Labels: `<sci-table>` on the table, `<sci-table-header>` on header cells,
/// `<sci-table-value>` on value cells, `<sci-table-highlight>` on cells of
/// highlighted rows.
#let data-table(..rows, highlight: ()) = {
  let all = rows.pos()
  if rows.named().len() > 0 {
    fail("data-table takes positional rows and highlight:")
  }
  if all.len() == 0 or type(all.first()) != array or all.first().len() == 0 {
    fail("data-table requires a nonempty header row")
  }
  let ncols = all.first().len()
  if not all.all(row => type(row) == array and row.len() == ncols) {
    fail("data-table rows must have the same number of cells")
  }
  if (
    type(highlight) != array
      or not highlight.all(i => type(i) == int and i >= 0 and i < all.len() - 1)
  ) {
    fail("data-table highlight must be an array of zero-based body row indices")
  }
  let cell(j, it, emphasized) = {
    let body = as-content(it)
    let body = if j == 0 { body } else { tag("sci-table-value", body) }
    if emphasized { tag("sci-table-highlight", body) } else { body }
  }
  [#table(
    columns: (auto,) + (1fr,) * (ncols - 1),
    align: (left + horizon,) + (center + horizon,) * (ncols - 1),
    table.header(..all.first().map(h => tag("sci-table-header", as-content(h)))),
    ..all.slice(1).enumerate().map(((i, row)) => (
      row.enumerate().map(((j, it)) => cell(j, it, i in highlight))
    )).flatten(),
  )#label("sci-table")]
}

// ── Theory ─────────────────────────────────────────────────────────────
#let theory(id, kind, role) = (body, title: none) => band("sci-" + id, m.components.callout(
  role: role,
  title: [#tag("sci-theory-kind", kind)#if title != none [ · #title]],
  body,
))

/// Theorem, definition, lemma, example, and proof boxes. Each takes the body
/// and an optional `title`. The first three carry the deck accent; example
/// and proof sit on the neutral surface.
///
/// ```typ
/// #sci.theorem(title: [Sample mean])[For independent samples, $"SE" = sigma / sqrt(N)$.]
/// #sci.proof[Expand the variance and use independence.]
/// ```
///
/// Labels: `<sci-theorem>`, `<sci-definition>`, `<sci-lemma>`, `<sci-example>`,
/// `<sci-proof>` on the boxes; `<sci-theory-kind>` on the kind word.
#let theorem = theory("theorem", [Theorem], "accent")
#let definition = theory("definition", [Definition], "accent")
#let lemma = theory("lemma", [Lemma], "accent")
#let example = theory("example", [Example], "neutral")
#let proof = theory("proof", [Proof], "neutral")

// ── Closing ────────────────────────────────────────────────────────────
/// A grid of conclusion cards. Each card is a record with `label`, `title`,
/// and `body`; `highlight` is the zero-based index of the card to set in the
/// accent role.
///
/// ```typ
/// #sci.conclusion-grid(
///   (label: [Question], title: [What did we ask?], body: [Name the uncertainty.]),
///   (label: [Next], title: [What should we test?], body: [Propose one experiment.]),
///   highlight: 1,
/// )
/// ```
///
/// Labels: `<sci-conclusion-grid>`, `<sci-conclusion-label>`,
/// `<sci-conclusion-title>`, `<sci-conclusion-body>`.
#let conclusion-grid(..cards, highlight: none, columns: 2) = {
  let items = cards.pos()
  if cards.named().len() > 0 or items.len() == 0 {
    fail("conclusion-grid takes positional card records")
  }
  if highlight != none and (
    type(highlight) != int or highlight < 0 or highlight >= items.len()
  ) {
    fail("conclusion-grid highlight must be a valid zero-based card index")
  }
  if type(columns) != int or columns < 1 {
    fail("conclusion-grid columns must be a positive integer")
  }
  [#grid(
    columns: (1fr,) * columns,
    gutter: 0.5em,
    ..items.enumerate().map(((i, card)) => {
      if type(card) != dictionary or ("label", "title", "body").any(key => key not in card) {
        fail("conclusion-grid card " + str(i + 1) + " must be a record with label, title, and body")
      }
      m.components.card(
        role: if i == highlight { "accent" } else { "neutral" },
        width: 100%,
        stack(
          dir: ttb,
          spacing: 0.35em,
          band("sci-conclusion-label", card.at("label")),
          band("sci-conclusion-title", text(weight: "bold", card.title)),
          band("sci-conclusion-body", card.body),
        ),
      )
    }),
  )#label("sci-conclusion-grid")]
}

/// Labeled links for the closing slide: `(label, content)` pairs. Use a Typst
/// `link` in the content when the destination should be clickable.
///
/// ```typ
/// #sci.key-links(
///   ("Code", link("https://github.com/hz-xiaxz/sci-mosaic")),
///   ("Data", [On request.]),
/// )
/// ```
///
/// Labels: `<sci-key-links>`, `<sci-key-links-label>`.
#let key-links(..pairs) = {
  let entries = pairs.pos()
  if pairs.named().len() > 0 or entries.len() == 0 {
    fail("key-links takes positional (label, content) pairs")
  }
  if not entries.all(pair => type(pair) == array and pair.len() == 2) {
    fail("key-links entries must be (label, content) pairs")
  }
  [#grid(
    columns: (auto, 1fr),
    column-gutter: 0.6em,
    row-gutter: 0.5em,
    align: top,
    ..entries.map(((name, body)) => (
      tag("sci-key-links-label", as-content(name)),
      as-content(body),
    )).flatten(),
  )#label("sci-key-links")]
}

// ── Pacing ─────────────────────────────────────────────────────────────
// The running rehearsal clock. `setup` freezes it across the frames of an
// incremental slide, so a slide's minutes count once however many times it
// pauses.
#let clock = state("sci-mosaic:clock", 0)

/// A cumulative rehearsal time at the top right of the cell. Call it once per
/// slide with the minutes that slide should take.
///
/// ```typ
/// #sci.pacing(2)
/// ```
///
/// Labels: `<sci-pacing>`.
#let pacing(minutes) = {
  if type(minutes) not in (int, float) or minutes < 0 {
    fail("pacing minutes must be a nonnegative number")
  }
  clock.update(total => total + minutes)
  place(top + right, tag("sci-pacing", context {
    let total = clock.get()
    let shown = if type(total) == float and calc.fract(total) == 0 {
      str(int(total))
    } else {
      str(total)
    }
    [#shown min]
  }))
}
