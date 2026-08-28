C3C ?= c3c
D2 ?= d2
TYPST ?= typst

DOCS_DIR := docs
D2_SRCS := $(wildcard $(DOCS_DIR)/*.d2)
SVGS := $(D2_SRCS:.d2=.svg)
TYPS := $(wildcard $(DOCS_DIR)/*.typ)
PDFS := $(TYPS:.typ=.pdf)

.DEFAULT_GOAL := build

.PHONY: build docs all clean

build:
	$(C3C) build calc3

docs: $(SVGS) $(PDFS)
	@echo "Documentation built: $(PDFS)"

%.svg: %.d2
	$(D2) $< $@

%.pdf: %.typ
	$(TYPST) compile $< $@

all: build docs

clean:
	rm -rf build
