#!/bin/sh
# EGOS-LEAF-KIT — Pre-Commit Check 20 — PII + Protected-Dir Hard-Block
# Generalizado de daniel-falencias/hooks/_checks/21-pii-hardblock.sh +
# 20-sovereign-guard.sh (fundidos num único check self-contained, sem path de kernel).
#
# HARD BLOCK (não warn) de:
#   (a) PII real BR no CONTEÚDO dos arquivos de texto staged: CPF, CNPJ, RG, número de
#       processo CNJ. Nunca imprime o valor casado — só arquivo:linha:tipo (R-SEC-007:
#       agente nunca ecoa valor de dado sensível).
#   (b) qualquer arquivo STAGED sob um diretório "protegido" (dado real de processo/
#       cliente que nunca deve ir pro GitHub). O `.gitignore` já cobre `git add`, mas
#       não `git add -f` — este check pega esse furo.
#
# Diretórios protegidos: lidos de `.egos-leaf-kit.json` (chave `protected_dirs`, array
# de strings) na raiz do repo-alvo. Se o arquivo/chave não existir, usa o default:
#   _intake/ casos/ dados-reais/
#
# Exceções (não bloqueiam):
#   - arquivo cujo caminho contém "_exemplo-treino"
#   - linha que contém uma das palavras: exemplo, ficticio/fictício, FULANO,
#     000.000..., 123.456... (marcador claro de dado inventado)
#
# Override consciente (logado): EGOS_LEAF_PII_OVERRIDE=1

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$REPO_ROOT" || exit 0

CONFIG_FILE="$REPO_ROOT/.egos-leaf-kit.json"
DEFAULT_DIRS="_intake/ casos/ dados-reais/"

PROTECTED_DIRS="$DEFAULT_DIRS"
if [ -f "$CONFIG_FILE" ]; then
  EXTRACTED=$(sed -n '/"protected_dirs"/,/\]/p' "$CONFIG_FILE" 2>/dev/null | grep -oE '"[^"]+"' | grep -v '"protected_dirs"' | tr -d '"')
  if [ -n "$EXTRACTED" ]; then
    PROTECTED_DIRS=$(printf '%s\n' "$EXTRACTED" | tr '\n' ' ')
  fi
fi

# --- (a) diretório protegido -------------------------------------------------

STAGED_ALL=$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null || true)
DIR_FOUND=0
DIR_MATCHES=""
if [ -n "$STAGED_ALL" ]; then
  for DIR in $PROTECTED_DIRS; do
    # normaliza: garante barra final para casar só o diretório, não um prefixo parcial
    case "$DIR" in
      */) DIR_PAT="$DIR" ;;
      *) DIR_PAT="$DIR/" ;;
    esac
    MATCH=$(printf '%s\n' "$STAGED_ALL" | grep -F "$DIR_PAT" | grep -v '_exemplo-treino/' || true)
    if [ -n "$MATCH" ]; then
      DIR_FOUND=1
      DIR_MATCHES="${DIR_MATCHES}${MATCH}
"
    fi
  done
fi

if [ "$DIR_FOUND" = "1" ]; then
  echo "🛑 COMMIT BLOQUEADO — arquivo em diretório protegido (nunca vai para o GitHub):"
  printf '%s' "$DIR_MATCHES" | sed 's/^/     /'
  echo ""
  echo "   O que fazer:"
  echo "     - Tire do commit: git restore --staged <arquivo>"
  echo "     - Se for exemplo de treino sem dado real, mova para uma pasta '_exemplo-treino/'."
  echo "   Diretórios protegidos configurados: $PROTECTED_DIRS"
  echo "   Override consciente (logado): EGOS_LEAF_PII_OVERRIDE=1"
  if [ "${EGOS_LEAF_PII_OVERRIDE:-0}" != "1" ]; then
    exit 1
  fi
  echo "   ⚠️  EGOS_LEAF_PII_OVERRIDE=1 — prosseguindo sob responsabilidade explícita."
fi

# --- (b) PII no conteúdo ------------------------------------------------------
#
# v1.1: escaneia o CONTEÚDO STAGED (git show ":$FILE", o blob no índice), não o
# working-tree — mesma técnica de 01-secrets.sh v1.2. Antes, o check listava os
# nomes dos arquivos staged mas dava grep/sed no arquivo do working-tree — podia
# (a) PERDER PII que está staged mas já foi removida/editada no working-tree, e
# (b) FLAGAR PII que está só no working-tree e nunca vai ser commitada.
# `git show ":$FILE"` lê exatamente o que será commitado.

