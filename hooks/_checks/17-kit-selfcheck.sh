#!/bin/sh
# EGOS Pre-Commit — o kit checa a si mesmo. WARN-only.
#
# POR QUE EXISTE (LEAF-KIT-COBERTURA-001, 2026-07-27)
# ---------------------------------------------------
# O conteúdo dos checks é kernel-vivo. A LISTA passou a ser kernel-viva no v2.1 (piso).
# Mas o EXECUTOR — o `pre-commit` do kit — continua vendorizado: ele é o arquivo que o git
# chama, então não tem como vir do kernel em tempo de execução sem um salto de confiança.
#
# Resultado: um leaf instalado antes do v2.1 roda o executor antigo e ignora o piso em silêncio.
# Foi exatamente o que aconteceu com o daniel-falencias — o repositório com dado real de
# cliente ficou como o ÚNICO leaf sem piso, e o termômetro ainda o creditava como coberto.
# É o mesmo formato de defeito de sempre: a diferença não dói, ela só não aparece.
#
# Este check é o remédio mais barato possível: o kit reclama de si mesmo, toda vez, até alguém
# reinstalar. E como ele entra no PISO, chega em todo leaf sem ninguém editar leaf nenhum —
# ou seja, ele é ao mesmo tempo o conserto e a demonstração de que o mecanismo funciona.
#
# WARN-only de propósito: executor velho ainda roda os checks: está desatualizado, não quebrado.
# Bloquear o commit de alguém por causa da nossa própria dívida de instalação seria cobrar do
# leaf uma conta do kernel.

# Sem kernel na máquina (parceiro, VPS, CI) não há com o que comparar — sai calado.
KERNEL="${EGOS_KERNEL_PATH:-$HOME/egos}"
KERNEL_EXE="$KERNEL/templates/leaf-kit/hooks/pre-commit"
[ -f "$KERNEL_EXE" ] || exit 0

# O executor deste leaf é o pai do diretório de checks em que este arquivo está rodando.
# `$0` aponta para a fonte real (kernel-vivo ou local), então não serve — usamos o CHECKS_DIR
# que o despachante exporta implicitamente pelo caminho do próprio kit local.
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
LOCAL_EXE=""
for D in "$REPO_ROOT/hooks" "$REPO_ROOT/.egos-hooks"; do
  [ -f "$D/pre-commit" ] && LOCAL_EXE="$D/pre-commit" && break
done
[ -n "$LOCAL_EXE" ] || exit 0

# Mesmo arquivo (o próprio kernel) — nada a comparar.
[ "$LOCAL_EXE" -ef "$KERNEL_EXE" ] && exit 0

_ver() { grep -o 'EGOS-LEAF-KIT v[0-9][0-9.]*' "$1" 2>/dev/null | head -1 | sed 's/.*v//'; }
LOCAL_V=$(_ver "$LOCAL_EXE")
KERNEL_V=$(_ver "$KERNEL_EXE")

[ -n "$LOCAL_V" ] && [ -n "$KERNEL_V" ] || exit 0
[ "$LOCAL_V" = "$KERNEL_V" ] && exit 0

# Ordena as duas versões: se a maior for a do kernel, o leaf está atrás.
MAIOR=$(printf '%s\n%s\n' "$LOCAL_V" "$KERNEL_V" | sort -V | tail -1)
if [ "$MAIOR" = "$KERNEL_V" ]; then
  echo "  ⚠️  KIT-SELFCHECK: o executor deste repo é v$LOCAL_V e o kernel já está em v$KERNEL_V."
  echo "      O executor é vendorizado — ele NÃO se atualiza sozinho, e versões antigas ignoram"
  echo "      o piso do kernel (checks novos não chegam aqui). Conserto: cd '$REPO_ROOT' && sh $(dirname "$LOCAL_EXE" | sed "s|$REPO_ROOT/||")/install.sh"
fi
exit 0
