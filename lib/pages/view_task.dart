import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_app/models/task_model.dart';
import 'package:task_app/pages/home.dart';
import 'package:task_app/services/task_service.dart';
import 'package:task_app/utils/button_helper.dart';
import 'package:task_app/utils/snackbar_helper.dart';
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
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  bool isLoading = true;
  final TaskService _taskService = TaskService(); // Instanciando o TaskService

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
    try {
      // Se a taskId não for nula, carrega os dados da tarefa
      Task? task = await _taskService.getTaskById(widget.taskId!);

      if (task != null) {
        _tituloController.text = task.titulo;
        _descricaoController.text = task.descricao;
      }
    } catch (e) {
      showSnackbar(message: "Erro ao carregar dados: $e", context: context);
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
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
                  const SizedBox(height: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                        Row(
                          children: [
                            Expanded(child: _salvar(context)),
                            const SizedBox(width: 16),
                            if (widget.taskId != null) _delete(context),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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

  Widget _delete(BuildContext context) {
    return Expanded( // Para alinhar junto com o botão salvar
      child: ElevatedButtonHelper(
        title: "Apagar",
        onPressed: () async {
          if (widget.taskId == null) return;

          try {
            await _taskService.deleteTask(widget.taskId!);

            showSnackbar(message: "Tarefa apagada com sucesso!", context: context);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Home()),
            );
          } catch (e) {
            showSnackbar(message: "Erro ao apagar a tarefa: $e", context: context);
          }
        },
      ),
    );
  }

  Widget _salvar(BuildContext context) {
    return ElevatedButtonHelper(
      onPressed: () async {
        if (widget.taskId == null) {
          // Criar nova tarefa
          try {
            await _taskService.createTask(
              context: context,
              titulo: _tituloController.text,
              descricao: _descricaoController.text,
              uid: FirebaseAuth.instance.currentUser!.uid,
            );
          } catch (e) {
            showSnackbar(message: "Erro ao criar tarefa: $e", context: context);
          }
        } else {
          // Atualizar tarefa existente
          try {
            final task = Task(
              id: widget.taskId!,
              uid: FirebaseAuth.instance.currentUser!.uid,
              titulo: _tituloController.text,
              descricao: _descricaoController.text,
              dataCriacao: DateTime.now(),
            );

            await _taskService.updateTask(task);

            showSnackbar(message: "Tarefa atualizada com sucesso!", context: context);
          } catch (e) {
            showSnackbar(message: "Erro ao atualizar tarefa: $e", context: context);
          }
        }

        // Volta para Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Home()),
        );
      },
      title: widget.taskId == null ? "Criar" : "Salvar",
    );
  }
}
