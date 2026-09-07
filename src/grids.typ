// Grids with anonymous cells, and three named grids for the shapes a
// research talk keeps reaching for.
//
// Mosaic's own `m.grids.columns` and `m.grids.rows` take string cell ids only.
// The constructors here accept `auto` for a cell that needs no name and an
// integer for that many of them, and name those cells by their path from the
// root: the second cell of the third child is `3-2`. Every other child (a
// string id, a Mosaic node, a `m.grids.track`) passes through unchanged.
//
//   #m.slide(sci.grids.rows(
//     sci.grids.header,
//     sci.grids.columns(auto, auto),
//     sci.grids.columns(3),
//   ))[== Heading][left][right][a][b][c]
//
// The cells are `header`, `2-1`, `2-2`, `3-1`, `3-2`, `3-3`, so an anonymous
// cell is still addressable when a rule or a `cells:` entry needs it:
//
//   #show label("mosaic-cell-2-2"): set text(size: 0.85em)
//
// Ids made only of digits and dashes are therefore reserved for anonymous
// cells; a named cell needs a letter in it.
#import "@preview/mosaic:0.0.1" as m

#let fail(message) = assert(false, message: "sci-mosaic: " + message)

#let is-anonymous(id) = id.match(regex("^[0-9]+(-[0-9]+)*$")) != none

#let is-node(value) = (
  type(value) == dictionary and "mosaic" in value and "kind" in value
)

// Prefixes every anonymous id in a subtree with the index of the child the
// subtree is, so the ids grow into paths as the tree is built outward.
#let reprefix(node, index) = {
  if node.kind == "cell" {
    if is-anonymous(node.id) {
      node.id = str(index) + "-" + node.id
    }
  } else if node.kind == "split" {
    node.children = node.children.map(child => reprefix(child, index))
  } else if node.kind == "on" {
    node.child = reprefix(node.child, index)
  }
  node
}

#let expand(children) = children.map(child => {
  if type(child) == int {
    if child < 1 {
      fail("a cell count must be a positive integer")
    }
    (auto,) * child
  } else {
    (child,)
  }
}).flatten()

#let normalize(children, name) = {
  if children.len() == 0 {
    fail(name + " must contain at least one child")
  }
  expand(children).enumerate().map(((i, child)) => {
    let size = none
    let inner = child
    if is-node(child) and child.kind == "track" {
      size = child.size
      inner = child.child
    }
    let node = if inner == auto {
      m.grids.cell(str(i + 1))
    } else if type(inner) == str {
      m.grids.cell(inner)
    } else if is-node(inner) {
      reprefix(inner, i + 1)
    } else {
      fail(
        name + " children must be auto, a cell count, a cell id, or a grid node",
      )
    }
    if size == none { node } else { m.grids.track(size, node) }
  })
}

/// `m.grids.columns` that also accepts `auto` for an anonymous cell and an
/// integer for that many of them.
#let columns(gutter: 0pt, stroke: none, ..children) = {
  if children.named().len() > 0 {
    fail("columns accepts only gutter, stroke, and children")
  }
  m.grids.columns(
    gutter: gutter,
    stroke: stroke,
    ..normalize(children.pos(), "columns"),
  )
}

/// `m.grids.rows` that also accepts `auto` for an anonymous cell and an
/// integer for that many of them.
#let rows(gutter: 0pt, stroke: none, ..children) = {
  if children.named().len() > 0 {
    fail("rows accepts only gutter, stroke, and children")
  }
  m.grids.rows(
    gutter: gutter,
    stroke: stroke,
    ..normalize(children.pos(), "rows"),
  )
}

// The heading band. The inset matches what Mosaic's own content layout gives
// its header: the deck inset across, a little over half of it above and below.
#let header = m.grids.track(
  auto,
  m.grids.cell("header", inset: (x: 1.25em, y: 0.69em)),
)
#let header-band = header

// ── Shapes ─────────────────────────────────────────────────────────────
// A shape is the terse spelling of rows of columns: `m.slide(columns: 3)`
// says one row of three, `shape(3, 2)` says a row of three over a row of
// two. Each positional argument is one row. Inside a spec:
//
//   - an integer is that many equal anonymous cells along the current axis,
//   - an array is a split along the current axis whose children take the
//     other axis, so axes alternate with depth: `shape(3, (2, 1))` gives a
//     second row of two columns, the first of which stacks two cells,
//   - a string is a named cell and `auto` one anonymous cell,
//   - `m.grids.track(size, spec)` sizes a row or a column,
//   - a finished grid node passes through.
//
// Anonymous cells are named row-column: `1-3` is the third cell of the first
// row and `2-1-2` the second stacked cell of the second row's first column.
#let build(spec, axis, gutter) = {
  let split = if axis == "columns" { columns } else { rows }
  let inner = if axis == "columns" { "rows" } else { "columns" }
  if is-node(spec) and spec.kind == "track" {
    m.grids.track(spec.size, build(spec.child, axis, gutter))
  } else if type(spec) == int {
    if spec < 1 {
      fail("a shape count must be a positive integer")
    }
    if spec == 1 { auto } else { split(gutter: gutter, spec) }
  } else if type(spec) == array {
    if spec.len() == 0 {
      fail("a shape split must contain at least one child")
    }
    split(gutter: gutter, ..spec.map(child => build(child, inner, gutter)))
  } else if spec == auto or type(spec) == str or is-node(spec) {
    spec
  } else {
    fail(
      "shape specs are integers, arrays, cell ids, auto, tracks, or grid"
        + " nodes; got " + repr(spec),
    )
  }
}

/// Rows of columns from a terse spec, under a heading band. `shape(3)` is
/// `m.slide(columns: 3)`; `shape(3, 2)` puts a row of three over a row of
/// two. See the grammar above for nesting, names, and sizes.
#let shape(..specs, header: true, gutter: 0.7em) = {
  if specs.named().len() > 0 {
    fail("shape accepts only row specs, header, and gutter")
  }
  if specs.pos().len() == 0 {
    fail("shape needs at least one row")
  }
  if type(header) != bool {
    fail("shape header must be true or false")
  }
  let body = rows(
    gutter: gutter,
    ..specs.pos().map(spec => build(spec, "columns", gutter)),
  )
  if header { m.grids.rows(header-band, body) } else { body }
}

/// Figure beside interpretation: a wide `figure` cell and a narrower
/// `commentary` cell under a `header`. The default research slide.
#let spread = rows(
  header,
  columns(gutter: 0.7em, m.grids.track(2fr, "figure"), "commentary"),
)

/// One centered equation or claim: a `hero` cell under a `header`.
#let hero = rows(header, "hero")

/// One sentence, alone on the slide, in a single `focus` cell. Pair it with
/// `invert: true` for the closing statement.
#let focus = rows("focus")
