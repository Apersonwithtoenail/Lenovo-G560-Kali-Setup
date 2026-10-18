# The Legendary Lenovo G560 - Dual-Screen Hacker Station

Proof that you do not need a 2000 dollar MacBook to build a dual-monitor workstation.

This repo documents the complete, chaotic journey of setting up a 1080p extended display on a 2010 Lenovo G560 running Kali Linux (XFCE).

## Hardware
- **Laptop:** Lenovo G560 (Circa 2010)
- **CPU:** Intel Pentium P6200 (Dual-Core, 2.13 GHz)
- **RAM:** 3.6 GB DDR3
- **OS:** Kali Linux 2026.3 (XFCE Desktop)
- **TV:** Lloyd Smart TV AF01 (2016) - 1080p

## The Problems & Fixes
1. **The Wall Mount & Dead Cable:** The old Airtel HDMI cable had broken video pins but working data pins. Fixed by swapping to a new cable.
2. **The Overscan:** The TV zoomed in. Fixed by setting the TV remote Aspect Ratio to Just Scan.
3. **The BadMatch Error:** Forcing xrandr threw an error due to GPU limits. Fixed by using the XFCE Display GUI.
4. **Missing Taskbar & Audio:** Taskbar stayed on laptop. Fixed by moving it in Panel Preferences. Audio stayed on laptop. Fixed via pactl.

## The Automation Script (dual-screen.sh)
Here is the script that runs on every boot:
```bash
#!/bin/bash
xrandr --output LVDS-1 --mode 1366x768 --pos 0x0 --output HDMI-1 --mode 1920x1080 --pos 1366x0
sleep 1
HDMI_SINK=$(pactl list short sinks | grep hdmi | awk '{print $2}' | head -n 1)
if [ -n "$HDMI_SINK" ]; then
    pactl set-default-sink "$HDMI_SINK"
fi
```


### 5. The Audio Routing Battle
**Problem:** The 2010 Lenovo G560 refused to wake up the HDMI audio chip. PipeWire only saw the laptop speakers, and forcing it via terminal caused a BadMatch error.
**Fix:** Added `options snd-hda-intel model=auto` to `/etc/modprobe.d/alsa-base.conf` and rebooted to force the kernel to detect the HDMI audio pins.

We also wrote `toggle-audio.sh` to instantly swap audio between your laptop headphones and the TV speakers.

## 🎧 Audio Toggle Script
When a video is playing, run this to instantly jump the audio between your laptop headphones and the TV speakers:

```bash
./toggle-audio.sh
```

## Usage
```bash
git clone https://github.com/Apersonwithtoenail/lenovo-g560-kali-setup.git
cd lenovo-g560-kali-setup
chmod +x dual-screen.sh
./dual-screen.sh
```
