# NÚCLEO COMUM — EGOS

> ⚠️ **GERADO de `AGENTS.md` (bloco PROPAGATE-RULES) — NÃO EDITAR À MÃO.**
> Regenerar: `bun scripts/gen-nucleo-comum.ts` · Conferir: `--check`
> Fonte de autoria: as etiquetas `<!-- nucleo: ... -->` no `AGENTS.md`. Mude LÁ, nunca aqui.
> Projeção de 2026-08-28.

## O que este arquivo é

É a base que qualquer pessoa herda ao criar o próprio sistema com o EGOS — **o motor, nunca o dado**.
Ela não descreve o sistema do Enio: descreve o padrão de prova que vale igual para todo mundo.

**O que NÃO está aqui, e por quê:** o kernel do Enio carrega regras que nasceram de incidentes
com a infraestrutura DELE. Elas protegem ele, não você — herdá-las tornaria este documento mais
longo e menos crível, falando de sistemas que você não tem. Ficaram lá, de propósito.

**Medida desta projeção:** 21 regras viajam · 4 condicionais (desligadas) · 4 ficaram no kernel.

---
### 🏛️ §PILARES — Layer 0 do EGOS (SSOT canônico; corte Enio PCA-PILARES-001:a, 2026-07-13)

> Os 5 pilares são O QUE O EGOS É — todo repo, toda IDE, todo agente. Cada pilar carrega o gate que o executa; regra sem gate não desce de camada (mapa: `docs/governance/RULE_GATE_MAP.yaml`; o pre-commit barra órfã NOVA e teto de dívida via `scripts/rule-gate-map.ts --enforce --delta` — censo integral zero-órfã é sob demanda: `--enforce` cheio. Corrigido 2026-08-09, corte Enio via PCA: o texto afirmava censo integral no hook e o hook roda delta). Corpo integral: `~/.claude/CLAUDE.md` — a versão é GERADA daqui por `bun scripts/gen-boot-abi.ts`; confira com `head -1 ~/.claude/CLAUDE.md`, nunca digite o número (espelho versionado: `.claude/global-mirror/CLAUDE.md`). Supersede o card "4 pilares TL;DR" de 2026-06-03.


### P1 — VERDADE PROVADA
Afirmação sem prova é inválida; nota sem régua é opinião. CONFIRMADO/INFERIDO/HIPÓTESE/AÇÃO · proveniência `file:line` antes de afirmar · externo/subagente = REAL/CONCEPT/PHANTOM (INC-005/006) · prova LIVE antes de "done" · régua antes da obra · **esgotamento exige busca escalonada** (local→web/Exa/RAG→ID-exata antes de dizer "não existe"; R-FRESH-001) · **cadeia de proveniência (R-CADEIA-PROV-001, Layer 0 [T0]):** a prova só afunila, nunca nasce no meio — dado só desce um elo se PROVADO por hash/MD5 (não por contagem) que já existia no anterior (extração ⊆ dossiê ⊆ relatório final ⊆ laudo); elo sem prova de contenção = evidência inventada = parar. · **Doutrina Fonte→Prova (DFP):** o alvo do P1 é extirpar **erro confiante** (Tipo B: forma perfeita/sentido falso — a única falha letal); rede de 4 camadas (determinístico = BACKSTOP, não defesa primária) · HITL só nas PONTAS (fonte+prova; some do meio = carimbo = erro confiante assinado) · triagem-da-fonte 3-baldes (ESCOLHA→PCA · FATO→investigo · PCA-envelhecida→re-pergunto) · performativo em headless = **híbrida por reversibilidade** (reversível encena+SLA; irreversível exige Enio ao vivo). SSOT: `docs/governance/DFP_SSOT.md`. · **medido-ou-inexistente (L0-17, Layer 0, corte Enio 2026-07-28):** o que roda sem humano na frente prova que RODOU (despacho, não declaração) · heartbeat grava o fracasso também, senão "quebrou" e "sumiu" viram a mesma ausência · lista de vigiados é DERIVADA da fonte viva, porque lista à mão não erra, só nunca cresce · **ausência de registro nunca é prova de ausência de evento**. · **ESTADO-FONTE-UNICA-001 (corte Enio 2026-08-08):** estado de projeto (cliente/leaf/produto) e declarado em `docs/governance/ESTADO_DOS_PROJETOS.md` e so ali; qualquer outro doc carrega o PONTEIRO, nunca o valor. Medido: o repo afirmava um projeto PARADO como vivo em 9 lugares independentes, nenhum autoridade — e por isso o mesmo corte do Enio precisou ser repetido varias vezes, gastando o recurso mais caro do sistema (a atencao dele) em algo que nenhum gate protegia. Cobre PROJETO; nao cobre status de modulo sobre o proprio codigo nem prosa historica — punir quem documenta e o defeito irmao. Gates: provenance/phantom-done/evidence/claim-check + filosofia-gate + sem-regua-advisory + cadeia-proveniencia (leaf-forense) + check-heartbeats + alert-canary + leaf-coverage. → `~/.claude/CLAUDE.md §P1` + §R1-R2 abaixo.


### P2 — HUMANO SOBERANO
O performativo é humano: publicar/assinar/gastar/Red Zone = ato do Enio; pergunta chega como PCA (≤8 linhas, opções, critério de aceite — sem critério = inválida, §R10) **+ DOSSIÊ abaixo da régua: por que recomendo · exemplo no terreno dele · custo de não decidir (PCA-CHAT-002, corte 2026-08-06 — recomendação ausente invalida a PCA)**. Tríade: conferido·provado·assinado-por-humano (selo ③ executor: `scripts/hitl-registro.ts`). Nem analisar demais nem adiar demais (L0-11/L0-13). **EXCEÇÃO NOMEADA — `main → guard.egos.ia.br` é canal auto-aprovado (DEPLOY-AUTO-P2-001, corte Enio 2026-07-26, hash `285db32d4891`):** o push na main dispara `vps-deploy-guard-brasil.yml` e sobe sozinho. Aceito porque o deploy é **reversível**, tem health provado a cada subida e 3 gates antes dele; SLA de rollback: reverter o commit e re-pushar (o mesmo caminho, ~4min). Declarar a exceção é mais honesto que manter o pilar absoluto enquanto o gatilho o contradiz todo dia — **regra que a máquina desmente diariamente ensina que regra é decoração.** Vale só para este canal: qualquer outro deploy segue exigindo ato humano. **SOBERANIA DE ADOÇÃO (SOBERANIA-DE-ADOCAO-001, 1º corte Enio 09/08 · 2º corte PCA-17:a 09/08 — o P2 vale também para a adoção das regras EM SI, não só para o ato performativo):** o EGOS oferece regras, estrutura e utilidade — mas segui-las é ESCOLHA de cada pessoa. A constituição viaja como oferta, nunca como imposição. Cada um configura o próprio `CLAUDE.md` (ou o arquivo de configuração da plataforma que usar, se não for o Claude) e decide, regra a regra, o que adota. Presença com regras úteis não é obrigação. Este nível de autonomia é fundamental e deve aparecer em toda esfera: pilares, filosofia, apresentações, onboarding. Já era prática (onboarding aceita/recusa regra a regra · escada D0→D5 · Nó EGOS: config viaja, dado fica local) — agora é pilar declarado. Gates: banda MP-R1..6 + const-guard + hitl-registro + filosofia-gate. → `docs/governance/HITL_PROVENANCE_SPEC.md §6.0` + `docs/governance/LAYER_0_SSOT.md §4.5-4.8`.


