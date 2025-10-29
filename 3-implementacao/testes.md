
## Testes Unitários

### Frontend e Backends:
- Componentes de UI: Testes para componentes
- Testes de limites inferiores e superiores considerando o contexto dos dados e campos de inputs
- Utilitários: Funções de formatação de campos
- Controladores: Lógica de CRUD e outras funcionalidades
- Autenticação JWT, validação de dados
- Modelos de dados e transformações de dados

## Testes de Integração : usar os cenários de BDD definidos em Gherkin

### API Integration:
- Autenticação: Login, registro, renovação de tokens
- CRUD: Criar, listar, editar, deletar registros
- Eventos: Comunicação assíncrona

### Database Integration:
- Operações: Inserção, consulta, atualização de dados
- Relacionamentos: Testes de foreign keys entre os vários microsserviços
- Transações: Testes o fluxo com base no padrão de projeto SAGA

### Frontend-Backend Integration:
- Fluxo completo de autenticação: Do login até acesso a recursos protegidos
- Criação e exibição de dados: Interface → API → Banco → Interface
- Atualizações em tempo real: WebSocket ou polling para feed atualizado

## Testes de Interface do Usuário End-to-End (E2E)

### Fluxos de usuário completos:
- Registro e primeiro login
- Criar registros
- Navegação entre diferentes seções da aplicação
- Teste de carga

## Ferramentas Recomendadas

Frontend e Backend:
- Bibliotecas específicas de cada linguagem
- Selenium para navegação sintética
- Sonar Qube para avaliar possíveis vulnerabilidades de segurança
- K6 para teste de performance
- Cucumber para BDD

## Formato de saída:

- Os testes unitários devem ficar dentro de cada componente
- Os testes de integração e de interface do usuário (E2E) devem ser criados na pasta "testes_integracao" que reprenta um projeto independente a ser mantido pela equipe de QA.
- Usar Docker Compose para possibilidar um ambiente de teste completo
- Propor os arquivos necessários para usar o GitHub Actions como ferramenta de CI/CD automatizado

## Cenários de Teste Específicos
- Segurança: Prevenção de XSS, validação de tokens
- Performance: Carregamento com muitos posts e gets
- Concorrência: Múltiplos usuários disparando fluxos que envolvam transações
• Offline: Comportamento quando sem conexão para testar no frontend caso tenha sido definido implementar PWA

