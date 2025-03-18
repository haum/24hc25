import machine
import haumbot.config as conf

i2c = machine.I2C(
    0,
    scl=machine.Pin(conf.get('pin_i2c_rangefinder_scl')),
    sda=machine.Pin(conf.get('pin_i2c_rangefinder_sda')),
    freq=400_000,
    timeout=1000
)
