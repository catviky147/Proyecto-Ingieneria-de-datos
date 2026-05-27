const API = '';  // mismo origen

// ══════════════════════════════════════════
// NAVEGACIÓN
// ══════════════════════════════════════════
function showSection(name) {
  document.querySelectorAll('.section').forEach(s => s.classList.remove('active'));
  document.querySelectorAll('.nav-btn').forEach(b => b.classList.remove('active'));
  document.getElementById(`sec-${name}`).classList.add('active');
  document.querySelector(`[onclick="showSection('${name}')"]`).classList.add('active');

  if (name === 'pacientes')   cargarPacientes();
  if (name === 'citas')       cargarCitas();
  if (name === 'pagos')       cargarPagos();
  if (name === 'calendario')  cargarCalendario();
}

// ══════════════════════════════════════════
// MODALES
// ══════════════════════════════════════════
function openModal(id)  { document.getElementById(id).classList.add('open'); }
function closeModal(id) { document.getElementById(id).classList.remove('open'); }
function closeOnOverlay(e, id) { if (e.target.id === id) closeModal(id); }

// ══════════════════════════════════════════
// PACIENTES
// ══════════════════════════════════════════
async function cargarPacientes(termino = '') {
  const url = termino
    ? `${API}/api/pacientes/buscar/${termino}`
    : `${API}/api/pacientes`;
  const data = await fetch(url).then(r => r.json());
  renderPacientes(data);
}

function renderPacientes(data) {
  const wrap = document.getElementById('tabla-pacientes');
  if (!data.length) { wrap.innerHTML = '<p style="padding:16px;color:#94a3b8">Sin resultados.</p>'; return; }
  wrap.innerHTML = `
    <table>
      <thead><tr>
        <th>ID</th><th>Nombre</th><th>Documento</th>
        <th>Preexistencias</th><th>Alergias</th><th>Acciones</th>
      </tr></thead>
      <tbody>
        ${data.map(p => `
          <tr>
            <td>${p.idpaciente}</td>
            <td>${p.nombrePaciente}</td>
            <td>${p.documentoPaciente}</td>
            <td>${p.Preexistencias || '—'}</td>
            <td>${p.Alergias || '—'}</td>
            <td>
              <button class="btn-icon" title="Editar" onclick="editarPaciente(${p.idpaciente},'${esc(p.nombrePaciente)}','${esc(p.direccionPaciente)}','${esc(p.Preexistencias)}','${esc(p.Alergias)}')">✏️</button>
              <button class="btn-icon" title="Historia clínica" onclick="verAnamnesis(${p.idHistoriaClinica || 0})">📋</button>
              <button class="btn-icon" title="Eliminar" onclick="eliminarPaciente(${p.idpaciente})">🗑️</button>
            </td>
          </tr>`).join('')}
      </tbody>
    </table>`;
}

let debounce;
function buscarPaciente() {
  clearTimeout(debounce);
  debounce = setTimeout(() => {
    const t = document.getElementById('buscar-paciente').value.trim();
    cargarPacientes(t);
  }, 350);
}

async function guardarPaciente() {
  const id = document.getElementById('pac-id').value;
  const body = {
    nombrePaciente:    document.getElementById('pac-nombre').value,
    documentoPaciente: document.getElementById('pac-doc').value,
    direccionPaciente: document.getElementById('pac-dir').value,
    fechaNacPaciente:  document.getElementById('pac-fecha').value,
    Preexistencias:    document.getElementById('pac-pre').value,
    Alergias:          document.getElementById('pac-aler').value
  };
  if (id) {
    await fetch(`${API}/api/pacientes/${id}`, { method:'PUT', headers:{'Content-Type':'application/json'}, body:JSON.stringify(body) });
  } else {
    await fetch(`${API}/api/pacientes`, { method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(body) });
  }
  closeModal('modal-paciente');
  limpiarFormPaciente();
  cargarPacientes();
}

function editarPaciente(id, nombre, dir, pre, aler) {
  document.getElementById('modal-paciente-title').textContent = 'Editar paciente';
  document.getElementById('pac-id').value     = id;
  document.getElementById('pac-nombre').value = nombre;
  document.getElementById('pac-dir').value    = dir;
  document.getElementById('pac-pre').value    = pre;
  document.getElementById('pac-aler').value   = aler;
  openModal('modal-paciente');
}

async function eliminarPaciente(id) {
  if (!confirm('¿Eliminar este paciente?')) return;
  await fetch(`${API}/api/pacientes/${id}`, { method:'DELETE' });
  cargarPacientes();
}

function limpiarFormPaciente() {
  ['pac-id','pac-nombre','pac-doc','pac-dir','pac-fecha','pac-pre','pac-aler']
    .forEach(id => document.getElementById(id).value = '');
  document.getElementById('modal-paciente-title').textContent = 'Nuevo paciente';
}

