# Lenovo G560 — Kali Linux Dual-Screen Hacker Station

![OS](https://img.shields.io/badge/OS-Kali%20Linux%202026.3-blue)
![WM](https://img.shields.io/badge/WM-XFCE-green)

Proof that you do not need a $2,000 MacBook to have a powerful, dual-monitor development environment. This is a fully functional 1080p extended desktop running on a 14-year-old laptop.

## 💻 The Hardware (The Potato)
*   **Laptop:** Lenovo G560 (Released ~2010)
*   **CPU:** Intel Pentium P6200 (Dual-Core, 2.13 GHz)
*   **RAM:** 3.6 GB DDR3
*   **Laptop Display:** 1366x768 (LVDS-1)
*   **External Display:** Lloyd Smart TV AF01 (2016) - 1920x1080 (HDMI-1)
*   **OS:** Kali Linux 2026.3 (XFCE Desktop)

## 🛠️ The Problems We Faced & How We Fixed Them

### 1. The Wall-Mounted TV & The Dead Cable
**Problem:** The TV was mounted to the wall, making the HDMI ports nearly impossible to reach. Furthermore, the existing HDMI cable (routed from an Airtel Set-Top Box) was "half-dead." The EDID data pins worked (so Linux knew a TV was connected), but the TMDS video pins were broken, resulting in a permanent black screen.
**Fix:** Took the TV off the wall mount. Replaced the old Airtel cable with a fresh, shorter HDMI cable directly to the laptop. Video signal instantly restored.

### 2. The Overscan (Zoomed-In) Nightmare
**Problem:** Even when the display connected, the image was horribly zoomed in, cutting off the taskbar and desktop edges.
**Fix:** This is a TV hardware feature, not a Linux issue. We grabbed the TV remote, went to **Picture Size / Aspect Ratio**, and changed it from `16:9` to **`Just Scan`** (or `Screen Fit`). This disabled the TV internal zoom.

### 3. The Scaling & Resolution Battle
**Problem:** Using xrandr to mirror the screens caused severe blurring. Forcing `1920x1080` on the TV while mirroring caused a `BadMatch` X11 error because the old Intel GPU ran out of virtual canvas memory.
**Fix:** We abandoned Mirror mode completely. We forced the laptop to stay at its native `1366x768` on the left, and the TV to output true `1920x1080` on the right. This uses the GPU much more efficiently and looks crystal clear.

### 4. The Missing Taskbar & Audio
**Problem:** Moving to Extend mode meant the taskbar stayed on the laptop, and audio continued blasting from the laptop speakers instead of the TV.
**Fix:**
*   **Taskbar:** Right-clicked the XFCE panel -> Panel Preferences -> Display -> Changed Output to `HDMI-1`.
*   **Audio:** Wrote a script using `pactl` to automatically detect the HDMI audio sink and route PulseAudio to the TV speakers.

## 🚀 The Performance Flex
Despite running Kali Linux, Brave Browser, YouTube (1080p), and a custom system dashboard (TermFetch), the CPU idles around **19%**. Because Kali (XFCE) is so lightweight, 14-year-old hardware can still multitask flawlessly.

## 📜 The Automation Script (dual-screen.sh)
Because unplugging the HDMI cable resets the display server, this script automates the entire setup process. It forces the resolutions, positions the screens, and routes the audio.

```bash
#!/bin/bash
# Force Laptop to Native 768p (Left) and TV to 1080p (Right)
xrandr --output LVDS-1 --mode 1366x768 --pos 0x0 --output HDMI-1 --mode 1920x1080 --pos 1366x0

sleep 1

# Route Audio to TV
HDMI_SINK=\$(pactl list short sinks | grep "hdmi" | awk '{print \$2}' | head -n 1)
if [ -n "\$HDMI_SINK" ]; then
    pactl set-default-sink "\$HDMI_SINK"
    echo "🔊 Audio switched to TV"
fi
```

## 🛠️ Usage
```bash
git clone https://github.com/Apersonwithtoenail/lenovo-g560-kali-setup.git
cd lenovo-g560-kali-setup
chmod +x dual-screen.sh
./dual-screen.sh
```