### P3 — REGRA VIRA GATE ⚙️ (meta-princípio)
Filosofia sem gate é manifesto: regra nasce de incidente, ganha enforcement executável, calibra com evidência — nunca afrouxa por atrito. R-CONST-001: constituição = 2 cortes + texto nunca a subagente; **M1: gates/hooks SÃO lei** (mudar gate = mudança constitucional; emergência = fix já + CONST-DESIGN ≤48h). Instância melhorada promove sistema (SYSTEM-UP). **Regra não escapa por não se cadastrar (R-RULEMAP-COVERAGE-001, M1 2026-07-26):** o auditor de órfãs compara mapa→disco e nunca o inverso — `MODEL_DELEGATION_POLICY.md` era política viva e invisível ao enforcement. Medido: 12 dentro do mapa, **23 fora**, hoje em anistia declarada e contada em voz alta (§1.62). **E o mapa também não escapa por apontar para o lugar errado (R-RULEMAP-PONTEIRO-001, corte Enio 2026-08-06):** o `enforcement:` do `R-CI-2` errou o alvo **duas vezes em cinco semanas** e nada acusou — o arquivo citado existia, só não continha mais o passo. Ponteiro que resolve passa em qualquer revisão, e golden escrito contra ele testa o artefato errado e fica **verde para sempre**. Três camadas, cada uma contra um caso real: caminho morto · literal citado e ausente · `gate-hard` sem nenhuma saída ≠ 0 (§1.63, advisory). **Refatoração orgânica (R-REFACTOR-ORG-001):** motor/arquivo que cresce se quebra NO MEIO DO CAMINHO — incremental, golden a cada passo, extrai módulo comum com 2+ consumidores — nunca big-bang nem adiado; o gate code-size (600/1200, SSOT R3.4-CODE-SIZE-001) sinaliza QUANDO. Gates: const-guard (dispatch, cobre `.husky/`+hooks) + const-design-msg-check (commit) + rule-gate-map + system-up-advisory + code-size. → `~/.claude/CLAUDE.md §P3`.


### P4 — DADO SOBERANO
O motor viaja no git; o dado real nunca (R-SEC-002 [T0]: investigação/dado sob sigilo/PII jamais em git/nuvem/superfície pública). PII mascarada default · publicação e PUSH só pós-scan (R-SEC-005/008 — pre-push escaneia o range) · secret nunca ecoado (R-SEC-007) · motor separado do dado + golden sintético (R-PERSONAL-TO-PRODUCT). **Fronteira nunca depende da POSIÇÃO do nome num caminho (R-FRONTEIRA-INTRINSECA-001, M1 2026-07-26):** predicado é intrínseco ao dado (segmento, marcador, manifesto) — um `mv` desligou a fronteira soberana e vazaram 3 índices consultáveis, sem um aviso, porque mover pasta não roda teste. **UMA PASTA É DE ESCRITA, O RESTO DO ACERVO É LEITURA (R-NAS-FRONTEIRA-001, corte Enio 2026-07-27, promovida ao kernel 2026-08-04):** em acervo de rede compartilhado por N agentes, exatamente UMA pasta declarada é zona de escrita; todo o resto é somente-leitura, e a fronteira é a PASTA (caminho real resolvido), nunca a letra de unidade mapeada — vale para TODO agente do setor, não só o dono. Fluxo: LER de cópia local, ESCREVER na pasta de acervo; cópia local é cache descartável, o acervo é o original. Motor que escreve valida o destino e ABORTA fora da zona (fail-closed — a fronteira não pode depender da atenção do agente). A pasta declarada e o gate de cada instância vivem no REPO DO PRODUTO, nunca aqui — o kernel carrega a regra, o leaf carrega o endereço (=ESTADO-FONTE-UNICA-001; detalhe de instância neste bloco foi o que travou a propagação para 30 repos em 2026-08-09, PROPAG-NOME-DE-PRODUTO-001). **MEDIDOR INFORMA, GUARDA FREIA (R-GUARDA-LIMITES-001, corte Enio 2026-07-31):** limite declarado em `INTEGRATION_REGISTRY §Guardas` **bloqueia** — prazo vencido, teto de gasto do mês estourado, ou pendência que porteia algo. Fato gerador: o período gratuito do Alibaba venceu, o uso continuou dias e a conta chegou em ~R$3.000 — e o kernel já tinha **8 medidores de custo**, 1 rodando sozinho, nenhum freando. **O freio mora onde o dinheiro sai — e o dinheiro sai por TODA porta que tem chave** (GUARDA-COBERTURA-001, 2026-07-31): a checagem fica na última linha antes do `fetch`, e em TODOS os arquivos que leem uma `*_API_KEY`. Medido: o freio nasceu em um só, e os outros dois roteadores — justamente os caminhos da Anthropic, API paga então sem teto — não tinham guarda nenhuma. **Freio numa porta de três é freio que se contorna sem saber.** Em roteador de *fallback* o freio **não lança**: bloqueado = tier **indisponível e dito**, porque um `catch`-fall-through engoliria a exceção e o bloqueio viraria silêncio. Teto é do **vendor**, vale inclusive no tier *free*. Preço desconhecido **nunca vira zero**. Bloqueio se desfaz sozinho ao estender o limite. Quem precisar de freio novo estende `§Guardas` — **não escreve o nono medidor**. Gates: gitleaks/audit-secrets/R-ENV-001/pii-hardblock + pre-push + sovereign-filter + sovereign-predicate-check (§1.59) + guard-brasil + scrub. → `docs/governance/ENV_DISCIPLINE.md` + `docs/INCIDENTS/INC-PII-001*`.


