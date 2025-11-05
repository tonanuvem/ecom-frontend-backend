# 📦 Descrição do Projeto e Objetivo do Pipeline

Este repositório /ecom contém um **projeto monorepo** composto por múltiplos **microserviços** (cada um com seus próprios testes unitários) e uma pasta separada de **testes de integração** baseada em **Cucumber**.

O objetivo é criar um **pipeline de CI/CD simples** que possa ser **executado tanto localmente quanto em ambiente de CI** (por exemplo, GitHub Actions, AWS CodeBuild, ou outra plataforma), garantindo a execução automatizada de:
1. Build dos microserviços
2. Testes unitários de cada microserviço
3. Testes de integração de ponta a ponta (Cucumber)
4. Opção futura de implantação (deploy) para ambientes de staging/produção

---

## 🧩 Estrutura Geral do Repositório

```
ecommerce-monorepo/
├── microservices/
│   ├── orders/
│   │   ├── src/
│   │   └── pom.xml
│   ├── products/
│   │   ├── src/
│   │   └── pom.xml
│   └── payments/
│       ├── src/
│       └── pom.xml
├── integration-tests/
│   ├── features/
│   │   ├── checkout.feature
│   │   └── payment.feature
│   └── pom.xml
└── .github/
    └── workflows/
        └── ci.yml
```

---

## 🧠 Requisitos Técnicos do Pipeline

### 1. Linguagem e Build
- Linguagem: **Java 17**
- Ferramenta de build: **Maven Wrapper (`./mvnw`)**
- O pipeline deve configurar o ambiente Java antes de executar testes.

### 2. Testes Unitários
- Cada microserviço deve rodar seus próprios testes unitários com:
  ```bash
  ./mvnw test
  ```
- Executar sequencialmente ou em paralelo, conforme suporte da plataforma.

### 3. Testes de Integração
- Localizados na pasta `integration-tests/`
- Devem ser executados com:
  ```bash
  mvn clean test
  ```
- Usam **Cucumber** para validações ponta a ponta.

### 4. Estrutura de Jobs
- Um job principal chamado `build-and-test`
- Etapas:
  - Checkout do código
  - Configuração do ambiente Java 17
  - Execução dos testes unitários dos microserviços
  - Execução dos testes de integração Cucumber
- Opcionalmente, um job futuro de deploy.

### 5. Compatibilidade
- O pipeline deve poder rodar:
  - Localmente via **act (GitHub Actions local runner)**
  - Em ambientes de CI/CD da AWS (ex: **AWS CodeBuild**)
  - Em **GitHub Actions** (estrutura YAML padrão)

---

## ⚙️ Expectativa de Saída do Pipeline

- Um arquivo YAML de pipeline (ex: `.github/workflows/ci.yml` ou `buildspec.yml`) que:
  - Faça o checkout do repositório
  - Configure Java 17
  - Execute todos os testes unitários de cada microserviço
  - Execute os testes de integração (Cucumber)
  - Exiba o status final da build (sucesso/falha)
  - Use etapas nomeadas e com logs legíveis

---

## 🧩 Requisitos Opcionais (para evolução futura)

- Cache Maven (`actions/cache` ou similar)
- Geração de relatórios JUnit
- Build paralelo dos microserviços
- Deploy automatizado para ambiente de staging no EKS/EC2
- Integração com ferramentas de code quality (SonarQube)

---

## ✅ Objetivo do Prompt

Gerar um pipeline funcional, legível e portável (em YAML), com foco em **simplicidade, clareza e execução local via `act`** ou em **ambiente AWS CodeBuild**, de forma que o time de desenvolvimento possa:
- Rodar testes automaticamente em cada commit/pull request
- Validar integração completa antes de deploy
- Ter logs claros para depuração de falhas

---

## 🧭 Exemplo de comando desejado para execução local

```bash
act workflow_dispatch
```

ou

```bash
aws codebuild start-build --project-name ecommerce-monorepo
```

---

## 💬 Instrução para o Amazon Q Developer

> Com base nesta descrição (`pipeline.md`), gere um arquivo de pipeline CI/CD YAML que atenda aos requisitos acima, priorizando simplicidade e compatibilidade com execução local (`act`) e com AWS CodeBuild.
