# The Legendary Lenovo G560 — Ultimate Hacker Setup & War Log

> *Proof that you do not need a $2,000 MacBook. You just need a 14-year-old laptop, a half-dead HDMI cable, and a lot of patience.*

This repository documents the complete, chaotic journey of turning a **2010 Lenovo G560** into a fully functional dual-screen Kali Linux workstation, including every hardware failure, driver bug, and terminal workaround discovered along the way.

## 💻 The Hardware (The \"Potato\")
*   **Laptop:** Lenovo G560 (Circa 2010)
*   **CPU:** Intel Pentium P6200 (Dual-Core, 2.13 GHz)
*   **RAM:** 3.6 GB DDR3
*   **GPU:** Intel HD Graphics (Integrated)
*   **OS:** Kali Linux (XFCE Desktop)
*   **External Display:** Lloyd Smart TV AF01 (2016) — 1080p
*   **Peripherals:** Airtel Set-Top Box, Earphones

---

## 🛠️ The Troubleshooting War Log (Chronological)

### 1. The Browser War: Brave Origin vs. GTK
*   **Problem:** `brave-origin-nightly` would crash instantly on launch, flashing a window in the taskbar and then dying. The crash log showed a SIGTRAP in `chrome_crashpad_handler`. The TV also had GTK module errors: `Failed to load module \"colorreload-gtk-module\"`.
*   **Cause:** The GTK modules were leftover from a KDE installation. Chromium-based browsers hate missing GTK modules.
*   **Fix:** Commented out the broken `gtk-modules` line in `~/.config/gtk-3.0/settings.ini` and installed regular `brave-browser` as a reliable fallback. Migrated all bookmarks, passwords, and cookies manually via `~/.config/BraveSoftware/`.

### 2. The Python Venv Trap
*   **Problem:** Running apps or scripts suddenly threw `ModuleNotFoundError: No module named 'gi'`. Terminal commands for GTK apps completely broke.
*   **Cause:** An active Python Virtual Environment (`.venv`) was overriding the system Python, which didn't have the GTK bindings installed.
*   **Fix:** Removed the old Bash alias activating the venv. Rewrote app launchers (`install.sh` scripts) to explicitly pin the system Python (`/usr/bin/python3`) so venvs can never break the GUI apps again.

### 3. The Terminal Hang (Backtick & Heredoc Trap)
*   **Problem:** Pasting large blocks of code or markdown into Konsole caused the terminal to freeze at the `>` prompt.
*   **Cause:** Backticks (`), single quotes ('), and apostrophes in the pasted text were being interpreted by Bash as command substitutions, breaking the `cat << EOF` heredoc.
*   **Fix:** Switched to using Base64 encoding for complex strings, or Python one-liners (`python3 -c`) with `chr(96)` to safely generate text files without the shell panicking.

### 4. The Half-Dead HDMI Cable
*   **Problem:** Connected the laptop to the TV, but the screen stayed permanently black. `xrandr` showed `HDMI-1 connected`.
*   **Cause:** The old Airtel HDMI cable had broken TMDS (video) pins, but functional EDID (data) pins. The laptop saw the TV's name and resolution, but the video signal was dying in the cable.
*   **Fix:** Replaced the old Airtel cable with a fresh, short HDMI cable.

### 5. The Overscan (Zoomed) Nightmare
*   **Problem:** The 1080p TV image was horribly zoomed in, cutting off the taskbar and edges.
*   **Cause:** TVs automatically zoom in on HDMI inputs to hide broadcast static (Overscan).
*   **Fix:** Used the TV remote to change the Aspect Ratio from `16:9` to **`Just Scan`** (or `Screen Fit`).

### 6. The X11 BadMatch Error
*   **Problem:** Running `xrandr` to extend the laptop (1366x768) and TV (1080p) side-by-side threw a `BadMatch` error.
*   **Cause:** The 2010 Intel GPU ran out of virtual canvas memory trying to create a 3286x1080 desktop.
*   **Fix:** Used the XFCE Display GUI (`xfce4-display-settings`) to configure the layout, which reallocated the X11 canvas safely.

### 7. The Missing Taskbar & Audio
*   **Problem:** The taskbar stayed on the laptop, and audio kept routing to the laptop speakers even though the TV was connected.
*   **Fix:** 
    *   **Taskbar:** Right-clicked Panel -> Panel Preferences -> Display -> Changed Output to `HDMI-1`.
    *   **Audio:** The 2010 Lenovo refused to activate the HDMI audio chip by default. Added `options snd-hda-intel model=auto` to `/etc/modprobe.d/alsa-base.conf` and rebooted.

---

## 📜 The Automation Scripts

### 1. `dual-screen.sh`
Unplugging the HDMI cable resets the layout. This script forces the laptop to 1366x768, the TV to 1080p, and routes the audio.

```bash
#!/bin/bash
xrandr --output LVDS-1 --mode 1366x768 --pos 0x0 --output HDMI-1 --mode 1920x1080 --pos 1366x0
sleep 1
# Force audio to TV
pactl set-card-profile alsa_card.pci-0000_00_1b.0 output:hdmi-stereo+input:analog-stereo
pactl set-default-sink alsa_output.pci-0000_00_1b.0.hdmi-stereo
for i in $(pactl list short sink-inputs | awk '{print $1}'); do
    pactl move-sink-input $i alsa_output.pci-0000_00_1b.0.hdmi-stereo
done
```

### 2. `toggle-audio.sh` (Aliased to `audio`)
Instead of opening the GUI every time, this script instantly swaps audio between the laptop headphones and the TV.

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

for i in $(pactl list short sink-inputs | awk '{print $1}'); do
    pactl move-sink-input \"$i\" \"$TARGET\" 2>/dev/null
done
```

---

## 🚀 The Performance Flex
Despite running Kali Linux, Brave (with many tabs), YouTube (1080p), and a live wallpaper, the CPU idles around **19%**. Lightweight XFCE is the only reason this 14-year-old hardware survives without melting.
