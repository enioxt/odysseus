#!/bin/sh
# EGOS-LEAF-KIT — Pre-Commit Check 01 — Secret Scanning
# Generalizado de um check já rodado em produção num leaf desta frota (ADOPT-BEFORE-BUILD,
# self-contained). Detecta chaves de API e secrets antes do commit. Usa gitleaks SE
# estiver instalado (opcional) + grep de padrões conhecidos de secret (sempre disponível).
#
# v1.2: escaneia o CONTEÚDO STAGED (git show ":$FILE", o blob no índice), não o
# working-tree. Antes, o check listava os nomes dos arquivos staged mas dava grep no
# arquivo do working-tree — podia (a) PERDER um secret que está staged mas já foi
# removido/editado no working-tree, e (b) FLAGAR um secret que está só no working-tree
# e nunca vai ser commitado. `git show ":$FILE"` lê exatamente o que será commitado.

CHECK_PASSED=1

# Gitleaks (se instalado — opcional, não é dependência obrigatória).
# NOTA: usa o EXIT CODE do gitleaks (0=limpo, 1=leak), não grep no texto do log —
# a mensagem de sucesso é "no leaks found", que contém a substring "leaks found" e
# faria grep textual disparar falso-positivo em TODO commit limpo.
if command -v gitleaks > /dev/null 2>&1; then
  GITLEAKS_OUT=$(gitleaks protect --staged --redact --no-banner 2>&1)
  GITLEAKS_EXIT=$?
  if [ "$GITLEAKS_EXIT" != "0" ]; then
    echo "❌ Gitleaks: secrets detectados. Remova antes de commitar."
    echo "$GITLEAKS_OUT" | sed 's/^/     /'
    CHECK_PASSED=0
  fi
fi

# Padrões de secret conhecidos — escaneia o BLOB STAGED de cada arquivo de código/texto
# (não o working-tree).
STAGED_CODE=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(ts|tsx|js|jsx|py|sh|env|json)$' | grep -v '\.example$' | grep -v 'test' || true)
if [ -n "$STAGED_CODE" ]; then
  for pattern in 'sk-or-[a-zA-Z0-9_-]{20,}' 'sk-ant-[a-zA-Z0-9_-]{20,}' 'AIza[a-zA-Z0-9_-]{30,}' 'eyJhbGciOi[a-zA-Z0-9._-]{30,}' 'sbp_[a-zA-Z0-9]{20,}' 'ghp_[a-zA-Z0-9]{20,}' 'xoxb-[a-zA-Z0-9-]{10,}'; do
    for FILE in $STAGED_CODE; do
      STAGED_CONTENT=$(git show ":$FILE" 2>/dev/null || true)
      if [ -n "$STAGED_CONTENT" ] && echo "$STAGED_CONTENT" | grep -qE "$pattern"; then
        echo "❌ Padrão de secret detectado ($pattern) em $FILE (conteúdo staged). Use variável de ambiente."
        CHECK_PASSED=0
      fi
    done
  done
fi

[ "$CHECK_PASSED" = "1" ] && echo "  [01-secrets] clean ✅"
[ "$CHECK_PASSED" = "1" ] && exit 0
exit 1
