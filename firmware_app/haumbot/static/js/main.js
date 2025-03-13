const sections = document.querySelectorAll('section[data-title]');
const ul_header_menu = document.getElementById('ul_header_menu');
const sections_opened = new Set();
if (sessionStorage.getItem('sections_opened')) {
	for (const s of sessionStorage.getItem('sections_opened').split('§'))
		sections_opened.add(s);
}
for (const s of sections) {
	const h2 = document.createElement('h2');
	const title = s.dataset.title;
	h2.innerText = title;
	s.insertBefore(h2, s.firstChild);
	s.classList.add('pico');
	const li = document.createElement('li');
	ul_header_menu.append(li);
	const label = document.createElement('label');
	li.append(label);
	const checkbox = document.createElement('input');
	checkbox.type = 'checkbox';
	label.append(checkbox, title);
	checkbox.addEventListener('click', e => {
		const on = e.target.checked;
		s.classList.toggle('opened', on);
		if (on)
			sections_opened.add(title);
		else
			sections_opened.delete(title);
		sessionStorage.setItem('sections_opened', Array.from(sections_opened).join('§'));
	});
	checkbox.checked = false;
	if (sections_opened.has(title)) {
		s.classList.add('opened');
		checkbox.checked = true;
	}
}

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
	const data = new URLSearchParams();
	for (const pair of new FormData(led_form)) {
		data.append(pair[0], pair[1]);
	}
	fetch(led_form.action, {
		method: 'post',
		headers: { "Content-Type": "application/x-www-form-urlencoded" },
		body: data
	});
});

const motors_buf = new Float32Array(2);
const motors_ml = document.getElementById("motors_ml")
const motors_mr = document.getElementById("motors_mr")
const motors_stop = document.getElementById("motors_stop")
let motors_ws = null;
const send_motors = (vl, vr) => {
	if (motors_ws && motors_ws.readyState == WebSocket.OPEN) {
		const lim = v => Math.max(-1, Math.min(v, 1));
		motors_buf[0] = lim(vl);
		motors_buf[1] = lim(vr);
		motors_ml.value = vl * 100;
		motors_mr.value = vr * 100;
		motors_ws.send(motors_buf);
	} else if (!motors_ws || motors_ws.readyState != WebSocket.CONNECTING) {
		motors_ws = new WebSocket('ws://' + document.location.host + '/motors.ws');
		motors_ws.addEventListener("open", () => send_motors(vl, vr));
	}
};
const update_motors = () => {
	const vl = motors_ml.value / 100;
	const vr = motors_mr.value / 100;
	send_motors(vl, vr);
}
motors_ml.addEventListener('change', update_motors);
motors_mr.addEventListener('change', update_motors);
motors_stop.addEventListener('click', e => {
	e.preventDefault();
	motors_ml.value = 0;
	motors_mr.value = 0;
	update_motors();
});

const map_canvas = document.getElementById('map');
const map_scale_range = document.getElementById('map_scale');
const pos_hist = [];
const text_color = getComputedStyle(map_canvas).color;
const map_draw = (x, y, a) => {
	const ctx = map_canvas.getContext("2d");
	const w = map_canvas.width;
	const h = map_canvas.height;
	const map_scale = Number(map_scale_range.value);
	ctx.clearRect(0, 0, w, h);

	pos_hist.unshift([x, y]);
	if (pos_hist.length > 10) pos_hist.pop();

	ctx.font = '30px sans-serif';
	ctx.fillStyle = text_color;
	ctx.textAlign = 'right';
	ctx.fillText(Math.round(x*1000) + ' mm <X>', w-5, 30);
	ctx.fillText(Math.round(y*1000) + ' mm <Y>', w-5, 60);
	ctx.fillText(Math.round(a*180/Math.PI) + ' deg <A>', w-5, 90);

	ctx.save();
	ctx.translate(w/2, h/2);
	ctx.scale(map_scale/1000, map_scale/1000);
	ctx.lineWidth = Math.round(2*1000/map_scale);

	ctx.beginPath();
	for (let i = -10; i <= 11; i++) {
		ctx.moveTo(-95+190*i, -95-2090);
		ctx.lineTo(-95+190*i, -95+2090+190);
		ctx.moveTo(-95-2090, -95+190*i);
		ctx.lineTo(-95+2090+190, -95+190*i);
	}
	ctx.strokeStyle = 'rgba(180, 180, 180, 50%)';
	ctx.stroke();

	const hl = pos_hist.length;
	for (let i = 1; i < hl; i++) {
		ctx.beginPath();
		ctx.moveTo(1000*pos_hist[i-1][0], -1000*pos_hist[i-1][1]);
		ctx.lineTo(1000*pos_hist[i][0], -1000*pos_hist[i][1]);
		const v = Math.round((hl-i)/(hl-1)*100);
		ctx.strokeStyle = 'rgba(180, 200, 0, ' + v + '%)';
		ctx.stroke();
	}

	ctx.translate(x*1000, -y*1000);
	ctx.rotate(-a);
	ctx.beginPath();
	ctx.moveTo(40, 0);
	ctx.lineTo(35, 77/4);
	ctx.lineTo(24, 77/2);
	ctx.lineTo(-68, 77/2);
	ctx.lineTo(-68, -77/2);
	ctx.lineTo(24, -77/2);
	ctx.lineTo(35, -77/4);
	ctx.lineTo(40, 0);
	ctx.strokeStyle = '#008000'
	ctx.stroke();

	ctx.restore();
};

