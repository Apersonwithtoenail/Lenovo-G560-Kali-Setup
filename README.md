# Lenovo G560: Dual-Screen Linux Workstation

## Overview
This repository documents the configuration, automation, and troubleshooting required to transform a legacy 2010 Lenovo G560 laptop into a fully functional dual-screen development workstation running Kali Linux (XFCE) with an extended 1080p external display.

## Hardware Specifications
*   **Laptop:** Lenovo G560 (2010)
*   **Processor:** Intel Pentium P6200 (Dual-Core, 2.13 GHz)
*   **Memory:** 3.6 GB DDR3
*   **Graphics:** Intel HD Graphics (Integrated)
*   **Operating System:** Kali Linux (XFCE Desktop)
*   **External Display:** Lloyd Smart TV AF01 (2016) - 1080p via HDMI

## Technical Troubleshooting & Resolutions

### 1. Browser Initialization Failure (GTK Modules)
*   **Issue:** Chromium-based browsers (e.g., Brave Origin) crashed instantly upon launch. Logs indicated a SIGTRAP in the `chrome_crashpad_handler` and missing GTK modules (`colorreload-gtk-module`).
*   **Resolution:** The GTK configuration contained residual module calls from a previous KDE environment. Commented out the invalid `gtk-modules` entry in `~/.config/gtk-3.0/settings.ini`. Migrated user data to a stable browser release as a secondary measure.

### 2. Python Virtual Environment Conflicts
*   **Issue:** GUI applications utilizing Python GTK bindings failed to launch with `ModuleNotFoundError: No module named 'gi'`.
*   **Resolution:** The system was defaulting to an active Python Virtual Environment that lacked system-level GTK libraries. Modified all application launch scripts to explicitly invoke the system Python interpreter (`/usr/bin/python3`), bypassing the venv.

### 3. Terminal Hang on Large Paste (Shell Escaping)
*   **Issue:** Pasting large code blocks (Markdown or Bash) into the terminal resulted in a hang at the `>` continuation prompt.
*   **Resolution:** The shell was interpreting unescaped backticks and quotes as command substitutions, breaking `cat << EOF` heredocs. Switched to using Base64 encoding or Python one-liners (`python3 -c`) with `chr(96)` for safe file generation.

### 4. HDMI Video Signal Failure
*   **Issue:** The external display remained black despite `xrandr` reporting `HDMI-1 connected`.
*   **Resolution:** Diagnostic testing revealed the legacy HDMI cable had functional EDID (data) pins but broken TMDS (video) pins. Replaced the cable to restore the video signal.

### 5. Display Overscan (Scaling Issue)
*   **Issue:** The 1080p output was zoomed in, cropping the desktop environment and taskbar.
*   **Resolution:** The TV was applying default overscan. Changed the television's hardware Aspect Ratio setting from `16:9` to `Just Scan` (Screen Fit).

### 6. X11 Virtual Canvas Limit (BadMatch Error)
*   **Issue:** Forcing a side-by-side display layout via `xrandr` triggered a `BadMatch` error.
*   **Resolution:** The legacy Intel GPU lacked the memory to create a virtual canvas combining a 1366x768 and 1920x1080 display (3286x1080). Used the XFCE Display GUI (`xfce4-display-settings`) to configure the layout, which safely reallocated the X11 canvas.

### 7. HDMI Audio Routing
*   **Issue:** Audio defaulted to the laptop speakers. The `pactl` utility reported no HDMI sinks available.
*   **Resolution:** Added `options snd-hda-intel model=auto` to `/etc/modprobe.d/alsa-base.conf` to force the kernel to detect the legacy HDMI audio chip. Rebooted to apply the module configuration.

---

## Automation Scripts

### 1. `dual-screen.sh`
Automates the extended display configuration and audio routing upon connecting the external monitor.

```bash
#!/bin/bash
# Configure display layout
xrandr --output LVDS-1 --mode 1366x768 --pos 0x0 --output HDMI-1 --mode 1920x1080 --pos 1366x0
sleep 1

# Route audio to HDMI
pactl set-card-profile alsa_card.pci-0000_00_1b.0 output:hdmi-stereo+input:analog-stereo
pactl set-default-sink alsa_output.pci-0000_00_1b.0.hdmi-stereo

for i in $(pactl list short sink-inputs | awk '{print $1}'); do
    pactl move-sink-input $i alsa_output.pci-0000_00_1b.0.hdmi-stereo
done
```

### 2. `toggle-audio.sh`
Instantly toggles the default audio sink between the laptop headphones and the HDMI display without requiring a GUI interface.

```bash
#!/bin/bash
HDMI=\"alsa_output.pci-0000_00_1b.0.hdmi-stereo\"
ANALOG=\"alsa_output.pci-0000_00_1b.0.analog-stereo\"
CARD=\"alsa_card.pci-0000_00_1b.0\"

CURRENT=$(pactl get-default-sink)

if [ \"$CURRENT\" = \"$HDMI\" ]; then
    pactl set-card-profile \"$CARD\" output:analog-stereo+input:analog-stereo
    sleep 0.5
    pactl set-default-sink \"$ANALOG\"
    TARGET=\"$ANALOG\"
else
    pactl set-card-profile \"$CARD\" output:hdmi-stereo+input:analog-stereo
    sleep 0.5
    pactl set-default-sink \"$HDMI\"
    TARGET=\"$HDMI\"
fi

for i in $(pactl list short sink-inputs | awk '{print $1}\x27); do
    pactl move-sink-input \"$i\" \"$TARGET\" 2>/dev/null
done
```

## Performance Metrics
Through the use of the lightweight XFCE desktop environment and specific hardware configurations, the system maintains idle CPU usage around 19% while running multiple applications (browser with active video playback, terminal emulator, and system monitors) on the extended display.

## License
MIT