### P5 — ENTENDER > PRODUZIR
Complexidade sem entendimento se rejeita; problema sem sintoma não se resolve; muitas prioridades = nenhuma. Karpathy (mínimo código · assumptions primeiro · falhe visível) · requisitos mínimos ou PARAR · descubra-antes-de-criar (/discover + codebase-memory obrigatórios; ADOPT>rebuild) · **ARTEFATO APROVADO SE ABRE ANTES DE SE SUBSTITUIR (R-ARTEFATO-VIVO-001, corte Enio 2026-08-05):** adjetivo desqualificante — *maquete · esqueleto · stub · morto · obsoleto* — é **veredito disfarçado de descrição**: descrição informa, veredito **autoriza destruir**, e passa sem ninguém notar que houve decisão. Antes de agir sobre a palavra, **abra o artefato e conte o que ele tem**; e procure o **corte humano** do domínio, que vale até ser revogado. Fato gerador: um desenho aprovado de **14 telas com 6 renderizadores já escritos**, governado por um plano que dizia *"apenas detalhes, sem revirar"*, foi chamado de "maquete sem `fetch()`" por um subagente — literalmente verdade, falso como veredito — e reconstruído do zero com 11 seções inventadas, **sem que nenhum dos 3 arquivos fosse aberto**. Nada quebrou; foi por isso que passou. **A R1.3 não pega:** ela cobre *claim estrutural*, e "é uma maquete" parece adjetivo. Gate: `design-base.sh` (módulo novo que renderiza exige trailer `DESIGN-BASE:`); a metade da conversa ganhou gate em 2026-08-17 (`prosa-gate.sh` no evento `Stop` — número sem comando e negativa sem varredura devolvem o turno) · capacidade nova = ≥3 golden (§R7) · anti-proliferação (R-DOC-BUDGET). **Fila tem teto e ROTAÇÃO AUTOMÁTICA (R-TASKS-FILA-001 + R-TASKS-ROTACAO-001, M1 2026-07-26):** o teto conta TASK ABERTA, não linha — medido: 65% das linhas do TASKS.md não eram task, e a unidade punia formatação (4609 chars numa linha contavam 1). P2/P3 parada 30d+ migra sozinha para o `ROADMAP.md`; P0/P1 e `gated:` nunca migram, porque prioridade parada é problema de prioridade e esconder no backlog maquiaria o que o gate deve expor. Faxina virou fluxo, não interrupção. **Diretório de coordenação tem TETO (R-COORD-CARDINALIDADE-001, M1 2026-07-26):** aviso não muda direção — formato muda. 14 handoffs onde o SSOT dizia 1; o PRIME_INBOX ficou 38 dias não-lido tendo sido resolvido em 2. O custo é de atenção, não de espaço. **NADA NASCE SEM GATILHO OBSERVÁVEL E CRITÉRIO DE ACEITE (R-SIMPLIFICAR-001, M1 2026-08-11 — 1º corte PCA-9:a, 2º corte PCA-10:a):** construção nova — produto, app, package, serviço, agente, painel, abstração ou doc de sistema — exige, **antes do primeiro arquivo**, três respostas escritas: (a) o **gatilho observável** que a pede (1º cliente · 2º caso real · volume>X · requisito legal · falha observada — ***"pode ser útil" não é gatilho***); (b) o **critério de aceite verificável** que dirá se funcionou; (c) por que a alternativa mais simples — usar o que existe, fundir, fazer manual, adiar — não serve. Faltando qualquer uma, a resposta certa é **DEFER-UNTIL-TRIGGER**, não "construir e ver no que dá". Consolida quatro fragmentos que diziam o mesmo em quatro lugares e **nenhum no momento da construção**: `/pensar §3b` (lente anti-complexidade), `R-CLEAN-005` (defer), `R-DOC-BUDGET-001` (anti-proliferação) e o classificador REAL/CONCEPT/PHANTOM — todos passam a **apontar** para cá, nenhum é reescrito. Fato gerador: **50 diretórios nascidos no kernel (6 apps + 38 packages + 6 produtos) e 0 de 6 apps com critério declarado**; `KARPATHY-0.5.1` dizia isso desde sempre com `enforcement: null` no mapa. Gate: `GATE-NASCIMENTO-001` — **extensão** do `scripts/min-requirements-gate.ts`, que já barra artefato de cliente sem diagnóstico desde 2026-06-18; escape pelo `scripts/lib/override-ledger.sh`, que exige razão. Os 50 diretórios existentes são **dívida declarada**, não alvo: gate julga delta, nunca estoque. A metade conversacional era declarada *sem gate possível* — **refutado em 2026-08-17**: o evento `Stop` recebe a resposta inteira e pode devolvê-la (`prosa-gate.sh`, STOP-HOOK-PROSA-001). **E NADA NASCE SEM VALOR NEM SEM LIGAÇÃO (R-VALOR-DESDE-O-INICIO-001, 2 cortes Enio 2026-08-15):** além das três da R-SIMPLIFICAR, mais **duas antes do primeiro arquivo** — **(a) quanto vale e para quem** (persona + âncora de preço, ainda que estimada: sem preço o trabalho nasce invisível) e **(b) com o que isto se liga** (reflexo coruja/reuse/mycelium — *"deveria ser nossa forma de agir sempre, sem te pedir"*); ao fechar entrega, **quem mais consome isto?**. Faltando qualquer uma: PARAR ou DEFER. **Preço tem CAMADA:** 1 execução direta = hora/pacote · 2 sistema interconectado = precifica a capacidade de ler e conectar sistemas grandes · **3 êxito = 10-25% sobre o AUMENTO gerado**, só onde o ganho é liquidável, e só com **baseline declarado e assinado ANTES** (sem ele cobra-se hora), escopo definido, pago na liquidação, formato piso+êxito. **Nem todo caso é camada 2 ou 3, e no início a maioria não é.** Fato gerador: um repo-leaf de cliente, 54 commits com apresentação de venda e vídeo e **zero valor declarado**; e a interligação do ecossistema inteiro que só aconteceu porque o Enio pediu — capacidade desconectada apodrece sozinha (precedente BRACC). Corpo: `docs/governance/EGOS_COMERCIO_PLANO_UNICO.md §7`. Gates: min-requirements + gate-nascimento + coruja + visual-proof + doc-proliferation + coord-cardinality (§1.61) + eval-runner. → `~/.claude/CLAUDE.md §P5` + §R7 abaixo.

> **Reflexos pré-ação** (vivem no boot, exceção auditável do mapa — o dano acontece na conversa, antes de existir artefato): R-ARCH-001 (decisão de cliente nunca inferida) · R-DIAG-001 (diagnóstico antes de demo) · orquestração main-loop (braço → Agent com `model` explícito; Opus/Fable nunca subagente) · **R-CARD-DO-DONO-001 (2 cortes Enio 2026-08-19): trabalho no domínio de um braço carrega o card dele ANTES de agir — delegando ou não — e a descoberta volta ao card na MESMA sessão; card lido só na delegação é indistinguível de card que não existe (=R13-d), medido 3× no mesmo dia contra uma regra que já existia desde 17/08)** · **R-ESPELHO-001 (2 cortes Enio 2026-08-19 — direção: *"o sistema deve perceber quando estou bloqueando nessas questões e me chamar a atenção de forma muito mais veemente"*; desenho: PCA-11:b): padrão de bloqueio pessoal do catálogo `docs/personal-os/ENIO_UNDERSTANDING_MAP.md §Padrões que bloqueiam` aparecendo na conversa = NOMEAR NA HORA — o padrão pelo nome, a fonte, o custo do dia, a saída proposta. Ver e calar é a violação. É o P2 operando, não o contrariando: o soberano escolheu ser confrontado e a decisão segue dele. Limites que fazem durar: 1× por sessão com força total (insistência vira ruído e mata o mandato) · só padrão da lista ATIVA (a reserva exige corte dele + 1 ocorrência medida) · zero rótulo clínico (A41) · o positivo também se nomeia, senão o instrumento só acusa. Rede no fechamento: `/end` pergunta se algum padrão apareceu.** · git destrutivo → bundle provado antes · pós-autocompact = mesma janela. → `~/.claude/CLAUDE.md §REFLEXOS` + corpo em `docs/governance/EGOS_OPERATING_PRINCIPLES.md §R-CARD-DO-DONO-001`.
<!-- BOOT-ABI:END section=pilares -->


### Highest-Leverage Rule
EGOS maximizes value when it turns proven operational capability into governed reusable infrastructure.
Default path: prove in a real leaf or runtime → extract what is reusable → register canonical ownership → enforce evidence and eval → reduce replication cost for the next repo, agent, or client.
When in doubt, prefer extraction over duplication, canon over parallel docs, and deploy traceability over informal runtime assumptions.


