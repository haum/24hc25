from machine import Pin
from neopixel import NeoPixel

import asyncio

pin = Pin(0, Pin.OUT)   # set GPIO0 to output to drive NeoPixels
np = NeoPixel(pin, 1)   # create NeoPixel driver on GPIO0 for 1 pixels

np[0] = (0, 0, 0)
np.write()         
new_color = asyncio.Event()

async def update_led():
    while True:
        # wait for the event to be set
        await new_color.wait()
        # print(np[0])
        np.write()
        new_color.clear()



