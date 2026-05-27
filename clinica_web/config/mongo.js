const mongoose = require('mongoose');

mongoose.connect(process.env.MONGO_URI)
    .then(() => console.log('✅ Conectado a MongoDB'))
    .catch(err => console.error('❌ Error conectando a MongoDB:', err.message));

module.exports = mongoose;

// Schema de anamnesis en MongoDB (más flexible que SQL)
const anamnesisSchema = new mongoose.Schema({
  historiaClinicaFK:      { type: Number, required: true },
  pacienteNombre:         String,
  motivoConsulta:         String,
  enfermedadActual:       String,
  antecedentesPersonales: String,
  antecedentesFamiliares: String,
  revisionSistemas:       String,
  signosVitales: {
    presionArterial:        String,
    frecuenciaCardiaca:     Number,
    frecuenciaRespiratoria: Number,
    temperatura:            Number,
    peso:                   Number,
    talla:                  Number,
    imc:                    Number,
    glucemia:               Number
  },
  habitosHigiene: {
    frecuenciaCepillado:     String,
    usaHiloDental:           Boolean,
    usaEnjuague:             Boolean,
    visitaDentistaPeriodica: Boolean,
    consumoTabaco:           Boolean,
    consumoAlcohol:          Boolean,
    observaciones:           String
  },
  medicamentos: [{
    nombreMedicamento: String,
    dosis:             String,
    frecuencia:        String,
    motivoUso:         String
  }],
  fechaRegistro: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Anamnesis', anamnesisSchema);
