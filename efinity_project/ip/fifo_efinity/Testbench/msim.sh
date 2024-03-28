#!/bin/sh

if [ -d work ]; then
	rm -rf work
fi

if [ -f transcript ]; then
	rm transcript
fi

if [ -f vsim.wlf ]; then
	rm vsim.wlf
fi

vsim -do tcl.do
