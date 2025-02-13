def start():
    import asyncio
    import haumbot.wlan
    import haumbot.led
    import haumbot.routes # To register web routes
    import aiowebserver as web

    asyncio.create_task(wlan.autoconnect())
    asyncio.create_task(web.start())
    asyncio.create_task(led.update_led())

    try:
        asyncio.get_event_loop().run_forever()
    except KeyboardInterrupt:
        web.stop()
