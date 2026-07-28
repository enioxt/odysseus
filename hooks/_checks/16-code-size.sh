#!/bin/sh
# EGOS Pre-Commit — Code File Size (R3.4 vira GATE → R-REFACTOR-ORG-001). WARN-only (calibragem progressiva).
#
# POR QUE EXISTE: R3.4 (">300 LOC → refatorar") vivia só como TEXTO no CLAUDE.md/AGENTS.md,
# sem enforcement — por isso analisar_caso.py (intelink) chegou a 6232 linhas sem nada disparar.
# Infra de tamanho existia só p/ DOC (03-doc-size.sh: TASKS/AGENTS). Este espelha p/ CÓDIGO.
#
# CONST-DESIGN (M1, cortes Enio 2026-07-22 + reconciliação 2026-07-23):
#   direção  = "regra de tamanho de código vira gate + disseminar a todos os repos" (Enio)
#   desenho  = WARN agora → BLOCK depois · teto ÚNICO 600/1200 · mede STAGED · só avisa quem CRESCE/CRUZA
#
# LIMIAR CANÔNICO (SSOT): docs/governance/RULE_GATE_MAP.yaml id R3.4-CODE-SIZE-001 = 600 warn / 1200 hard.
#   Fontes reconciliadas p/ o MESMO número: .guarani/PREFERENCES.md · AGENTS.md §R3 item 4 · scripts/bloat-scan.ts.
#   Audit repo-wide (todos os gordos, não só staged): `bun scripts/bloat-scan.ts`.
#
# DESENHO (correções da review Codex+Banda 2026-07-23):
#   - mede o BLOB STAGED (git show :file), não o working tree — o que de fato será commitado.
#   - só sinaliza quando o arquivo CRESCEU neste commit E está acima do teto (new>old && new>WARN);
#     tocar/encolher um arquivo já-gordo NÃO avisa (evita banner-blindness — o kernel tem 12 gordos legados).
#
# BLOCK depois: quando os motores gordos forem refatorados (RULE-HARDEN-CODE-SIZE-001),
# trocar o `exit 0` do ramo HARD por `exit 1` — decisão humana logada.

WARN=${EGOS_CODE_SIZE_WARN:-600}
HARD=${EGOS_CODE_SIZE_HARD:-1200}

FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null \
  | grep -iE '\.(py|ts|tsx|js|jsx|go|rs)$' \
  | grep -viE '(^|/)(node_modules|dist|build|\.next|vendor|migrations|__generated__|_archived)/|\.min\.js$|\.d\.ts$|_pb2\.py$')

[ -z "$FILES" ] && exit 0

_hit=0
for f in $FILES; do
  # tamanho STAGED (o que vai pro commit), não o working tree
  new=$(git show ":$f" 2>/dev/null | wc -l | tr -d ' ')
  [ -z "$new" ] && continue
  # tamanho no HEAD (0 se arquivo novo)
  old=$(git show "HEAD:$f" 2>/dev/null | wc -l | tr -d ' ')
  [ -z "$old" ] && old=0
  # só pune crescimento acima do teto — encolher um gordo ou tocar sem crescer passa silencioso
  [ "$new" -le "$old" ] && continue
  if [ "$new" -gt "$HARD" ]; then
    echo "  🚨 CODE-SIZE: $f = $new linhas (>$HARD, era $old). Refatore (R-REFACTOR-ORG-001): quebra orgânica, extrai motor comum (2+ consumidores)."
    _hit=1
  elif [ "$new" -gt "$WARN" ]; then
    echo "  ⚠️  CODE-SIZE: $f = $new linhas (>$WARN, era $old). Quebra no meio do caminho (R-REFACTOR-ORG-001) antes de crescer mais."
    _hit=1
  fi
done

[ "$_hit" = 1 ] && echo "  ℹ️  code-size é WARN (calibragem) — vira BLOCK quando os gordos forem quebrados (RULE-HARDEN-CODE-SIZE-001). Audit: bun scripts/bloat-scan.ts"
exit 0
