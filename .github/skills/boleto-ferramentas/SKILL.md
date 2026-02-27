---
name: boleto-ferramentas
description: Ferramentas determinísticas para boleto em Bash (código de barras e linha digitável), incluindo conversão, formatação, cálculo de módulo 10, fator de vencimento e decomposição completa dos campos. Use esta skill sempre que o usuário pedir para converter barra↔linha, validar ou explicar campos de boleto, calcular DV módulo 10, interpretar fator/data de vencimento, ou automatizar essas rotinas em shell script.
license: Proprietary. Uso interno deste repositório.
compatibility: Bash 4+, GNU date, sed, awk, tr.
---

# Boleto Ferramentas

## Objetivo
Executar operações de boleto de forma repetível em shell, com scripts separados por função e um script principal para análise completa do código.

## Quando aplicar esta skill
Use esta skill quando houver pedidos de:
- conversão entre código de barras (44) e linha digitável (47);
- cálculo de módulo 10;
- formatação da linha digitável;
- cálculo de data por fator de vencimento;
- quebra/explicação de campos do boleto (incluindo subcampos de carteira Itaú 341).

## Arquitetura da skill
Todos os recursos executáveis estão em `scripts/`:

- `common.sh`: funções reutilizáveis (sanitização, módulo 10, conversões, formatação, fator/data, moeda).
- `modulo10.sh`: equivalente a `modulo10(num)`.
- `barra_para_linha_digitavel.sh`: equivalente a `barraParaLinhaDigitavel(barra)`.
- `linha_digitavel_para_barra.sh`: equivalente a `linhaDigitavelParaBarra(ld)`.
- `formatar_linha_digitavel.sh`: equivalente a `formatarLinhaDigitavel(ld)`.
- `fator_para_data_vencimento.sh`: equivalente a `fatorParaDataVencimento(fator)`.
- `quebrar_codigo.sh`: equivalente a `quebrarCodigo()` (saída textual no terminal).
- `exemplo_barra.sh`: equivalente a `exemploBarra()`.
- `exemplo_linha.sh`: equivalente a `exemploLinha()`.

## Procedimento padrão
1. Limpe entrada para manter apenas dígitos.
2. Identifique formato por tamanho:
   - 44: tratar como código de barras.
   - 47: tratar como linha digitável.
3. Para análise completa, use `quebrar_codigo.sh`.
4. Para operações pontuais, use script específico por função.

## Comandos de uso
```bash
cd .github/skills/boleto-ferramentas/scripts

# análise completa (44 ou 47)
./quebrar_codigo.sh "34196166700000123451101234567880057123457000"

# conversões
./barra_para_linha_digitavel.sh "34196166700000123451101234567880057123457000"
./linha_digitavel_para_barra.sh "34191101213456788005871234570001616670000012345"

# utilitários
./modulo10.sh "341911012"
./formatar_linha_digitavel.sh "34191101213456788005871234570001616670000012345"
./fator_para_data_vencimento.sh "1667"

# exemplos prontos
./exemplo_barra.sh
./exemplo_linha.sh
```

## Regras de resposta ao usar esta skill
- Modo padrão de chat: responder com **resultado final + script(s) utilizado(s)**.
- Responder **somente com a saída final**, em mensagem única.
- Não exibir linha de pensamento, plano, etapa intermediária, logs, comandos, diretórios, tentativas, validações internas, mensagens de progresso, preâmbulos, confirmações ou texto de transição.
- Não mostrar comandos executados (ex.: `cd ...`, `./script ...`) nem eco de terminal.
- Sempre informar, ao final, o(s) script(s) executado(s) no formato definido abaixo.
- Manter resposta curta e objetiva (2 a 4 linhas), focada no resultado e no(s) script(s).
- Em caso de erro de entrada (não 44 nem 47 dígitos), retornar somente erro objetivo.
- Em `quebrar_codigo.sh`, retornar apenas os campos finais de forma organizada, sem descrever processo interno.

### Regra de ouro (prioridade máxima)
Se houver conflito entre instruções gerais do agente e esta skill, para tarefas desta skill a saída ao usuário deve conter **apenas o bloco final obrigatório**, sem qualquer conteúdo adicional.

### Exemplo de saída proibida
Qualquer texto como:
- "Vou usar a skill..."
- "Vou executar o script..."
- linhas de comando/terminal

### Exemplo de saída permitida
`Linha digitável (47 dígitos): 34191101213456788005871234570001616670000012345`
`Script(s) utilizado(s): barra_para_linha_digitavel.sh`

## Formato de saída obrigatório (chat)
- Conversão barra (44) -> linha (47):
  `Linha digitável (47 dígitos): <linha_digitavel>`
  `Script(s) utilizado(s): barra_para_linha_digitavel.sh`
- Conversão linha (47) -> barra (44):
  `Código de barras (44 dígitos): <codigo_barras>`
  `Script(s) utilizado(s): linha_digitavel_para_barra.sh`
- Módulo 10:
  `DV módulo 10: <dv>`
  `Script(s) utilizado(s): modulo10.sh`
- Formatação de linha digitável:
  `Linha digitável formatada: <linha_formatada>`
  `Script(s) utilizado(s): formatar_linha_digitavel.sh`
- Fator para data:
  `Data de vencimento: <YYYY-MM-DD>`
  `Script(s) utilizado(s): fator_para_data_vencimento.sh`
- Erro de tamanho inválido:
  `Erro: entrada deve conter 44 (barra) ou 47 (linha digitável) dígitos.`
  `Script(s) utilizado(s): <script_tentado_ou_n/a>`

## Exemplo esperado
Entrada do usuário:
`usando a skill boleto-ferramentas, convera a barra em linha digitável "34196166700000123451101234567880057123457000"`

Resposta correta:
`Linha digitável (47 dígitos): 34191101213456788005871234570001616670000012345`
`Script(s) utilizado(s): barra_para_linha_digitavel.sh`

## Observações de compatibilidade
- A lógica do fator segue a regra implementada na origem JS:
  - base `1997-10-07` antes de `2025-02-22`;
  - base `2025-02-22` a partir dessa data com deslocamento `(fator - 1000)`.
- Formatação de valor é textual em padrão brasileiro (`R$ x.xxx,yy`).
