#!/bin/bash

DUT=fifo_tb.sv

xrun -64bit -sv  -access +RWC +licq ${DUT} -f flist -log xrun.log -timescale 1ns/1ps +define+XRUN


