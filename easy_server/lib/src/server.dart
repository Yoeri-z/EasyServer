import 'dart:async';
import 'dart:convert';
import 'dart:io';

///the easy server object, use this to manage your server, acces endpoints, set up websockets and more
class EasyServer {
  final String _adress;
  final int _port;

  ///This is the core of your easyserver, you can connect your functions up to the endpoints defined in endpoints.yaml, [endpoints] is the base of all your endpoints
  ///you can set endpoints like this:
  ///
  ///
  ///  `server.endpoints.example.setEndpoint = (request, params) => myFunc`
  ///
  ///
  ///The function will return what you defined in endpoints.yaml, if you did not specify a returntype it will be void. You can define the parameters in
  ///endpoints.yaml, allowed types are String, double, Int, bool and serializable models that
  ///you defined in models.yaml
  ///
  ///You can also create deeper branches in your endpoints.yaml. They might look like this
  ///
  ///`server.endpoints.example.helloworld.setEndpoint = (request, params) => myFunc`
  ///
  ///You can make endpoints however deep you want, note that an endpoints can only have one function
  ///this might seem complicated but it creates an easier readable structure to your endpoints and allows you to set up the functions in whatever form you want

  bool _initialized = false;

  late final HttpServer _httpServer;

  ///all the paths that are bounded to a function, allows to key a path and execute a function, usually this variable is only used internally
  final Map<String, Future<Map<String, dynamic>> Function(Map<String, dynamic>)>
      connections;

  ///Create an EasyServer, manages httprequests and sends them to the correct endpoints, call [initialize] to start the server
  EasyServer(String adress, int port, this.connections)
      : _adress = adress,
        _port = port;

  ///wether the server has been initialized or not, you can start the initialization by calling [initialize]
  bool get initialized => _initialized;

  ///get the adress that the server is bound to
  String get adress => _adress;

  ///get the port that the server is bound to
  int get port => _port;

  ///initialize the server, start listening on the adress and port that were specified in the constructor of the [EasyServer] class
  Future<void> initialize() async {
    _httpServer = await HttpServer.bind(_adress, _port);
    _httpServer.listen((r) => _handleRequest(r));
    _initialized = true;
  }

  ///stop the server, to start it again [initialize] must be called
  void stop() {
    _httpServer.close();
  }

  void _handleRequest(HttpRequest request) async {
    if (connections[request.uri.path] != null) {
      final json = jsonDecode(await utf8.decodeStream(request));
      final result =
          await connections[request.uri.path]!(json as Map<String, dynamic>);
      final body = jsonEncode(result);
      final response = request.response
        ..headers.contentType = ContentType.json
        ..write(body);
      await response.close();
    }
  }
}
