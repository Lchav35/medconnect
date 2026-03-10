# Guia de Configuração do Firebase

Este guia detalha como configurar o Firebase para o sistema Med Connect.

## 1. Criar Projeto Firebase

1. Acesse https://console.firebase.google.com/
2. Clique em "Adicionar projeto"
3. Nome do projeto: "Med Connect" (ou nome de sua preferência)
4. Desabilite Google Analytics (opcional)
5. Clique em "Criar projeto"

## 2. Configurar Authentication

1. No menu lateral, clique em "Authentication"
2. Clique em "Começar"
3. Ative o método "Email/senha"
4. Clique em "Salvar"

### Criar Usuários de Teste

1. Vá para a aba "Users"
2. Clique em "Add user"
3. Crie os seguintes usuários:

```
ACS de Teste:
Email: acs@demo.com
Senha: demo123456

Médico de Teste:
Email: medico@demo.com
Senha: demo123456

Gestor de Teste:
Email: gestor@demo.com
Senha: demo123456
```

## 3. Configurar Firestore Database

1. No menu lateral, clique em "Firestore Database"
2. Clique em "Criar banco de dados"
3. Selecione "Modo de teste" (para desenvolvimento)
4. Escolha a localização (southamerica-east1 para Brasil)
5. Clique em "Ativar"

### Criar Estrutura Inicial

Execute os seguintes comandos no console do Firestore ou use o script Python fornecido:

#### Criar Município Exemplo

```json
Collection: municipios
Document ID: demo_municipio_001
{
  "nome": "Município Demonstração",
  "estado": "SP",
  "codigo_ibge": "3550308",
  "plano": {
    "limite_vidas": 5000,
    "limite_usuarios": 100,
    "limite_unidades": 20,
    "vidas_ativas": 0,
    "usuarios_ativos": 0,
    "unidades_ativas": 0
  },
  "ativo": true,
  "criado_em": "timestamp"
}
```

#### Criar Unidade de Saúde Exemplo

```json
Collection: municipios/demo_municipio_001/units
Document ID: demo_unidade_001
{
  "municipio_id": "demo_municipio_001",
  "nome": "UBS Centro",
  "cnes": "1234567",
  "endereco": {
    "logradouro": "Rua Principal",
    "numero": "100",
    "bairro": "Centro",
    "cidade": "Município Demonstração",
    "estado": "SP",
    "cep": "12345-678"
  },
  "ativo": true,
  "criado_em": "timestamp"
}
```

## 4. Configurar Storage

1. No menu lateral, clique em "Storage"
2. Clique em "Começar"
3. Aceite as regras padrão (modo teste)
4. Escolha a mesma localização do Firestore
5. Clique em "Concluído"

## 5. Configurar Web App

1. No painel principal, clique no ícone "</>" (Web)
2. Registre o app com o apelido "Med Connect Web"
3. Marque "Configure Firebase Hosting" (opcional)
4. Clique em "Registrar app"
5. Copie as configurações do Firebase

### Criar arquivo firebase_options.dart

Crie o arquivo `lib/firebase_options.dart` com o seguinte conteúdo:

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'SUA_API_KEY_WEB',
    appId: 'SEU_APP_ID_WEB',
    messagingSenderId: 'SEU_MESSAGING_SENDER_ID',
    projectId: 'SEU_PROJECT_ID',
    authDomain: 'SEU_PROJECT_ID.firebaseapp.com',
    storageBucket: 'SEU_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'SUA_API_KEY_ANDROID',
    appId: 'SEU_APP_ID_ANDROID',
    messagingSenderId: 'SEU_MESSAGING_SENDER_ID',
    projectId: 'SEU_PROJECT_ID',
    storageBucket: 'SEU_PROJECT_ID.appspot.com',
  );
}
```

### Atualizar main.dart

Substitua a inicialização do Firebase no `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializar Hive para armazenamento offline
  await Hive.initFlutter();

  runApp(const MyApp());
}
```

## 6. Configurar Android App (para APK)

1. No Firebase Console, adicione um app Android
2. Nome do pacote: `com.medconnect.health`
3. Baixe o arquivo `google-services.json`
4. Coloque em `android/app/google-services.json`
5. Siga as instruções para adicionar o plugin do Google Services

### Atualizar android/build.gradle

Adicione ao final do arquivo:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.2'
    }
}
```

