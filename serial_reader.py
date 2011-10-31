import serial
import struct

c = serial.Serial('/dev/tty.usbserial-A4008Vcw', 9600, timeout=2)

while 1:
    val = c.read(8)
    if len(val) > 8:
        print struct.unpack("BBBBBBBB", val)
    else:
        for x in val:
            print struct.unpack("B", x)