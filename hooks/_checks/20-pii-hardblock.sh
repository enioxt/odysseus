#!/bin/sh
# EGOS-LEAF-KIT — Pre-Commit Check 20 — PII + Protected-Dir Hard-Block
# Generalizado de dois checks já rodados em produção num leaf desta frota (21-pii-hardblock.sh +
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
# Diretórios protegidos: default do kit UNIDO ao que `.egos-leaf-kit.json` declarar (chave
# `protected_dirs`, array de strings, na raiz do repo-alvo). A config SOMA, nunca subtrai —
# ver AUD-PII-CONFIG-SUBTRAI-001 abaixo. Default de fábrica:
#   _intake/ casos/ dados-reais/ _dados/
# ⚠️ Esta lista aparece em DOIS lugares (aqui e em `DEFAULT_DIRS`, umas linhas abaixo) porque
#    uma é para humano e a outra é para o shell. Divergir foi o AUD-PII-DEFAULT-DRIFT-001.
#    Quem impede a divergência é o cenário 6 de `_tests/kit-portabilidade.test.sh`, não a
#    atenção de quem edita — a leitura errada aqui é plausível demais para depender disso.
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
# `_dados/` está aqui porque a entrevista de onboarding do kit o chama de "pasta padrão"
# (docs/onboarding/02-SEU-AGENTE.md §5.2). Antes de 2026-08-07 o texto prometia uma proteção
# que o código só entregava se a pessoa criasse `.egos-leaf-kit.json` — duas fontes para um
# fato só, que é como a promessa e a entrega se separam sem ninguém ver.
DEFAULT_DIRS="_intake/ casos/ dados-reais/ _dados/"

# ── CONFIG SOMA, NUNCA SUBSTITUI (AUD-PII-CONFIG-SUBTRAI-001, 2026-08-07) ────────────────────
#
# Isto era `PROTECTED_DIRS=$EXTRACTED` — a config do repo SUBSTITUÍA o default inteiro. Então
# declarar uma pasta a mais custava, em silêncio, TODAS as outras: quem escrevesse
# `{"protected_dirs": ["_dados/"]}` — o caso natural, e exatamente o que um parceiro escreveu em
# 07/08 seguindo a entrevista — perdia a proteção de `_intake/`, `casos/` e `dados-reais/` sem
# uma linha de aviso, achando que tinha ACRESCENTADO uma.
#
# É a doença que este kit inteiro existe para combater, dentro do próprio kit: redução de
# cobertura em silêncio, por uma edição que parecia só somar. E contradizia a doutrina que o
# despachante já aplicava ao lado, para os checks: a lista efetiva é PISO ∪ LOCAL, o leaf pode
# ACRESCENTAR e não pode SUBTRAIR. Não havia motivo para o diretório protegido seguir a regra
# oposta — só não tinham sido escritos no mesmo dia.
#
# Agora é união, igual ao MANIFEST. Tirar um default é ato deliberado e raro: use o override
# consciente e logado (EGOS_LEAF_PII_OVERRIDE=1), que deixa rastro, em vez de uma chave de
# config que apaga proteção parecendo configurá-la.
PROTECTED_DIRS="$DEFAULT_DIRS"
if [ -f "$CONFIG_FILE" ]; then
  EXTRACTED=$(sed -n '/"protected_dirs"/,/\]/p' "$CONFIG_FILE" 2>/dev/null | grep -oE '"[^"]+"' | grep -v '"protected_dirs"' | tr -d '"')
  if [ -n "$EXTRACTED" ]; then
    PROTECTED_DIRS=$(printf '%s\n%s\n' "$(printf '%s' "$DEFAULT_DIRS" | tr ' ' '\n')" "$EXTRACTED" \
      | sed 's#/*$##' | grep -v '^$' | sort -u | tr '\n' ' ')
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
  # A metade (a) é por CAMINHO: falso positivo é impossível por construção. Registramos
  # mesmo assim, para que "nunca errou" deixe de ser afirmação e vire contagem.
  _d="${EGOS_PII_LOG_DIR:-$HOME/.egos/logs}"; mkdir -p "$_d" 2>/dev/null && \
    printf '{"ts":"%s","repo":"%s","acao":"bloqueio-diretorio","achados":"%s"}\n' \
      "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$(basename "$REPO_ROOT")" \
      "$(printf '%s' "$DIR_MATCHES" | grep -c . 2>/dev/null || true) arquivo(s)" \
      >> "$_d/pii-hardblock.jsonl" 2>/dev/null || true
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
# maior. Bloqueou um leaf desta frota num UUID de tenant: `...-180931982899` contém 11 dígitos
# seguidos e virou "CPF". O arquivo estava commitado havia semanas; o falso-positivo só apareceu
# agora porque este check acabou de passar a rodar naquele repo.
#
# É a MESMA correção que o RG recebeu em 26/07 e o CNPJ em 27/07, pela terceira vez no mesmo
# arquivo: expressão sem borda não distingue o dado do dígito que passava por ali. E é a mesma
# forma que o gate local de um leaf desta frota (21-pii-hardblock.sh) já usa em produção desde
# 15/07, também depois de bloquear em falso.
#
# AGORA, duas expressões, como no RG:
#   FMT  — pontuação OBRIGATÓRIA (3 dígitos, ponto, 3, ponto, 3, hífen, 2): bloqueia sempre.
#          Escrito por extenso de propósito: um CPF-molde literal aqui faz o gitleaks acusar o
#          próprio arquivo que define a regra — aconteceu ao commitar esta linha.
#   BARE — 11 dígitos crus: exige borda não-dígito antes E depois, então não casa como pedaço
#          de UUID, timestamp, hash ou número de processo.

