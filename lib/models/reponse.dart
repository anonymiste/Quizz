class Reponse {
  final String body;        // Le texte de la réponse
  final String value;       // La valeur/identifiant
  final bool check;         // Si c'est la bonne réponse
  final String questionId;  // ID de la question associée

  Reponse({
    required this.body,
    required this.value,
    required this.check,
    required this.questionId,
  });

  factory Reponse.fromJson(Map<String, dynamic> json) {
    return Reponse(
      body: json['body']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      check: json['check'] ?? json['is_correct'] ?? false,
      questionId: json['question_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'body': body,
      'value': value,
      'check': check,
      'question_id': questionId,
    };
  }
}