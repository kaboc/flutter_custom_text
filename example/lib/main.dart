import 'package:flutter/material.dart';

import 'package:custom_text_example/common/router.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CustomText Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        textTheme: const TextTheme(
          bodyText1: TextStyle(fontWeight: FontWeight.normal, height: 1.2),
          bodyText2: TextStyle(fontSize: 18.0, height: 1.5),
        ),
      ),
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
    );
  }
}
