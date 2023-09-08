const modelTemplate = '''
class class_name implements Model {
vars

  class_name({
reqs
  });

  ///Transforms your model into a Map with a json like structure.
  @override
  Map<String, dynamic> toJson() {
    return {
tojson
    };
  }

  ///Creates a model from a map that has a json like structure, if you use this function yourself be absolutely sure that your map has a proper format that has the same keys as calling toJson on this method.
  @override
  factory class_name.fromJson(Map<String, dynamic> json) {
    return class_name(
fromjson
    );
  }
}''';
