import asyncio
import machine
import vl53l3cx
import haumbot.config as conf

i2c = machine.I2C(
    0,
    scl=machine.Pin(conf.get('pin_i2c_rangefinder_scl')),
    sda=machine.Pin(conf.get('pin_i2c_rangefinder_sda')),
    freq=400_000,
    timeout=1000
)

vl = vl53l3cx.VL53L3CX(i2c)
distance = 0

async def run():
    global distance
    is_present = (vl.getSensorId() == 0xeaaa)
    if is_present:
        vl.sensorInit()
        vl.setSigmaThreshold(30)
        vl.setSignalThreshold(2000)
        vl.setInterruptConfiguration(0, False)
        vl.setInterMeasurementInMs(20)
        vl.setRoi(16)
        vl.startRanging()

        while True:
            if vl.checkForDataReady():
                vl.clearInterrupt()
                data = vl.dumpDebugData()
                measurement_status, estimated_distance_mm, signal_kcps, sigma_mm, ambient_kcps = data
                if measurement_status == 0:
                    distance = estimated_distance_mm + 0.82 * (distance - estimated_distance_mm)
            await asyncio.sleep_ms(20)
    else:
        print('Sensor not found.')
