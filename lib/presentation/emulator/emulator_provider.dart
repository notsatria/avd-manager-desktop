// --- EmulatorProvider ---
// This class holds all the application's state and business logic.
import 'dart:io';

import 'package:avd_manager/utils/preference.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class EmulatorProvider extends ChangeNotifier {
  List<String> _availableAVDs = [];
  List<String> get availableAVDs => _availableAVDs;

  List<String> _runningEmulators = [];
  List<String> get runningEmulators => _runningEmulators;

  String _statusMessage = "Welcome! Click 'Refresh' to find emulators.";
  String get statusMessage => _statusMessage;
  set statusMessage(String message) {
    _statusMessage = message;
    notifyListeners();
  }

  final TextEditingController sdkPathController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Constructor: Load the SDK path as soon as the provider is created.
  EmulatorProvider() {
    _loadSdkPath();
  }

  /// Loads the SDK path from shared preferences and updates the text field.
  Future<void> _loadSdkPath() async {
    final sdkPath = await Preference.loadSdkPath(_getDefaultSdkPath());
    sdkPathController.text = sdkPath;
    notifyListeners();
    refreshAll();
  }

  /// Get default sdk path by each platform
  String _getDefaultSdkPath() {
    if (Platform.isMacOS) {
      return '${Platform.environment['HOME']}/Library/Android/sdk';
    } else if (Platform.isWindows) {
      return '${Platform.environment['LOCALAPPDATA']}\\Android\\Sdk';
    } else if (Platform.isLinux) {
      return '${Platform.environment['HOME']}/Android/sdk';
    }
    return '';
  }

  /// Call the file picker library and save the selected directory
  Future<void> pickSdkPath() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      await Preference.saveSdkPath(selectedDirectory);
      sdkPathController.text = selectedDirectory;
      _statusMessage = "SDK path updated. Refreshing lists...";
      notifyListeners();
      refreshAll();
    } else {
      _statusMessage = "Folder selection canceled.";
      notifyListeners();
    }
  }

  /// Run command in terminal
  Future<ProcessResult> runCommand(
    String executable,
    List<String> arguments,
  ) async {
    return await Process.run(executable, arguments, runInShell: true);
  }

  /// Run comman asynchronously
  Future<void> runCommandAsync(
    String executable,
    List<String> arguments,
  ) async {
    try {
      await Process.start(executable, arguments, runInShell: true);
    } catch (e) {
      _statusMessage = "Failed to launch process: $e";
      notifyListeners();
    }
  }

  /// Refresh all states
  Future<void> refreshAll() async {
    if (sdkPathController.text.isEmpty) {
      _statusMessage = "Please select your Android SDK path.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _statusMessage = "Searching for emulators...";
    notifyListeners();

    await _fetchAvailableAVDs();
    await _fetchRunningEmulators();

    _isLoading = false;
    final status =
        "Found ${_availableAVDs.length} available and ${_runningEmulators.length} running emulators.";
    if (!_statusMessage.startsWith("Error")) {
      _statusMessage = status;
    }
    notifyListeners();
  }

  /// Run commands to fetch for available AVDs
  Future<void> _fetchAvailableAVDs() async {
    final sdkPath = sdkPathController.text;
    final emulatorPath =
        '$sdkPath${Platform.pathSeparator}emulator${Platform.pathSeparator}emulator';
    final result = await runCommand(emulatorPath, ['-list-avds']);

    if (result.exitCode == 0) {
      _availableAVDs =
          (result.stdout as String)
              .split('\n')
              .where((line) => line.isNotEmpty)
              .toList();
    } else {
      _statusMessage = "Error finding emulators. Is the SDK path correct?";
      _availableAVDs = [];
    }
    notifyListeners();
  }

  /// Run comman to fetch running emulators
  Future<void> _fetchRunningEmulators() async {
    final sdkPath = sdkPathController.text;
    final adbPath =
        '$sdkPath${Platform.pathSeparator}platform-tools${Platform.pathSeparator}adb';
    final result = await runCommand(adbPath, ['devices']);

    if (result.exitCode == 0) {
      _runningEmulators =
          (result.stdout as String)
              .split('\n')
              .where((line) => line.startsWith('emulator-'))
              .map((line) => line.split(RegExp(r'\\s+')).first)
              .toList();
    } else {
      _statusMessage = "Error finding running devices via ADB.";
      _runningEmulators = [];
    }
    notifyListeners();
  }

  /// Run command to start AVD
  Future<void> runAVD(String avdName) async {
    _statusMessage = "Starting emulator: $avdName...";
    notifyListeners();

    final sdkPath = sdkPathController.text;
    final emulatorPath =
        '$sdkPath${Platform.pathSeparator}emulator${Platform.pathSeparator}emulator';
    await runCommandAsync(emulatorPath, ['-avd', avdName]);

    _statusMessage =
        "Start command sent for $avdName. It may take a moment to launch.";
    notifyListeners();

    Future.delayed(const Duration(seconds: 8), refreshAll);
  }

  /// Run command to stop emulator
  Future<void> stopEmulator(String emulatorId) async {
    _statusMessage = "Stopping emulator: $emulatorId...";
    notifyListeners();

    final sdkPath = sdkPathController.text;
    final adbPath =
        '$sdkPath${Platform.pathSeparator}platform-tools${Platform.pathSeparator}adb';
    await runCommand(adbPath, ['-s', emulatorId, 'emu', 'kill']);

    _statusMessage = "Stop command sent to $emulatorId.";
    notifyListeners();

    Future.delayed(const Duration(seconds: 2), refreshAll);
  }
}