### Atualizar android/app/build.gradle

Adicione no final do arquivo:

```gradle
apply plugin: 'com.google.gms.google-services'
```

## 7. Regras de Segurança do Firestore

Substitua as regras do Firestore por:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Função auxiliar para verificar autenticação
    function isSignedIn() {
      return request.auth != null;
    }
    
    // Função para verificar se o usuário pertence ao município
    function belongsToMunicipality(municipalityId) {
      return isSignedIn() && 
             request.auth.token.municipioId == municipalityId;
    }
    
    // Função para verificar role do usuário
    function hasRole(role) {
      return isSignedIn() && request.auth.token.role == role;
    }
    
    // Regras para municípios
    match /municipios/{municipioId} {
      allow read: if belongsToMunicipality(municipioId) || 
                     hasRole('super_admin');
      allow write: if hasRole('super_admin') || 
                      hasRole('gestor_municipal');
      
      // Regras para unidades
      match /units/{unitId} {
        allow read: if belongsToMunicipality(municipioId);
        allow write: if hasRole('gestor_municipal') || 
                        hasRole('gestor_unidade');
      }
      
      // Regras para pacientes
      match /pacientes/{pacienteId} {
        allow read: if belongsToMunicipality(municipioId);
        allow create: if belongsToMunicipality(municipioId) && 
                         (hasRole('acs') || hasRole('medico'));
        allow update: if belongsToMunicipality(municipioId);
      }
      
      // Regras para receitas
      match /receitas/{receitaId} {
        allow read: if belongsToMunicipality(municipioId);
        allow create: if belongsToMunicipality(municipioId) && 
                         (hasRole('acs') || hasRole('medico'));
        allow update: if belongsToMunicipality(municipioId) && 
                         hasRole('medico');
      }
      
      // Regras para logs de auditoria (somente leitura)
      match /audit_logs/{logId} {
        allow read: if belongsToMunicipality(municipioId) && 
                       (hasRole('gestor_municipal') || 
                        hasRole('gestor_unidade'));
        allow write: if false; // Logs são imutáveis
      }
    }
    
    // Regras para usuários
    match /usuarios/{userId} {
      allow read: if isSignedIn() && 
                     (request.auth.uid == userId || 
                      hasRole('gestor_municipal') || 
                      hasRole('gestor_unidade'));
      allow write: if hasRole('gestor_municipal') || 
                      hasRole('gestor_unidade') || 
                      hasRole('super_admin');
    }
  }
}
```

## 8. Regras de Segurança do Storage

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /municipios/{municipioId}/{allPaths=**} {
      allow read: if request.auth != null && 
                     request.auth.token.municipioId == municipioId;
      allow write: if request.auth != null && 
                      request.auth.token.municipioId == municipioId;
    }
  }
}
```

## 9. Configurar Custom Claims (Cloud Functions)

Para configurar as roles dos usuários, você precisará de Cloud Functions.

### Criar Cloud Function

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.setUserRole = functions.https.onCall(async (data, context) => {
  // Verificar se o usuário chamador é admin
  if (!context.auth.token.role || 
      !['super_admin', 'gestor_municipal'].includes(context.auth.token.role)) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Apenas administradores podem atribuir roles.'
    );
  }

  const { userId, role, municipioId, unidadeId } = data;

  // Definir custom claims
  await admin.auth().setCustomUserClaims(userId, {
    role,
    municipioId,
    unidadeId,
  });

  return { message: 'Role atribuída com sucesso' };
});
```

## 10. Testar a Configuração

1. Execute o app: `flutter run -d chrome`
2. Faça login com um dos usuários de teste
3. Verifique se os dados são carregados corretamente
4. Teste a criação de novos registros

## Troubleshooting

### Erro: "No Firebase App '[DEFAULT]' has been created"
- Verifique se `firebase_options.dart` está correto
- Verifique se `Firebase.initializeApp()` está sendo chamado no `main()`

### Erro: "Permission denied" no Firestore
- Verifique as regras de segurança
- Verifique se o usuário tem os custom claims corretos

### Erro ao fazer login
- Verifique se Authentication está habilitado
- Verifique se o método Email/Senha está ativo

## Conclusão

Após seguir todos estes passos, seu sistema Med Connect estará configurado e pronto para uso com Firebase!
