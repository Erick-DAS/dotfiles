#!/bin/bash

if xrandr | grep "HDMI-1-0 connected"; then
  #xrandr --output HDMI-1-0 --auto --right-of eDP --rate 59.94 --mode 3840x2160
  xrandr --output HDMI-1-0 --auto --right-of eDP --rate 59.94 --mode 2560x1440
else
  xrandr --output eDP --auto
fi
