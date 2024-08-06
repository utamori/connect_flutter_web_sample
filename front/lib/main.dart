import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:front/gen/greet/v1/greet.pb.dart';
import 'package:http/http.dart';

void main() {
  runApp(const MainApp());
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

                    final client = Client();

                    final request = GreetRequest(name: value);

                    final response = await client.post(
                      Uri.http(
                        'localhost:8888',
                        '/greet.v1.GreetService/Greet',
                      ),
                      body: jsonEncode(request.toProto3Json()),
                      headers: {'Content-Type': 'application/json'},
                    );

                    final decodedResponse = GreetResponse()
                      ..mergeFromProto3Json(jsonDecode(response.body));

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                      decodedResponse.greeting,
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
