// The one channel from setup to code that needs paint values at call time.
//
// Components need no colors: they are labeled structure, and the theme's show
// rules paint them. Diagrams are the exception, because a CeTZ fill or a pinit
// highlight is a value, not a rule. `setup` therefore publishes the resolved
// palette once as queryable metadata, and `colors()` reads it back inside
// `context`. There is no state and no second record: the value is exactly the
// palette Mosaic's deck record holds, including any `colors:` overrides.
#import "palettes.typ": academic

#let publish(palette) = [#metadata(palette)#label("sci-colors")]

/// Reads the deck's resolved palette: the eight-color dictionary `setup`
/// painted the deck with. Call it inside `context`.
///
/// ```typ
/// #context {
///   let c = sci.colors()
///   rect(width: 60%, height: 1em, fill: c.accent)
/// }
/// ```
///
/// Outside a deck it returns the academic palette, so a component rendered in
/// a plain document still has something to paint from.
///
/// -> dictionary
#let colors() = {
  let found = query(label("sci-colors"))
  if found.len() == 0 { academic } else { found.first().value }
}
