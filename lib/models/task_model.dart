class Task {
  String id; // ID único da tarefa (pode ser o id do documento no Firebase)
  String uid; // ID do usuário (vinculado ao Firebase Auth)
  String titulo;
  String descricao;
  DateTime dataCriacao;
  bool concluida;
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

  // Converter para Map (para salvar no Firebase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'titulo': titulo,
      'descricao': descricao,
      'dataCriacao': dataCriacao.toIso8601String(),
      'concluida': concluida,
      'favorita': favorita,
    };
  }

  // Criar a partir de Map (para recuperar do Firebase)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      dataCriacao: DateTime.parse(map['dataCriacao']),
      concluida: map['concluida'] ?? false,
      favorita: map['favorita'] ?? false,
    );
  }
}
