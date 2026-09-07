# Changelog

## 0.1.0

First release: [sci-brain-slides](https://github.com/GiggleLiu/sci-brain-slides)
rebuilt on [Mosaic](https://github.com/vincentarelbundock/mosaic).

- Headings, the cover title, hero equations, and the ground of an inverted
  focus slide carry the palette accent, so the academic palette keeps
  sci-brain's indigo look.
- One `setup`, five palettes (`academic`, `dark`, `minimal`, `vibrant`, and
  `brand(primary)`), three named-cell grids (`spread`, `hero`, `focus`).
- Fourteen research components that go inside any cell: callout, figbox,
  data-table, stat, punch, spec-list, theorem, definition, lemma, example,
  proof, conclusion-grid, key-links, pacing. Each is labeled `<sci-*>` and
  styled by show rules.
- `diagrams` submodule with CeTZ helpers (`canvas`, `tensor`, `state`, `edge`,
  `flowbox`) and pinit annotations (`pin`, `highlight`, `note`) that read the
  deck palette.
- Removed from the Touying version: the `setup` dictionary and its
  destructuring, the `sizes` token system (use `set text` and em units), the
  `twocol`, `threecol`, `band`, `cards`, `card`, `quote_pull`,
  `progress_dots`, `toc`, `title-slide`, and `focus-slide` functions, and the
  Touying `only` and `uncover` reveals. Mosaic covers each of them.
