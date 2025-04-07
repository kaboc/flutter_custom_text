import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:custom_text_example/common/device_info.dart';
import 'package:custom_text_example/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DeviceInfo.checkIosSimulator();
  runApp(App());
}

class App extends StatelessWidget {
  final _router = GoRouter(
    routes: $appRoutes,
    navigatorKey: rootNavigatorKey,
    onException: (context, state, router) => router.go('/'),
  );

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
      routerConfig: _router,
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
    );
  }
}
