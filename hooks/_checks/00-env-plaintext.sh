#!/bin/sh
# EGOS-LEAF-KIT — Pre-Commit Check 00 — ENV Plaintext Hard-Block
# Generalizado de daniel-falencias/hooks/_checks/00-env-plaintext.sh (ADOPT-BEFORE-BUILD,
# self-contained, zero dependência de kernel).
#
# gitignore protege contra `git add`, mas NÃO contra `git add -f`. Este check bloqueia
# QUALQUER arquivo de env com valores nos staged, independente do gitignore.
# Permitidos: .example/.template/.sample + cifrados (.gpg/.age/.enc).
# Override consciente (logado): EGOS_LEAF_ENV_OVERRIDE=1

ENV_STAGED=$(git diff --cached --name-only --diff-filter=AM | grep -E '(^|/)\.env(\.|$)' | grep -vE '\.(example|template|sample|gpg|age|enc)$' || true)
if [ -n "$ENV_STAGED" ]; then
  echo "❌ BLOQUEADO: arquivo de ambiente em PLAINTEXT staged:"
  echo "$ENV_STAGED" | sed 's/^/     /'
  echo "   Env com valores NUNCA vai pro GitHub."
  echo "   Transferir? Cifre: gpg --symmetric --cipher-algo AES256 -o x.env.gpg <arquivo>"
  echo "   Override consciente (logado): EGOS_LEAF_ENV_OVERRIDE=1"
  if [ "${EGOS_LEAF_ENV_OVERRIDE:-0}" = "1" ]; then
    echo "   ⚠️  EGOS_LEAF_ENV_OVERRIDE=1 — prosseguindo sob responsabilidade explícita."
  else
    exit 1
  fi
fi
echo "  [00-env] sem env plaintext nos staged ✅"
