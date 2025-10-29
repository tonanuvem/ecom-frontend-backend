# Solução E‑Commerce — Arquitetura e Fluxo (Frontend acessando Backends)

## 1. Resumo Executivo
Esta proposta descreve uma solução de E‑commerce baseada em microserviços, com um **frontend web** (SPA) consumindo vários backends especializados: **Usuários**, **Produtos**, **Pedidos** e **Pagamentos**. A arquitetura foca em escalabilidade, independência de implantação, observabilidade e facilidade de teste.

---

## 2. Objetivos
- Fornecer uma loja online responsiva para clientes.
- Separar responsabilidades por domínio (users, products, orders, payments).
- Permitir deploy independente e escalonamento por serviço.
- Garantir segurança (autenticação/autorização) e resiliência (retry, circuit breaker).
- Facilitar integração entre frontend e APIs via HTTP/REST (ou GraphQL quando aplicável).

---

## 3. Visão Geral dos Componentes
- **Frontend (SPA)**: React / Vue / Angular — autenticação, catálogo, carrinho, checkout.
- **API Gateway**: Roteamento, autenticação, rate limiting (ex: Kong, Traefik, NGINX).
- **Microserviço Users**: Registro, login, perfil, autenticação JWT/OAuth2.
- **Microserviço Products**: Catálogo, categorias, busca, inventário (consultas).
- **Microserviço Orders**: Carrinho, criação de pedidos, status, histórico.
- **Microserviço Payments**: Integração com provedores (Stripe, PayPal) e processamento.
- **Serviços de suporte**: Auth service, Notification (e‑mail), Search (Elastic), Message Broker (RabbitMQ / Kafka), Database(s).
- **Banco de Dados**: Cada serviço tem seu banco (ex: Postgres para domain data, Redis para cache/session).
- **Observability**: Prometheus + Grafana, ELK/EFK stack, tracing com Elastic APM.

---

## 4. Principais Microserviços e Endpoints (exemplos REST)

### Users Service
- `POST /api/users/register` — registra usuário (body: name, email, password)
- `POST /api/users/login` — retorna JWT
- `GET /api/users/me` — perfil do usuário (autenticado)
- `PUT /api/users/me` — atualiza perfil

### Products Service
- `GET /api/products` — lista com filtros (category, q, page, size)
- `GET /api/products/{id}` — detalhes do produto
- `POST /api/products` — cria produto (admin)
- `PUT /api/products/{id}` — atualiza produto (admin)

### Orders Service
- `POST /api/orders` — cria pedido (body inclui items, shipping, paymentMethod)
- `GET /api/orders/{id}` — detalhes do pedido (proprietário/admin)
- `GET /api/orders?userId={id}` — histórico de pedidos do usuário
- `PUT /api/orders/{id}/status` — atualizar status (pagamento, envio) (admin)

### Payments Service
- `POST /api/payments/create-session` — inicia sessão de pagamento (retorna url/checkout)
- `POST /api/payments/webhook` — webhook de status (p.ex. Stripe)
- `GET /api/payments/{id}` — consulta status do pagamento

---

## 5. Fluxo Principal (Checkout) — Domain Storytelling (texto)
1. **Cliente** (ator) navega no **Frontend** e adiciona **Produto** ao **Carrinho**.
2. **Cliente** inicia checkout; Frontend chama **Users Service** para obter perfil (autenticação) e **Products Service** para validar estoque e preços.
3. **Frontend** chama **Orders Service** para criar rascunho de pedido (`POST /api/orders`) com itens e dados de envio.
4. **Orders Service** publica evento `order:created` no message broker.
5. **Payments Service** é acionado (ou Frontend redireciona para provedor) para iniciar pagamento (`POST /api/payments/create-session`).
6. Provedor de pagamento processa e notifica via **Webhook** para `Payments Service`.
7. **Payments Service** valida e publica `payment:confirmed`.
8. **Orders Service** consome `payment:confirmed` e atualiza status do pedido para `PAID` — então desencadeia `order:confirmed` (notificação e preparação para envio).
9. **Notification Service** envia e‑mail para o cliente.

Observações:
- Eventos (order:created, payment:confirmed) permitem comunicação assíncrona e desacoplada.
- Se o pagamento falhar, `payment:failed` atualiza pedido para `FAILED` e cliente é notificado.

