import 'package:flutter/material.dart';

import 'package:custom_text_example/common/device_info.dart';
import 'package:custom_text_example/common/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DeviceInfo.checkIosSimulator();
  runApp(const App());
}

class App extends StatelessWidget {
  const App();

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blueGrey,
    ).copyWith(
      primary: Colors.grey.shade800,
      surfaceTint: Colors.transparent,
    );

    return MaterialApp.router(
      title: 'CustomText Demo',
      theme: ThemeData(
        colorScheme: colorScheme,
        // Workaround for https://github.com/flutter/flutter/issues/129553.
        typography: Typography.material2018(),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 18.0, height: 1.5),
          bodySmall: TextStyle(fontSize: 14.0, height: 1.2),
        ),
        appBarTheme: AppBarTheme(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
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
