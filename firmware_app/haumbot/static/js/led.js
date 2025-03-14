import { form_post } from "./main.js";

const cs = document.querySelectorAll('input[type=color]');
for (const c of cs) {
	c.type = 'text';
	c.dataset.coloris = 'convert';
}
Coloris.setInstance('input[data-coloris=convert]', {
	theme: 'pill',
	themeMode: 'auto',
	margin: 10,
	alpha: false,
	swatches: [
		'#ff0000',
		'#ff8000',
		'#ffff00',
		'#80ff00',
		'#00ff00',
		'#00ff80',
		'#00ffff',
		'#0080ff',
		'#0000ff',
		'#8000ff',
		'#ff00ff',
		'#ff0080',
		'#000000',
	]
});

const led_form = document.getElementById("led_form");
led_form.addEventListener('submit', e => {
	e.preventDefault();
	form_post(led_form);
});

const ledcolor_info = document.getElementById('ledcolor_info');
document.body.addEventListener('infos_led', e => {
	let color_hex = '#';
	for (const v of e.detail) {
		const sv = v.toString(16);
		if (sv.length == 1) color_hex += '0';
		color_hex += sv;
	}
	ledcolor_info.style.backgroundColor = color_hex;
});
