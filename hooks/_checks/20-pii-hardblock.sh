#!/bin/sh
# EGOS-LEAF-KIT — Pre-Commit Check 20 — PII + Protected-Dir Hard-Block
# Generalizado de daniel-falencias/hooks/_checks/21-pii-hardblock.sh +
# 20-sovereign-guard.sh (fundidos num único check self-contained, sem path de kernel).
#
# HARD BLOCK (não warn) de:
#   (a) PII real BR no CONTEÚDO dos arquivos de texto staged: CPF e RG de PESSOA.
#       CNPJ (empresa, D-008) e número de processo CNJ (D-006) são AVISO, não bloqueio —
#       ambos são públicos por lei. Nunca imprime o valor casado — só arquivo:linha:tipo (R-SEC-007:
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

# ── CPF: PII-CPF-BORDA-001 (2026-07-27) ──────────────────────────────────────────────────────
# ANTES era uma expressão só, com TODOS os separadores opcionais: '[0-9]{3}\.?[0-9]{3}\.?[0-9]{3}-?[0-9]{2}'
# — ou seja, qualquer corrida de 11 dígitos, em qualquer lugar, inclusive DENTRO de um número
# maior. Bloqueou o `daniel-falencias` num UUID de tenant: `...-180931982899` contém 11 dígitos
# seguidos e virou "CPF". O arquivo estava commitado havia semanas; o falso-positivo só apareceu
# agora porque este check acabou de passar a rodar naquele repo.
#
# É a MESMA correção que o RG recebeu em 26/07 e o CNPJ em 27/07, pela terceira vez no mesmo
# arquivo: expressão sem borda não distingue o dado do dígito que passava por ali. E é a mesma
# forma que o gate local do daniel-falencias (21-pii-hardblock.sh) já usa em produção desde
# 15/07, também depois de bloquear em falso.
#
# AGORA, duas expressões, como no RG:
#   FMT  — pontuação OBRIGATÓRIA (3 dígitos, ponto, 3, ponto, 3, hífen, 2): bloqueia sempre.
#          Escrito por extenso de propósito: um CPF-molde literal aqui faz o gitleaks acusar o
#          próprio arquivo que define a regra — aconteceu ao commitar esta linha.
#   BARE — 11 dígitos crus: exige borda não-dígito antes E depois, então não casa como pedaço
#          de UUID, timestamp, hash ou número de processo.
CPF_FMT_RE='[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}'
CPF_BARE_RE='(^|[^0-9])[0-9]{11}([^0-9]|$)'
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
# Golden nos dois sentidos: ../_tests/20-pii-hardblock.test.sh.
RG_FMT_RE='[0-9]{1,2}\.[0-9]{3}\.[0-9]{3}-[0-9Xx]'
RG_BARE_RE='(^|[^0-9./-])[0-9]{8,9}([^0-9./-]|$)'
RG_ROTULO_RE='\bRGs?\b|registro[ -]geral|carteira de identidade|\bidentidade\b|\bid civil\b'

