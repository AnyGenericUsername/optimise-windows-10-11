# Windows 10 & 11 Debloat & Privacy Script

This PowerShell script is designed to optimize both Windows 10 and Windows 11 by removing common bloatware, disabling telemetry and advertising, and uninstalling components like Copilot and Cortana.

It is a consolidated script intended to be run once to configure a fresh or existing Windows installation for a cleaner, more private user experience.

**This script is designed to be safe, but it makes significant changes to your system. Please read the disclaimers and instructions carefully before proceeding.**

## ⚠️ Important Disclaimer: Read Before Use

* **Run at Your Own Risk:** This is a powerful script that modifies system settings, changes the registry, and removes core components. While it has been tested, every system configuration is unique.

* **Create a Restore Point:** It is **STRONGLY** recommended that you [create a System Restore Point](https://support.microsoft.com/en-us/windows/create-a-system-restore-point-70b30600-4e9c-4399-b00d-327c54173e3a) before running this script. If you encounter any issues, you can revert your system to its previous state.

* **Script Origin & Review:** This script was initially generated using Google's Gemini. It has since been **reviewed and refined by a competent software engineer.**

* **Testing:** This script has been personally tested and verified on:
    * A **Dell Latitude 16** running **Windows 11**
    * A custom **gaming PC** running **Windows 10**

## 🚀 How to Use

1.  **Create Restore Point:** Go to your Start Menu, type `Create a restore point`, and follow the wizard to create one. **Do not skip this step.**

2.  **Save the Script:** Save the script from our chat to your computer as `Optimize-Windows.ps1` (or your preferred name).

3.  **Run as Administrator:**
    * Right-click on the `.ps1` file.
    * Select "**Run with PowerShell**".
    * The script will request administrator privileges. You must select **"Yes"** for it to work.

4.  **Follow Prompts:** The script will pause and ask you to press `Enter` to begin. Read any output in the terminal.

5.  **Restart:** Once the script has finished (it may take a minute or two, especially during the DISM cleanup), **restart your computer** to apply all changes.

## ✅ What This Script Does

This script is organized into several key sections:

* **1. Disables Copilot:**
    * Sets registry policies to disable Copilot system-wide.
    * Removes the Copilot button from the taskbar.
    * Attempts to uninstall the `Microsoft.Copilot` application package.

* **2. Uninstalls Cortana:**
    * Finds and removes the `Microsoft.549981C3F5F10` (Cortana) package for all users.

* **3. Configures Privacy & Telemetry:**
    * Stops and disables the `DiagTrack` (Connected User Experiences and Telemetry) service.
    * Sets the telemetry level to `0` (Security only).
    * Disables the personalized Advertising ID.
    * Disables "Tailored experiences" (using your data for ads/tips).
    * Disables tips, tricks, and "fun facts" on the lock screen.
    * Disables suggested content in the Settings app.

* **4. Removes AppX Bloatware:**
    * Uninstalls a list of common, non-essential apps.
    * **This script EXCLUDES all Xbox and Game Bar components.**
    * **Apps removed include:** GetHelp, GetStarted, Office Hub, OneNote (AppX), Todos, Phone Link, Maps, SoundRecorder, Groove Music, Zune Video, Weather, Feedback Hub, Spotify, Netflix (stub), TikTok (stub), Mixed Reality Portal, and 3D Viewer.

* **5. Disables Optional Windows Features:**
    * Removes legacy components like XPS Document Writer, XPS Viewer, Internet Explorer 11, and Work Folders.

* **6. Applies UI Tweaks:**
    * Disables the "Recommended" and "Suggested" sections in the Start Menu.
    * Disables ad notifications in File Explorer.

* **7. System Cleanup:**
    * Runs `Dism.exe /online /Cleanup-Image /StartComponentCleanup` to clean up the Windows component store and free up disk space.
