# MesclaInvest

Aplicação mobile desenvolvida como parte do Projeto Integrador 3 (2026) do curso de Engenharia de Software da PUC-Campinas.

O projeto consiste na implementação de uma plataforma digital para simulação de investimento em startups vinculadas ao ecossistema Mescla, por meio da negociação simulada de tokens.

---

## ✨ Funcionalidades

- Cadastro e autenticação de usuários
- Visualização de startups disponíveis para investimento
- Compra e venda de tokens
- Acompanhamento de saldo e investimentos
- Simulação de valorização de ativos

---

## 👩‍💻 Integrantes

- Ana Júlia Conceição da Silva
- Diogo Gonçalves Tonhosolo
- Felipe Lima Miranda
- Laura Cristine Soares
- Lucas David de Sousa
- Marília Sara Pereira dos Santos

## 🛠 Tecnologias Utilizadas

### Backend
- Node.js (LTS)
- TypeScript / JavaScript
- Firebase Firestore

### Frontend
- Flutter
- Dart

### Controle de Versão
- Git
- GitHub

---

## 📁 Estrutura do Projeto

```
MesclaInvest/
├── backend/    # API e regras de negócio  
├── frontend/   # Aplicação mobile (Flutter)  
├── docs/       # Documentação do projeto  
└── README.md  
```

## 🔐 Configuração do Firebase

Para executar o projeto corretamente, é necessário configurar o Firebase:

### 1. Criar projeto
- Acesse o Firebase Console
- Crie um novo projeto

### 2. Adicionar app Android
- Clique em "Adicionar app"
- Informe o nome do pacote (ex: `com.exemplo.app`)
- Baixe o arquivo `google-services.json`

### 3. Adicionar ao projeto Flutter
Coloque o arquivo em: android/app/google-services.json

### 4. Ativar serviços no Firebase

Ative os seguintes recursos:

- Authentication → método Email/Senha
- Firestore Database
- Cloud Functions

### 5. Configurar regras do Firestore (modo desenvolvimento)

```js
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

## 🚀 Como Executar o Projeto

### Backend

1. Acessar a pasta `backend/functions`
2. Instalar dependências:
   ```bash
   npm install
3. Fazer Login
   ```bash
   firebase login
5. Selecionar Projeto
   ```bash
   firebase use --add
6. Deploy das Funções
   ```bash
   firebase deploy --only functions
7. Acessar pasta `/frontend`
8. Instalar Dependências
   ```bash
   flutter pub get
9. Rodar o app
```bash
flutter run
