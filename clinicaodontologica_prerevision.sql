-- ============================================================
-- BASE DE DATOS: clinicaodontologica
-- Versión 2 — estructura reorganizada:
--   1. Tablas principales (originales + nuevas)
--   2. Tablas de auditoría (todas juntas)
--   3. Triggers de auditoría (todos juntos)
--   4. Consultas por RQF
-- Cambios respecto a v1:
--   - TINYINT(1) reemplazado por ENUM con valores descriptivos
--   - odontograma cambiado a VARCHAR(500) para URLs
--   - Correcciones lógicas aplicadas directamente en la definición
-- ============================================================

CREATE DATABASE IF NOT EXISTS clinicaodontologica
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_spanish_ci;

USE clinicaodontologica;


-- ============================================================
-- SECCIÓN 1: TABLAS PRINCIPALES
-- ============================================================

-- -----------------------------------------------------------
-- 1.1 usuario  (PK raíz: idUsuario)
--     AUTO_INCREMENT corregido desde v1
--     contrasena ampliada a 255 para hash bcrypt
--     rol como ENUM para evitar errores de escritura
-- -----------------------------------------------------------
CREATE TABLE usuario (
    idUsuario          INT(10)      NOT NULL AUTO_INCREMENT,
    nombreUsuario      VARCHAR(50),
    telefono           VARCHAR(20),
    correoElectronico  VARCHAR(50),
    tipoDocumento      VARCHAR(10),
    userName           VARCHAR(20),
    contrasena         VARCHAR(255) NOT NULL,
    rol                ENUM('Paciente','Odontologo','Auxiliar','Admin','Inactivo')
                                    DEFAULT 'Paciente',
    PRIMARY KEY (idUsuario)
);

