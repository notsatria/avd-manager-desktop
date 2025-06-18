# Android Emulator Manager

![Emulator Manager Screenshot](https://placehold.co/800x450/2d3748/ffffff?text=App+Screenshot)

A simple, fast, and cross-platform UI wrapper for managing your Android SDK emulators. Built with Flutter, it runs on macOS, Windows, and Linux.

---

## Features

* ✅ **List Available Emulators:** Automatically finds all Android Virtual Devices (AVDs) installed on your system.
* ✅ **See Running Emulators:** Instantly view which emulators are currently running.
* ✅ **One-Click Controls:** Start and stop your emulators with simple "Run" and "Stop" buttons.
* ✅ **Cross-Platform:** Works identically on macOS, Windows, and Linux.
* ✅ **Auto-Path Detection:** Intelligently finds your Android SDK path, or lets you specify a custom one.
* ✅ **User-Friendly:** Includes helpful hints, like how to find hidden folders on macOS.

---

## Installation

Download the latest version for your operating system from the [**GitHub Releases**](https://github.com/notsatria/avd-manager-desktop/releases) page.

#### macOS
1.  Download the `emulator_manager.app.zip` file.
2.  Unzip the file.
3.  Drag `Emulator Manager.app` into your `/Applications` folder.
4.  You may need to right-click the app and select "Open" the first time due to macOS Gatekeeper.

#### Windows
1.  Download the `emulator_manager_windows.zip` file.
2.  Unzip the folder to a location of your choice (e.g., `C:\Program Files\EmulatorManager`).
3.  Run `emulator_manager.exe` from within the unzipped folder.

#### Linux
1.  Download the `emulator_manager_linux.tar.gz` file.
2.  Extract the archive: `tar -xvf emulator_manager_linux.tar.gz`
3.  Run the executable from within the extracted folder: `./emulator_manager`

---

## How to Use

1.  **Launch the app.** It will attempt to find your Android SDK automatically.
2.  If the path is incorrect, click the folder icon to **select your Android SDK folder**.
3.  Click **Refresh** to see the lists of available and running emulators.
4.  Click **Run** to start an emulator.
5.  Click **Stop** to kill a running emulator.

---

## Building From Source

If you'd like to build the app yourself, follow these steps:

1.  Ensure you have the [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
2.  Enable desktop support for your platform (e.g., `flutter config --enable-macos-desktop`).
3.  Clone the repository:
    ```bash
    git clone [https://github.com/notsatria/avd-manager-desktop.git](https://github.com/notsatria/avd-manager-desktop)
    cd emulator-manager
    ```
4.  Install dependencies:
    ```bash
    flutter pub get
    ```
5.  Run the app:
    ```bash
    flutter run
    ```

---

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
