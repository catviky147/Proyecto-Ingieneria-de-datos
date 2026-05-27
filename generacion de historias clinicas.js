// ============================================================
// SCRIPT: generar_historias.js
// PROPÓSITO: Generar una historia clínica por cada paciente
// USO: mongosh clinicaodontologica generar_historias.js
// ============================================================

use("clinicaodontologica");

// Obtener todos los pacientes
const pacientes = db.pacientes.find().toArray();
print(`📋 Encontrados ${pacientes.length} pacientes en la base de datos.`);

// Obtener odontólogos disponibles para asignar a evoluciones
const odontologos = db.odontologos.find().toArray();
const odontologosIds = odontologos.map(o => o._id);

if (odontologosIds.length === 0) {
  print("❌ ERROR: No hay odontólogos registrados. Primero inserta los odontólogos.");
  quit();
}

print(`👨‍⚕️ Odontólogos disponibles: ${odontologosIds.length}`);

// Función para obtener fecha aleatoria entre dos fechas
function fechaAleatoria(inicio, fin) {
  return new Date(inicio.getTime() + Math.random() * (fin.getTime() - inicio.getTime()));
}

// Función para obtener elemento aleatorio de un array
function aleatorio(array) {
  return array[Math.floor(Math.random() * array.length)];
}

