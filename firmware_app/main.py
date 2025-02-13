from wifi_manager import WifiManager
wm = WifiManager()
wm.connect()
while not wm.is_connected():
    pass

import asyncio
import led
import routes # To register web routes
import aiowebserver as web

asyncio.create_task(web.start())
asyncio.create_task(led.update_led())

try:
    asyncio.get_event_loop().run_forever()
except KeyboardInterrupt:
    web.stop()
