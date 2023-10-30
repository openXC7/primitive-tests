#!/usr/bin/env python3
import serial
ser = serial.Serial('/dev/ttyUSB1', 115207)

while True:
    b = int(ser.read()[0])
    if b == 0:
        print("")
    print(str(b), end=" ")