FOUND=0
FINDINGS=""
PROCESSOS_VISTOS=0
CNPJ_VISTOS=0   # D-008: CNPJ de empresa é aviso, não bloqueio — mas nunca some da vista

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
  # CPF e RG de pessoa continuam BLOQUEANDO (CNPJ saiu em D-008). Golden nos dois sentidos:
  # templates/leaf-kit/hooks/_tests/20-pii-hardblock.test.sh
  CONTEUDO_SEM_PROCESSO=$(printf '%s\n' "$STAGED_CONTENT" | sed -E "s#${CNJ_RE}#<numero-de-processo>#g")
  N_PROCESSOS=$(printf '%s\n' "$STAGED_CONTENT" | grep -oE "$CNJ_RE" | wc -l | tr -d ' ')
  [ "$N_PROCESSOS" -gt 0 ] && PROCESSOS_VISTOS=$((PROCESSOS_VISTOS + N_PROCESSOS))

  # ── D-008 (calibragem, 2026-07-27 — corte Enio: "não devemos ter um gate tão severo assim") ──
  # CNPJ sai do bloqueio e passa a AVISO, pela mesma razão que o número de processo saiu em D-006.
  #
  # CNPJ é o cadastro de uma pessoa JURÍDICA. É público por lei, consultável por qualquer um na
  # Receita Federal, e nos nossos repositórios ele chega de API pública sem chave (BrasilAPI). A
  # LGPD protege pessoa NATURAL; empresa não é titular de dado pessoal. Bloquear CNPJ não protegia
  # ninguém — só ensinava a usar override, que é como um gate morre.
  #
  # FATO GERADOR: a decisão D-008, que PERGUNTAVA se o gate deveria tratar CNPJ como dado pessoal,
  # foi barrada por este gate porque citava um CNPJ. A pergunta sobre o detector, bloqueada pelo
  # detector. Antes dela, a regra A2 do radar do Daniel — cuja evidência é o par de CNPJs que
  # provou que a administração judicial tem 1 sócio e a sociedade de advogados tem 22 — ficou dias
  # fora do git, porque a prova não pode ser mascarada sem deixar de ser prova.
  #
  # O QUE NÃO MUDOU: CPF e RG de pessoa continuam BLOQUEANDO, exatamente como antes. É o ponto
  # todo — o gate fica MAIS preciso, não mais frouxo: para de gritar em cima de dado público de
  # empresa e segue barrando o que é de pessoa.
  # Golden nos dois sentidos: templates/leaf-kit/hooks/_tests/20-pii-hardblock.test.sh
  # E o CNPJ é CONSUMIDO do texto, não apenas ignorado no laço — pelo mesmo motivo do processo.
  # Achado pelo golden ao escrever esta calibragem: um CNPJ cru tem 14 dígitos, e a expressão
  # de CPF (11 dígitos, separadores opcionais, sem âncora) casa com os 11 primeiros. Um CNPJ cru
  # era reportado como CPF e bloqueava. Sem consumir antes, tirar o CNPJ do laço não bastaria — o
  # gate seguiria barrando o mesmo texto sob outro rótulo, que é pior: erra e ainda mente sobre o
  # que achou.
  N_CNPJ=$(printf '%s\n' "$CONTEUDO_SEM_PROCESSO" | grep -oE "$CNPJ_RE" | wc -l | tr -d ' ')
  [ "$N_CNPJ" -gt 0 ] && CNPJ_VISTOS=$((CNPJ_VISTOS + N_CNPJ))
  CONTEUDO_SEM_PROCESSO=$(printf '%s\n' "$CONTEUDO_SEM_PROCESSO" | sed -E "s#${CNPJ_RE}#<cnpj-de-empresa>#g")

  for LABEL in CPF CPF_BARE RG RG_BARE; do
    case "$LABEL" in
      CPF) RE="$CPF_FMT_RE" ;;
      CPF_BARE) RE="$CPF_BARE_RE" ;;
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
      case "$LABEL" in
        RG_BARE) LABEL_REPORT="RG" ;;
        CPF_BARE) LABEL_REPORT="CPF" ;;
        *) LABEL_REPORT="$LABEL" ;;
      esac
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
AVISOS=""
[ "$PROCESSOS_VISTOS" -gt 0 ] && AVISOS="${PROCESSOS_VISTOS} número(s) de processo (D-006)"
if [ "$CNPJ_VISTOS" -gt 0 ]; then
  [ -n "$AVISOS" ] && AVISOS="$AVISOS · "
  AVISOS="${AVISOS}${CNPJ_VISTOS} CNPJ de empresa (D-008)"
fi
if [ -n "$AVISOS" ]; then
  echo "  [20-pii-hardblock] sem PII de pessoa ✅ · ${AVISOS} nos staged — público, não bloqueia"
else
  echo "  [20-pii-hardblock] sem PII detectada nos staged ✅"
fi
