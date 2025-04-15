class Task {
  String titulo;
  String descricao;
  final DateTime dataCriacao;
  bool concluida;

  Task({
    required this.titulo,
    required this.descricao,
    DateTime? dataCriacao,
    this.concluida = false,
  }) : dataCriacao = dataCriacao ?? DateTime.now();
}