import 'package:easy_server_cli/src/templates/model.dart';
import 'package:yaml/yaml.dart';
import 'package:easy_server_cli/generate.dart';

class GeneratedModel {
  ///the name of the class
  String className;

  ///the types inside the class
  final List<String> _typeList = [];

  ///the names of the fields
  final List<String> _names = [];

  ///create the pre-generated model
  GeneratedModel(MapEntry yamlEntry, StringBuffer imports)
      : className = yamlEntry.key {
    className = yamlEntry.key;
    final entries = _readYamlMap(yamlEntry.value);
    for (var entry in entries) {
      submit(entry.key, entry.value);
    }
  }

  ///submite a field with a [fieldName] and [type] to the model
  void submit(String fieldName, String type) {
    _typeList.add(type);
    _names.add(fieldName);
  }

  //get the values out of the yamlmap
  List<MapEntry> _readYamlMap(dynamic yaml) {
    try {
      return (yaml as YamlMap).entries.toList();
    } catch (e) {
      print("Error: $e");
      print("Formatting issue");
      throw Error();
    }
  }

  //write the base of the model
  String _base(String classTemplate, StringBuffer buffer) {
    for (int i = 0; i < _names.length; i++) {
      buffer.writeln('\t${_typeList[i]} ${_names[i]};');
    }
    classTemplate = classTemplate.replaceFirst('vars', buffer.toString());
    buffer.clear();
    for (String name in _names) {
      buffer.write('\t\trequired this.$name, ');
    }
    return classTemplate.replaceFirst('reqs', buffer.toString());
  }

  //write the tojson function of the model
  String _toJson(String classTemplate, StringBuffer buffer) {
    for (int i = 0; i < _names.length; i++) {
      if (modelTypes.contains(_typeList[i])) {
        buffer.write('\t\t\t"${_names[i]}": ${_names[i]}.toJson(),');
      } else {
        buffer.writeln('\t\t\t"${_names[i]}": ${_names[i]},');
      }
    }
    return classTemplate.replaceFirst('tojson', buffer.toString());
  }

  //write the fromJson function of the model
  String _fromJson(String classTemplate, StringBuffer buffer) {
    for (int i = 0; i < _names.length; i++) {
      if (modelTypes.contains(_typeList[i])) {
        buffer.writeln(
            '\t\t\t${_names[i]}: ${_typeList[i]}.fromJson(json["${_names[i]}"]),');
      } else {
        buffer.writeln('\t\t\t${_names[i]}: json["${_names[i]}"],');
      }
    }
    return classTemplate.replaceFirst('fromjson', buffer.toString());
  }

  ///convert the object to a file, the file will be created inside the function and is also returned
  void generate(StringBuffer modelbuffer) async {
    String classTemplate = modelTemplate;
    StringBuffer buffer = StringBuffer();
    classTemplate = classTemplate.replaceAll('class_name', className);
    classTemplate = _base(classTemplate, buffer);
    buffer.clear();
    classTemplate = _toJson(classTemplate, buffer);
    buffer.clear();
    classTemplate = _fromJson(classTemplate, buffer);
    buffer.clear();
    modelbuffer.write(classTemplate);
  }
}
