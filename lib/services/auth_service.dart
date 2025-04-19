import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task_app/pages/home.dart';
import 'package:task_app/pages/login.dart';
import 'package:task_app/utils/snackbar_helper.dart';

class AuthService {
  // Método para criação de conta
  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required BuildContext context
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password
      );

      // Atualiza o nome no perfil do Firebase
      await userCredential.user!.updateDisplayName(name);

      // Recarrega o usuário para garantir que o nome esteja disponível
      await userCredential.user!.reload();

      // Exibe mensagem ou redireciona
      showSnackbar(context: context, message: 'Cadastro realizado com sucesso!');
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const Home()
        )
      );

      Navigator.of(context, rootNavigator: true).pop(); // fecha o diálogo    

    } 
    // Tratamento de exceções
    on FirebaseAuthException catch(e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'A senha utilizada é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Uma conta já existe com esse email.';
      } else {
        message = 'Erro: ${e.message}';
      }
      showSnackbar(message: message, isError: true, context: context);
    }
  }

  // Método para login
  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password
      );

      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const Home()
        )
      );
    }
    // Tratamento de exceções
    on FirebaseAuthException catch(e) {
      String message = '';
      if (e.code == 'user-not-found') {
        message = 'Usuário não encontrado.';
      } else if (e.code == 'wrong-password') {
        message = 'Senha incorreta.';
      } else {
        message = 'Erro ao autenticar: ${e.message}';
      }
      showSnackbar(message: message, isError: true, context: context);
    }
  }

  Future<void> signout({
    required BuildContext context
  }) async {
    
    await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>Login()
        )
      );
  }
}