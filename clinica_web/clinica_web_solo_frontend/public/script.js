// ============================================
// DATOS DE EJEMPLO
// ============================================
let currentUser = null;
let currentRole = 'usuario';
let currentDate = new Date();
let selectedDate = new Date();

let pacientes = [
    { id: 1, nombre: "Ana María Rodríguez", documento: 12345678, direccion: "Calle 123", telefono: "3111234567", fechaNacimiento: "1990-05-15", alergias: "Ninguna", preexistencias: "Ninguna" },
    { id: 2, nombre: "Carlos López Méndez", documento: 87654321, direccion: "Carrera 45 #23-12", telefono: "3227654321", fechaNacimiento: "1985-08-22", alergias: "Penicilina", preexistencias: "Hipertensión" }
];

let citas = [
    { id: 1, pacienteId: 1, pacienteNombre: "Ana María Rodríguez", fecha: "2026-05-26T09:00", tratamiento: "Limpieza dental", observaciones: "Paciente nueva", estado: "pendiente", pagoRegistrado: false },
    { id: 2, pacienteId: 2, pacienteNombre: "Carlos López Méndez", fecha: "2026-05-26T11:30", tratamiento: "Extracción", observaciones: "", estado: "confirmada", pagoRegistrado: false }
];

let pagos = [
    { id: 1, citaId: 1, pacienteNombre: "Ana María Rodríguez", fecha: "2026-05-20", monto: 150000, metodo: "Efectivo", estado: "Completado" }
];

let nextId = { paciente: 3, cita: 3, pago: 2 };

// ============================================
// INICIALIZACIÓN
// ============================================
function init() {
    // Obtener usuario de sesión
    const userData = localStorage.getItem('user');
    if (!userData) {
        window.location.href = '/';
        return;
    }
    
    currentUser = JSON.parse(userData);
    currentRole = currentUser.rol;
    
    // Mostrar perfil
    document.getElementById('userProfile').innerHTML = `
        <div class="user-name">${currentUser.nombre}</div>
        <div class="user-role"><span class="role-badge">${currentUser.rol === 'odontologo' ? '👨‍⚕️ Odontólogo' : '👤 Usuario'}</span></div>
    `;
    document.getElementById('userInfo').innerHTML = `<span>${currentUser.nombre}</span><i class="fas fa-user-circle"></i>`;
    
    // Mostrar/ocultar botones según rol
    if (currentRole === 'odontologo') {
        document.getElementById('btnNuevoPaciente').style.display = 'block';
        document.getElementById('btnNuevaCita').style.display = 'block';
        document.getElementById('thAccionPago').style.display = 'table-cell';
    }
    
    // Cargar datos
    cargarPacientes();
    cargarCitas();
    cargarPagos();
    actualizarSelects();
    renderCalendar();
    
    // Eventos
    document.getElementById('filterNombre').addEventListener('input', filtrarPacientes);
    document.getElementById('filtroMetodoPago').addEventListener('change', filtrarPagos);
    document.getElementById('globalSearch').addEventListener('input', buscarGlobal);
    
    document.getElementById('formPaciente').addEventListener('submit', guardarPaciente);
    document.getElementById('formCita').addEventListener('submit', guardarCita);
    document.getElementById('formPago').addEventListener('submit', guardarPago);
    
    // Navegación
    document.querySelectorAll('.nav-item').forEach(item => {
        item.addEventListener('click', (e) => {
            e.preventDefault();
            document.querySelectorAll('.nav-item').forEach(nav => nav.classList.remove('active'));
            document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));
            item.classList.add('active');
            document.getElementById(item.dataset.tab).classList.add('active');
        });
    });
}

function cerrarSesion() {
    localStorage.removeItem('user');
    window.location.href = '/';
}

// ============================================
// PACIENTES
// ============================================
function cargarPacientes() {
    const container = document.getElementById('pacientesList');
    container.innerHTML = pacientes.map(p => `
        <div class="paciente-card" onclick="verDetallePaciente(${p.id})">
            <h3>${p.nombre}</h3>
            <p><strong>Documento:</strong> ${p.documento}</p>
            <p><strong>Teléfono:</strong> ${p.telefono || 'N/A'}</p>
            <p><strong>Alergias:</strong> ${p.alergias || 'Ninguna'}</p>
        </div>
    `).join('');
}

function filtrarPacientes() {
    const termino = document.getElementById('filterNombre').value.toLowerCase();
    const container = document.getElementById('pacientesList');
    const filtrados = pacientes.filter(p => p.nombre.toLowerCase().includes(termino));
    container.innerHTML = filtrados.map(p => `
        <div class="paciente-card" onclick="verDetallePaciente(${p.id})">
            <h3>${p.nombre}</h3>
            <p><strong>Documento:</strong> ${p.documento}</p>
            <p><strong>Teléfono:</strong> ${p.telefono || 'N/A'}</p>
        </div>
    `).join('');
}

