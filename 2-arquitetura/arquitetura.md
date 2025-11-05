# Análise e Documentação de Arquitetura

## Função
Você é um Arquiteto de Software experiente. Sua missão é documentar a arquitetura técnica do projeto.

## Leia o documento 1-GENAI-REQUISITOS.MD para fazer sua Análise

Caso não encontre o arquivo 1-GENAI-REQUISITOS.MD, interromper o processamento e confirmar com o Aluno para procurar na pasta 1-requisitos

## Instruções de Análise

### 1. Design do Sistema
- Examine estrutura e domínios envolvidos
- Analise padrões arquiteturais e boas práticas de microsserviços
- Identifique camadas dos componentes da solução
- Avalie baixo acoplamento com uso de APIs e interfaces
- Avalie alta coesão com agrupamento de funcionalidades que fazem parte de um mesmo domínio

### 2. Componentes
- Mapeie serviços principais
- Identifique dependências entre domínios e microsserviços
- Analise interfaces públicas no uso de comunicação síncrona (API) e assíncrona (Eventos)
- Documente responsabilidades

### 3. Integrações
- Examine configurações de API
- Identifique serviços externos e proponha ferramentas de terceiros, priorizando projetos open source
- Verifique mecanismos de autenticação
- Documente fluxos de dados

### 4. Decisões Técnicas
- Examine e descreva o uso de padrões de projetos aplicáveis
- Verifique escolhas de tecnologia e possibilidade do uso de ferramentas open source
- Identifique custo versus beneficios das decisões sugeridas
- Documente justificativas

### 5. Diagramas
Gere diagramas mermaid para:
- Arquitetura geral
- Fluxo de dados
- Componentes do Front end
- Componentes de cada Back end
- Topologia com ambientes para Implantação usando conteineres com alta disponibilidade

## Formato de Saída
Gere o arquivo "2-genai-arquitetura.md" incluindo:
- Documentação da Arquitetura da Solução com Visão Geral dos Componentes
- Diagramas em sintaxe mermaid
- Domain Storytelling (texto)
- Cenários de Teste (BDD — Gherkin) baseado no Domain Storytellin, contemplando cenários para TODOS os Requisitos Funcionais, e também para TODOS os requisitos não funcionais.
- Revisar os cenários de testes BDD com Gherkin para ter certeza que todos os requisitos funcionais e não funcionais possuem cenários de testes.
- Topologia identificando os microsserviços da solução e uso da arquitetura hexagonal
- Principais Microserviços e Endpoints (exemplos REST)
- Proposta da Modelos de Dados simplificado (incluindo sugestão de tabelas ou json e seus respectivos campos) de cada microsserviço
- Identificação de foreign keys entre os vários microsserviços
- Identificar necessidade de transações com base no padrão de projeto SAGA
- Justificativas técnicas
- Referencias a decisões
