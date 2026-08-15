#!/bin/sh
# EGOS-LEAF-KIT v1.2 — instalador do pre-commit de segurança (1 comando, roda 1x por clone).
# Uso:
#   sh <kit-dir>/install.sh
#
# Não precisa de node, bun, nem de nenhum framework de hooks — é git puro, e não depende de
# nenhum path absoluto de kernel.
#
# ── ONDE ISTO FOI MEDIDO (R-PORTABILIDADE-MEDIDA-001, 2026-08-07) ────────────────────────────
# Aqui dizia "funciona em qualquer máquina com git instalado (parceiro, VPS, CI)". Era uma
# suposição escrita como fato, e ficou 11 dias sem ninguém notar porque toda a evidência vinha
# de uma plataforma só. No primeiro contato com Windows (parceiro da frota, 07/08) apareceram 2 defeitos
# numa sentada, os dois da MESMA família — suposição de POSIX (formato de caminho e symlink) —
# e um deles travou TODOS os commits do repositório dele.
#   PROVADO: Linux (bash/dash), incluindo a simulação do modo de falha do Windows —
#            golden `_tests/kit-portabilidade.test.sh`, 7 cenários, mutações provadas.
#   RELATADO: Windows/Git-Bash (os 2 defeitos). O CONSERTO deles ainda não foi re-observado
#            por nós numa máquina Windows — está pendente de confirmação de terceiro.
#   NÃO MEDIDO: macOS, WSL, CI hospedado.
# Rodou em plataforma não medida? Registre aqui o resultado. Este bloco é a régua do que
# podemos AFIRMAR — não a lista do que gostaríamos que fosse verdade.
#
# v1.2 (2026-08-07): dispatcher em vez de `ln -sf` (symlink não é garantido no Windows);
#       REPO_ROOT re-derivado por `pwd` (formato de caminho); e a instalação passou a ser
#       PROVADA RODANDO o hook, não conferindo que o arquivo existe.
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

# AUD-INSTALL-CWD-WIN-001 (2026-08-07, achado por um parceiro no Windows) — re-deriva REPO_ROOT
# pelo `pwd` do PRÓPRIO shell em vez de confiar no formato que `git rev-parse` devolveu.
#
# No Git Bash (Windows) `git rev-parse --show-toplevel` pode devolver estilo Windows
# (`C:/IA/PROJETO`), enquanto SCRIPT_DIR abaixo é montado com `cd ... && pwd` do MESMO shell,
# que normaliza para estilo POSIX (`/c/IA/PROJETO`). A comparação de prefixo do
# AUD-INSTALL-CWD-001 logo abaixo então NUNCA casava — o instalador recusava qualquer repo
# no Windows dizendo "o kit está fora dele", mesmo quando estava exatamente dentro.
# `cd`+`pwd` no mesmo shell que vai gerar SCRIPT_DIR garante o mesmo formato dos dois lados.
# Em Linux/macOS isto é no-op: `pwd` já devolvia o mesmo valor que `git rev-parse` deu.
REPO_ROOT=$(pwd)

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