# ── D-009 (corte Enio 2026-07-28) — DÍGITO VERIFICADOR ────────────────────────────────────────
#
# Um CPF real SEMPRE fecha o dígito verificador: é assim que ele é construído. Um número de 11
# dígitos que não fecha NÃO PODE ser um CPF. Ensinar isto ao gate não afrouxa nada — todo CPF de
# verdade continua sendo pego. É aritmética, não política de segurança.
#
# O que motivou: medido na base do daniel-falencias, 169 números de 11 dígitos sem rótulo têm DV
# INVÁLIDO (são ID de documento do PJe, protocolo, número de peça) contra 3 com DV válido. O gate
# acusava 169 falsos positivos para proteger no máximo 3 casos duvidosos — e era a 3ª vez em 4
# dias que ele parava trabalho legítimo (D-006 número de processo, D-008 CNPJ, agora ID do PJe).
# Gate que grita em falso ensina a usar override, e override vira hábito.
#
# A guarda do rótulo é INDEPENDENTE e vem primeiro: se a linha diz "CPF", o número sai bloqueado
# com DV válido ou não — CPF digitado errado no diário continua sendo CPF de alguém.
#
# ── PII-JANELA-JSONL-001, parte 2: custo (2026-08-06) ────────────────────────────────────────
# A aritmética é a mesma de 28/07, dígito por dígito, e os goldens de DV não mudam. O que mudou
# é COMO cada dígito é lido: era `printf | cut -c$i` dentro do laço — **23 processos por número**.
# Enquanto a guarda do rótulo era por linha, isso rodava no máximo uma vez por linha e não doía.
# Com a janela por achado (parte 1), um registro `.jsonl` com 400 números passou a custar ~9.200
# processos: **medido, 4,14s num arquivo só**. Um gate que trava 4s por arquivo é um gate que
# ensina override — foi o que matou o RG em 26/07 e o CNPJ em 27/07, e não vou reintroduzir o
# mesmo modo de falha pela porta do desempenho.
# Agora os dígitos saem por expansão de parâmetro (`${r%${r#?}}` = primeiro caractere), sem
# processo nenhum. **Medido depois: 4,14s → 1,98s**, mesmo arquivo, mesmo veredito.
# O resto (≈1,9s) é o `cut` da janela e os dois `grep` de rótulo, 3 processos por achado — e fica
# assim de propósito: some se a análise virar um `awk` por linha, ao custo de duas leituras da
# mesma regra em linguagens diferentes. Num pior caso PATOLÓGICO (249 KB numa linha só, 400
# números), 2s por arquivo não é o que mata um gate. Se um dia matar, o número está aqui.
# A equivalência não é argumento: `_tests/20-pii-dv.equivalencia.test.sh` compara as duas
# implementações em 20.000 números e exige divergência ZERO.
_cpf_dv_ok() {
  n=$(printf '%s' "$1" | tr -cd '0-9')
  [ "${#n}" -eq 11 ] || return 1
  # 11 dígitos iguais passam na conta do DV mas não existem como CPF. Antes isso era um
  # `grep -qE '^(.)\1{10}$'` (1 processo); a primeira tentativa de substituir sem processo foi
  # listar os dez números literais num `case` — e o R-SEC-001 barrou o commit, com razão: são
  # dez CPFs-molde escritos à mão dentro de um arquivo de segurança. A saída certa não era o
  # marcador `scan-ok`, era não escrever número nenhum. O laço abaixo já percorre os dígitos:
  # comparar cada um com o primeiro custa zero e não deixa molde no disco.
  _r=$n; _i=1; _s1=0; _s2=0; _d10=""; _d11=""; _iguais=1; _pri=${n%${n#?}}
  while [ -n "$_r" ]; do
    _c=${_r%${_r#?}}          # 1º caractere, sem subprocesso
    _r=${_r#?}
    [ "$_c" = "$_pri" ] || _iguais=0
    [ "$_i" -le 9 ]  && _s1=$(( _s1 + _c * (11 - _i) ))
    [ "$_i" -le 10 ] && _s2=$(( _s2 + _c * (12 - _i) ))
    [ "$_i" -eq 10 ] && _d10=$_c
    [ "$_i" -eq 11 ] && _d11=$_c
    _i=$(( _i + 1 ))
  done
  [ "$_iguais" = 1 ] && return 1
  [ "$(( (_s1 * 10) % 11 % 10 ))" = "$_d10" ] || return 1
  [ "$(( (_s2 * 10) % 11 % 10 ))" = "$_d11" ]
}

CPF_FMT_RE='[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}'
CPF_BARE_RE='(^|[^0-9])[0-9]{11}([^0-9]|$)'
CNPJ_RE='[0-9]{2}\.?[0-9]{3}\.?[0-9]{3}/?[0-9]{4}-?[0-9]{2}'
CNJ_RE='[0-9]{7}[-.]?[0-9]{2}\.?[0-9]{4}\.?[0-9]\.?[0-9]{2}\.?[0-9]{4}'

# ── RG: PII-RG-KERNEL-CALIBRA-001 (achado 2026-07-26, corte Enio na mesma sessão) ────────────
# ANTES: RG_RE='[0-9]{1,2}\.?[0-9]{3}\.?[0-9]{3}-?[0-9Xx]\b' — TODOS os separadores opcionais,
# então a expressão casava com QUALQUER corrida de 8-9 dígitos. Num repo de legal-tech isso é
# quase tudo: número de lei, data em slug de HTML gerado, placeholder de formato de processo.
# MEDIDO num leaf de legal-tech desta frota: 4 bloqueios = "Lei 11.101/2005" achatada num slug,
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

# ── PII-JANELA-JSONL-001 (achado 2026-08-05, corte Enio 2026-08-06) ──────────────────────────
#
# Todas as guardas por RÓTULO acima ("só é RG se a linha disser RG", "11 dígitos crus só são CPF
# se a linha disser CPF") e a própria EXCEPT_RE ("exemplo", "fictício") perguntavam pela LINHA
# INTEIRA. Em `.md` a linha é uma frase, e "mesma linha" é uma boa aproximação de "perto".
#
# Em `.jsonl` a linha É O REGISTRO INTEIRO — um transcript de conversa cabe em uma linha de
# centenas de KB. Ali "mesma linha" não significa nada, e o gate erra nas DUAS direções:
#   FALSO POSITIVO  — a palavra "CPF" numa ponta do registro qualifica um número de protocolo
#                     na outra ponta. Sintoma medido: um arquivo do daniel-falencias ficou fora
#                     do git por isso, e **sem override** — a pessoa não contornou o gate, parou.
#   FALSO NEGATIVO  — a palavra "exemplo" numa ponta isenta um CPF REAL na outra. Este é o caro:
#                     dado pessoal entra no git em silêncio, e nada avisa. Não foi reportado por
#                     ninguém: apareceu ao escrever o golden deste conserto.
#
# A correção é PROXIMIDADE, não afrouxamento — e a diferença é verificável: para qualquer linha
# de até ~200 bytes (todo `.md`, e os 21 casos de golden anteriores a este) a janela cobre a
# linha inteira e o comportamento é BYTE-A-BYTE O MESMO. O que muda é só o que "perto" quer
# dizer numa linha gigante. Golden nos dois sentidos: ./20-pii-hardblock.test.sh
#
# A janela é em BYTES, casando com o offset de `grep -ob` e com `cut -b`: em texto acentuado
# byte≠caractere, mas para uma régua de proximidade de 200 a diferença é irrelevante, e mantê-la
# na mesma unidade elimina a chance de cortar no lugar errado.
PII_JANELA=${EGOS_PII_JANELA:-200}

_janela() { # $1=linha  $2=offset do achado (0-based, de grep -ob)  $3=tamanho do achado em bytes
  _de=$(( $2 + 1 - PII_JANELA )); [ "$_de" -lt 1 ] && _de=1
  _ate=$(( $2 + $3 + PII_JANELA ))
  printf '%s' "$1" | cut -b "${_de}-${_ate}"
}

# Verdadeiro (exit 0) se ALGUM achado da linha sobrevive à sua própria janela. O laço percorre
# ocorrência por ocorrência: um registro `.jsonl` com 300 números tem 300 janelas independentes,
# e basta uma real para bloquear. Nenhum achado é descartado por corte de volume — o laço só
# para cedo porque já decidiu BLOQUEAR, nunca porque desistiu de olhar.
#
# ── O ATALHO, e por que ele NÃO é uma segunda regra ──────────────────────────────────────────
# Uma janela é um pedaço da linha. Logo: o que não está na LINHA não pode estar em janela
# nenhuma. Se a linha inteira não contém termo de exceção nem rótulo, todas as suas janelas
# também não contêm — e a resposta já está dada sem recortar janela alguma. Não é um caminho
# alternativo com regra própria: é a mesma regra, sabendo que não precisa perguntar de novo.
# As listas `LINHAS_EXC` / `LINHAS_ROT_*` são calculadas UMA VEZ POR ARQUIVO (3 processos) pelo
# laço chamador; aqui a consulta é `case`, sem processo nenhum.
# Medido no arquivo que motivou tudo isto (`.jsonl` de 2,1 MB, 1.587 linhas, 1.598 achados de
# RG dos quais só 42 linhas têm rótulo): sem o atalho, +8,3s sobre o gate antigo; com ele, o
# custo da janela some no ruído.
_achado_real() { # $1=linha  $2=regex do achado  $3=rótulo lógico  $4=nº da linha
  _linha="$1"; _re="$2"; _lab="$3"; _nl="$4"
  _lenta=0
  case "$LINHAS_EXC" in *" $_nl "*) _lenta=1 ;; esac
  case "$_lab" in
    RG_BARE)  case "$LINHAS_ROT_RG"  in *" $_nl "*) _lenta=1 ;; esac ;;
    CPF_BARE) case "$LINHAS_ROT_CPF" in *" $_nl "*) _lenta=1 ;; esac ;;
  esac
  if [ "$_lenta" = 0 ]; then
    case "$_lab" in
      # dígito cru sem rótulo em lugar nenhum da linha não é RG (PII-RG-KERNEL-CALIBRA-001)
      RG_BARE) return 1 ;;
      # 11 dígitos sem rótulo: só o dígito verificador decide (D-009) — segue no laço abaixo,
      # que agora não gasta `cut` nem `grep` por achado
      CPF_BARE) ;;
      # CPF/RG pontuado, sem exceção declarada em parte alguma da linha: bloqueia, como sempre
      *) return 0 ;;
    esac
  fi
  printf '%s' "$_linha" | grep -obE "$_re" 2>/dev/null | { while IFS= read -r _oc; do
      [ -z "$_oc" ] && continue
      _off=${_oc%%:*}; _tre=${_oc#*:}
      if [ "$_lenta" = 1 ]; then
        # `${#}` conta caracteres; o achado é dígito + no máximo uma borda de cada lado, então
        # em texto acentuado pode divergir do byte por 1-2. Numa régua de proximidade de 200
        # bytes isso não muda veredito nenhum — e evita um `wc` por achado.
        _jan=$(_janela "$_linha" "$_off" "${#_tre}")
        # exceção declarada (exemplo/fictício/FULANO) — agora tem de estar PERTO do número
        printf '%s' "$_jan" | grep -qiE "$EXCEPT_RE" && continue
        if [ "$_lab" = "RG_BARE" ]; then
          printf '%s' "$_jan" | grep -qiE "$RG_ROTULO_RE" || continue
        fi
        if [ "$_lab" = "CPF_BARE" ] && ! printf '%s' "$_jan" | grep -qiE 'CPF|C\.P\.F'; then
          # D-009 intacto: sem rótulo perto, só bloqueia se o número fechar o dígito verificador.
          _cpf_dv_ok "$_tre" || continue
        fi
      elif [ "$_lab" = "CPF_BARE" ]; then
        # atalho: nenhuma janela desta linha tem rótulo, logo D-009 decide sozinho.
        _cpf_dv_ok "$_tre" || continue
      fi
      exit 0
    done
    exit 1
  }
}

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

  # PII-JANELA-JSONL-001: quais linhas contêm exceção declarada / rótulo — UMA passada por
  # arquivo, para as três. É o que permite a `_achado_real` decidir sem recortar janela quando
  # a linha comprovadamente não tem o que qualificaria o achado (ver o atalho lá em cima).
  # Espaços nas pontas são de propósito: a consulta é `case "$LISTA" in *" $N "*)`, e sem eles
  # a linha 4 casaria dentro de "14" ou "42".
  LINHAS_EXC=" $(printf '%s\n' "$CONTEUDO_SEM_PROCESSO" | grep -niE "$EXCEPT_RE" 2>/dev/null | cut -d: -f1 | tr '\n' ' ') "
  LINHAS_ROT_RG=" $(printf '%s\n' "$CONTEUDO_SEM_PROCESSO" | grep -niE "$RG_ROTULO_RE" 2>/dev/null | cut -d: -f1 | tr '\n' ' ') "
  LINHAS_ROT_CPF=" $(printf '%s\n' "$CONTEUDO_SEM_PROCESSO" | grep -niE 'CPF|C\.P\.F' 2>/dev/null | cut -d: -f1 | tr '\n' ' ') "

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
      # PII-JANELA-JSONL-001: as três guardas (exceção declarada · rótulo de RG · rótulo/DV do
      # CPF) migraram para dentro de `_achado_real`, que as aplica na JANELA de cada achado em
      # vez de na linha inteira. Em linha curta o resultado é o mesmo; em `.jsonl` deixa de ser
      # loteria. As regras em si — PII-RG-KERNEL-CALIBRA-001 e D-009 — não mudaram uma vírgula.
      _achado_real "$CONTENT" "$RE" "$LABEL" "$LN" || continue
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

