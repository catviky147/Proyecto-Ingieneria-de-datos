const router = require('express').Router();
const db     = require('../config/mysql');

// GET todos los pacientes
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query('select * from paciente order by idpaciente desc');
    res.json(rows);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET buscar por nombre o documento
router.get('/buscar/:termino', async (req, res) => {
  try {
    const t = `%${req.params.termino}%`;
    const [rows] = await db.query(
      `select p.*, hc.idHistoriaClinica, hc.estado, hc.observaciones
       from paciente p
       left join historiaClinica hc on hc.pacienteFK = p.idpaciente
       where p.nombrePaciente like ? or p.documentoPaciente like ?`,
      [t, t]
    );
    res.json(rows);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST crear paciente + historia clínica
router.post('/', async (req, res) => {
  const { nombrePaciente, documentoPaciente, direccionPaciente,
          fechaNacPaciente, Preexistencias, Alergias } = req.body;
  try {
    const [result] = await db.query(
      `insert into paciente(nombrePaciente, documentoPaciente, direccionPaciente,
        fechaNacPaciente, Preexistencias, Alergias)
       values (?, ?, ?, ?, ?, ?)`,
      [nombrePaciente, documentoPaciente, direccionPaciente,
       fechaNacPaciente, Preexistencias, Alergias]
    );
    const idPaciente = result.insertId;
    await db.query(
      `insert into historiaClinica(fechaApertura, estado, observaciones, pacienteFK)
       values (curdate(), 'Activa', '', ?)`,
      [idPaciente]
    );
    res.json({ ok: true, idPaciente });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// PUT actualizar paciente (con COALESCE lógico)
router.put('/:id', async (req, res) => {
  const { nombrePaciente, direccionPaciente, Preexistencias, Alergias } = req.body;
  try {
    await db.query(
      `update paciente set
        nombrePaciente    = coalesce(nullif(?, ''), nombrePaciente),
        direccionPaciente = coalesce(nullif(?, ''), direccionPaciente),
        Preexistencias    = coalesce(nullif(?, ''), Preexistencias),
        Alergias          = coalesce(nullif(?, ''), Alergias)
       where idpaciente = ?`,
      [nombrePaciente, direccionPaciente, Preexistencias, Alergias, req.params.id]
    );
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// DELETE paciente
router.delete('/:id', async (req, res) => {
  try {
    await db.query('delete from paciente where idpaciente = ?', [req.params.id]);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

module.exports = router;
