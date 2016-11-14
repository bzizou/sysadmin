#!/usr/bin/env bash
xrandr --output DP1-2 --auto --left-of eDP1
xrandr --output eDP1 --off
xrandr --output DP1-1 --auto --left-of DP1-2