STAGED_TEXT=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null | grep -E '\.(md|txt|html|json|jsonl|csv|py)$' || true)
if [ -z "$STAGED_TEXT" ]; then
  echo "  [20-pii-hardblock] sem arquivos de texto staged ✅"
  exit 0
fi

EXCEPT_RE='exemplo|ficticio|fictício|FULANO|000\.000|123\.456'

CPF_RE='[0-9]{3}\.?[0-9]{3}\.?[0-9]{3}-?[0-9]{2}'
CNPJ_RE='[0-9]{2}\.?[0-9]{3}\.?[0-9]{3}/?[0-9]{4}-?[0-9]{2}'
CNJ_RE='[0-9]{7}[-.]?[0-9]{2}\.?[0-9]{4}\.?[0-9]\.?[0-9]{2}\.?[0-9]{4}'

# ── RG: PII-RG-KERNEL-CALIBRA-001 (achado 2026-07-26, corte Enio na mesma sessão) ────────────
# ANTES: RG_RE='[0-9]{1,2}\.?[0-9]{3}\.?[0-9]{3}-?[0-9Xx]\b' — TODOS os separadores opcionais,
# então a expressão casava com QUALQUER corrida de 8-9 dígitos. Num repo de legal-tech isso é
# quase tudo: número de lei, data em slug de HTML gerado, placeholder de formato de processo.
# MEDIDO no commit 6edebac (daniel-falencias): 4 bloqueios = "Lei 11.101/2005" achatada num slug,
# 2 datas em âncora de índice e 1 placeholder. RG de pessoa: ZERO. Foi preciso override para
# commitar trabalho limpo — e é assim que um hard-block morre, gritando em falso até o override
# virar hábito.
#
# AGORA, duas expressões em vez de uma:
#   FMT  — com separadores (12.345.678-9): bloqueia SEMPRE. Essa forma não é lei nem data.  # scan-ok: mock — número inventado, ilustra o formato
#   BARE — 8-9 dígitos crus: bloqueia SÓ se a linha disser que aquilo é um RG.
#
# O custo, dito na cara: um RG cru sem rótulo nenhum passa a passar. É perda real. Foi aceita
# porque a alternativa media pior — a versão antiga não distinguia RG de número de lei, e um
# gate que acusa tudo não está detectando nada, só bloqueando. Onde o RG cru de fato aparece
# (documento, cadastro, qualificação de parte) o rótulo vem junto, e é lá que o BARE pega.
# Golden nos dois sentidos: 20-pii-hardblock.test.sh.
RG_FMT_RE='[0-9]{1,2}\.[0-9]{3}\.[0-9]{3}-[0-9Xx]'
RG_BARE_RE='(^|[^0-9./-])[0-9]{8,9}([^0-9./-]|$)'
RG_ROTULO_RE='\bRGs?\b|registro[ -]geral|carteira de identidade|\bidentidade\b|\bid civil\b'

FOUND=0
FINDINGS=""
PROCESSOS_VISTOS=0

