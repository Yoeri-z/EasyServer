// ignore_for_file: library_private_types_in_public_api 
 import "dart:convert";

import "package:http/http.dart" as http; 

import "./model.dart"; 


class Endpoints{ 
  static final Map<String, Future<Map<String, dynamic>> Function(Map<String, dynamic>)>connections = {}; 

	final _Notes notes;
	final Uri uri;
	Endpoints(this.uri): notes = _Notes(uri);
} 
class _Notes{ 
	String get name => "Notes";

	final _GetSingleNote getsinglenote;
	final _getAllNotes getallnotes;
	final _setNote setnote;
	final Uri uri;
	_Notes(this.uri): getsinglenote = _GetSingleNote(uri), getallnotes = _getAllNotes(uri), setnote = _setNote(uri);
} 

class _GetSingleNote{ 
	String get path => "/Endpoints/Notes/GetSingleNote";
	String get name => "GetSingleNote";

	Uri uri;
  _GetSingleNote(this.uri){
    uri = uri.replace(path: path);
  }


	Future<Note?> Function( String title)? _endPoint; 
 
  ///calls the server endpoints, this will make a http/https request to the server endpoint that was passed in the Endpoints() constructor
	Future<Note?> call( String title) async {
		final map = {
			"title": title,

		}; 

		var response = await http.post(uri,
		body: jsonEncode(map), headers: {"content-type": "application/json"});
		if (response.statusCode == 200) {
			final json = jsonDecode(response.body);
			return Note?.fromJson(json["response"]); 
		}
    else{
      throw Error();
    }

	}

	Future<Map<String, dynamic>> _middle(Map<String, dynamic> json) async {
		final String title = json["title"];


	  final result = await _endPoint!(title,);
    return {"response":result?.toJson()};
  }

  ///You can use this function to link a functon to an endpoint, the function you pass will be called whenever the server receives a request on this endpoints, the endpoints will receive the paramaters you defined in endpoints.yaml. 
  ///
  ///Allowed parameters as of now are: String, double, int, bool and Lists and Maps with any of these basic types. You can also pass any of the generated models from models.yaml
  ///Right now it is not yet possible to pass a List or Map that contains generated models.
  ///You can do this yourself by manually calling to and from map on the models and incorperate them like you want to.
	set setEndpoint(Future<Note?> Function( String title) function){
		_endPoint = function;
		Endpoints.connections[path] = (Map<String, dynamic> json) => _middle(json);
	} 
}

class _getAllNotes{ 
	String get path => "/Endpoints/Notes/getAllNotes";
	String get name => "getAllNotes";

	Uri uri;
  _getAllNotes(this.uri){
    uri = uri.replace(path: path);
  }


	Future<List> Function()? _endPoint; 
 
  ///calls the server endpoints, this will make a http/https request to the server endpoint that was passed in the Endpoints() constructor
	Future<List> call() async {
		final map = {

		}; 

		var response = await http.post(uri,
		body: jsonEncode(map), headers: {"content-type": "application/json"});
		if (response.statusCode == 200) {
			final json = jsonDecode(response.body);
			return json["response"] as List; 
		}
    else{
      throw Error();
    }

	}

	Future<Map<String, dynamic>> _middle(Map<String, dynamic> json) async {


	  final result = await _endPoint!();
    return {"response": result};
  }

  ///You can use this function to link a functon to an endpoint, the function you pass will be called whenever the server receives a request on this endpoints, the endpoints will receive the paramaters you defined in endpoints.yaml. 
  ///
  ///Allowed parameters as of now are: String, double, int, bool and Lists and Maps with any of these basic types. You can also pass any of the generated models from models.yaml
  ///Right now it is not yet possible to pass a List or Map that contains generated models.
  ///You can do this yourself by manually calling to and from map on the models and incorperate them like you want to.
	set setEndpoint(Future<List> Function() function){
		_endPoint = function;
		Endpoints.connections[path] = (Map<String, dynamic> json) => _middle(json);
	} 
}

class _setNote{ 
	String get path => "/Endpoints/Notes/setNote";
	String get name => "setNote";

	Uri uri;
  _setNote(this.uri){
    uri = uri.replace(path: path);
  }


	Future<void> Function( Note note)? _endPoint; 
 
  ///calls the server endpoints, this will make a http/https request to the server endpoint that was passed in the Endpoints() constructor
	Future<void> call( Note note) async {
		final map = {
			"note": note.toJson(),

		}; 

		var response = await http.post(uri,
		body: jsonEncode(map), headers: {"content-type": "application/json"});
		if (response.statusCode == 200) {
			final json = jsonDecode(response.body);
			return ; 
		}
    else{
      throw Error();
    }

	}

	Future<Map<String, dynamic>> _middle(Map<String, dynamic> json) async {
		final Note note = Note.fromJson(json["note"]);


	  final result = await _endPoint!(note,);
    return {"response": null};
  }

  ///You can use this function to link a functon to an endpoint, the function you pass will be called whenever the server receives a request on this endpoints, the endpoints will receive the paramaters you defined in endpoints.yaml. 
  ///
  ///Allowed parameters as of now are: String, double, int, bool and Lists and Maps with any of these basic types. You can also pass any of the generated models from models.yaml
  ///Right now it is not yet possible to pass a List or Map that contains generated models.
  ///You can do this yourself by manually calling to and from map on the models and incorperate them like you want to.
	set setEndpoint(Future<void> Function( Note note) function){
		_endPoint = function;
		Endpoints.connections[path] = (Map<String, dynamic> json) => _middle(json);
	} 
}
