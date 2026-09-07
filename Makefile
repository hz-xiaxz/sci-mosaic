# Development helpers. The tests install the working tree into a temporary
# package path and compile against `@preview/sci-mosaic:0.1.0`, so the sources
# never need to be published to be exercised.
TYPST ?= typst
VERSION := $(shell sed -n 's/^version = "\(.*\)"/\1/p' typst.toml)
PACKAGES := $(CURDIR)/.packages
LOCAL := $(HOME)/.local/share/typst/packages/local/sci-mosaic

.PHONY: check previews install uninstall clean

check:
	python3 tests/check.py --typst $(TYPST)

# Compile the starter and the gallery into previews/ for a quick look.
previews:
	mkdir -p $(PACKAGES)/preview/sci-mosaic previews
	ln -sfn $(CURDIR) $(PACKAGES)/preview/sci-mosaic/$(VERSION)
	$(TYPST) compile --package-path $(PACKAGES) template/main.typ previews/starter.pdf
	$(TYPST) compile --package-path $(PACKAGES) gallery.typ previews/gallery.pdf

# Make the working tree importable as `@local/sci-mosaic:$(VERSION)`.
install:
	mkdir -p $(LOCAL)
	ln -sfn $(CURDIR) $(LOCAL)/$(VERSION)

uninstall:
	rm -f $(LOCAL)/$(VERSION)

clean:
	rm -rf previews $(PACKAGES)
