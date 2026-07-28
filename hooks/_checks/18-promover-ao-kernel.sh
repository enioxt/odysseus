#!/bin/sh
# EGOS Pre-Commit — melhoria de check feita no leaf pertence ao kernel. WARN-only.
#
# POR QUE EXISTE (pergunta do Enio, 2026-07-27)
# --------------------------------------------
# "Quando outra janela se depara com melhorias que são do kernel, tem regras dizendo como
# agir? Estão valendo de fato?"
#
# As regras existiam: o pilar P3 ("instância melhorada promove sistema na mesma passada"), o
# trailer SYSTEM-UP: e o `system-up-advisory.sh`. Medido no mesmo dia: 34 de 200 commits com o
# trailer — 17%. E três buracos:
#   · o advisory só olha commits que começam com `fix` — `feat` passava batido;
#   · ele fala no commit-msg, DEPOIS da mensagem escrita — lembrete tardio, não reflexo;
#   · e só existe no kernel. O leaf-kit propaga o pre-commit, não o commit-msg nem o advisory.
#
# O terceiro é o pior, porque é invertido: a janela que trabalha num LEAF é justamente a que
# mais topa com melhoria de kernel — ela está usando o kernel na prática — e era a única que
# nunca era lembrada. Mesmo formato do defeito que o piso veio consertar: o conteúdo propaga,
# o lembrete não.
#
# O SINAL, e por que ele é preciso: um check local que não bate com NENHUMA versão que o
# kernel já teve é, por definição, coisa que alguém escreveu aqui. Se está sendo commitado
# agora, é melhoria de instância acontecendo — o momento exato de perguntar se ela sobe.
#
# Só fala sobre arquivo STAGED. Isso não é economia de CPU: é o que separa reflexo de
# banner-blindness. Avisar em todo commit sobre um arquivo que ninguém tocou treina a pessoa
# a ignorar o aviso, e aviso ignorado é o mesmo que aviso ausente — que é a doença que este
# repositório inteiro persegue.

KERNEL="${EGOS_KERNEL_PATH:-$HOME/egos}"
KERNEL_KIT="$KERNEL/templates/leaf-kit/hooks/_checks"
[ -d "$KERNEL_KIT" ] || exit 0   # sem kernel não há com o que comparar

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
case "$REPO_ROOT" in "$KERNEL"|"$KERNEL"/*) exit 0 ;; esac   # no próprio kernel não faz sentido

STAGED=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null \
  | grep -E '(^|/)(hooks|\.egos-hooks)/_checks/[^/]+\.sh$' \
  | grep -v '\.test\.sh$')
[ -n "$STAGED" ] || exit 0

_avisou=0
for F in $STAGED; do
  NOME=$(basename "$F")
  ALVO="$REPO_ROOT/$F"
  [ -f "$ALVO" ] || continue

  if [ ! -f "$KERNEL_KIT/$NOME" ]; then
    echo "  💡 PROMOVER? $NOME não existe no leaf-kit do kernel — check inventado aqui."
    echo "     Se serve para outros repositórios, ele pertence ao kernel (P3: instância melhorada"
    echo "     promove sistema). Se é só deste repo, ignore — mas decida, não deixe por omissão."
    _avisou=1
    continue
  fi

  # Igual ao kernel: nada a promover.
  cmp -s "$ALVO" "$KERNEL_KIT/$NOME" && continue

  # Divergente. Bate com alguma versão PASSADA do kernel? Então é só cópia velha — o
  # leaf-kit-sync resolve, e avisar aqui seria ruído.
  H=$(git hash-object "$ALVO" 2>/dev/null)
  ANTIGA=0
  for C in $(git -C "$KERNEL" log --all --format=%H -- "templates/leaf-kit/hooks/_checks/$NOME" 2>/dev/null); do
    B=$(git -C "$KERNEL" rev-parse "$C:templates/leaf-kit/hooks/_checks/$NOME" 2>/dev/null)
    [ "$B" = "$H" ] && { ANTIGA=1; break; }
  done
  [ "$ANTIGA" = "1" ] && continue

  echo "  💡 PROMOVER? $NOME não bate com NENHUMA versão do kernel — foi editado aqui."
  echo "     Calibração deliberada deste repositório, ou melhoria que todo mundo deveria ter?"
  echo "     Se é melhoria: leve ao kernel na MESMA passada (P3) e ponha 'SYSTEM-UP: <o que subiu>'"
  echo "     no corpo do commit. Se é calibração local, diga isso no commit — para a próxima"
  echo "     janela não desfazer sem saber."
  _avisou=1
done

[ "$_avisou" = "1" ] && echo "     (aviso — não bloqueia. SSOT: docs/governance/LEAF_GATE_COVERAGE.md §9)"
exit 0
