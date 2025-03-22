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
etau = 0
ms = 10
lin_a = conf.get('rangefinder_lin_a')
lin_b = conf.get('rangefinder_lin_b')

async def run():
    global distance
    is_present = (vl.getSensorId() == 0xeaaa)
    if is_present:
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
                    estimated_distance_mm = min(max(0, estimated_distance_mm * lin_a + lin_b), 1000)
                    distance = estimated_distance_mm + etau * (distance - estimated_distance_mm)
            await asyncio.sleep_ms(ms)
    else:
        print('Sensor not found.')

def conf_changed():
    global lin_a, lin_b, etau
    lin_a = conf.get('rangefinder_lin_a')
    lin_b = conf.get('rangefinder_lin_b')
    etau = exp(-ms/max(conf.get('rangefinder_tau'), 1))

def start_measure():
    conf.notify_changes('rangefinder_lin_a', conf_changed)
    conf.notify_changes('rangefinder_lin_b', conf_changed)
    conf.notify_changes('rangefinder_tau', conf_changed)

conf_changed()
