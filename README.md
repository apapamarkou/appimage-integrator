# Appimage Integrator

Appimage Integrator provides a simple and intuitive way to manage your AppImage applications, similar to how applications are integrated on macOS. With this tool, you can easily add or remove AppImage applications from your system's application menus and launchers.

## Features

- **Automatic Integration**: Drag and drop an AppImage file into your Applications folder, and it will be automatically integrated into your application menus and launchers.
- **Automatic Removal**: Drag out or delete an AppImage file from your Applications folder, and it will automatically disappear from your application menus and launchers.

## How It Works

Appimage Integrator is a lightweight, user-scoped autostart service that runs in the background. It continuously monitors the Applications folder for any changes. When an AppImage is added or removed, the service automatically updates the integration, ensuring your application menus and launchers are always up-to-date.

No more manual editing of `.desktop` files or searching for icons. Appimage Integrator handles everything for you!

## Installation

To install Appimage Integrator, follow these steps:

1. **Install the dependencies**
   - Debian based distros
     ```
     sudo apt install inotify-tools git wget
     ```
     
   - Arch based distros
     ```
     sudo pacman -S inotify-tools git wget
     ```
     
3. **Run the installer:**
   ```bash
   wget -qO- https://raw.githubusercontent.com/apapamarkou/appimage-integrator/main/appimage-integrator-install | bash
   ```

## Uninstallation
    ```bash
    wget -qO- https://raw.githubusercontent.com/apapamarkou/appimage-integrator/main/appimage-integrator-uninstall | bash
    ```

## Usage

Once installed, Appimage Integrator will automatically start and run in the background. You do not need to manually start or stop the service; it will handle the integration of AppImages into your application menus and launchers automatically.

## Have Fun!

Enjoy the seamless integration of your AppImage applications! If you encounter any issues or have suggestions for improvements, feel free to open an issue or contribute to the project.

## License

This project is licensed under the GNU License.

---

Happy integrating!
```
