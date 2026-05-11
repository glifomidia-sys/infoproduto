#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
#  setup.sh — Instala todas as dependências do projeto sem sudo
#  Testado em: Ubuntu/Debian (WSL2, nativo), macOS
# ─────────────────────────────────────────────────────────────────────────────

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'

ok()   { echo -e "${GREEN}  ✓ $1${NC}"; }
info() { echo -e "${YELLOW}  · $1${NC}"; }
fail() { echo -e "${RED}  ✗ $1${NC}"; exit 1; }
banner(){ echo -e "\n${CYAN}━━━ $1 ━━━${NC}"; }

PANDOC_VER="3.6.4"
mkdir -p ~/bin ~/tmp ~/.local/share/pandoc/templates ~/.local/share/fonts

export PATH="$HOME/bin:$HOME/.TinyTeX/bin/x86_64-linux:$HOME/.local/bin:$PATH"

# ── 1. Pandoc ─────────────────────────────────────────────────────────────────
banner "Pandoc"
if command -v pandoc &>/dev/null && pandoc --version | grep -q "$PANDOC_VER"; then
    ok "Pandoc ${PANDOC_VER} já instalado"
else
    info "Baixando Pandoc ${PANDOC_VER}..."
    curl -fsSL "https://github.com/jgm/pandoc/releases/download/${PANDOC_VER}/pandoc-${PANDOC_VER}-linux-amd64.tar.gz" \
        -o ~/tmp/pandoc.tar.gz
    tar -xzf ~/tmp/pandoc.tar.gz -C ~/tmp
    cp ~/tmp/pandoc-${PANDOC_VER}/bin/pandoc ~/bin/pandoc
    chmod +x ~/bin/pandoc
    ok "Pandoc instalado: $(pandoc --version | head -1)"
fi

# ── 2. TinyTeX (XeLaTeX) ─────────────────────────────────────────────────────
banner "TinyTeX (XeLaTeX)"
if command -v xelatex &>/dev/null; then
    ok "XeLaTeX já instalado: $(xelatex --version | head -1)"
else
    info "Instalando TinyTeX (pode levar alguns minutos)..."
    curl -fsSL https://yihui.org/tinytex/install-bin-unix.sh | sh
    ok "TinyTeX instalado"
fi

# ── 3. Pacotes LaTeX ─────────────────────────────────────────────────────────
banner "Pacotes LaTeX"
PKGS=(
    xetex fontspec adjustbox babel-german background bidi collectbox
    csquotes everypage filehook footmisc framed fvextra koma-script
    letltxmacro ly1 mdframed mweights needspace pagecolor sourcecodepro
    sourcesans titling ucharcat ulem unicode-math upquote xecjk xurl
    zref microtype setspace caption colortbl listings tcolorbox etoolbox
    booktabs longtable enumitem babel-portuges hyphen-portuguese
)

for pkg in "${PKGS[@]}"; do
    result=$(tlmgr install "$pkg" 2>&1)
    if echo "$result" | grep -qE "already installed"; then
        echo -n "."
    else
        echo -n "+"
    fi
done
echo ""
ok "Pacotes LaTeX verificados"

# ── 4. Template Eisvogel ─────────────────────────────────────────────────────
banner "Template Eisvogel"
if [[ -f ~/.local/share/pandoc/templates/eisvogel.latex ]]; then
    ok "Eisvogel já instalado"
else
    info "Baixando Eisvogel..."
    curl -fsSL "https://github.com/Wandmalfarbe/pandoc-latex-template/releases/download/v3.4.0/Eisvogel.tar.gz" \
        -o ~/tmp/eisvogel.tar.gz
    tar -xzf ~/tmp/eisvogel.tar.gz -C ~/tmp/
    cp ~/tmp/Eisvogel-3.4.0/eisvogel.latex ~/.local/share/pandoc/templates/
    ok "Eisvogel instalado"
fi

# ── 5. Fontes ─────────────────────────────────────────────────────────────────
banner "Fontes (Inter + Playfair Display)"

