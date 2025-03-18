#!/bin/sh
esptool.py --port /dev/ttyACM0 erase_flash
esptool.py --port /dev/ttyACM0 --baud 460800 write_flash 0 /tmp/ESP32_GENERIC_C3-20241129-v1.24.1.bin
rshell -p /dev/ttyACM0 rsync ./firmware_app /pyboard 
