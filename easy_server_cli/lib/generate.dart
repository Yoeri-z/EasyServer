import 'dart:io';

import 'package:easy_server_cli/src/templates/model_abstract.dart';
import 'package:yaml/yaml.dart';

import 'package:easy_server_cli/src/generated_model.dart';
import 'package:easy_server_cli/src/generated_endpoints.dart';

late final List<String> modelTypes;

Future<void> generateModels() async {
  final pathToFolder = Directory.current.path.replaceAll('\\', '/');
  // the models in the yaml file
  final yamlFile = File('$pathToFolder/models.yaml');
  //create a new file in case it accidentally got deleted
  if (!await yamlFile.exists()) {
    await yamlFile.create();
    return;
  }

  final YamlMap yaml = loadYaml(await yamlFile.readAsString());
  if (yaml.isEmpty) {
    print('models.yaml is empty');
    return;
  }
  modelTypes = yaml.keys.cast<String>().toList();

  //model file
  File modelFile = File('$pathToFolder/lib/model.dart');
  //"refresh" the file (delete it and generate a new one)
  if (await modelFile.exists()) {
    await modelFile.delete();
  }
  //create  model file
  await modelFile.create();
  //create a stringbuffer to write the filecontents to
  final StringBuffer modelbuffer = StringBuffer();
  //write the abstract class
  modelbuffer.writeln(modelAbstractTemplate);

  //read the input file and process the YamlMap
  late final List<MapEntry> entryList;
  try {
    entryList = yaml.entries.toList();
  } catch (e) {
    print("Error: $e");
    print("Formatting issue occured in your yaml");
    throw Error();
  }

  //for loop to handle every Model in the yaml
  List<GeneratedModel> models = [];
  for (MapEntry mapEntry in entryList) {
    models.add(GeneratedModel(mapEntry, modelbuffer));
  }
  //generate each model
  for (GeneratedModel model in models) {
    model.generate(modelbuffer);
  }
  //write the buffer to the file
  modelFile.writeAsString(modelbuffer.toString());
}

Future<void> generateEndpoints() async {
  //file loading
  //get currectdirectory
  final pathToFolder = Directory.current.path.replaceAll('\\', '/');
  //read the yamlfile
  final yamlFile = File('$pathToFolder/endpoints.yaml');
  //if file is exidentally deleted recreate it
  if (!await yamlFile.exists()) {
    await yamlFile.create();
    return;
  }
  //load the yaml from the file
  final YamlMap yaml = loadYaml(await yamlFile.readAsString());
  //stop if the file is empty
  if (yaml.isEmpty) {
    print('endpoints.yaml is empty');
    return;
  }
  //get the generated file location
  final generatedFile = File('$pathToFolder/lib/endpoints.dart');

  //"refresh" file (delete and recreate it)
  if (await generatedFile.exists()) {
    await generatedFile.delete();
  }
  await generatedFile.create();

  //file writing
  //create the endpoints tree structure
  GeneratedEndpoint endpoint = GeneratedEndpoint(yaml);
  //create the buffer with the required imports
  StringBuffer fileContents = StringBuffer(
      '// ignore_for_file: library_private_types_in_public_api \n import "dart:convert";\n\nimport "package:http/http.dart" as http; \n\nimport "./model.dart"; \n\n\n');
  //generate the tree structure
  endpoint.generate(fileContents);
  //write the generated string to file
  generatedFile.writeAsString(fileContents.toString());
}

void generate() async {
  generateModels();
  generateEndpoints();
}
