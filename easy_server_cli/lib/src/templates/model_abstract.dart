const modelAbstractTemplate = '''abstract class Model {
  Model() {
    throw Error();
  }
  factory Model.fromJson(Map<String, dynamic> json) {
    throw Error();
  }
  Map<String, dynamic> toJson();
}''';
