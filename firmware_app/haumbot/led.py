import asyncio
import haumbot.config as conf
from machine import Pin
from neopixel import NeoPixel

np = NeoPixel(Pin(conf.get('pin_led'), Pin.OUT), 1)  # create NeoPixel driver for 1 pixels on pin_led

np[0] = (0, 0, 0)
np.write()
new_color = asyncio.Event()

def get_color():
    return (np[0][1], np[0][0], np[0][2])

def set_color(rgb):
    np[0] = (rgb[1], rgb[0], rgb[2])
    new_color.set()

async def update_led():
    while True:
        await new_color.wait() # wait for the event to be set
        np.write()
        new_color.clear()
