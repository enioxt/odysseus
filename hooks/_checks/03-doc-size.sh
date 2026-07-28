#!/bin/sh
# EGOS Pre-Commit Check 03 — SSOT File Size Limits
# Avisa quando TASKS.md, AGENTS.md ou outros SSOTs ficam grandes demais

# SSOT: CLAUDE.md §"Colocação de docs" — "TASKS 600 hard (arquive em 400) · AGENTS 400".
# Alinhado 2026-07-26 (corte Enio). Antes: TASKS 500/900 e AGENTS 350/500 aqui, contra
# AGENTS 200 / TASKS 500 no ci.yml e 400/600 no CLAUDE.md — três fontes, três números para
# o mesmo arquivo, num par de gates cujo nome é "doc-size"/"SSOT drift".
LIMITS_TASKS_WARN=400
LIMITS_TASKS_HARD=600
LIMITS_AGENTS_WARN=350
LIMITS_AGENTS_HARD=400

if [ -f "TASKS.md" ]; then
  LINES=$(wc -l < TASKS.md)
  if [ "$LINES" -gt "$LIMITS_TASKS_HARD" ]; then
    echo "  🚨 TASKS.md: $LINES linhas (>$LIMITS_TASKS_HARD HARD LIMIT). Arquive concluídos."
  elif [ "$LINES" -gt "$LIMITS_TASKS_WARN" ]; then
    echo "  ⚠️  TASKS.md: $LINES linhas (>$LIMITS_TASKS_WARN warn). Considere arquivar."
  fi
fi

if [ -f "AGENTS.md" ]; then
  LINES=$(wc -l < AGENTS.md)
  if [ "$LINES" -gt "$LIMITS_AGENTS_HARD" ]; then
    echo "  🚨 AGENTS.md: $LINES linhas (>$LIMITS_AGENTS_HARD HARD). Compress manual."
  elif [ "$LINES" -gt "$LIMITS_AGENTS_WARN" ]; then
    echo "  ⚠️  AGENTS.md: $LINES linhas. Compress quando puder."
  fi
fi

# Não bloqueia
exit 0