// Función para generar número aleatorio en rango
function rand(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

// Lista de motivos de consulta
const motivosConsulta = [
  "Dolor dental", "Revisión de rutina", "Sangrado de encías", 
  "Dientes sensibles", "Consulta por ortodoncia", "Extracción dental",
  "Control de caries", "Limpieza dental", "Fractura dental", "Mal aliento"
];

// Lista de diagnósticos CIE
const diagnosticosCIE = [
  { codigo: "K02.1", descripcion: "Caries dental complicada" },
  { codigo: "K04.0", descripcion: "Pulpitis irreversible" },
  { codigo: "K05.3", descripcion: "Periodontitis crónica" },
  { codigo: "K01.0", descripcion: "Diente incluido" },
  { codigo: "K00.6", descripcion: "Maloclusión dental" },
  { codigo: "K08.3", descripcion: "Raíz dental retenida" },
  { codigo: "K03.1", descripcion: "Abrasión dental" },
  { codigo: "K02.5", descripcion: "Caries en dentina" }
];

// Lista de tratamientos
const tratamientos = [
  "Limpieza profunda", "Extracción dental", "Tratamiento de conducto",
  "Ortodoncia con brackets", "Blanqueamiento dental", "Corona dental",
  "Resina compuesta", "Injerto óseo", "Implante dental", "Periodoncia"
];

// Función para generar signos vitales según preexistencias
function generarSignosVitales(preexistencias) {
  let presionBase = 120;
  let glucosaBase = 90;
  
  if (preexistencias && preexistencias.toLowerCase().includes("hipertensión")) {
    presionBase = 135;
  }
  if (preexistencias && preexistencias.toLowerCase().includes("diabetes")) {
    glucosaBase = 145;
  }
  
  const sistolica = presionBase + rand(-10, 15);
  const diastolica = 70 + rand(-10, 15);
  
  return {
    presionArterial: `${sistolica}/${diastolica}`,
    frecuenciaCardiaca: 60 + rand(-5, 25),
    frecuenciaRespiratoria: 14 + rand(-2, 6),
    temperatura: Math.round((36 + Math.random() * 2) * 10) / 10,
    peso: Math.round((55 + Math.random() * 40) * 100) / 100,
    talla: Math.round((1.55 + Math.random() * 0.25) * 100) / 100,
    imc: 0,
    glucemia: glucosaBase + rand(-15, 40),
    fechaRegistro: fechaAleatoria(new Date("2023-01-01"), new Date())
  };
}

// Función para generar hábitos de higiene
function generarHabitos() {
  return {
    frecuenciaCepillado: aleatorio(["3 veces al día", "2 veces al día", "1 vez al día", "Ocasional"]),
    usaHiloDental: Math.random() > 0.5,
    usaEnjuague: Math.random() > 0.6,
    visitaDentistaPeriodica: Math.random() > 0.5,
    consumoTabaco: Math.random() > 0.85,
    consumoAlcohol: Math.random() > 0.7,
    observaciones: "Se recomienda mejorar frecuencia de cepillado y uso de hilo dental.",
    fechaRegistro: fechaAleatoria(new Date("2023-01-01"), new Date())
  };
}

// Función para generar medicamentos según preexistencias
function generarMedicamentos(preexistencias) {
  const medicamentos = [];
  
  if (preexistencias && preexistencias.toLowerCase().includes("hipertensión")) {
    medicamentos.push({
      nombreMedicamento: aleatorio(["Losartán", "Enalapril", "Amlodipino"]),
      principioActivo: aleatorio(["Losartán potásico", "Enalapril maleato", "Amlodipino besilato"]),
      dosis: aleatorio(["50 mg", "10 mg", "5 mg"]),
      frecuencia: aleatorio(["Una vez al día", "Cada 12 horas"]),
      viaAdministracion: "Oral",
      motivoUso: "Control de hipertensión arterial",
      fechaInicio: fechaAleatoria(new Date("2018-01-01"), new Date("2022-01-01")),
      fechaFin: null
    });
  }
  
  if (preexistencias && preexistencias.toLowerCase().includes("diabetes")) {
    medicamentos.push({
      nombreMedicamento: aleatorio(["Metformina", "Glibenclamida"]),
      principioActivo: aleatorio(["Metformina HCl", "Glibenclamida"]),
      dosis: aleatorio(["850 mg", "500 mg", "5 mg"]),
      frecuencia: aleatorio(["Cada 12 horas", "Una vez al día"]),
      viaAdministracion: "Oral",
      motivoUso: "Control glucémico",
      fechaInicio: fechaAleatoria(new Date("2015-01-01"), new Date("2021-01-01")),
      fechaFin: null
    });
  }
  
  if (Math.random() < 0.2 && medicamentos.length < 2) {
    medicamentos.push({
      nombreMedicamento: aleatorio(["Ibuprofeno", "Acetaminofén", "Amoxicilina"]),
      principioActivo: aleatorio(["Ibuprofeno", "Paracetamol", "Amoxicilina trihidrato"]),
      dosis: aleatorio(["400 mg", "500 mg", "100 mg"]),
      frecuencia: aleatorio(["Cada 8 horas", "Según necesidad"]),
      viaAdministracion: "Oral",
      motivoUso: aleatorio(["Alivio del dolor", "Tratamiento antibiótico"]),
      fechaInicio: fechaAleatoria(new Date("2023-01-01"), new Date()),
      fechaFin: Math.random() > 0.7 ? fechaAleatoria(new Date(), new Date("2025-01-01")) : null
    });
  }
  
  return medicamentos;
}

// Función para generar anamnesis
function generarAnamnesis(paciente) {
  const edad = new Date().getFullYear() - paciente.fechaNacPaciente.getFullYear();
  let antecedentesFamiliares = "Sin antecedentes familiares relevantes.";
  
  if (Math.random() > 0.5) {
    antecedentesFamiliares = aleatorio([
      "Madre con hipertensión, padre con diabetes.",
      "Abuelos con problemas cardiovasculares.",
      "Hermano con periodontitis severa.",
      "Madre con osteoporosis."
    ]);
  }
  
  return [{
    motivoConsulta: aleatorio(motivosConsulta),
    enfermedadActual: `Paciente refiere ${aleatorio([
      "dolor intermitente", "sensibilidad al frío", "inflamación", "molestia general"
    ])} en región ${aleatorio(["maxilar izquierda", "mandibular derecha", "anterior", "posterior"])}.`,
    antecedentesPersonales: paciente.preexistencias || "Ninguna enfermedad sistémica relevante.",
    antecedentesFamiliares: antecedentesFamiliares,
    revisionSistemas: aleatorio([
      "Sin alteraciones sistémicas.", "Paciente refiere fatiga ocasional.", 
      "Sin hallazgos relevantes.", "Funcionalmente normal."
    ]),
    fechaRegistro: fechaAleatoria(new Date(paciente.fechaNacPaciente), new Date())
  }];
}

// Función para generar planes de tratamiento
function generarPlanes(paciente, tieneDiagnostico) {
  const planes = [];
  const numPlanes = tieneDiagnostico ? rand(1, 2) : 1;
  
  for (let i = 0; i < numPlanes; i++) {
    const presupuesto = rand(150000, 3500000);
    planes.push({
      descripcion: aleatorio(tratamientos),
      presupuesto: presupuesto,
      saldoPendiente: Math.random() > 0.7 ? 0 : rand(50000, presupuesto),
      fechaInicio: fechaAleatoria(new Date("2023-01-01"), new Date()),
      fechaFin: Math.random() > 0.5 ? fechaAleatoria(new Date(), new Date("2025-12-31")) : null,
      estado: aleatorio(["Activo", "Completado", "En progreso", "Pendiente"])
    });
  }
  
  return planes;
}

// Función para generar consentimientos
function generarConsentimientos(planes) {
  if (planes.length === 0 || Math.random() > 0.7) return [];
  
  return planes.map(plan => ({
    procedimiento: plan.descripcion,
    fechaFirma: fechaAleatoria(new Date("2023-01-01"), new Date()),
    firmaPaciente: Math.random() > 0.2 ? "Firmado" : "Pendiente",
    firmaProfesional: Math.random() > 0.1 ? "Firmado" : "Pendiente",
    observaciones: "Paciente informado sobre procedimiento y riesgos."
  }));
}

// Función para generar evoluciones
function generarEvoluciones(paciente, planes, odontologosIds) {
  const numEvoluciones = rand(1, 3);
  const evoluciones = [];
  
  for (let i = 0; i < numEvoluciones; i++) {
    evoluciones.push({
      odontologoId: aleatorio(odontologosIds),
      fechaSesion: fechaAleatoria(new Date("2023-06-01"), new Date()),
      estadoActual: aleatorio([
        "Evolución favorable, paciente asintomático.",
        "Mejoría significativa en síntomas.",
        "Paciente estable, continúa tratamiento.",
        "Leve molestia post-operatoria controlada con analgésicos.",
        "Excelente respuesta al tratamiento."
      ]),
      consultaAnterior: aleatorio([
        "Paciente presentaba dolor moderado.", "Revisión de rutina sin hallazgos.",
        "Procedimiento realizado sin complicaciones.", "Paciente refiere mejoría."
      ]),
      cambiosTratamiento: Math.random() > 0.7 ? "Se ajusta medicación." : "Se mantiene plan actual.",
      respuestaPaciente: aleatorio(["Buena", "Excelente", "Aceptable"]),
      huboRemision: Math.random() > 0.9,
      huboInterconsulta: Math.random() > 0.95,
      cambioProfesional: Math.random() > 0.98,
      observaciones: "Seguimiento regular, próxima cita en 3 meses."
    });
  }
  
  return evoluciones;
}

// Función para generar examen dental
function generarExamenDental() {
  return [{
    hallazgos: aleatorio([
      "Caries interproximales en múltiples piezas.",
      "Cálculo dental generalizado, encías con inflamación.",
      "Pérdida de soporte óseo leve en sector posterior.",
      "Apiñamiento dental, mordida profunda.",
      "Diente 2.5 con fractura coronaria."
    ]),
    odontograma: `https://storage.clinica.com/odontogramas/paciente_${Math.floor(Math.random() * 100) + 1}.png`,
    fechaRegistro: fechaAleatoria(new Date("2023-01-01"), new Date())
  }];
}

// Función para generar ayuda diagnóstica
function generarAyudaDiagnostica() {
  if (Math.random() > 0.4) return [];
  const diag = aleatorio(diagnosticosCIE);
  return [{
    codigoCIE: diag.codigo,
    descripcionDiagnostico: diag.descripcion,
    pronostico: aleatorio(["Bueno", "Reservado", "Malo"]),
    rutaArchivo: `https://storage.clinica.com/rx/paciente_${Math.floor(Math.random() * 100) + 1}_${new Date().getFullYear()}.jpg`,
    tipoArchivo: "image/jpeg",
    fechaRegistro: fechaAleatoria(new Date("2023-01-01"), new Date())
  }];
}

// Array para almacenar las historias clínicas a insertar
const historias = [];
let contadorErrores = 0;
let contadorExitos = 0;

// Generar una historia clínica por cada paciente
for (const paciente of pacientes) {
  try {
    const signosVitales = generarSignosVitales(paciente.preexistencias);
    // Calcular IMC correctamente
    if (signosVitales.peso && signosVitales.talla && signosVitales.talla > 0) {
      signosVitales.imc = Math.round((signosVitales.peso / (signosVitales.talla * signosVitales.talla)) * 10) / 10;
    }
    
    const ayudaDiagnostica = generarAyudaDiagnostica();
    const planes = generarPlanes(paciente, ayudaDiagnostica.length > 0);
    const evoluciones = generarEvoluciones(paciente, planes, odontologosIds);
    
    const historia = {
      pacienteId: paciente._id,
      fechaApertura: fechaAleatoria(new Date("2022-01-01"), new Date()),
      estado: aleatorio(["Activa", "En tratamiento", "Completa", "Inactiva"]),
      observaciones: `${paciente.nombrePaciente.split(' ')[0]}, ${paciente.preexistencias ? "con " + paciente.preexistencias + "." : "sin comorbilidades significativas."} Se recomienda control periódico.`,
      anamnesis: generarAnamnesis(paciente),
      signosVitales: [signosVitales],
      habitosHigiene: [generarHabitos()],
      medicamentos: generarMedicamentos(paciente.preexistencias),
      ayudaDiagnostica: ayudaDiagnostica,
      planesTratamiento: planes,
      consentimientos: generarConsentimientos(planes),
      examenesDentales: generarExamenDental(),
      evoluciones: evoluciones
    };
    
    historias.push(historia);
    contadorExitos++;
    
  } catch (error) {
    print(`⚠️ Error procesando paciente ${paciente.nombrePaciente}: ${error.message}`);
    contadorErrores++;
  }
}

// Insertar todas las historias clínicas
if (historias.length > 0) {
  try {
    const resultado = db.historiasClinicas.insertMany(historias);
    print(`\n✅ ÉXITO: Se insertaron ${resultado.insertedIds.length} historias clínicas.`);
  } catch (error) {
    print(`\n❌ ERROR al insertar: ${error.message}`);
  }
} else {
  print("\n❌ No se generó ninguna historia clínica.");
}

// Verificar resultados finales
const totalHistorias = db.historiasClinicas.countDocuments();
print(`\n📊 RESUMEN FINAL:`);
print(`   - Pacientes procesados: ${pacientes.length}`);
print(`   - Historias exitosas: ${contadorExitos}`);
print(`   - Errores: ${contadorErrores}`);
print(`   - Total en colección: ${totalHistorias}`);

if (totalHistorias === pacientes.length) {
  print(`\n🎉 COMPLETADO: Cada paciente tiene su historia clínica.`);
} else {
  print(`\n⚠️ ADVERTENCIA: Faltan ${pacientes.length - totalHistorias} historias clínicas.`);
}

print(`\n🔍 Para verificar, ejecuta: db.historiasClinicas.find().pretty()`);