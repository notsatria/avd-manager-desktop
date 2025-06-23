import 'dart:io';

import 'package:avd_manager/presentation/emulator/emulator_provider.dart';
import 'package:flutter/material.dart';

class WirelessProvider extends ChangeNotifier {
  final EmulatorProvider _emulatorProvider;
  final TextEditingController ipAddressController = TextEditingController();
  final TextEditingController portController = TextEditingController(text: '5555');

  WirelessProvider(this._emulatorProvider);

  @override
  void dispose() {
    ipAddressController.dispose();
    portController.dispose();
    super.dispose();
  }

  String get _adbPath {
    final sdkPath = _emulatorProvider.sdkPathController.text;
    return '$sdkPath${Platform.pathSeparator}platform-tools${Platform.pathSeparator}adb';
  }

  Future<void> enableWirelessMode() async {
    final port = portController.text.trim();
    if (port.isEmpty) {
        _emulatorProvider.statusMessage = "Port number cannot be empty.";
        return;
    }
    _emulatorProvider.statusMessage = "Attempting to enable wireless mode (tcpip:$port)...";
    final result = await _emulatorProvider.runCommand(_adbPath, ['tcpip', port]);
    if (result.stdout.toString().contains('restarting')) {
      _emulatorProvider.statusMessage = "Wireless mode enabled on port $port. Now connect to your device's IP.";
    } else {
      _emulatorProvider.statusMessage = "Error: Is a device connected via USB?";
    }
  }

  Future<void> connectToIp() async {
    final ip = ipAddressController.text.trim();
    final port = portController.text.trim();
    if (ip.isEmpty) {
      _emulatorProvider.statusMessage = "Please enter an IP address.";
      return;
    }
    if (port.isEmpty) {
      _emulatorProvider.statusMessage = "Please enter a port number.";
      return;
    }
    _emulatorProvider.statusMessage = "Connecting to $ip:$port...";
    await _emulatorProvider.runCommand(_adbPath, ['connect', '$ip:$port']);
    _emulatorProvider.statusMessage = "Connection command sent to $ip:$port.";
    Future.delayed(const Duration(seconds: 2), _emulatorProvider.refreshAll);
  }

  Future<void> disconnectAll() async {
    _emulatorProvider.statusMessage = "Disconnecting all wireless devices...";
    await _emulatorProvider.runCommand(_adbPath, ['disconnect']);
    _emulatorProvider.statusMessage = "Disconnect command sent.";
    Future.delayed(const Duration(seconds: 2), _emulatorProvider.refreshAll);
  }
}