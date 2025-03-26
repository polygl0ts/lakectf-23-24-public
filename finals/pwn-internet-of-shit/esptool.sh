#!/bin/bash
# argv[1]: serial device, e.g., /dev/ttyACM0
# argv[2]: firmware application file, e.g., ./handout/lakectf-ios-1.bin
# Note: flash the bootloader seperately before with app CRC validation disabled
# so that our byte-patched images actually boot (this is the simplest way to
# ensure consistent offsets)
esptool.py --port $1 --before default_reset --after hard_reset \
    write_flash --flash_size 4MB 0x10000 $2
