import asyncio
import haumbot.config as conf
import haumbot.motors as motors
import haumbot.position as position

task = None

class DiscretePID:
    def __init__(self, dt, Kp, Ki, Kd):
        self.q0 = Kp*(Ki*dt/2+Kd/dt+1)
        self.q1 = Kp*(Ki*dt/2-Kd/dt*2-1)
        self.q2 = Kp*Kd/dt
        self.em1 = 0
        self.em2 = 0
        self.y = 0

    def process(self, e):
        self.y += self.q0 * e + self.q1 * self.em1 + self.q2 * self.em2
        self.em2 = self.em1
        self.em1 = e
        return self.y


def start(data):
    global task
    stop()
    t = data.get('type', '')

    if t == 'dist':
        task = asyncio.create_task(move_dist(data.get('dist')))
    elif t == 'angle':
        task = asyncio.create_task(move_angle(data.get('angle')))
    else:
        return False
    return True

def stop():
    global task
    if task: task.cancel()
    task = None
    motors.ml.stop()
    motors.mr.stop()

async def move_dist(dist):
    x0 = position.x
    y0 = position.y
    a0 = position.a
    dist2 = (dist/1000)**2
    pid = DiscretePID(0.05, conf.get('Kp_v'), conf.get('Ki_v'), conf.get('Kd_v'))
    sgn = 1 if dist > 0 else -1
    d2_old = 0
    block_count = 0
    while True:
        d2 = (position.x - x0)**2 + (position.y - y0)**2
        if d2 > dist2: break
        if abs(d2 - d2_old) < 0.001: block_count += 1
        if block_count >= 10: break
        d2_old = d2
        c = min(pid.process(position.a - a0), 0.3)
        motors.ml.go(sgn * 0.7 + c)
        motors.mr.go(sgn * 0.7 - c)
        await asyncio.sleep_ms(50)
    motors.ml.stop()
    motors.mr.stop()

async def move_angle(angle):
    angle *= 3.14159/180
    a0 = position.a
    pid = DiscretePID(0.05, conf.get('Kp_w'), conf.get('Ki_w'), conf.get('Kd_w'))
    sgn = 1 if angle > 0 else -1
    a_old = 0
    block_count = 0
    while True:
        if sgn * (position.a - a0) > sgn * angle: break
        if (position.a - a_old) < 0.0001:
            block_count +=1
        if block_count >= 3:
            break
        a_old = position.a
        c = min(pid.process(position.v), 0.3)
        motors.ml.go(sgn * (-0.7 + c))
        motors.mr.go(sgn * (0.7 + c))
        await asyncio.sleep_ms(50)
    motors.ml.stop()
    motors.mr.stop()
