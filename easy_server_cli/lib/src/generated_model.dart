import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:easy_server_cli/generate.dart';

class GeneratedModel {
  ///the name of the class
  String className;

  ///the types inside the class
  final List<String> _typeList = [];

  ///the names of the fields
  final List<String> _names = [];

  GeneratedModel(MapEntry yamlEntry, StringBuffer imports)
      : className = yamlEntry.key {
    className = yamlEntry.key;
    imports.writeln(
        'export "./models/${yamlEntry.key.toString().toLowerCase()}.dart";\n');
    final entries = readYamlMap(yamlEntry.value);
    for (var entry in entries) {
      submit(entry.key, entry.value);
    }
  }

  void submit(String fieldName, String type) {
    _typeList.add(type);
    _names.add(fieldName);
  }

  List<MapEntry> readYamlMap(dynamic yaml) {
    try {
      return (yaml as YamlMap).entries.toList();
    } catch (e) {
      print("Error: $e");
      print("Formatting issue");
      throw Error();
    }
  }

  void _base(StringBuffer buffer) {
    for (int i = 0; i < _names.length; i++) {
      buffer.writeln('  ${_typeList[i]} ${_names[i]};');
    }
    buffer.writeln();
    buffer.writeln();
    buffer.write('  $className({');
    for (String name in _names) {
      buffer.write('required this.$name, ');
    }
    buffer.writeln('});');
  }

  void _toJson(StringBuffer buffer) {
    buffer.writeln();
    buffer.writeln('\t@override');
    buffer.writeln('\tMap<String, dynamic> toJson() {');
    buffer.writeln('\t\treturn {');
    for (int i = 0; i < _names.length; i++) {
      if (modelTypes.contains(_typeList[i])) {
        buffer.write('\t\t\t\'${_names[i]}\': ${_names[i]}.toJson(),');
      } else {
        buffer.writeln('\t\t\t\'${_names[i]}\': ${_names[i]},');
      }
    }
    buffer.writeln('\t\t};');
    buffer.writeln('\t}');
  }

  void _fromJson(StringBuffer buffer) {
    buffer.writeln();
    buffer.writeln('\t@override');
    buffer.writeln('\tfactory $className.fromJson(Map<String,dynamic> json) {');
    buffer.writeln('\t\treturn $className(');
    for (int i = 0; i < _names.length; i++) {
      if (modelTypes.contains(_typeList[i])) {
        buffer.writeln(
            '\t\t\t${_names[i]}: ${_typeList[i]}.fromJson(json["${_names[i]}"]),');
      } else {
        buffer.writeln('\t\t\t${_names[i]}: json["${_names[i]}"],');
      }
    }
    buffer.writeln('\t\t);');
    buffer.writeln('\t}');
  }

  ///convert the object to a file, the file will be created inside the function and is also returned
  Future<File> toFile(String pathToFolder) async {
    File file = File('$pathToFolder/${className.toLowerCase()}.dart');
    StringBuffer buffer = StringBuffer('import "../model.dart"')
      ..write(';\n\n')
      ..writeln('class $className implements Model{\n');
    _base(buffer);
    _toJson(buffer);
    _fromJson(buffer);
    buffer.writeln('}');
    await file.writeAsString(buffer.toString());
    await file.create();
    return file;
  }
}
