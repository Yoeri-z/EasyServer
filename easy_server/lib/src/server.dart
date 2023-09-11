import 'dart:async';
import 'dart:convert';
import 'dart:io';

///the easy server object, use this to manage your server, acces endpoints, set up websockets and more
class EasyServer {
  final String _host;
  final int _port;

  bool _initialized = false;

  late final HttpServer _httpServer;

  ///all the paths that are bounded to a function, allows to key a path and execute a function, usually this variable is only used internally
  final Map<String, Future<Map<String, dynamic>> Function(Map<String, dynamic>)>
      connections;

  ///Create an EasyServer, manages httprequests and sends them to the correct endpoints, call [initialize] to start the server
  EasyServer(String host, int port, this.connections)
      : _host = host,
        _port = port;

  ///wether the server has been initialized or not, you can start the initialization by calling [initialize]
  bool get initialized => _initialized;

  ///get the adress that the server is bound to
  String get adress => _host;

  ///get the port that the server is bound to
  int get port => _port;

  ///initialize the server, start listening on the adress and port that were specified in the constructor of the [EasyServer] class
  Future<void> start() async {
    _httpServer = await HttpServer.bind(_host, _port);
    _httpServer.listen((r) => _handleRequest(r));
    _initialized = true;
  }

  ///stop the server, to start it again [start] must be called
  void stop() {
    _httpServer.close();
  }

  void _handleRequest(HttpRequest request) async {
    print(request.method);
    print(request.headers.toString());
    if (request.method == 'OPTIONS') {
      // Respond to preflight request with necessary headers
      _handlePreflightRequest(request);
      return;
    }

    // Set CORS headers to allow requests from localhost
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers
        .add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    request.response.headers.add(
        'Access-Control-Allow-Headers', 'Origin, Content-Type, X-Auth-Token');

    print(request.method);
    if (request.method == 'POST') {
      print(request.headers.value('content-type'));
      final message = await utf8.decodeStream(request);
      print('content: $message');
      final json = jsonDecode(message);
      final result =
          await connections[request.uri.path]!(json as Map<String, dynamic>);
      final body = jsonEncode(result);
      final response = request.response
        ..headers.set('Content-Type', 'application/json')
        ..write(body);
      await response.close();
    }
  }

  Future<void> _handlePreflightRequest(HttpRequest request) async {
    // Respond to preflight request with necessary headers
    request.response.statusCode = HttpStatus.noContent;
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers
        .add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers',
        "Origin, X-Requested-With, Content-Type, Accept");
    request.response.close();
  }
}
