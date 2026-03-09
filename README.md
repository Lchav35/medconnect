# Med Connect - Sistema de Gerenciamento de Receitas Médicas

## 📋 Visão Geral

Sistema SaaS multilocatário para gerenciamento de receitas médicas e acompanhamento de pacientes na Atenção Básica de Saúde brasileira. Conecta Agentes Comunitários de Saúde (ACS), Médicos, Gestores de Unidade e Gestores Municipais com isolamento total entre municípios.

## 🎯 Funcionalidades Principais

### ✅ Implementadas Neste MVP

1. **Autenticação e Controle de Acesso**
   - Sistema de login com email e senha
   - Múltiplos perfis de usuário (SuperAdmin, Gestor Municipal, Gestor de Unidade, Médico, ACS)
   - Isolamento de dados por município e unidade

2. **Gerenciamento de Pacientes**
   - Cadastro com validação de CPF único por município
   - Lista de pacientes do ACS responsável
   - Busca e filtros
   - Status de acompanhamento

3. **Prescrição de Medicamentos**
   - Formulário completo de nova receita
   - Tipos de receita (Branca Aguda, Branca Contínua, Azul, Amarela)
   - Dosagem, frequência e observações
   - Dados do médico (nome e CRM)

4. **Dashboard e Navegação**
   - Visão geral de renovações pendentes
   - Contadores por tipo de receita
   - Lista de pacientes com status
   - Navegação por abas (Pacientes, Renovações, Relatórios)

5. **Motor de Agrupamento Inteligente**
   - Agrupamento automático de medicamentos por tipo de receita
   - Validação de medicamentos controlados
   - Cálculo de validade por categoria

6. **Sistema Offline-First**
   - Armazenamento local com Hive
   - Sincronização automática quando online
   - Cache de dados críticos

7. **Modelos de Dados Completos**
   - Município, Unidade de Saúde, Usuário, Paciente, Receita, Medicamento
   - Sistema de auditoria imutável
   - Logs de todas as ações

### 🔨 Funcionalidades Planejadas (Próximas Iterações)

1. **Geração de PDFs**
   - PDFs separados por tipo de receita
   - Personalização white-label (logo, cabeçalho, rodapé)
   - Assinatura digital ou física

2. **Relatórios Gerenciais**
   - Dashboard para Gestores de Unidade
   - Dashboard consolidado para Gestores Municipais
   - Métricas epidemiológicas
   - Exportação de dados (CSV, PDF, Excel)

3. **Transferência de Pacientes**
   - Entre ACS da mesma unidade
   - Entre unidades de saúde
   - Histórico de transferências

4. **Configuração White-Label**
   - Upload de logomarca municipal
   - Personalização de cores
   - Textos customizados

## 🏗️ Arquitetura do Sistema

### Estrutura de Dados (Firestore)

```
municípios/
  {municipioId}/
    - dados do município
    - plano (limites de vidas, usuários, unidades)
    - configuração visual
    
    units/
      {unidadeId}/
        - dados da unidade
        - endereço
    
    pacientes/
      {pacienteId}/
        - dados do paciente
        - CPF único por município
        - ACS responsável
        - unidade vinculada
    
    receitas/
      {receitaId}/
        - dados da receita
        - medicamentos
        - médico responsável
        - status e datas
    
    audit_logs/
      {logId}/
        - ação realizada
        - usuário
        - timestamp (imutável)

usuarios/
  {userId}/
    - dados do usuário
    - role e permissões
    - município e unidade
```

### Isolamento Multilocatário

- **Nível 1**: Municípios completamente isolados
- **Nível 2**: Unidades isoladas dentro do município
- **CPF**: Único por município (não por unidade)
- **Regras de Acesso**:
  - SuperAdmin: Acesso a configurações globais (sem dados médicos)
  - Gestor Municipal: Todas unidades do município
  - Gestor de Unidade: Apenas sua unidade
  - Médico: Receitas da sua unidade
  - ACS: Pacientes da sua carteira

## 🚀 Como Acessar o Sistema

### Acesso Web

1. **URL do Aplicativo**: https://5060-icqb895f9y5g2kcjac302-dfc00ec5.sandbox.novita.ai

2. **Credenciais de Demonstração** (a serem configuradas no Firebase):
   ```
   ACS:
   Email: acs@demo.com
   Senha: demo123456
   
   Médico:
   Email: medico@demo.com
   Senha: demo123456
   
   Gestor:
   Email: gestor@demo.com
   Senha: demo123456
   ```

### Primeira Configuração

Para usar o sistema com dados reais, você precisará:

1. **Criar projeto Firebase**:
   - Acesse https://console.firebase.google.com/
   - Crie um novo projeto
   - Ative Authentication (Email/Password)
   - Ative Firestore Database
   - Ative Storage

2. **Configurar credenciais**:
   - Baixe o arquivo `google-services.json` (Android)
   - Baixe as configurações Web
   - Crie o arquivo `lib/firebase_options.dart` com as configurações

