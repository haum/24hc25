import { form_post } from "./main.js";

const config_section = document.getElementById('config_section');
const form = document.createElement('form');

const c_pins = [
	['pin_led', 'Pin LED'],
	['pin_ml', 'Pin moteur gauche'],
	['pin_mr', 'Pin moteur droit'],
	['pin_i2c_l_scl', 'Pin I2C SCL roue gauche'],
	['pin_i2c_l_sda', 'Pin I2C SDA roue gauche'],
	['pin_i2c_r_scl', 'Pin I2C SCL roue droite'],
	['pin_i2c_r_sda', 'Pin I2C SDA roue droite'],
	['pin_i2c_rangefinder_scl', 'Pin I2C SCL télémètre'],
	['pin_i2c_rangefinder_sda', 'Pin I2C SDA télémètre'],
	['ml_inv', 'Moteur gauche inversé'],
	['mr_inv', 'Moteur droit inversé'],
];

const c_geometry = [
	['Kw', 'Constante géométrique de rotation'],
	['Kv', 'Constante géométrique d\'avancement'],
];

function update_form(conf) {
	for (const input of form.elements) {
		if (input.name)
			input.value = conf[input.name];
	}
}

async function load_config() {
	const r = await fetch('/config/all.json');
	const conf = await r.json();
	update_form(conf);
}

function setup_form() {
	form.action = '/config/set';
	form.method = 'POST';
	config_section.append(form);

	const add_input = (l, locked) => {
		const l_label = l[1];
		const l_name = l[0];
		const label = document.createElement('label');
		form.append(label);
		const input = document.createElement('input')
		input.type="text";
		input.disabled = locked;
		input.name = l_name;
		label.append(l_label, input);
	};

	const h_pins = document.createElement('h3');
	h_pins.innerText = 'Brochage'
	form.append(h_pins);
	for (const l of c_pins) add_input(l, true);

	const h_moving = document.createElement('h3');
	h_moving.innerText = 'Géométrie'
	form.append(h_moving);
	for (const l of c_geometry) add_input(l);

	const btn = document.createElement('input');
	btn.type = 'submit';
	form.append(btn)

	form.addEventListener('submit', async e => {
		e.preventDefault();
		btn.disabled = true;
		const r = await form_post(form);
		update_form(await r.json())
		btn.disabled = false;
	});
}

setup_form();
load_config();
