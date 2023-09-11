const endpointsTemplate = '''
import "./src/errors.dart";

class _endpoint_name{ 
	String get path => url_path;
	String get name => model_name;

	Uri uri;
  _endpoint_name(this.uri){
    uri = uri.replace(path: path);
  }


	Future<returnType> Function(params)? _endPoint; 
 
  ///calls the server endpoints, this will make a http/https request to the server endpoint that was passed in the Endpoints() constructor
	Future<returnType> call(params) async {
		final map = {
call_map
		}; 

		var response = await http.post(uri,
		body: jsonEncode(map), headers: {"content-type": "application/json"});
		if (response.statusCode == 200) {
			final json = jsonDecode(response.body);
			return json_call_return 
		}
    else{
      throw EasyServerException(statusCode);
    }

	}

	Future<Map<String, dynamic>> _middle(Map<String, dynamic> json) async {
middle_vars

	  final result = await _endPoint!(middle_names);
    middle_mapper
  }

  ///You can use this function to link a functon to an endpoint, the function you pass will be called whenever the server receives a request on this endpoints, the endpoints will receive the paramaters you defined in endpoints.yaml. 
  ///
  ///Allowed parameters as of now are: String, double, int, bool and Lists and Maps with any of these basic types. You can also pass any of the generated models from models.yaml
  ///Right now it is not yet possible to pass a List or Map that contains generated models.
  ///You can do this yourself by manually calling to and from map on the models and incorperate them like you want to.
	set setEndpoint(Future<returnType> Function(params) function){
		_endPoint = function;
		Endpoints.connections[path] = (Map<String, dynamic> json) => _middle(json);
	} 
}
''';
