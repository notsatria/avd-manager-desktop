// The main page of the application.
import 'dart:io';

import 'package:avd_manager/presentation/emulator/emulator_provider.dart';
import 'package:avd_manager/presentation/widgets/footer.dart';
import 'package:avd_manager/presentation/wireless_debugging/wireless_debugging_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// The main page of the application.
class EmulatorPage extends StatelessWidget {
  const EmulatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmulatorProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AVD Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.wifi_tethering_rounded),
            tooltip: 'Wireless Debugging',
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WirelessDebuggingPage(),
                  ),
                ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSdkPathInput(context, provider),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildEmulatorListCard(context, provider),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: _buildRunningDevicesCard(context, provider),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            buildFooter(
              context: context,
              statusMessage: provider.statusMessage,
              isLoading: provider.isLoading,
              refreshAll: provider.refreshAll,
            ),
          ],
        ),
      ),
    );
  }

  // UI Builder Methods are the same as before...
  Widget _buildSdkPathInput(BuildContext context, EmulatorProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Android SDK Path',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: provider.sdkPathController,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'Enter the full path to your Android SDK',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.folder_open_rounded),
              onPressed: provider.pickSdkPath,
              tooltip: 'Select SDK Folder',
            ),
          ),
        ),
        if (Platform.isMacOS)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            child: Text(
              "Hint: Can't see the 'Library' folder? Press 'Command + Shift + .' to show hidden folders.",
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ),
      ],
    );
  }

  Widget _buildEmulatorListCard(
    BuildContext context,
    EmulatorProvider provider,
  ) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Icon(
                  Icons.phone_android_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  "Available Emulators",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child:
                provider.availableEmulators.isEmpty
                    ? const Center(
                      child: Text(
                        'No emulators found.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      itemCount: provider.availableEmulators.length,
                      itemBuilder: (context, index) {
                        final name = provider.availableEmulators[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.smartphone_rounded,
                            size: 28,
                          ),
                          title: Text(name),
                          trailing: _buildActionButton(
                            label: 'Run',
                            icon: Icons.play_circle_filled_rounded,
                            color: Colors.green,
                            isLoading: provider.isLoading,
                            onPressed: () => provider.runEmulator(name),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildRunningDevicesCard(
    BuildContext context,
    EmulatorProvider provider,
  ) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Icon(
                  Icons.devices_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  "Running Devices",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child:
                provider.runningDevices.isEmpty
                    ? const Center(
                      child: Text(
                        'No devices found.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      itemCount: provider.runningDevices.length,
                      itemBuilder: (context, index) {
                        final device = provider.runningDevices[index];
                        return ListTile(
                          leading: Icon(
                            device.isWireless
                                ? Icons.wifi_rounded
                                : Icons.smartphone_rounded,
                            size: 28,
                          ),
                          title: Text(device.id),
                          trailing: _buildActionButton(
                            label: device.isWireless ? 'Disconnect' : 'Stop',
                            icon:
                                device.isWireless
                                    ? Icons.wifi_off_rounded
                                    : Icons.stop_circle_rounded,
                            color: Colors.red,
                            isLoading: provider.isLoading,
                            onPressed:
                                () => provider.stopOrDisconnectDevice(device),
                          ),
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
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}
