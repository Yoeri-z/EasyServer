import 'dart:io';

import 'package:yaml/yaml.dart';

///the constant part of the [Model] abstract class
const String kmodel = '''
abstract class Model {
  Model() {
    throw Error();
  }
  factory Model.fromJson(Map<String, dynamic> json) {
    throw Error();
  }
  Map<String, dynamic> toJson();
}
''';
late final List<String> modelTypes;

///the class of a prewritten model
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
        'import "./models/${yamlEntry.key.toString().toLowerCase()}.dart";\n export "./models/${yamlEntry.key.toString().toLowerCase()}.dart";');
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
      print('$i: ${_typeList[i]}');
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
    StringBuffer buffer =
        StringBuffer('import "dart:io";\n\nimport "./model.dart"')
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

class _FinalGeneratedEndPoint implements GeneratedEndpoint {
  final String _name;
  String returnType = 'void';
  final List<String> params = [];
  String path;
  _FinalGeneratedEndPoint(MapEntry endpointMap, this.path)
      : _name = endpointMap.key {
    path = '$path/$_name';
    for (YamlMap param in endpointMap.value as YamlList) {
      if (param.keys.first == 'returnType') {
        returnType = param['returnType'];
      } else {
        params.add('${param.values.first} ${param.keys.first}');
      }
    }
  }
  bool isBasicType(String text) {
    return text == 'String' ||
        text == 'int' ||
        text == 'double' ||
        text == 'bool';
  }

  void _writeParams(StringBuffer buffer) {
    for (String param in params) {
      buffer.write('$param,');
    }
  }

  void _writeFunctionType(StringBuffer buffer) {
    buffer.write('\t$returnType Function(');
    _writeParams(buffer);
    buffer.write(')?');
  }

  void _writeMiddle(StringBuffer buffer) {
    buffer
        .writeln('\tMap<String, dynamic> _middle(Map<String, dynamic> json){');
    for (String param in params) {
      final split = param.split(' ');
      final type = split.first;
      final name = split.last;
      if (!isBasicType(type)) {
        buffer.writeln('\t\tfinal $param = $type.fromJson(json["$name"]);');
      } else {
        buffer.writeln('\t\tfinal $param = json["$name"];');
      }
    }
    buffer.write('\t\tfinal result = _endPoint!(');
    for (String param in params) {
      buffer.write('${param.split(' ').last},');
    }
    buffer.write(');\n');
    buffer.write('''
    late Map<String, dynamic> map;
    if(result is Model){
      map = (result as Model).toJson();
      return {'response':map};
    }else{
      return{'response': result};
    }
  }\n\n
''');
  }

  @override
  void generate(StringBuffer buffer) {
    buffer.write('class ${name}Endpoint{ \n');
    buffer.writeln('\tString get path => "$path";');
    buffer.writeln('\tString get name => "$_name";');
    _writeFunctionType(buffer);
    buffer.write(' _endPoint; \n \n');
    _writeMiddle(buffer);
    buffer.write('\tset setEndpoint(');
    _writeFunctionType(buffer);
    buffer.write(' function){\n');
    buffer.write('\t\t_endPoint = function;\n');
    buffer.write(
        '\t\tEasyServer.boundedPaths[path] = (Map<String, dynamic> json) => _middle(json);\n');
    buffer.write('\t} \n } \n');
  }

  @override
  String get name => _name;
}

class _SubGeneratedEndpoint implements GeneratedEndpoint {
  final List<GeneratedEndpoint> subPoints = [];
  final String _name;
  _SubGeneratedEndpoint(MapEntry endpointMap, String path)
      : _name = endpointMap.key {
    for (MapEntry entry in (endpointMap.value as YamlMap).entries) {
      if (entry.value is YamlList) {
        subPoints.add(_FinalGeneratedEndPoint(entry, '$path/$_name'));
      } else {
        subPoints.add(_SubGeneratedEndpoint(entry, '$path/$_name'));
      }
    }
  }

  @override
  void generate(StringBuffer buffer) {
    buffer.write((name == 'Endpoints')
        ? 'class $name{ \n'
        : 'class ${name}Endpoint{ \n\tString get name => "$_name";\n');
    for (GeneratedEndpoint subPoint in subPoints) {
      buffer.write(
          '\tfinal ${subPoint.name}Endpoint ${subPoint.name.toLowerCase()} = ${subPoint.name}Endpoint(); \n');
    }
    buffer.write('} \n');
    for (GeneratedEndpoint subPoint in subPoints) {
      subPoint.generate(buffer);
    }
  }

  @override
  String get name => _name;
}

abstract class GeneratedEndpoint {
  String get name;
  void generate(StringBuffer buffer) {}
}

Future<void> generateModels() async {
  final pathToFolder = Directory.current.path.replaceAll('\\', '/');
  // the models in the yaml file
  final file = File('$pathToFolder/models.yaml');

  if (!await file.exists()) {
    print('Error: models.yaml does not exist in the script directory.');
    return;
  }
  //directory to be created
  Directory folder = Directory('$pathToFolder/lib/models');
  //model file
  File modelFile = File('$pathToFolder/model.dart');
  //if the directory exists delete it and its contents to 'refresh'
  if (await folder.exists()) {
    await folder.delete(recursive: true);
  }
  //create directory and model file
  await folder.create();
  await modelFile.create();
  //read the input file and process the YamlMap
  List<GeneratedModel> models = [];
  final YamlMap yaml = loadYaml(await file.readAsString());
  modelTypes = yaml.keys.cast<String>().toList();
  print(modelTypes);
  late final List<MapEntry> entryList;
  try {
    entryList = yaml.entries.toList();
  } catch (e) {
    print("Error: $e");
    print("Formatting issue");
    print("Here is the processed version of you yaml");
    print(yaml);
    throw Error();
  }
  //buffer for the import statements at the top of the file
  StringBuffer importBuffer = StringBuffer('import "dart:io";\n');

  //for loop to handle every Model in the yaml
  //TO-DO: Error checking
  for (MapEntry mapEntry in entryList) {
    var generatedModel = GeneratedModel(mapEntry, importBuffer);
    models.add(generatedModel);
  }
  importBuffer.write(kmodel);
  modelFile.writeAsString(importBuffer.toString());
  //make files for each model
  for (GeneratedModel model in models) {
    model.toFile('$pathToFolder/lib/models');
  }
}

Future<void> generateEndpoints() async {
  final pathToFolder = Directory.current.path.replaceAll('\\', '/');

  final file = File('$pathToFolder/endpoints.yaml');

  if (!await file.exists()) {
    print('Error: endpoints.yaml does not exist in the script directory.');
    return;
  }
  final YamlMap yaml = loadYaml(await file.readAsString());
  GeneratedEndpoint endpoint =
      _SubGeneratedEndpoint(MapEntry('Endpoints', yaml), '');

  StringBuffer fileContents = StringBuffer(
      'import "./server.dart";\nimport "../models/model.dart"; \n\n\n');
  endpoint.generate(fileContents);
  final generatedFile = File('$pathToFolder/src/endpoints.dart');
  if (await generatedFile.exists()) {
    await generatedFile.delete();
  }
  await generatedFile.create();
  generatedFile.writeAsString(fileContents.toString());
}

void generate() async {
  generateModels();
  generateEndpoints();
}
