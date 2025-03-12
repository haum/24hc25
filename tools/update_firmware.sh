#! /bin/bash

rshell --port /dev/ttyACM1 rsync ../firmware_app /haumbot-esp32
