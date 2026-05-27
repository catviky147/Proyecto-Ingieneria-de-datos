// ============================================================
// SCRIPT: generar_citas.js
// PROPÓSITO: Generar citas odontológicas para todos los pacientes
// USO: mongosh clinicaodontologica generar_citas.js
// ============================================================

use("clinicaodontologica");

// Obtener datos necesarios
const pacientes = db.pacientes.find().toArray();
const odontologos = db.odontologos.find().toArray();
const pagos = db.pagos.find().toArray();

print(`📋 Pacientes: ${pacientes.length}`);
print(`👨‍⚕️ Odontólogos: ${odontologos.length}`);
print(`💰 Pagos disponibles: ${pagos.length}`);

// Funciones auxiliares
function rand(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function aleatorio(array) {
  return array[Math.floor(Math.random() * array.length)];
}

function fechaAleatoria() {
  const start = new Date("2023-01-01");
  const end = new Date("2025-12-31");
  return new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));
}

// Listas de opciones
const tratamientos = [
  "Consulta general", "Ortodoncia", "Endodoncia", "Periodoncia",
  "Cirugía oral", "Profilaxis", "Extracción dental", "Tratamiento de conducto",
  "Blanqueamiento", "Corona dental", "Implante dental", "Urgencia"
];

const estados = ["Pendiente", "Confirmada Asistida", "Confirmada No Asistida", "Cancelada", "Reprogramada"];

// Array para almacenar citas
const citas = [];

// Generar citas
for (const paciente of pacientes) {
  // Número variable de citas por paciente (entre 1 y 5)
  const numCitas = rand(1, 5);
  
  for (let i = 0; i < numCitas; i++) {
    // Asignar pago aleatorio (a veces null si no tiene pago)
    let pagoId = null;
    const pagosPaciente = pagos.filter(p => p.pacienteId.toString() === paciente._id.toString());
    if (pagosPaciente.length > 0 && Math.random() > 0.3) {
      pagoId = aleatorio(pagosPaciente)._id;
    }
    
    const fecha = fechaAleatoria();
    const estado = aleatorio(estados);
    
    // Si la cita ya pasó y está confirmada, se marca como asistida o no asistida
    let estadoFinal = estado;
    if (fecha < new Date() && estado === "Pendiente") {
      estadoFinal = Math.random() > 0.3 ? "Confirmada Asistida" : "Confirmada No Asistida";
    }
    
    citas.push({
      odontologoId: aleatorio(odontologos)._id,
      pacienteId: paciente._id,
      pagoId: pagoId,
      horario: fecha,
      tratamiento: aleatorio(tratamientos),
      estado: estadoFinal,
      duracionMinutos: rand(30, 90),
      notas: `Cita programada para ${paciente.nombrePaciente} - ${aleatorio(tratamientos)}`
    });
  }
}

// Asegurar al menos 200 citas
while (citas.length < 200) {
  const paciente = aleatorio(pacientes);
  citas.push({
    odontologoId: aleatorio(odontologos)._id,
    pacienteId: paciente._id,
    pagoId: null,
    horario: fechaAleatoria(),
    tratamiento: aleatorio(tratamientos),
    estado: aleatorio(estados),
    duracionMinutos: rand(30, 90),
    notas: `Cita adicional programada`
  });
}

print(`📅 Generadas ${citas.length} citas`);

// Insertar en la base de datos
if (citas.length > 0) {
  try {
    // Limpiar citas existentes (opcional)
    // db.citasOdontologicas.deleteMany({});
    
    const resultado = db.citasOdontologicas.insertMany(citas);
    print(`✅ Insertadas ${resultado.insertedIds.length} citas correctamente`);
  } catch (error) {
    print(`❌ Error: ${error.message}`);
  }
}

// Resumen de citas
print("\n📊 RESUMEN DE CITAS:");
const resumen = db.citasOdontologicas.aggregate([
  { $group: { _id: "$estado", cantidad: { $sum: 1 } } },
  { $sort: { cantidad: -1 } }
]).toArray();

resumen.forEach(r => {
  print(`   ${r._id}: ${r.cantidad} citas`);
});

// Próximas citas
const proximas = db.citasOdontologicas.find({
  horario: { $gte: new Date() },
  estado: "Pendiente"
}).count();

print(`\n📅 Próximas citas pendientes: ${proximas}`);