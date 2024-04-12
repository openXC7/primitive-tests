#!/usr/bin/env python3
#
# This script converts an XLSX file as exported in Vivado's implementation viewer
# from the 'BEL Pins' tab in 'Site Properties' into a site_type_<site>.json
# file in nextpnr-xilinx-meta, see: https://github.com/openXC7/nextpnr-xilinx-meta

from sys import argv
import pandas
from icecream import ic

result = {}

primitive_name = argv[1].split(".")[0]
primitive = result[primitive_name] = {}
bels = primitive["bels"] = {}

def create_bel(bel_name):
    bel = bels[bel_name] = {}
    bel['type'] = primitive_name + "_" + bel_name
    bel['class'] = "BEL" if not bel_name.endswith("INV") else "RBEL"
    belpins = bel['pins'] = {}
    return bel

create_bel(primitive_name)
pips = primitive["pips"] = []
pins = primitive["pins"] = {}

table = pandas.read_excel(argv[1])
for index, row in table.iterrows():
    bel_name = row['BEL']
    is_inv = bel_name.endswith('INV')
    bel = bels.get(bel_name) 
    if bel is None:
        bel = create_bel(bel_name)
    name = row['Name']
    belpins = bel['pins']
    belpin = belpins[name] = {}
    dir = row["Direction"].upper()
    wire = row["Site Wire"]
    belpin['dir'] = dir
    belpin['wire'] = wire

    if bel_name == primitive_name:
        pin = pins.get(name)
        if pin is None:
            pin = pins[name] = {}
        pin['primary'] = name
        pin['wire'] = wire.replace("INV_OUT", "")
        pin['dir'] = dir

    if is_inv and name != "OUT":
        pip = {}
        pip['bel'] = bel_name
        pip['from_pin'] = name
        pip['to_pin'] = "OUT"
        pips.append(pip)

with open(f"site_type_{primitive_name}.json", "w") as write_file:
    import json
    json.dump(result, write_file, indent=2)