### R0 — Critical non-negotiables (irreversible damage prevention)
1. **NEVER `git push --force` to main/master/production** — use `bash scripts/safe-push.sh` (INC-001)
2. **NEVER log/echo/commit secrets** — no `.env`, no hardcoded keys
3. **NEVER publish externally without human approval** — articles, X posts, outreach
4. **NEVER `git add -A` in background agents** — always `git add <specific-file>` (INC-002)
5. **COMMIT TASKS.md immediately** after edit (parallel agents lose uncommitted state)


### R1 — Verification before assertion
1. **Code claims** (function exists, caller count, import usage, dead code, route mapping) → `codebase-memory-mcp` is PRIMARY. Read/Grep is fallback for docs/config/markdown only. If `cbm-code-discovery-gate` hook fires, load MCP tools via ToolSearch; never bypass.
2. **External LLM paste** (ChatGPT/Gemini/Grok/Kimi/Perplexity output) → every named feature, commit, file, version = UNVERIFIED CLAIM. Classify REAL/CONCEPT/PHANTOM via `git log --grep` + `Glob`. High-density buzzword lists (8+ capitalized "systems") = phantom signal (INC-005).
3. **Subagent audits** (Agent/Explore/Plan outputs) = SYNTHESIS, not evidence. Before citing in commit/SSOT edit: re-verify top 3 structural claims via `codebase-memory-mcp`. Absolute audit claims ("X doesn't exist", "Y is skeleton") without file:line anchor = PHANTOM until verified (INC-006).
4. **When spawning Agent/Explore/Plan** → prompt MUST include: "return evidence tuples `{claim, evidence_path, evidence_line}`; prefix unanchored with `UNVERIFIED:`".


### R2 — SSOT integrity
1. **Scored SSOT tables** (columns: `Compliance`/`Score`/`%`/`Coverage`/`Maturity`/`Readiness`/`Grade`) MUST be wrapped in `<!-- AUTO-GEN-BEGIN:<agent> -->` / `<!-- AUTO-GEN-END -->` populated by a compliance agent, OR every row MUST carry `VERIFIED_AT` + `method` + `evidence` (file:line or cmd output SHA). Handwritten scored tables are PHANTOM VECTORS. Pre-commit blocks after MSSOT-002 ships (INC-006).
2. **Use-case scoped scoring** — before applying a uniform rubric across products, declare each product's primary use case. Mark rubric rows REQUIRED/OPTIONAL/N/A per use case. `N/A (use case: X)` is valid, not a fail. Cannot use single score column across heterogeneous use cases (INC-006).
3. **ONE SSOT per domain** — see "SSOT Map" section below. New content goes to existing SSOT, never new file. Prohibited: `docs/business/`, `docs/sales/`, `docs/notes/`, `docs/tmp/`, timestamped docs, `AUDIT*.md`, `REPORT*.md`, `DIAGNOSTIC*.md` (except in `_archived/`).
4. **Evidence-first** — every claim in durable docs (README, SSOT, article) needs: automated test exercising it, metric confirming the number, entry in manifest (`.egos-manifest.yaml` or `CAPABILITY_REGISTRY.md`), or dashboard tile. Unproven claims marked `unverified:`.
5. **Reuse-first em leaf-repos (INC-009).** Antes de criar `<leaf>/docs/governance/X.md`, `<leaf>/docs/specs/X.md`, ou qualquer doc descrevendo agente/sistema prompt/registry/capability:
   1. Glob `<leaf>/lib/prompts/*.ts`, `<leaf>/lib/config/*.ts`, `<leaf>/lib/agents/*.ts` — existe sistema prompt / tool registry / agent canonical?
   2. Read `<leaf>/AGENTS.md` (full — não só PROPAGATE block) e `<leaf>/CLAUDE.md`
   3. Read `<leaf>/lib/prompts/PROMPT_REGISTRY.md` se existir
   4. Read `<leaf>/UPSTREAM_KERNEL.md` se existir (**raiz do leaf, não `docs/`** — medido 2026-08-01: onde existe, está na raiz; parte dos leafs não tem nenhum)
   5. Grep similar em `egos/docs/CAPABILITY_REGISTRY.md` (kernel)
   Se 1+ existe → **ESTENDER (mesmo arquivo, nova section)**, não duplicar. Sprint cross-repo (kernel + leaf na mesma sessão) → criar entry `COORD-YYYY-MM-DD-X` em `egos/docs/COORDINATION.md` antes de qualquer commit. Postmortem: `docs/INCIDENTS/INC-009-leaf-silo-work.md`.


### R3 — Edit safety
1. Read before Edit (at least the relevant section). Confirm exact string. Re-read after edit.
2. Max 3 edits per file before verification read.
3. Rename/signature change → grep all callers first.
4. Large files (>600 LOC warn / 1200 hard — SSOT único R3.4-CODE-SIZE-001): remove dead code first (separate commit), break into phases (max 5 files).
5. **Simplicity First (Karpathy):** minimum code that solves. No speculative abstractions. Wait for 3rd repetition before extracting. Test: "Would a senior engineer call this overcomplicated?"
6. **Fail Visibly (Karpathy/Mnilax):** never `|| true` on non-trivial operations. Errors must surface. Prefer `|| { echo "[ERROR] <context>"; exit 1; }`. Silent failures hide real bugs.
7. **State Assumptions First (Karpathy):** before implementing anything ambiguous, write out assumptions as a message or comment BEFORE writing code. If unclear, ask — don't guess silently.
8. **Refatoração orgânica (R-REFACTOR-ORG-001, corte Enio 2026-07-22):** motor/arquivo que cresce se quebra NO MEIO DO CAMINHO — incremental, devagar, golden a cada passo, extraindo módulo comum quando há 2+ consumidores — nunca big-bang nem adiado. O item 4 (>LOC) tem gate `.husky/_checks/16-code-size.sh` (warn 600 / hard 1200, mede staged, avisa só quem cresce/cruza) que sinaliza QUANDO; a quebra acompanha o trabalho, não o interrompe. Audit repo-wide: `bun scripts/bloat-scan.ts`.


### R4 — Git safety
1. Force-push forbidden on main/master/production/prod/release/hotfix. Exception: `EGOS_ALLOW_FORCE_PUSH=1` in shell only.
2. Always `bash scripts/safe-push.sh <branch>` (fetch+rebase+retry).
3. `.husky/pre-push` blocks non-FF. Answer = `git fetch && git rebase`, never `--no-verify`.


### R-WIRE-001 — Componente ativo prova ativação (INTERCONNECT-RULE-P3-001, 2026-07-17)

**Regra (corte Enio — direção sprint interconexão + desenho redação Codex, 2 cortes):** Todo componente `active` com trigger não-manual (gate/hook/cron/agente) DEVE ter **activation resolvível**, **canário comportamental** e **evidência de execução no SLA declarado**. Estados `manual/disabled/external/intentional-off` são explícitos e **NÃO** contam como dívida. Distingue 4 coisas que o sistema misturava: **declarado ≠ estaticamente-conectado ≠ realmente-disparado ≠ observado**. Aresta declarada-mas-desconectada = dívida; off-explícito = não.

