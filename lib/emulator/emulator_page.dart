// The main page of the application.
import 'dart:io';

import 'package:avd_manager/emulator/emulator_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// The main page of the application.
class EmulatorPage extends StatelessWidget {
  const EmulatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EmulatorProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),

                _buildSdkPathInput(context, provider),
                const SizedBox(height: 20),

                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildEmulatorListCard(
                          context,
                          title: 'Available Emulators',
                          icon: Icons.phone_android_rounded,
                          emulators: provider.availableAVDs,
                          actionButtonBuilder:
                              (name) => _buildActionButton(
                                context,
                                provider,
                                label: 'Run',
                                icon: Icons.play_circle_filled_rounded,
                                color: Colors.green,
                                onPressed: () => provider.runAVD(name),
                              ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildEmulatorListCard(
                          context,
                          title: 'Running Emulators',
                          icon: Icons.devices_rounded,
                          emulators: provider.runningEmulators,
                          actionButtonBuilder:
                              (id) => _buildActionButton(
                                context,
                                provider,
                                label: 'Stop',
                                icon: Icons.stop_circle_rounded,
                                color: Colors.red,
                                onPressed: () => provider.stopEmulator(id),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // --- Footer ---
                _buildFooter(context, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- UI Builder Methods ---
  Widget _buildHeader(BuildContext context) {
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
        // This hint only shows on macOS.
        if (Platform.isMacOS)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            child: Text(
              "Hint: Can't see the 'Library' folder? Press 'Command + Shift + .' to show hidden folders in the file picker.",
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ),
      ],
    );
  }

  Widget _buildEmulatorListCard(
    BuildContext context, {
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
            child:
                emulators.isEmpty
                    ? const Center(
                      child: Text(
                        'No emulators found.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      itemCount: emulators.length,
                      itemBuilder: (context, index) {
                        final name = emulators[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.smartphone_rounded,
                            size: 28,
                          ),
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

  Widget _buildActionButton(
    BuildContext context,
    EmulatorProvider provider, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: provider.isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, EmulatorProvider provider) {
    return Row(
      children: [
        Expanded(
          child: Text(
            provider.statusMessage,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        if (provider.isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        const SizedBox(width: 16),
        FilledButton.icon(
          onPressed: provider.isLoading ? null : provider.refreshAll,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Refresh'),
        ),
      ],
    );
  }
}
