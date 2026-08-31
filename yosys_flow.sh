!usr/bin/bash

yosys ./synth.ys
sed -i -E 's/\b(wire|reg|input|output|inout)\s+signed\b/\1/g' results/axi_fifo_netlist.v