#!/bin/sh
# EGOS Pre-Commit Check 21 — os 5 pilares e a ética no README (PILARES-FIACAO-001)
#
# POR QUE ESTE CHECK EXISTE, medido em 2026-07-28: 32 READMEs na frota, 6 citavam os pilares,
# 3 tinham o mantra, e o do próprio kernel — 449 linhas — não tinha nenhum dos dois. A base do
# sistema não estava na porta de entrada do sistema. O rollout arrumou 26; este check é o que
# impede os 26 de voltarem a apodrecer, que é a doença que a L0-15/L0-17 nomeiam.
#
# ── POR QUE ELE NÃO CALCULA HASH NENHUM ────────────────────────────────────────────────────
# A versão do texto-mãe é calculada em UM lugar só (`scripts/pilares-sync.ts`, no kernel) e
# escrita em `PILARES_VERSAO`, aqui do lado. Este check faz comparação de texto e mais nada.
#
# Reimplementar o hash em shell criaria uma segunda definição da mesma regra, em outra
# linguagem, com outro tratamento de espaço em branco — e verificador que reimplementa a regra
# é erro catalogado nesta casa: quando as duas divergem, a errada é sempre a que ninguém olhou.
# O arquivo de versão viaja ao lado deste script, então na máquina do sócio (sem kernel) vale a
# versão congelada na sincronia, e na máquina com kernel vale a do kernel — que é exatamente a
# semântica do resto do kit.
#
# WARN, nunca BLOCK: é a regra de entrada no piso ("check novo entra em WARN e só vira BLOCK
# depois de calibrado com a frota rodando"), e também bom senso — barrar commit por README
# desatualizado é como se ensina alguém a usar `--no-verify`.

[ -f "README.md" ] || exit 0

CHECK_DIR=$(dirname "$0")
ARQ_VERSAO="$CHECK_DIR/PILARES_VERSAO"

# O que o README declara: bloco gerado (`v=`) OU adaptação declarada (`deriva=`).
DECLARADA=$(sed -n 's/.*EGOS-PILARES-BEGIN v=\([0-9a-f]\{12\}\).*/\1/p;s/.*EGOS-PILARES-ADAPTADO deriva=\([0-9a-f]\{12\}\).*/\1/p' README.md | head -1)

if [ -z "$DECLARADA" ]; then
  # Distinguir "nunca teve" de "tinha e alguém tirou" não dá para fazer aqui sem falar com o
  # git de forma que funcione em todo repo da frota. Então a mensagem serve aos dois casos.
  echo "  ⚠️  [21-pilares] README.md sem o bloco dos 5 pilares do EGOS."
  echo "      A ética que rege este sistema não está na porta de entrada dele."
  echo "      Conserto:  bun \$EGOS_KERNEL_PATH/scripts/pilares-sync.ts --frota --write"
  echo "      Já adaptou o texto à mão? Declare, para o drift ficar visível:"
  echo "        <!-- EGOS-PILARES-ADAPTADO deriva=<versao> registro=<dev|produto|vitrine> motivo=<...> -->"
  exit 0
fi

if [ ! -f "$ARQ_VERSAO" ]; then
  # Sem régua não se dá nota — e dizer "está em dia" sem ter com o que comparar seria
  # exatamente o falso-verde que este kit existe para não produzir.
  echo "  ℹ️  [21-pilares] bloco presente (v=$DECLARADA); versão de referência ausente neste kit — não dá para comparar."
  exit 0
fi

ESPERADA=$(head -1 "$ARQ_VERSAO" | tr -d '[:space:]')

if [ "$DECLARADA" != "$ESPERADA" ]; then
  echo "  ⚠️  [21-pilares] o bloco dos pilares está DESATUALIZADO neste README."
  echo "      declarado: $DECLARADA · esperado: $ESPERADA"
  echo "      Conserto:  bun \$EGOS_KERNEL_PATH/scripts/pilares-sync.ts --frota --write"
  echo "      (adaptação declarada: reescreva o texto e atualize o \`deriva=\` — a §9 pede as"
  echo "       superfícies atualizadas na MESMA passada em que o texto-mãe muda.)"
fi

exit 0
