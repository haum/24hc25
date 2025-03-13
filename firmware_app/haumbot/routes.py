import asyncio
import json
import struct
import haumbot.led as led
import haumbot.motors as motors
import haumbot.position as position
import aiowebserver as web
from math import pi

@web.route('GET', '/')
async def root_handler(rq):
    await rq.sendfile('haumbot/static/root_index.htm')


@web.route('GET', '/static/', True)
async def root_handler(rq):
    await rq.sendfile(rq.path[8:], 'haumbot/static/')


# curl -X POST -H 'Content-Type: application/json' --data '{"LED": {"r": 64, "g": 0, "b": 0}}' http://ip_esp/led/set_color
# curl -X POST --data 'ledcolor=#cc0080' http://ip_esp/led/set_color
@web.route('POST', '/led/set_color')
async def led_post_handler(rq):
    if rq.is_postform():
        form = await rq.decode_postform_data()
        color = form.get('ledcolor')
        if not color:
            await rq.return_status(400)
            await rq.w('Need ledcolor')
            return
        try:
            if len(color) != 7: raise ValueError
            if color[0] != '#': raise ValueError
            color = int(color[1:], 16)
        except ValueError:
            await rq.return_status(400)
            await rq.w('Invalid value')
            return
        led.np[0] = ((color >> 8 & 0xFF), (color >> 16), (color & 0xFF))
        led.new_color.set()
        await rq.w('OK')
    elif rq.is_postjson():
        led_val = await rq.decode_postjson_data()
        if not led_val:
            await rq.return_status(400)
            await rq.w('Wrong format')
            return
        try:
            led.np[0] = (led_val['LED']['g'],led_val['LED']['r'] , led_val['LED']['b'])
            led.new_color.set()
            await rq.w('OK')
        except KeyError:
            await rq.return_status(400)
            await rq.w('KeyError')
    else:
        await rq.return_status(400)
        await rq.w('No POST data')


@web.route_ws('/motors.ws')
async def motor_ws(rq, evt):
    t = evt['type']
    if t == 'bytes':
        vl, vr = struct.unpack('ff', evt['data'])
        motors.ml.go(vl)
        motors.mr.go(vr)
    elif t == 'close':
        motors.ml.stop()
        motors.mr.stop()

async def info_ws_task(rq):
    while True:
        b = struct.pack(
            '>fffbbb',
            position.x, position.y, position.a,
            led.np[0][1], led.np[0][0], led.np[0][2]
        )
        await rq.w(b);
        await asyncio.sleep(0.5)

info_tasks = {}
@web.route_ws('/infos.ws')
async def info_ws(rq, evt):
    global info_tasks
    t = evt['type']
    if t == 'open':
        info_tasks[rq] = asyncio.create_task(info_ws_task(rq))

    elif t == 'close':
        info_tasks[rq].cancel()
        del info_tasks[rq]

@web.route('GET', '/position/position.txt')
async def pos_handler(rq):
    await rq.header_text()
    await rq.w("Position:\r\n{} mm\r\n{} mm\r\n{} degrees".format(
        round(position.x * 1000),
        round(position.y * 1000),
        round(position.a * 180 / pi)
    ))

@web.route('GET', '/position/reset')
async def position_reset_handler(rq):
    position.reset()
    await rq.w('OK')