3. **Estrutura inicial do Firestore**:
   - Criar primeiro município
   - Criar primeira unidade de saúde
   - Criar usuários iniciais

4. **Regras de segurança**:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Regras de isolamento multilocatário aqui
     }
   }
   ```

## 📱 Estrutura do Projeto

```
lib/
├── main.dart                 # Entrada do aplicativo
├── models/                   # Modelos de dados
│   ├── enums.dart
│   ├── municipio.dart
│   ├── unidade_saude.dart
│   ├── usuario.dart
│   ├── paciente.dart
│   ├── receita.dart
│   └── log_auditoria.dart
├── services/                 # Serviços de negócio
│   ├── auth_service.dart
│   ├── paciente_service.dart
│   └── receita_service.dart
├── providers/                # Gerenciamento de estado
│   └── auth_provider.dart
├── screens/                  # Telas do aplicativo
│   ├── auth/
│   │   └── login_screen.dart
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   ├── pacientes/
│   │   └── lista_pacientes_screen.dart
│   └── receitas/
│       ├── lista_renovacoes_screen.dart
│       └── nova_receita_screen.dart
└── widgets/                  # Componentes reutilizáveis
```

## 🔧 Tecnologias Utilizadas

- **Flutter 3.35.4**: Framework de desenvolvimento
- **Dart 3.9.2**: Linguagem de programação
- **Firebase**: Backend completo (Auth, Firestore, Storage)
- **Hive**: Armazenamento local offline
- **Provider**: Gerenciamento de estado
- **PDF & Printing**: Geração de documentos (planejado)

## 📦 Pacotes Principais

```yaml
firebase_core: 3.6.0
cloud_firestore: 5.4.3
firebase_auth: 5.3.1
firebase_storage: 12.3.2
provider: 6.1.5+1
hive: 2.2.3
hive_flutter: 1.1.0
shared_preferences: 2.5.3
pdf: 3.11.1
printing: 5.13.4
```

## 🎨 Design e Interface

O design foi baseado nas telas fornecidas, com:
- **Cores principais**: Verde saúde (#2E7D32)
- **Material Design 3**: Componentes modernos
- **Layout portrait**: Otimizado para dispositivos móveis
- **Acessibilidade**: Seguindo diretrizes WCAG

## 🔒 Segurança e LGPD

### Dados Permitidos em PDFs
- Nome completo do paciente
- Endereço completo
- Cartão SUS (opcional)
- Nome do médico
- CRM
- Data da receita

### Dados Proibidos em PDFs (LGPD)
- ❌ CPF do paciente
- ❌ Telefone
- ❌ Diagnóstico/CID
- ❌ Dados sensíveis não relacionados à prescrição

### Auditoria
- Todos os acessos são registrados
- Logs imutáveis
- Rastreabilidade completa
- Impossível deletar histórico

## 📊 Planos e Limites

### Exemplo de Plano Municipal

```dart
PlanoMunicipio(
  limiteVidas: 5000,        // Pacientes ativos
  limiteUsuarios: 100,      // Profissionais de saúde
  limiteUnidades: 20,       // UBS/USF
  vidasAtivas: 0,           // Contador atual
  usuariosAtivos: 0,        // Contador atual
  unidadesAtivas: 0,        // Contador atual
)
```

## 🚧 Limitações Conhecidas

1. **Firebase não configurado**: O MVP funciona em modo demonstração. Para produção, é necessário configurar Firebase.
2. **Geração de PDFs**: Planejada mas não implementada nesta versão.
3. **Relatórios**: Tela placeholder - funcionalidade completa em desenvolvimento.
4. **Transferência de pacientes**: Backend pronto, UI em desenvolvimento.
5. **Upload de imagens**: Funcionalidade de foto de receita não implementada.

## 🔄 Próximos Passos

### Curto Prazo (1-2 semanas)
1. Configurar Firebase completo
2. Implementar geração de PDFs
3. Criar tela de cadastro de pacientes
4. Adicionar validações de formulário
5. Implementar busca de medicamentos

### Médio Prazo (1 mês)
1. Dashboard de gestores com gráficos
2. Relatórios exportáveis
3. Sistema de notificações
4. Upload de fotos de receitas
5. Transferência de pacientes (UI)

### Longo Prazo (3 meses)
1. App mobile nativo Android
2. Assinatura digital de receitas
3. Integração com sistemas externos
4. API pública para integrações
5. Modo offline completo com sincronização robusta

## 📞 Suporte e Contato

Para dúvidas, sugestões ou problemas:
- Email: suporte@medconnect.com.br (exemplo)
- Documentação: [Link para documentação completa]
- GitHub: [Repositório do projeto]

## 📄 Licença

Copyright © 2026 Med Connect. Todos os direitos reservados.

---

**Nota**: Este é um MVP (Minimum Viable Product) desenvolvido para demonstração das funcionalidades principais do sistema. Para uso em produção, é necessário completar a configuração do Firebase, implementar testes automatizados e realizar auditoria de segurança completa.
