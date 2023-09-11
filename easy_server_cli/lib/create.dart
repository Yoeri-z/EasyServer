import 'dart:io';

void copyFromGit(Directory projectDir) {
  print(projectDir.path);
  // Define the GitHub repository URL
  String repoUrl = 'https://github.com/Yoeri-z/EasyServer.git';
  Directory clonedRepoDir =
      Directory('${Directory.systemTemp.path}/easyTempStore');
  if (clonedRepoDir.existsSync()) {
    clonedRepoDir.deleteSync(recursive: true);
  }
  clonedRepoDir.createSync();
  // Clone the GitHub repository
  ProcessResult cloneResult =
      Process.runSync('git', ['clone', repoUrl, clonedRepoDir.path]);

  if (cloneResult.exitCode == 0) {
    // Define the folders to copy
    List<String> foldersToCopy = ['${clonedRepoDir.path}/templates/'];

    // Copy the specified folders to the current directory
    for (String folder in foldersToCopy) {
      ProcessResult copyResult = Process.runSync(
          'xcopy',
          [
            folder.replaceAll('/', '\\'),
            projectDir.path.replaceAll('/', '\\'),
            '/E',
            '/H',
          ],
          runInShell: true);

      if (copyResult.exitCode != 0) {
        print(
            'Failed to copy folder "$folder".\nExitcode:${copyResult.exitCode}');
        print('Error message:');
        print(copyResult.stderr);
      }
    }
    clonedRepoDir.delete(recursive: true);
  } else {
    print(
        'Failed to clone the repository. Check the repository URL and try again.\n Exitcode: ${cloneResult.exitCode}');
    print('Error message:');
    print(cloneResult.stderr);
  }
}

Future<Directory> reconfigureyaml(
    Directory dirWithYaml, String projectname) async {
  final yamlFile = File('${dirWithYaml.path}/pubspec.yaml');
  final contents = await yamlFile.readAsString();
  final newContents = contents.replaceAll('project_name', projectname);
  await yamlFile.writeAsString(newContents);
  Process.run('dart', ['pub', 'get'], workingDirectory: dirWithYaml.path);
  return dirWithYaml;
}

Future<void> reconfigureDart(
    Directory projectDirectory, String projectname) async {
  final flutterfile =
      File('${projectDirectory.path}/${projectname}_flutter/lib/main.dart');
  final serverfile =
      File('${projectDirectory.path}/${projectname}_server/lib/main.dart');
  final serverbinfile =
      File('${projectDirectory.path}/${projectname}_server/bin/main.dart');
  flutterfile
      .readAsString()
      .then((value) => value.replaceAll('project_name', projectname))
      .then((value) => flutterfile.writeAsString(value));
  serverfile
      .readAsString()
      .then((value) => value.replaceAll('project_name', projectname))
      .then((value) => serverfile.writeAsString(value));
  serverbinfile
      .readAsString()
      .then((value) => value.replaceAll('project_name', projectname))
      .then((value) => serverbinfile.writeAsString(value));
}

void create(String projectname) async {
  final projectDir = Directory(projectname).absolute..createSync();
  copyFromGit(projectDir);
  final defaultpath = '${projectDir.path}/project_name';
  final newpath = '${projectDir.path}/$projectname';

  List<Future> futures = [
    Directory('${defaultpath}_flutter')
        .rename('${newpath}_flutter')
        .then((val) => reconfigureyaml(val, projectname)),
    Directory('${defaultpath}_server')
        .rename('${newpath}_server')
        .then((val) => reconfigureyaml(val, projectname)),
    Directory('${defaultpath}_generated')
        .rename('${newpath}_generated')
        .then((val) => reconfigureyaml(val, projectname))
  ];
  await Future.wait(futures);
  reconfigureDart(projectDir, projectname);
}