# AUD-CODEX-INSTALL-001 (2026-07-28) — em WORKTREE o `.git` é ARQUIVO, não diretório.
#
# Reproduzido antes de consertar, num worktree de verdade:
#     mkdir: cannot create directory '.../.git': Not a directory
#     ln: failed to access '.../.git/hooks/pre-commit': Not a directory
#     ✅ Pronto — sua máquina agora bloqueia automaticamente:
#     EXIT=0
#
# Ou seja: o instalador falhava em toda linha que importa e AINDA ASSIM dizia à pessoa que ela
# estava protegida, saindo com sucesso. É a mesma doença do ETL que publicava o retrato de
# ontem e do backfill que saía verde sem gravar nada — mas aqui o dano é maior, porque o
# assunto é justamente a rede de proteção. Confiar num hook que não existe é pior que saber
# que não tem hook nenhum.
#
# `git rev-parse --git-path hooks` resolve os três casos de uma vez — repositório comum,
# worktree e core.hooksPath configurado — porque quem responde é o próprio git, não a nossa
# suposição sobre onde o `.git` fica. Verificado nos dois: no worktree devolve o caminho do
# repositório principal; no repo comum, `.git/hooks`.
HOOKS_PATH=$(git config --get core.hooksPath 2>/dev/null || true)
if [ -n "$HOOKS_PATH" ]; then
  case "$HOOKS_PATH" in
    /*) ACTIVE_DIR="$HOOKS_PATH" ;;
    *) ACTIVE_DIR="$REPO_ROOT/$HOOKS_PATH" ;;
  esac
else
  ACTIVE_DIR=$(git rev-parse --git-path hooks 2>/dev/null || true)
  case "$ACTIVE_DIR" in
    /*) : ;;
    "") ACTIVE_DIR="$REPO_ROOT/.git/hooks" ;;   # git antigo demais para --git-path
    *) ACTIVE_DIR="$REPO_ROOT/$ACTIVE_DIR" ;;   # devolvido relativo à raiz do repo
  esac
fi

# ── ACHADO AO TESTAR O CONSERTO ACIMA (2026-07-28), pior que o defeito original ────────────
# Worktree COMPARTILHA o diretório de hooks com o repositório principal. Instalando de dentro
# de um worktree, o encadeador grava o caminho DO WORKTREE no hook compartilhado:
#
#     LEAF="/tmp/.../wt-teste/hooks/pre-commit"
#
# Quando o worktree é removido — e worktree é coisa temporária por definição — esse caminho
# deixa de existir. O elo é testado com `[ -x "$LEAF" ]`, então ele simplesmente PARA DE RODAR.
# Sem erro, sem aviso: o repositório principal perde os checks do leaf e continua commitando
# como se tudo estivesse no lugar. Foi exatamente o que aconteceu comigo ao reproduzir o bug do
# `.git`-arquivo, e só percebi porque fui conferir para onde o LEAF apontava.
#
# Por isso a recusa é aqui, e não um aviso: os hooks são compartilhados, então o lugar certo de
# instalar é sempre o checkout principal. Instalar do worktree não é uma variante que funciona
# pior — é uma que estraga o de todo mundo.
GIT_DIR_ATUAL=$(git rev-parse --git-dir 2>/dev/null || echo "")
GIT_DIR_COMUM=$(git rev-parse --git-common-dir 2>/dev/null || echo "")
if [ -n "$GIT_DIR_ATUAL" ] && [ -n "$GIT_DIR_COMUM" ] && [ "$GIT_DIR_ATUAL" != "$GIT_DIR_COMUM" ]; then
  echo "❌ você está num WORKTREE, e worktree compartilha os hooks com o repositório principal." >&2
  echo "   Instalar daqui gravaria o caminho deste worktree no hook compartilhado; quando este" >&2
  echo "   worktree fosse removido, o repositório principal perderia os checks EM SILÊNCIO." >&2
  echo "   Instale a partir do checkout principal:" >&2
  echo "     cd \"$(cd "$GIT_DIR_COMUM/.." 2>/dev/null && pwd)\" && sh hooks/install.sh" >&2
  echo "   NADA foi instalado." >&2
  exit 1
fi

if ! mkdir -p "$ACTIVE_DIR"; then
  echo "❌ não consegui criar o diretório de hooks ($ACTIVE_DIR)." >&2
  echo "   NADA foi instalado — este repositório NÃO está protegido." >&2
  exit 1
fi
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
  # AUD-INSTALL-WIN-SYMLINK-001 (2026-08-07, achado por um parceiro no Windows) — dispatcher em vez
  # de symlink, sempre.
  #
  # `ln -sf` exige privilégio de symlink no Windows. Sem ele (o caso comum — não é preciso
  # rodar como admin nem ligar Developer Mode para usar o kit), o Git Bash NÃO FALHA: ele
  # silenciosamente COPIA o arquivo em vez de linkar. A cópia fica sozinha em `.git/hooks/`,
  # sem o `_checks/` do lado — e como o pre-commit resolve `_checks/` relativo ao seu próprio
  # SCRIPT_DIR, ele não encontra o MANIFEST, entra em fail-closed e bloqueia TODO commit, não
  # só os ruins. `[ -e "$ALVO" ]` mais abaixo não pega isso: a cópia existe e é executável,
  # só está vazia por dentro.
  #
  # Em vez de linkar, escrevemos um dispatcher de 1 linha (mesmo formato do HOOK-CHAIN acima)
  # que sempre faz `sh` no caminho absoluto do pre-commit real, dentro do kit. Isso não depende
  # de symlink em NENHUM sistema — funciona idêntico em Windows/Git-Bash, Linux e macOS, e
  # continua achando `_checks/` porque quem roda é o script original, no lugar original.
  cat > "$ALVO" <<DISPATCH
#!/bin/sh
# GERADO por hooks/install.sh (AUD-INSTALL-WIN-SYMLINK-001). Não editar à mão.
exec sh "$SCRIPT_DIR/pre-commit" "\$@"
DISPATCH
fi
chmod +x "$SCRIPT_DIR/pre-commit" "$SCRIPT_DIR"/_checks/*.sh "$ALVO" 2>/dev/null

# A prova antes do anúncio. Dizer "Pronto" sem conferir foi exatamente o defeito de cima: o
# instalador anunciava proteção que não existia.
if [ ! -e "$ALVO" ]; then
  echo "❌ o hook não ficou em $ALVO — este repositório NÃO está protegido." >&2
  exit 1
fi
if [ ! -x "$ALVO" ] && [ ! -L "$ALVO" ]; then
  echo "❌ o hook em $ALVO não é executável — o git vai ignorá-lo em silêncio." >&2
  exit 1
fi

# ── AUD-INSTALL-PROVA-EXISTENCIA-001 (2026-08-07) — provar RODANDO, não existindo ─────────────
#
# As duas checagens acima existem desde 27/07 sob o título "a prova antes do anúncio", e o
# comentário original prometia conferir que o hook "responde". Ele nunca conferiu: `-e` e `-x`
# são perguntas sobre a PRESENÇA do arquivo, não sobre o COMPORTAMENTO dele.
#
# Foi por esse vão que o incidente de 07/08 passou inteiro. No Windows o `ln -sf` virou cópia; a
# cópia EXISTIA e era EXECUTÁVEL, então as duas checagens passaram e o instalador imprimiu
# "✅ Pronto — sua máquina agora bloqueia automaticamente" — enquanto o que ele tinha acabado de
# instalar bloqueava TODO commit do repositório. O instalador não só deixou de detectar o
# estrago: ele CERTIFICOU o contrário do que era verdade.
#
# É a família #1 do nosso próprio CLAUDE.md ("gate que roda, imprime e nunca barra") na versão
# instalador, e a mesma lição do teste-de-gate: a pergunta certa nunca é "o artefato está lá?",
# é "o artefato FAZ o que promete?". Agora o hook é EXECUTADO de verdade.
#
# O que se exige é o BANNER: ele só é impresso depois que o dispatcher se localizou e achou o
# kit. Não se exige exit 0, porque um bloqueio legítimo (alguém com segredo já staged neste
# momento) também sai != 0 — e reprovar a instalação por isso seria confundir "o kit funciona"
# com "este índice está limpo", que é justamente o tipo de erro que este bloco existe p/ matar.
PROVA=$(sh "$ALVO" 2>&1)
PROVA_RC=$?
if ! printf '%s\n' "$PROVA" | grep -q "EGOS-LEAF-KIT"; then
  echo "❌ o hook foi instalado em $ALVO mas NÃO RODA — este repositório NÃO está protegido." >&2
  echo "   Ele existe e é executável, e ainda assim não conseguiu se localizar. Saída dele:" >&2
  printf '%s\n' "$PROVA" | sed 's/^/     /' >&2
  echo "   NÃO confie neste repositório até isto ser resolvido." >&2
  exit 1
fi
if printf '%s\n' "$PROVA" | grep -qE "MANIFEST ausente|OBRIGATÓRIO ausente"; then
  echo "❌ o hook roda mas o kit está INCOMPLETO — e assim ele bloqueia TODO commit, não só os ruins." >&2
  printf '%s\n' "$PROVA" | sed 's/^/     /' >&2
  exit 1
fi
if [ "$PROVA_RC" != "0" ]; then
  echo "ℹ️  instalação OK. O hook rodou e BLOQUEOU o que está staged agora — isso é ele funcionando:"
  printf '%s\n' "$PROVA" | sed 's/^/     /'
  echo ""
fi

echo "✅ Pronto (provado rodando, não só instalado) — sua máquina agora bloqueia automaticamente:"
echo "   - arquivos .env com senha/chave"
echo "   - chaves de API e segredos coladas no código"
echo "   - marcadores de conflito de merge não resolvidos"
echo "   - CPF, CNPJ, RG, número de processo real e arquivos em diretórios protegidos"
echo ""
echo "   Isso roda sozinho toda vez que você der 'git commit' — não precisa lembrar de nada."
