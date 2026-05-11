#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
#  Build script — "Achar Não é Ter Certeza"
#  Uso: ./build.sh [pdf|html|all|clean]
# ─────────────────────────────────────────────────────────────────────────────

TARGET="${1:-pdf}"
OUTPUT_PDF="achar-nao-e-ter-certeza.pdf"
OUTPUT_HTML="achar-nao-e-ter-certeza.html"
COMBINED="build/ebook-combined.md"
SOURCE="ebook.md"
METADATA="styles/metadata.yaml"
CUSTOM_LATEX="styles/custom.latex"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'

banner() { echo -e "${CYAN}━━━ $1 ━━━${NC}"; }
ok()     { echo -e "${GREEN}  ✓ $1${NC}"; }
info()   { echo -e "${YELLOW}  · $1${NC}"; }
fail()   { echo -e "${RED}  ✗ $1${NC}"; exit 1; }

# ── Verificar dependências ────────────────────────────────────────────────────
check_dep() { command -v "$1" &>/dev/null || fail "'$1' não encontrado. Execute ./setup.sh"; }

# ── Processar !include ────────────────────────────────────────────────────────
process_includes() {
    mkdir -p build
    > "$COMBINED"
    while IFS= read -r line; do
        if [[ "$line" =~ ^!include[[:space:]]+(.*) ]]; then
            f="${BASH_REMATCH[1]}"
            [[ -f "$f" ]] || fail "Arquivo não encontrado: $f"
            cat "$f" >> "$COMBINED"
            echo "" >> "$COMBINED"
        else
            echo "$line" >> "$COMBINED"
        fi
    done < "$SOURCE"
    ok "Capítulos processados ($(wc -l < "$COMBINED") linhas)"
}

# ── Build PDF ─────────────────────────────────────────────────────────────────
build_pdf() {
    banner "Gerando PDF"
    check_dep pandoc
    check_dep xelatex

    process_includes
    info "Compilando com XeLaTeX..."

    HEADER_ARGS=()
    [[ -f "$CUSTOM_LATEX" ]] && HEADER_ARGS=(--include-in-header="$CUSTOM_LATEX")

    pandoc "$COMBINED" \
        --metadata-file="$METADATA" \
        --template=eisvogel \
        --pdf-engine=xelatex \
        --highlight-style=tango \
        --number-sections \
        -V classoption=oneside \
        "${HEADER_ARGS[@]}" \
        -o "$OUTPUT_PDF"

    [[ -f "$OUTPUT_PDF" ]] || fail "Falha ao gerar o PDF."
    SIZE=$(du -sh "$OUTPUT_PDF" | cut -f1)
    ok "PDF: ${OUTPUT_PDF} (${SIZE})"
}

# ── Build HTML ────────────────────────────────────────────────────────────────
build_html() {
    banner "Gerando HTML"
    check_dep pandoc

    process_includes
    info "Compilando HTML..."

    pandoc "$COMBINED" \
        --metadata-file="$METADATA" \
        --template=styles/ebook-template.html \
        --standalone \
        --toc \
        --toc-depth=2 \
        --section-divs \
        --highlight-style=tango \
        -o "$OUTPUT_HTML"

    [[ -f "$OUTPUT_HTML" ]] || fail "Falha ao gerar o HTML."
    ok "HTML: ${OUTPUT_HTML}"
}

# ── Clean ─────────────────────────────────────────────────────────────────────
clean() {
    banner "Limpando build"
    rm -rf build/ "$OUTPUT_PDF" "$OUTPUT_HTML"
    ok "Diretórios de build removidos"
}

# ── Dispatcher ────────────────────────────────────────────────────────────────
echo -e "${CYAN}📖 Achar Não é Ter Certeza — Build System${NC}"
echo ""

case "$TARGET" in
    pdf)   build_pdf ;;
    html)  build_html ;;
    all)   build_pdf; build_html ;;
    clean) clean ;;
    *)     echo "Uso: ./build.sh [pdf|html|all|clean]"; exit 1 ;;
esac

echo ""
echo -e "${GREEN}✓ Concluído.${NC}"
