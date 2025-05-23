#!/usr/bin/env bash

# Generate 256-bit INIT Pattern

RAND256_HEX=""
RAND32_HEX_LIST=()

for i in {0..7}; do
    RAND32_HEX=$(printf "%08X" $((RANDOM << 16 | RANDOM)))
    RAND32_HEX_LIST+=("0x${RAND32_HEX}")
    RAND256_HEX="${RAND32_HEX}${RAND256_HEX}"
done

echo "// generated by generate_init.sh" > lutram_init.vh
echo "\`define LUTRAM_INIT 256'h$RAND256_HEX" >> lutram_init.vh
echo "# generated by generate_init.sh" > init.cfg
echo "# INIT split into list of 32-bit values starting with INIT[31:0]" >> init.cfg
echo "set lutram_init_list [list ${RAND32_HEX_LIST[*]}]" >> init.cfg
