#!/usr/bin/env bash
payload="$(cat)"
cmd="$(printf '%s' "$payload" | /usr/bin/jq -r '.tool_input.command // .matcher_context // empty' 2>/dev/null)"
[ -z "$cmd" ] && exit 0
block(){ printf '{"decision":"block","reason":"%s"}' "$1"; exit 0; }
printf '%s' "$cmd" | grep -qE '(^|[;&| ])sudo ' && block "guardbin: agente nao usa sudo"
if printf '%s' "$cmd" | grep -qE 'rm[[:space:]]+-[a-zA-Z]*[rR]'; then
  printf '%s' "$cmd" | grep -qE '(rm[^\n]* )(/|/Users|/Users/carvalho|~|\$HOME|/System|/Library|/Applications|/opt|/usr|/bin|/etc|/var|/private)([[:space:]]|/\*|\*|$)' && block "guardbin: rm -r em caminho perigoso"
fi
printf '%s' "$cmd" | grep -qE 'dd[^\n]* of=/dev/' && block "guardbin: dd em disco"
printf '%s' "$cmd" | grep -qE '\b(mkfs|newfs)\b|diskutil[^\n]* (erase|reformat)' && block "guardbin: formatar disco"
printf '%s' "$cmd" | grep -qE 'git[^\n]* push' && printf '%s' "$cmd" | grep -qE ' (--force|--force-with-lease|-f)\b' && block "guardbin: git push --force"
exit 0