// ══════════════════════════════════════════
// CITAS
// ══════════════════════════════════════════
async function cargarCitas() {
  const data = await fetch(`${API}/api/citas`).then(r => r.json());
  const wrap = document.getElementById('tabla-citas');
  if (!data.length) { wrap.innerHTML = '<p style="padding:16px;color:#94a3b8">Sin citas registradas.</p>'; return; }
  wrap.innerHTML = `
    <table>
      <thead><tr>
        <th>ID</th><th>Paciente</th><th>Odontólogo</th>
        <th>Especialidad</th><th>Fecha</th><th>Tratamiento</th><th>Estado</th><th>Acciones</th>
      </tr></thead>
      <tbody>
        ${data.map(c => `
          <tr>
            <td>${c.idCita}</td>
            <td>${c.nombrePaciente}</td>
            <td>${c.nombreOdontologo}</td>
            <td>${c.especialidad}</td>
            <td>${formatFecha(c.horario)}</td>
            <td>${c.tratamiento || '—'}</td>
            <td><span class="badge ${badgeCita(c.estado)}">${c.estado}</span></td>
            <td>
              <button class="btn-icon" title="Anamnesis" onclick="verAnamnesis(0, ${c.idCita})">📋</button>
              <button class="btn-icon" title="Eliminar"  onclick="eliminarCita(${c.idCita})">🗑️</button>
            </td>
          </tr>`).join('')}
      </tbody>
    </table>`;
}

async function guardarCita() {
  const body = {
    pacienteFK:   document.getElementById('cita-paciente').value,
    odontologoFK: document.getElementById('cita-odontologo').value,
    horario:      document.getElementById('cita-horario').value,
    tratamiento:  document.getElementById('cita-tratamiento').value
  };
  await fetch(`${API}/api/citas`, { method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(body) });
  closeModal('modal-cita');
  cargarCitas();
}

async function eliminarCita(id) {
  if (!confirm('¿Eliminar esta cita?')) return;
  await fetch(`${API}/api/citas/${id}`, { method:'DELETE' });
  cargarCitas();
}

function badgeCita(estado) {
  if (estado === 'Completada') return 'badge-green';
  if (estado === 'Cancelada')  return 'badge-red';
  return 'badge-yellow';
}

// ══════════════════════════════════════════
// PAGOS
// ══════════════════════════════════════════
async function cargarPagos() {
  const [pagos, resumen] = await Promise.all([
    fetch(`${API}/api/pagos`).then(r => r.json()),
    fetch(`${API}/api/pagos/resumen`).then(r => r.json())
  ]);

  // cards resumen
  document.getElementById('resumen-pagos').innerHTML =
    resumen.map(r => `
      <div class="card">
        <div class="card-label">${r.metodoPago}</div>
        <div class="card-value">$${Number(r.total).toLocaleString('es-CO')}</div>
      </div>`).join('');

  // tabla
  const wrap = document.getElementById('tabla-pagos');
  wrap.innerHTML = `
    <table>
      <thead><tr><th>ID</th><th>Fecha</th><th>Monto</th><th>Método</th><th>Estado</th></tr></thead>
      <tbody>
        ${pagos.map(p => `
          <tr>
            <td>${p.idPago}</td>
            <td>${p.fecha}</td>
            <td>$${Number(p.monto).toLocaleString('es-CO')}</td>
            <td>${p.metodoPago}</td>
            <td><span class="badge ${p.estado==='Pagado'?'badge-green':'badge-yellow'}">${p.estado}</span></td>
          </tr>`).join('')}
      </tbody>
    </table>`;
}

async function guardarPago() {
  const body = {
    fecha:      document.getElementById('pago-fecha').value,
    monto:      document.getElementById('pago-monto').value,
    metodoPago: document.getElementById('pago-metodo').value,
    estado:     document.getElementById('pago-estado').value
  };
  await fetch(`${API}/api/pagos`, { method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(body) });
  closeModal('modal-pago');
  cargarPagos();
}