function verDetallePaciente(id) {
    const p = pacientes.find(p => p.id === id);
    alert(`📋 HISTORIA CLÍNICA\n\nNombre: ${p.nombre}\nDocumento: ${p.documento}\nDirección: ${p.direccion}\nTeléfono: ${p.telefono || 'N/A'}\nFecha Nac: ${p.fechaNacimiento}\nAlergias: ${p.alergias || 'Ninguna'}\nPreexistencias: ${p.preexistencias || 'Ninguna'}`);
}

function mostrarModalPaciente() {
    if (currentRole !== 'odontologo') { alert('Solo odontólogos pueden agregar pacientes'); return; }
    document.getElementById('modalPaciente').style.display = 'block';
}

function guardarPaciente(e) {
    e.preventDefault();
    const nuevoPaciente = {
        id: nextId.paciente++,
        nombre: document.getElementById('pacNombre').value,
        documento: parseInt(document.getElementById('pacDocumento').value),
        direccion: document.getElementById('pacDireccion').value,
        telefono: document.getElementById('pacTelefono').value,
        fechaNacimiento: document.getElementById('pacFechaNac').value,
        alergias: document.getElementById('pacAlergias').value,
        preexistencias: document.getElementById('pacPreexistencias').value
    };
    pacientes.push(nuevoPaciente);
    cargarPacientes();
    actualizarSelects();
    cerrarModal('modalPaciente');
    document.getElementById('formPaciente').reset();
    alert('Paciente agregado');
}

// ============================================
// CITAS
// ============================================
function cargarCitas() {
    const container = document.getElementById('citasList');
    if (citas.length === 0) {
        container.innerHTML = '<p style="text-align:center; padding:20px;">No hay citas programadas</p>';
        return;
    }
    container.innerHTML = citas.map(c => `
        <div class="cita-item">
            <div class="cita-info">
                <h4>${c.pacienteNombre}</h4>
                <p>${new Date(c.fecha).toLocaleString()} - ${c.tratamiento}</p>
                <small>${c.observaciones || ''}</small>
            </div>
            <div class="cita-actions">
                <span class="cita-estado estado-${c.estado}">${c.estado}</span>
                ${currentRole === 'odontologo' && !c.pagoRegistrado ? `<button class="btn-secondary" onclick="registrarPagoCita(${c.id}, '${c.pacienteNombre}')">💰 Pago</button>` : ''}
                ${currentRole === 'odontologo' ? `<button class="btn-secondary" onclick="cambiarEstadoCita(${c.id})">📝 Estado</button>` : ''}
            </div>
        </div>
    `).join('');
}

function mostrarModalCita() {
    if (currentRole !== 'odontologo') { alert('Solo odontólogos pueden crear citas'); return; }
    document.getElementById('modalCita').style.display = 'block';
}

function guardarCita(e) {
    e.preventDefault();
    const nuevaCita = {
        id: nextId.cita++,
        pacienteId: parseInt(document.getElementById('citaPaciente').value),
        pacienteNombre: pacientes.find(p => p.id == document.getElementById('citaPaciente').value).nombre,
        fecha: document.getElementById('citaHorario').value,
        tratamiento: document.getElementById('citaTratamiento').value,
        observaciones: document.getElementById('citaObservaciones').value,
        estado: 'pendiente',
        pagoRegistrado: false
    };
    citas.push(nuevaCita);
    cargarCitas();
    renderCalendar();
    cerrarModal('modalCita');
    document.getElementById('formCita').reset();
    alert('Cita agendada');
}

function cambiarEstadoCita(id) {
    const nuevosEstados = ['pendiente', 'confirmada', 'completada', 'cancelada'];
    const cita = citas.find(c => c.id === id);
    const idx = nuevosEstados.indexOf(cita.estado);
    cita.estado = nuevosEstados[(idx + 1) % nuevosEstados.length];
    cargarCitas();
    renderCalendar();
}

function registrarPagoCita(citaId, pacienteNombre) {
    document.getElementById('pagoCitaId').value = citaId;
    document.getElementById('pagoCitaInfo').textContent = `${pacienteNombre} - ${citas.find(c => c.id === citaId).tratamiento}`;
    document.getElementById('modalPago').style.display = 'block';
}

function guardarPago(e) {
    e.preventDefault();
    const citaId = parseInt(document.getElementById('pagoCitaId').value);
    const nuevoPago = {
        id: nextId.pago++,
        citaId: citaId,
        pacienteNombre: citas.find(c => c.id === citaId).pacienteNombre,
        fecha: new Date().toISOString().split('T')[0],
        monto: parseFloat(document.getElementById('pagoMonto').value),
        metodo: document.getElementById('pagoMetodo').value,
        estado: 'Completado'
    };
    pagos.push(nuevoPago);
    const cita = citas.find(c => c.id === citaId);
    cita.pagoRegistrado = true;
    cargarPagos();
    cargarCitas();
    cerrarModal('modalPago');
    document.getElementById('formPago').reset();
    alert('Pago registrado');
}

