import 'dart:io';

import 'package:avd_manager/presentation/emulator/emulator_provider.dart';
import 'package:flutter/material.dart';

class WirelessProvider extends ChangeNotifier {
  final EmulatorProvider _emulatorProvider;
  final TextEditingController ipAddressController = TextEditingController();

  WirelessProvider(this._emulatorProvider);

  @override
  void dispose() {
    ipAddressController.dispose();
    super.dispose();
  }

  String get _adbPath {
    final sdkPath = _emulatorProvider.sdkPathController.text;
    return '$sdkPath${Platform.pathSeparator}platform-tools${Platform.pathSeparator}adb';
  }

  Future<void> enableWirelessMode() async {
    _emulatorProvider.statusMessage = "Attempting to enable wireless mode (tcpip:5555)...";
    final result = await _emulatorProvider.runCommand(_adbPath, ['tcpip', '5555']);
    if (result.stdout.toString().contains('restarting')) {
      _emulatorProvider.statusMessage = "Wireless mode enabled. Now connect to your device's IP.";
    } else {
      _emulatorProvider.statusMessage = "Error: Is a device connected via USB?";
    }
  }

  Future<void> connectToIp() async {
    final ip = ipAddressController.text.trim();
    if (ip.isEmpty) {
      _emulatorProvider.statusMessage = "Please enter an IP address.";
      return;
    }
    _emulatorProvider.statusMessage = "Connecting to $ip...";
    await _emulatorProvider.runCommand(_adbPath, ['connect', '$ip:5555']);
    _emulatorProvider.statusMessage = "Connection command sent to $ip.";
    Future.delayed(const Duration(seconds: 2), _emulatorProvider.refreshAll);
  }

    Future<void> disconnectAll() async {
    _emulatorProvider.statusMessage = "Disconnecting all wireless devices...";
    await _emulatorProvider.runCommand(_adbPath, ['disconnect']);
    _emulatorProvider.statusMessage = "Disconnect command sent.";
    Future.delayed(const Duration(seconds: 2), _emulatorProvider.refreshAll);
  }
}