**Enforcement:** (a) HOJE, estático/real — `scripts/rule-gate-map.ts --enforce` wiring-check: entrada com `activation:` prova que o gate está fiado onde declara (bate com `.husky`/settings/crontab); zero-órfã já é gate duro no pre-commit. (b) STAGED, calibra com evidência (G2B behavioral) — canário que prova que o gate DISPARA (não só linkado) + evidência no SLA; liga `GUARDA-DECL-001` Slice B (M1). Nasce advisory, endurece com evidência (calibragem progressiva). **Origem:** investigação 2026-07-17 achou registries que mentem sobre wiring (`capability-scanner` declarava `pre_commit` sem estar fiado; `context-tracker`↔`context_tracker` caía em fallback silencioso). SSOT: `docs/governance/RULE_GATE_MAP.yaml`.


### R7 — Behavioral eval required for claimed capabilities (INC-008, 2026-04-22)

**Rule:** Any capability a system claims (in manifest, README, docs, CAPABILITY_REGISTRY, or `/api/*/discover` response) MUST have a **behavioral eval** proving it at runtime.

- **"Behavioral"** = simulates real usage (full input→output pipeline), not shape assertions on pure functions.
- Unit test of `detectPII()` returning correct findings is **NOT** enough — it doesn't prove `detectPII()` is being called in the code path that claims PII masking.
- Golden case that POSTs a chat message containing a CPF and asserts the response has no unmasked CPF **IS** behavioral.

**Why (INC-008, 2026-04-22):** a shared module in one of this fleet's repos exported stub implementations of `scanForPII`/`sanitizeText`/`createAtrianValidator` that returned `[]`/unchanged/always-passed. A route imported these expecting real work. Manifest claimed `pii-masking` + `atrian-validation`. Type checker, linter, 151 unit tests all green. For weeks/months, PII leaked in every production response. Golden eval's first live run caught it in 1 day.

**How to apply:**
1. **New capability in manifest/README → ≥3 golden cases before merge.** If the capability is `X`, at least one case must be designed so that if the underlying code were a stub, the case would fail.
2. **Stubs in compliance/safety code paths are FORBIDDEN in main.** Use `throw new Error('NOT IMPLEMENTED — see TODO-XXX')` during refactors so CI fails loudly, not a silent no-op returning `[]`/`true`/unchanged input.
3. **`try { compliance() } catch { /* non-fatal */ }` patterns MUST log + alert.** Silent swallow is how stubs hide.
4. **Weekly eval against production.** Pass-rate drop = something regressed silently. See `@egos/eval-runner` for reference.
5. **Canonical eval harness:** `packages/eval-runner/` (extracted from a battle-tested in-production runner + trajectory + judge-LLM). Adopt it, don't reinvent. promptfoo layers on top for YAML cases + redteam (Phase B of EVAL track).

**Pattern to detect in code review:**
- File named `*.shared.ts`, `*.stubs.ts`, `*-placeholder.ts` exporting functions with non-trivial signatures returning trivial defaults
- Capability listed in manifest with no corresponding `tests/eval/golden/*.ts` case
- Green CI + green typecheck + green unit tests but no end-to-end eval

Full postmortem: `docs/INCIDENTS/INC-008-phantom-compliance-stubs.md`.
Canonical eval strategy: `docs/knowledge/AI_EVAL_STRATEGY.md` (being written — see EVAL-X2).


**R10 — PCA: todo HITL usa Pergunta com Critério de Aceite [T1 — Enio 2026-07-11]:** toda pergunta a humano (HITL) em qualquer repo do workspace segue o formato PCA — pergunta + critério de aceite verificável + recomendação com argumento. SSOT único do formato + matriz de migração dos 16 sistemas: `egos/docs/governance/HITL_PROVENANCE_SPEC.md §ENTRADA-PCA` (não criar formato paralelo — 15º sistema é o modo de falha). Decisão HITL registrada sem `criterio_de_aceite` = inválida (`registrar_decisao()`/adapters rejeitam; gate soft `scripts/filosofia-gate.ts`). Avaliadores AI (Banda/Codex/Council) já cumprem o mesmo núcleo via MP-R1..R6 (`METAPROMPT_STANDARD.md`).


**R11 — Regras propagáveis 2026-07-13 (resumo-com-link; corpo NUNCA copiado — o SSOT é a fonte) [T1 — corte Enio O2:a]:**
1. **HITL × PCA:** HITL é o PORTÃO (onde o sistema para e QUEM decide — eixo, não severidade); PCA é a FORMA da pergunta no portão (opções letradas + recomendação + critério de aceite). Todo HITL estrutural se manifesta como PCA. → `egos/docs/governance/HITL_PROVENANCE_SPEC.md §6.0`
2. **PCA-CHAT-001/002:** decisão que precisa do humano chega como pergunta de ≤8 linhas — opções letradas (respondível com 1 letra) + "Recomendo" + "Fecha quando" + link clicável real. Muro-de-prosa não é pergunta. **E abaixo da régua vai o DOSSIÊ (PCA-CHAT-002, corte Enio 2026-08-06):** por que recomendo (com o número que sustenta) · exemplo prático **no terreno dele** (cliente/sócio/dinheiro/prazo antes de trabalho interno) · custo de não decidir. O bloco de cima decide sozinho; o dossiê é para quando a recomendação soar estranha. Recomendação ausente invalida a PCA como critério ausente. Várias → todas juntas, numeradas, respondíveis `"1a 2b 3c"`. → `§6.0.1` + `§6.0.2`
3. **Tríade da Confiança:** todo output relevante carrega 3 selos — ① Conferido-contra-fontes ② Provado-na-origem ③ Assinado-por-humano. Em peça jurídica, o selo ③ é SEMPRE ato humano do subscritor, nunca carimbo. → `egos/docs/governance/LAYER_0_SSOT.md §4.8`
4. **Calibragem progressiva:** todo gate/regra/filtro nasce máximo-restritivo (fail-closed), registra falso-positivos (telemetria) e calibra com evidência — cada calibragem AMPLIA o vocabulário da regra, nunca afrouxa por atrito. Calibragem é sempre decisão humana registrada. → `egos/docs/governance/EGOS_OPERATING_PRINCIPLES.md`


**R12 — Anti-Hipérbole / Prova Ativa (INC-010, 2026-07-26):** texto público (copy, `.md`, análise) está sob a DFP e não carrega absoluto ufanista ("100%", "ninguém no mundo", "perfeito", "a única solução") sem prova. Comparação com o mercado exige classificação `REAL/CONCEPT/PHANTOM` por item.
- Gate REAL: `scripts/check-banned-words.sh`, wired em `.husky/pre-commit:379`, **hard-block por padrão** desde o INC-010. Bypass: `EGOS_BANNED_SKIP="<motivo>"` (pontual) ou `EGOS_BANNED_WARN_ONLY=1` (degrada a aviso).
- **Correção de fantasma 2026-07-26:** a 1ª redação desta regra citava um gate `17-anti-hyperbole.sh` e um bypass `HYPERBOLE_OVERRIDE` — **nenhum dos dois existe**. O gate redundante foi deletado no mesmo dia e o `check-banned-words.sh` que já existia foi endurecido no lugar (ADOPT). Regra que aponta gate inexistente é a própria hipérbole que ela proíbe.


