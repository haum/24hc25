import micropython
import machine
import struct
import haumbot.config as conf
from math import cos, sin

period = micropython.const(50) # ms

iwl, iwr = 0, 0 # initial wheel position
owl, owr = 0, 0 # last sample wheel position
tl, tr = 0, 0 # Nb of turns of wheels
Kv, Kw = 1, 1 # Constants for speed and angle
x, y, a = 0, 0, 0 # Position in m and rad
v = 0 # average speed

i2c_l = machine.SoftI2C(
    scl=machine.Pin(conf.get('pin_i2c_l_scl')),
    sda=machine.Pin(conf.get('pin_i2c_l_sda')),
    freq=400_000,
    timeout=1000
)
i2c_r = machine.SoftI2C(
    scl=machine.Pin(conf.get('pin_i2c_r_scl')),
    sda=machine.Pin(conf.get('pin_i2c_r_sda')),
    freq=400_000,
    timeout=1000
)
timer = machine.Timer(0)

def as5600_get_rawangle(i2c):
    return struct.unpack('>H', i2c.readfrom_mem(0x36, 0x0c, 2))[0] & 0xfff

def diagnostic():
    try:
        as5600_get_rawangle(i2c_l)
    except OSError:
        print("Left not found")
    try:
        as5600_get_rawangle(i2c_r)
    except OSError:
        print("Right not found")

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
    try:
        wl, wr = read_angles()
    except OSError:
        print('Communication error with AS5600, stop measuring position')
        timer.deinit()
        diagnostic()
        return
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
    global iwl, iwr, owl, owr, tl, tr, x, y, Kw, Kv
    timer.deinit()
    try:
        iwl, iwr = as5600_get_rawangle(i2c_l), as5600_get_rawangle(i2c_r)
        owl, owr = read_angles()
    except OSError:
        print('Communication error with AS5600, not measuring position')
        diagnostic()
        return
    tl, tr = 0, 0
    x, y = 0, 0
    Kw = conf.get('Kw')
    Kv = conf.get('Kv')
    timer.init(
        period=period,
        callback=lambda t: micropython.schedule(position_tick, None)
    )

def conf_changed():
    global Kw, Kv
    Kw = conf.get('Kw')
    Kv = conf.get('Kv')

def start_measure():
    conf.notify_changes('Kw', conf_changed)
    conf.notify_changes('Kv', conf_changed)
    reset()