for FILE in $STAGED_TEXT; do
  case "$FILE" in
    *_exemplo-treino*) continue ;;
  esac
  STAGED_CONTENT=$(git show ":$FILE" 2>/dev/null || true)
  [ -z "$STAGED_CONTENT" ] && continue

  # ── D-006 (calibragem, 2026-07-25 — corte Enio) ────────────────────────────────────────────
  # ANTES: as 4 expressões rodavam INDEPENDENTES sobre o mesmo texto. Um número de processo tem
  # 20 dígitos e casa com CPF (11), CNPJ (14), RG (8-9) E CNJ (20) ao mesmo tempo — então UM
  # número virava QUATRO acusações, e era reportado ao usuário como se fosse um CPF.
  # MEDIDO no commit do motor incremental: 30 bloqueios = 12 números de processo + o slug
  # "lei-11101-2005" (a Lei 11.101/2005). CPF de pessoa: ZERO.
  #
  # AGORA: o número de PROCESSO é consumido do texto ANTES de procurar PII de pessoa. Isso deixa
  # o gate MAIS PRECISO, não mais frouxo — um número de processo deixa de ser reportado como CPF,
  # e o que sobrar depois do desconto é PII de verdade.
  #
  # POR QUE PROCESSO NÃO BLOQUEIA NESTE KIT: o número do processo é PÚBLICO (sai no Diário
  # Oficial) e é a chave primária do domínio destes repositórios — toda task, toda prova, todo
  # caso de teste cita um. Gate que barra todo commit que menciona um processo, num repositório
  # sobre processos, é contornado toda vez — e aí para de proteger o que importa. Ele segue
  # LISTADO no relatório, como aviso, para nunca sumir da vista.
  # CPF, CNPJ e RG de pessoa continuam BLOQUEANDO. Golden nos dois sentidos:
  # templates/leaf-kit/hooks/_checks/20-pii-hardblock.test.sh
  CONTEUDO_SEM_PROCESSO=$(printf '%s\n' "$STAGED_CONTENT" | sed -E "s#${CNJ_RE}#<numero-de-processo>#g")
  N_PROCESSOS=$(printf '%s\n' "$STAGED_CONTENT" | grep -oE "$CNJ_RE" | wc -l | tr -d ' ')
  [ "$N_PROCESSOS" -gt 0 ] && PROCESSOS_VISTOS=$((PROCESSOS_VISTOS + N_PROCESSOS))

  for LABEL in CPF CNPJ RG RG_BARE; do
    case "$LABEL" in
      CPF) RE="$CPF_RE" ;;
      CNPJ) RE="$CNPJ_RE" ;;
      RG) RE="$RG_FMT_RE" ;;
      RG_BARE) RE="$RG_BARE_RE" ;;
    esac
    LINES=$(printf '%s\n' "$CONTEUDO_SEM_PROCESSO" | grep -noE "$RE" | cut -d: -f1 | sort -un || true)
    for LN in $LINES; do
      CONTENT=$(printf '%s\n' "$CONTEUDO_SEM_PROCESSO" | sed -n "${LN}p")
      if echo "$CONTENT" | grep -qiE "$EXCEPT_RE"; then
        continue
      fi
      # PII-RG-KERNEL-CALIBRA-001: dígito cru só é RG se a linha disser que é. Sem esta guarda,
      # todo número de lei e toda data em slug voltam a bloquear (foi o achado de 2026-07-26).
      if [ "$LABEL" = "RG_BARE" ] && ! echo "$CONTENT" | grep -qiE "$RG_ROTULO_RE"; then
        continue
      fi
      [ "$LABEL" = "RG_BARE" ] && LABEL_REPORT="RG" || LABEL_REPORT="$LABEL"
      FOUND=1
      FINDINGS="${FINDINGS}     ${FILE}:${LN}:${LABEL_REPORT}
"
    done
  done
done

if [ "$FOUND" = "1" ]; then
  echo "🛑 COMMIT BLOQUEADO — possível dado pessoal real detectado:"
  printf '%s' "$FINDINGS"
  echo ""
  echo "   O valor não é mostrado aqui — nunca expomos dado sensível em texto."
  echo ""
  echo "   O que fazer:"
  echo "     - Se é dado real: apague/mascare, ou tire do commit (git restore --staged <arquivo>)."
  echo "     - Se é dado fictício/exemplo: adicione a palavra 'exemplo' na mesma linha,"
  echo "       ou mova o arquivo para uma pasta '_exemplo-treino/'."
  echo "   Override consciente (logado): EGOS_LEAF_PII_OVERRIDE=1"
  if [ "${EGOS_LEAF_PII_OVERRIDE:-0}" = "1" ]; then
    echo "   ⚠️  EGOS_LEAF_PII_OVERRIDE=1 — prosseguindo sob responsabilidade explícita."
  else
    exit 1
  fi
fi

# D-006: número de processo NÃO bloqueia, mas nunca some da vista — some da vista é como uma
# exceção vira buraco. O contador aparece sempre que houver, mesmo no caminho de sucesso.
if [ "$PROCESSOS_VISTOS" -gt 0 ]; then
  echo "  [20-pii-hardblock] sem PII de pessoa ✅ · ${PROCESSOS_VISTOS} número(s) de processo nos staged (público, não bloqueia — D-006)"
else
  echo "  [20-pii-hardblock] sem PII detectada nos staged ✅"
fi
