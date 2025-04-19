import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:task_app/models/task_model.dart';
import 'package:task_app/pages/home.dart';
import 'package:task_app/services/task_service.dart';
import 'package:uuid/uuid.dart';

class ViewTask extends StatefulWidget {
  final String? taskId;

  ViewTask({super.key, this.taskId}); // aceita um ID opcional

  @override
  State<ViewTask> createState() => _ViewTaskState();
}

class _ViewTaskState extends State<ViewTask> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TaskService _taskService = TaskService();
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.taskId != null) {
      _loadTaskData();
    } else {
      isLoading = false; // não precisa carregar
    }
  }

  Future<void> _loadTaskData() async {
    var box = await Hive.openBox<Task>('tasks');

    // Supondo que a taskId seja a key usada no Hive (ex: int ou String)
    final task = box.get(widget.taskId);

    if (task != null) {
      _tituloController.text = task.titulo;
      _descricaoController.text = task.descricao;
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const Home()),
                    );
                  },
                ),
              ],
            ),
            Text(
              widget.taskId == null ? 'Nova Tarefa' : 'Editar Tarefa',
              style: GoogleFonts.raleway(
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
            ),
            const SizedBox(height: 80),
            _titulo(),
            const SizedBox(height: 20),
            _descricao(),
            const SizedBox(height: 50),
            _salvar(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _titulo() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextField(
          controller: _tituloController,
          decoration: InputDecoration(
            filled: true,
            hintText: 'Título',
            hintStyle: const TextStyle(
              color: Color(0xff6A6A6A),
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            fillColor: const Color(0xffF7F7F9),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );

  Widget _descricao() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextField(
          controller: _descricaoController,
          decoration: InputDecoration(
            filled: true,
            hintText: 'Descrição',
            hintStyle: const TextStyle(
              color: Color(0xff6A6A6A),
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            fillColor: const Color(0xffF7F7F9),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );

  Widget _salvar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff0D6EFD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size(double.infinity, 60),
          elevation: 0,
        ),
        onPressed: () async {
          final box = await Hive.openBox<Task>('tasks');

          if (widget.taskId == null) {
            // Criar nova tarefa
            final newTask = Task(
              uid: FirebaseAuth.instance.currentUser!.uid,
              id: const Uuid().v4(),
              titulo: _tituloController.text,
              descricao: _descricaoController.text,
              dataCriacao: DateTime.now()
            );

            await box.put(newTask.id, newTask);
          } else {
            // Atualizar tarefa existente
            final task = box.get(widget.taskId);
            if (task != null) {
              task.titulo = _tituloController.text;
              task.descricao = _descricaoController.text;
              await task.save();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Tarefa atualizada com sucesso!")),
              );
            }
          }

          // Volta para Home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Home()),
          );
        },
        child: Text(widget.taskId == null ? "Criar" : "Salvar"),
      ),
    );
  }
}