---

## 6. User Stories (exemplos)
- Como **cliente**, quero me cadastrar e logar para acompanhar meus pedidos.
- Como **cliente**, quero buscar produtos por nome/categoria para encontrar itens.
- Como **cliente**, quero adicionar produtos ao carrinho e finalizar compra para adquirir produtos.
- Como **gerente/admin**, quero gerenciar catálogo de produtos para manter o portfólio atualizado.
- Como **operador**, quero ver lista de pedidos e alterar status de envio para operar logística.

---

## 7. Cenários de Teste (BDD — Gherkin)

### Cenário: Cliente finaliza compra com sucesso
```
Dado que o Cliente fez login e tem um carrinho com 2 itens
E que o estoque dos produtos está suficiente
Quando o Cliente confirmar o pedido e efetuar pagamento válido
Então o Pedido deve ser criado com status "PAID"
E o Cliente recebe um e‑mail de confirmação
```

### Cenário: Pagamento recusado
```
Dado que o Cliente preencheu os dados de pagamento com cartão inválido
Quando tentar processar o pagamento
Então o Pagamento deve ser marcado como "FAILED"
E o Pedido permanece em "PENDING_PAYMENT"
E o Cliente vê a mensagem "Pagamento recusado"
```

---

## 8. Modelos de Dados (simplificado)

### Product
```json
{
  "id": "uuid",
  "name": "string",
  "description": "string",
  "price": 199.99,
  "stock": 120,
  "category": "string",
  "images": ["url"]
}
```

### Order
```json
{
  "id": "uuid",
  "userId": "uuid",
  "items": [{"productId":"uuid","qty":2,"price":199.99}],
  "total": 399.98,
  "status": "PENDING_PAYMENT|PAID|CANCELLED|SHIPPED",
  "shipping": {...},
  "createdAt": "iso8601"
}
```

### Payment
```json
{
  "id": "uuid",
  "orderId": "uuid",
  "provider": "stripe",
  "status": "CREATED|CONFIRMED|FAILED",
  "providerSessionId": "string",
  "amount": 399.98
}
```

---

## 9. Integração Frontend ↔ Backend (padrões e boas práticas)
- Frontend chama o **API Gateway** (ex: `/api/*`), que faz roteamento para os microserviços.
- Autenticação: JWT obtido via `POST /api/users/login`, enviado em `Authorization: Bearer <token>`.
- Frontend valida dados localmente antes de enviar (forms).
- Usar retries exponenciais, service mesh e circuit breaker no gateway para chamadas críticas.
- Pagamentos: usar redirect para provedores ou integrar via sessão segura; nunca armazenar dados de cartão no servidor.

---

## 10. Tecnologias sugeridas (open source)
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

---

## 11. Segurança e Conformidade
- HTTPS obrigatório; HSTS.
- Proteção contra CSRF, XSS e SQL injection.
- Tokens com expiração curta e refresh token seguro.
- Logs sem dados sensíveis (compliance com melhores práticas).

---

## 12. Deploy e Infraestrutura
- Deploy em Kubernetes e docker-compose.
- Separar ambientes: dev / staging / prod.
- Backups regulares para bancos de dados; restore testado.
- Autoscaling horizontal para serviços stateless (frontend, backends).
- Possibilidade de usar istio service mesh no K8S

---

## 13. Observability e Operação
- Métricas por serviço (latência, erros, throughput).
- Alertas (CPU, memória, error rate, queue lag).
- Tracing distribuído para diagnosticar latência entre serviços.

---

## 14. Extensões Futuras
- Programas de fidelidade e cupom.
- Recomendações com ML.
- Integração logística via eventos.

---

## 15. Anexo: Estrutura de Pastas (exemplo monorepo)
```
/ecom
  /frontend
  /backend
    /usuarios
    /produtos
    /estoque
    /pedidos
    /pagamento
    /notificacao
  /infra
    /k8s
    /docker-compose
      /singlenode
      /swarm
```

---

## 16. Conclusão
Arquitetura modular que permite evolução incremental. Separar responsabilidades reduz risco, facilita testes e permite scaling independente do domínio.


