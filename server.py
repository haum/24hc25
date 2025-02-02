import web
import json
import led
import uos
import uasyncio as asyncio


import web
import uasyncio as asyncio

async def root_handler(r, w):

    if r.path=="/":
        r.path = "/index.htm"

    try:
        f = open(r.path, 'rb')
    except OSError:
        print(r.path)
        print(r.query)
        print(r.headers)
        w.write(b'HTTP/1.0 404 Not Found\r\n')
        await w.drain()
        return

    w.write(b'HTTP/1.0 200 OK\r\n')
    w.write(b'Content-Length: %i\r\n' % uos.stat(r.path)[6])

    p = r.path
    if p.endswith(".gz"):
        w.write(b'Content-Encoding: gzip\r\n')
        p = p[0:-3]

    w.write(b'Content-Type:  ');
    if p.endswith(".htm") or p.endswith(".html"):
        w.write(b'text/html')
    elif p.endswith(".js"):
        w.write(b'application/javascript')
    elif p.endswith(".css"):
        w.write(b'text/css')
    elif p.endswith(".png"):
        w.write(b'image/png')
    else:
        w.write(b'text/plain')
    w.write(b'\r\n\r\n')

    l = f.read(1024)
    if not l:
       await w.drain()
    while (l):
        w.write(l)
        await w.drain()
        l = f.read(1024)
    f.close()


# curl -X POST -i 'http://pi_esp/api' --data '{"LED":{"r":0,"g":0,"b":0}}'

async def api_handler(r, w):
    body = await r.read(1024)
    data = body.decode()
    try:
        led_val = json.loads(data)
        try:
           led.np[0] = (led_val['LED']['g'],led_val['LED']['r'] , led_val['LED']['b'])
           led.new_color.set()
           print("200 OK")
           w.write(b'HTTP/1.0 200 OK\r\n')
           w.write(b'Content-Type: text/html; charset=utf-8\r\n')
           w.write(b'\r\n')
           # write page body
           w.write(b'OK')
        except KeyError:
           print("400 KO")
           w.write(b'HTTP/1.0  400 \r\n')
           w.write(b'Content-Type: text/html; charset=utf-8\r\n')
           w.write(b'\r\n')
           # write page body
           w.write(b'KeyError')
    except ValueError:
        print("400 KO")
        w.write(b'HTTP/1.0 400 \r\n')
    # drain stream buffer
    await w.drain()
 
 
async def api_get_handler(r, w):
    if r.path=="/api":
        r.path = "/api/index.htm.gz"
    await root_handler(r, w)
    
def init(app):
    app.add_handler('/', root_handler)
    app.add_handler('/api', api_get_handler, methods=['GET'])
    app.add_handler('/api', api_handler, methods=['POST'])
    