**R13 — NADA QUEBRA EM SILÊNCIO (R-NO-SILENT-FAIL-001, corte Enio 2026-07-26; dá gate ao "falhe visível" do §P5, que existia sem enforcement):** capacidade só está pronta quando o **caminho de falha** dela existe e foi provado. Três proibições, cada uma com fato-gerador medido:
- **(a) sucesso-fantasma** — reportar ok com a operação falhando. `broadcast_step` devolvia `"Broadcast sent"` com o INSERT em 403; `sendTelegram` marcava entregue com `{"ok":false}` de HTTP 401 (`notify-router.ts:234`, corrigido).
- **(b) gate mole** — cabeado com `|| exit 1` mas incapaz de sair 1: `check-cap-modular.sh` (sempre `exit 0`), `check-banned-words.sh` (warn-only por dentro), `human-doc-html-check.ts` (só bloqueia com flag), `env-shadow-check.ts` (não estava wired). Cabear não é enforcar.
- **(c) medição que não mediu** — declarar limpo sem ter conseguido medir. "Não sei" nunca se apresenta como "ok" (ver `workspace-orphan-check.ts`, exit 2).
- **(d) gate que não roda** — a forma extrema de (c), e a mais perigosa: gate que FALHA é barulhento e se conserta; gate que NÃO RODA é **indistinguível de gate que passou**. `HOOKS-WORKTREE-SILENT-SKIP-001` (2026-07-26): commit em `git worktree` executava **zero gates**, porque `.husky/_` não é versionado e o `core.hooksPath` relativo apontava para diretório inexistente — 9 de 14 worktrees assim, e um dos nossos agentes de implementação roda em worktree **por desenho**. Agravante: o `husky` reescreve o valor para relativo a cada `prepare`, então todo `bun install` desfazia o conserto manual. Irmã: **(e) cura que se desfaz** — configuração sob autoheal tem DUAS superfícies, a que RODA e a que MANDA; escrever na que roda funciona até a próxima cura e **o teste feito logo depois PASSA, confirmando o engano** (`R-AUTOHEAL-FONTE-001`, §1.60 — o `husky` reescreve `core.hooksPath` a cada `prepare`). Todo mecanismo de enforcement precisa provar que **EXECUTOU**, não só que não reclamou (`scripts/ensure-hooks-path.sh --check`, wired em `.husky/pre-commit §1.58` **e** no `prepare`).
- **Corolário de crescimento (é a parte que vale pro futuro):** notificador/job/gate novo só entra com **(1)** prova de entrega, **(2)** destino durável quando o canal principal falha, **(3)** um leitor desse destino. **Fila sem leitor é lixo:** a `notify-soft-queue.jsonl` acumulou 56 eventos entre 2026-06-19 e 2026-07-26 enquanto o SSOT afirmava "surface no /start" — o leitor não existia (criado em `/start` §4.5d).
- Gates: `env-shadow-check` + `workspace-orphan-check` + `phantom-done` + `notify-router --test` (sai ≠0 se não entregou). SSOT: `docs/governance/NOTIFICATION_SSOT.md §R-NO-SILENT-FAIL-001`.


**R14 — Regras promovidas de um leaf ao kernel (KRN-1-PROMOVER-REGRAS-001, corte Enio 2026-08-01):** nasceram num domínio específico, o princípio generaliza. Recuperadas por `git show` de commits que vivem só numa branch órfã do repo de origem (`RECONCILE-034`) — nunca chegaram à `main` de lá; a maioria sem gate ativo hoje em lugar nenhum (ÓRFÃ, registrado em `RULE_GATE_MAP.yaml`, não escondido — ver R-RULEMAP-COVERAGE-001).
- **(a) R-PARIDADE-REAL-001:** golden case que reimplementa formato/algoritmo de OUTRO sistema (trigger de banco, API externa, lib em outra linguagem) precisa de ≥1 caso com valor CAPTURADO do sistema real — comparar só contra valor recomputado pela própria função sob teste prova consistência interna, nunca correção externa. Fato gerador: validador de hash-chain com 7 golden verdes reportaria toda linha real de produção como adulterada (drift `::text` Postgres × ISO PostgREST), só achado testando manualmente 1 linha real.
- **(b) R-NOTA-NAO-CONTRADIZ-HUMANO-001:** item que entra num artefato por decisão humana registrada não carrega, ao lado, métrica automática (score/confiança) que a contradiga — no lugar entra a razão escrita pelo humano. Fato gerador: docx forense imprimia "Força: BAIXA (score 0)" ao lado do item que o investigador pôs em primeiro lugar — léxico não achou gíria numa dívida nomeada entre duas pessoas. Erro confiante que entrega argumento contra o próprio corte humano registrado.
- **(c) R-MUTACAO-PRESERVA-ANCORA-001:** motor que reescreve a fonte destrutivamente só é aceitável se o identificador (MD5/UUID/chave) sobrevive em campo que os leitores de fato consultam, e existe caminho de reprocessamento. Fato gerador: script apagava a referência a um MD5 quando o arquivo-mídia não estava em disco no momento da execução; recuperado 7 dias depois, o vínculo morreu para sempre, sem erro — pipeline seguiu verde (1 caso foi de 0/186 para 185/186 após o conserto).
- **(d) R-CURADORIA-E-A-REGUA-001:** corte humano sobre o mesmo universo que um motor processou é conjunto de avaliação — meça, separando INVISÍVEL (nenhum detector produz, defeito de vocabulário) de MAL-RANQUEADO (existe mas perde por ordenação/teto, defeito de score). Somar os dois esconde qual conserto o sistema precisa.
- **(e) R-TRILHA-COBERTURA-001:** cobertura alegada não é cobertura provada — antes de dizer "analisado", percorra a trilha inteira com um número em cada elo, inclusive o que NÃO foi coberto (é resultado, não rodapé). Fato gerador: cobertura dita "completa" era 70,2% medida; o resto só apareceu ao procurar pelo caminho físico em vez de confiar só no vínculo lógico.
- **(f) R-PONTEIRO-001:** ponteiro/referência que não resolve localmente não é "a regra não existe" — antes de concluir ausência, procure na fonte apontada (kernel, se for leaf); se não estiver em nenhum dos dois, registre como fantasma, nunca invente a regra que "deveria" estar lá. Fato gerador: bloco propagado do kernel cita `docs/governance/*.md` que só resolve dentro do repo `egos`; sem tradução de caminho, morre no leaf, e agente que segue o ponteiro morto **improvisou regra própria 3× num dia**. Achado ao promover esta regra: `scripts/disseminate-propagator.ts` ainda não traduz esses caminhos hoje — ver `PONTEIRO-TRADUCAO-001`.
- **(g) R-PENDENCIA-CROSS-MAQUINA-001:** quando o trabalho roda em ambientes que só trocam informação por git, um pedido de uma parte à outra não vive só no chat de uma sessão — morre com ela. Formalize como registro versionado que viaja no commit/push e cobra visivelmente do lado-alvo até ser respondido; quem abriu não fica bloqueado (cobrar de si mesmo trava trabalho sem motivo). Mesmo fato gerador de (f), resolvido por mecanismo complementar: mover o pedido, não só apontar para onde ele deveria estar.
- **(h) R-UNIVERSO-DECLARADO-001 [=P1]:** número publicado sem o universo de onde saiu **engana** — quem lê "6 selecionados" e não vê o denominador conclui que é tudo o que existe. Toda contagem publicada carrega três números: **N publicados · M do universo · S que passaram no filtro**, e diz o que os demais são. **A régua também se declara:** "passou no filtro" depende do critério, e critério tem falso-positivo — publicar o número sem essa ressalva é erro confiante em forma de estatística. *Não é regra de um domínio: o mesmo padrão apareceu 3× fora do de origem (139 itens ditos "genéricos" que eram de um cliente · 83 declarados × 77 medidos · 6.777 de 8.174 excluídos antes de pontuar).*
- **(i) R-IDENTIFICADOR-OPACO-001:** antes de casar dois identificadores por semelhança numérica/textual, pergunte se pertencem ao **mesmo domínio de identificação**. Telefone×telefone, sim. Telefone×ID-opaco, CPF×protocolo, hash-de-arquivo×hash-de-conteúdo: **não**. Casamento entre domínios diferentes por sufixo/prefixo é ruído com aparência de resolução — produz **atribuição falsa**, que é pior que ausência de resultado. A saída certa é achar a **âncora determinística** (a estrutura que já prova o vínculo), e declarar no dado **por qual âncora** cada casamento foi feito — misturar as duas num contador só esconde que uma delas é chute.
- **(j) R-REPLICAVEL-001:** o motor tem que rodar na máquina do outro. Literal específico-de-ambiente (host, porta, nome de organização, caminho absoluto) é dívida **quando é a única verdade possível** — `env.get("X", "default-local")` é fallback declarado, isso é bom desenho. A régua não é "achou o literal", é "achou o literal E não há saída"; gate que não distingue os dois vira ruído, ruído vira bypass, bypass vira teatro. **Não é o mesmo que R-ENV-005** (aquele é sobre *secret* em plaintext; este é sobre literal *não-secreto* que quebra portabilidade — falha diferente, conserto diferente).
- **(k) GATE-FRESCOR-001:** artefato derivado que é publicado prova que leu a fonte de hoje — compare o timestamp do artefato com o da fonte e **barre a publicação** se estiver velho. **HTML velho abre igual a HTML novo**, e gerador que parou de escrever falha em silêncio (=R13-d). Tolerância existe para caber uma passada de geração, não uma tarde. **Não é o mesmo que o `frescor-sentinel`** (aquele *relata* frescor da cadeia documental em cron; este *bloqueia* publicação de artefato derivado). *Fato gerador re-confirmado em 2026-08-01, no próprio kernel: o `mycelium-snapshot.json` versionado estava 7 dias atrás da fonte e nada apontou — só apareceu porque fui consertar outra coisa no mesmo arquivo.*


