# Descrição do Projeto e Objetivo do Pipeline

A pasta /ecom contém um **projeto monorepo** composto por múltiplos **microserviços** (cada um com seus próprios testes unitários) e uma pasta separada de **testes de integração** baseada em **Cucumber**.

O objetivo é criar um **pipeline de CI/CD simples** que possa ser **executado tanto localmente quanto em ambiente de CI** (por exemplo, GitHub Actions, AWS CodeBuild, ou outra plataforma), garantindo a execução automatizada de:
1. Build dos microserviços
2. Testes unitários de cada microserviço
3. Testes de integração de ponta a ponta (Cucumber)
4. Implantação (deploy) usando o docker-compose para ambientes local ou de produção

---

## Estrutura Geral do Repositório para esta etapa

```
ecom/
└── .github/
    └── workflows/
        └── ci.yml
```

---

## Requisitos Técnicos do Pipeline

### 1. Estrutura de Fases do Pipeline
- Um job principal chamado `build-and-test`
- Etapas:
  - Checkout do código
  - Configuração do ambiente
  - Execução dos testes unitários dos microserviços a partir da pasta /ecom/backend
  - Execução dos testes de integração Cucumber a partir da pasta /ecom/testes_integracao
- Um job de deploy no proprio ambiente usando docker-compose.yml

### 2. Compatibilidade
- O pipeline deve poder rodar:
  - Localmente via **act (GitHub Actions local runner)**
  - Em ambientes de CI/CD da AWS (ex: **AWS CodeBuild**)
  - Em **GitHub Actions** (estrutura YAML padrão)

### 3. Expectativa de Saída do Pipeline

- Um arquivo YAML de pipeline (ex: `.github/workflows/ci.yml` ou `buildspec.yml`) que:
  - Faça o checkout do repositório
  - Configure as dependencias necessárias
  - Execute todos os testes unitários de cada microserviço
  - Execute os testes de integração (Cucumber)
  - Exiba o status final da build (sucesso/falha)
  - Use etapas nomeadas e com logs legíveis

### 4. Requisitos adicionais

- Cache Maven (`actions/cache` ou similar)
- Geração de relatórios
- Build paralelo dos microserviços
- Deploy automatizado para ambiente
- Integração com ferramentas de code quality (SonarQube)

### 5. Exemplo de comando desejado para execução local

Criar um script na pasta /ecom/scripts para que seja possível executar o pipeline, por exemplo:

```bash
act workflow_dispatch
```

---

## Formato de Saída

Gerar um pipeline funcional, legível e portável (em YAML), com foco em **simplicidade, clareza e execução local via `act`**, de forma que seja possível:
- Rodar testes automaticamente em cada commit/pull request
- Validar integração completa antes de deploy
- Ter logs claros para depuração de falhas


## Conclusão

- Com base nesta descrição, deve ser gerado um arquivo de pipeline CI/CD YAML que atenda aos requisitos acima, priorizando simplicidade e compatibilidade com execução local (`act`).
