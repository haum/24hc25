export const INFOS_POSITION = 0x01;
export const INFOS_LED = 0x02;
export const INFOS_MOTORS = 0x04;
export const INFOS_WHEELS = 0x08;
export const INFOS_SPEED = 0x10;
export const INFOS_RANGEFINDER = 0x20;

let infos_ws = null;
let period_ms = 500;
let mask = 0;

function on_msg(e) {
	const view = new DataView(e.data);
	let pos = 0;

	const mask = view.getUint8(pos);
	pos++;

	if (mask & INFOS_POSITION) {
		const position_x = view.getFloat32(pos + 0);
		const position_y = view.getFloat32(pos + 4);
		const position_a = view.getFloat32(pos + 8);
		pos += 3*4;
		document.body.dispatchEvent(new CustomEvent('h:infos:position', {
			'detail': [position_x, position_y, position_a]
		}));
	}

	if (mask & INFOS_LED) {
		const led_r = view.getUint8(pos + 0);
		const led_g = view.getUint8(pos + 1);
		const led_b = view.getUint8(pos + 2);
		pos += 3;

		document.body.dispatchEvent(new CustomEvent('h:infos:led', {
			'detail': [led_r, led_g, led_b]
		}));
	}

	if (mask & INFOS_MOTORS) {
		const ml = view.getFloat32(pos + 0);
		const mr = view.getFloat32(pos + 4);
		pos += 2*4;

		document.body.dispatchEvent(new CustomEvent('h:infos:motors', {
			'detail': [ml, mr]
		}));
	}

	if (mask & INFOS_WHEELS) {
		const wl = view.getInt16(pos + 0);
		const wr = view.getInt16(pos + 2);
		const tl = view.getInt16(pos + 4);
		const tr = view.getInt16(pos + 6);
		pos += 4*2;

		document.body.dispatchEvent(new CustomEvent('h:infos:wheels', {
			'detail': [wl, wr, tl, tr]
		}));
	}

	if (mask & INFOS_SPEED) {
		const w = view.getFloat32(pos + 0);
		const v = view.getFloat32(pos + 4);
		pos += 4*2;

		document.body.dispatchEvent(new CustomEvent('h:infos:speed', {
			'detail': [w, v]
		}));
	}

	if (mask & INFOS_RANGEFINDER) {
		const d = view.getUint16(pos + 0);
		pos += 2;

		document.body.dispatchEvent(new CustomEvent('h:infos:rangefinder', {
			'detail': [d]
		}));
	}
}

function send_mask() {
	if (mask == 0) {
		if (infos_ws) {
			infos_ws.close();
			infos_ws = null;
		}
	} else {
		if (infos_ws) {
			if (infos_ws.readyState == WebSocket.OPEN) {
				const buf = new Uint8Array(2);
				buf[0] = period_ms / 10;
				buf[1] = mask;
				infos_ws.send(buf);
			}
		} else {
			infos_ws = new WebSocket('ws://' + document.location.host + '/infos.ws');
			infos_ws.binaryType = "arraybuffer";
			infos_ws.addEventListener("open", send_mask);
			infos_ws.addEventListener("message", on_msg);
		}
	}
}

export function infos_mask(v, on) {
	if (on)
		mask |= v;
	else
		mask &= ~v;
	send_mask();
}
