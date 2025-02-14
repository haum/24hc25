import json
import network
import asyncio
import time
from machine import Pin

LED_builtin = Pin(8, Pin.OUT)

wlan = network.WLAN(network.STA_IF)
networks = []
mac = wlan.config('mac')
hostname = 'haumbot-' + ''.join('{:02x}'.format(b) for b in mac[3:])
try:
    with open('wifi.dat', 'r') as f:
        for line in f:
            networks.append(line.strip().split(';', 1))
except OSError:
    pass

def print_wlaninfo():
    if wlan.isconnected():
        c = wlan.ifconfig()
        print("Connected\nIP:", c[0])
        print("Mask:", c[1])
        print("Gateway:", c[2])
        print("DNS:", c[3])
        print("Hostname:", wlan.config('hostname'))
        print(f"RSSI: {wlan.status('rssi')} dB")
    else:
        print("Not connected")

def first_connect():
        if not wlan.active():
            wlan.active(True)
        if wlan.status() != network.STAT_IDLE:
            wlan.disconnect()
        if hostname:
            wlan.config(hostname=hostname)
        nets = wlan.scan()
        ssids = tuple(net[0] for net in nets)
        for n in networks:
            s = n[0].encode()
            if s in ssids:
                print(f'Found network "{s}", try connecting')
                wlan.connect(*n)
                while not wlan.isconnected():
                    print('.', end='')
                    LED_builtin.value(not LED_builtin.value())
                    time.sleep_ms(100)
                print('\n\r')
                LED_builtin.off() # LED_builtin on
                print_wlaninfo()
                break
        else:
            print(f'No known network in {ssids}')
            raise ValueError

async def connect(ssid, passwd):
    wlan.connect(ssid, passwd)
    while True:
        status = wlan.status()
        if status == network.STAT_CONNECTING or status == network.STAT_IDLE:
            await asyncio.sleep_ms(10)
        else:
            break

    if status == network.STAT_ASSOC_FAIL:
        print('Wifi: ASSOC_FAIL')
    elif status == network.STAT_BEACON_TIMEOUT:
        print('Wifi: BEACON_TIMEOUT')
    elif status == network.STAT_GOT_IP:
        print('Wifi: GOT_IP')
    elif status == network.STAT_HANDSHAKE_TIMEOUT:
        print('Wifi: HANDSHAKE_TIMEOUT')
    elif status == network.STAT_NO_AP_FOUND:
        print('Wifi: NO_AP_FOUND')
    elif status == network.STAT_WRONG_PASSWORD:
        print('Wifi: WRONG_PASSWORD')

    print_wlaninfo()


async def autoconnect():
    if wlan.isconnected():
        print_wlaninfo()

    while True:
        if wlan.isconnected():
            await asyncio.sleep(5)
            continue
        if not wlan.active():
            wlan.active(True)
        if wlan.status() != network.STAT_IDLE:
            wlan.disconnect()
        if hostname:
            wlan.config(hostname=hostname)
        nets = wlan.scan()
        ssids = tuple(net[0] for net in nets)

        for n in networks:
            s = n[0].encode()
            if s in ssids:
                print(f'Found network "{s}", try connecting')
                await connect(*n)
                break
        else:
            print(f'No known network in {ssids}')
        await asyncio.sleep(5)
