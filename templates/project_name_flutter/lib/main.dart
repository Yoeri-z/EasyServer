import 'package:flutter/material.dart';
import 'package:project_name_generated/endpoints.dart';
import 'package:project_name_generated/model.dart';

//this is a default flutter app to demonstrate the capabilities of easy server,
//try to start up the server that is in your server folder and running this app

//You can get endpoints like this
final endpoints = Endpoints(Uri.parse("http://localhost:8080"));
void main() {
  runApp(const MyApp());
}

//you should be familiar with the widget below if you have used flutter before, if you have not used flutter before
//I recommend you to familiarize yourself with that first only the elements involving easyserver will be documented aswell
//as a few notabilities in the flutter code
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy server Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Easy server demo homepage'),
    );
  }
}

//the homepage
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  //we define a function to store a note on the server
  void setNote(Note note) {
    //this calls the endpoint, the behavior of the endpoints can be specified take a look at the models.yaml and endpoints.yaml file
    //in your _generated folder
    endpoints.notes.setnote.call(note);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: const NoteList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
            context: context,
            builder: (context) {
              var title = "", content = "";
              return Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        decoration: const InputDecoration(label: Text("Title")),
                        onChanged: (value) => title = value,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        decoration:
                            const InputDecoration(label: Text("Content")),
                        onChanged: (value) => content = value,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextButton(
                          onPressed: () {
                            setNote(Note(
                                title: title,
                                content: content,
                                //we store the data in a stringformat that can also be parsed by the DateTime model
                                timestamp: DateTime.now().toIso8601String()));
                            Navigator.pop(context);
                          },
                          child: const Text('set note'))
                    ],
                  ),
                ),
              );
            }),
        tooltip: 'set note',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NoteList extends StatefulWidget {
  const NoteList({
    super.key,
  });

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  //a list of the titles of all the posts
  List<String> posts = [];

  //a function that updates the posts list, note that this is not an efficient implemantation
  //in a large scale application where there are lots of notes you dont want to load all the notes every time,
  //but for this test app it will suffice
  Future<void> refresh() async {
    //call the getallnotes endpoint to get all the notes
    final notes = await endpoints.notes.getallnotes.call();
    //update the posts list
    posts = notes.cast<String>();
    //check if mounted to ensure state is not called when the widget is already disposed
    if (mounted) {
      //set the state to reflect the changes to the posts variable
      setState(() {});
    }
  }

  //call refresh immediately when the widget is mounted
  @override
  void initState() {
    super.initState();
    refresh();
  }

  ///a pop up dialog that shows a Note object
  void showNote(BuildContext context, Note note) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(note.title),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(note.content),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(DateTime.parse(note.timestamp).toExcludeSecondsString())
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('notes:'),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: refresh,
                tooltip: 'refresh',
              )
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: posts.length,
            itemBuilder: (context, index) => ListTile(
              onTap: () async {
                endpoints.notes.getsinglenote
                    //get the note using the string from the notes list
                    .call(posts[index])
                    .then((value) => showNote(context, value!));
              },
              leading: const Icon(Icons.note),
              title: Text(posts[index]),
            ),
          ),
        ),
      ],
    );
  }
}

//an extension to make the code a bite more readable,
//this adds a function to a DateTime objects that allows you to convert it into a nice readable format
extension Readable on DateTime {
  toExcludeSecondsString() {
    return ' $hour:$minute, $day-$month-$year';
  }
}
