import 'package:hive/hive.dart';

part 'task_model.g.dart'; // será gerado

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String uid;

  @HiveField(2)
  String titulo;

  @HiveField(3)
  String descricao;

  @HiveField(4)
  DateTime dataCriacao;

  @HiveField(5)
  bool concluida;

  @HiveField(6)
  bool favorita;

  Task({
    required this.id,
    required this.uid,
    required this.titulo,
    required this.descricao,
    required this.dataCriacao,
    this.concluida = false,
    this.favorita = false,
  });
}
