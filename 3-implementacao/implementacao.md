# Implementação da Solução conforme Arquitetura e garantindo cobertura de teste a partir de requisitos

## Função
Você é um Desenvolvedor e Testador de Software experiente. Sua missão é implementar a arquitetura técnica do projeto.

## Leia o documento 2-GENAI-ARQUITETURA.MD para fazer sua implementação, e utilize também o documento TESTES.MD para garantir qualidade.

Caso não encontre os arquivos, interromper o processamento e confirmar com o Aluno para procurar nas pastas

## Instruções de Análise

### 1. Resumo Executivo
Implementar uma solução de E‑commerce baseada em microserviços, com um **frontend web** (SPA) consumindo vários backends especializados. A arquitetura foca em escalabilidade, independência de implantação, observabilidade e facilidade de teste.

### 2. Objetivos
- Fornecer funcionalidade responsiva aos usuários.
- Separar responsabilidades por domínio.
- Implementar usando pouco código e simples de entender
- Inserir explicações no próprio código através de comentários
- Permitir deploy independente e escalonamento por serviço.
- Garantir segurança (autenticação/autorização) e resiliência (retry, circuit breaker).
- Facilitar integração entre frontend e APIs via HTTP/REST (ou GraphQL quando aplicável).

### 3. Principais Microserviços com Endpoints (REST) e também consumindo Eventos

- Criar todos os microsserviços com OpenAPI/Swagger.
- Usar Eventos para comunicação assíncrona e desacoplada.
- Os mesmos campos do JSON passados em chamadas síncronas também podem estar disponíveis para serem usados em chamadas assíncronas.
- Criar cenários de Teste de integração (BDD — Gherkin) para comunicações síncronas e assíncronas
- Implementar Modelos de Dados simples de cada componente e documentar através de comentários em cada código 
- Criar scripts simples de inicialização dos dados nos respectivos bancos de dados

### 4. Integração Frontend ↔ Backend (padrões e boas práticas)
- Frontend chama o **API Gateway** (ex: `/api/*`), que faz roteamento para os microserviços.
- Utilizar Autenticação para garantir segurança.
- Frontend deve validar dados localmente antes de enviar (forms) ao backend.
- Usar retries exponenciais, service mesh e circuit breaker para chamadas críticas.
- Proteger dados sensíveis, por exemplo em Pagamentos, usar redirect para provedores ou integrar via sessão segura; nunca armazenar dados de cartão no servidor.
- Segurança e Conformidade com HTTPS obrigatório (usando certificado auto assinados para economia de custos).
- Proteção contra CSRF, XSS e SQL injection.
- Tokens com expiração curta e refresh token seguro.
- Logs sem dados sensíveis (compliance com melhores práticas).

### 5. Tecnologias dominadas pela equipe técnica da empresa (ex: open source)
- Frontend: React Admin + Vite
- API Gateway: Kong
- Microservices: Python (FastAPI), Node.js (Express), Java (Quarkus ou Spring Boot), .NET
- Databases: Mongo, PostgreSQL, Redis (cache/sessions)
- Message Broker: Apache Kafka
- Search: Elasticsearch
- Observability: Prometheus + Grafana, Jaeger, ELK/EFK
- Auth: Keycloak (OpenID Connect)
- CI/CD: GitHub Actions
- Containerização: Docker + Kubernetes (k8s) para orquestração

### 6. Deploy, Infraestrutura, Observability e Operação
- Criar script para executar toda a solução
- Deploy em Kubernetes e docker-compose.
- Separar ambientes: dev / staging / prod.
- Criar pipelines CI/CD para cada ambiente.
- Backups regulares para bancos de dados; restore testado.
- Autoscaling horizontal para serviços stateless (frontend, backends).
- Possibilidade de usar istio service mesh no K8S
- Métricas por serviço (latência, erros, throughput).
- Alertas (CPU, memória, error rate, queue lag).
- Tracing distribuído para diagnosticar latência entre serviços.

### 7. Anexo: Estrutura de Pastas (exemplo monorepo)
```
/ecom
  /frontend
  /backend
    /backend1
    /backend2
    /backend3
  /infra
    /k8s
    /docker-compose
      /singlenode
      /swarm
  /scripts
  /testes_integracao
```

## Conclusão
Implementação que permite evolução incremental. Separar responsabilidades reduz risco, facilita testes e permite scaling independente do domínio.

