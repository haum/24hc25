def start():
    import haumbot.wlan
    try:
        import aiowebserver as web
    except ImportError:
        try:
            haumbot.wlan.first_connect()
        except ValueError:
            print(f'No known network in file wifi.dat')
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
    import haumbot.position
    import haumbot.rangefinder
    import haumbot.routes # To register web routes

    asyncio.create_task(wlan.autoconnect())
    asyncio.create_task(web.start())
    asyncio.create_task(led.update_led())
    asyncio.create_task(rangefinder.run())
    asyncio.create_task(check_stdin())
    position.start_measure()

    try:
        asyncio.get_event_loop().run_forever()
    except KeyboardInterrupt:
        web.stop()

async def check_stdin():
    import asyncio, select, sys
    import haumbot.wlan
    while True:
        w = False
        while select.select([sys.stdin], [], [], 0)[0]:
            _ = sys.stdin.read(1)
            w = True
        if w:
            print('\nOh le petit malin !')
            if haumbot.wlan.wlan.isconnected():
                ip = haumbot.wlan.wlan.ifconfig()[0]
                print(f"C'est ça que tu cherches : http://{ip}/ ?")
            else:
                print("Le robot n'est pas connecté.")
        await asyncio.sleep_ms(200)
