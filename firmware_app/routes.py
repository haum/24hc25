import asyncio
import json
import led
import aiowebserver as web

@web.route('GET', '/')
async def root_handler(rq):
    await rq.sendfile('static/root_index.htm')


@web.route('GET', '/api')
async def api_get_handler(rq):
    await rq.sendfile('static/api_index.htm')


# curl -X POST -i 'http://ip_esp/api' --data '{"LED":{"r":0,"g":0,"b":0}}'
@web.route('POST', '/api')
async def api_post_handler(rq):
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


@web.route('GET', '/led')
async def led_get_handler(rq):
    await rq.sendfile('static/led_index.htm')


# curl -X POST -i 'http://ip_esp/led' --data 'ledcolor=#666666'
@web.route('POST', '/led')
async def led_post_handler(rq):
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

