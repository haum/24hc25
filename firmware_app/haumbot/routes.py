import asyncio
import json
import struct
import haumbot.config as conf
import haumbot.led as led
import haumbot.motors as motors
import haumbot.pilot as pilot
import haumbot.position as position
import haumbot.wlan as wlan
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
        led.set_color(((color >> 16), (color >> 8 & 0xFF), (color & 0xFF)))
        await rq.w('OK')
    elif rq.is_postjson():
        led_val = await rq.decode_postjson_data()
        if not led_val:
            await rq.return_status(400)
            await rq.w('Wrong format')
            return
        try:
            led.set_color((led_val['LED']['r'], led_val['LED']['g'], led_val['LED']['b']))
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
        pilot.stop()
        vl, vr = struct.unpack('ff', evt['data'])
        motors.ml.go(vl)
        motors.mr.go(vr)
    elif t == 'close':
        motors.ml.stop()
        motors.mr.stop()


infos_ws_data = {}
async def infos_ws_task(rq):
    info = infos_ws_data[rq]
    while True:
        mask = info['mask']
        b = int(mask).to_bytes()
        if mask & 1: b += struct.pack('>fff', position.x, position.y, position.a)
        if mask & 2: b += struct.pack('>bbb', *led.get_color())
        if mask & 4: b += struct.pack('>ff', motors.ml.p, motors.mr.p)
        if mask & 8: b += struct.pack(
            '>hhhh',
            position.owl, position.owr,
            position.tl, position.tr
        )
        if mask & 16: b += struct.pack('>ff', position.w, position.v)
        await rq.w(b);
        await asyncio.sleep(info['delay'])

@web.route_ws('/infos.ws')
async def infos_ws(rq, evt):
    global infos_ws_data
    t = evt['type']
    if t == 'open':
        infos_ws_data[rq] = { 'task': asyncio.create_task(infos_ws_task(rq)), 'mask': 1, 'delay': 0.5 }

    elif t == 'bytes':
        infos_ws_data[rq]['mask'] = evt['data'][-1]
        if len(evt['data']) > 1:
            infos_ws_data[rq]['delay'] = max(evt['data'][-2], 1) * 0.01

    elif t == 'close':
        infos_ws_data[rq]['task'].cancel()
        del infos_ws_data[rq]


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
    try:
        position.reset()
        await rq.w('OK')
    except:
        await rq.w('KO')

@web.route('GET', '/config/all.json')
async def config_all_handler(rq):
    await rq.header_json()
    await rq.w(json.dumps(conf.config))

@web.route('POST', '/config/set')
async def config_set_handler(rq):
    d = await rq.decode_postform_data()
    for k, v in d.items():
        try:
            conf.set(k, v)
        except:
            pass
    conf.save()
    await config_all_handler(rq)

@web.route('GET', '/wlan/known.json')
async def wlan_known_handler(rq):
    await rq.header_json()
    await rq.w(json.dumps([n[0] for n in wlan.load_networks()]))

@web.route('POST', '/wlan/set_password')
async def wlan_password_handler(rq):
    networks = wlan.load_networks()
    form = await rq.decode_postform_data()
    ssid = form.get('ssid')
    pwd = form.get('password')
    if ssid in next(zip(*networks)):
        wlan.save_networks([[ssid, pwd] if n[0] == ssid else n for n in networks])
    else:
        networks.append([ssid, pwd])
        wlan.save_networks(networks)
    await rq.header_text()
    await rq.w('OK')

@web.route('POST', '/wlan/delete')
async def wlan_delete_handler(rq):
    ssid = (await rq.decode_postform_data()).get('ssid')
    wlan.save_networks([n for n in wlan.load_networks() if n[0] != ssid])
    await rq.header_text()
    await rq.w('OK')

@web.route('POST', '/wlan/sort')
async def wlan_sort_handler(rq):
    form = await rq.decode_postform_data()
    networks = wlan.load_networks()
    ranks = (form.get(str(i+1), 1000) for i in range(len(networks)))
    wlan.save_networks([n for _, _, n in sorted(zip(ranks, range(len(networks)), networks))])
    await rq.header_text()
    await rq.w('OK');

@web.route('GET', '/wlan/disconnect')
async def wlan_disconnect_handler(rq):
    print('DISCONNECT')
    wlan.disconnect()
    await rq.header_text()
    await rq.w('OK');

@web.route('POST', '/turtle/send')
async def turtle_send_handler(rq):
    await rq.header_text()
    if rq.is_postjson():
        data = await rq.decode_postjson_data()
        if pilot.start(data):
            await rq.w('OK');
            return
    await rq.w('KO');

@web.route('GET', '/turtle/stop')
async def turtle_stop_handler(rq):
    pilot.stop()
    await rq.header_text()
    await rq.w('OK');
