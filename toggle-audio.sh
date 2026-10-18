#!/bin/bash
HDMI_SINK="alsa_output.pci-0000_00_1b.0.hdmi-stereo"
ANALOG_SINK="alsa_output.pci-0000_00_1b.0.analog-stereo"
CARD="alsa_card.pci-0000_00_1b.0"

CURRENT=$(pactl get-default-sink)
echo "Current default: $CURRENT"

if [ "$CURRENT" = "$HDMI_SINK" ]; then
    echo "Switching to Headphones..."
    pactl set-card-profile "$CARD" output:analog-stereo+input:analog-stereo
    sleep 0.5
    pactl set-default-sink "$ANALOG_SINK"
    TARGET="$ANALOG_SINK"
else
    echo "Switching to TV..."
    pactl set-card-profile "$CARD" output:hdmi-stereo+input:analog-stereo
    sleep 0.5
    pactl set-default-sink "$HDMI_SINK"
    TARGET="$HDMI_SINK"
fi

echo "Moving active streams to $TARGET..."
for i in $(pactl list short sink-inputs | awk '{print $1}'); do
    pactl move-sink-input "$i" "$TARGET"
    echo "-> Moved stream $i to TV"
done

echo "Done!"
