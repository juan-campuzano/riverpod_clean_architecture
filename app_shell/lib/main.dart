import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mf_example/mf_example.dart';
import 'config/di/app_di.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: AppDI.overrides,
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Host App Shell',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      // Renders the TransferPage from the independent mf_example package
      home: const TransferPage(),
    );
  }
}
