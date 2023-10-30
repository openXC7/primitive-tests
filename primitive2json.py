#!/usr/bin/env python3
from sys import argv
import pandas

result = {}

primitive_name = argv[1].split(".")[0]
primitive = result[primitive_name] = {}
bels = primitive["bels"] = {}
bel = bels[primitive_name] = {}
bel['type'] = primitive_name + "_" + primitive_name
bel['class'] = "BEL"
belpins = bel['pins'] = {}
pips = primitive["pips"] = []
pins = primitive["pins"] = {}
print(primitive)

table = pandas.read_excel(argv[1])
for index, row in table.iterrows():
    name = row['Name']
    belpin = belpins[name] = {}
    dir = row["Direction"].upper()
    wire = row["Site Wire"]
    belpin['dir'] = dir
    belpin['wire'] = wire
    pin = pins[name] = {}
    pin['primary'] = name
    pin['wire'] = wire
    pin['dir'] = dir

with open(f"site_type_{primitive_name}.json", "w") as write_file:
    import json
    json.dump(result, write_file, indent=2)