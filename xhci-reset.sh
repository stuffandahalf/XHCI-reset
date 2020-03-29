#!/bin/sh

# This script resets any XHCI buses that may have died during runtime.
# Based on information from "https://bbs.archlinux.org/viewtopic.php?id=236536"
# This script is released into the public domain.
# Written by Gregory Norton <Gregory.Norton@me.com> March 28, 2020

DEBUG=false

DEVICES=$(dmesg | grep "xhci_hcd" | grep "HC died" | cut -d" " -f4 | sed 's/.$//')
#DEVICES=$(cat ~/test.txt | grep "xhci_hcd" | grep "HC died" | cut -d" " -f4 | sed 's/.$//' | cat)
if $DEBUG; then
	echo "\$DEVICES = $DEVICES"
fi

QUIT=false
for D in `echo $DEVICES | rev`; do
#for (( i=${#DEVICES[@]}-1 ; i>=0 ; i-- )); do
#	D=${DEVICES[i]}
	if $DEBUG; then
		echo "\$D = $D"
	fi
	VALID_INPUT=false
	while [ $VALID_INPUT != true ]; do
		read -p "Reset $D ? [ynq] " RESET
		if $DEBUG; then
			echo "\$RESET = $RESET"
		fi
		if [[ $RESET == [ynq] ]]; then
			VALID_INPUT=true
		fi
		if $DEBUG; then
			echo "\$VALID_INPUT = $VALID_INPUT"
		fi

		case $RESET in
		y)
			echo -n "$D" | sudo tee /sys/bus/pci/drivers/xhci_hcd/unbind
			sleep 5
			echo -n "$D" | sudo tee /sys/bus/pci/drivers/xhci_hcd/bind
			;;
		n)
			echo "Skipping device $D"
			;;
		q)
			echo "Quitting"
			QUIT=true
			;;
		*)
			echo "Input must be one of [ynq]"
			;;
		esac
	done
	if $QUIT; then
		break
	fi
done
