import './infos.js'
import './led.js'
import './motors.js'
import './position.js'
import './config.js'
import './wlan.js'

const sections = document.querySelectorAll('section[data-title]');
const ul_header_menu = document.getElementById('ul_header_menu');
const sections_opened = new Set();
if (sessionStorage.getItem('sections_opened')) {
	for (const s of sessionStorage.getItem('sections_opened').split('§'))
		sections_opened.add(s);
}
for (const s of sections) {
	const h2 = document.createElement('h2');
	const b_spans = document.createElement('b');
	const span_fs = document.createElement('span');
	span_fs.innerText = "⛶";
	const span_close = document.createElement('span');
	span_close.innerText = "×";
	b_spans.append(span_fs, span_close);
	const title = s.dataset.title;
	h2.append(title, b_spans);
	s.insertBefore(h2, s.firstChild);
	s.classList.add('pico');
	const li = document.createElement('li');
	ul_header_menu.append(li);
	const label = document.createElement('label');
	li.append(label);
	const checkbox = document.createElement('input');
	checkbox.type = 'checkbox';
	label.append(checkbox, title);
	const toggle = on => {
		s.classList.toggle('opened', on);
		checkbox.checked = on;
		if (on)
			sections_opened.add(title);
		else
			sections_opened.delete(title);
		sessionStorage.setItem('sections_opened', Array.from(sections_opened).join('§'));
	}
	checkbox.addEventListener('click', e => toggle(e.target.checked));
	checkbox.checked = false;
	if (sections_opened.has(title)) {
		s.classList.add('opened');
		checkbox.checked = true;
	}
	span_close.addEventListener('click', () => {
		if (document.fullscreenElement != null)
			document.exitFullscreen();
		toggle(false);
	});
	span_fs.addEventListener('click', () => {
		if (document.fullscreenElement == null)
			s.requestFullscreen();
		else
			document.exitFullscreen();
	});
}

export async function form_post(form) {
		const data = new URLSearchParams();
		for (const pair of new FormData(form)) {
			data.append(pair[0], pair[1]);
		}
		return await fetch(form.action, {
			method: 'post',
			headers: { "Content-Type": "application/x-www-form-urlencoded" },
			body: data
		});
}
