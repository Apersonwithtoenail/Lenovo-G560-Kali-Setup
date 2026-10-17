# Lenovo G560 - Kali Linux Dual-Screen Setup

Proof that you do not need a $2,000 MacBook to have a dual-monitor hacker station.
This is my 2010 Lenovo G560 running Kali Linux, extended to a 1080p TV using a custom xrandr script.

## The Hardware
- **Laptop:** Lenovo G560 (Intel P6200, 3.6GB RAM)
- **OS:** Kali Linux (XFCE)
- **Display:** 1366x768 Laptop + 1920x1080 TV (Extended)

## The Problem
When plugging in the TV via HDMI, Linux struggled with the scaling, causing the image to zoom in (Overscan) and the laptop screen to drop its native resolution.

## The Solution
I wrote a quick bash script (dual-screen.sh) that:
1. Forces the laptop to stay at its native 1366x768.
2. Forces the TV to run at 1920x1080 to the right.
3. Automatically routes the PulseAudio sound to the TV speakers.

## Usage
```bash
git clone https://github.com/Apersonwithtoenail/lenovo-g560-kali-setup.git
cd lenovo-g560-kali-setup
./dual-screen.sh
```