**R15 — O que a sessão de 2026-08-02 provou medindo (corte Enio 2026-08-02):** duas [T1] que valem em todo repo que pontue algo ou registre evidência. Corpo: `docs/governance/EGOS_OPERATING_PRINCIPLES.md`.
- **(a) R-DECIDE-DETERMINISTICO-001 [=P1]:** o que emite **veredito, nota ou score** decide por função **pura e versionada** — sem rede, relógio ou sorteio; o modelo interpreta fala livre e **propõe a entrada**, nunca converte nota em veredito. A saída carrega a versão do motor (veredito irreproduzível não sustenta contrato), e a **ordem da entrada não pode alterar o resultado** — o golden que embaralha a entrada é o que acusa estado escondido. Fato gerador medido: num produto de diagnóstico de terceiro, duas sessões com as mesmas respostas devolveram JSON **byte-idêntico** (zero LLM no caminho que decide) e trocar a resposta de texto livre por palavras aleatórias **não alterou a leitura**. Instância de referência: `packages/cabe-ia` (17/17, inclui o golden de pureza).
- **(b) R-EVIDENCIA-PADRAO-001 [=P4]:** evidência que sai do rascunho e entra em **artefato entregue** registra o **padrão**, nunca o **identificador** — *"valor de contrato visível a todo mundo"* entra, *"o contrato da Fulana, R$ 82 mil"* não. O identificador vive no rascunho com prazo de descarte escrito. Vale para diagnóstico, dossiê, relatório, ficha de capacidade e mensagem de commit. **O gate de PII é backstop, não defesa:** ele pega CPF e telefone, não pega "o contrato da Fulana".
- **(c) R-SUCESSO-PARCIAL-001 [=P1]:** ferramenta que reporta sucesso **sobre o subconjunto que ela cobre** não prova que o objetivo foi atingido — o relato diz **o que ficou de fora**, sempre. 3 ocorrências medidas em 2026-08-02: o propagador respondeu `0 arquivos atualizados` e o correto era *"as regras novas não viajaram"*; o verificador de leaves diria "em dia" escondendo 6 **NÃO-MEDIDO**; e a landing exibia `● ONLINE` para três serviços dos quais **dois não respondiam**. Antes de dizer "feito", pergunte **qual universo a ferramenta olhou** — e publique o denominador junto (irmã de `R-UNIVERSO-DECLARADO-001`).


**R16 — A DEFESA TAMBÉM COBRE A CONVERSA E O ESTÁGIO (censo da arquitetura de defesa, 2026-08-17):** três [T1] nascidas de defeitos medidos no mesmo dia. Escritas primeiro fora do bloco propagável e movidas para cá em 2026-08-17 — provado que não viajavam: um leaf amostrado tinha **0 ocorrências das três** e **1** de `R-VALOR-DESDE-O-INICIO-001`, que já estava dentro do bloco. Regra escrita no lugar errado do arquivo certo não existe para ninguém — é o próprio `R-SUCESSO-PARCIAL-001` acima, aplicado ao propagador.
- **(a) R-PROSA-PROVADA-001 [=P1, 2 cortes Enio]:** o que o agente diz no chat passa por defesa igual ao que ele commita. O evento `Stop` recebe a resposta inteira e a **devolve** (`egos/scripts/claude-runtime/hooks/prosa-gate.sh`) quando ela afirma **número sem comando rodado no turno** ou **negativa sem varredura**. Motivo de existir: das 3 camadas de defesa, a do commit tem 98 pontos de bloqueio e o dano lá é reversível; a da prosa tinha **zero** e o dano é irreversível — o humano decide lendo. Guarda anti-loop (1 disparo por turno) e fail-open **com voz** (transcript ilegível não acusa, mas diz `NÃO-MEDIDO` — =R13-c). Desliga com `EGOS_PROSA_GATE_OFF=1`. 8 goldens, metade provando o que ele **deixa passar** — turno que mediu passa cheio de números, senão o gate morre por override. *Refuta a afirmação, feita 2× na própria constituição, de que a metade conversacional não teria gate possível.*
- **(b) R-ESCAPE-ESTAGIO-001 [=P3]:** gate que roda no `pre-commit` **não** lê `.git/COMMIT_EDITMSG` — ali o arquivo ainda tem a mensagem do commit **ANTERIOR**. Detecta no pre-commit (grava sinal em `$GIT_DIR`, não bloqueia) e **cobra no `commit-msg`**, onde `$1` é a mensagem real. Dois defeitos simétricos, ambos medidos: **(i)** o escape que o autor escreve agora não é visto — o gate bloqueia, manda escrever o marcador, ele escreve, e bloqueia de novo; **(ii)** o escape do commit anterior **ainda autoriza este**, em silêncio — pior, porque (i) faz barulho e (ii) não faz nenhum. O sinal é **consumido em todo caminho de saída, inclusive no bloqueio**: é isso que mata o vazamento. Instrução impressa que não funciona no estágio treina o `--no-verify`. Motor: `egos/scripts/lib/gate-msg-escape.sh` + `gate-msg-check.sh` (9 goldens).
- **(c) R-UM-PORTADOR-001 [=P3/P5, 2 cortes Enio]:** a constituição se escreve **uma vez** em cada repositório. Quem carrega é o `AGENTS.md`; o `CLAUDE.md` **importa** com `@AGENTS.md` e guarda só o que é próprio dele. Exceção nomeada: repo **sem** `AGENTS.md` — ali o `CLAUDE.md` é o único portador e assim permanece (remover apagaria a regra, não a duplicação). Fato gerador: o propagador escrevia o mesmo bloco nos dois arquivos e **18 repos carregavam 55.168 bytes idênticos em duplicata** — 986 KB de boot na frota, sem que nada acusasse. O freio que faz durar é `adapter-skip` no `updateFileWithBlock`: sem ele o cron reinjetava o bloco no arquivo já migrado e a cura se desfazia sozinha (=R-AUTOHEAL-FONTE-001). Motor: `egos/scripts/leaf-adapter-migrate.ts` (dry-run por padrão). 10 goldens, 6 sobre o que o motor **recusa** fazer.


