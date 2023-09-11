import 'package:easy_server/easy_server.dart';
import 'package:project_name_generated/endpoints.dart';
import 'package:project_name_generated/model.dart';

//starts the server
void startServer() async {
  //the url of your server, in case of this demo it is just the localhost
  Uri uri = Uri.parse('http://localhost:8080');
  //these are the endpoints of you server
  final endpoints = Endpoints(uri);
  //we can pass a function to execute to the endpoints like this
  endpoints.notes.getsinglenote.setEndpoint = getSingleNote;
  endpoints.notes.getallnotes.setEndpoint = getAllNotes;
  endpoints.notes.setnote.setEndpoint = setNote;

  //this starts the server, note that you need to set your endpoints
  //before you create the server object otherwise it will not connect up the endpoints
  final server = EasyServer(uri.host, uri.port, Endpoints.connections);
  await server.start();
  print('Server started!');
  print('host: ${uri.host}');
  print('port: ${uri.port}');
}

List<Note> notebook = [];
//our endpoint for getting a note made by the user
Future<Note?> getSingleNote(String title) async {
  for (Note note in notebook) {
    if (note.title == title) {
      return note;
    }
  }
  return null;
}

//our endpoint for getting the title of multiple notes
Future<List<String>> getAllNotes() async {
  return notebook.map((e) => e.title).toList();
}

//our endpoint for saving a note
Future<void> setNote(Note note) async {
  notebook.add(note);
}
