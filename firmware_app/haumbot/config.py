import json

config = {
    'pin_led': 0,
    'pin_ml': 1,
    'pin_mr': 2,
    'pin_i2c_l_scl': 10,
    'pin_i2c_l_sda': 7,
    'pin_i2c_r_scl': 6,
    'pin_i2c_r_sda': 5,
    'ml_inv': True,
    'mr_inv': False,
    'Kw': 0.00073885,
    'Kv': 0.0005,
}
config_types = {
    'pin_led': int,
    'pin_ml': int,
    'pin_mr': int,
    'pin_i2c_l_scl': int,
    'pin_i2c_l_sda': int,
    'pin_i2c_r_scl': int,
    'pin_i2c_r_sda': int,
    'ml_inv': bool,
    'mr_inv': bool,
    'Kw': float,
    'Kv': float,
}
notify_changes_cbs = {}

def load():
    global config
    try:
        with open('haumbot_config.json', 'r') as f:
            config.update(json.load(f))
    except:
        print('Loading config failed, use default')

def save():
    with open('haumbot_config.json', 'w') as f:
        json.dump(config, f)

def get(k, dv=None):
    if k in config:
        return config[k]
    else:
        return dv

def set(k, v):
    if not k in config: return
    v = config_types[k](v)
    if v == config[k]: return
    config[k] = v
    if k in notify_changes_cbs:
        for cb in notify_changes_cbs[k]:
            cb()

def notify_changes(k, fct):
    if not k in notify_changes_cbs:
        notify_changes_cbs[k] = []
    notify_changes_cbs[k].append(fct)

load()
