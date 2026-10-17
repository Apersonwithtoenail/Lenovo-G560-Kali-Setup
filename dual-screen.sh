#!/bin/bash
# Sets up Laptop (Left) and TV (Right)
xrandr --output LVDS-1 --mode 1366x768 --pos 0x0 --output HDMI-1 --mode 1920x1080 --pos 1366x0

sleep 1

# Switch Audio to HDMI (TV)
HDMI_SINK=$(pactl list short sinks | grep "hdmi" | awk '{print $2}' | head -n 1)
if [ -n "$HDMI_SINK" ]; then
    pactl set-default-sink "$HDMI_SINK"
    echo "🔊 Audio switched to TV"
fi
