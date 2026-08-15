#!/bin/sh
# EGOS-LEAF-KIT — bloqueia commit se houver marcadores de merge não resolvidos em
# arquivos staged. Generalizado de um check já rodado em produção num leaf desta frota
# (self-contained).
#
# v1.1: escaneia o CONTEÚDO STAGED (git show ":$FILE", o blob no índice), não o
# working-tree — mesma técnica de 01-secrets.sh v1.2. Antes, o check listava os
# nomes dos arquivos staged mas dava grep no arquivo do working-tree — podia (a)
# PERDER um marcador de conflito que está staged mas já foi removido/editado no
# working-tree, e (b) FLAGAR um marcador que está só no working-tree e nunca vai
# ser commitado. `git show ":$FILE"` lê exatamente o que será commitado.

STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null || true)
[ -z "$STAGED_FILES" ] && exit 0

CONFLICTED=""
for FILE in $STAGED_FILES; do
  STAGED_CONTENT=$(git show ":$FILE" 2>/dev/null || true)
  [ -z "$STAGED_CONTENT" ] && continue
  if echo "$STAGED_CONTENT" | grep -qE '^(<{7}( |$)|={7}$|>{7}( |$))'; then
    CONFLICTED="${CONFLICTED}  - ${FILE}
"
  fi
done

if [ -n "$CONFLICTED" ]; then
  echo "❌ COMMIT BLOQUEADO — marcadores de merge encontrados:"
  printf '%s' "$CONFLICTED"
  echo "Resolva os conflitos antes de commitar."
  exit 1
fi

echo "  [conflict-markers] sem marcadores de merge ✅"
exit 0
