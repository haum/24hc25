import web
import json
import led

app = web.App(host='0.0.0.0', port=80)

# root route handler
@app.route('/')
async def handler(r, w):
    w.write(b'HTTP/1.0 200 OK\r\n')
    w.write(b'Content-Type: text/html; charset=utf-8\r\n')
    w.write(b'\r\n')
    w.write(b'Hello world!')
    await w.drain()

# curl -X POST -i 'http://192.168.0.184' --data '{"LED":{"r":0,"g":0,"b":0}}'
@app.route('/', methods=['POST'])
async def handler(r, w):
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