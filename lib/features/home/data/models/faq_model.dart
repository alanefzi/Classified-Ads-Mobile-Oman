class FaqModel {
  final int id;
  final String questionAr;
  final String answerAr;

  FaqModel({required this.id, required this.questionAr, required this.answerAr});

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['id'] as int,
      questionAr: json['question_ar'] ?? '',
      answerAr: json['answer_ar'] ?? '',
    );
  }
}
