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

		document.body.dispatchEvent(new CustomEvent('infos_position', {
			'detail': [position_x, position_y, position_a]
		}));
	}

	if (mask & INFO_LED) {
		const led_r = view.getUint8(pos + 0);
		const led_g = view.getUint8(pos + 1);
		const led_b = view.getUint8(pos + 2);
		pos += 3;

		document.body.dispatchEvent(new CustomEvent('infos_led', {
			'detail': [led_r, led_g, led_b]
		}));
	}
});
