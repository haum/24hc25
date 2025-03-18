import webrepl
webrepl.start(32, 'haumbot')

import haumbot
from time import sleep
while True:
    try:
        haumbot.start()
    except:
        pass
    try:
        sleep(0.5)
    except KeyboardInterrupt:
        break
