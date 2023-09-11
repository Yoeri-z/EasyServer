import 'package:easy_server_cli/src/templates/endpoints.dart';
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
        text == 'bool' ||
        text.startsWith('List') ||
        text.startsWith('Map');
  }

  void _writeParams(StringBuffer buffer) {
    if (params.isNotEmpty) {
      String paramString = '';
      for (String param in params) {
        paramString = '$paramString $param,';
      }
      buffer.write(paramString.substring(0, paramString.length - 1));
    }
  }

  void _writeNames(StringBuffer buffer) {
    for (String param in params) {
      buffer.write('${param.split(' ').last},');
    }
  }

  String _writeMiddle(String classtemplate, StringBuffer buffer) {
    for (String param in params) {
      final split = param.split(' ');
      final type = split.first;
      final name = split.last;
      if (isBasicType(type)) {
        buffer.writeln('\t\tfinal $param = json["$name"];');
      } else {
        buffer.writeln('\t\tfinal $param = $type.fromJson(json["$name"]);');
      }
    }
    classtemplate =
        classtemplate.replaceFirst('middle_vars', buffer.toString());
    buffer.clear();
    _writeNames(buffer);
    classtemplate =
        classtemplate.replaceFirst('middle_names', buffer.toString());
    buffer.clear();
    if (isBasicType(returnType)) {
      classtemplate = classtemplate.replaceFirst(
          'middle_mapper', 'return {"response": result};');
    } else if (returnType == 'void') {
      classtemplate = classtemplate.replaceFirst(
          'middle_mapper', 'return {"response": null};');
    } else {
      classtemplate = classtemplate.replaceFirst(
          'middle_mapper', 'return {"response":result?.toJson()};');
    }
    return classtemplate;
  }

  String _writeCall(String classtemplate, StringBuffer buffer) {
    for (String param in params) {
      final split = param.split(' ');
      final name = split.last;
      if (isBasicType(split.first)) {
        buffer.writeln('\t\t\t"$name": $name,');
      } else {
        buffer.writeln('\t\t\t"$name": $name.toJson(),');
      }
    }
    classtemplate = classtemplate.replaceFirst('call_map', buffer.toString());
    buffer.clear();
    return classtemplate.replaceFirst(
        'json_call_return',
        isBasicType(returnType)
            ? 'json["response"] as $returnType;'
            : (returnType == 'void')
                ? ';'
                : '$returnType.fromJson(json["response"]);');
  }

  @override
  void generate(StringBuffer classbuffer) {
    String classtemplate = endpointsTemplate;
    StringBuffer buffer = StringBuffer();
    classtemplate = classtemplate.replaceFirst('url_path', '"$path"');
    classtemplate = classtemplate.replaceFirst('model_name', '"$_name"');
    _writeParams(buffer);
    classtemplate = classtemplate.replaceAll('params', buffer.toString());
    buffer.clear();
    classtemplate = classtemplate.replaceAll('endpoint_name', _name);
    classtemplate = classtemplate.replaceAll('returnType', returnType);
    classtemplate = _writeCall(classtemplate, buffer);
    buffer.clear();
    classtemplate = _writeMiddle(classtemplate, buffer);
    buffer.clear();
    classbuffer.writeln();
    classbuffer.write(classtemplate);
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
        : 'class _$_name{ \n\tString get name => "$_name";\n');

    buffer.writeln();
    for (GeneratedEndpoint subPoint in subPoints) {
      buffer
          .writeln('\tfinal _${subPoint.name} ${subPoint.name.toLowerCase()};');
    }
    buffer.writeln('\tfinal Uri uri;');
    buffer.write((_name == 'Endpoints')
        ? '\t$_name(this.uri):'
        : '\t_$_name(this.uri):');
    String initializers = '';
    for (GeneratedEndpoint subPoint in subPoints) {
      initializers =
          '$initializers ${subPoint.name.toLowerCase()} = _${subPoint.name}(uri),';
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