const ledcolor_info = document.getElementById('ledcolor_info');
const INFO_POSITION = 0x01;
const INFO_LED = 0x02;
let infos_ws = new WebSocket('ws://' + document.location.host + '/infos.ws');
infos_ws.binaryType = "arraybuffer";
infos_ws.addEventListener("open", () => {
	const buf = new Uint8Array(1);
	buf[0] = INFO_POSITION | INFO_LED;
	infos_ws.send(buf);
});
infos_ws.addEventListener("message", e => {
	const view = new DataView(e.data);
	let pos = 0;

	const mask = view.getUint8(pos);
	pos++;

	if (mask & INFO_POSITION) {
		const position_x = view.getFloat32(pos + 0);
		const position_y = view.getFloat32(pos + 4);
		const position_a = view.getFloat32(pos + 8);
		pos += 3*4;

		map_draw(position_x, position_y, position_a);
	}

	if (mask & INFO_LED) {
		const led_r = view.getUint8(pos + 0);
		const led_g = view.getUint8(pos + 1);
		const led_b = view.getUint8(pos + 2);

		let color_hex = '#';
		for (const v of [led_r, led_g, led_b]) {
			const sv = v.toString(16);
			if (sv.length == 1) color_hex += '0';
			color_hex += sv;
		}
		ledcolor_info.style.backgroundColor = color_hex;
	}
});

const position_reset = document.getElementById('position_reset');
position_reset.addEventListener('click', async () => {
	position_reset.disabled = true;
	await fetch('/position/reset')
	position_reset.disabled = false;
});

const motors_joystick = document.getElementById('motors_joystick');
{
	const btnsz = 40;
	let positionX = 0, positionY = 0;
	let clicked = false;
	let lastsend = performance.now();
	const draw = () => {
		const ctx = motors_joystick.getContext("2d");
		const w = motors_joystick.width;
		const h = motors_joystick.height;
		ctx.clearRect(0, 0, w, h);

		ctx.fillStyle = "#00aaff40";
		ctx.beginPath();
		ctx.arc(w/2, h/2, w/2-btnsz, 0, 2 * Math.PI);
		ctx.fill();

		ctx.lineWidth = 2;
		ctx.strokeStyle = "#0099ee";
		ctx.fillStyle = "#00aaff";
		ctx.beginPath();
		ctx.arc(w/2 + positionX, h/2 + positionY, btnsz, 0, 2 * Math.PI);
		ctx.fill();
		ctx.stroke();
	}
	const updatePosition = e => {
		const r = motors_joystick.getBoundingClientRect();
		const kw = r.width/2 - btnsz;
		let vx = Math.max(-1, Math.min((e.clientX - r.left - r.width/2) / kw, 1));
		let vy = Math.max(-1, Math.min((e.clientY - r.top - r.height/2) / kw, 1));
		if (vx*vx + vy*vy > 1) {
			const a = Math.atan2(vy, vx);
			vx = Math.cos(a);
			vy = Math.sin(a);
		}
		positionX = vx * kw;
		positionY = vy * kw;
		vy *= -1;
		if (performance.now() - lastsend > 250) {
			send_motors(vy+vx, vy-vx);
			lastsend = performance.now();
		}
		draw();
	}
	const ondown = e => {
		clicked = true;
		motors_joystick.style.cursor = 'none'
		updatePosition(e);
	};
	const onmove = e => {
		if (clicked) {
			updatePosition(e);
		}
	};
	const onup = e => {
		if (clicked) {
			send_motors(0, 0);
			motors_joystick.style.cursor = ''
			clicked = false;
			positionX = positionY = 0;
			draw();
		}
	};
	draw();
	motors_joystick.addEventListener('mousedown', ondown);
	motors_joystick.addEventListener('mousemove', onmove);
	motors_joystick.addEventListener('mouseup', onup);
	motors_joystick.addEventListener('mouseleave', onup);
	motors_joystick.addEventListener('touchstart', ondown);
	motors_joystick.addEventListener('touchmove', onmove);
	motors_joystick.addEventListener('touchend', onup);
	motors_joystick.addEventListener('touchcancel', onup);
}
