from server import app
import asyncio
import led

async def main():
    # Create tasks 
    asyncio.create_task(app.serve())
    asyncio.create_task(led.update_led())

loop = asyncio.get_event_loop()
loop.create_task(main())
loop.run_forever()
