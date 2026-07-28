#!/bin/sh
# EGOS-LEAF-KIT v1.1 — instalador do pre-commit de segurança (1 comando, roda 1x por clone).
# Uso:
#   sh <kit-dir>/install.sh
#
# Não precisa de node, bun, nem de nenhum framework de hooks — é git puro. Funciona em
# qualquer máquina com git instalado (parceiro, VPS, CI), sem depender de nenhum path
# absoluto de kernel.
#
# v1.1: respeita core.hooksPath (ex.: repos com Husky em .husky/) em vez de assumir
# sempre .git/hooks/, e se auto-localiza (SCRIPT_DIR) em vez de assumir que o kit
# mora em "hooks/" — funciona também se o kit foi instalado em ".egos-hooks/".

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
  echo "❌ Rode este script de dentro do repositório git." >&2
  exit 1
fi
cd "$REPO_ROOT" || exit 1

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# ─────────────────────────────────────────────────────────────────────────────────────────
# AUD-INSTALL-CWD-001 (2026-07-27) — instalar onde o kit MORA, não onde o cwd está.
#
# REPO_ROOT vinha de `git rev-parse` puro, que responde sobre o cwd. Então
#   cd ~/egos && sh /caminho/do/leaf/hooks/install.sh
# lia o kit do LEAF e o instalava no KERNEL — e, sendo `ln -sf`, sobrescrevia o slot sem
# perguntar. Aconteceu comigo às 21:58 de 27/07: o `.husky/_/pre-commit` do kernel virou um
# symlink para o kit de um leaf, e os ~40 gates do kernel sumiram de uma vez. Levou um
# `git hook run` para aparecer, porque nada reclamou.
#
# A leitura errada era plausível demais para depender de disciplina de quem digita. Agora o
# script exige que o kit esteja DENTRO do repositório que ele vai alterar. Fora disso, para.
# ─────────────────────────────────────────────────────────────────────────────────────────
case "$SCRIPT_DIR/" in
  "$REPO_ROOT"/*) : ;;
  *)
    echo "❌ Este kit mora em $SCRIPT_DIR, que NÃO está dentro de $REPO_ROOT." >&2
    echo "   Instalar daqui alteraria o repositório errado — foi assim que o hook do kernel" >&2
    echo "   foi sobrescrito em 2026-07-27. Entre no repositório-alvo antes:" >&2
    echo "     cd <repo-alvo> && sh hooks/install.sh" >&2
    exit 1
    ;;
esac

HOOKS_PATH=$(git config --get core.hooksPath 2>/dev/null || true)
case "$HOOKS_PATH" in
  /*) ACTIVE_DIR="$HOOKS_PATH" ;;
  "") ACTIVE_DIR="$REPO_ROOT/.git/hooks" ;;
  *) ACTIVE_DIR="$REPO_ROOT/$HOOKS_PATH" ;;
esac

mkdir -p "$ACTIVE_DIR"
ALVO="$ACTIVE_DIR/pre-commit"

# ─────────────────────────────────────────────────────────────────────────────────────────
# HOOK-CHAIN-001 (2026-07-26) — encadear, nunca sobrescrever.
#
# A v1.1 fazia `ln -sf`, que SOBRESCREVE em silêncio. E o kernel EGOS tem o próprio instalador,
# que aponta o mesmo slot para ~/.egos/hooks/pre-commit. Os dois disputavam o mesmo arquivo e o
# ÚLTIMO A RODAR VENCIA — sem aviso, sem erro, sem nada no log.
#
# Medido em 2026-07-26 neste repo: o kernel venceu em 12:02 e, desde então, os 11 checks do leaf
# NUNCA rodaram. Entre eles `20-pii-hardblock`, `20-sovereign-guard`, `21-pii-hardblock`,
# `40-decisoes-conjuntas` e `50-prova-1-clique` — num repositório que guarda dado real de
# processo. O commit seguia verde e dizia "Ready to commit".
#
# É a mesma família dos defeitos que este projeto persegue: a proteção não falhou, ela
# DESAPARECEU, e o sistema continuou dizendo que estava tudo certo.
#
# Agora: se já existe um hook que não é nosso, geramos um encadeador que roda os DOIS, na ordem
# (o de fora primeiro — o do kernel faz gitleaks e é o mais barato de falhar). Qualquer um que
# falhe barra o commit. Idempotente: rodar de novo não empilha nem duplica.
# ─────────────────────────────────────────────────────────────────────────────────────────
EXISTENTE=""
if [ -L "$ALVO" ]; then
  EXISTENTE=$(readlink "$ALVO")
elif [ -f "$ALVO" ]; then
  if grep -q "HOOK-CHAIN-001" "$ALVO" 2>/dev/null; then
    EXISTENTE=$(grep -oE '^EXTERNO=.*' "$ALVO" | cut -d'"' -f2)
  else
    # ─── AUD-CODEX-INSTALL-001 [CRÍTICO], achado no review gpt-5.6-sol e corrigido em 27/07 ───
    #
    # Este ramo NÃO EXISTIA, e a falta dele anulava o arquivo inteiro. Um hook ESCRITO À MÃO —
    # arquivo comum, sem a marca do nosso encadeador — deixava `EXISTENTE` vazio, caía no `else`
    # lá embaixo e era APAGADO pelo `ln -sf`, sem aviso e sem cópia.
    #
    # Ou seja: o instalador escrito para parar de destruir o hook alheio destruía exatamente o
    # caso que mais importa, o hook que a pessoa escreveu ela mesma. Os dois casos que ele
    # tratava (symlink nosso, encadeador nosso) são os que ELE PRÓPRIO tinha criado.
    #
    # Agora o hook estranho é PRESERVADO num arquivo ao lado e encadeado a partir dali. O nome
    # é fixo de propósito: numa 2ª execução o `-e` abaixo impede sobrescrever a cópia original,
    # que é o único registro do que a pessoa tinha antes.
    GUARDADO="$ALVO.pre-egos"
    if [ -e "$GUARDADO" ]; then
      echo "ℹ️  já existe $GUARDADO de uma instalação anterior — mantendo essa cópia."
    else
      cp -p "$ALVO" "$GUARDADO" || { echo "❌ não consegui preservar o hook existente — ABORTANDO para não destruí-lo."; exit 1; }
      echo "🛟  hook próprio encontrado e PRESERVADO em $GUARDADO"
    fi
    EXISTENTE="$GUARDADO"
  fi
fi

# Se o que está lá já é o nosso próprio hook, não há o que encadear.
case "$EXISTENTE" in
  "$SCRIPT_DIR/pre-commit") EXISTENTE="" ;;
esac

if [ -n "$EXISTENTE" ] && [ -e "$EXISTENTE" ]; then
  echo "ℹ️  já havia um hook aqui ($EXISTENTE) — ENCADEANDO em vez de sobrescrever."
  # ⚠️ `rm` ANTES do `cat`, e isto não é detalhe: se o alvo for symlink, `cat >` escreve ATRAVÉS
  # dele e DESTRÓI o arquivo apontado. Aconteceu comigo em 2026-07-26 ao escrever este próprio
  # instalador: o encadeador sobrescreveu o hook do kernel (200 linhas, compartilhado por vários
  # repos) e o `ls -l` continuou mostrando um symlink saudável. Restaurado de
  # egos/scripts/egos-home/hooks/pre-commit. Redirecionamento de shell não respeita symlink —
  # ele segue o link e escreve no destino.
  rm -f "$ALVO"
  cat > "$ALVO" <<CHAIN
#!/bin/sh
# HOOK-CHAIN-001 — GERADO por hooks/install.sh. Não editar à mão.
# Roda o hook que já existia na máquina E os checks deste repositório. Antes disto, um
# instalador sobrescrevia o outro em silêncio e os checks do leaf sumiam sem aviso.
#
# ── SEM CURTO-CIRCUITO (2026-07-27) ──────────────────────────────────────────────────────
# A primeira versão fazia \`|| exit 1\` em cada elo, então o primeiro que falhasse escondia o
# resto. Medido ao instalar o kit num leaf da frota: o hook externo bloqueava por README velho, e os
# checks do leaf — recém-instalados — não chegavam a rodar. Quem olhasse a saída concluiria
# que o kit não estava lá.
# O bloqueio continua igual: se QUALQUER elo falha, o commit não passa. O que muda é que
# todos rodam e você vê tudo de uma vez, em vez de descobrir um problema por tentativa.
EXTERNO="$EXISTENTE"
LEAF="$SCRIPT_DIR/pre-commit"
RC=0

[ -x "\$EXTERNO" ] && { sh "\$EXTERNO" "\$@" || RC=1; }
[ -x "\$LEAF" ]    && { sh "\$LEAF"    "\$@" || RC=1; }
exit \$RC
CHAIN
else
  ln -sf "$SCRIPT_DIR/pre-commit" "$ALVO"
fi
chmod +x "$SCRIPT_DIR/pre-commit" "$SCRIPT_DIR"/_checks/*.sh "$ALVO" 2>/dev/null

echo "✅ Pronto — sua máquina agora bloqueia automaticamente:"
echo "   - arquivos .env com senha/chave"
echo "   - chaves de API e segredos coladas no código"
echo "   - marcadores de conflito de merge não resolvidos"
echo "   - CPF, CNPJ, RG, número de processo real e arquivos em diretórios protegidos"
echo ""
echo "   Isso roda sozinho toda vez que você der 'git commit' — não precisa lembrar de nada."
