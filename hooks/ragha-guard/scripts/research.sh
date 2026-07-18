#!/usr/bin/env bash
# UserPromptSubmit: escreve pesquisa web fresca em moim.txt. O binario Goose patchado
# injeta esse arquivo no system prompt do turno. Vale CLI e Desktop.
payload="$(cat)"
msg="$(printf '%s' "$payload" | /usr/bin/jq -r '.message // .matcher_context // empty' 2>/dev/null)"
MOIM="$HOME/.config/agent/moim.txt"; mkdir -p "$(dirname "$MOIM")"
: > "$MOIM"   # limpa (evita contexto velho)
[ -z "$msg" ] && exit 0
# SEMPRE pesquisa (meta: nunca inventar). Pula SO op local trivial pura.
skip=0
printf '%s' "$msg" | grep -qiE '^(liste?|mostr|exib|apag|delet|remov|abra|feche|rode|execute) ' \
  && ! printf '%s' "$msg" | grep -qiE "como|porque|melhor|atual|versao|pesquis|explica|o que|resumo|conteudo|sobre " \
  && skip=1
if [ "$skip" = "0" ]; then
  # limpa a query: tira instrucoes de formato/comando que poluem a busca
  q="$(printf '%s' "$msg" | sed -E 's/responda[^.]*//Ig; s/escreva[^.]*//Ig; s/(so |apenas |somente )?(o |a )?(numero|nome|texto|valor)( principal)?//Ig; s/ em \/[^ ]+//g; s/[[:space:]]+/ /g' | cut -c1-140)"
  RES="$("$HOME/.local/bin/uv" run --quiet --with ddgs --with httpx --with beautifulsoup4 python "$HOME/.local/bin/agent-research" "$q" 3 2>/dev/null)"
  [ -n "$RES" ] && printf '%s' "$RES" > "$MOIM"
fi
exit 0
