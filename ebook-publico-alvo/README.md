# Achar Não é Ter Certeza — Defina seu público-alvo

**Autor:** Jean Victor Paradella
**Formato:** Markdown → PDF (via Pandoc + Eisvogel)

---

## Identidade visual (Brandbook)

| Elemento | Valor |
|---|---|
| Cor de fundo da capa | `#0F0F0F` (Noir) |
| Cor primária / âmbar | `#C49A1E` |
| Destaque capa | `#E8D5A3` (Dourado) |
| Fundo páginas internas | `#FAFAF8` (Off-white) |
| Fonte display | Playfair Display 900 |
| Fonte corpo | Inter 400 · 15px · line-height 1.75 |

---

## Estrutura do projeto

```
ebook-publico-alvo/
├── chapters/
│   ├── 01-introducao.md
│   ├── 02-pratica1.md      — Observe as perguntas que mais se repetem
│   ├── 03-pratica2.md      — Vá além dos dados demográficos
│   ├── 04-pratica3.md      — Dê um rosto ao seu cliente ideal
│   ├── 05-pratica4.md      — Valide antes de assumir
│   ├── 06-pratica5.md      — Mapeie as dores e os desejos reais
│   ├── 07-pratica6.md      — Entenda a jornada do cliente
│   ├── 08-pratica7.md      — Monitore, ajuste e refine
│   └── 09-conclusao.md
├── assets/
│   └── images/
├── styles/
│   └── metadata.yaml       — Metadados, cores e tipografia
├── build/                  — Gerado automaticamente
├── ebook.md                — Arquivo principal (agrega capítulos)
├── build.sh                — Script de build
└── README.md
```

---

## Pré-requisitos

### 1. Instalar Pandoc

**Ubuntu/Debian:**
```bash
sudo apt-get update && sudo apt-get install pandoc
```

**macOS:**
```bash
brew install pandoc
```

**Windows:** https://pandoc.org/installing.html

---

### 2. Instalar LaTeX (XeLaTeX)

**Ubuntu/Debian — instalação mínima:**
```bash
sudo apt-get install texlive-xetex texlive-fonts-recommended \
  texlive-fonts-extra texlive-lang-portuguese
```

**Ubuntu/Debian — instalação completa (recomendado):**
```bash
sudo apt-get install texlive-full
```

**macOS:**
```bash
brew install --cask mactex
```

---

### 3. Instalar o template Eisvogel

```bash
mkdir -p ~/.local/share/pandoc/templates

curl -o ~/.local/share/pandoc/templates/eisvogel.latex \
  https://raw.githubusercontent.com/Wandmalfarbe/pandoc-latex-template/master/eisvogel.latex
```

---

### 4. Instalar as fontes do brandbook (opcional, recomendado)

O e-book usa **Playfair Display** (títulos) e **Inter** (corpo). Se não estiverem instaladas, o `build.sh` usa automaticamente Georgia e Arial como fallback.

**Ubuntu/Debian:**
```bash
# Baixar e instalar as fontes
mkdir -p ~/.local/share/fonts

# Inter
curl -L https://github.com/rsms/inter/releases/download/v4.0/Inter-4.0.zip \
  -o /tmp/inter.zip && unzip /tmp/inter.zip -d /tmp/inter \
  && cp /tmp/inter/**/*.ttf ~/.local/share/fonts/

# Playfair Display (via Google Fonts)
# Acesse fonts.google.com/specimen/Playfair+Display e instale manualmente,
# ou use o pacote do sistema:
sudo apt-get install fonts-gfs-artemisia  # aproximação serif elegante

fc-cache -fv
```

---

## Gerando o PDF

```bash
cd ebook-publico-alvo
./build.sh
```

O arquivo `achar-nao-e-ter-certeza.pdf` será gerado na raiz do projeto.

---

## Personalização

### Alterar cores no `styles/metadata.yaml`

```yaml
titlepage-color: "0F0F0F"      # Fundo da capa (hex sem #)
titlepage-rule-color: "C49A1E" # Linha decorativa (âmbar)
linkcolor: "C49A1E"            # Links no PDF
```

### Adicionar imagens

```markdown
![Descrição](assets/images/nome.png){ width=80% }
```

---

## Troubleshooting

**`template eisvogel not found`**
Verifique se `~/.local/share/pandoc/templates/eisvogel.latex` existe.

**`xelatex not found`**
Certifique-se de que o TeX Live está instalado e no PATH.

**Fonte não encontrada**
O `build.sh` detecta automaticamente e usa fallback (Georgia/Arial).
Para verificar fontes instaladas: `fc-list | grep -i "inter"`

**PDF sem sumário**
Verifique se `toc: true` está em `styles/metadata.yaml`.

---

## Licença

Conteúdo de autoria de **Jean Victor Paradella**. Todos os direitos reservados.
