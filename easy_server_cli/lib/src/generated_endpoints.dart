import 'package:yaml/yaml.dart';

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
        '\t\tEndpoints.boundedPaths[path] = (Map<String, dynamic> json) => _middle(json);\n');
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
        ? 'class $name{ \n  static final Map<String, Map<String, dynamic> Function(Map<String, dynamic>)>boundedPaths = {}; \n'
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
  factory GeneratedEndpoint(YamlMap yaml) {
    return _SubGeneratedEndpoint(MapEntry('Endpoints', yaml), '');
  }
  void generate(StringBuffer buffer) {}
}
