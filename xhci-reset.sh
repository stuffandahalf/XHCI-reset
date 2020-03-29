#!/bin/sh

# This script resets any XHCI busses that may have died during runtime.
# This script is released into the public domain.
# Written by Gregory Norton <Gregory.Norton@me.com> March 28, 2020

#export DEVICE="0000:12:00.3"

DEVICE=$(dmesg | grep "xhci_hcd" | grep "HC died" | cut -d" " -f4 | sed 's/.$//' | cat)
#DEVICES=$(cat ~/test.txt | grep "xhci_hcd" | grep "HC died" | cut -d" " -f4 | sed 's/.$//' | cat)
#echo $DEVICES

QUIT=false
for D in $DEVICES; do
	VALID_INPUT=false
	while [ $VALID_INPUT != true ]; do
		read -p "Reset $D ? [ynq] " RESET
		echo $RESET
		if [[ $RESET == [ynq] ]]; then
			VALID_INPUT=true
		fi
		echo "\$VALID_INPUT = $VALID_INPUT"

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

