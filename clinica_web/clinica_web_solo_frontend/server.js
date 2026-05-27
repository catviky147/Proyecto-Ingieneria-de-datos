const express = require('express');
const path = require('path');

const app = express();

// Servir archivos estáticos
app.use(express.static(path.join(__dirname, 'public')));

// Todas las rutas van al index.html
app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`✅ Interfaz disponible en http://localhost:${PORT}`);
    console.log(`📌 Datos de ejemplo - Sin conexión a base de datos real`);
});