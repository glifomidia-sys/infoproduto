# ─────────────────────────────────────────────────────────────────────────────
#  Makefile — "Achar Não é Ter Certeza"
#  Uso: make [pdf|html|all|clean|setup|watch]
# ─────────────────────────────────────────────────────────────────────────────

SHELL := /bin/bash
PATH  := $(HOME)/bin:$(HOME)/.TinyTeX/bin/x86_64-linux:$(HOME)/.local/bin:$(PATH)

OUTPUT_PDF  := achar-nao-e-ter-certeza.pdf
OUTPUT_HTML := achar-nao-e-ter-certeza.html
CHAPTERS    := $(sort $(wildcard chapters/*.md))
METADATA    := styles/metadata.yaml
CUSTOM_TEX  := styles/custom.latex

.PHONY: all pdf html clean setup watch help

# Default
all: pdf html

## Gera o PDF (padrão)
pdf: $(OUTPUT_PDF)

$(OUTPUT_PDF): $(CHAPTERS) $(METADATA) $(CUSTOM_TEX) ebook.md
	@export PATH="$(PATH)" && ./build.sh pdf

## Gera o HTML
html: $(OUTPUT_HTML)

$(OUTPUT_HTML): $(CHAPTERS) $(METADATA) ebook.md
	@export PATH="$(PATH)" && ./build.sh html

## Gera PDF e HTML
all: pdf html

## Remove arquivos gerados
clean:
	@./build.sh clean

## Instala todas as dependências
setup:
	@./setup.sh

## Rebuild automático ao salvar qualquer .md ou .yaml
watch:
	@command -v inotifywait &>/dev/null || { echo "Instale inotify-tools: sudo apt install inotify-tools"; exit 1; }
	@echo "Observando alterações... (Ctrl+C para parar)"
	@while inotifywait -qre modify chapters/ styles/ ebook.md 2>/dev/null; do \
		echo "Mudança detectada — rebuilding PDF..."; \
		$(MAKE) pdf; \
	done

## Exibe ajuda
help:
	@echo ""
	@echo "  make pdf     — Gera o PDF"
	@echo "  make html    — Gera o HTML"
	@echo "  make all     — Gera PDF + HTML"
	@echo "  make clean   — Remove arquivos gerados"
	@echo "  make setup   — Instala dependências"
	@echo "  make watch   — Rebuild automático ao salvar"
	@echo ""
