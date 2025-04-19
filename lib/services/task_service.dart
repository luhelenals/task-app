import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../models/task_model.dart';
import '../pages/home.dart';

class TaskService {
  final _uuid = const Uuid();
  final Box<Task> taskBox = Hive.box('tasks');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Task?> getTaskById(String taskId) async {
    try {
      final task = taskBox.get(taskId);
      if (task != null) {
        return task;
      } else {
        // Tente buscar no Firestore caso não tenha no Hive
        final snapshot = await _firestore.collection('tasks').doc(taskId).get();
        if (snapshot.exists) {
          final data = snapshot.data()!;
          final task = Task(
            id: snapshot.id,
            uid: data['uid'],
            titulo: data['titulo'],
            descricao: data['descricao'],
            dataCriacao: DateTime.parse(data['dataCriacao']),
            favorita: data['favorita'] ?? false,
            concluida: data['concluida'] ?? false,
          );
          await taskBox.put(task.id, task); // Salvando no Hive para futuras consultas
          return task;
        }
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<List<Task>> getTasksByUser(String uid) async {
    // Filtrando as tarefas pelo usuário
    return taskBox.values.where((task) => task.uid == uid).toList();
  }

  Future<List<Task>> getFavoriteTasksByUser(String uid) async {
    // Filtrando as tarefas pelo usuário
    return taskBox.values.where((task) => task.uid == uid && task.favorita).toList();
  }

  Future<List<Task>> getCompleteTasksByUser(String uid) async {
    // Filtrando as tarefas pelo usuário
    return taskBox.values.where((task) => task.uid == uid && task.concluida).toList();
  }

  Future<void> createTask({
    required BuildContext context,
    required String titulo,
    required String descricao,
    required String uid,
  }) async {
    final task = Task(
      id: _uuid.v4(),
      uid: uid,
      titulo: titulo,
      descricao: descricao,
      dataCriacao: DateTime.now(),
    );

    // Salva no Hive (local)
    await taskBox.put(task.id, task);

    // Salva no Firestore (nuvem)
    await _firestore.collection('tasks').doc(task.id).set({
      'uid': task.uid,
      'titulo': task.titulo,
      'descricao': task.descricao,
      'dataCriacao': task.dataCriacao.toIso8601String(),
      'favorita': task.favorita,
      'concluida': task.concluida,
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Home()),
    );
  }

  Future<void> deleteTask(String id) async {
    await taskBox.delete(id);
    await _firestore.collection('tasks').doc(id).delete();
  }

  Future<void> updateTask(Task task) async {
    await taskBox.put(task.id, task);

    await _firestore.collection('tasks').doc(task.id).update({
      'titulo': task.titulo,
      'descricao': task.descricao,
      'favorita': task.favorita,
      'concluida': task.concluida,
      // Opcional: atualizar data de modificação
    });
  }

  Future<void> syncTasksFromFirebase(String uid) async {
    final snapshot = await _firestore
        .collection('tasks')
        .where('uid', isEqualTo: uid)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final task = Task(
        id: doc.id,
        uid: data['uid'],
        titulo: data['titulo'],
        descricao: data['descricao'],
        dataCriacao: DateTime.parse(data['dataCriacao']),
        favorita: data['favorita'] ?? false,
        concluida: data['concluida'] ?? false,
      );
      await taskBox.put(task.id, task);
    }
  }
}