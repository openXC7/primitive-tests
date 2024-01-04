#!/bin/bash
FAMILY=spartan7
PARTS="xc7s50csga324-1"

for PART in $PARTS
do
    for FACTOR in $(seq 6 12)
    do
        mkdir ${PART}_${FACTOR}
        cd ${PART}_${FACTOR}
        sed "s/10\.625/${FACTOR}/g" ../../blinky.v > blinky.v
        sed "s/__PART__/${PART}/g" ../build.tcl > build.tcl
        cp ../../blinky.xdc blinky.xdc
        echo "set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_IBUF]" >> blinky.xdc
        (vivado -mode batch -source build.tcl;
         bit2fasm --db-root /devel/HDL/kintex-reveng/prjxray-db/${FAMILY}/ --part ${PART} blinky.bit > blinky.fasm;
         grep LKTABLE blinky.fasm > lktable.txt
        )&        
        cd ..
    done
done