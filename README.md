# ragha 🦾

**Agente de IA local, grátis e privado pro MacBook Air M4/M5 (16GB RAM).**
Um "funcionário digital" que **pesquisa na internet antes de agir** (nunca inventa), executa tarefas passo-a-passo no seu Mac (arquivos, navegador, apps), **vê imagens** e roda 100% offline nos seus modelos — dentro do **Goose Desktop**.

## Por que
Modelos locais pequenos são "burros" sozinhos. O ragha compensa com um **harness**:
- **Sempre pesquisa** (DuckDuckGo) antes de responder → dados atuais, zero alucinação.
- **Doutrina passo-a-passo** que ensina o modelo como uma criança (uma ação por vez, prova com `cat`).
- **Rede anti-erro**: bloqueia comando destrutivo, força execução real (nada de "narrar"), confere o resultado.
- **Contexto 32k** pra caber pesquisa + ferramentas sem truncar.

## Instalação (1 clique)
```bash
git clone <este-repo> ragha && cd ragha && bash install.sh
```
Instala Homebrew, Ollama, uv, Goose Desktop, baixa os modelos e configura tudo. No fim roda a verificação de aceitação.

## Modelos (7B, uncensored, num_ctx 32768)
| Papel | Modelo | Pra quê |
|---|---|---|
| **Agente** (padrão) | `qwen25-16k` (Qwen2.5-7B abliterated) | tarefas multi-passo, ferramentas, ~28 tok/s |
| **Visão** (roteado) | `qwen25vl-32k` (Qwen2.5-VL-7B abliterated) | quando a tarefa envolve imagem/print/tela |

O harness troca pro modelo de visão **automaticamente** quando você cita imagem/foto/print/screenshot.

## Como usar
- **Goose Desktop** (o harness visual): abra, escolha `qwen25-16k`, modo **Autônomo** (Definições → Conversa). Digite a tarefa.
- **Terminal**: `agent "pesquise X e crie um resumo em /tmp/x.md"`

## Comandos úteis
- `ragha-acceptance` — bateria de aceitação (deve dar 100%).
- `agent-modelcheck <modelo>` — diagnostica qualquer modelo plugado (tools/visão/loop/velocidade).
- `mac browsers|open-url|traffic|organize|make-app` — controle do Mac.
- `agent-plug <modelo-ollama>` — pluga e auto-configura um novo modelo.

## Segurança
Mesmo no modo Autônomo, o **guardbin** bloqueia `sudo`, `rm -rf /`, `dd`, `mkfs`, `git push --force`. O agente age livre, mas não faz besteira irreversível.

## Requisitos
macOS (Apple Silicon M4/M5 recomendado), 16GB RAM, ~15GB de disco (modelos).

---
Grátis e open. Sem nuvem, sem conta, sem custo. Seus dados ficam no seu Mac.
