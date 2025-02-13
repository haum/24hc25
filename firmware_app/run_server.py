import server
import asyncio
import led
import web

app = web.App(host='0.0.0.0', port=80)


async def main():
    # Create tasks
    asyncio.create_task(app.serve())
    asyncio.create_task(led.update_led())

server.init(app)

loop = asyncio.get_event_loop()
loop.create_task(main())
loop.run_forever()
