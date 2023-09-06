import 'package:easy_server_cli/create.dart';
import 'package:easy_server_cli/generate.dart';

void main(List<String> arguments) {
  if (arguments.first == 'generate') {
    generate();
  }
  if (arguments.first == 'create') {
    try {
      create(arguments[1]);
    } catch (e) {
      print(e);
      print('Usage: \n \t easyserver create {project_name}');
    }
  } else {
    print('valid arguments:');
    print('easyserver generate');
    print('easyserver create {project_name}');
  }
}
