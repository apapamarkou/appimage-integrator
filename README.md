# Appimage Integrator

Appimage Integrator provides a simple and intuitive way to manage your AppImage applications, similar to how applications are integrated on macOS. With this tool, you can easily add or remove AppImage applications from your system's application menus and launchers.

![Peek 2024-09-15 22-08](https://github.com/user-attachments/assets/b8b1ce47-7f40-450d-bac4-73024ea5ae7c)

## Features

- **Automatic Integration**: Drag and drop an AppImage file into your Applications folder, and it will be automatically integrated into your application menus and launchers with their original application name, icon, desciption and type.
- **Automatic Removal**: Drag out or delete an AppImage file from your Applications folder, and it will automatically disappear from your application menus and launchers.

## How It Works

Appimage Integrator is a lightweight, user-scoped autostart service that runs in the background. It continuously monitors the Applications folder for any changes. When an AppImage is added or removed, the service takes action, ensuring your application menus and launchers are always up-to-date.

No more manual editing of `.desktop` files or searching for icons. Appimage Integrator handles everything for you!

## Before installation

### Install the dependencies

   To install and operate you need `inotify-tools`, `git` and `wget`:
   
   - **Debian** based distros
     ```
     sudo apt install inotify-tools git wget
     ```
   - **Fedora**/**RedHat** based distros
     ```
     sudo dnf install inotify-tools git wget
     ```
   - **Arch** based distros
     ```
     sudo pacman -S --needed inotify-tools git wget
     ```
   - **Solus**
     ```
     sudo eopkg install inotify-tools git wget
     ```
     
## Installation
   Copy the following command, paste it in a terminal and hit [ENTER]. Thats it!

   ```bash
   wget -qO- https://raw.githubusercontent.com/apapamarkou/appimage-integrator/main/src/appimage-integrator-install-git | bash
   ```

## Uninstallation
   Copy the following command, paste it in a terminal and hit [ENTER]. Thats it!
   ```bash
   wget -qO- https://raw.githubusercontent.com/apapamarkou/appimage-integrator/main/src/appimage-integrator-uninstall-git | bash
   ```

## Usage

Once installed, Appimage Integrator will automatically start and run in the background. You do not need to manually start or stop the service; it will handle the integration of AppImages into your application menus and launchers automatically.

## Have Fun!

Enjoy the seamless integration of your AppImage applications! If you encounter any issues or have suggestions for improvements, feel free to open an issue or contribute to the project.

## A More "Technical" Description

This project consists of a set of Bash scripts, with the main script serving as an observer that leverages `inotifywait` to monitor changes in the `~/Appimages` directory. When a new AppImage file appears in the `~/Applications` folder, the observer triggers the integration script. This script extracts relevant contents from the AppImage, such as the icon and `.desktop` file, copying them to the appropriate locations: icons are moved to `~/Applications/.icons`, and the `.desktop` file is placed in `~/.local/share/applications`.

If an AppImage is removed from the `~/Applications` directory, the observer calls a cleanup script, which deletes the corresponding icon and `.desktop` file.

During installation, the scripts are copied to `~/.local/bin`, a '.desktop' file is placed in '~/.config/autostart' and the observer service is started to begin integration immediately. The uninstaller removes the scripts from `~/.local/bin`, removes the autostart '.desktop' file and stops the observer service.

All file operations are contained within the user's `$HOME` directory, and no `sudo` privileges are required. The observer runs with single-threaded protection.

## License

This project is licensed under the GNU License.

---

Happy integrating!
