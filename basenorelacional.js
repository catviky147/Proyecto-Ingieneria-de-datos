// ============================================================
// BASE DE DATOS: clinicaodontologica (MongoDB)
// VERSIÓN: Paciente independiente (sin usuarioId)
// ============================================================
use("clinicaodontologica");

// Limpiar colecciones
db.usuarios.drop();
db.odontologos.drop();
db.auxiliares.drop();
db.pacientes.drop();
db.historiasClinicas.drop();
db.citasOdontologicas.drop();
db.pagos.drop();
// Auditoría
db.usuarios_auditoria.drop();
db.odontologos_auditoria.drop();
db.auxiliares_auditoria.drop();
db.pacientes_auditoria.drop();
db.historiasClinicas_auditoria.drop();
db.citasOdontologicas_auditoria.drop();
db.pagos_auditoria.drop();

// ------------------------------------------------------------
// 1.1 usuarios (SOLO personal: Odontologo, Auxiliar, Admin, Inactivo)
// ------------------------------------------------------------
db.createCollection("usuarios", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["nombreUsuario", "contrasena", "rol"],
      properties: {
        nombreUsuario:     { bsonType: "string" },
        telefono:          { bsonType: "string" },
        correoElectronico: { bsonType: "string" },
        tipoDocumento:     { bsonType: "string" },
        userName:          { bsonType: "string" },
        contrasena:        { bsonType: "string" },
        rol: {
          bsonType: "string",
          enum: ["Odontologo", "Auxiliar", "Admin", "Inactivo"]
        }
      }
    }
  }
});
db.usuarios.createIndex({ userName: 1 }, { unique: true });

// ------------------------------------------------------------
// 1.2 odontologos
// ------------------------------------------------------------
db.createCollection("odontologos", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["usuarioId", "especialidad"],
      properties: {
        usuarioId:         { bsonType: "objectId" },
        tarjetaProfesional: { bsonType: "string" },
        especialidad:      { bsonType: "string" }
      }
    }
  }
});
db.odontologos.createIndex({ usuarioId: 1 });

// ------------------------------------------------------------
// 1.3 auxiliares
// ------------------------------------------------------------
db.createCollection("auxiliares", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["usuarioId"],
      properties: {
        usuarioId:            { bsonType: "objectId" },
        tarjetaProfesionalAux: { bsonType: "string" }
      }
    }
  }
});
db.auxiliares.createIndex({ usuarioId: 1 });

// ------------------------------------------------------------
// 1.4 pacientes (completamente independientes)
// ------------------------------------------------------------
db.createCollection("pacientes", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["nombrePaciente", "documentoPaciente", "direccionPaciente", "fechaNacPaciente"],
      properties: {
        nombrePaciente:    { bsonType: "string" },
        tipoDocumento:     { bsonType: "string" },
        documentoPaciente: { bsonType: "string" },
        telefono:          { bsonType: "string" },
        correoElectronico: { bsonType: "string" },
        direccionPaciente: { bsonType: "string" },
        fechaNacPaciente:  { bsonType: "date" },
        preexistencias:    { bsonType: "string" },
        alergias:          { bsonType: "string" }
      }
    }
  }
});
db.pacientes.createIndex({ documentoPaciente: 1 }, { unique: true });
db.pacientes.createIndex({ nombrePaciente: 1 });
db.pacientes.createIndex({ telefono: 1 });

// ------------------------------------------------------------
// 1.5 historiasClinicas (con subdocumentos embebidos)
// ------------------------------------------------------------
db.createCollection("historiasClinicas", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["pacienteId", "fechaApertura"],
      properties: {
        pacienteId:   { bsonType: "objectId" },
        fechaApertura: { bsonType: "date" },
        estado:       { bsonType: "string" },
        observaciones: { bsonType: "string" },
        anamnesis: { bsonType: "array" },
        signosVitales: { bsonType: "array" },
        habitosHigiene: { bsonType: "array" },
        medicamentos: { bsonType: "array" },
        ayudaDiagnostica: { bsonType: "array" },
        planesTratamiento: { bsonType: "array" },
        consentimientos: { bsonType: "array" },
        examenesDentales: { bsonType: "array" },
        evoluciones: { bsonType: "array" }
      }
    }
  }
});
db.historiasClinicas.createIndex({ pacienteId: 1 });

// ------------------------------------------------------------
// 1.6 pagos
// ------------------------------------------------------------
db.createCollection("pagos", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["fecha", "monto", "metodoPago", "pacienteId"],
      properties: {
        fecha:      { bsonType: "date" },
        monto:      { bsonType: "double" },
        metodoPago: { bsonType: "string" },
        estado:     { bsonType: "string", enum: ["Pendiente","Pagado","Anulado","Rechazado"] },
        pacienteId: { bsonType: "objectId" }
      }
    }
  }
});
db.pagos.createIndex({ pacienteId: 1 });
db.pagos.createIndex({ fecha: 1 });

// ------------------------------------------------------------
// 1.7 citasOdontologicas
// ------------------------------------------------------------
db.createCollection("citasOdontologicas", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["odontologoId", "pacienteId", "horario"],
      properties: {
        odontologoId: { bsonType: "objectId" },
        pacienteId:   { bsonType: "objectId" },
        pagoId:       { bsonType: "objectId" },
        horario:      { bsonType: "date" },
        tratamiento:  { bsonType: "string" },
        estado:       { bsonType: "string", enum: ["Pendiente","Confirmada Asistida","Confirmada No Asistida","Cancelada","Reprogramada"] }
      }
    }
  }
});
db.citasOdontologicas.createIndex({ odontologoId: 1 });
db.citasOdontologicas.createIndex({ pacienteId: 1 });
db.citasOdontologicas.createIndex({ horario: 1 });

// ------------------------------------------------------------
// 1.8 Auditoría (estructura simple)
// ------------------------------------------------------------
["usuarios_auditoria","odontologos_auditoria","auxiliares_auditoria",
 "pacientes_auditoria","historiasClinicas_auditoria",
 "citasOdontologicas_auditoria","pagos_auditoria"].forEach(col => {
  db.createCollection(col);
  db[col].createIndex({ fechaAuditoria: -1 });
  db[col].createIndex({ usuarioAudit: 1 });
});

print("✅ Colecciones creadas exitosamente en clinicaodontologica (MongoDB)");