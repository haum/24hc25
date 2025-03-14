const position_reset = document.getElementById('position_reset');
position_reset.addEventListener('click', async () => {
	position_reset.disabled = true;
	await fetch('/position/reset')
	position_reset.disabled = false;
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

document.body.addEventListener('infos_position', e => {
	 map_draw(...e.detail);
});
