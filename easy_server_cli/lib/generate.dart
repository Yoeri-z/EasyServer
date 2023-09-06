import 'dart:io';

import 'package:yaml/yaml.dart';

import 'package:easy_server_cli/src/generated_model.dart';
import 'package:easy_server_cli/src/generated_endpoints.dart';

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
  File modelFile = File('$pathToFolder/lib/model.dart');
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
  late final List<MapEntry> entryList;
  try {
    entryList = yaml.entries.toList();
  } catch (e) {
    print("Error: $e");
    print("Formatting issue");
    print("Here is the processed version of your yaml");
    print(yaml);
    throw Error();
  }
  //buffer for the import statements at the top of the file
  StringBuffer importBuffer = StringBuffer();

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
  GeneratedEndpoint endpoint = GeneratedEndpoint(yaml);

  StringBuffer fileContents = StringBuffer(
      'import "dart:convert";\n\nimport "package:http/http.dart" as http; \n\nimport "./model.dart"; \n\n\n');
  endpoint.generate(fileContents);
  final generatedFile = File('$pathToFolder/lib/endpoints.dart');
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
