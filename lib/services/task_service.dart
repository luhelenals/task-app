import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../models/task_model.dart';
import '../pages/home.dart';

class TaskService {
  final _uuid = const Uuid();
  final Box<Task> taskBox = Hive.box('tasks');

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
    Task task = Task(
      id: _uuid.v4(),
      uid: uid,
      titulo: titulo,
      descricao: descricao,
      dataCriacao: DateTime.now(),
    );

    await taskBox.put(task.id, task); // Adicionando ou atualizando a tarefa

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Home()),
    );
  }

  Future<void> deleteTask(String id) async {
    await taskBox.delete(id); // Removendo a tarefa
  }

  Future<void> updateTask(Task task) async {
    await taskBox.put(task.id, task); // Atualizando a tarefa
  }
}