CREATE DATABASE clinicaodontologica;
USE clinicaodontologica;

-- =======================================================
-- TABLA USUARIO
-- =======================================================

CREATE TABLE usuario(
    idUsuario INT(10) PRIMARY KEY,
    nombreUsuario VARCHAR(50) NOT NULL,
    telefono VARCHAR(20),
    correoElectronico VARCHAR(50) UNIQUE,
    tipoDocumento VARCHAR(10),
    userName VARCHAR(20) UNIQUE,
    contrasena VARCHAR(16) NOT NULL,
    rol VARCHAR(30) NOT NULL,
    estadoUsuario VARCHAR(20) DEFAULT 'Activo'
);

-- =======================================================
-- TABLA ODONTOLOGO
-- =======================================================

CREATE TABLE odontologo(
    idOdontologo INT AUTO_INCREMENT PRIMARY KEY,
    tarjetaProfesional VARCHAR(50) NOT NULL,
    especialidad VARCHAR(50),
    usuarioFK INT(10),

    FOREIGN KEY (usuarioFK)
    REFERENCES usuario(idUsuario)
    ON DELETE CASCADE
);

-- =======================================================
-- TABLA AUXILIAR
-- =======================================================

CREATE TABLE auxiliar(
    idAuxiliar INT AUTO_INCREMENT PRIMARY KEY,
    tarjetaProfesionalAux VARCHAR(50),
    usuarioFK INT(10),

    FOREIGN KEY (usuarioFK)
    REFERENCES usuario(idUsuario)
    ON DELETE CASCADE
);

-- =======================================================
-- TABLA PACIENTE
-- =======================================================

CREATE TABLE paciente(
    idPaciente INT AUTO_INCREMENT PRIMARY KEY,
    nombrePaciente VARCHAR(50) NOT NULL,
    documentoPaciente INT(10) NOT NULL UNIQUE,
    direccionPaciente VARCHAR(100) NOT NULL,
    fechaNacPaciente DATE NOT NULL,

    tipoSangre VARCHAR(10),
    acudiente VARCHAR(100),
    eps VARCHAR(100),
    telefonoUrgencia VARCHAR(20),
    direccionTrabajo VARCHAR(100),

    preexistencias VARCHAR(500),
    alergias VARCHAR(100),

    usuarioFK INT(10),

    FOREIGN KEY (usuarioFK)
    REFERENCES usuario(idUsuario)
    ON DELETE CASCADE
);

-- =======================================================
-- TABLA HISTORIA CLINICA
-- =======================================================

CREATE TABLE historiaClinica(
    idHistoriaClinica INT AUTO_INCREMENT PRIMARY KEY,
    fechaApertura DATE NOT NULL,
    estado VARCHAR(70),
    observaciones VARCHAR(10000),

    pacienteFK INT NOT NULL,

    FOREIGN KEY (pacienteFK)
    REFERENCES paciente(idPaciente)
);

-- =======================================================
-- TABLA SIGNOS VITALES
-- =======================================================

CREATE TABLE signosVitales(
    idSignos INT AUTO_INCREMENT PRIMARY KEY,

    pulso VARCHAR(20),
    tensionArterial VARCHAR(20),
    temperatura DECIMAL(4,2),
    frecuenciaRespiratoria VARCHAR(20),

    historiaClinicaFK INT,

    FOREIGN KEY (historiaClinicaFK)
    REFERENCES historiaClinica(idHistoriaClinica)
);

-- =======================================================
-- TABLA HABITOS HIGIENE
-- =======================================================

CREATE TABLE habitosHigiene(
    idHabito INT AUTO_INCREMENT PRIMARY KEY,

    cepillado VARCHAR(20),
    sedaDental VARCHAR(20),
    enjuageBucal VARCHAR(20),
    frecuencia VARCHAR(50),

    historiaClinicaFK INT,

    FOREIGN KEY (historiaClinicaFK)
    REFERENCES historiaClinica(idHistoriaClinica)
);

-- =======================================================
-- TABLA EXAMEN DENTAL
-- =======================================================

CREATE TABLE examenDental(
    idExamen INT AUTO_INCREMENT PRIMARY KEY,

    descripcion VARCHAR(1000),
    odontograma VARCHAR(1000),

    historiaClinicaFK INT,

    FOREIGN KEY (historiaClinicaFK)
    REFERENCES historiaClinica(idHistoriaClinica)
);

