// The main page of the application.
import 'dart:io';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- State Properties ---

  // Holds the list of available Android Virtual Devices (AVDs).
  List<String> _availableAVDs = [];

  // Holds the list of currently running emulator instances.
  List<String> _runningEmulators = [];

  // A message to display status or errors to the user.
  String _statusMessage = "Welcome! Click 'Refresh' to find emulators.";

  // Controller for the SDK Path text field.
  late final TextEditingController _sdkPathController;

  bool _isLoading = false;

  // --- Core Logic ---

  @override
  void initState() {
    super.initState();
    // Initialize the SDK path with a platform-specific default.
    _sdkPathController = TextEditingController(text: _getDefaultSdkPath());
    // Immediately refresh the lists when the app starts.
    _refreshAll();
  }

  @override
  void dispose() {
    _sdkPathController.dispose();
    super.dispose();
  }

  /// Returns the default path for the Android SDK based on the operating system.
  String _getDefaultSdkPath() {
    if (Platform.isMacOS) {
      return '${Platform.environment['HOME']}/Library/Android/sdk';
    } else if (Platform.isWindows) {
      return '${Platform.environment['LOCALAPPDATA']}\\Android\\Sdk';
    } else if (Platform.isLinux) {
      return '${Platform.environment['HOME']}/Android/sdk';
    }
    return ''; // Default for other OSes
  }

  /// Executes a shell command and returns the result.
  Future<ProcessResult> _runCommand(String executable, List<String> arguments) async {
    final result = await Process.run(executable, arguments, runInShell: true);
    if (result.exitCode != 0) {
      debugPrint('Error running command: ${result.stderr}');
    }
    return result;
  }
  
  /// Asynchronously executes a command without waiting for it to finish.
  Future<void> _runCommandAsync(String executable, List<String> arguments) async {
    try {
      await Process.start(executable, arguments, runInShell: true);
    } catch (e) {
       setState(() {
         _statusMessage = "Failed to launch process: $e";
       });
    }
  }

  /// Refreshes both available and running emulator lists.
  Future<void> _refreshAll() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Searching for emulators...";
    });

    await _fetchAvailableAVDs();
    await _fetchRunningEmulators();

    setState(() {
      _isLoading = false;
      _statusMessage =
          "Found ${_availableAVDs.length} available and ${_runningEmulators.length} running emulators.";
    });
  }

  /// Fetches the list of all installed AVDs.
  Future<void> _fetchAvailableAVDs() async {
    final sdkPath = _sdkPathController.text;
    if (sdkPath.isEmpty) return;

    final emulatorPath = '$sdkPath${Platform.pathSeparator}emulator${Platform.pathSeparator}emulator';
    final result = await _runCommand(emulatorPath, ['-list-avds']);

    if (result.exitCode == 0) {
      setState(() {
        _availableAVDs = (result.stdout as String)
            .split('\n')
            .where((line) => line.isNotEmpty)
            .toList();
      });
    } else {
      setState(() {
         _statusMessage = "Error finding emulators. Is the SDK path correct?";
         _availableAVDs = [];
      });
    }
  }

  /// Fetches the list of currently running emulators.
  Future<void> _fetchRunningEmulators() async {
    final sdkPath = _sdkPathController.text;
    if (sdkPath.isEmpty) return;

    final adbPath = '$sdkPath${Platform.pathSeparator}platform-tools${Platform.pathSeparator}adb';
    final result = await _runCommand(adbPath, ['devices']);

    if (result.exitCode == 0) {
      setState(() {
        _runningEmulators = (result.stdout as String)
            .split('\n')
            .where((line) => line.startsWith('emulator-'))
            .map((line) => line.split(RegExp(r'\s+')).first)
            .toList();
      });
    } else {
      setState(() {
         _statusMessage = "Error finding running devices via ADB.";
         _runningEmulators = [];
      });
    }
  }
  
  /// Starts a specific AVD.
  Future<void> _runAVD(String avdName) async {
    setState(() => _statusMessage = "Starting emulator: $avdName...");
    final sdkPath = _sdkPathController.text;
    final emulatorPath = '$sdkPath${Platform.pathSeparator}emulator${Platform.pathSeparator}emulator';
    
    await _runCommandAsync(emulatorPath, ['-avd', avdName]);
    
    setState(() => _statusMessage = "Start command sent for $avdName. It may take a moment to launch.");

    // Refresh after a delay to allow the emulator to boot.
    Future.delayed(const Duration(seconds: 8), _refreshAll);
  }

  /// Stops a running emulator instance.
  Future<void> _stopEmulator(String emulatorId) async {
    setState(() => _statusMessage = "Stopping emulator: $emulatorId...");
    final sdkPath = _sdkPathController.text;
    final adbPath = '$sdkPath${Platform.pathSeparator}platform-tools${Platform.pathSeparator}adb';
    
    await _runCommand(adbPath, ['-s', emulatorId, 'emu', 'kill']);
    
    setState(() => _statusMessage = "Stop command sent to $emulatorId.");
    
    // Refresh after a delay to see the updated list.
    Future.delayed(const Duration(seconds: 2), _refreshAll);
  }

  // --- UI Body ---
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            _buildHeader(),
            const SizedBox(height: 20),

            // --- SDK Path Configuration ---
            _buildSdkPathInput(),
            const SizedBox(height: 20),

            // --- Emulator Lists ---
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildEmulatorListCard(
                      title: 'Available Emulators',
                      icon: Icons.phone_android_rounded,
                      emulators: _availableAVDs,
                      actionButtonBuilder: (name) => _buildActionButton(
                        label: 'Run',
                        icon: Icons.play_circle_filled_rounded,
                        color: Colors.green,
                        onPressed: () => _runAVD(name),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildEmulatorListCard(
                      title: 'Running Emulators',
                      icon: Icons.devices_rounded,
                      emulators: _runningEmulators,
                      actionButtonBuilder: (id) => _buildActionButton(
                        label: 'Stop',
                        icon: Icons.stop_circle_rounded,
                        color: Colors.red,
                        onPressed: () => _stopEmulator(id),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // --- Footer ---
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // --- UI Builder Methods ---
  
  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.play_for_work_rounded, size: 40, color: Colors.blue),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Android Emulator Manager',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'A simple wrapper for Android SDK command-line tools.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildSdkPathInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Android SDK Path',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _sdkPathController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter the full path to your Android SDK',
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildEmulatorListCard({
    required String title,
    required IconData icon,
    required List<String> emulators,
    required Widget Function(String) actionButtonBuilder,
  }) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: emulators.isEmpty
                ? const Center(
                    child: Text('No emulators found.',
                        style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: emulators.length,
                    itemBuilder: (context, index) {
                      final name = emulators[index];
                      return ListTile(
                        leading: const Icon(Icons.smartphone_rounded, size: 28),
                        title: Text(name),
                        trailing: actionButtonBuilder(name),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
  
  Widget _buildFooter() {
    return Row(
      children: [
        Expanded(
          child: Text(
            _statusMessage,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        if (_isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        const SizedBox(width: 16),
        FilledButton.icon(
          onPressed: _isLoading ? null : _refreshAll,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Refresh'),
        ),
      ],
    );
  }
}
