import 'package:flutter/material.dart';

import 'package:custom_text_example/utils/router.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CustomText Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blueGrey,
        ).copyWith(primary: Colors.grey.shade800),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontWeight: FontWeight.normal, height: 1.2),
          bodyMedium: TextStyle(fontSize: 18.0, height: 1.5),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blueGrey,
              width: 1.6,
            ),
          ),
        ),
      ),
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
    );
  }
}