-- =======================================================
-- TABLA AYUDA DIAGNOSTICA
-- =======================================================

CREATE TABLE ayudaDiagnostica(
    idAyuda INT AUTO_INCREMENT PRIMARY KEY,

    nombreArchivo VARCHAR(100),
    rutaArchivo VARCHAR(255),
    descripcion VARCHAR(500),

    historiaClinicaFK INT,

    FOREIGN KEY (historiaClinicaFK)
    REFERENCES historiaClinica(idHistoriaClinica)
);

-- =======================================================
-- TABLA DIAGNOSTICO
-- =======================================================

CREATE TABLE diagnostico(
    idDiagnostico INT AUTO_INCREMENT PRIMARY KEY,

    cie VARCHAR(20),
    descripcion VARCHAR(1000),
    pronostico VARCHAR(30),

    historiaClinicaFK INT,

    FOREIGN KEY (historiaClinicaFK)
    REFERENCES historiaClinica(idHistoriaClinica)
);

-- =======================================================
-- TABLA PLAN TRATAMIENTO
-- =======================================================

CREATE TABLE planTratamiento(
    idPlan INT AUTO_INCREMENT PRIMARY KEY,

    descripcion VARCHAR(2000),
    presupuesto DOUBLE,
    estado VARCHAR(50),

    historiaClinicaFK INT,

    FOREIGN KEY (historiaClinicaFK)
    REFERENCES historiaClinica(idHistoriaClinica)
);

-- =======================================================
-- TABLA EVOLUCION CLINICA
-- =======================================================

CREATE TABLE evolucionClinica(
    idEvolucion INT AUTO_INCREMENT PRIMARY KEY,

    fecha DATE,

    estadoActual VARCHAR(1000),
    cambiosTratamiento VARCHAR(1000),
    respuestaPaciente VARCHAR(1000),

    interconsulta VARCHAR(500),
    remision VARCHAR(500),
    cambioProfesional VARCHAR(500),

    historiaClinicaFK INT,

    FOREIGN KEY (historiaClinicaFK)
    REFERENCES historiaClinica(idHistoriaClinica)
);

-- =======================================================
-- TABLA MEDICAMENTO
-- =======================================================

CREATE TABLE medicamento(
    idMedicamento INT AUTO_INCREMENT PRIMARY KEY,

    nombreMedicamento VARCHAR(100),
    dosis VARCHAR(100),
    indicaciones VARCHAR(500),

    historiaClinicaFK INT,

    FOREIGN KEY (historiaClinicaFK)
    REFERENCES historiaClinica(idHistoriaClinica)
);

-- =======================================================
-- TABLA PAGO
-- =======================================================

CREATE TABLE pago(
    idPago INT AUTO_INCREMENT PRIMARY KEY,

    fecha DATE NOT NULL,
    monto DOUBLE NOT NULL,
    metodoPago VARCHAR(100) NOT NULL,
    estado VARCHAR(50)
);

-- =======================================================
-- TABLA CITA ODONTOLOGICA
-- =======================================================

CREATE TABLE citaOdontologico(
    idCita INT AUTO_INCREMENT PRIMARY KEY,

    odontologoFK INT NOT NULL,
    pacienteFK INT NOT NULL,
    pagoFK INT,

    horario DATETIME,
    tratamiento VARCHAR(100),

    estado VARCHAR(50) DEFAULT 'Pendiente',

    FOREIGN KEY (odontologoFK)
    REFERENCES odontologo(idOdontologo),

    FOREIGN KEY (pacienteFK)
    REFERENCES paciente(idPaciente),

    FOREIGN KEY (pagoFK)
    REFERENCES pago(idPago)
);

-- =======================================================
-- TABLA LOG ACTIVIDAD
-- =======================================================

CREATE TABLE logActividad(
    idLog INT AUTO_INCREMENT PRIMARY KEY,

    usuarioFK INT,
    accionRealizada VARCHAR(500),
    fecha DATETIME,

    FOREIGN KEY (usuarioFK)
    REFERENCES usuario(idUsuario)
);



SELECT *
FROM pago
WHERE metodoPago = 'Efectivo';


-- 1. Pacientes con alergia al latex

SELECT nombrePaciente AS nombre,
       preexistencias AS preExistencias
FROM paciente
WHERE alergias = 'Latex';

