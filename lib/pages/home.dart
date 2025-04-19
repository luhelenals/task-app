import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:task_app/pages/view_task.dart';
import 'package:task_app/services/task_service.dart';
import '../models/task_model.dart';
import '../services/auth_service.dart';

enum SortOption { title, creationDate }

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SortOption? _sortOption;
  final TaskService _taskService = TaskService();
  late Box<Task> taskBox = initTaskBox() as Box<Task>; 
  
  Future<Box<Task>> initTaskBox() async {
    return await Hive.openBox<Task>('tasks');
  }

  List<Task>? _filteredTasks;
  bool _isFiltered = false;
  late final String uid;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
    TaskService().syncTasksFromFirebase(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _logout(),
                  _filterFavorites(),
                  _filterComplete(),
                  _showAllTasks(),
                  _addTask(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final name = FirebaseAuth.instance.currentUser!.displayName!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Olá, ',
              style: GoogleFonts.raleway(
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            Text(
              name,
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
        PopupMenuButton<SortOption>(
          icon: const Icon(Icons.sort, color: Colors.black),
          tooltip: 'Ordenar tarefas',
          onSelected: (SortOption selectedOption) async {
            final tasks = await _taskService.getTasksByUser(uid);
            _sortTasks(selectedOption, tasks);
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
            const PopupMenuItem<SortOption>(
              value: SortOption.title,
              child: Text('Ordenar pelo título'),
            ),
            const PopupMenuItem<SortOption>(
              value: SortOption.creationDate,
              child: Text('Ordenar pela data de criação'),
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

  Widget _addTask() {
    return IconButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ViewTask()
          )
        );
      },
      icon: const Icon(Icons.add, color: Colors.black)
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
          onPressed: () async {
            setState(() {
              task.concluida = !task.concluida;
            });

            // Atualiza a tarefa no Hive e no Firestore
            await _taskService.updateTask(task); // Atualizando no Firestore
            await taskBox.put(task.id, task); // Atualizando no Hive
          },
        ),
        title: Text(task.titulo),
        subtitle: Text(task.descricao),
        trailing: IconButton(
          icon: Icon(
            task.favorita ? Icons.star : Icons.star_border,
          ),
          color: task.favorita ? Colors.black : Colors.grey,
          onPressed: () async {
            setState(() {
              task.favorita = !task.favorita;
            });

            // Atualiza a tarefa no Hive e no Firestore
            await _taskService.updateTask(task); // Atualizando no Firestore
            await taskBox.put(task.id, task); // Atualizando no Hive
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

  void _sortTasks(SortOption option, List<Task> tasks) {
    setState(() {
      _sortOption = option;
      if (option == SortOption.title) {
        tasks.sort((a, b) => a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase()));
      } else if (option == SortOption.creationDate) {
        tasks.sort((a, b) => a.dataCriacao.compareTo(b.dataCriacao));
      }
      _filteredTasks = tasks;
      _isFiltered = true;
    });
  }
}