-- -----------------------------------------------------------
-- 1.2 odontologo  (FK → usuario)
-- -----------------------------------------------------------
CREATE TABLE odontologo (
    idOdontologo        INT          NOT NULL AUTO_INCREMENT,
    tarjetaProfesional  VARCHAR(50),
    especialidad        VARCHAR(50),
    usuarioFK           INT(10)      NOT NULL,
    PRIMARY KEY (idOdontologo),
    CONSTRAINT fk_odontologo_usuario
        FOREIGN KEY (usuarioFK) REFERENCES usuario (idUsuario)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- -----------------------------------------------------------
-- 1.3 auxiliar  (FK → usuario)
-- -----------------------------------------------------------
CREATE TABLE auxiliar (
    idAuxiliar              INT         NOT NULL AUTO_INCREMENT,
    tarjetaProfesionalAux   VARCHAR(50),
    usuarioFK               INT(10)     NOT NULL,
    PRIMARY KEY (idAuxiliar),
    CONSTRAINT fk_auxiliar_usuario
        FOREIGN KEY (usuarioFK) REFERENCES usuario (idUsuario)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- -----------------------------------------------------------
-- 1.4 paciente  (FK → usuario)
--     documentoPaciente como VARCHAR para cédulas con ceros
--     usuarioFK NOT NULL: todo paciente debe tener usuario
--     UNIQUE en documento para evitar duplicados (RQF21)
-- -----------------------------------------------------------
CREATE TABLE paciente (
    idpaciente        INT          NOT NULL AUTO_INCREMENT,
    nombrePaciente    VARCHAR(50)  NOT NULL,
    documentoPaciente VARCHAR(20)  NOT NULL,
    direccionPaciente VARCHAR(100) NOT NULL,
    fechaNacPaciente  DATE         NOT NULL,
    Preexistencias    VARCHAR(500),
    Alergias          VARCHAR(100),
    usuarioFK         INT(10)      NOT NULL,
    PRIMARY KEY (idpaciente),
    UNIQUE KEY uk_documento_paciente (documentoPaciente),
    CONSTRAINT fk_paciente_usuario
        FOREIGN KEY (usuarioFK) REFERENCES usuario (idUsuario)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- -----------------------------------------------------------
-- 1.5 historiaClinica  (FK → paciente)
-- -----------------------------------------------------------
CREATE TABLE historiaClinica (
    idHistoriaClinica  INT           NOT NULL AUTO_INCREMENT,
    fechaApertura      DATE          NOT NULL,
    estado             VARCHAR(70),
    observaciones      VARCHAR(10000),
    pacienteFK         INT           NOT NULL,
    PRIMARY KEY (idHistoriaClinica),
    CONSTRAINT fk_historia_paciente
        FOREIGN KEY (pacienteFK) REFERENCES paciente (idpaciente)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- -----------------------------------------------------------
-- 1.6 anamnesis  (FK → historiaClinica)
-- -----------------------------------------------------------
CREATE TABLE anamnesis (
    idAnamnesis            INT          NOT NULL AUTO_INCREMENT,
    historiaClinicaFK      INT          NOT NULL,
    motivoConsulta         VARCHAR(500),
    enfermedadActual       VARCHAR(1000),
    antecedentesPersonales VARCHAR(500),
    antecedentesFamiliares VARCHAR(500),
    revisionSistemas       VARCHAR(1000),
    fechaRegistro          DATE,
    PRIMARY KEY (idAnamnesis),
    CONSTRAINT fk_anamnesis_historia
        FOREIGN KEY (historiaClinicaFK) REFERENCES historiaClinica (idHistoriaClinica)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- -----------------------------------------------------------
-- 1.7 signos_vitales  (FK → historiaClinica)
-- -----------------------------------------------------------
CREATE TABLE signos_vitales (
    idSignosVitales        INT     NOT NULL AUTO_INCREMENT,
    historiaClinicaFK      INT     NOT NULL,
    presionArterial        VARCHAR(20),
    frecuenciaCardiaca     INT,
    frecuenciaRespiratoria INT,
    temperatura            DECIMAL(4,1),
    peso                   DECIMAL(5,2),
    talla                  DECIMAL(4,2),
    imc                    DECIMAL(4,2),
    glucemia               DECIMAL(5,1),
    fechaRegistro          DATE,
    PRIMARY KEY (idSignosVitales),
    CONSTRAINT fk_signos_historia
        FOREIGN KEY (historiaClinicaFK) REFERENCES historiaClinica (idHistoriaClinica)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- -----------------------------------------------------------
-- 1.8 habitos_higiene  (FK → historiaClinica)
--     TINYINT reemplazado por ENUM descriptivo
-- -----------------------------------------------------------
CREATE TABLE habitos_higiene (
    idHabitosHigiene        INT         NOT NULL AUTO_INCREMENT,
    historiaClinicaFK       INT         NOT NULL,
    frecuenciaCepillado     VARCHAR(50),
    usaHilosDental          ENUM('Si','No')    DEFAULT 'No',
    usaEnjuague             ENUM('Si','No')    DEFAULT 'No',
    visitaDentistaPeriodica ENUM('Si','No')    DEFAULT 'No',
    consumoTabaco           ENUM('Si','No')    DEFAULT 'No',
    consumoAlcohol          ENUM('Si','No')    DEFAULT 'No',
    observaciones           VARCHAR(500),
    fechaRegistro           DATE,
    PRIMARY KEY (idHabitosHigiene),
    CONSTRAINT fk_habitos_historia
        FOREIGN KEY (historiaClinicaFK) REFERENCES historiaClinica (idHistoriaClinica)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- -----------------------------------------------------------
-- 1.9 medicamentos  (FK → historiaClinica)
-- -----------------------------------------------------------
CREATE TABLE medicamentos (
    idMedicamento      INT          NOT NULL AUTO_INCREMENT,
    historiaClinicaFK  INT          NOT NULL,
    nombreMedicamento  VARCHAR(100) NOT NULL,
    principioActivo    VARCHAR(100),
    dosis              VARCHAR(50),
    frecuencia         VARCHAR(50),
    viaAdministracion  VARCHAR(50),
    motivoUso          VARCHAR(200),
    fechaInicio        DATE,
    fechaFin           DATE,
    PRIMARY KEY (idMedicamento),
    CONSTRAINT fk_medicamentos_historia
        FOREIGN KEY (historiaClinicaFK) REFERENCES historiaClinica (idHistoriaClinica)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- -----------------------------------------------------------
-- 1.10 pago
--      monto como DECIMAL para precisión monetaria
--      pacienteFK agregado para trazabilidad directa (RQF37/38)
-- -----------------------------------------------------------
CREATE TABLE pago (
    idPago       INT           NOT NULL AUTO_INCREMENT,
    fecha        DATE          NOT NULL,
    monto        DECIMAL(12,2) NOT NULL,
    metodoPago   VARCHAR(100)  NOT NULL,
    estado       VARCHAR(50),
    pacienteFK   INT           NOT NULL,
    PRIMARY KEY (idPago),
    CONSTRAINT fk_pago_paciente
        FOREIGN KEY (pacienteFK) REFERENCES paciente (idpaciente)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- -----------------------------------------------------------
-- 1.11 citaOdontologico  (FK → odontologo, paciente, pago)
--      ON DELETE/UPDATE explícitos en todas las FK
-- -----------------------------------------------------------
CREATE TABLE citaOdontologico (
    idCita        INT         NOT NULL AUTO_INCREMENT,
    odontologoFK  INT         NOT NULL,
    pacienteFK    INT         NOT NULL,
    pagoFK        INT,
    horario       DATETIME,
    tratamiento   VARCHAR(100),
    estado        VARCHAR(50) DEFAULT 'Pendiente',
    PRIMARY KEY (idCita),
    CONSTRAINT fk_cita_odontologo
        FOREIGN KEY (odontologoFK) REFERENCES odontologo (idOdontologo)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_cita_paciente
        FOREIGN KEY (pacienteFK) REFERENCES paciente (idpaciente)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_cita_pago
        FOREIGN KEY (pagoFK) REFERENCES pago (idPago)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- -----------------------------------------------------------
-- 1.12 evolucion  (FK → historiaClinica, odontologo)
--      RQF04, RQF05, RQF08, RQF09, RQF28
--      TINYINT reemplazado por ENUM descriptivo
-- -----------------------------------------------------------
CREATE TABLE evolucion (
    idEvolucion        INT          NOT NULL AUTO_INCREMENT,
    historiaClinicaFK  INT          NOT NULL,
    odontologoFK       INT          NOT NULL,
    fechaSesion        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estadoActual       VARCHAR(1000),
    consultaAnterior   VARCHAR(1000),
    cambiosTratamiento VARCHAR(500),
    respuestaPaciente  VARCHAR(500),
    huboRemision       ENUM('Si','No')          DEFAULT 'No',
    huboInterconsulta  ENUM('Si','No')          DEFAULT 'No',
    cambioProfesional  ENUM('Si','No')          DEFAULT 'No',
    observaciones      VARCHAR(2000),
    PRIMARY KEY (idEvolucion),
    CONSTRAINT fk_evolucion_historia
        FOREIGN KEY (historiaClinicaFK) REFERENCES historiaClinica (idHistoriaClinica)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_evolucion_odontologo
        FOREIGN KEY (odontologoFK) REFERENCES odontologo (idOdontologo)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- -----------------------------------------------------------
-- 1.13 ayuda_diagnostica  (FK → historiaClinica)
--      RQF13, RQF24, RQF25
-- -----------------------------------------------------------
CREATE TABLE ayuda_diagnostica (
    idAyuda                INT          NOT NULL AUTO_INCREMENT,
    historiaClinicaFK      INT          NOT NULL,
    codigoCIE              VARCHAR(10),
    descripcionDiagnostico VARCHAR(500),
    pronostico             ENUM('Bueno','Malo','Reservado'),
    rutaArchivo            VARCHAR(500),
    tipoArchivo            VARCHAR(50),
    fechaRegistro          DATE         NOT NULL DEFAULT (CURRENT_DATE),
    PRIMARY KEY (idAyuda),
    CONSTRAINT fk_ayuda_historia
        FOREIGN KEY (historiaClinicaFK) REFERENCES historiaClinica (idHistoriaClinica)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- -----------------------------------------------------------
-- 1.14 plan_tratamiento  (FK → historiaClinica)
--      RQF14, RQF25, RQF38
-- -----------------------------------------------------------
CREATE TABLE plan_tratamiento (
    idPlan             INT           NOT NULL AUTO_INCREMENT,
    historiaClinicaFK  INT           NOT NULL,
    descripcion        VARCHAR(1000),
    presupuesto        DECIMAL(12,2),
    saldoPendiente     DECIMAL(12,2),
    fechaInicio        DATE,
    fechaFin           DATE,
    estado             VARCHAR(50)   DEFAULT 'Activo',
    PRIMARY KEY (idPlan),
    CONSTRAINT fk_plan_historia
        FOREIGN KEY (historiaClinicaFK) REFERENCES historiaClinica (idHistoriaClinica)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- -----------------------------------------------------------
-- 1.15 consentimiento  (FK → historiaClinica)
--      RQF02, RQF26, RQF27
--      TINYINT reemplazado por ENUM descriptivo
-- -----------------------------------------------------------
CREATE TABLE consentimiento (
    idConsentimiento   INT          NOT NULL AUTO_INCREMENT,
    historiaClinicaFK  INT          NOT NULL,
    procedimiento      VARCHAR(200),
    fechaFirma         DATE,
    firmaPaciente      ENUM('Firmado','Pendiente')    DEFAULT 'Pendiente',
    firmaProfesional   ENUM('Firmado','Pendiente')    DEFAULT 'Pendiente',
    observaciones      VARCHAR(500),
    PRIMARY KEY (idConsentimiento),
    CONSTRAINT fk_consentimiento_historia
        FOREIGN KEY (historiaClinicaFK) REFERENCES historiaClinica (idHistoriaClinica)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- -----------------------------------------------------------
-- 1.16 examen_dental  (FK → historiaClinica)
--      odontograma como VARCHAR(500) para almacenar URL
--      del recurso externo (imagen alojada en servicio online)
-- -----------------------------------------------------------
CREATE TABLE examen_dental (
    idExamen           INT          NOT NULL AUTO_INCREMENT,
    historiaClinicaFK  INT          NOT NULL,
    hallazgos          TEXT,
    odontograma        VARCHAR(500),
    fechaRegistro      DATE         NOT NULL DEFAULT (CURRENT_DATE),
    PRIMARY KEY (idExamen),
    CONSTRAINT fk_examen_historia
        FOREIGN KEY (historiaClinicaFK) REFERENCES historiaClinica (idHistoriaClinica)
        ON DELETE CASCADE ON UPDATE CASCADE
);


-- ============================================================
-- SECCIÓN 2: TABLAS DE AUDITORÍA (todas juntas)
-- ============================================================

-- -----------------------------------------------------------
-- 2.1 usuario_auditoria
-- -----------------------------------------------------------
CREATE TABLE usuario_auditoria (
    idAuditoria        INT          NOT NULL AUTO_INCREMENT,
    idUsuario          INT(10),
    nombreUsuario      VARCHAR(50),
    telefono           VARCHAR(20),
    correoElectronico  VARCHAR(50),
    tipoDocumento      VARCHAR(10),
    userName           VARCHAR(20),
    contrasena         VARCHAR(255),
    rol                VARCHAR(20),
    accion             VARCHAR(10)  NOT NULL,
    fechaAuditoria     DATETIME     DEFAULT CURRENT_TIMESTAMP,
    usuarioAudit       VARCHAR(100) DEFAULT USER(),
    PRIMARY KEY (idAuditoria)
);

-- -----------------------------------------------------------
-- 2.2 odontologo_auditoria
-- -----------------------------------------------------------
CREATE TABLE odontologo_auditoria (
    idAuditoria         INT          NOT NULL AUTO_INCREMENT,
    idOdontologo        INT,
    tarjetaProfesional  VARCHAR(50),
    especialidad        VARCHAR(50),
    usuarioFK           INT(10),
    accion              VARCHAR(10)  NOT NULL,
    fechaAuditoria      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    usuarioAudit        VARCHAR(100) DEFAULT USER(),
    PRIMARY KEY (idAuditoria)
);

-- -----------------------------------------------------------
-- 2.3 auxiliar_auditoria
-- -----------------------------------------------------------
CREATE TABLE auxiliar_auditoria (
    idAuditoria           INT          NOT NULL AUTO_INCREMENT,
    idAuxiliar            INT,
    tarjetaProfesionalAux VARCHAR(50),
    usuarioFK             INT(10),
    accion                VARCHAR(10)  NOT NULL,
    fechaAuditoria        DATETIME     DEFAULT CURRENT_TIMESTAMP,
    usuarioAudit          VARCHAR(100) DEFAULT USER(),
    PRIMARY KEY (idAuditoria)
);

-- -----------------------------------------------------------
-- 2.4 paciente_auditoria
-- -----------------------------------------------------------
CREATE TABLE paciente_auditoria (
    idAuditoria       INT          NOT NULL AUTO_INCREMENT,
    idpaciente        INT,
    nombrePaciente    VARCHAR(50),
    documentoPaciente VARCHAR(20),
    direccionPaciente VARCHAR(100),
    fechaNacPaciente  DATE,
    Preexistencias    VARCHAR(500),
    Alergias          VARCHAR(100),
    usuarioFK         INT(10),
    accion            VARCHAR(10)  NOT NULL,
    fechaAuditoria    DATETIME     DEFAULT CURRENT_TIMESTAMP,
    usuarioAudit      VARCHAR(100) DEFAULT USER(),
    PRIMARY KEY (idAuditoria)
);

-- -----------------------------------------------------------
-- 2.5 historiaClinica_auditoria
-- -----------------------------------------------------------
CREATE TABLE historiaClinica_auditoria (
    idAuditoria        INT           NOT NULL AUTO_INCREMENT,
    idHistoriaClinica  INT,
    fechaApertura      DATE,
    estado             VARCHAR(70),
    observaciones      VARCHAR(10000),
    pacienteFK         INT,
    accion             VARCHAR(10)   NOT NULL,
    fechaAuditoria     DATETIME      DEFAULT CURRENT_TIMESTAMP,
    usuarioAudit       VARCHAR(100)  DEFAULT USER(),
    PRIMARY KEY (idAuditoria)
);

-- -----------------------------------------------------------
-- 2.6 anamnesis_auditoria
-- -----------------------------------------------------------
CREATE TABLE anamnesis_auditoria (
    idAuditoria            INT          NOT NULL AUTO_INCREMENT,
    idAnamnesis            INT,
    historiaClinicaFK      INT,
    motivoConsulta         VARCHAR(500),
    enfermedadActual       VARCHAR(1000),
    antecedentesPersonales VARCHAR(500),
    antecedentesFamiliares VARCHAR(500),
    revisionSistemas       VARCHAR(1000),
    fechaRegistro          DATE,
    accion                 VARCHAR(10)  NOT NULL,
    fechaAuditoria         DATETIME     DEFAULT CURRENT_TIMESTAMP,
    usuarioAudit           VARCHAR(100) DEFAULT USER(),
    PRIMARY KEY (idAuditoria)
);

-- -----------------------------------------------------------
-- 2.7 signos_vitales_auditoria
-- -----------------------------------------------------------
CREATE TABLE signos_vitales_auditoria (
    idAuditoria            INT     NOT NULL AUTO_INCREMENT,
    idSignosVitales        INT,
    historiaClinicaFK      INT,
    presionArterial        VARCHAR(20),
    frecuenciaCardiaca     INT,
    frecuenciaRespiratoria INT,
    temperatura            DECIMAL(4,1),
    peso                   DECIMAL(5,2),
    talla                  DECIMAL(4,2),
    imc                    DECIMAL(4,2),
    glucemia               DECIMAL(5,1),
    fechaRegistro          DATE,
    accion                 VARCHAR(10)  NOT NULL,
    fechaAuditoria         DATETIME     DEFAULT CURRENT_TIMESTAMP,
    usuarioAudit           VARCHAR(100) DEFAULT USER(),
    PRIMARY KEY (idAuditoria)
);

-- -----------------------------------------------------------
-- 2.8 habitos_higiene_auditoria
-- -----------------------------------------------------------
CREATE TABLE habitos_higiene_auditoria (
    idAuditoria             INT     NOT NULL AUTO_INCREMENT,
    idHabitosHigiene        INT,
    historiaClinicaFK       INT,
    frecuenciaCepillado     VARCHAR(50),
    usaHilosDental          VARCHAR(10),
    usaEnjuague             VARCHAR(10),
    visitaDentistaPeriodica VARCHAR(10),
    consumoTabaco           VARCHAR(10),
    consumoAlcohol          VARCHAR(10),
    observaciones           VARCHAR(500),
    fechaRegistro           DATE,
    accion                  VARCHAR(10)  NOT NULL,
    fechaAuditoria          DATETIME     DEFAULT CURRENT_TIMESTAMP,
    usuarioAudit            VARCHAR(100) DEFAULT USER(),
    PRIMARY KEY (idAuditoria)
);

-- -----------------------------------------------------------
-- 2.9 medicamentos_auditoria
-- -----------------------------------------------------------
CREATE TABLE medicamentos_auditoria (
    idAuditoria       INT          NOT NULL AUTO_INCREMENT,
    idMedicamento     INT,
    historiaClinicaFK INT,
    nombreMedicamento VARCHAR(100),
    principioActivo   VARCHAR(100),
    dosis             VARCHAR(50),
    frecuencia        VARCHAR(50),
    viaAdministracion VARCHAR(50),
    motivoUso         VARCHAR(200),
    fechaInicio       DATE,
    fechaFin          DATE,
    accion            VARCHAR(10)  NOT NULL,
    fechaAuditoria    DATETIME     DEFAULT CURRENT_TIMESTAMP,
    usuarioAudit      VARCHAR(100) DEFAULT USER(),
    PRIMARY KEY (idAuditoria)
);

-- -----------------------------------------------------------
-- 2.10 pago_auditoria
-- -----------------------------------------------------------
CREATE TABLE pago_auditoria (
    idAuditoria    INT           NOT NULL AUTO_INCREMENT,
    idPago         INT,
    fecha          DATE,
    monto          DECIMAL(12,2),
    metodoPago     VARCHAR(100),
    estado         VARCHAR(50),
    pacienteFK     INT,
    accion         VARCHAR(10)   NOT NULL,
    fechaAuditoria DATETIME      DEFAULT CURRENT_TIMESTAMP,
    usuarioAudit   VARCHAR(100)  DEFAULT USER(),
    PRIMARY KEY (idAuditoria)
);

-- -----------------------------------------------------------
-- 2.11 citaOdontologico_auditoria
-- -----------------------------------------------------------
CREATE TABLE citaOdontologico_auditoria (
    idAuditoria    INT          NOT NULL AUTO_INCREMENT,
    idCita         INT,
    odontologoFK   INT,
    pacienteFK     INT,
    pagoFK         INT,
    horario        DATETIME,
    tratamiento    VARCHAR(100),
    estado         VARCHAR(50),
    accion         VARCHAR(10)  NOT NULL,
    fechaAuditoria DATETIME     DEFAULT CURRENT_TIMESTAMP,
    usuarioAudit   VARCHAR(100) DEFAULT USER(),
    PRIMARY KEY (idAuditoria)
);

-- -----------------------------------------------------------
-- 2.12 evolucion_auditoria
-- -----------------------------------------------------------
CREATE TABLE evolucion_auditoria (
    idAuditoria        INT          NOT NULL AUTO_INCREMENT,
    idEvolucion        INT,
    historiaClinicaFK  INT,
    odontologoFK       INT,
    fechaSesion        DATETIME,
    estadoActual       VARCHAR(1000),
    consultaAnterior   VARCHAR(1000),
    cambiosTratamiento VARCHAR(500),
    respuestaPaciente  VARCHAR(500),
    huboRemision       VARCHAR(10),
    huboInterconsulta  VARCHAR(10),
    cambioProfesional  VARCHAR(10),
    observaciones      VARCHAR(2000),
    accion             VARCHAR(10)  NOT NULL,
    fechaAuditoria     DATETIME     DEFAULT CURRENT_TIMESTAMP,
    usuarioAudit       VARCHAR(100) DEFAULT USER(),
    PRIMARY KEY (idAuditoria)
);

-- -----------------------------------------------------------
-- 2.13 ayuda_diagnostica_auditoria
-- -----------------------------------------------------------
CREATE TABLE ayuda_diagnostica_auditoria (
    idAuditoria            INT          NOT NULL AUTO_INCREMENT,
    idAyuda                INT,
    historiaClinicaFK      INT,
    codigoCIE              VARCHAR(10),
    descripcionDiagnostico VARCHAR(500),
    pronostico             VARCHAR(20),
    rutaArchivo            VARCHAR(500),
    tipoArchivo            VARCHAR(50),
    fechaRegistro          DATE,
    accion                 VARCHAR(10)  NOT NULL,
    fechaAuditoria         DATETIME     DEFAULT CURRENT_TIMESTAMP,
    usuarioAudit           VARCHAR(100) DEFAULT USER(),
    PRIMARY KEY (idAuditoria)
);

-- -----------------------------------------------------------
-- 2.14 plan_tratamiento_auditoria
-- -----------------------------------------------------------
CREATE TABLE plan_tratamiento_auditoria (
    idAuditoria        INT           NOT NULL AUTO_INCREMENT,
    idPlan             INT,
    historiaClinicaFK  INT,
    descripcion        VARCHAR(1000),
    presupuesto        DECIMAL(12,2),
    saldoPendiente     DECIMAL(12,2),
    fechaInicio        DATE,
    fechaFin           DATE,
    estado             VARCHAR(50),
    accion             VARCHAR(10)   NOT NULL,
    fechaAuditoria     DATETIME      DEFAULT CURRENT_TIMESTAMP,
    usuarioAudit       VARCHAR(100)  DEFAULT USER(),
    PRIMARY KEY (idAuditoria)
);

-- -----------------------------------------------------------
-- 2.15 consentimiento_auditoria
-- -----------------------------------------------------------
CREATE TABLE consentimiento_auditoria (
    idAuditoria        INT          NOT NULL AUTO_INCREMENT,
    idConsentimiento   INT,
    historiaClinicaFK  INT,
    procedimiento      VARCHAR(200),
    fechaFirma         DATE,
    firmaPaciente      VARCHAR(20),
    firmaProfesional   VARCHAR(20),
    observaciones      VARCHAR(500),
    accion             VARCHAR(10)  NOT NULL,
    fechaAuditoria     DATETIME     DEFAULT CURRENT_TIMESTAMP,
    usuarioAudit       VARCHAR(100) DEFAULT USER(),
    PRIMARY KEY (idAuditoria)
);

-- -----------------------------------------------------------
-- 2.16 examen_dental_auditoria
-- -----------------------------------------------------------
CREATE TABLE examen_dental_auditoria (
    idAuditoria        INT          NOT NULL AUTO_INCREMENT,
    idExamen           INT,
    historiaClinicaFK  INT,
    hallazgos          TEXT,
    odontograma        VARCHAR(500),
    fechaRegistro      DATE,
    accion             VARCHAR(10)  NOT NULL,
    fechaAuditoria     DATETIME     DEFAULT CURRENT_TIMESTAMP,
    usuarioAudit       VARCHAR(100) DEFAULT USER(),
    PRIMARY KEY (idAuditoria)
);


-- ============================================================
-- SECCIÓN 3: TRIGGERS DE AUDITORÍA (todos juntos)
-- ============================================================

DELIMITER $$

-- ── usuario ─────────────────────────────────────────────────
CREATE TRIGGER trg_usuario_insert AFTER INSERT ON usuario
FOR EACH ROW BEGIN
    INSERT INTO usuario_auditoria
        (idUsuario, nombreUsuario, telefono, correoElectronico,
         tipoDocumento, userName, contrasena, rol, accion)
    VALUES (NEW.idUsuario, NEW.nombreUsuario, NEW.telefono,
            NEW.correoElectronico, NEW.tipoDocumento, NEW.userName,
            NEW.contrasena, NEW.rol, 'INSERT');
END$$

CREATE TRIGGER trg_usuario_update AFTER UPDATE ON usuario
FOR EACH ROW BEGIN
    INSERT INTO usuario_auditoria
        (idUsuario, nombreUsuario, telefono, correoElectronico,
         tipoDocumento, userName, contrasena, rol, accion)
    VALUES (NEW.idUsuario, NEW.nombreUsuario, NEW.telefono,
            NEW.correoElectronico, NEW.tipoDocumento, NEW.userName,
            NEW.contrasena, NEW.rol, 'UPDATE');
END$$

CREATE TRIGGER trg_usuario_delete AFTER DELETE ON usuario
FOR EACH ROW BEGIN
    INSERT INTO usuario_auditoria
        (idUsuario, nombreUsuario, telefono, correoElectronico,
         tipoDocumento, userName, contrasena, rol, accion)
    VALUES (OLD.idUsuario, OLD.nombreUsuario, OLD.telefono,
            OLD.correoElectronico, OLD.tipoDocumento, OLD.userName,
            OLD.contrasena, OLD.rol, 'DELETE');
END$$

-- ── odontologo ───────────────────────────────────────────────
CREATE TRIGGER trg_odontologo_insert AFTER INSERT ON odontologo
FOR EACH ROW BEGIN
    INSERT INTO odontologo_auditoria
        (idOdontologo, tarjetaProfesional, especialidad, usuarioFK, accion)
    VALUES (NEW.idOdontologo, NEW.tarjetaProfesional, NEW.especialidad,
            NEW.usuarioFK, 'INSERT');
END$$

CREATE TRIGGER trg_odontologo_update AFTER UPDATE ON odontologo
FOR EACH ROW BEGIN
    INSERT INTO odontologo_auditoria
        (idOdontologo, tarjetaProfesional, especialidad, usuarioFK, accion)
    VALUES (NEW.idOdontologo, NEW.tarjetaProfesional, NEW.especialidad,
            NEW.usuarioFK, 'UPDATE');
END$$

CREATE TRIGGER trg_odontologo_delete AFTER DELETE ON odontologo
FOR EACH ROW BEGIN
    INSERT INTO odontologo_auditoria
        (idOdontologo, tarjetaProfesional, especialidad, usuarioFK, accion)
    VALUES (OLD.idOdontologo, OLD.tarjetaProfesional, OLD.especialidad,
            OLD.usuarioFK, 'DELETE');
END$$

-- ── auxiliar ─────────────────────────────────────────────────
CREATE TRIGGER trg_auxiliar_insert AFTER INSERT ON auxiliar
FOR EACH ROW BEGIN
    INSERT INTO auxiliar_auditoria
        (idAuxiliar, tarjetaProfesionalAux, usuarioFK, accion)
    VALUES (NEW.idAuxiliar, NEW.tarjetaProfesionalAux, NEW.usuarioFK, 'INSERT');
END$$

CREATE TRIGGER trg_auxiliar_update AFTER UPDATE ON auxiliar
FOR EACH ROW BEGIN
    INSERT INTO auxiliar_auditoria
        (idAuxiliar, tarjetaProfesionalAux, usuarioFK, accion)
    VALUES (NEW.idAuxiliar, NEW.tarjetaProfesionalAux, NEW.usuarioFK, 'UPDATE');
END$$

CREATE TRIGGER trg_auxiliar_delete AFTER DELETE ON auxiliar
FOR EACH ROW BEGIN
    INSERT INTO auxiliar_auditoria
        (idAuxiliar, tarjetaProfesionalAux, usuarioFK, accion)
    VALUES (OLD.idAuxiliar, OLD.tarjetaProfesionalAux, OLD.usuarioFK, 'DELETE');
END$$

-- ── paciente ─────────────────────────────────────────────────
CREATE TRIGGER trg_paciente_insert AFTER INSERT ON paciente
FOR EACH ROW BEGIN
    INSERT INTO paciente_auditoria
        (idpaciente, nombrePaciente, documentoPaciente, direccionPaciente,
         fechaNacPaciente, Preexistencias, Alergias, usuarioFK, accion)
    VALUES (NEW.idpaciente, NEW.nombrePaciente, NEW.documentoPaciente,
            NEW.direccionPaciente, NEW.fechaNacPaciente, NEW.Preexistencias,
            NEW.Alergias, NEW.usuarioFK, 'INSERT');
END$$

CREATE TRIGGER trg_paciente_update AFTER UPDATE ON paciente
FOR EACH ROW BEGIN
    INSERT INTO paciente_auditoria
        (idpaciente, nombrePaciente, documentoPaciente, direccionPaciente,
         fechaNacPaciente, Preexistencias, Alergias, usuarioFK, accion)
    VALUES (NEW.idpaciente, NEW.nombrePaciente, NEW.documentoPaciente,
            NEW.direccionPaciente, NEW.fechaNacPaciente, NEW.Preexistencias,
            NEW.Alergias, NEW.usuarioFK, 'UPDATE');
END$$

CREATE TRIGGER trg_paciente_delete AFTER DELETE ON paciente
FOR EACH ROW BEGIN
    INSERT INTO paciente_auditoria
        (idpaciente, nombrePaciente, documentoPaciente, direccionPaciente,
         fechaNacPaciente, Preexistencias, Alergias, usuarioFK, accion)
    VALUES (OLD.idpaciente, OLD.nombrePaciente, OLD.documentoPaciente,
            OLD.direccionPaciente, OLD.fechaNacPaciente, OLD.Preexistencias,
            OLD.Alergias, OLD.usuarioFK, 'DELETE');
END$$

-- ── historiaClinica ──────────────────────────────────────────
CREATE TRIGGER trg_historia_insert AFTER INSERT ON historiaClinica
FOR EACH ROW BEGIN
    INSERT INTO historiaClinica_auditoria
        (idHistoriaClinica, fechaApertura, estado, observaciones, pacienteFK, accion)
    VALUES (NEW.idHistoriaClinica, NEW.fechaApertura, NEW.estado,
            NEW.observaciones, NEW.pacienteFK, 'INSERT');
END$$

CREATE TRIGGER trg_historia_update AFTER UPDATE ON historiaClinica
FOR EACH ROW BEGIN
    INSERT INTO historiaClinica_auditoria
        (idHistoriaClinica, fechaApertura, estado, observaciones, pacienteFK, accion)
    VALUES (NEW.idHistoriaClinica, NEW.fechaApertura, NEW.estado,
            NEW.observaciones, NEW.pacienteFK, 'UPDATE');
END$$

CREATE TRIGGER trg_historia_delete AFTER DELETE ON historiaClinica
FOR EACH ROW BEGIN
    INSERT INTO historiaClinica_auditoria
        (idHistoriaClinica, fechaApertura, estado, observaciones, pacienteFK, accion)
    VALUES (OLD.idHistoriaClinica, OLD.fechaApertura, OLD.estado,
            OLD.observaciones, OLD.pacienteFK, 'DELETE');
END$$

-- ── anamnesis ────────────────────────────────────────────────
CREATE TRIGGER trg_anamnesis_insert AFTER INSERT ON anamnesis
FOR EACH ROW BEGIN
    INSERT INTO anamnesis_auditoria
        (idAnamnesis, historiaClinicaFK, motivoConsulta, enfermedadActual,
         antecedentesPersonales, antecedentesFamiliares, revisionSistemas,
         fechaRegistro, accion)
    VALUES (NEW.idAnamnesis, NEW.historiaClinicaFK, NEW.motivoConsulta,
            NEW.enfermedadActual, NEW.antecedentesPersonales,
            NEW.antecedentesFamiliares, NEW.revisionSistemas,
            NEW.fechaRegistro, 'INSERT');
END$$

CREATE TRIGGER trg_anamnesis_update AFTER UPDATE ON anamnesis
FOR EACH ROW BEGIN
    INSERT INTO anamnesis_auditoria
        (idAnamnesis, historiaClinicaFK, motivoConsulta, enfermedadActual,
         antecedentesPersonales, antecedentesFamiliares, revisionSistemas,
         fechaRegistro, accion)
    VALUES (NEW.idAnamnesis, NEW.historiaClinicaFK, NEW.motivoConsulta,
            NEW.enfermedadActual, NEW.antecedentesPersonales,
            NEW.antecedentesFamiliares, NEW.revisionSistemas,
            NEW.fechaRegistro, 'UPDATE');
END$$

CREATE TRIGGER trg_anamnesis_delete AFTER DELETE ON anamnesis
FOR EACH ROW BEGIN
    INSERT INTO anamnesis_auditoria
        (idAnamnesis, historiaClinicaFK, motivoConsulta, enfermedadActual,
         antecedentesPersonales, antecedentesFamiliares, revisionSistemas,
         fechaRegistro, accion)
    VALUES (OLD.idAnamnesis, OLD.historiaClinicaFK, OLD.motivoConsulta,
            OLD.enfermedadActual, OLD.antecedentesPersonales,
            OLD.antecedentesFamiliares, OLD.revisionSistemas,
            OLD.fechaRegistro, 'DELETE');
END$$

-- ── signos_vitales ───────────────────────────────────────────
CREATE TRIGGER trg_signos_insert AFTER INSERT ON signos_vitales
FOR EACH ROW BEGIN
    INSERT INTO signos_vitales_auditoria
        (idSignosVitales, historiaClinicaFK, presionArterial,
         frecuenciaCardiaca, frecuenciaRespiratoria, temperatura,
         peso, talla, imc, glucemia, fechaRegistro, accion)
    VALUES (NEW.idSignosVitales, NEW.historiaClinicaFK, NEW.presionArterial,
            NEW.frecuenciaCardiaca, NEW.frecuenciaRespiratoria, NEW.temperatura,
            NEW.peso, NEW.talla, NEW.imc, NEW.glucemia, NEW.fechaRegistro, 'INSERT');
END$$

CREATE TRIGGER trg_signos_update AFTER UPDATE ON signos_vitales
FOR EACH ROW BEGIN
    INSERT INTO signos_vitales_auditoria
        (idSignosVitales, historiaClinicaFK, presionArterial,
         frecuenciaCardiaca, frecuenciaRespiratoria, temperatura,
         peso, talla, imc, glucemia, fechaRegistro, accion)
    VALUES (NEW.idSignosVitales, NEW.historiaClinicaFK, NEW.presionArterial,
            NEW.frecuenciaCardiaca, NEW.frecuenciaRespiratoria, NEW.temperatura,
            NEW.peso, NEW.talla, NEW.imc, NEW.glucemia, NEW.fechaRegistro, 'UPDATE');
END$$

CREATE TRIGGER trg_signos_delete AFTER DELETE ON signos_vitales
FOR EACH ROW BEGIN
    INSERT INTO signos_vitales_auditoria
        (idSignosVitales, historiaClinicaFK, presionArterial,
         frecuenciaCardiaca, frecuenciaRespiratoria, temperatura,
         peso, talla, imc, glucemia, fechaRegistro, accion)
    VALUES (OLD.idSignosVitales, OLD.historiaClinicaFK, OLD.presionArterial,
            OLD.frecuenciaCardiaca, OLD.frecuenciaRespiratoria, OLD.temperatura,
            OLD.peso, OLD.talla, OLD.imc, OLD.glucemia, OLD.fechaRegistro, 'DELETE');
END$$

-- ── habitos_higiene ──────────────────────────────────────────
CREATE TRIGGER trg_habitos_insert AFTER INSERT ON habitos_higiene
FOR EACH ROW BEGIN
    INSERT INTO habitos_higiene_auditoria
        (idHabitosHigiene, historiaClinicaFK, frecuenciaCepillado,
         usaHilosDental, usaEnjuague, visitaDentistaPeriodica,
         consumoTabaco, consumoAlcohol, observaciones, fechaRegistro, accion)
    VALUES (NEW.idHabitosHigiene, NEW.historiaClinicaFK, NEW.frecuenciaCepillado,
            NEW.usaHilosDental, NEW.usaEnjuague, NEW.visitaDentistaPeriodica,
            NEW.consumoTabaco, NEW.consumoAlcohol, NEW.observaciones,
            NEW.fechaRegistro, 'INSERT');
END$$

CREATE TRIGGER trg_habitos_update AFTER UPDATE ON habitos_higiene
FOR EACH ROW BEGIN
    INSERT INTO habitos_higiene_auditoria
        (idHabitosHigiene, historiaClinicaFK, frecuenciaCepillado,
         usaHilosDental, usaEnjuague, visitaDentistaPeriodica,
         consumoTabaco, consumoAlcohol, observaciones, fechaRegistro, accion)
    VALUES (NEW.idHabitosHigiene, NEW.historiaClinicaFK, NEW.frecuenciaCepillado,
            NEW.usaHilosDental, NEW.usaEnjuague, NEW.visitaDentistaPeriodica,
            NEW.consumoTabaco, NEW.consumoAlcohol, NEW.observaciones,
            NEW.fechaRegistro, 'UPDATE');
END$$

CREATE TRIGGER trg_habitos_delete AFTER DELETE ON habitos_higiene
FOR EACH ROW BEGIN
    INSERT INTO habitos_higiene_auditoria
        (idHabitosHigiene, historiaClinicaFK, frecuenciaCepillado,
         usaHilosDental, usaEnjuague, visitaDentistaPeriodica,
         consumoTabaco, consumoAlcohol, observaciones, fechaRegistro, accion)
    VALUES (OLD.idHabitosHigiene, OLD.historiaClinicaFK, OLD.frecuenciaCepillado,
            OLD.usaHilosDental, OLD.usaEnjuague, OLD.visitaDentistaPeriodica,
            OLD.consumoTabaco, OLD.consumoAlcohol, OLD.observaciones,
            OLD.fechaRegistro, 'DELETE');
END$$

-- ── medicamentos ─────────────────────────────────────────────
CREATE TRIGGER trg_medicamentos_insert AFTER INSERT ON medicamentos
FOR EACH ROW BEGIN
    INSERT INTO medicamentos_auditoria
        (idMedicamento, historiaClinicaFK, nombreMedicamento, principioActivo,
         dosis, frecuencia, viaAdministracion, motivoUso, fechaInicio, fechaFin, accion)
    VALUES (NEW.idMedicamento, NEW.historiaClinicaFK, NEW.nombreMedicamento,
            NEW.principioActivo, NEW.dosis, NEW.frecuencia, NEW.viaAdministracion,
            NEW.motivoUso, NEW.fechaInicio, NEW.fechaFin, 'INSERT');
END$$

CREATE TRIGGER trg_medicamentos_update AFTER UPDATE ON medicamentos
FOR EACH ROW BEGIN
    INSERT INTO medicamentos_auditoria
        (idMedicamento, historiaClinicaFK, nombreMedicamento, principioActivo,
         dosis, frecuencia, viaAdministracion, motivoUso, fechaInicio, fechaFin, accion)
    VALUES (NEW.idMedicamento, NEW.historiaClinicaFK, NEW.nombreMedicamento,
            NEW.principioActivo, NEW.dosis, NEW.frecuencia, NEW.viaAdministracion,
            NEW.motivoUso, NEW.fechaInicio, NEW.fechaFin, 'UPDATE');
END$$

CREATE TRIGGER trg_medicamentos_delete AFTER DELETE ON medicamentos
FOR EACH ROW BEGIN
    INSERT INTO medicamentos_auditoria
        (idMedicamento, historiaClinicaFK, nombreMedicamento, principioActivo,
         dosis, frecuencia, viaAdministracion, motivoUso, fechaInicio, fechaFin, accion)
    VALUES (OLD.idMedicamento, OLD.historiaClinicaFK, OLD.nombreMedicamento,
            OLD.principioActivo, OLD.dosis, OLD.frecuencia, OLD.viaAdministracion,
            OLD.motivoUso, OLD.fechaInicio, OLD.fechaFin, 'DELETE');
END$$

-- ── pago ─────────────────────────────────────────────────────
CREATE TRIGGER trg_pago_insert AFTER INSERT ON pago
FOR EACH ROW BEGIN
    INSERT INTO pago_auditoria
        (idPago, fecha, monto, metodoPago, estado, pacienteFK, accion)
    VALUES (NEW.idPago, NEW.fecha, NEW.monto, NEW.metodoPago,
            NEW.estado, NEW.pacienteFK, 'INSERT');
END$$

CREATE TRIGGER trg_pago_update AFTER UPDATE ON pago
FOR EACH ROW BEGIN
    INSERT INTO pago_auditoria
        (idPago, fecha, monto, metodoPago, estado, pacienteFK, accion)
    VALUES (NEW.idPago, NEW.fecha, NEW.monto, NEW.metodoPago,
            NEW.estado, NEW.pacienteFK, 'UPDATE');
END$$

CREATE TRIGGER trg_pago_delete AFTER DELETE ON pago
FOR EACH ROW BEGIN
    INSERT INTO pago_auditoria
        (idPago, fecha, monto, metodoPago, estado, pacienteFK, accion)
    VALUES (OLD.idPago, OLD.fecha, OLD.monto, OLD.metodoPago,
            OLD.estado, OLD.pacienteFK, 'DELETE');
END$$

-- ── citaOdontologico ─────────────────────────────────────────
CREATE TRIGGER trg_cita_insert AFTER INSERT ON citaOdontologico
FOR EACH ROW BEGIN
    INSERT INTO citaOdontologico_auditoria
        (idCita, odontologoFK, pacienteFK, pagoFK, horario, tratamiento, estado, accion)
    VALUES (NEW.idCita, NEW.odontologoFK, NEW.pacienteFK, NEW.pagoFK,
            NEW.horario, NEW.tratamiento, NEW.estado, 'INSERT');
END$$

CREATE TRIGGER trg_cita_update AFTER UPDATE ON citaOdontologico
FOR EACH ROW BEGIN
    INSERT INTO citaOdontologico_auditoria
        (idCita, odontologoFK, pacienteFK, pagoFK, horario, tratamiento, estado, accion)
    VALUES (NEW.idCita, NEW.odontologoFK, NEW.pacienteFK, NEW.pagoFK,
            NEW.horario, NEW.tratamiento, NEW.estado, 'UPDATE');
END$$

CREATE TRIGGER trg_cita_delete AFTER DELETE ON citaOdontologico
FOR EACH ROW BEGIN
    INSERT INTO citaOdontologico_auditoria
        (idCita, odontologoFK, pacienteFK, pagoFK, horario, tratamiento, estado, accion)
    VALUES (OLD.idCita, OLD.odontologoFK, OLD.pacienteFK, OLD.pagoFK,
            OLD.horario, OLD.tratamiento, OLD.estado, 'DELETE');
END$$

-- ── evolucion ────────────────────────────────────────────────
CREATE TRIGGER trg_evolucion_insert AFTER INSERT ON evolucion
FOR EACH ROW BEGIN
    INSERT INTO evolucion_auditoria
        (idEvolucion, historiaClinicaFK, odontologoFK, fechaSesion,
         estadoActual, consultaAnterior, cambiosTratamiento,
         respuestaPaciente, huboRemision, huboInterconsulta,
         cambioProfesional, observaciones, accion)
    VALUES (NEW.idEvolucion, NEW.historiaClinicaFK, NEW.odontologoFK, NEW.fechaSesion,
            NEW.estadoActual, NEW.consultaAnterior, NEW.cambiosTratamiento,
            NEW.respuestaPaciente, NEW.huboRemision, NEW.huboInterconsulta,
            NEW.cambioProfesional, NEW.observaciones, 'INSERT');
END$$

CREATE TRIGGER trg_evolucion_update AFTER UPDATE ON evolucion
FOR EACH ROW BEGIN
    INSERT INTO evolucion_auditoria
        (idEvolucion, historiaClinicaFK, odontologoFK, fechaSesion,
         estadoActual, consultaAnterior, cambiosTratamiento,
         respuestaPaciente, huboRemision, huboInterconsulta,
         cambioProfesional, observaciones, accion)
    VALUES (NEW.idEvolucion, NEW.historiaClinicaFK, NEW.odontologoFK, NEW.fechaSesion,
            NEW.estadoActual, NEW.consultaAnterior, NEW.cambiosTratamiento,
            NEW.respuestaPaciente, NEW.huboRemision, NEW.huboInterconsulta,
            NEW.cambioProfesional, NEW.observaciones, 'UPDATE');
END$$

CREATE TRIGGER trg_evolucion_delete AFTER DELETE ON evolucion
FOR EACH ROW BEGIN
    INSERT INTO evolucion_auditoria
        (idEvolucion, historiaClinicaFK, odontologoFK, fechaSesion,
         estadoActual, consultaAnterior, cambiosTratamiento,
         respuestaPaciente, huboRemision, huboInterconsulta,
         cambioProfesional, observaciones, accion)
    VALUES (OLD.idEvolucion, OLD.historiaClinicaFK, OLD.odontologoFK, OLD.fechaSesion,
            OLD.estadoActual, OLD.consultaAnterior, OLD.cambiosTratamiento,
            OLD.respuestaPaciente, OLD.huboRemision, OLD.huboInterconsulta,
            OLD.cambioProfesional, OLD.observaciones, 'DELETE');
END$$

-- ── ayuda_diagnostica ────────────────────────────────────────
CREATE TRIGGER trg_ayuda_insert AFTER INSERT ON ayuda_diagnostica
FOR EACH ROW BEGIN
    INSERT INTO ayuda_diagnostica_auditoria
        (idAyuda, historiaClinicaFK, codigoCIE, descripcionDiagnostico,
         pronostico, rutaArchivo, tipoArchivo, fechaRegistro, accion)
    VALUES (NEW.idAyuda, NEW.historiaClinicaFK, NEW.codigoCIE, NEW.descripcionDiagnostico,
            NEW.pronostico, NEW.rutaArchivo, NEW.tipoArchivo, NEW.fechaRegistro, 'INSERT');
END$$

CREATE TRIGGER trg_ayuda_update AFTER UPDATE ON ayuda_diagnostica
FOR EACH ROW BEGIN
    INSERT INTO ayuda_diagnostica_auditoria
        (idAyuda, historiaClinicaFK, codigoCIE, descripcionDiagnostico,
         pronostico, rutaArchivo, tipoArchivo, fechaRegistro, accion)
    VALUES (NEW.idAyuda, NEW.historiaClinicaFK, NEW.codigoCIE, NEW.descripcionDiagnostico,
            NEW.pronostico, NEW.rutaArchivo, NEW.tipoArchivo, NEW.fechaRegistro, 'UPDATE');
END$$

CREATE TRIGGER trg_ayuda_delete AFTER DELETE ON ayuda_diagnostica
FOR EACH ROW BEGIN
    INSERT INTO ayuda_diagnostica_auditoria
        (idAyuda, historiaClinicaFK, codigoCIE, descripcionDiagnostico,
         pronostico, rutaArchivo, tipoArchivo, fechaRegistro, accion)
    VALUES (OLD.idAyuda, OLD.historiaClinicaFK, OLD.codigoCIE, OLD.descripcionDiagnostico,
            OLD.pronostico, OLD.rutaArchivo, OLD.tipoArchivo, OLD.fechaRegistro, 'DELETE');
END$$

-- ── plan_tratamiento ─────────────────────────────────────────
CREATE TRIGGER trg_plan_insert AFTER INSERT ON plan_tratamiento
FOR EACH ROW BEGIN
    INSERT INTO plan_tratamiento_auditoria
        (idPlan, historiaClinicaFK, descripcion, presupuesto,
         saldoPendiente, fechaInicio, fechaFin, estado, accion)
    VALUES (NEW.idPlan, NEW.historiaClinicaFK, NEW.descripcion, NEW.presupuesto,
            NEW.saldoPendiente, NEW.fechaInicio, NEW.fechaFin, NEW.estado, 'INSERT');
END$$

CREATE TRIGGER trg_plan_update AFTER UPDATE ON plan_tratamiento
FOR EACH ROW BEGIN
    INSERT INTO plan_tratamiento_auditoria
        (idPlan, historiaClinicaFK, descripcion, presupuesto,
         saldoPendiente, fechaInicio, fechaFin, estado, accion)
    VALUES (NEW.idPlan, NEW.historiaClinicaFK, NEW.descripcion, NEW.presupuesto,
            NEW.saldoPendiente, NEW.fechaInicio, NEW.fechaFin, NEW.estado, 'UPDATE');
END$$

CREATE TRIGGER trg_plan_delete AFTER DELETE ON plan_tratamiento
FOR EACH ROW BEGIN
    INSERT INTO plan_tratamiento_auditoria
        (idPlan, historiaClinicaFK, descripcion, presupuesto,
         saldoPendiente, fechaInicio, fechaFin, estado, accion)
    VALUES (OLD.idPlan, OLD.historiaClinicaFK, OLD.descripcion, OLD.presupuesto,
            OLD.saldoPendiente, OLD.fechaInicio, OLD.fechaFin, OLD.estado, 'DELETE');
END$$

-- ── consentimiento ───────────────────────────────────────────
CREATE TRIGGER trg_consentimiento_insert AFTER INSERT ON consentimiento
FOR EACH ROW BEGIN
    INSERT INTO consentimiento_auditoria
        (idConsentimiento, historiaClinicaFK, procedimiento, fechaFirma,
         firmaPaciente, firmaProfesional, observaciones, accion)
    VALUES (NEW.idConsentimiento, NEW.historiaClinicaFK, NEW.procedimiento, NEW.fechaFirma,
            NEW.firmaPaciente, NEW.firmaProfesional, NEW.observaciones, 'INSERT');
END$$

CREATE TRIGGER trg_consentimiento_update AFTER UPDATE ON consentimiento
FOR EACH ROW BEGIN
    INSERT INTO consentimiento_auditoria
        (idConsentimiento, historiaClinicaFK, procedimiento, fechaFirma,
         firmaPaciente, firmaProfesional, observaciones, accion)
    VALUES (NEW.idConsentimiento, NEW.historiaClinicaFK, NEW.procedimiento, NEW.fechaFirma,
            NEW.firmaPaciente, NEW.firmaProfesional, NEW.observaciones, 'UPDATE');
END$$

CREATE TRIGGER trg_consentimiento_delete AFTER DELETE ON consentimiento
FOR EACH ROW BEGIN
    INSERT INTO consentimiento_auditoria
        (idConsentimiento, historiaClinicaFK, procedimiento, fechaFirma,
         firmaPaciente, firmaProfesional, observaciones, accion)
    VALUES (OLD.idConsentimiento, OLD.historiaClinicaFK, OLD.procedimiento, OLD.fechaFirma,
            OLD.firmaPaciente, OLD.firmaProfesional, OLD.observaciones, 'DELETE');
END$$

-- ── examen_dental ────────────────────────────────────────────
CREATE TRIGGER trg_examen_insert AFTER INSERT ON examen_dental
FOR EACH ROW BEGIN
    INSERT INTO examen_dental_auditoria
        (idExamen, historiaClinicaFK, hallazgos, odontograma, fechaRegistro, accion)
    VALUES (NEW.idExamen, NEW.historiaClinicaFK, NEW.hallazgos, NEW.odontograma,
            NEW.fechaRegistro, 'INSERT');
END$$

CREATE TRIGGER trg_examen_update AFTER UPDATE ON examen_dental
FOR EACH ROW BEGIN
    INSERT INTO examen_dental_auditoria
        (idExamen, historiaClinicaFK, hallazgos, odontograma, fechaRegistro, accion)
    VALUES (NEW.idExamen, NEW.historiaClinicaFK, NEW.hallazgos, NEW.odontograma,
            NEW.fechaRegistro, 'UPDATE');
END$$

CREATE TRIGGER trg_examen_delete AFTER DELETE ON examen_dental
FOR EACH ROW BEGIN
    INSERT INTO examen_dental_auditoria
        (idExamen, historiaClinicaFK, hallazgos, odontograma, fechaRegistro, accion)
    VALUES (OLD.idExamen, OLD.historiaClinicaFK, OLD.hallazgos, OLD.odontograma,
            OLD.fechaRegistro, 'DELETE');
END$$

DELIMITER ;


-- ============================================================
-- SECCIÓN 4: CONSULTAS POR REQUISITO FUNCIONAL
-- ============================================================
-- @variable = parámetro que viene de la aplicación.
-- Reemplazar o pasar como bind parameter desde el backend.
-- ============================================================


-- Requisito RQF-IniciarSesion: Iniciar sesión
-- Requisito RQF34: Control de acceso al sistema (Login)
-- ============================================================
-- RQF – INICIAR SESIÓN / RQF34 – CONTROL DE ACCESO
-- ============================================================

-- Verificar credenciales (login)
-- La app compara el hash de la contraseña ingresada contra
-- el campo contrasena; nunca comparar texto plano.
SELECT idUsuario,
       nombreUsuario,
       correoElectronico,
       rol
FROM   usuario
WHERE  userName   = @userName
  AND  contrasena = @hashContrasena;


-- Requisito RQF-CrearUsuario: Crear usuario
-- Requisito RQF-AsignarRol: Asignar y modificar rol
-- Requisito RQF-ActualizarEstado: Actualizar estado de usuario
-- Requisito RQF18: Gestión de usuarios y permisos (Roles)
-- ============================================================
-- RQF – GESTIÓN DE USUARIOS / RQF18 – ROLES
-- ============================================================

-- Consultar todos los usuarios con su rol
SELECT idUsuario,
       nombreUsuario,
       correoElectronico,
       tipoDocumento,
       telefono,
       rol
FROM   usuario
ORDER  BY rol, nombreUsuario;

-- Consultar usuarios por rol específico
-- @rolBuscado: 'Paciente' | 'Odontologo' | 'Auxiliar' | 'Admin'
SELECT idUsuario,
       nombreUsuario,
       correoElectronico,
       telefono,
       rol
FROM   usuario
WHERE  rol = @rolBuscado
ORDER  BY nombreUsuario;

-- Consultar staff con especialidad (todos excepto Paciente e Inactivo)
SELECT u.idUsuario,
       u.nombreUsuario,
       u.correoElectronico,
       u.telefono,
       u.rol,
       CASE WHEN o.idOdontologo IS NOT NULL THEN o.especialidad ELSE 'N/A' END AS especialidad
FROM   usuario u
LEFT   JOIN odontologo o ON o.usuarioFK = u.idUsuario
WHERE  u.rol NOT IN ('Paciente', 'Inactivo')
ORDER  BY u.rol, u.nombreUsuario;

-- Actualizar rol de un usuario
-- @nuevoRol, @idUsuario
UPDATE usuario
SET    rol = @nuevoRol
WHERE  idUsuario = @idUsuario;

-- Desactivar usuario (RQF – Actualizar estado)
UPDATE usuario
SET    rol = 'Inactivo'
WHERE  idUsuario = @idUsuario;


-- Requisito RQF-RegistrarPaciente: Registrar paciente
-- Requisito RQF-ConsultarInfoGeneral: Consultar información general
-- Requisito RQF-ActualizarInfoGeneral: Actualizar información general
-- Requisito RQF07: Edición y actualización de datos personales
-- ============================================================
-- RQF – INFORMACIÓN GENERAL DEL PACIENTE / RQF07 – EDICIÓN
-- ============================================================

-- Consultar información general de un paciente
-- @idPaciente
SELECT p.idpaciente,
       p.nombrePaciente,
       p.documentoPaciente,
       p.direccionPaciente,
       p.fechaNacPaciente,
       TIMESTAMPDIFF(YEAR, p.fechaNacPaciente, CURDATE()) AS edadActual,
       p.Preexistencias,
       p.Alergias,
       u.telefono,
       u.correoElectronico,
       u.tipoDocumento
FROM   paciente p
INNER  JOIN usuario u ON p.usuarioFK = u.idUsuario
WHERE  p.idpaciente = @idPaciente;

-- Actualizar datos personales del paciente (RQF07)
-- @nombrePaciente, @direccionPaciente, @Preexistencias, @Alergias, @idPaciente
UPDATE paciente
SET    nombrePaciente    = @nombrePaciente,
       direccionPaciente = @direccionPaciente,
       Preexistencias    = @Preexistencias,
       Alergias          = @Alergias
WHERE  idpaciente = @idPaciente;

-- Actualizar datos de contacto del usuario asociado
-- @telefono, @correoElectronico, @idUsuario
UPDATE usuario
SET    telefono          = @telefono,
       correoElectronico = @correoElectronico
WHERE  idUsuario = @idUsuario;


-- Requisito RQF03: Búsqueda de historia clínica por parámetros (nombre, cédula, teléfono)
-- ============================================================
-- RQF03 – BÚSQUEDA DE HISTORIA CLÍNICA POR PARÁMETROS
-- ============================================================

-- Búsqueda flexible por nombre, cédula o teléfono
-- @termino
SELECT p.idpaciente,
       p.nombrePaciente,
       p.documentoPaciente,
       u.telefono,
       hc.idHistoriaClinica,
       hc.fechaApertura,
       hc.estado AS estadoHistoria
FROM   paciente p
INNER  JOIN usuario         u  ON p.usuarioFK   = u.idUsuario
LEFT   JOIN historiaClinica hc ON hc.pacienteFK = p.idpaciente
WHERE  p.nombrePaciente    LIKE CONCAT('%', @termino, '%')
   OR  p.documentoPaciente LIKE CONCAT('%', @termino, '%')
   OR  u.telefono           LIKE CONCAT('%', @termino, '%')
ORDER  BY p.nombrePaciente;

-- Por nombre exacto
SELECT p.idpaciente, p.nombrePaciente, p.documentoPaciente, hc.idHistoriaClinica
FROM   paciente p
INNER  JOIN historiaClinica hc ON hc.pacienteFK = p.idpaciente
WHERE  p.nombrePaciente = @nombrePaciente;

-- Por cédula
SELECT p.idpaciente, p.nombrePaciente, p.documentoPaciente, hc.idHistoriaClinica
FROM   paciente p
INNER  JOIN historiaClinica hc ON hc.pacienteFK = p.idpaciente
WHERE  p.documentoPaciente = @documentoPaciente;

-- Por teléfono
SELECT p.idpaciente, p.nombrePaciente, u.telefono, hc.idHistoriaClinica
FROM   paciente p
INNER  JOIN usuario         u  ON p.usuarioFK   = u.idUsuario
INNER  JOIN historiaClinica hc ON hc.pacienteFK = p.idpaciente
WHERE  u.telefono = @telefono;


-- Requisito RQF01: Creación de historias clínicas
-- ============================================================
-- RQF01 – HISTORIA CLÍNICA COMPLETA
-- ============================================================

-- @idHistoriaClinica
SELECT hc.idHistoriaClinica,
       hc.fechaApertura,
       hc.estado,
       hc.observaciones,
       p.nombrePaciente,
       p.documentoPaciente,
       p.fechaNacPaciente,
       TIMESTAMPDIFF(YEAR, p.fechaNacPaciente, CURDATE()) AS edad,
       p.Preexistencias,
       p.Alergias,
       u.telefono,
       u.correoElectronico
FROM   historiaClinica hc
INNER  JOIN paciente p ON hc.pacienteFK = p.idpaciente
INNER  JOIN usuario  u ON p.usuarioFK   = u.idUsuario
WHERE  hc.idHistoriaClinica = @idHistoriaClinica;


-- Requisito RQF-RegistrarAnamnesis: Registrar anamnesis (alergias, embarazos, medicamentos, antecedentes familiares)
-- Requisito RQF-ConsultarAnamnesis: Consultar anamnesis
-- Requisito RQF-ActualizarAnamnesis: Actualizar anamnesis
-- ============================================================
-- RQF – ANAMNESIS
-- ============================================================

-- Consultar anamnesis de una historia clínica
-- @idHistoriaClinica
SELECT idAnamnesis,
       motivoConsulta,
       enfermedadActual,
       antecedentesPersonales,
       antecedentesFamiliares,
       revisionSistemas,
       fechaRegistro
FROM   anamnesis
WHERE  historiaClinicaFK = @idHistoriaClinica
ORDER  BY fechaRegistro DESC;

-- Actualizar anamnesis
-- @motivoConsulta, @enfermedadActual, @antecedentesPersonales,
-- @antecedentesFamiliares, @revisionSistemas, @idAnamnesis
UPDATE anamnesis
SET    motivoConsulta         = @motivoConsulta,
       enfermedadActual       = @enfermedadActual,
       antecedentesPersonales = @antecedentesPersonales,
       antecedentesFamiliares = @antecedentesFamiliares,
       revisionSistemas       = @revisionSistemas,
       fechaRegistro          = CURDATE()
WHERE  idAnamnesis = @idAnamnesis;


-- Requisito RQF-RegistrarSignosVitales: Registrar signos vitales (pulso, tensión arterial, temperatura, frecuencia respiratoria)
-- Requisito RQF-ConsultarSignosVitales: Consultar signos vitales
-- Requisito RQF-ActualizarSignosVitales: Actualizar signos vitales
-- ============================================================
-- RQF – SIGNOS VITALES
-- ============================================================

-- Consultar todos los registros de signos vitales
-- @idHistoriaClinica
SELECT idSignosVitales,
       presionArterial,
       frecuenciaCardiaca,
       frecuenciaRespiratoria,
       temperatura,
       peso,
       talla,
       imc,
       glucemia,
       fechaRegistro
FROM   signos_vitales
WHERE  historiaClinicaFK = @idHistoriaClinica
ORDER  BY fechaRegistro DESC;

-- Último registro de signos vitales
-- @idHistoriaClinica
SELECT presionArterial, frecuenciaCardiaca, frecuenciaRespiratoria,
       temperatura, peso, talla, imc, glucemia, fechaRegistro
FROM   signos_vitales
WHERE  historiaClinicaFK = @idHistoriaClinica
ORDER  BY fechaRegistro DESC
LIMIT  1;

-- Actualizar signos vitales
-- @presionArterial, @frecuenciaCardiaca, @frecuenciaRespiratoria,
-- @temperatura, @peso, @talla, @imc, @glucemia, @idSignosVitales
UPDATE signos_vitales
SET    presionArterial        = @presionArterial,
       frecuenciaCardiaca     = @frecuenciaCardiaca,
       frecuenciaRespiratoria = @frecuenciaRespiratoria,
       temperatura            = @temperatura,
       peso                   = @peso,
       talla                  = @talla,
       imc                    = @imc,
       glucemia               = @glucemia,
       fechaRegistro          = CURDATE()
WHERE  idSignosVitales = @idSignosVitales;


-- Requisito RQF-RegistrarHabitos: Registrar hábitos de higiene oral (cepillado, seda dental, enjuague bucal)
-- Requisito RQF-RegistrarFrecuenciaHabitos: Registrar frecuencia de hábitos de higiene oral
-- Requisito RQF-ActualizarHabitos: Actualizar hábitos de higiene oral
-- ============================================================
-- RQF – HÁBITOS DE HIGIENE ORAL
-- ============================================================

-- Consultar hábitos de higiene
-- @idHistoriaClinica
SELECT idHabitosHigiene,
       frecuenciaCepillado,
       usaHilosDental,
       usaEnjuague,
       visitaDentistaPeriodica,
       consumoTabaco,
       consumoAlcohol,
       observaciones,
       fechaRegistro
FROM   habitos_higiene
WHERE  historiaClinicaFK = @idHistoriaClinica
ORDER  BY fechaRegistro DESC;

-- Actualizar hábitos de higiene oral
-- @frecuenciaCepillado, @usaHilosDental, @usaEnjuague,
-- @visitaDentistaPeriodica, @consumoTabaco, @consumoAlcohol,
-- @observaciones, @idHabitosHigiene
UPDATE habitos_higiene
SET    frecuenciaCepillado     = @frecuenciaCepillado,
       usaHilosDental          = @usaHilosDental,
       usaEnjuague             = @usaEnjuague,
       visitaDentistaPeriodica = @visitaDentistaPeriodica,
       consumoTabaco           = @consumoTabaco,
       consumoAlcohol          = @consumoAlcohol,
       observaciones           = @observaciones,
       fechaRegistro           = CURDATE()
WHERE  idHabitosHigiene = @idHabitosHigiene;


-- Requisito RQF11: Registro de medicamentos formulados
-- ============================================================
-- RQF11 – MEDICAMENTOS FORMULADOS
-- ============================================================

-- Consultar todos los medicamentos de una historia clínica
-- @idHistoriaClinica
SELECT idMedicamento,
       nombreMedicamento,
       principioActivo,
       dosis,
       frecuencia,
       viaAdministracion,
       motivoUso,
       fechaInicio,
       fechaFin
FROM   medicamentos
WHERE  historiaClinicaFK = @idHistoriaClinica
ORDER  BY fechaInicio DESC;

-- Consultar solo medicamentos activos
-- @idHistoriaClinica
SELECT nombreMedicamento, principioActivo, dosis,
       frecuencia, viaAdministracion, motivoUso, fechaInicio, fechaFin
FROM   medicamentos
WHERE  historiaClinicaFK = @idHistoriaClinica
  AND  (fechaFin IS NULL OR fechaFin >= CURDATE())
ORDER  BY fechaInicio DESC;


-- Requisito RQF-RegistrarExamenDental: Registrar examen dental
-- Requisito RQF-ConsultarExamenDental: Consultar examen dental
-- Requisito RQF-RegistrarOdontograma: Registrar odontograma
-- Requisito RQF-ConsultarOdontograma: Consultar odontograma
-- ============================================================
-- RQF – EXAMEN DENTAL Y ODONTOGRAMA
-- ============================================================

-- Consultar examen dental (odontograma = URL de imagen externa)
-- @idHistoriaClinica
SELECT idExamen,
       hallazgos,
       odontograma,
       fechaRegistro
FROM   examen_dental
WHERE  historiaClinicaFK = @idHistoriaClinica
ORDER  BY fechaRegistro DESC;

-- Actualizar examen dental
-- @hallazgos, @odontograma (URL), @idExamen
UPDATE examen_dental
SET    hallazgos     = @hallazgos,
       odontograma   = @odontograma,
       fechaRegistro = CURDATE()
WHERE  idExamen = @idExamen;


-- Requisito RQF02: Registro de consentimiento por cada procedimiento
-- Requisito RQF26: Registro de firma del profesional
-- Requisito RQF27: Registro de firma del paciente
-- ============================================================
-- RQF02 – CONSENTIMIENTO POR PROCEDIMIENTO
-- RQF26 – FIRMA DEL PROFESIONAL / RQF27 – FIRMA DEL PACIENTE
-- ============================================================

-- Consultar consentimientos de una historia clínica
-- @idHistoriaClinica
SELECT idConsentimiento,
       procedimiento,
       fechaFirma,
       firmaPaciente,
       firmaProfesional,
       observaciones
FROM   consentimiento
WHERE  historiaClinicaFK = @idHistoriaClinica
ORDER  BY fechaFirma DESC;

-- Consentimientos con firma pendiente
-- @idHistoriaClinica
SELECT idConsentimiento,
       procedimiento,
       fechaFirma,
       firmaPaciente,
       firmaProfesional
FROM   consentimiento
WHERE  historiaClinicaFK = @idHistoriaClinica
  AND  (firmaPaciente = 'Pendiente' OR firmaProfesional = 'Pendiente');

-- Registrar firma del paciente (RQF27)
UPDATE consentimiento
SET    firmaPaciente = 'Firmado'
WHERE  idConsentimiento = @idConsentimiento;

-- Registrar firma del profesional (RQF26)
UPDATE consentimiento
SET    firmaProfesional = 'Firmado'
WHERE  idConsentimiento = @idConsentimiento;


-- Requisito RQF04: Calidad de seguimiento clínico (estado actual vs consulta anterior, cambios en tratamiento, respuesta del paciente)
-- Requisito RQF05: Registrar si hubo interconsulta, remisión o cambio de profesional desde la última atención
-- Requisito RQF08: Visualización de las evoluciones
-- Requisito RQF09: Edición de evoluciones clínicas
-- Requisito RQF28: Registro detallado de evolución por sesión
-- ============================================================
-- RQF04 – SEGUIMIENTO CLÍNICO / RQF08 – VER EVOLUCIONES
-- RQF09 – EDITAR EVOLUCIONES  / RQF28 – DETALLE POR SESIÓN
-- ============================================================

-- Consultar todas las evoluciones de una historia clínica
-- @idHistoriaClinica
SELECT e.idEvolucion,
       e.fechaSesion,
       u.nombreUsuario    AS nombreOdontologo,
       e.estadoActual,
       e.consultaAnterior,
       e.cambiosTratamiento,
       e.respuestaPaciente,
       e.huboRemision,
       e.huboInterconsulta,
       e.cambioProfesional,
       e.observaciones
FROM   evolucion e
INNER  JOIN odontologo od ON e.odontologoFK = od.idOdontologo
INNER  JOIN usuario    u  ON od.usuarioFK   = u.idUsuario
WHERE  e.historiaClinicaFK = @idHistoriaClinica
ORDER  BY e.fechaSesion DESC;

-- Última evolución registrada
-- @idHistoriaClinica
SELECT e.fechaSesion,
       u.nombreUsuario AS nombreOdontologo,
       e.estadoActual,
       e.consultaAnterior,
       e.cambiosTratamiento,
       e.respuestaPaciente
FROM   evolucion e
INNER  JOIN odontologo od ON e.odontologoFK = od.idOdontologo
INNER  JOIN usuario    u  ON od.usuarioFK   = u.idUsuario
WHERE  e.historiaClinicaFK = @idHistoriaClinica
ORDER  BY e.fechaSesion DESC
LIMIT  1;

-- Editar una evolución (RQF09)
-- @estadoActual, @cambiosTratamiento, @respuestaPaciente,
-- @huboRemision, @huboInterconsulta, @cambioProfesional,
-- @observaciones, @idEvolucion
UPDATE evolucion
SET    estadoActual       = @estadoActual,
       cambiosTratamiento = @cambiosTratamiento,
       respuestaPaciente  = @respuestaPaciente,
       huboRemision       = @huboRemision,
       huboInterconsulta  = @huboInterconsulta,
       cambioProfesional  = @cambioProfesional,
       observaciones      = @observaciones
WHERE  idEvolucion = @idEvolucion;


-- Requisito RQF05: Control de asistencia a citas (confirmada asistida, confirmada no asistida, cancelada, reprogramada)
-- ============================================================
-- RQF05 – CONTROL DE ASISTENCIA A CITAS
-- ============================================================

-- Consultar citas de un paciente con estado de asistencia
-- @idPaciente
SELECT c.idCita,
       c.horario,
       c.tratamiento,
       c.estado,
       u.nombreUsuario AS nombreOdontologo
FROM   citaOdontologico c
INNER  JOIN odontologo od ON c.odontologoFK = od.idOdontologo
INNER  JOIN usuario    u  ON od.usuarioFK   = u.idUsuario
WHERE  c.pacienteFK = @idPaciente
ORDER  BY c.horario DESC;

-- Actualizar estado de una cita
-- @estado: 'Confirmada Asistida' | 'Confirmada No Asistida' |
--          'Cancelada' | 'Reprogramada' | 'Pendiente'
-- @idCita
UPDATE citaOdontologico
SET    estado = @estado
WHERE  idCita = @idCita;


-- Requisito RQF06: Clasificación de historias por preexistencias sistémicas
-- Requisito RQF10: Alertas clínicas automatizadas / Búsqueda de pacientes por preexistencias categóricas
-- Requisito RQF29: Registro de preexistencias y antecedentes
-- Requisito RQF30: Búsqueda de pacientes por preexistencia específica
-- Requisito RQF31: Búsqueda de pacientes por categoría de preexistencia
-- ============================================================
-- RQF06 – CLASIFICACIÓN POR PREEXISTENCIAS
-- RQF10 / RQF30 / RQF31 – BÚSQUEDA POR PREEXISTENCIA
-- RQF29 – ACTUALIZAR PREEXISTENCIAS Y ANTECEDENTES
-- ============================================================

-- Buscar pacientes por preexistencia específica (RQF30)
-- @preexistencia: ej. 'diabetes', 'hipertension'
SELECT p.idpaciente,
       p.nombrePaciente,
       p.documentoPaciente,
       p.Preexistencias,
       p.Alergias,
       hc.idHistoriaClinica
FROM   paciente p
LEFT   JOIN historiaClinica hc ON hc.pacienteFK = p.idpaciente
WHERE  p.Preexistencias LIKE CONCAT('%', @preexistencia, '%')
ORDER  BY p.nombrePaciente;

-- Buscar por categoría de preexistencia (RQF31)
-- @categoriaPreexistencia: ej. 'cardiovascular', 'endocrina'
SELECT p.idpaciente,
       p.nombrePaciente,
       p.documentoPaciente,
       p.Preexistencias
FROM   paciente p
WHERE  p.Preexistencias LIKE CONCAT('%', @categoriaPreexistencia, '%')
   OR  p.Alergias       LIKE CONCAT('%', @categoriaPreexistencia, '%')
ORDER  BY p.nombrePaciente;

-- Listado de pacientes con alguna preexistencia (RQF06)
SELECT p.idpaciente,
       p.nombrePaciente,
       p.documentoPaciente,
       p.Preexistencias,
       p.Alergias,
       hc.idHistoriaClinica,
       hc.estado AS estadoHistoria
FROM   paciente p
INNER  JOIN historiaClinica hc ON hc.pacienteFK = p.idpaciente
WHERE  p.Preexistencias IS NOT NULL
  AND  p.Preexistencias NOT IN ('', 'Ninguna')
ORDER  BY p.Preexistencias, p.nombrePaciente;

-- Actualizar preexistencias (RQF29)
-- @Preexistencias, @Alergias, @idPaciente
UPDATE paciente
SET    Preexistencias = @Preexistencias,
       Alergias       = @Alergias
WHERE  idpaciente = @idPaciente;


-- Requisito RQF13: Registro de ayudas diagnósticas
-- Requisito RQF-RegistrarDiagnosticoCIE: Registrar diagnóstico con CIE
-- Requisito RQF-ConsultarDiagnostico: Consultar diagnóstico
-- Requisito RQF-RegistrarPronostico: Registrar pronóstico por paciente (bueno, malo, reservado)
-- Requisito RQF-ConsultarPronostico: Consultar pronóstico
-- Requisito RQF24: Anexos de ayudas diagnósticas (archivos)
-- Requisito RQF25: Vinculación de planes de tratamiento a ayudas diagnósticas
-- ============================================================
-- RQF13 – AYUDAS DIAGNÓSTICAS
-- ============================================================

-- Consultar ayudas diagnósticas de una historia clínica
-- @idHistoriaClinica
SELECT idAyuda,
       codigoCIE,
       descripcionDiagnostico,
       pronostico,
       rutaArchivo,
       tipoArchivo,
       fechaRegistro
FROM   ayuda_diagnostica
WHERE  historiaClinicaFK = @idHistoriaClinica
ORDER  BY fechaRegistro DESC;

-- Buscar diagnóstico por código CIE en todos los pacientes
-- @codigoCIE: ej. 'K02.1'
SELECT ad.codigoCIE,
       ad.descripcionDiagnostico,
       ad.pronostico,
       p.nombrePaciente,
       p.documentoPaciente,
       ad.fechaRegistro
FROM   ayuda_diagnostica ad
INNER  JOIN historiaClinica hc ON ad.historiaClinicaFK = hc.idHistoriaClinica
INNER  JOIN paciente        p  ON hc.pacienteFK        = p.idpaciente
WHERE  ad.codigoCIE = @codigoCIE
ORDER  BY ad.fechaRegistro DESC;


-- Requisito RQF14: Gestión de planes de tratamiento
-- Requisito RQF-RegistrarPresupuesto: Registrar presupuesto de tratamiento
-- Requisito RQF-ConsultarPresupuesto: Consultar presupuesto del tratamiento
-- ============================================================
-- RQF14 – PLANES DE TRATAMIENTO
-- ============================================================

-- Consultar planes de tratamiento de una historia clínica
-- @idHistoriaClinica
SELECT idPlan,
       descripcion,
       presupuesto,
       saldoPendiente,
       fechaInicio,
       fechaFin,
       estado
FROM   plan_tratamiento
WHERE  historiaClinicaFK = @idHistoriaClinica
ORDER  BY fechaInicio DESC;

-- Actualizar estado y saldo de un plan
-- @estado, @saldoPendiente, @idPlan
UPDATE plan_tratamiento
SET    estado         = @estado,
       saldoPendiente = @saldoPendiente
WHERE  idPlan = @idPlan;


-- Requisito RQF15: Reportes y estadísticas de atención
-- ============================================================
-- RQF15 – REPORTES Y ESTADÍSTICAS
-- ============================================================

-- Pacientes atendidos por mes en el año actual
SELECT YEAR(horario)                AS anio,
       MONTH(horario)               AS mes,
       MONTHNAME(horario)           AS nombreMes,
       COUNT(DISTINCT pacienteFK)   AS totalPacientes,
       COUNT(idCita)                AS totalCitas
FROM   citaOdontologico
WHERE  YEAR(horario) = YEAR(CURDATE())
  AND  estado = 'Confirmada Asistida'
GROUP  BY YEAR(horario), MONTH(horario)
ORDER  BY mes;

-- Citas por odontólogo con desglose de estados
SELECT u.nombreUsuario  AS nombreOdontologo,
       o.especialidad,
       COUNT(c.idCita)  AS totalCitas,
       SUM(CASE WHEN c.estado = 'Confirmada Asistida'    THEN 1 ELSE 0 END) AS asistidas,
       SUM(CASE WHEN c.estado = 'Confirmada No Asistida' THEN 1 ELSE 0 END) AS noAsistidas,
       SUM(CASE WHEN c.estado = 'Cancelada'              THEN 1 ELSE 0 END) AS canceladas
FROM   citaOdontologico c
INNER  JOIN odontologo od ON c.odontologoFK = od.idOdontologo
INNER  JOIN usuario    u  ON od.usuarioFK   = u.idUsuario
GROUP  BY od.idOdontologo, u.nombreUsuario, o.especialidad
ORDER  BY totalCitas DESC;

-- Tratamientos más frecuentes
SELECT tratamiento,
       COUNT(*) AS frecuencia
FROM   citaOdontologico
WHERE  tratamiento IS NOT NULL
GROUP  BY tratamiento
ORDER  BY frecuencia DESC;

-- Ingresos por mes en el año actual
SELECT YEAR(fecha)      AS anio,
       MONTH(fecha)     AS mes,
       MONTHNAME(fecha) AS nombreMes,
       SUM(monto)       AS ingresoTotal,
       COUNT(idPago)    AS numeroPagos
FROM   pago
WHERE  YEAR(fecha) = YEAR(CURDATE())
GROUP  BY YEAR(fecha), MONTH(fecha)
ORDER  BY mes;


-- Requisito RQF16: Gestión de citas
-- Requisito RQF-CreacionCitas: Creación de citas médicas
-- Requisito RQF17: Notificaciones de citas próximas
-- Requisito RQF-BusquedaCitasFecha: Búsqueda de citas por fecha (mes, día, año)
-- ============================================================
-- RQF16 – GESTIÓN DE CITAS / RQF17 – BÚSQUEDA POR FECHA
-- ============================================================

-- Agenda de un odontólogo para una fecha
-- @idOdontologo, @fecha
SELECT c.idCita,
       c.horario,
       p.nombrePaciente,
       p.documentoPaciente,
       u.telefono        AS telefonoPaciente,
       c.tratamiento,
       c.estado
FROM   citaOdontologico c
INNER  JOIN paciente p ON c.pacienteFK = p.idpaciente
INNER  JOIN usuario  u ON p.usuarioFK  = u.idUsuario
WHERE  c.odontologoFK = @idOdontologo
  AND  DATE(c.horario) = @fecha
ORDER  BY c.horario;

-- Búsqueda de citas por año
-- @anio
SELECT c.idCita, c.horario, p.nombrePaciente, c.tratamiento, c.estado
FROM   citaOdontologico c
INNER  JOIN paciente p ON c.pacienteFK = p.idpaciente
WHERE  YEAR(c.horario) = @anio
ORDER  BY c.horario;

-- Búsqueda de citas por mes y año
-- @mes (1-12), @anio
SELECT c.idCita, c.horario, p.nombrePaciente, c.tratamiento, c.estado
FROM   citaOdontologico c
INNER  JOIN paciente p ON c.pacienteFK = p.idpaciente
WHERE  MONTH(c.horario) = @mes
  AND  YEAR(c.horario)  = @anio
ORDER  BY c.horario;

-- Citas próximas en los siguientes 7 días (notificaciones — RQF17)
SELECT c.idCita,
       c.horario,
       p.nombrePaciente,
       u.telefono         AS telefonoPaciente,
       u.correoElectronico,
       c.tratamiento,
       c.estado
FROM   citaOdontologico c
INNER  JOIN paciente p ON c.pacienteFK = p.idpaciente
INNER  JOIN usuario  u ON p.usuarioFK  = u.idUsuario
WHERE  c.horario BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
  AND  c.estado  NOT IN ('Cancelada', 'Confirmada Asistida')
ORDER  BY c.horario;

-- Citas por estado específico
-- @estado
SELECT c.idCita, c.horario, p.nombrePaciente, c.tratamiento, c.estado
FROM   citaOdontologico c
INNER  JOIN paciente p ON c.pacienteFK = p.idpaciente
WHERE  c.estado = @estado
ORDER  BY c.horario DESC;


-- Requisito RQF19: Copia de seguridad y recuperación de datos
-- Requisito RQF-AlmacenamientoDatos: Almacenamiento de datos
-- ============================================================
-- RQF19 – ALMACENAMIENTO / VERIFICACIÓN DE DATOS
-- ============================================================

-- Verificar tablas y cantidad de registros
SELECT table_name                            AS tabla,
       table_rows                            AS filas_estimadas,
       ROUND(data_length  / 1024, 2)         AS datos_KB,
       ROUND(index_length / 1024, 2)         AS indices_KB,
       create_time                           AS fecha_creacion,
       update_time                           AS ultima_modificacion
FROM   information_schema.tables
WHERE  table_schema = 'clinicaodontologica'
ORDER  BY table_name;


-- Requisito RQF21: Validación de duplicados por identificación
-- ============================================================
-- RQF21 – VALIDACIÓN DE DUPLICADOS
-- ============================================================

-- Verificar si un documento ya existe
-- @documentoPaciente
SELECT COUNT(*) AS existe, nombrePaciente, documentoPaciente
FROM   paciente
WHERE  documentoPaciente = @documentoPaciente
GROUP  BY nombrePaciente, documentoPaciente;

-- Verificar si un userName ya está en uso
-- @userName
SELECT COUNT(*) AS existe
FROM   usuario
WHERE  userName = @userName;


-- Requisito RQF23: Visualización de resultados de búsqueda
-- Requisito RQF-ResultadosConsulta: Resultados de consulta
-- ============================================================
-- RQF23 – RESULTADOS DE CONSULTA GENERAL
-- ============================================================

-- Vista general de todos los pacientes con su historia clínica
SELECT p.idpaciente,
       p.nombrePaciente,
       p.documentoPaciente,
       TIMESTAMPDIFF(YEAR, p.fechaNacPaciente, CURDATE()) AS edad,
       p.Preexistencias,
       hc.idHistoriaClinica,
       hc.fechaApertura,
       hc.estado AS estadoHistoria
FROM   paciente p
LEFT   JOIN historiaClinica hc ON hc.pacienteFK = p.idpaciente
ORDER  BY p.nombrePaciente;


-- Requisito RQF33: Exportación de historia clínica (PDF)
-- ============================================================
-- RQF33 – EXPORTACIÓN DE HISTORIA CLÍNICA (datos para PDF)
-- ============================================================

-- Datos principales del paciente y HC
-- @idHistoriaClinica
SELECT p.nombrePaciente,
       p.documentoPaciente,
       p.fechaNacPaciente,
       TIMESTAMPDIFF(YEAR, p.fechaNacPaciente, CURDATE()) AS edad,
       p.direccionPaciente,
       u.telefono,
       u.correoElectronico,
       p.Preexistencias,
       p.Alergias,
       hc.idHistoriaClinica,
       hc.fechaApertura,
       hc.estado,
       hc.observaciones
FROM   historiaClinica hc
INNER  JOIN paciente p ON hc.pacienteFK = p.idpaciente
INNER  JOIN usuario  u ON p.usuarioFK   = u.idUsuario
WHERE  hc.idHistoriaClinica = @idHistoriaClinica;

-- Anamnesis más reciente
SELECT motivoConsulta, enfermedadActual, antecedentesPersonales,
       antecedentesFamiliares, revisionSistemas, fechaRegistro
FROM   anamnesis
WHERE  historiaClinicaFK = @idHistoriaClinica
ORDER  BY fechaRegistro DESC LIMIT 1;

-- Signos vitales más recientes
SELECT presionArterial, frecuenciaCardiaca, frecuenciaRespiratoria,
       temperatura, peso, talla, imc, glucemia, fechaRegistro
FROM   signos_vitales
WHERE  historiaClinicaFK = @idHistoriaClinica
ORDER  BY fechaRegistro DESC LIMIT 1;

-- Medicamentos activos
SELECT nombreMedicamento, dosis, frecuencia, viaAdministracion, motivoUso
FROM   medicamentos
WHERE  historiaClinicaFK = @idHistoriaClinica
  AND  (fechaFin IS NULL OR fechaFin >= CURDATE());

-- Diagnósticos
SELECT codigoCIE, descripcionDiagnostico, pronostico, fechaRegistro
FROM   ayuda_diagnostica
WHERE  historiaClinicaFK = @idHistoriaClinica
ORDER  BY fechaRegistro DESC;

-- Evoluciones
SELECT e.fechaSesion,
       u.nombreUsuario AS odontologo,
       e.estadoActual,
       e.cambiosTratamiento,
       e.respuestaPaciente,
       e.huboRemision,
       e.observaciones
FROM   evolucion e
INNER  JOIN odontologo od ON e.odontologoFK = od.idOdontologo
INNER  JOIN usuario    u  ON od.usuarioFK   = u.idUsuario
WHERE  e.historiaClinicaFK = @idHistoriaClinica
ORDER  BY e.fechaSesion;

-- Odontograma (URL de imagen)
SELECT odontograma, hallazgos, fechaRegistro
FROM   examen_dental
WHERE  historiaClinicaFK = @idHistoriaClinica
ORDER  BY fechaRegistro DESC LIMIT 1;


-- Requisito RQF35: Registro de actividad de usuarios (Logs)
-- ============================================================
-- RQF35 – LOGS DE ACTIVIDAD DE USUARIOS
-- ============================================================

-- Actividad de un usuario en un rango de fechas
-- @usuarioAudit, @fechaInicio, @fechaFin
SELECT 'usuario'          AS tabla, accion, fechaAuditoria, usuarioAudit FROM usuario_auditoria
    WHERE usuarioAudit = @usuarioAudit AND DATE(fechaAuditoria) BETWEEN @fechaInicio AND @fechaFin
UNION ALL
SELECT 'paciente',                   accion, fechaAuditoria, usuarioAudit FROM paciente_auditoria
    WHERE usuarioAudit = @usuarioAudit AND DATE(fechaAuditoria) BETWEEN @fechaInicio AND @fechaFin
UNION ALL
SELECT 'historiaClinica',            accion, fechaAuditoria, usuarioAudit FROM historiaClinica_auditoria
    WHERE usuarioAudit = @usuarioAudit AND DATE(fechaAuditoria) BETWEEN @fechaInicio AND @fechaFin
UNION ALL
SELECT 'evolucion',                  accion, fechaAuditoria, usuarioAudit FROM evolucion_auditoria
    WHERE usuarioAudit = @usuarioAudit AND DATE(fechaAuditoria) BETWEEN @fechaInicio AND @fechaFin
UNION ALL
SELECT 'citaOdontologico',           accion, fechaAuditoria, usuarioAudit FROM citaOdontologico_auditoria
    WHERE usuarioAudit = @usuarioAudit AND DATE(fechaAuditoria) BETWEEN @fechaInicio AND @fechaFin
UNION ALL
SELECT 'pago',                       accion, fechaAuditoria, usuarioAudit FROM pago_auditoria
    WHERE usuarioAudit = @usuarioAudit AND DATE(fechaAuditoria) BETWEEN @fechaInicio AND @fechaFin
ORDER  BY fechaAuditoria DESC;

-- Resumen de actividad por tabla y tipo de acción
SELECT tabla, accion, COUNT(*) AS total
FROM (
    SELECT 'usuario'          AS tabla, accion FROM usuario_auditoria
    UNION ALL SELECT 'paciente',          accion FROM paciente_auditoria
    UNION ALL SELECT 'historiaClinica',   accion FROM historiaClinica_auditoria
    UNION ALL SELECT 'evolucion',         accion FROM evolucion_auditoria
    UNION ALL SELECT 'citaOdontologico',  accion FROM citaOdontologico_auditoria
    UNION ALL SELECT 'pago',              accion FROM pago_auditoria
) AS todas
GROUP  BY tabla, accion
ORDER  BY tabla, accion;


-- Requisito RQF37: Registro de pagos y abonos
-- Requisito RQF38: Consulta de saldo de tratamientos realizados
-- Requisito RQF-BusquedaAportes: Búsqueda de aportes a saldo final de tratamientos
-- ============================================================
-- RQF37 – PAGOS Y ABONOS / RQF38 – SALDO DE TRATAMIENTOS
-- ============================================================

-- Consultar todos los pagos de un paciente
-- @idPaciente
SELECT p.idPago,
       p.fecha,
       p.monto,
       p.metodoPago,
       p.estado,
       c.tratamiento
FROM   pago p
LEFT   JOIN citaOdontologico c ON c.pagoFK = p.idPago
WHERE  p.pacienteFK = @idPaciente
ORDER  BY p.fecha DESC;

-- Total pagado por un paciente
-- @idPaciente
SELECT SUM(monto) AS totalPagado
FROM   pago
WHERE  pacienteFK = @idPaciente
  AND  estado NOT IN ('Anulado', 'Rechazado');

-- Saldo pendiente de un plan de tratamiento
-- @idPlan
SELECT pt.descripcion,
       pt.presupuesto,
       pt.saldoPendiente,
       (pt.presupuesto - pt.saldoPendiente) AS totalPagado,
       pt.estado
FROM   plan_tratamiento pt
WHERE  pt.idPlan = @idPlan;

-- Aportes individuales al saldo de un tratamiento (RQF38 específico)
-- @idHistoriaClinica
SELECT pg.idPago,
       pg.fecha,
       pg.monto,
       pg.metodoPago,
       pg.estado,
       c.tratamiento,
       c.horario AS fechaCita
FROM   pago pg
INNER  JOIN citaOdontologico c  ON c.pagoFK     = pg.idPago
INNER  JOIN historiaClinica  hc ON hc.pacienteFK = c.pacienteFK
WHERE  hc.idHistoriaClinica = @idHistoriaClinica
ORDER  BY pg.fecha DESC;

-- Total recaudado por método de pago
SELECT metodoPago,
       COUNT(idPago)  AS numeroPagos,
       SUM(monto)     AS totalRecaudado,
       AVG(monto)     AS promedioMonto
FROM   pago
WHERE  estado NOT IN ('Anulado', 'Rechazado')
GROUP  BY metodoPago
ORDER  BY totalRecaudado DESC;
