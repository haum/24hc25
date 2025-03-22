import { infos_mask, INFOS_RANGEFINDER } from "./infos.js";

const section = document.getElementById('section_rangefinder');
section.insertAdjacentHTML('beforeend', `
	<canvas id="rangefinder" width="800" height="40"></canvas>
`);

const canvas = document.getElementById('rangefinder');
const text_color = getComputedStyle(canvas).color;

document.body.addEventListener('h:infos:rangefinder', e => {
	const ctx = canvas.getContext("2d");
	const w = canvas.width;
	const h = canvas.height;
	const range = e.detail[0];
	const rangep = Math.min(range/1000, 1);
	ctx.clearRect(0, 0, w, h);

	ctx.lineWidth = 3;
	ctx.strokeStyle = "#808080"

	ctx.fillStyle = "#00aaff40";
	ctx.beginPath();
	ctx.rect(5, 5, (w-10) * rangep, h-10);
	ctx.fill();

	ctx.beginPath();
	ctx.rect(5, 5, w-10, h-10);
	ctx.stroke();

	ctx.font = '26px sans-serif';
	ctx.fillStyle = text_color;
	ctx.textAlign = 'right';
	ctx.fillText(range + "mm", w-10, h-10);
});

document.body.addEventListener('h:section:statechanged', e => {
	infos_mask(INFOS_RANGEFINDER, e.detail['on']);
});
infos_mask(INFOS_RANGEFINDER, true);
