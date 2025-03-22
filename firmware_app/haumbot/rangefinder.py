import asyncio
import machine
import vl53l3cx
import haumbot.config as conf
from math import exp

i2c = machine.I2C(
    0,
    scl=machine.Pin(conf.get('pin_i2c_rangefinder_scl')),
    sda=machine.Pin(conf.get('pin_i2c_rangefinder_sda')),
    freq=400_000,
    timeout=1000
)

vl = vl53l3cx.VL53L3CX(i2c)
distance = 0
etau = 0.82
ms = 10

async def run():
    global distance, etau
    is_present = (vl.getSensorId() == 0xeaaa)
    if is_present:
        etau = exp(-ms/max(conf.get('rangefinder_tau'), 1))
        vl.sensorInit()
        vl.setSigmaThreshold(conf.get('rangefinder_sigma'))
        vl.setSignalThreshold(conf.get('rangefinder_thresh'))
        vl.setInterruptConfiguration(0, False)
        vl.setInterMeasurementInMs(ms)
        vl.setRoi(16)
        vl.startRanging()

        while True:
            if vl.checkForDataReady():
                vl.clearInterrupt()
                data = vl.dumpDebugData()
                measurement_status, estimated_distance_mm, signal_kcps, sigma_mm, ambient_kcps = data
                if measurement_status == 0:
                    distance = estimated_distance_mm + etau * (distance - estimated_distance_mm)
            await asyncio.sleep_ms(ms)
    else:
        print('Sensor not found.')
