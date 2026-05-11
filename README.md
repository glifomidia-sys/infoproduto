# Digital Garden

Site público de notas usando Quartz + Obsidian, hospedado no GitHub Pages.

## Stack
- [Quartz v4](https://quartz.jzhao.xyz/) — gerador de site estático
- Obsidian — editor de notas
- GitHub Pages — hospedagem gratuita

## Estrutura
```
content/
├── index.md       # Homepage
├── proposta/      # Propostas
├── docs/          # Documentação
├── paginas/       # Páginas estratégicas
├── blog/          # Posts
└── assets/        # Imagens e arquivos
```

## Rodar localmente
```bash
# Dentro do WSL Ubuntu
export NVM_DIR=”$HOME/.nvm” && . “$NVM_DIR/nvm.sh”
cd /home/glifomidia/ebook
npx quartz build --serve
# Acesse: http://localhost:8080
```

## Publicar
```bash
git add content/
git commit -m “nova nota: nome-da-nota”
git push
# GitHub Actions publica automaticamente em ~1 min
```

## Convenção de nomenclatura
| Tipo     | Padrão                 | Exemplo                   |
|----------|------------------------|---------------------------|
| Notas    | `kebab-case.md`        | `como-usar-obsidian.md`   |
| Proposta | `proposta-nome.md`     | `proposta-freelance.md`   |
| Página   | `nome-descritivo.md`   | `sobre-mim.md`            |
| Blog     | `YYYY-MM-DD-titulo.md` | `2026-05-11-inicio.md`    |
