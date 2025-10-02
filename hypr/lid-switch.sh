#!/bin/bash

# Check if any external monitors are connected
if hyprctl monitors | grep -q "DP-1"; then
  # If an external monitor is connected, disable the laptop's internal screen
  hyprctl keyword monitor "eDP-1, disable"
else
  # If no external monitor is connected, lock the screen and suspend the system
  # using hypridle
  hyprctl dispatch dpms off
fi