// ══════════════════════════════════════════
// CALENDARIO
// ══════════════════════════════════════════
async function cargarCalendario() {
  const citas = await fetch(`${API}/api/citas/calendario`).then(r => r.json());
  const hoy   = new Date();
  const anio  = hoy.getFullYear();
  const mes   = hoy.getMonth();
  const diasEnMes   = new Date(anio, mes + 1, 0).getDate();
  const primerDia   = new Date(anio, mes, 1).getDay();

  // agrupar citas por día
  const citasPorDia = {};
  citas.forEach(c => {
    const d = new Date(c.horario).getDate();
    if (!citasPorDia[d]) citasPorDia[d] = [];
    citasPorDia[d].push(c);
  });

  const dias = ['Dom','Lun','Mar','Mié','Jue','Vie','Sáb'];
  let html = `<div class="cal-header">${dias.map(d=>`<div class="cal-day-name">${d}</div>`).join('')}</div>`;

  // celdas vacías al inicio
  for (let i = 0; i < primerDia; i++) html += `<div class="cal-cell empty"></div>`;

  for (let d = 1; d <= diasEnMes; d++) {
    const esHoy = d === hoy.getDate();
    const eventos = (citasPorDia[d] || []).map(c =>
      `<div class="cal-event" title="${c.nombrePaciente} - ${c.tratamiento}">
        ${c.horario.slice(11,16)} ${c.nombrePaciente.split(' ')[0]}
      </div>`
    ).join('');
    html += `
      <div class="cal-cell ${esHoy ? 'today' : ''}">
        <div class="cal-num">${d}</div>
        ${eventos}
      </div>`;
  }

  document.getElementById('calendario').innerHTML = html;
}

// ══════════════════════════════════════════
// ANAMNESIS
// ══════════════════════════════════════════
async function verAnamnesis(historiaClinicaFK) {
  if (!historiaClinicaFK) {
    alert('Este paciente aún no tiene historia clínica asignada.');
    return;
  }
  document.getElementById('ana-historiaFK').value = historiaClinicaFK;
  const data = await fetch(`${API}/api/anamnesis/${historiaClinicaFK}`).then(r => r.json());

  document.getElementById('ana-motivo').value      = data.motivoConsulta || '';
  document.getElementById('ana-enfermedad').value  = data.enfermedadActual || '';
  document.getElementById('ana-antPersonal').value = data.antecedentesPersonales || '';
  document.getElementById('ana-antFamiliar').value = data.antecedentesFamiliares || '';

  const sv = data.signosVitales || {};
  document.getElementById('ana-presion').value   = sv.presionArterial || '';
  document.getElementById('ana-fc').value        = sv.frecuenciaCardiaca || '';
  document.getElementById('ana-temp').value      = sv.temperatura || '';
  document.getElementById('ana-peso').value      = sv.peso || '';
  document.getElementById('ana-talla').value     = sv.talla || '';
  document.getElementById('ana-glucemia').value  = sv.glucemia || '';

  const hh = data.habitosHigiene || {};
  document.getElementById('ana-cepillado').value    = hh.frecuenciaCepillado || '';
  document.getElementById('ana-hilo').checked        = !!hh.usaHiloDental;
  document.getElementById('ana-enjuague').checked    = !!hh.usaEnjuague;
  document.getElementById('ana-tabaco').checked      = !!hh.consumoTabaco;
  document.getElementById('ana-alcohol').checked     = !!hh.consumoAlcohol;
  document.getElementById('ana-habObs').value        = hh.observaciones || '';

  openModal('modal-anamnesis');
}

async function guardarAnamnesis() {
  const hFK = document.getElementById('ana-historiaFK').value;
  const body = {
    historiaClinicaFK: Number(hFK),
    motivoConsulta:         document.getElementById('ana-motivo').value,
    enfermedadActual:       document.getElementById('ana-enfermedad').value,
    antecedentesPersonales: document.getElementById('ana-antPersonal').value,
    antecedentesFamiliares: document.getElementById('ana-antFamiliar').value,
    signosVitales: {
      presionArterial:    document.getElementById('ana-presion').value,
      frecuenciaCardiaca: Number(document.getElementById('ana-fc').value),
      temperatura:        Number(document.getElementById('ana-temp').value),
      peso:               Number(document.getElementById('ana-peso').value),
      talla:              Number(document.getElementById('ana-talla').value),
      glucemia:           Number(document.getElementById('ana-glucemia').value)
    },
    habitosHigiene: {
      frecuenciaCepillado: document.getElementById('ana-cepillado').value,
      usaHiloDental:       document.getElementById('ana-hilo').checked,
      usaEnjuague:         document.getElementById('ana-enjuague').checked,
      consumoTabaco:       document.getElementById('ana-tabaco').checked,
      consumoAlcohol:      document.getElementById('ana-alcohol').checked,
      observaciones:       document.getElementById('ana-habObs').value
    }
  };
  await fetch(`${API}/api/anamnesis`, { method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(body) });
  closeModal('modal-anamnesis');
  alert('Anamnesis guardada correctamente ✅');
}

// ══════════════════════════════════════════
// UTILS
// ══════════════════════════════════════════
function formatFecha(str) {
  if (!str) return '—';
  return new Date(str).toLocaleString('es-CO', { dateStyle:'short', timeStyle:'short' });
}
function esc(str) { return (str || '').replace(/'/g, "\\'"); }

// Carga inicial
cargarPacientes();
