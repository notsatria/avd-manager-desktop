// --- EmulatorProvider ---
// This class holds all the application's state and business logic.
import 'dart:io';

import 'package:avd_manager/models/device.dart';
import 'package:avd_manager/utils/preference.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class EmulatorProvider extends ChangeNotifier {
  List<Device> _runningDevices = [];
  List<Device> get runningDevices => _runningDevices;

  List<String> _availableEmulators = [];
  List<String> get availableEmulators => _availableEmulators;

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
    }
    if (Platform.isWindows) {
      return '${Platform.environment['LOCALAPPDATA']}\\Android\\Sdk';
    }
    if (Platform.isLinux) return '${Platform.environment['HOME']}/Android/sdk';
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

    await _fetchAvailableEmulators();
    await _fetchRunningDevices();

    _isLoading = false;
    _isLoading = false;
    final status =
        "Found ${_availableEmulators.length} emulators and ${_runningDevices.length} running devices.";
    if (!_statusMessage.startsWith("Error")) {
      statusMessage = status;
    } else {
      notifyListeners();
    }
  }

  Future<void> _fetchAvailableEmulators() async {
    final sdkPath = sdkPathController.text;
    final emulatorPath =
        '$sdkPath${Platform.pathSeparator}emulator${Platform.pathSeparator}emulator';
    final result = await runCommand(emulatorPath, ['-list-avds']);

    if (result.exitCode == 0) {
      _availableEmulators =
          (result.stdout as String)
              .split('\n')
              .where((line) => line.isNotEmpty)
              .toList();
    } else {
      _statusMessage = "Error finding emulators. Is the SDK path correct?";
      _availableEmulators = [];
    }
  }

  Future<void> _fetchRunningDevices() async {
    final sdkPath = sdkPathController.text;
    final adbPath =
        '$sdkPath${Platform.pathSeparator}platform-tools${Platform.pathSeparator}adb';
    final result = await runCommand(adbPath, ['devices']);

    if (result.exitCode == 0) {
      _runningDevices =
          (result.stdout as String)
              .split('\n')
              .map((line) => line.trim())
              .where(
                (line) =>
                    line.isNotEmpty && !line.startsWith('List of devices'),
              )
              .map((line) {
                final id = line.split(RegExp(r'\\s+')).first;
                final isWireless = id.contains(':');
                return Device(id: id, isWireless: isWireless);
              })
              .toList();
    } else {
      _statusMessage = "Error finding running devices via ADB.";
      _runningDevices = [];
    }
  }

  Future<void> runEmulator(String avdName) async {
    statusMessage = "Starting emulator: $avdName...";
    final sdkPath = sdkPathController.text;
    final emulatorPath =
        '$sdkPath${Platform.pathSeparator}emulator${Platform.pathSeparator}emulator';
    await runCommandAsync(emulatorPath, ['-avd', avdName]);
    statusMessage =
        "Start command sent for $avdName. It may take a moment to launch.";
    Future.delayed(const Duration(seconds: 8), refreshAll);
  }

  Future<void> stopOrDisconnectDevice(Device device) async {
    final sdkPath = sdkPathController.text;
    final adbPath =
        '$sdkPath${Platform.pathSeparator}platform-tools${Platform.pathSeparator}adb';

    if (device.isWireless) {
      statusMessage = "Disconnecting from ${device.id}...";
      await runCommand(adbPath, ['disconnect', device.id]);
      statusMessage = "Disconnected from ${device.id}.";
    } else {
      statusMessage = "Stopping emulator: ${device.id}...";
      await runCommand(adbPath, ['-s', device.id, 'emu', 'kill']);
      statusMessage = "Stop command sent to ${device.id}.";
    }
    Future.delayed(const Duration(seconds: 2), refreshAll);
  }
}
