const router = require('express').Router();
const db     = require('../config/mysql');

// GET todos los pagos
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query('select * from pago order by fecha desc');
    res.json(rows);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET resumen por método de pago
router.get('/resumen', async (req, res) => {
  try {
    const [rows] = await db.query(
      'select metodoPago, sum(monto) as total from pago group by metodoPago'
    );
    res.json(rows);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST crear pago
router.post('/', async (req, res) => {
  const { fecha, monto, metodoPago, estado } = req.body;
  try {
    const [result] = await db.query(
      'insert into pago(fecha, monto, metodoPago, estado) values (?, ?, ?, ?)',
      [fecha, monto, metodoPago, estado || 'Pagado']
    );
    res.json({ ok: true, idPago: result.insertId });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// PUT actualizar estado de pago
router.put('/:id', async (req, res) => {
  const { estado, monto } = req.body;
  try {
    await db.query(
      `update pago set
        estado = coalesce(nullif(?, ''), estado),
        monto  = coalesce(nullif(?, 0), monto)
       where idPago = ?`,
      [estado, monto, req.params.id]
    );
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

module.exports = router;
