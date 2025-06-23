import 'package:avd_manager/presentation/emulator/emulator_page.dart';
import 'package:avd_manager/presentation/emulator/emulator_provider.dart';
import 'package:avd_manager/presentation/wireless_debugging/wireless_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Provider for core emulator/device list and SDK path logic.
        ChangeNotifierProvider(create: (context) => EmulatorProvider()),
        // Provider for wireless-specific logic. It depends on EmulatorProvider
        // to get the SDK path for running ADB commands.
        ChangeNotifierProxyProvider<EmulatorProvider, WirelessProvider>(
          create:
              (context) => WirelessProvider(context.read<EmulatorProvider>()),
          update:
              (context, emulatorProvider, wirelessProvider) =>
                  WirelessProvider(emulatorProvider),
        ),
      ],
      child: const EmulatorManagerApp(),
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
