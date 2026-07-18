#!/usr/bin/env bash
# SessionEnd: manutencao leve da memoria em background (nao bloqueia).
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/bin:/bin"
( agent-mem consolidate >/dev/null 2>&1 & ) >/dev/null 2>&1
exit 0
