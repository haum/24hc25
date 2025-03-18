#!/bin/sh

rshell -p /dev/ttyACM0 rsync ../firmware_app /pyboard
