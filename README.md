# 📋 Task App

Um aplicativo de gerenciamento de tarefas desenvolvido em Flutter, com autenticação via Firebase, sincronização em tempo real e persistência local com Hive.

### Preview
https://github.com/user-attachments/assets/8eff8722-b9a8-49c2-8ce8-f7381b6d87f9

## ✨ Funcionalidades

- 📌 **Adicionar, visualizar e editar tarefas**
- ⭐ **Marcar tarefas como favoritas**
- ✅ **Marcar tarefas como concluídas**
- 🔍 **Filtrar tarefas (todas, favoritas, concluídas)**
- 🔀 **Ordenar tarefas por título ou data de criação**
- ☁️ **Sincronização com Firebase Firestore**
- 🔐 **Autenticação com Firebase**
- 📦 **Persistência offline com Hive**

## 📱 Telas

### Home
- Exibe a lista de tarefas associadas ao usuário logado.
- Ícone de ordenação no topo direito, com menu para:
  - Ordenar pelo título
  - Ordenar pela data de criação
- Ícones na parte inferior:
  - Fazer logout
  - Filtrar tarefas favoritas
  - Filtrar tarefas concluídas
  - Ver todas as tarefas
  - Cria nova tarefa

### ViewTask
- Tela de criação ou edição de uma tarefa.
- Campos: título e descrição

### Login
- Tela de login com emal e senha

### Signup
- Tela de criação de usuário com nome, email e senha

## 💾 Tecnologias utilizadas

- [Flutter](https://flutter.dev)
- [Firebase Auth](https://firebase.google.com/products/auth)
- [Firebase Firestore](https://firebase.google.com/products/firestore)
- [Hive](https://pub.dev/packages/hive)
- [Google Fonts](https://pub.dev/packages/google_fonts)

## 🧪 Estrutura do Projeto

```bash
lib/
├── models/
│   ├── task_model.dart
│   └── task_model.g.dart
├── pages/
│   ├── home.dart
│   ├── view_task.dart
│   ├── signup.dart
│   └── login.dart
├── services/
│   ├── auth_service.dart
│   └── task_service.dart
├── utils/
│   ├── button_helper.dart
│   └── snackbar_helper.dart
└── main.dart
```

## 🚀 Como executar
1. Clone o repositório:

```bash
git clone https://github.com/luhelenals/task-app.git
```

2. Instale as dependências:

```bash
flutter pub get
```

3. Configure o Firebase no seu projeto:
- Adicione os arquivos google-services.json (Android) ou GoogleService-Info.plist (iOS)
- Habilite Authentication e Firestore no console do Firebase

4. Execute o app:

```bash
flutter run
```
