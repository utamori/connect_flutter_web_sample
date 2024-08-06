import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:front/gen/greet/v1/greet.pb.dart';
import 'package:http/http.dart';
import 'package:protobuf/protobuf.dart';

void main() {
  runApp(const MainApp());
}

class MyClient implements RpcClient {
  MyClient();
  final client = Client();

  final port = 8888;
  final host = 'localhost';

  @override
  Future<T> invoke<T extends GeneratedMessage>(
    ClientContext? ctx,
    String serviceName,
    String methodName,
    GeneratedMessage request,
    T emptyResponse,
  ) async {
    final response = await client.post(
      Uri.http(
        '$host:$port',
        '/$serviceName/$methodName',
      ),
      body: jsonEncode(request.toProto3Json()),
      headers: {'Content-Type': 'application/json'},
    );

    return emptyResponse..mergeFromProto3Json(jsonDecode(response.body));
  }
}

/// The auto-generated GreetServiceApi has no package name information, so create your own instead.
class ConnectGreetServiceApi {
  RpcClient _client;
  ConnectGreetServiceApi(this._client);
  String _serviceName = 'greet.v1.GreetService';

  Future<GreetResponse> greet(ClientContext? ctx, GreetRequest request) =>
      _client.invoke<GreetResponse>(
          ctx, _serviceName, 'Greet', request, GreetResponse());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: LayoutBuilder(builder: (context, constraints) {
            return ConstrainedBox(
              constraints:
                  constraints.copyWith(maxWidth: constraints.maxWidth / 2),
              child: TextField(
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter text and Communitcate Connect Server',
                ),
                onSubmitted: (value) async {
                  try {
                    print("onSubmitted");

                    final client = MyClient();

                    final request = GreetRequest(name: value);

                    final stub = ConnectGreetServiceApi(client);

                    final response = await stub.greet(ClientContext(), request);

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                      response.greeting,
                      textAlign: TextAlign.center,
                    )));
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}
