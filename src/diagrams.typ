// CeTZ and pinit helpers for the diagrams that recur in scientific slides:
// tensor-network nodes, automaton states, flow boxes, connectors, and pin
// annotations.
//
// The CeTZ helpers are pure functions that draw with whatever style is in
// force; `canvas` reads the deck palette and states that style once, so a
// diagram follows the palette without naming a color:
//
//   #sci.diagrams.canvas(length: 1.5cm, {
//     sci.diagrams.tensor((0, 0), "A", [$A$])
//     sci.diagrams.tensor((3, 0), "B", [$B$])
//     sci.diagrams.edge("A", "B")
//   })
//
// The drawing packages load only when these are called, so a deck without
// diagrams never downloads them.
#import "colors.typ": colors as deck-colors

#let fail(message) = assert(false, message: "sci-mosaic: " + message)

#let tint(colors, c, k) = color.mix((c, k), (colors.canvas, 100% - k))

/// A CeTZ canvas painted from the deck palette. Positional draw elements are
/// the body; named arguments go to `cetz.canvas`. Nodes take the accent,
/// connectors the muted color, and labels inherit the deck's text color.
///
/// -> content
#let canvas(body, ..args) = {
  if args.pos().len() > 0 {
    fail("diagrams.canvas takes one body and cetz.canvas named arguments")
  }
  context {
    import "@preview/cetz:0.5.2" as cetz
    let c = deck-colors()
    cetz.canvas(..args.named(), {
      cetz.draw.set-style(
        stroke: 1.1pt + c.accent,
        fill: tint(c, c.accent, 18%),
        line: (stroke: 1pt + c.muted),
        content: (
          fill: tint(c, c.accent, 12%),
          stroke: 1pt + c.accent,
          padding: (left: 10pt, right: 10pt, top: 6pt, bottom: 6pt),
        ),
      )
      body
    })
  }
}

/// A tensor-network node: a filled circle with its label at the center. The
/// radius is in canvas units, so node size follows the canvas `length`; keep
/// centers about 2.5 units apart.
#let tensor(loc, name, label, radius: 0.45) = {
  import "@preview/cetz:0.5.2": draw
  draw.circle(loc, radius: radius, name: name)
  draw.content(name, label)
}

/// An automaton state. Accepting states get a double ring.
#let state(loc, name, label, accept: false, radius: 0.55) = {
  import "@preview/cetz:0.5.2": draw
  draw.circle(loc, radius: radius, name: name, fill: none)
  if accept {
    draw.circle(loc, radius: radius - 0.12, fill: none, stroke: 0.8pt)
  }
  draw.content(name, label)
}

/// A connector between two named anchors, stopping at element borders.
/// Undirected by default; pass `mark: (end: "straight")` for an arrow.
#let edge(from, to, mark: none, stroke: auto) = {
  import "@preview/cetz:0.5.2": draw
  if stroke == auto {
    draw.line(from, to, mark: mark)
  } else {
    draw.line(from, to, mark: mark, stroke: stroke)
  }
}

/// A boxed node sized to its label, for flowcharts. Connect through its side
/// anchors, such as `"in.east"` and `"out.west"`.
#let flowbox(loc, name, label) = {
  import "@preview/cetz:0.5.2": draw
  draw.content(loc, label, name: name, frame: "rect")
}

/// Drops an inline pin marker. Wrap a span between two pins to highlight it.
#let pin(id) = {
  import "@preview/pinit:0.2.2": pin as pinit-pin
  pinit-pin(id)
}

/// Highlights the span between pins, in the deck accent.
#let highlight(..ids) = context {
  import "@preview/pinit:0.2.2": pinit-highlight
  let c = deck-colors()
  pinit-highlight(..ids, fill: c.accent.transparentize(82%))
}

/// A note pointing at a pin; the arrow and the box follow the palette.
#let note(id, body, dx: 35pt, dy: 35pt) = context {
  import "@preview/pinit:0.2.2": pinit-point-from
  let c = deck-colors()
  pinit-point-from(id, offset-dx: dx, offset-dy: dy, fill: c.accent)[
    #block(
      radius: 3pt, inset: 0.35em,
      fill: tint(c, c.accent, 12%),
      stroke: 0.5pt + c.accent,
      text(fill: c.text, body),
    )
  ]
}
