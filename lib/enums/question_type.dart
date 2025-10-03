enum QuestionType {
  multipleChoice,
  trueFalse,
  code,
  practical;

  String get label {
    switch (this) {
      case QuestionType.multipleChoice:
        return 'Choix multiple';
      case QuestionType.trueFalse:
        return 'Vrai/Faux';
      case QuestionType.code:
        return 'Code';
      case QuestionType.practical:
        return 'Pratique';
    }
  }

  static QuestionType parseType(String value) {
    switch (value.toLowerCase()) {
      case 'multiplechoice':
      case 'multiple_choice':
      case 'choix multiple':
        return QuestionType.multipleChoice;
      case 'truefalse':
      case 'true_false':
      case 'vrai/faux':
        return QuestionType.trueFalse;
      case 'code':
        return QuestionType.code;
      case 'pratique':
      case 'practical':
        return QuestionType.practical;
      default:
        return QuestionType.multipleChoice;
    }
  }
}