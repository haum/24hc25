
import network

from wifi_manager import WifiManager
wm = WifiManager()
wm.connect()



while not wm.is_connected():
    pass

import run_server