-- 2. Citas del mes de abril

SELECT odontologoFK AS ID_Odontologo,
       pacienteFK AS ID_Paciente,
       horario AS fecha
FROM citaOdontologico
WHERE MONTH(horario) = 4;

-- 3. Informacion odontologos

SELECT u.nombreUsuario AS nombreOdontologo,
       u.telefono,
       o.especialidad
FROM odontologo o
INNER JOIN usuario u
ON o.usuarioFK = u.idUsuario;

-- 4. Total ingresos por metodo de pago

SELECT metodoPago,
       SUM(monto) AS total_recaudado
FROM pago
GROUP BY metodoPago;

-- 5. Pacientes con enfermedades sistemicas

SELECT nombrePaciente,
       preexistencias
FROM paciente
WHERE preexistencias IS NOT NULL
AND preexistencias != 'Ninguna';

-- 6. Agenda de citas proximas

SELECT c.horario,
       p.nombrePaciente,
       c.tratamiento
FROM citaOdontologico c
INNER JOIN paciente p
ON c.pacienteFK = p.idPaciente
WHERE c.horario >= CURDATE();

-- 7. Usuarios administrativos

SELECT nombreUsuario,
       correoElectronico,
       rol
FROM usuario
WHERE rol != 'Paciente';

-- 8. Historia Clínica: búsqueda por nombre del paciente
SELECT hc.idHistoriaClinica,
       p.nombrePaciente,
       hc.fechaApertura
FROM historiaClinica hc
INNER JOIN paciente p
ON hc.pacienteFK = p.idPaciente
WHERE p.nombrePaciente = 'Juan Perez';

-- 9. Historia Clínica: búsqueda por documento
SELECT hc.idHistoriaClinica,
       p.nombrePaciente,
       p.documentoPaciente
FROM historiaClinica hc
INNER JOIN paciente p
ON hc.pacienteFK = p.idPaciente
WHERE p.documentoPaciente = 123456789;

-- 10. Historia Clínica: búsqueda por teléfono
SELECT nombrePaciente,
       telefonoUrgencia
FROM paciente
WHERE telefonoUrgencia = '3000000000';

-- 11. Clínica: búsqueda de pacientes por preexistencia específica
SELECT nombrePaciente,
       preexistencias
FROM paciente
WHERE preexistencias LIKE '%Diabetes%';

-- 12. Clínica: búsqueda de pacientes por categoría de preexistencia
SELECT nombrePaciente,
       preexistencias
FROM paciente
WHERE preexistencias IN ('Diabetes', 'Hipertension');

-- 13. Agenda: búsqueda de citas por día
SELECT *
FROM citaOdontologico
WHERE DATE(horario) = '2026-05-13';

-- 14. Agenda: búsqueda de citas por mes
SELECT *
FROM citaOdontologico
WHERE MONTH(horario) = 5;

-- 15. Agenda: búsqueda de citas por año
SELECT *
FROM citaOdontologico
WHERE YEAR(horario) = 2026;

-- 16. Evolución Clínica: visualización de evoluciones
SELECT fecha,
       estadoActual,
       cambiosTratamiento
FROM evolucionClinica
WHERE historiaClinicaFK = 1;

-- 17. Medicamentos: consulta de medicamentos formulados
SELECT nombreMedicamento,
       dosis,
       indicaciones
FROM medicamento
WHERE historiaClinicaFK = 1;

-- 18. Alertas Clínicas: pacientes con alertas activas
SELECT p.nombrePaciente,
       a.tipoAlerta,
       a.descripcion
FROM alertaClinica a
INNER JOIN paciente p
ON a.pacienteFK = p.idPaciente;

-- 19. Pagos: consulta de saldo pendiente de tratamiento
SELECT pt.idPlan,
       pt.presupuesto,
       SUM(a.valorAbono) AS totalAbonado,
       (pt.presupuesto - SUM(a.valorAbono)) AS saldoPendiente
FROM planTratamiento pt
INNER JOIN abonoTratamiento a
ON pt.idPlan = a.planFK
GROUP BY pt.idPlan;

-- 20. Seguridad: registro de actividad de usuarios
SELECT u.nombreUsuario,
       l.accionRealizada,
       l.fecha
FROM logActividad l
INNER JOIN usuario u
ON l.usuarioFK = u.idUsuario;

