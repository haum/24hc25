const section = document.getElementById('section_turtle');
section.insertAdjacentHTML('beforeend', `
	<p>
		<form method="POST" action="/turtle/send" id="turtle_send_dist_form">
			<fieldset role="group">
				<input type="text" name="distance" value="190 mm" />
				<input type="submit" value="Avancer (mm)" />
			</fieldset>
		</form>
	</p>
	<p>
		<form method="POST" action="/turtle/send" id="turtle_send_ang_form">
			<fieldset role="group">
				<input type="text" name="angle" value="90°" />
				<input type="submit" value="Tourner (°)"/>
			</fieldset>
		</form>
	</p>
	<p>
		<form method="POST" action="/turtle/stop" id="turtle_stop_form">
				<input type="submit" value="Stop" />
		</form>
	</p>
`);

const dist_form = document.forms["turtle_send_dist_form"];
dist_form.addEventListener('submit', async e => {
	e.preventDefault();
	const form = dist_form;
	const d = parseInt(form.elements.namedItem('distance').value);
	form.elements.namedItem('distance').value = d + ' mm';
	const data = {
		'type': 'dist',
		'dist': d,
	}
	await fetch(form.action, {
    method: "POST",
    headers: { "Content-Type": "application/json", },
    body: JSON.stringify(data),
  });
});

const ang_form = document.forms["turtle_send_ang_form"];
ang_form.addEventListener('submit', async e => {
	e.preventDefault();
	const form = ang_form;
	const a = parseInt(form.elements.namedItem('angle').value);
	form.elements.namedItem('angle').value = a + '°';
	const data = {
		'type': 'angle',
		'angle': a,
	}
	await fetch(form.action, {
    method: "POST",
    headers: { "Content-Type": "application/json", },
    body: JSON.stringify(data),
  });
});

const stop_form = document.forms['turtle_stop_form'];
stop_form.addEventListener('submit', async e => {
	e.preventDefault();
	await fetch(stop_form.action);
});
