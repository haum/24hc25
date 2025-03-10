import machine
import haumbot.config as conf

class Servo:
    def __init__(self, pin, inv=False):
        self.inv = -1 if inv else 1
        self.pwm = machine.PWM(pin, freq=50, duty_ns=self._p(0))
        self.stop()

    def _p(self, p):
        return int(min(max(-1.0, p*self.inv), 1.0) * 265000 + 1415000)

    def _start(self, p=0):
        self.pwm.init(freq=50, duty_ns=self._p(p))
        self.on = True

    def stop(self):
        self.pwm.deinit()
        self.on = False

    def go(self, p):
        if not self.on:
            if p != 0:
                self._start(p)
        elif p == 0:
            self.stop()
        else:
            self.pwm.duty_ns(self._p(p))

pin_ml = machine.Pin(conf.get('pin_ml'), machine.Pin.OUT)
pin_mr = machine.Pin(conf.get('pin_mr'), machine.Pin.OUT)
ml = Servo(pin_ml, conf.get('ml_inv'))
mr = Servo(pin_mr, conf.get('mr_inv'))
