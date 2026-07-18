#!/usr/bin/env bash
# Stop hook: forca execucao só se NARROU tool call como texto. Conservador p/ nao
# bloquear codigo legitimo que o usuario pediu (```python sozinho NAO conta).
payload="$(cat)"
msg="$(printf '%s' "$payload" | /usr/bin/jq -r '.last_assistant_message // empty' 2>/dev/null)"
[ -z "$msg" ] && exit 0
# assinaturas de tool-call narrado (nao de codigo pedido pelo usuario)
if printf '%s' "$msg" | grep -qE 'shell\(command=|default_api\.|print\(default_api|tool_code|functions\.[a-z_]+\(|```tool_code'; then
  printf '{"decision":"block","reason":"Voce escreveu a chamada de ferramenta como TEXTO mas NAO executou. Continue AGORA: chame a ferramenta de verdade e mostre a saida real. Nao invente resultado."}'
fi
exit 0
