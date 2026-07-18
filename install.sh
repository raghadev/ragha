#!/usr/bin/env bash
# ██████╗  █████╗  ██████╗ ██╗  ██╗ █████╗
# ██╔══██╗██╔══██╗██╔════╝ ██║  ██║██╔══██╗
# ██████╔╝███████║██║  ███╗███████║███████║
# ██╔══██╗██╔══██║██║   ██║██╔══██║██╔══██║
# ██║  ██║██║  ██║╚██████╔╝██║  ██║██║  ██║
# ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝
# ragha — agente local grátis pro MacBook Air M4/M5 (16GB). Instalador 1-clique.
# Sempre pesquisa (nunca inventa), executa passo-a-passo, roda no Goose Desktop.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
say(){ printf "\033[35m▸\033[0m %s\n" "$1"; }
ok(){  printf "  \033[32m✓\033[0m %s\n" "$1"; }
warn(){ printf "  \033[33m!\033[0m %s\n" "$1"; }

echo "== ragha installer =="
# 0) checagens
[ "$(uname)" = "Darwin" ] || { echo "só roda no macOS"; exit 1; }
[ "$(uname -m)" = "arm64" ] || warn "não é Apple Silicon (M-series) — desempenho pode variar"
RAM=$(( $(sysctl -n hw.memsize) / 1073741824 ))
[ "$RAM" -ge 15 ] || warn "RAM=${RAM}GB (<16GB) — os modelos 7B cabem, mas feche apps pesados"
mkdir -p "$HOME/.local/bin" "$HOME/.config/goose/mcp" "$HOME/.config/agent/guardbin" \
         "$HOME/.config/goose/recipes" "$HOME/.agents/plugins"

# 1) Homebrew
if ! command -v brew >/dev/null 2>&1; then
  say "instalando Homebrew…"; /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || true)"; ok "Homebrew"

# 2) Ollama (formula, NAO cask — cask trava no Gatekeeper) + uv + coreutils(gtimeout)
say "instalando Ollama, uv, coreutils…"
brew list ollama   >/dev/null 2>&1 || brew install ollama
brew list coreutils>/dev/null 2>&1 || brew install coreutils
command -v uv >/dev/null 2>&1 || brew install uv
brew services start ollama >/dev/null 2>&1
for i in $(seq 1 30); do curl -s --max-time 2 http://localhost:11434/api/version >/dev/null 2>&1 && break; sleep 1; done
ok "Ollama no ar"; launchctl setenv OLLAMA_CONTEXT_LENGTH 32768 2>/dev/null

# 3) Goose Desktop (o harness visual)
if [ ! -d "/Applications/Goose.app" ]; then
  say "instalando Goose Desktop…"; brew install --cask block-goose 2>/dev/null || warn "instale o Goose Desktop manualmente: https://block.github.io/goose/"
fi
[ -d "/Applications/Goose.app" ] && ok "Goose Desktop"

# 4) Modelos (7B uncensored, num_ctx 32768) — agente + visão
say "baixando modelos (agente + visão, ~11GB)… pode demorar"
ollama pull huihui_ai/qwen2.5-abliterate:7b       && ollama create qwen25-16k   -f "$HERE/modelfiles/Modelfile.qwen25"   && ok "qwen25-16k (agente)"
ollama pull huihui_ai/qwen2.5-vl-abliterated:7b   && ollama create qwen25vl-32k -f "$HERE/modelfiles/Modelfile.qwen25vl" && ok "qwen25vl-32k (visão)"

# 5) Arquivos do harness
say "instalando o harness…"
cp "$HERE"/bin/*                   "$HOME/.local/bin/"           && chmod +x "$HOME/.local/bin/"* 2>/dev/null
cp "$HERE"/config/config.yaml      "$HOME/.config/goose/config.yaml"
cp "$HERE"/config/.goosehints      "$HOME/.config/goose/.goosehints"
cp -r "$HERE"/mcp/mactools         "$HOME/.config/goose/mcp/" 2>/dev/null
cp -r "$HERE"/hooks/ragha-guard    "$HOME/.agents/plugins/"   2>/dev/null
cp "$HERE"/guardbin/*              "$HOME/.config/agent/guardbin/" 2>/dev/null && chmod +x "$HOME/.config/agent/guardbin/"* 2>/dev/null
cp "$HERE"/recipes/*.yaml          "$HOME/.config/goose/recipes/" 2>/dev/null
cp "$HERE"/config/config.yaml      "$HOME/.config/agent/config.canonical.yaml"
grep -q '.local/bin' <<<"$PATH" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
ok "harness instalado"

# 6) Verificação (aceitação 100%)
say "rodando verificação…"
export PATH="$HOME/.local/bin:/opt/homebrew/bin:$PATH"
if command -v ragha-acceptance >/dev/null 2>&1; then
  ragha-acceptance || warn "verificação não 100% — rode 'ragha-acceptance' após reiniciar o Ollama"
fi

echo
echo "== ragha instalado =="
echo "  • Abra o Goose Desktop. Modelo agente: qwen25-16k. Visão: qwen25vl-32k."
echo "  • No Desktop: Definições → Conversa → modo 'Autônomo' (sem pedir permissão)."
echo "  • Terminal: 'agent \"sua tarefa\"' — ele pesquisa e resolve sozinho."