install_inter() {
    if fc-list | grep -qi "^.*Inter-Regular"; then
        ok "Inter já instalada"
        return
    fi
    info "Baixando Inter..."
    curl -fsSL "https://github.com/rsms/inter/releases/download/v4.0/Inter-4.0.zip" \
        -o ~/tmp/inter.zip
    python3 - <<'EOF'
import zipfile, os
with zipfile.ZipFile(os.path.expanduser("~/tmp/inter.zip")) as z:
    z.extractall(os.path.expanduser("~/tmp/inter"))
EOF
    find ~/tmp/inter -name "Inter-*.ttf" | xargs -I{} cp {} ~/.local/share/fonts/
    ok "Inter instalada"
}

install_playfair() {
    if fc-list | grep -qi "PlayfairDisplay-Regular"; then
        ok "Playfair Display já instalada (estática)"
        return
    fi

    # Verificar fonttools
    if ! python3 -c "import fontTools" 2>/dev/null; then
        info "Instalando fonttools..."
        curl -fsSL https://bootstrap.pypa.io/get-pip.py -o ~/tmp/get-pip.py
        python3 ~/tmp/get-pip.py --user --break-system-packages --quiet
        ~/.local/bin/pip install fonttools --break-system-packages --quiet
    fi

    info "Baixando e instanciando Playfair Display..."
    curl -fsSL "https://raw.githubusercontent.com/google/fonts/main/ofl/playfairdisplay/PlayfairDisplay%5Bwght%5D.ttf" \
        -o ~/tmp/pfd-var.ttf
    curl -fsSL "https://raw.githubusercontent.com/google/fonts/main/ofl/playfairdisplay/PlayfairDisplay-Italic%5Bwght%5D.ttf" \
        -o ~/tmp/pfd-italic-var.ttf

    python3 - <<'EOF'
from fontTools.varLib.instancer import instantiateVariableFont
from fontTools.ttLib import TTFont
import os

fd = os.path.expanduser("~/.local/share/fonts")
instances = [
    ("~/tmp/pfd-var.ttf",        400, "PlayfairDisplay-Regular.ttf"),
    ("~/tmp/pfd-var.ttf",        700, "PlayfairDisplay-Bold.ttf"),
    ("~/tmp/pfd-var.ttf",        900, "PlayfairDisplay-Black.ttf"),
    ("~/tmp/pfd-italic-var.ttf", 400, "PlayfairDisplay-Italic.ttf"),
    ("~/tmp/pfd-italic-var.ttf", 700, "PlayfairDisplay-BoldItalic.ttf"),
]
for src, wght, name in instances:
    font = TTFont(os.path.expanduser(src))
    inst = instantiateVariableFont(font, {"wght": wght})
    inst.save(os.path.join(fd, name))
    print(f"  ✓ {name}")
EOF
    ok "Playfair Display instalada"
}

install_inter
install_playfair

# Remover variáveis se existirem
rm -f ~/.local/share/fonts/PlayfairDisplay.ttf \
      ~/.local/share/fonts/PlayfairDisplay-Italic-variable.ttf \
      ~/.local/share/fonts/InterVariable.ttf \
      ~/.local/share/fonts/InterVariable-Italic.ttf 2>/dev/null || true

fc-cache -f ~/.local/share/fonts
ok "Cache de fontes atualizado"

# ── 6. Verificação final ──────────────────────────────────────────────────────
banner "Verificação"
echo ""
pandoc --version | head -1 | xargs -I{} echo -e "  ${GREEN}✓${NC} {}"
xelatex --version | head -1 | xargs -I{} echo -e "  ${GREEN}✓${NC} {}"
[[ -f ~/.local/share/pandoc/templates/eisvogel.latex ]] && \
    echo -e "  ${GREEN}✓${NC} Eisvogel template"
fc-list | grep -qi "Inter-Regular" && echo -e "  ${GREEN}✓${NC} Inter" || echo -e "  ${RED}✗${NC} Inter"
fc-list | grep -qi "PlayfairDisplay-Regular" && echo -e "  ${GREEN}✓${NC} Playfair Display" || echo -e "  ${RED}✗${NC} Playfair Display"

echo ""
echo -e "${GREEN}━━━ Setup concluído. Rode: ./build.sh ━━━${NC}"
echo ""