# ── TELEMETRIA DO PRÓPRIO GATE (L0-17, corte Enio 2026-07-28) ────────────────────────────
# Este gate foi calibrado TRÊS vezes em quatro dias (RG 26/07, CNPJ 27/07, dígito verificador
# do CPF 28/07), somando 180 falsos positivos medidos e nenhum verdadeiro positivo medido nas
# mesmas contagens. Só que "nenhum verdadeiro MEDIDO" não é "nenhum verdadeiro": ele nunca
# registrou o que barra, então a discussão sobre desligá-lo ou não era feita por impressão.
#
# Agora ele deixa rastro. Grava TIPO e ARQUIVO, jamais o valor (R-SEC-007 — o mesmo motivo
# pelo qual a saída na tela também não mostra). Em 30 dias existe número em vez de opinião.
#
# Fora do git de propósito: `~/.egos/logs/` é local da máquina. Um log de detecção de PII
# dentro do repositório viajaria para todo clone — inclusive para o do parceiro — e diria a
# ele quais arquivos nossos têm dado pessoal. O registro do guarda não pode virar o mapa.
_pii_log() { # $1=acao  $2=detalhe
  _d="${EGOS_PII_LOG_DIR:-$HOME/.egos/logs}"
  mkdir -p "$_d" 2>/dev/null || return 0
  printf '{"ts":"%s","repo":"%s","acao":"%s","achados":"%s"}\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$(basename "$REPO_ROOT")" "$1" "$2" \
    >> "$_d/pii-hardblock.jsonl" 2>/dev/null || true
}

if [ "$FOUND" = "1" ]; then
  # Só os rótulos (CPF/RG), sem arquivo:linha e sem valor: o que precisamos contar é
  # quantas vezes cada TIPO dispara, e caminho de arquivo em repo de cliente já é informação.
  _TIPOS=$(printf '%s' "$FINDINGS" | awk -F: '{print $NF}' | sort -u | tr '\n' ',' )
  _pii_log "$([ "${EGOS_LEAF_PII_OVERRIDE:-0}" = "1" ] && echo bloqueio-com-override || echo bloqueio)" "$_TIPOS"
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
  # Aviso também vira número: é aqui que mora a suspeita de que o gate seja barulhento sem ser
  # útil. Sem contar os avisos, "ele só atrapalha" seguiria sendo impressão contra impressão.
  _pii_log "aviso" "$AVISOS"
  echo "  [20-pii-hardblock] sem PII de pessoa ✅ · ${AVISOS} nos staged — público, não bloqueia"
else
  echo "  [20-pii-hardblock] sem PII detectada nos staged ✅"
fi
