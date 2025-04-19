import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_app/pages/view_task.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import '../services/auth_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TaskService _taskService = TaskService();
  List<Task>? _filteredTasks;
  bool _isFiltered = false;
  late final String uid;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => ViewTask()
            )
          );
        },
        backgroundColor: const Color(0xff0D6EFD),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Task>>(
                  future: _taskService.getTasksByUser(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text('Erro ao carregar tarefas: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Nenhuma tarefa encontrada.'));
                    }

                    final tasks = _isFiltered ? _filteredTasks! : snapshot.data!;
                    return ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return _buildTaskCard(task);
                      },
                    );
                  },
                ),
              ),
              Row(
                children: [
                  _logout(),
                  const SizedBox(width: 10),
                  _filterFavorites(),
                  const SizedBox(width: 10),
                  _filterComplete(),
                  const SizedBox(width: 10),
                  _showAllTasks()
              ],)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final email = FirebaseAuth.instance.currentUser!.email!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Olá,',
              style: GoogleFonts.raleway(
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              email,
              style: GoogleFonts.raleway(
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _logout() {
    return IconButton(
      icon: const Icon(Icons.logout, color: Colors.black,),
      tooltip: "Sair",
      onPressed: () async {
        await AuthService().signout(context: context);
      },
    );
  }

  Widget _showAllTasks() {
    return IconButton(
      icon: const Icon(Icons.list, color: Colors.black),
      tooltip: "Todas",
      onPressed: () async {
        final favoriteTasks = await _taskService.getTasksByUser(uid);
        setState(() {
          _filteredTasks = favoriteTasks;
          _isFiltered = true;
        });
      },
    );
  }

  Widget _filterFavorites() {
    return IconButton(
      icon: const Icon(Icons.star, color: Colors.black),
      tooltip: "Favoritas",
      onPressed: () async {
        final favoriteTasks = await _taskService.getFavoriteTasksByUser(uid);
        setState(() {
          _filteredTasks = favoriteTasks;
          _isFiltered = true;
        });
      },
    );
  }

  Widget _filterComplete() {
    return IconButton(
      icon: const Icon(Icons.check_circle, color: Colors.black),
      tooltip: "Concluídas",
      onPressed: () async {
        final completeTasks = await _taskService.getCompleteTasksByUser(uid);
        setState(() {
          _filteredTasks = completeTasks;
          _isFiltered = true;
        });
      },
    );
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: IconButton(
          icon: Icon(
            task.concluida ? Icons.check_circle : Icons.circle_outlined,
          ),
          color: task.concluida ? Colors.black : Colors.grey,
          onPressed: () {
            setState(() {
              task.concluida = !task.concluida;
              task.save();
            });
          },
        ),
        title: Text(task.titulo),
        subtitle: Text(task.descricao),
        trailing: IconButton(
          icon: Icon(
            task.favorita ? Icons.star : Icons.star_border,
          ),
          color: task.favorita ? Colors.black : Colors.grey,
          onPressed: () {
            setState(() {
              task.favorita = !task.favorita;
              task.save();
            });
          },
        ),
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => ViewTask(taskId: task.id),
            ),
          );
        },
      ),
    );
  }
}
