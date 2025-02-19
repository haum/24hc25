import micropython
import machine
import struct
from math import cos, sin

period = micropython.const(50) # ms

iwl, iwr = 0, 0 # initial wheel position
owl, owr = 0, 0 # last sample wheel position
tl, tr = 0, 0 # Nb of turns of wheels
Kv, Kw = 1, 1 # Constants for speed and angle
x, y, a = 0, 0, 0 # Position in m and rad
v = 0 # average speed

P = machine.Pin
i2c_l = machine.SoftI2C(scl=P(10), sda=P(9), freq=400_000, timeout=1000)
i2c_r = machine.SoftI2C(scl=P(8), sda=P(7), freq=400_000, timeout=1000)
timer = machine.Timer(0)

def as5600_get_rawangle(i2c):
    return struct.unpack('>H', i2c.readfrom_mem(0x36, 0x0c, 2))[0] & 0xfff

@micropython.native
def read_angles():
    wl = (8192 - as5600_get_rawangle(i2c_l) + iwl) & 0xfff
    wr = (8192 + as5600_get_rawangle(i2c_r) - iwr) & 0xfff
    return wl, wr

@micropython.native
def mod(a, arange, amin=0):
    return ((a - amin) % arange) + amin

@micropython.native
def position_tick(p=None):
    global owl, owr, tl, tr, v, x, y, a
    wl, wr = read_angles()
    if wl - owl > 2048: tl -= 1
    if wr - owr > 2048: tr -= 1
    if wl - owl < -2048: tl += 1
    if wr - owr < -2048: tr += 1
    a = (wr - wl + (tr - tl) * 4096) * Kw
    v = (mod(wl - owl, 4096, -2048) + mod(wr - owr, 4096, -2048)) / 2 * Kv
    x += v * cos(a) * period / 1000
    y += v * sin(a) * period / 1000
    owl, owr = wl, wr

def reset():
    global iwl, iwr, owl, owr, tl, tr, x, y
    iwl, iwr = as5600_get_rawangle(i2c_l), as5600_get_rawangle(i2c_r)
    owl, owr = read_angles()
    tl, tr = 0, 0
    x, y = 0, 0

def start_measure():
    try:
        reset()
    except OSError:
        print('At least one AS5600 not found, not measuring position')
        return

    # TODO Read from config file
    global Kw, Kv
    Kw = 0.00073885
    Kv = 0.0005

    timer.init(
        period=period,
        callback=lambda t: micropython.schedule(position_tick, None)
    )
