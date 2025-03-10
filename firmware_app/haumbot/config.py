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

load()
