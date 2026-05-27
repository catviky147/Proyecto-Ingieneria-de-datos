const router = require('express').Router();
const db     = require('../config/mysql');

// GET todas las citas con nombre de paciente y odontólogo
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query(
      `select c.*, p.nombrePaciente, u.nombreUsuario as nombreOdontologo,
              o.especialidad, pg.monto, pg.metodoPago, pg.estado as estadoPago
       from citaOdontologico c
       inner join paciente   p on c.pacienteFK   = p.idpaciente
       inner join odontologo o on c.odontologoFK  = o.idOdontologo
       inner join usuario    u on o.usuarioFK     = u.idUsuario
       left  join pago      pg on c.pagoFK        = pg.idPago
       order by c.horario desc`
    );
    res.json(rows);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET citas del mes actual (para calendario)
router.get('/calendario', async (req, res) => {
  try {
    const [rows] = await db.query(
      `select c.idCita, c.horario, c.tratamiento, c.estado,
              p.nombrePaciente, u.nombreUsuario as odontologo
       from citaOdontologico c
       inner join paciente   p on c.pacienteFK  = p.idpaciente
       inner join odontologo o on c.odontologoFK = o.idOdontologo
       inner join usuario    u on o.usuarioFK    = u.idUsuario
       where month(c.horario) = month(curdate())
         and year(c.horario)  = year(curdate())
       order by c.horario asc`
    );
    res.json(rows);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST crear cita
router.post('/', async (req, res) => {
  const { odontologoFK, pacienteFK, horario, tratamiento } = req.body;
  try {
    const [result] = await db.query(
      `insert into citaOdontologico(odontologoFK, pacienteFK, horario, tratamiento, estado)
       values (?, ?, ?, ?, 'Pendiente')`,
      [odontologoFK, pacienteFK, horario, tratamiento]
    );
    res.json({ ok: true, idCita: result.insertId });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// PUT actualizar estado/asistencia de cita
router.put('/:id', async (req, res) => {
  const { estado, tratamiento } = req.body;
  try {
    await db.query(
      `update citaOdontologico set
        estado      = coalesce(nullif(?, ''), estado),
        tratamiento = coalesce(nullif(?, ''), tratamiento)
       where idCita = ?`,
      [estado, tratamiento, req.params.id]
    );
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// DELETE cita
router.delete('/:id', async (req, res) => {
  try {
    await db.query('delete from citaOdontologico where idCita = ?', [req.params.id]);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

module.exports = router;
