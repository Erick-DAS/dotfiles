#!/bin/bash

if xrandr | grep "HDMI-1-0 connected"; then
	xrandr --output HDMI-1-0 --auto --left-of eDP --rate 143.99 --mode 2560x1440
else
	xrandr --output eDP --auto
fi

