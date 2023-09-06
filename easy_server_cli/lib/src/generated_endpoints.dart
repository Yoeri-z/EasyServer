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
        text == 'void' ||
        text == 'bool';
  }

  void _writeParams(StringBuffer buffer) {
    String paramString = '';
    for (String param in params) {
      paramString = '$paramString $param,';
    }
    buffer.write(paramString.substring(0, paramString.length - 1));
  }

  void _writeFunctionType(StringBuffer buffer) {
    buffer.write('\tFuture<$returnType> Function(');
    _writeParams(buffer);
    buffer.write(')?');
  }

  void _writeMiddle(StringBuffer buffer) {
    buffer.writeln(
        '\tFuture<Map<String, dynamic>> _middle(Map<String, dynamic> json) async {');
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
    buffer.write('\t\tfinal result = await _endPoint!(');
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

  void _writeCall(StringBuffer buffer) {
    buffer.writeln();
    buffer.write('\tFuture<$returnType> call(');
    _writeParams(buffer);
    buffer.write(') async {\n');
    buffer.writeln('\t\tfinal map = {');
    for (String param in params) {
      final split = param.split(' ');
      final name = split.last;
      if (isBasicType(returnType)) {
        buffer.writeln('\t\t\t"$name": $name,');
      } else {
        buffer.writeln('\t\t\t"$name": $name.toJson(),');
      }
    }
    buffer.write('\t\t}; \n');
    buffer.writeln('\t\tvar response = await http.post(uri,');
    buffer.writeln(
        '\t\tbody: jsonEncode(map), headers: {"Content-Type": "application/json"});');
    buffer.writeln('\t\tif (response.statusCode == 200) {');
    buffer.writeln('\t\t\tfinal json = jsonDecode(response.body);');
    buffer.writeln(isBasicType(returnType)
        ? '\t\t\treturn json["response"] as $returnType;'
        : '\t\t\treturn $returnType.fromJson(json["response"]);');
    buffer.writeln('\t\t}');
    buffer.writeln('''
    else{
      throw Error();
    }
''');
    buffer.writeln('\t}');
    buffer.writeln();
  }

  @override
  void generate(StringBuffer buffer) {
    buffer.write('class ${_name}Endpoint{ \n');
    buffer.writeln('\tString get path => "$path";');
    buffer.writeln('\tString get name => "$_name";');
    buffer.writeln();
    buffer.writeln('\tUri uri;');
    buffer.writeln('''
  ${_name}Endpoint(this.uri){
    uri = uri.replace(path: path);
  }
''');
    buffer.writeln();
    _writeFunctionType(buffer);
    buffer.write(' _endPoint; \n \n');
    _writeCall(buffer);
    _writeMiddle(buffer);
    buffer.write('\tset setEndpoint(');
    _writeFunctionType(buffer);
    buffer.write(' function){\n');
    buffer.write('\t\t_endPoint = function;\n');
    buffer.write(
        '\t\tEndpoints.connections[path] = (Map<String, dynamic> json) => _middle(json);\n');
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
    buffer.write((_name == 'Endpoints')
        ? 'class $_name{ \n  static final Map<String, Future<Map<String, dynamic>> Function(Map<String, dynamic>)>connections = {}; \n'
        : 'class ${_name}Endpoint{ \n\tString get name => "$_name";\n');

    buffer.writeln();
    for (GeneratedEndpoint subPoint in subPoints) {
      buffer.writeln(
          '\tfinal ${subPoint.name}Endpoint ${subPoint.name.toLowerCase()};');
    }
    buffer.writeln('\tfinal Uri uri;');
    buffer.write((_name == 'Endpoints')
        ? '\t$_name(this.uri):'
        : '\t${_name}Endpoint(this.uri):');
    String initializers = '';
    for (GeneratedEndpoint subPoint in subPoints) {
      initializers =
          '$initializers ${subPoint.name.toLowerCase()} = ${subPoint.name}Endpoint(uri),';
    }
    buffer.write(initializers.substring(0, initializers.length - 1));
    buffer.write(';');
    buffer.writeln();
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