-- 21. Clínica: pacientes con alertas médicas
SELECT nombrePaciente,
       alergias,
       preexistencias
FROM paciente
WHERE alergias IS NOT NULL
OR preexistencias IS NOT NULL;

-- 22. Administrativa: reporte diario de ingresos
SELECT fecha,
       SUM(monto) AS ingresosDia
FROM pago
GROUP BY fecha;

-- 23. Tratamientos: consulta de planes activos
SELECT *
FROM planTratamiento
WHERE estado = 'Activo';

-- 24. Estadística: pacientes con mayor número de citas
SELECT p.nombrePaciente,
       COUNT(c.idCita) AS totalCitas
FROM paciente p
INNER JOIN citaOdontologico c
ON p.idPaciente = c.pacienteFK
GROUP BY p.idPaciente
ORDER BY totalCitas DESC;

-- RQF10 - ALERTA AUTOMATICA POR PREEXISTENCIA

DELIMITER $$

CREATE TRIGGER alerta_preexistencia
AFTER INSERT ON paciente
FOR EACH ROW
BEGIN

    IF NEW.preexistencias IS NOT NULL THEN

        INSERT INTO alertaClinica(
            tipoAlerta,
            descripcion,
            fecha,
            pacienteFK
        )

        VALUES(
            'Preexistencia Médica',
            CONCAT('Paciente con preexistencia: ', NEW.preexistencias),
            NOW(),
            NEW.idPaciente
        );

    END IF;

END $$

DELIMITER ;

-- RQF10 - ALERTA AUTOMATICA POR ALERGIA

DELIMITER $$

CREATE TRIGGER alerta_alergia
AFTER INSERT ON paciente
FOR EACH ROW
BEGIN

    IF NEW.alergias IS NOT NULL THEN

        INSERT INTO alertaClinica(
            tipoAlerta,
            descripcion,
            fecha,
            pacienteFK
        )

        VALUES(
            'Alergia Médica',
            CONCAT('Paciente con alergia: ', NEW.alergias),
            NOW(),
            NEW.idPaciente
        );

    END IF;

END $$

DELIMITER ;

-- RQF35 - LOG AUTOMATICO CREACION PACIENTE
-- =======================================================

DELIMITER $$

CREATE TRIGGER log_creacion_paciente
AFTER INSERT ON paciente
FOR EACH ROW
BEGIN

    INSERT INTO logActividad(
        usuarioFK,
        accionRealizada,
        fecha
    )

    VALUES(
        NEW.usuarioFK,
        CONCAT('Registro de paciente: ', NEW.nombrePaciente),
        NOW()
    );

END $$

DELIMITER ;

-- RQF35 - LOG ACTUALIZACION PACIENTE

DELIMITER $$

CREATE TRIGGER log_actualizacion_paciente
AFTER UPDATE ON paciente
FOR EACH ROW
BEGIN

    INSERT INTO logActividad(
        usuarioFK,
        accionRealizada,
        fecha
    )

    VALUES(
        NEW.usuarioFK,
        CONCAT('Actualización de paciente: ', NEW.nombrePaciente),
        NOW()
    );

END $$

DELIMITER ;

}-- RQF35 - LOG ELIMINACION PACIENTE

DELIMITER $$

CREATE TRIGGER log_eliminacion_paciente
AFTER DELETE ON paciente
FOR EACH ROW
BEGIN

    INSERT INTO logActividad(
        usuarioFK,
        accionRealizada,
        fecha
    )

    VALUES(
        OLD.usuarioFK,
        CONCAT('Eliminación de paciente: ', OLD.nombrePaciente),
        NOW()
    );

END $$

DELIMITER ;

-- RQF16 - PROCEDIMIENTO CREAR CITA

DELIMITER $$

CREATE PROCEDURE crearCita(
    IN pOdontologo INT,
    IN pPaciente INT,
    IN pHorario DATETIME,
    IN pTratamiento VARCHAR(100)
)

BEGIN

    INSERT INTO citaOdontologico(
        odontologoFK,
        pacienteFK,
        horario,
        tratamiento
    )

    VALUES(
        pOdontologo,
        pPaciente,
        pHorario,
        pTratamiento
    );

END $$

DELIMITER ;

-- RQF16 - PROCEDIMIENTO CAMBIAR ESTADO CITA

DELIMITER $$

