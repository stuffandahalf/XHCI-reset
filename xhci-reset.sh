#!/bin/sh

# This script resets any XHCI buses that may have died during runtime.
# Based on information from "https://bbs.archlinux.org/viewtopic.php?id=236536"
# This script is released into the public domain.
# Written by Gregory Norton <Gregory.Norton@me.com> March 28, 2020

#DEBUG=false
DEBUG=true

SOURCE=dmesg
#SOURCE="cat ./test.txt"
if $DEBUG; then
	echo "\$SOURCE = $SOURCE"
fi
#DEVICES=$(dmesg | grep "xhci_hcd" | grep "HC died" | cut -d" " -f3,4,5 | sed 's/ /\n/' | sed 's/.$//')
#DEVICES=$(cat ~/test.txt | grep "xhci_hcd" | grep "HC died" | cut -d" " -f4 | sed 's/.$//' | cat)

DEVICES=$($SOURCE | grep "xhci_hcd" | grep "HC died" | cut -d" " -f3,4,5 | sed 's/ /\n/' | grep -o -P "\d{4}:\d+:\d{2}\.\d+")
if $DEBUG; then
	echo "\$DEVICES = $DEVICES"
fi

QUIT=false
for D in `echo $DEVICES | tac`; do
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
			printf "Unbinding device "
			echo -n "$D" | sudo tee /sys/bus/pci/drivers/xhci_hcd/unbind
			echo "" # to give a newline
			sleep 5
			printf "Rebinding device "
			echo -n "$D" | sudo tee /sys/bus/pci/drivers/xhci_hcd/bind
			echo "" # to give a newline
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