---

## Regras condicionais — presentes, DESLIGADAS

> Corte do Enio (2026-08-03): estas viajam **desligadas**, não ausentes. O motivo é honesto —
> regra que a pessoa não vê é regra que ela reinventa errado. O custo é o seu dia-um ficar mais
> longo, e ele foi aceito de propósito. **Ligue apenas a que corresponder ao que você tem.**

<details>
<summary><strong>⏸️ DESLIGADA — ligue se você usa: multi-agente</strong></summary>

> **Como ligar:** confirme que você de fato usa `multi-agente` e mova esta seção para as suas
> regras ativas. Se não usa, deixe desligada — regra ligada sem o objeto que ela protege
> vira ruído, e ruído se ignora.
> **Por que é condicional:** so faz sentido com 2+ agentes na mesma arvore

### R5 — Context & swarm
1. Use Agent tool when: 5+ files to read, >3 Glob/Grep rounds expected, research+implement needed. Don't spawn for single-file edits, git ops, known answers.
2. Independent tasks → all agents in ONE message. Dependent → sequential.
3. After 10+ turns or compaction: re-read TASKS.md + current file.
4. Cost control: 3 retries fail on same error → STOP, flag `[BLOCKER]`.
5. **Session checkpoint:** when pre-commit emits `[CHECKPOINT-NEEDED]` (turns≥10/commits≥15/elapsed≥90min), invoke `/checkpoint` (Hard Reset). Use `bun scripts/session-init.ts --status` to check. Never ignore [CHECKPOINT-NEEDED].
6. **Concurrent windows on the same checkout → worktree from start, constitutional (not just suggestion).** `session-registry.ts check` detects another live session on the SAME checkout. If detected AND this session will write/commit AND its objective diverges from the others' → open with `claude --worktree <name>` BEFORE editing hotspots (TASKS.md/CLAUDE.md/AGENTS.md/.guarani). Exceptions (worktree cost > protection): single session · read-only/research mode · work in a separate repo · trivial single-file edit · work depending on `.env`/deploy-from-tree (worktree lacks `.env`, gitignored). Pre-commit ALREADY verifies and blocks a shared-index commit with 2+ live windows (`INDICE-COMPARTILHADO-001`, `.husky/pre-commit` §0.15) — that gate is the backstop; worktree is the cure. SSOT: `docs/governance/SWARM_COMMIT_POLICY.md §Multi-Window`.


</details>

<details>
<summary><strong>⏸️ DESLIGADA — ligue se você usa: supabase</strong></summary>

> **Como ligar:** confirme que você de fato usa `supabase` e mova esta seção para as suas
> regras ativas. Se não usa, deixe desligada — regra ligada sem o objeto que ela protege
> vira ruído, e ruído se ignora.
> **Por que é condicional:** so com banco Supabase

### R-RLS-001 — Row-Level Security (INC-006, 2026-05-05)
Every RLS policy MUST have explicit `TO <role>`. No `{public}` on sensitive tables (`users`, `*_keys`, `*_secrets`, `admin_*`). Validator: `scripts/security/rls-validator.ts`. Continuous auditor: `scripts/security/rls-auditor-comprehensive.ts` (VPS cron daily 2 AM UTC). Setup: `docs/jobs/SUPABASE_RLS_AUDIT_SETUP.md`. Override: `RLS-POLICY-OVERRIDE: <reason>`.


</details>

<details>
<summary><strong>⏸️ DESLIGADA — ligue se você usa: banco</strong></summary>

> **Como ligar:** confirme que você de fato usa `banco` e mova esta seção para as suas
> regras ativas. Se não usa, deixe desligada — regra ligada sem o objeto que ela protege
> vira ruído, e ruído se ignora.
> **Por que é condicional:** so com banco de dados

### R8 — DB Discipline (INC-DB-001 — 2026-05-22)

> SSOT completo: `docs/governance/DB_DISCIPLINE.md`. Pre-commit enforcement: `scripts/pre-commit-db-discipline.sh`.

1. **R-DB-001 Schema-First** — scripts Supabase usam tipos gerados / zod. Nunca literal solto `{ is_active: true }` (PostgREST ignora colunas erradas em silêncio → bug invisível).
2. **R-DB-002 Smoke ANON pós-write** — todo seed/migration termina com SELECT count usando ANON, assertando ≥ expected.
3. **R-DB-003 RLS anon explícito** — migration de tabela usada por storefront DEVE incluir `CREATE POLICY ... TO anon, authenticated USING (...)` no mesmo arquivo. Nunca `current_setting('app.*')`.
4. **R-DB-004 SSOT-only** — fixes em `central-egos/template/` (ou equivalente leaf). Nunca em `clients/<slug>/src/`. **Incidente origem:** FVP seed v2 usou `is_active`, 32 rows defaultaram `active=false`, storefront 0 produtos 12h (RLS exigindo session var não-setada).


</details>

<details>
<summary><strong>⏸️ DESLIGADA — ligue se você usa: multi-agente</strong></summary>

> **Como ligar:** confirme que você de fato usa `multi-agente` e mova esta seção para as suas
> regras ativas. Se não usa, deixe desligada — regra ligada sem o objeto que ela protege
> vira ruído, e ruído se ignora.
> **Por que é condicional:** escopos/lock/Council so fazem sentido com 2+ agentes

**R9 — Agentic Governance & Scopes (2026-05-30):** agentes seguem escopos/permissões/notificação de [agent_scopes_and_governance.md](docs/governance/agent_scopes_and_governance.md). Out-of-scope → lock `.egos-lock` + escalar Council/HITL (Telegram/WhatsApp). Anti-repetição: checar `TASKS.md` + `git log` antes de planejar.


</details>
