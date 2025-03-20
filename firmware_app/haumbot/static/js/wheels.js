import { infos_mask, INFOS_WHEELS } from "./infos.js";

const section = document.getElementById('section_wheels');
section.insertAdjacentHTML('beforeend', `
	<canvas id="wheels" width="800" height="400"></canvas>
`);

const canvas = document.getElementById('wheels');
const text_color = getComputedStyle(canvas).color;

document.body.addEventListener('h:infos:wheels', e => {
	const ctx = canvas.getContext("2d");
	const w = canvas.width;
	const h = canvas.height;
	const r = 195;
	const wl = e.detail[0]/2048*Math.PI;
	const wr = e.detail[1]/2048*Math.PI;
	const tl = e.detail[2];
	const tr = e.detail[3];
	ctx.clearRect(0, 0, w, h);

	ctx.lineWidth = 3;
	ctx.strokeStyle = "#808080"

	ctx.beginPath();
	ctx.arc(w/4, h/2, r, 0, 2 * Math.PI, false);
	ctx.stroke();

	ctx.beginPath();
	ctx.arc(3*w/4, h/2, r, 0, 2 * Math.PI, false);
	ctx.stroke();

	ctx.save();
	ctx.translate(w/4, h/2)
	ctx.rotate(wl)
	ctx.beginPath()
	ctx.moveTo(0, 0);
	ctx.lineTo(r, 0);
	ctx.stroke();
	ctx.restore()

	ctx.save();
	ctx.translate(3*w/4, h/2)
	ctx.rotate(wr)
	ctx.beginPath()
	ctx.moveTo(0, 0);
	ctx.lineTo(r, 0);
	ctx.stroke();
	ctx.restore()

	ctx.font = '30px sans-serif';
	ctx.fillStyle = text_color;
	ctx.textAlign = 'center';
	if (tl) ctx.fillText(tl, w/4, 3*h/4);
	if (tr) ctx.fillText(tr, 3*w/4, 3*h/4);
});

document.body.addEventListener('h:section:statechanged', e => {
	infos_mask(INFOS_WHEELS, e.detail['on']);
});
infos_mask(INFOS_WHEELS, true);
