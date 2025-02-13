def start():
    import haumbot.wlan
    try:
        haumbot.wlan.first_connect()
    except ValueError:
        print(f'No known network in file wifi.dat ')
    try:
        import aiowebserver as web
    except ImportError:
        try:
            import mip
            mip.install('github:haum/micropython-aiowebserver')
            import aiowebserver as web
        except OSError:
            print('''
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! Need haum/micropython-aiowebserver library, but unable to download. !!
!! Is the target connected?                                            !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
''')

    import asyncio
    import haumbot.led
    import haumbot.routes # To register web routes

    asyncio.create_task(wlan.autoconnect())
    asyncio.create_task(web.start())
    asyncio.create_task(led.update_led())

    try:
        asyncio.get_event_loop().run_forever()
    except KeyboardInterrupt:
        web.stop()
