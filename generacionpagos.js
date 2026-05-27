// ============================================================
// SCRIPT: generar_pagos.js
// PROPÓSITO: Generar pagos para todos los pacientes
// USO: mongosh clinicaodontologica generar_pagos.js
// ============================================================

use("clinicaodontologica");

// Obtener todos los pacientes
const pacientes = db.pacientes.find().toArray();
print(`📋 Encontrados ${pacientes.length} pacientes`);

// Función para fecha aleatoria en el último año
function fechaAleatoria() {
  const start = new Date("2023-01-01");
  const end = new Date();
  return new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));
}

// Funciones auxiliares
function rand(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function aleatorio(array) {
  return array[Math.floor(Math.random() * array.length)];
}

// Listas de opciones
const metodosPago = ["Efectivo", "Tarjeta Débito", "Tarjeta Crédito", "Transferencia", "Nequi", "Daviplata"];
const estadosPago = ["Pagado", "Pendiente", "Anulado", "Rechazado"];
const conceptos = [
  "Consulta inicial", "Control mensual", "Limpieza dental", "Extracción simple",
  "Tratamiento de conducto", "Ortodoncia - cuota", "Blanqueamiento dental",
  "Corona dental", "Resina compuesta", "Periodoncia", "Cirugía oral",
  "Radiografía panorámica", "Aplicación de flúor", "Sellantes", "Urgencia dental"
];

// Array para almacenar pagos
const pagos = [];

// Generar pagos para cada paciente
for (const paciente of pacientes) {
  const numPagos = rand(1, 5); // Entre 1 y 5 pagos por paciente
  
  for (let i = 0; i < numPagos; i++) {
    const monto = rand(50000, 800000);
    const estado = aleatorio(estadosPago);
    
    pagos.push({
      fecha: fechaAleatoria(),
      monto: monto,
      metodoPago: aleatorio(metodosPago),
      estado: estado,
      pacienteId: paciente._id,
      concepto: aleatorio(conceptos),
      numeroFactura: `FAC-${new Date().getFullYear()}-${String(pagos.length + 1).padStart(6, '0')}`
    });
  }
}

print(`💰 Generados ${pagos.length} pagos`);

// Insertar en la base de datos
if (pagos.length > 0) {
  try {
    const resultado = db.pagos.insertMany(pagos);
    print(`✅ Insertados ${resultado.insertedIds.length} pagos correctamente`);
  } catch (error) {
    print(`❌ Error: ${error.message}`);
  }
}

// Resumen por método de pago
print("\n📊 RESUMEN DE PAGOS:");
const resumen = db.pagos.aggregate([
  { $group: { _id: "$metodoPago", total: { $sum: "$monto" }, cantidad: { $sum: 1 } } },
  { $sort: { total: -1 } }
]).toArray();

resumen.forEach(r => {
  print(`   ${r._id}: ${r.cantidad} pagos - $${r.total.toLocaleString()}`);
});

print(`\n💰 Total recaudado: $${db.pagos.aggregate([{ $group: { _id: null, total: { $sum: "$monto" } } }]).toArray()[0]?.total.toLocaleString() || 0}`);