// ============================================
// PAGOS
// ============================================
function cargarPagos() {
    const total = pagos.reduce((sum, p) => sum + p.monto, 0);
    document.getElementById('pagosSummary').innerHTML = `
        <div class="summary-card"><h4>Total Recaudado</h4><div class="stat-number">$${total.toLocaleString()}</div></div>
        <div class="summary-card"><h4>Total Pagos</h4><div class="stat-number">${pagos.length}</div></div>
        <div class="summary-card"><h4>Citas con Pago</h4><div class="stat-number">${pagos.length}</div></div>
    `;
    mostrarTablaPagos(pagos);
}

function filtrarPagos() {
    const metodo = document.getElementById('filtroMetodoPago').value;
    const filtrados = metodo ? pagos.filter(p => p.metodo === metodo) : pagos;
    mostrarTablaPagos(filtrados);
}

function mostrarTablaPagos(pagosList) {
    const tbody = document.getElementById('pagosList');
    tbody.innerHTML = pagosList.map(p => `
        <tr>
            <td>${p.citaId}</td>
            <td>${p.fecha}</td>
            <td>${p.pacienteNombre}</td>
            <td>$${p.monto.toLocaleString()}</td>
            <td>${p.metodo}</td>
            <td>${p.estado}</td>
            ${currentRole === 'odontologo' ? '<td><button class="btn-secondary" onclick="alert(\'Editar pago no implementado\')">✏️</button></td>' : ''}
        </tr>
    `).join('');
}

// ============================================
// CALENDARIO
// ============================================
function renderCalendar() {
    const year = currentDate.getFullYear();
    const month = currentDate.getMonth();
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);
    const daysInMonth = lastDay.getDate();
    const startDay = firstDay.getDay();
    
    document.getElementById('currentMonth').textContent = `${currentDate.toLocaleString('es', { month: 'long' })} ${year}`;
    
    let html = '';
    for (let i = 0; i < startDay; i++) html += '<div></div>';
    
    for (let day = 1; day <= daysInMonth; day++) {
        const dateStr = `${year}-${String(month+1).padStart(2,'0')}-${String(day).padStart(2,'0')}`;
        const hasCita = citas.some(c => c.fecha.split('T')[0] === dateStr);
        html += `<div class="calendar-day ${hasCita ? 'has-cita' : ''}" onclick="verCitasFecha('${dateStr}')">${day}</div>`;
    }
    document.getElementById('calendarDays').innerHTML = html;
}

function cambiarMes(delta) {
    currentDate.setMonth(currentDate.getMonth() + delta);
    renderCalendar();
}

function verCitasFecha(fecha) {
    selectedDate = new Date(fecha);
    const citasFecha = citas.filter(c => c.fecha.split('T')[0] === fecha);
    const container = document.getElementById('citasDelDia');
    if (citasFecha.length === 0) {
        container.innerHTML = '<p>No hay citas para este día</p>';
    } else {
        container.innerHTML = citasFecha.map(c => `
            <div class="cita-item">
                <div><strong>${c.pacienteNombre}</strong><br>${c.tratamiento}<br>${new Date(c.fecha).toLocaleTimeString()}</div>
                <span class="cita-estado estado-${c.estado}">${c.estado}</span>
            </div>
        `).join('');
    }
}

// ============================================
// BÚSQUEDA GLOBAL
// ============================================
function buscarGlobal() {
    const termino = document.getElementById('globalSearch').value.toLowerCase();
    if (!termino) return;
    
    const pacienteEncontrado = pacientes.find(p => p.nombre.toLowerCase().includes(termino) || p.documento.toString().includes(termino));
    if (pacienteEncontrado) {
        verDetallePaciente(pacienteEncontrado.id);
    }
    
    const citaEncontrada = citas.find(c => c.pacienteNombre.toLowerCase().includes(termino));
    if (citaEncontrada) {
        alert(`Cita: ${citaEncontrada.pacienteNombre} - ${new Date(citaEncontrada.fecha).toLocaleString()}\nTratamiento: ${citaEncontrada.tratamiento}`);
    }
}

function actualizarSelects() {
    const selectPaciente = document.getElementById('citaPaciente');
    selectPaciente.innerHTML = '<option value="">Seleccionar paciente</option>' + 
        pacientes.map(p => `<option value="${p.id}">${p.nombre}</option>`).join('');
}

function cerrarModal(modalId) {
    document.getElementById(modalId).style.display = 'none';
}

// Iniciar
init();