CREATE PROCEDURE actualizarEstadoCita(
    IN pCita INT,
    IN pEstado VARCHAR(50)
)

BEGIN

    UPDATE citaOdontologico
    SET estado = pEstado
    WHERE idCita = pCita;

END $$

DELIMITER ;

-- RQF03 - BUSQUEDA HISTORIA CLINICA

DELIMITER $$

CREATE PROCEDURE buscarHistoriaPorDocumento(
    IN pDocumento INT
)

BEGIN

    SELECT hc.idHistoriaClinica,
           p.nombrePaciente,
           p.documentoPaciente
    FROM historiaClinica hc
    INNER JOIN paciente p
    ON hc.pacienteFK = p.idPaciente
    WHERE p.documentoPaciente = pDocumento;

END $$

DELIMITER ;

-- RQF17 - NOTIFICACION AUTOMATICA DE CITAS

DELIMITER $$

CREATE EVENT notificacion_citas

ON SCHEDULE EVERY 1 DAY

DO

INSERT INTO notificacion(
    mensaje,
    fechaEnvio,
    estado,
    citaFK
)

SELECT
    CONCAT('Recordatorio de cita para paciente ', p.nombrePaciente),
    NOW(),
    'Pendiente',
    c.idCita

FROM citaOdontologico c

INNER JOIN paciente p
ON c.pacienteFK = p.idPaciente

WHERE DATE(c.horario) = CURDATE() + INTERVAL 1 DAY;

$$

DELIMITER ;

-- RQF19 - RESPALDO DE DATOS (SIMULACION)

CREATE TABLE respaldoPaciente AS
SELECT *
FROM paciente;

-- RQF21 - VALIDACION DUPLICADOS

ALTER TABLE paciente
ADD CONSTRAINT unique_documento
UNIQUE(documentoPaciente);

-- RQF23 - RESULTADOS DE CONSULTA

DELIMITER $$

CREATE PROCEDURE pacientesConPreexistencias()

BEGIN

    SELECT nombrePaciente,
           preexistencias
    FROM paciente
    WHERE preexistencias IS NOT NULL;

END $$

DELIMITER ;

-- RQF30 - ALERTAS POR CONDICION MEDICA

DELIMITER $$

CREATE PROCEDURE generarAlertas()

BEGIN

    INSERT INTO alertaClinica(
        tipoAlerta,
        descripcion,
        fecha,
        pacienteFK
    )

    SELECT
        'Condición Médica',
        CONCAT('Paciente con condición: ', preexistencias),
        NOW(),
        idPaciente

    FROM paciente

    WHERE preexistencias IS NOT NULL;

END $$

DELIMITER ;

-- RQF33 - EXPORTACION HISTORIA CLINICA

CREATE VIEW vistaHistoriaClinicaCompleta AS

SELECT
    p.nombrePaciente,
    p.documentoPaciente,
    hc.fechaApertura,
    hc.observaciones,
    d.descripcion AS diagnostico,
    pt.descripcion AS tratamiento

FROM paciente p

INNER JOIN historiaClinica hc
ON p.idPaciente = hc.pacienteFK

LEFT JOIN diagnostico d
ON hc.idHistoriaClinica = d.historiaClinicaFK

LEFT JOIN planTratamiento pt
ON hc.idHistoriaClinica = pt.historiaClinicaFK;

-- RQF37 - REGISTRO PAGOS Y ABONOS

DELIMITER $$

CREATE PROCEDURE registrarAbono(
    IN pPago INT,
    IN pPlan INT,
    IN pValor DOUBLE
)

BEGIN

    INSERT INTO abonoTratamiento(
        fecha,
        valorAbono,
        pagoFK,
        planFK
    )

    VALUES(
        CURDATE(),
        pValor,
        pPago,
        pPlan
    );

END $$

DELIMITER ;

-- RQF38 - CONSULTA SALDO TRATAMIENTO

CREATE VIEW vistaSaldoTratamientos AS

SELECT
    pt.idPlan,
    pt.descripcion,
    pt.presupuesto,

    IFNULL(SUM(a.valorAbono),0) AS totalAbonado,

    (pt.presupuesto - IFNULL(SUM(a.valorAbono),0))
    AS saldoPendiente

FROM planTratamiento pt

LEFT JOIN abonoTratamiento a
ON pt.idPlan = a.planFK

GROUP BY pt.idPlan;