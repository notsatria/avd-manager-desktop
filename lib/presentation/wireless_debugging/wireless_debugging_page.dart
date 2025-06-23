import 'package:avd_manager/presentation/emulator/emulator_provider.dart';
import 'package:avd_manager/presentation/widgets/footer.dart';
import 'package:avd_manager/presentation/wireless_debugging/wireless_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WirelessDebuggingPage extends StatelessWidget {
  const WirelessDebuggingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // This page can now listen to both providers
    final wirelessProvider = context.watch<WirelessProvider>();
    final emulatorProvider = context.watch<EmulatorProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Wireless Debugging')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "How to Connect",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const Text(
              "1. Connect a physical device to your computer via USB.",
            ),
            const Text("2. Click the 'Enable Wireless Mode' button below."),
            const Text(
              "3. On your phone, go to Settings > About Phone > Status to find its IP Address.",
            ),
            const Text(
              "4. Enter the IP Address in the field and click 'Connect'.",
            ),
            const Divider(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.usb_rounded),
                label: const Text("Enable Wireless Mode (via USB)"),
                onPressed:
                    emulatorProvider.isLoading
                        ? null
                        : wirelessProvider.enableWirelessMode,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: wirelessProvider.ipAddressController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Device IP Address',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: IconButton.filled(
                    icon: const Icon(Icons.arrow_forward_rounded),
                    iconSize: 24,
                    onPressed:
                        emulatorProvider.isLoading
                            ? null
                            : wirelessProvider.connectToIp,
                    tooltip: 'Connect',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  foregroundColor:
                      Theme.of(context).colorScheme.onErrorContainer,
                ),
                icon: const Icon(Icons.wifi_off_rounded),
                label: const Text("Disconnect All Wireless Devices"),
                onPressed:
                    emulatorProvider.isLoading
                        ? null
                        : wirelessProvider.disconnectAll,
              ),
            ),
            const Spacer(),
            buildFooter(
              context: context,
              statusMessage: emulatorProvider.statusMessage,
              isLoading: emulatorProvider.isLoading,
              refreshAll: emulatorProvider.refreshAll,
            ),
          ],
        ),
      ),
    );
  }
}
