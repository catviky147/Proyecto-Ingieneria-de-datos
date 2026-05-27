const router   = require('express').Router();
const Anamnesis = require('../config/mongo');

// GET anamnesis por historia clínica
router.get('/:historiaClinicaFK', async (req, res) => {
  try {
    const doc = await Anamnesis.findOne({
      historiaClinicaFK: req.params.historiaClinicaFK
    });
    res.json(doc || {});
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST crear o actualizar anamnesis (upsert)
router.post('/', async (req, res) => {
  try {
    const doc = await Anamnesis.findOneAndUpdate(
      { historiaClinicaFK: req.body.historiaClinicaFK },
      req.body,
      { upsert: true, new: true }
    );
    res.json({ ok: true, id: doc._id });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// PUT actualizar campos específicos
router.put('/:historiaClinicaFK', async (req, res) => {
  try {
    await Anamnesis.findOneAndUpdate(
      { historiaClinicaFK: req.params.historiaClinicaFK },
      { $set: req.body },
      { upsert: true }
    );
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

module.exports = router;
