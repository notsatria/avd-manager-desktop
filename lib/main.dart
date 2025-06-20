import 'package:avd_manager/emulator/emulator_page.dart';
import 'package:avd_manager/emulator/emulator_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: ((context) => EmulatorProvider()),
      child: EmulatorManagerApp(),
    ),
  );
}

// Main application widget.
class EmulatorManagerApp extends StatelessWidget {
  const EmulatorManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Android Emulator Manager',
      // The theme is designed to look clean and modern on desktop platforms.
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode:
          ThemeMode.system, // Automatically adapt to system's dark/light mode.
      home: const EmulatorPage(),
      debugShowCheckedModeBanner: false, // Hides the debug banner.
    );
  }
}
