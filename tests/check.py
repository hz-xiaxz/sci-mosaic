#!/usr/bin/env python3
"""Compile the installed template, the README example, and the gallery. No test dependencies."""
import argparse
import re
import shutil
import subprocess
import tempfile
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PALETTES = ("academic", "dark", "minimal", "vibrant")
STARTER_PAGES = 6
GALLERY_PAGES = 35


def pdf_pages(path):
    """Count page objects in a PDF emitted by Typst."""
    return len(re.findall(rb"/Type\s*/Page\b", path.read_bytes()))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--typst", default="typst", help="Typst compiler executable")
    parser.add_argument("--output", type=Path, default=ROOT / "previews")
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    manifest = tomllib.loads((ROOT / "typst.toml").read_text())
    package = manifest["package"]
    spec = f'@preview/{package["name"]}:{package["version"]}'

    with tempfile.TemporaryDirectory(prefix="sci-mosaic-") as tmp:
        tmp = Path(tmp)
        packages = tmp / "packages"
        install = packages / "preview" / package["name"] / package["version"]
        # Copy only what users receive.
        shutil.copytree(ROOT / "src", install / "src")
        shutil.copytree(ROOT / "template", install / "template")
        for name in ("lib.typ", "typst.toml", "README.md", "LICENSE"):
            shutil.copy2(ROOT / name, install / name)

        def run(*command, error=None, inputs=()):
            argv = [args.typst, *map(str, command), "--package-path", str(packages)]
            for key, value in inputs:
                argv += ["--input", f"{key}={value}"]
            result = subprocess.run(argv, capture_output=True, text=True)
            if error is not None:
                assert result.returncode != 0 and error in result.stderr, result.stderr
            else:
                assert result.returncode == 0, result.stderr
                assert "warning:" not in result.stderr, result.stderr
            return result.stdout

        deck = tmp / "fresh-deck"
        run("init", spec, deck)
        entry = deck / manifest["template"]["entrypoint"]

        # The README's complete example must compile as written.
        example = re.search(r"```typst\n(#import .*?)\n```", (ROOT / "README.md").read_text(), re.S)
        assert example is not None, "README must include a complete Typst example"
        (deck / "error.svg").write_text(
            '<svg xmlns="http://www.w3.org/2000/svg" width="160" height="100">'
            '<rect width="160" height="100" fill="#4f3fc4"/></svg>'
        )
        readme = deck / "readme.typ"
        readme.write_text(example.group(1))
        run("compile", readme, output / "readme.pdf")

        gallery = deck / "gallery.typ"
        gallery.write_text((ROOT / "gallery.typ").read_text())
        for palette in PALETTES:
            starter_pdf = output / f"starter-{palette}.pdf"
            gallery_pdf = output / f"gallery-{palette}.pdf"
            run("compile", entry, starter_pdf, inputs=[("theme", palette), ("overflow", "error")])
            run("compile", gallery, gallery_pdf, inputs=[("theme", palette), ("overflow", "error")])
            for source, pdf, expected in ((entry, starter_pdf, STARTER_PAGES), (gallery, gallery_pdf, GALLERY_PAGES)):
                count = pdf_pages(pdf)
                assert count == expected, f"{palette} {source.name}: expected {expected} pages, got {count}"
            print(f"PASS {palette}: starter + gallery, no clipped cells")

        # The starter must keep its page count at each supported body size.
        for size in (22, 24):
            for palette in PALETTES:
                starter_pdf = output / f"starter-{palette}-{size}pt.pdf"
                run("compile", entry, starter_pdf,
                    inputs=[("theme", palette), ("text-size", size), ("overflow", "error")])
                count = pdf_pages(starter_pdf)
                assert count == STARTER_PAGES, f"{size}pt {palette} starter spilled onto {count} pages"
        print("PASS starter fits at 20, 22, and 24pt in every palette")

        # A brand palette and a Mosaic color override compose with setup.
        brand = deck / "brand.typ"
        brand.write_text(
            f'#import "{spec}": *\n'
            '#import "@preview/mosaic:0.0.1" as m\n'
            '#show: setup.with(palette: palettes.brand(rgb("#aa1e2b")), colors: (accent: rgb("#0a7"),), '
            'title: [Brand], footer: [Footer], progress: false)\n'
            '#m.slide(layout: "title")\n'
            '== A slide\n#stat([13], [weeks], unit: [long])\n'
            '#context { assert(colors().accent == rgb("#0a7")); assert(colors().canvas.to-hex() == "#ffffff") }\n'
            '#m.slide(grids.focus, invert: true)[Done.]\n'
        )
        run("compile", brand, output / "brand.pdf")
        assert pdf_pages(output / "brand.pdf") == 3

        # Anonymous cells are named by their path and stay addressable.
        anon = deck / "anon.typ"
        anon.write_text(
            f'#import "{spec}": *\n'
            '#import "@preview/mosaic:0.0.1" as m\n'
            '#show: setup.with(title: [Anon])\n'
            '#show label("mosaic-cell-2-2"): it => [#metadata("hit") <cell>#it]\n'
            '#m.slide(grids.rows(grids.header, grids.columns(auto, auto), m.grids.track(2fr, grids.columns(3))),'
            ' cells: (header: [== A], "2-1": [x], "2-2": [y], "3-3": [z]))\n'
            '#m.slide(grids.columns(auto, grids.rows(auto, "note")))[a][b][c]\n'
        )
        run("compile", anon, output / "anon.pdf")
        observed = run("eval", "query(<cell>).map(it => it.value)", "--in", anon)
        assert observed.strip() == '["hit"]', observed

        # Shapes name their cells row-column and nest with alternating axes.
        shape = deck / "shape.typ"
        shape.write_text(
            f'#import "{spec}": *\n'
            '#import "@preview/mosaic:0.0.1" as m\n'
            '#show: setup.with(title: [Shape])\n'
            '#show label("mosaic-cell-2-1-2"): it => [#metadata("deep") <cell>#it]\n'
            '#m.slide(grids.shape(3, (2, 1)), cells: (header: [== S], "1-3": [x], "2-1-2": [y], "2-2": [z]))\n'
            '#m.slide(grids.shape(m.grids.track(2fr, ("figure", "commentary")), 3, header: false))'
            '[f][c][a][b][d]\n'
            '#m.slide(grids.shape(1))[== One][only]\n'
        )
        run("compile", shape, output / "shape.pdf")
        observed = run("eval", "query(<cell>).map(it => it.value)", "--in", shape)
        assert observed.strip() == '["deep"]', observed

        # The rehearsal clock counts an incremental slide once.
        pacing = deck / "pacing.typ"
        pacing.write_text(
            f'#import "{spec}": *\n'
            '#import "@preview/mosaic:0.0.1" as m\n'
            '#show: setup.with(title: [Pacing])\n'
            '== First\n#pacing(2)\nA.\n#m.steps.pause\nB.\n'
            '== Second\n#pacing(3)\n#context [#metadata(str(state("sci-mosaic:clock", 0).get())) <clock>]\n'
        )
        run("compile", pacing, output / "pacing.pdf")
        observed = run("eval", "query(<clock>).map(it => it.value)", "--in", pacing)
        assert observed.strip() == '["5"]', observed

        # Invalid inputs fail with the package's own messages.
        test = deck / "errors.typ"
        preamble = f'#import "{spec}": *\n#import "@preview/mosaic:0.0.1" as m\n'
        for code, message in (
            ('#show: setup.with(palette: "missing")', "palette must be one of"),
            ('#show: setup.with(palette: 3)', "palette must be a name"),
            ('#show: setup.with(colors: 3)', "colors must be a dictionary"),
            ('#show: setup.with(title: [T])\n== S\n#callout(kind: "loud")[x]', "callout kind must be one of"),
            ('#show: setup.with(title: [T])\n== S\n#data-table()', "data-table requires"),
            ('#show: setup.with(title: [T])\n== S\n#data-table(("A", "B"), ("one",))', "same number of cells"),
            ('#show: setup.with(title: [T])\n== S\n#data-table(("A",), ("b",), highlight: (1,))', "data-table highlight must be"),
            ('#show: setup.with(title: [T])\n== S\n#conclusion-grid((label: [a], title: [b], body: [c]), highlight: 1)', "conclusion-grid highlight must be"),
            ('#show: setup.with(title: [T])\n== S\n#spec-list((term: [a]))', "must be a record with term and desc"),
            ('#show: setup.with(title: [T])\n== S\n#key-links(("only",))', "key-links entries must be"),
            ('#show: setup.with(title: [T])\n== S\n#pacing(-1)', "pacing minutes must be"),
            ('#show: setup.with(title: [T])\n== S\n#diagrams.canvas({}, 1)', "diagrams.canvas takes one body"),
            ('#show: setup.with(title: [T])\n#m.slide(grids.spread)[a][b][c][d]', "bodies to override them, received 4"),
            ('#show: setup.with(title: [T])\n#m.slide(grids.columns(0))[a]', "cell count must be a positive integer"),
            ('#show: setup.with(title: [T])\n#m.slide(grids.rows(1.5))[a]', "rows children must be auto"),
            ('#show: setup.with(title: [T])\n#m.slide(grids.columns())[a]', "columns must contain at least one child"),
            ('#show: setup.with(title: [T])\n#m.slide(grids.shape())[a]', "shape needs at least one row"),
            ('#show: setup.with(title: [T])\n#m.slide(grids.shape(0))[a]', "shape count must be a positive integer"),
            ('#show: setup.with(title: [T])\n#m.slide(grids.shape(2.5))[a]', "shape specs are integers"),
            ('#show: setup.with(title: [T])\n#m.slide(grids.shape(()))[a]', "shape split must contain at least one child"),
            ('#show: setup.with(title: [T])\n#m.slide(grids.shape(2, header: 1))[a]', "shape header must be true or false"),
        ):
            test.write_text(preamble + code)
            run("compile", test, tmp / "error.pdf", error=message)
        print("PASS brand palette, color overrides, pacing clock, invalid inputs")

        run("compile", "--format", "png", "--pages", "1", "--ppi", "96", entry, output / "cover.png")


if __name__ == "__main__":
    main()
