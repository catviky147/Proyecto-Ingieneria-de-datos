-- ============================================================
-- BASE DE DATOS: clinicaodontologica
-- Versión 3 — PACIENTE INDEPENDIENTE
--   - Paciente NO depende de usuario
--   - Paciente tiene sus propios datos de contacto
--   - Usuario solo para personal (Odontologo, Auxiliar, Admin, Inactivo)
-- ============================================================

CREATE DATABASE IF NOT EXISTS clinicaodontologica
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_spanish_ci;

USE clinicaodontologica;

-- ============================================================
-- SECCIÓN 1: TABLAS PRINCIPALES
-- ============================================================

-- -----------------------------------------------------------
-- 1.1 usuario (SOLO para personal: Odontologo, Auxiliar, Admin, Inactivo)
-- -----------------------------------------------------------
CREATE TABLE usuario (
    idUsuario          INT(10)      NOT NULL AUTO_INCREMENT,
    nombreUsuario      VARCHAR(50)  NOT NULL,
    telefono           VARCHAR(20),
    correoElectronico  VARCHAR(50),
    tipoDocumento      VARCHAR(10),
    userName           VARCHAR(20)  NOT NULL UNIQUE,
    contrasena         VARCHAR(255) NOT NULL,
    rol                ENUM('Odontologo','Auxiliar','Admin','Inactivo') NOT NULL,
    PRIMARY KEY (idUsuario)
);

-- -----------------------------------------------------------
-- 1.2 odontologo (FK → usuario)
-- -----------------------------------------------------------
CREATE TABLE odontologo (
    idOdontologo        INT          NOT NULL AUTO_INCREMENT,
    tarjetaProfesional  VARCHAR(50)  NOT NULL,
    especialidad        VARCHAR(50),
    usuarioFK           INT(10)      NOT NULL,
    PRIMARY KEY (idOdontologo),
    CONSTRAINT fk_odontologo_usuario
        FOREIGN KEY (usuarioFK) REFERENCES usuario (idUsuario)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- -----------------------------------------------------------
-- 1.3 auxiliar (FK → usuario)
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
-- 1.4 paciente (INDEPENDIENTE - no depende de usuario)
-- -----------------------------------------------------------
CREATE TABLE paciente (
    idpaciente        INT          NOT NULL AUTO_INCREMENT,
    nombrePaciente    VARCHAR(50)  NOT NULL,
    tipoDocumento     VARCHAR(10)  NOT NULL,
    documentoPaciente VARCHAR(20)  NOT NULL UNIQUE,
    telefono          VARCHAR(20),
    correoElectronico VARCHAR(50),
    direccionPaciente VARCHAR(100) NOT NULL,
    fechaNacPaciente  DATE         NOT NULL,
    Preexistencias    VARCHAR(500),
    Alergias          VARCHAR(100),
    PRIMARY KEY (idpaciente)
);

-- -----------------------------------------------------------
-- 1.5 historiaClinica (FK → paciente)
-- -----------------------------------------------------------
CREATE TABLE historiaClinica (
    idHistoriaClinica  INT           NOT NULL AUTO_INCREMENT,
    fechaApertura      DATE          NOT NULL,
    estado             VARCHAR(70)    DEFAULT 'Activa',
    observaciones      VARCHAR(10000),
    pacienteFK         INT           NOT NULL,
    PRIMARY KEY (idHistoriaClinica),
    CONSTRAINT fk_historia_paciente
        FOREIGN KEY (pacienteFK) REFERENCES paciente (idpaciente)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- -----------------------------------------------------------
-- 1.6 anamnesis (FK → historiaClinica)
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
-- 1.7 signos_vitales (FK → historiaClinica)
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
-- 1.8 habitos_higiene (FK → historiaClinica)
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
-- 1.9 medicamentos (FK → historiaClinica)
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
-- 1.10 pago (FK → paciente)
-- -----------------------------------------------------------
CREATE TABLE pago (
    idPago       INT           NOT NULL AUTO_INCREMENT,
    fecha        DATE          NOT NULL,
    monto        DECIMAL(12,2) NOT NULL,
    metodoPago   VARCHAR(100)  NOT NULL,
    estado       ENUM('Pendiente','Pagado','Anulado','Rechazado') DEFAULT 'Pendiente',
    pacienteFK   INT           NOT NULL,
    PRIMARY KEY (idPago),
    CONSTRAINT fk_pago_paciente
        FOREIGN KEY (pacienteFK) REFERENCES paciente (idpaciente)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- -----------------------------------------------------------
-- 1.11 citaOdontologico (FK → odontologo, paciente, pago)
-- -----------------------------------------------------------
CREATE TABLE citaOdontologico (
    idCita        INT         NOT NULL AUTO_INCREMENT,
    odontologoFK  INT         NOT NULL,
    pacienteFK    INT         NOT NULL,
    pagoFK        INT,
    horario       DATETIME,
    tratamiento   VARCHAR(100),
    estado        ENUM('Pendiente','Confirmada Asistida','Confirmada No Asistida','Cancelada','Reprogramada') DEFAULT 'Pendiente',
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
-- 1.12 evolucion (FK → historiaClinica, odontologo)
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
-- 1.13 ayuda_diagnostica (FK → historiaClinica)
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
-- 1.14 plan_tratamiento (FK → historiaClinica)
-- -----------------------------------------------------------
CREATE TABLE plan_tratamiento (
    idPlan             INT           NOT NULL AUTO_INCREMENT,
    historiaClinicaFK  INT           NOT NULL,
    descripcion        VARCHAR(1000),
    presupuesto        DECIMAL(12,2),
    saldoPendiente     DECIMAL(12,2) DEFAULT 0,
    fechaInicio        DATE,
    fechaFin           DATE,
    estado             VARCHAR(50)   DEFAULT 'Activo',
    PRIMARY KEY (idPlan),
    CONSTRAINT fk_plan_historia
        FOREIGN KEY (historiaClinicaFK) REFERENCES historiaClinica (idHistoriaClinica)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- -----------------------------------------------------------
-- 1.15 consentimiento (FK → historiaClinica)
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
-- 1.16 examen_dental (FK → historiaClinica)
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
-- SECCIÓN 2: TABLAS DE AUDITORÍA
-- ============================================================

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
    usuarioAudit       VARCHAR(100) DEFAULT NULL,
    PRIMARY KEY (idAuditoria)
);

CREATE TABLE odontologo_auditoria (
    idAuditoria         INT          NOT NULL AUTO_INCREMENT,
    idOdontologo        INT,
    tarjetaProfesional  VARCHAR(50),
    especialidad        VARCHAR(50),
    usuarioFK           INT(10),
    accion              VARCHAR(10)  NOT NULL,
    fechaAuditoria      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    usuarioAudit        VARCHAR(100) DEFAULT NULL,
    PRIMARY KEY (idAuditoria)
);

CREATE TABLE auxiliar_auditoria (
    idAuditoria           INT          NOT NULL AUTO_INCREMENT,
    idAuxiliar            INT,
    tarjetaProfesionalAux VARCHAR(50),
    usuarioFK             INT(10),
    accion                VARCHAR(10)  NOT NULL,
    fechaAuditoria        DATETIME     DEFAULT CURRENT_TIMESTAMP,
    usuarioAudit          VARCHAR(100) DEFAULT NULL,
    PRIMARY KEY (idAuditoria)
);

CREATE TABLE paciente_auditoria (
    idAuditoria       INT          NOT NULL AUTO_INCREMENT,
    idpaciente        INT,
    nombrePaciente    VARCHAR(50),
    tipoDocumento     VARCHAR(10),
    documentoPaciente VARCHAR(20),
    telefono          VARCHAR(20),
    correoElectronico VARCHAR(50),
    direccionPaciente VARCHAR(100),
    fechaNacPaciente  DATE,
    Preexistencias    VARCHAR(500),
    Alergias          VARCHAR(100),
    accion            VARCHAR(10)  NOT NULL,
    fechaAuditoria    DATETIME     DEFAULT CURRENT_TIMESTAMP,
    usuarioAudit      VARCHAR(100) DEFAULT NULL,
    PRIMARY KEY (idAuditoria)
);

CREATE TABLE historiaClinica_auditoria (
    idAuditoria        INT           NOT NULL AUTO_INCREMENT,
    idHistoriaClinica  INT,
    fechaApertura      DATE,
    estado             VARCHAR(70),
    observaciones      VARCHAR(10000),
    pacienteFK         INT,
    accion             VARCHAR(10)   NOT NULL,
    fechaAuditoria     DATETIME      DEFAULT CURRENT_TIMESTAMP,
    usuarioAudit       VARCHAR(100)  DEFAULT NULL,
    PRIMARY KEY (idAuditoria)
);

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
    usuarioAudit           VARCHAR(100) DEFAULT NULL,
    PRIMARY KEY (idAuditoria)
);

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
    usuarioAudit           VARCHAR(100) DEFAULT NULL,
    PRIMARY KEY (idAuditoria)
);

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
    usuarioAudit            VARCHAR(100) DEFAULT NULL,
    PRIMARY KEY (idAuditoria)
);

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
    usuarioAudit      VARCHAR(100) DEFAULT NULL,
    PRIMARY KEY (idAuditoria)
);

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
    usuarioAudit   VARCHAR(100)  DEFAULT NULL,
    PRIMARY KEY (idAuditoria)
);

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
    usuarioAudit   VARCHAR(100) DEFAULT NULL,
    PRIMARY KEY (idAuditoria)
);

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
    usuarioAudit       VARCHAR(100) DEFAULT NULL,
    PRIMARY KEY (idAuditoria)
);

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
    usuarioAudit           VARCHAR(100) DEFAULT NULL,
    PRIMARY KEY (idAuditoria)
);

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
    usuarioAudit       VARCHAR(100)  DEFAULT NULL,
    PRIMARY KEY (idAuditoria)
);

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
    usuarioAudit       VARCHAR(100) DEFAULT NULL,
    PRIMARY KEY (idAuditoria)
);

CREATE TABLE examen_dental_auditoria (
    idAuditoria        INT          NOT NULL AUTO_INCREMENT,
    idExamen           INT,
    historiaClinicaFK  INT,
    hallazgos          TEXT,
    odontograma        VARCHAR(500),
    fechaRegistro      DATE,
    accion             VARCHAR(10)  NOT NULL,
    fechaAuditoria     DATETIME     DEFAULT CURRENT_TIMESTAMP,
    usuarioAudit       VARCHAR(100) DEFAULT NULL,
    PRIMARY KEY (idAuditoria)
);

-- ============================================================
-- SECCIÓN 3: TRIGGERS DE AUDITORÍA
-- ============================================================

DELIMITER $$

-- TRIGGERS PARA USUARIO
CREATE TRIGGER trg_usuario_insert AFTER INSERT ON usuario
FOR EACH ROW BEGIN
    INSERT INTO usuario_auditoria
        (idUsuario, nombreUsuario, telefono, correoElectronico,
         tipoDocumento, userName, contrasena, rol, accion, usuarioAudit)
    VALUES (NEW.idUsuario, NEW.nombreUsuario, NEW.telefono,
            NEW.correoElectronico, NEW.tipoDocumento, NEW.userName,
            NEW.contrasena, NEW.rol, 'INSERT', USER());
END$$

CREATE TRIGGER trg_usuario_update AFTER UPDATE ON usuario
FOR EACH ROW BEGIN
    INSERT INTO usuario_auditoria
        (idUsuario, nombreUsuario, telefono, correoElectronico,
         tipoDocumento, userName, contrasena, rol, accion, usuarioAudit)
    VALUES (NEW.idUsuario, NEW.nombreUsuario, NEW.telefono,
            NEW.correoElectronico, NEW.tipoDocumento, NEW.userName,
            NEW.contrasena, NEW.rol, 'UPDATE', USER());
END$$

CREATE TRIGGER trg_usuario_delete AFTER DELETE ON usuario
FOR EACH ROW BEGIN
    INSERT INTO usuario_auditoria
        (idUsuario, nombreUsuario, telefono, correoElectronico,
         tipoDocumento, userName, contrasena, rol, accion, usuarioAudit)
    VALUES (OLD.idUsuario, OLD.nombreUsuario, OLD.telefono,
            OLD.correoElectronico, OLD.tipoDocumento, OLD.userName,
            OLD.contrasena, OLD.rol, 'DELETE', USER());
END$$

-- TRIGGERS PARA ODONTOLOGO
CREATE TRIGGER trg_odontologo_insert AFTER INSERT ON odontologo
FOR EACH ROW BEGIN
    INSERT INTO odontologo_auditoria
        (idOdontologo, tarjetaProfesional, especialidad, usuarioFK, accion, usuarioAudit)
    VALUES (NEW.idOdontologo, NEW.tarjetaProfesional, NEW.especialidad,
            NEW.usuarioFK, 'INSERT', USER());
END$$

CREATE TRIGGER trg_odontologo_update AFTER UPDATE ON odontologo
FOR EACH ROW BEGIN
    INSERT INTO odontologo_auditoria
        (idOdontologo, tarjetaProfesional, especialidad, usuarioFK, accion, usuarioAudit)
    VALUES (NEW.idOdontologo, NEW.tarjetaProfesional, NEW.especialidad,
            NEW.usuarioFK, 'UPDATE', USER());
END$$

CREATE TRIGGER trg_odontologo_delete AFTER DELETE ON odontologo
FOR EACH ROW BEGIN
    INSERT INTO odontologo_auditoria
        (idOdontologo, tarjetaProfesional, especialidad, usuarioFK, accion, usuarioAudit)
    VALUES (OLD.idOdontologo, OLD.tarjetaProfesional, OLD.especialidad,
            OLD.usuarioFK, 'DELETE', USER());
END$$

-- TRIGGERS PARA AUXILIAR
CREATE TRIGGER trg_auxiliar_insert AFTER INSERT ON auxiliar
FOR EACH ROW BEGIN
    INSERT INTO auxiliar_auditoria
        (idAuxiliar, tarjetaProfesionalAux, usuarioFK, accion, usuarioAudit)
    VALUES (NEW.idAuxiliar, NEW.tarjetaProfesionalAux, NEW.usuarioFK, 'INSERT', USER());
END$$

CREATE TRIGGER trg_auxiliar_update AFTER UPDATE ON auxiliar
FOR EACH ROW BEGIN
    INSERT INTO auxiliar_auditoria
        (idAuxiliar, tarjetaProfesionalAux, usuarioFK, accion, usuarioAudit)
    VALUES (NEW.idAuxiliar, NEW.tarjetaProfesionalAux, NEW.usuarioFK, 'UPDATE', USER());
END$$

CREATE TRIGGER trg_auxiliar_delete AFTER DELETE ON auxiliar
FOR EACH ROW BEGIN
    INSERT INTO auxiliar_auditoria
        (idAuxiliar, tarjetaProfesionalAux, usuarioFK, accion, usuarioAudit)
    VALUES (OLD.idAuxiliar, OLD.tarjetaProfesionalAux, OLD.usuarioFK, 'DELETE', USER());
END$$

-- TRIGGERS PARA PACIENTE
CREATE TRIGGER trg_paciente_insert AFTER INSERT ON paciente
FOR EACH ROW BEGIN
    INSERT INTO paciente_auditoria
        (idpaciente, nombrePaciente, tipoDocumento, documentoPaciente,
         telefono, correoElectronico, direccionPaciente, fechaNacPaciente,
         Preexistencias, Alergias, accion, usuarioAudit)
    VALUES (NEW.idpaciente, NEW.nombrePaciente, NEW.tipoDocumento, NEW.documentoPaciente,
            NEW.telefono, NEW.correoElectronico, NEW.direccionPaciente, NEW.fechaNacPaciente,
            NEW.Preexistencias, NEW.Alergias, 'INSERT', USER());
END$$

CREATE TRIGGER trg_paciente_update AFTER UPDATE ON paciente
FOR EACH ROW BEGIN
    INSERT INTO paciente_auditoria
        (idpaciente, nombrePaciente, tipoDocumento, documentoPaciente,
         telefono, correoElectronico, direccionPaciente, fechaNacPaciente,
         Preexistencias, Alergias, accion, usuarioAudit)
    VALUES (NEW.idpaciente, NEW.nombrePaciente, NEW.tipoDocumento, NEW.documentoPaciente,
            NEW.telefono, NEW.correoElectronico, NEW.direccionPaciente, NEW.fechaNacPaciente,
            NEW.Preexistencias, NEW.Alergias, 'UPDATE', USER());
END$$

CREATE TRIGGER trg_paciente_delete AFTER DELETE ON paciente
FOR EACH ROW BEGIN
    INSERT INTO paciente_auditoria
        (idpaciente, nombrePaciente, tipoDocumento, documentoPaciente,
         telefono, correoElectronico, direccionPaciente, fechaNacPaciente,
         Preexistencias, Alergias, accion, usuarioAudit)
    VALUES (OLD.idpaciente, OLD.nombrePaciente, OLD.tipoDocumento, OLD.documentoPaciente,
            OLD.telefono, OLD.correoElectronico, OLD.direccionPaciente, OLD.fechaNacPaciente,
            OLD.Preexistencias, OLD.Alergias, 'DELETE', USER());
END$$

-- TRIGGERS PARA HISTORIA CLINICA
CREATE TRIGGER trg_historia_insert AFTER INSERT ON historiaClinica
FOR EACH ROW BEGIN
    INSERT INTO historiaClinica_auditoria
        (idHistoriaClinica, fechaApertura, estado, observaciones, pacienteFK, accion, usuarioAudit)
    VALUES (NEW.idHistoriaClinica, NEW.fechaApertura, NEW.estado,
            NEW.observaciones, NEW.pacienteFK, 'INSERT', USER());
END$$

CREATE TRIGGER trg_historia_update AFTER UPDATE ON historiaClinica
FOR EACH ROW BEGIN
    INSERT INTO historiaClinica_auditoria
        (idHistoriaClinica, fechaApertura, estado, observaciones, pacienteFK, accion, usuarioAudit)
    VALUES (NEW.idHistoriaClinica, NEW.fechaApertura, NEW.estado,
            NEW.observaciones, NEW.pacienteFK, 'UPDATE', USER());
END$$

CREATE TRIGGER trg_historia_delete AFTER DELETE ON historiaClinica
FOR EACH ROW BEGIN
    INSERT INTO historiaClinica_auditoria
        (idHistoriaClinica, fechaApertura, estado, observaciones, pacienteFK, accion, usuarioAudit)
    VALUES (OLD.idHistoriaClinica, OLD.fechaApertura, OLD.estado,
            OLD.observaciones, OLD.pacienteFK, 'DELETE', USER());
END$$

-- TRIGGERS PARA ANAMNESIS
CREATE TRIGGER trg_anamnesis_insert AFTER INSERT ON anamnesis
FOR EACH ROW BEGIN
    INSERT INTO anamnesis_auditoria
        (idAnamnesis, historiaClinicaFK, motivoConsulta, enfermedadActual,
         antecedentesPersonales, antecedentesFamiliares, revisionSistemas,
         fechaRegistro, accion, usuarioAudit)
    VALUES (NEW.idAnamnesis, NEW.historiaClinicaFK, NEW.motivoConsulta,
            NEW.enfermedadActual, NEW.antecedentesPersonales,
            NEW.antecedentesFamiliares, NEW.revisionSistemas,
            NEW.fechaRegistro, 'INSERT', USER());
END$$

CREATE TRIGGER trg_anamnesis_update AFTER UPDATE ON anamnesis
FOR EACH ROW BEGIN
    INSERT INTO anamnesis_auditoria
        (idAnamnesis, historiaClinicaFK, motivoConsulta, enfermedadActual,
         antecedentesPersonales, antecedentesFamiliares, revisionSistemas,
         fechaRegistro, accion, usuarioAudit)
    VALUES (NEW.idAnamnesis, NEW.historiaClinicaFK, NEW.motivoConsulta,
            NEW.enfermedadActual, NEW.antecedentesPersonales,
            NEW.antecedentesFamiliares, NEW.revisionSistemas,
            NEW.fechaRegistro, 'UPDATE', USER());
END$$

CREATE TRIGGER trg_anamnesis_delete AFTER DELETE ON anamnesis
FOR EACH ROW BEGIN
    INSERT INTO anamnesis_auditoria
        (idAnamnesis, historiaClinicaFK, motivoConsulta, enfermedadActual,
         antecedentesPersonales, antecedentesFamiliares, revisionSistemas,
         fechaRegistro, accion, usuarioAudit)
    VALUES (OLD.idAnamnesis, OLD.historiaClinicaFK, OLD.motivoConsulta,
            OLD.enfermedadActual, OLD.antecedentesPersonales,
            OLD.antecedentesFamiliares, OLD.revisionSistemas,
            OLD.fechaRegistro, 'DELETE', USER());
END$$

-- TRIGGERS PARA SIGNOS VITALES
CREATE TRIGGER trg_signos_insert AFTER INSERT ON signos_vitales
FOR EACH ROW BEGIN
    INSERT INTO signos_vitales_auditoria
        (idSignosVitales, historiaClinicaFK, presionArterial,
         frecuenciaCardiaca, frecuenciaRespiratoria, temperatura,
         peso, talla, imc, glucemia, fechaRegistro, accion, usuarioAudit)
    VALUES (NEW.idSignosVitales, NEW.historiaClinicaFK, NEW.presionArterial,
            NEW.frecuenciaCardiaca, NEW.frecuenciaRespiratoria, NEW.temperatura,
            NEW.peso, NEW.talla, NEW.imc, NEW.glucemia, NEW.fechaRegistro, 'INSERT', USER());
END$$

CREATE TRIGGER trg_signos_update AFTER UPDATE ON signos_vitales
FOR EACH ROW BEGIN
    INSERT INTO signos_vitales_auditoria
        (idSignosVitales, historiaClinicaFK, presionArterial,
         frecuenciaCardiaca, frecuenciaRespiratoria, temperatura,
         peso, talla, imc, glucemia, fechaRegistro, accion, usuarioAudit)
    VALUES (NEW.idSignosVitales, NEW.historiaClinicaFK, NEW.presionArterial,
            NEW.frecuenciaCardiaca, NEW.frecuenciaRespiratoria, NEW.temperatura,
            NEW.peso, NEW.talla, NEW.imc, NEW.glucemia, NEW.fechaRegistro, 'UPDATE', USER());
END$$

CREATE TRIGGER trg_signos_delete AFTER DELETE ON signos_vitales
FOR EACH ROW BEGIN
    INSERT INTO signos_vitales_auditoria
        (idSignosVitales, historiaClinicaFK, presionArterial,
         frecuenciaCardiaca, frecuenciaRespiratoria, temperatura,
         peso, talla, imc, glucemia, fechaRegistro, accion, usuarioAudit)
    VALUES (OLD.idSignosVitales, OLD.historiaClinicaFK, OLD.presionArterial,
            OLD.frecuenciaCardiaca, OLD.frecuenciaRespiratoria, OLD.temperatura,
            OLD.peso, OLD.talla, OLD.imc, OLD.glucemia, OLD.fechaRegistro, 'DELETE', USER());
END$$

-- TRIGGERS PARA HABITOS HIGIENE
CREATE TRIGGER trg_habitos_insert AFTER INSERT ON habitos_higiene
FOR EACH ROW BEGIN
    INSERT INTO habitos_higiene_auditoria
        (idHabitosHigiene, historiaClinicaFK, frecuenciaCepillado,
         usaHilosDental, usaEnjuague, visitaDentistaPeriodica,
         consumoTabaco, consumoAlcohol, observaciones, fechaRegistro, accion, usuarioAudit)
    VALUES (NEW.idHabitosHigiene, NEW.historiaClinicaFK, NEW.frecuenciaCepillado,
            NEW.usaHilosDental, NEW.usaEnjuague, NEW.visitaDentistaPeriodica,
            NEW.consumoTabaco, NEW.consumoAlcohol, NEW.observaciones,
            NEW.fechaRegistro, 'INSERT', USER());
END$$

CREATE TRIGGER trg_habitos_update AFTER UPDATE ON habitos_higiene
FOR EACH ROW BEGIN
    INSERT INTO habitos_higiene_auditoria
        (idHabitosHigiene, historiaClinicaFK, frecuenciaCepillado,
         usaHilosDental, usaEnjuague, visitaDentistaPeriodica,
         consumoTabaco, consumoAlcohol, observaciones, fechaRegistro, accion, usuarioAudit)
    VALUES (NEW.idHabitosHigiene, NEW.historiaClinicaFK, NEW.frecuenciaCepillado,
            NEW.usaHilosDental, NEW.usaEnjuague, NEW.visitaDentistaPeriodica,
            NEW.consumoTabaco, NEW.consumoAlcohol, NEW.observaciones,
            NEW.fechaRegistro, 'UPDATE', USER());
END$$

CREATE TRIGGER trg_habitos_delete AFTER DELETE ON habitos_higiene
FOR EACH ROW BEGIN
    INSERT INTO habitos_higiene_auditoria
        (idHabitosHigiene, historiaClinicaFK, frecuenciaCepillado,
         usaHilosDental, usaEnjuague, visitaDentistaPeriodica,
         consumoTabaco, consumoAlcohol, observaciones, fechaRegistro, accion, usuarioAudit)
    VALUES (OLD.idHabitosHigiene, OLD.historiaClinicaFK, OLD.frecuenciaCepillado,
            OLD.usaHilosDental, OLD.usaEnjuague, OLD.visitaDentistaPeriodica,
            OLD.consumoTabaco, OLD.consumoAlcohol, OLD.observaciones,
            OLD.fechaRegistro, 'DELETE', USER());
END$$

-- TRIGGERS PARA MEDICAMENTOS
CREATE TRIGGER trg_medicamentos_insert AFTER INSERT ON medicamentos
FOR EACH ROW BEGIN
    INSERT INTO medicamentos_auditoria
        (idMedicamento, historiaClinicaFK, nombreMedicamento, principioActivo,
         dosis, frecuencia, viaAdministracion, motivoUso, fechaInicio, fechaFin, accion, usuarioAudit)
    VALUES (NEW.idMedicamento, NEW.historiaClinicaFK, NEW.nombreMedicamento,
            NEW.principioActivo, NEW.dosis, NEW.frecuencia, NEW.viaAdministracion,
            NEW.motivoUso, NEW.fechaInicio, NEW.fechaFin, 'INSERT', USER());
END$$

CREATE TRIGGER trg_medicamentos_update AFTER UPDATE ON medicamentos
FOR EACH ROW BEGIN
    INSERT INTO medicamentos_auditoria
        (idMedicamento, historiaClinicaFK, nombreMedicamento, principioActivo,
         dosis, frecuencia, viaAdministracion, motivoUso, fechaInicio, fechaFin, accion, usuarioAudit)
    VALUES (NEW.idMedicamento, NEW.historiaClinicaFK, NEW.nombreMedicamento,
            NEW.principioActivo, NEW.dosis, NEW.frecuencia, NEW.viaAdministracion,
            NEW.motivoUso, NEW.fechaInicio, NEW.fechaFin, 'UPDATE', USER());
END$$

CREATE TRIGGER trg_medicamentos_delete AFTER DELETE ON medicamentos
FOR EACH ROW BEGIN
    INSERT INTO medicamentos_auditoria
        (idMedicamento, historiaClinicaFK, nombreMedicamento, principioActivo,
         dosis, frecuencia, viaAdministracion, motivoUso, fechaInicio, fechaFin, accion, usuarioAudit)
    VALUES (OLD.idMedicamento, OLD.historiaClinicaFK, OLD.nombreMedicamento,
            OLD.principioActivo, OLD.dosis, OLD.frecuencia, OLD.viaAdministracion,
            OLD.motivoUso, OLD.fechaInicio, OLD.fechaFin, 'DELETE', USER());
END$$

-- TRIGGERS PARA PAGO
CREATE TRIGGER trg_pago_insert AFTER INSERT ON pago
FOR EACH ROW BEGIN
    INSERT INTO pago_auditoria
        (idPago, fecha, monto, metodoPago, estado, pacienteFK, accion, usuarioAudit)
    VALUES (NEW.idPago, NEW.fecha, NEW.monto, NEW.metodoPago,
            NEW.estado, NEW.pacienteFK, 'INSERT', USER());
END$$

CREATE TRIGGER trg_pago_update AFTER UPDATE ON pago
FOR EACH ROW BEGIN
    INSERT INTO pago_auditoria
        (idPago, fecha, monto, metodoPago, estado, pacienteFK, accion, usuarioAudit)
    VALUES (NEW.idPago, NEW.fecha, NEW.monto, NEW.metodoPago,
            NEW.estado, NEW.pacienteFK, 'UPDATE', USER());
END$$

CREATE TRIGGER trg_pago_delete AFTER DELETE ON pago
FOR EACH ROW BEGIN
    INSERT INTO pago_auditoria
        (idPago, fecha, monto, metodoPago, estado, pacienteFK, accion, usuarioAudit)
    VALUES (OLD.idPago, OLD.fecha, OLD.monto, OLD.metodoPago,
            OLD.estado, OLD.pacienteFK, 'DELETE', USER());
END$$

-- TRIGGERS PARA CITA ODONTOLOGICO
CREATE TRIGGER trg_cita_insert AFTER INSERT ON citaOdontologico
FOR EACH ROW BEGIN
    INSERT INTO citaOdontologico_auditoria
        (idCita, odontologoFK, pacienteFK, pagoFK, horario, tratamiento, estado, accion, usuarioAudit)
    VALUES (NEW.idCita, NEW.odontologoFK, NEW.pacienteFK, NEW.pagoFK,
            NEW.horario, NEW.tratamiento, NEW.estado, 'INSERT', USER());
END$$

CREATE TRIGGER trg_cita_update AFTER UPDATE ON citaOdontologico
FOR EACH ROW BEGIN
    INSERT INTO citaOdontologico_auditoria
        (idCita, odontologoFK, pacienteFK, pagoFK, horario, tratamiento, estado, accion, usuarioAudit)
    VALUES (NEW.idCita, NEW.odontologoFK, NEW.pacienteFK, NEW.pagoFK,
            NEW.horario, NEW.tratamiento, NEW.estado, 'UPDATE', USER());
END$$

CREATE TRIGGER trg_cita_delete AFTER DELETE ON citaOdontologico
FOR EACH ROW BEGIN
    INSERT INTO citaOdontologico_auditoria
        (idCita, odontologoFK, pacienteFK, pagoFK, horario, tratamiento, estado, accion, usuarioAudit)
    VALUES (OLD.idCita, OLD.odontologoFK, OLD.pacienteFK, OLD.pagoFK,
            OLD.horario, OLD.tratamiento, OLD.estado, 'DELETE', USER());
END$$

-- TRIGGERS PARA EVOLUCION
CREATE TRIGGER trg_evolucion_insert AFTER INSERT ON evolucion
FOR EACH ROW BEGIN
    INSERT INTO evolucion_auditoria
        (idEvolucion, historiaClinicaFK, odontologoFK, fechaSesion,
         estadoActual, consultaAnterior, cambiosTratamiento,
         respuestaPaciente, huboRemision, huboInterconsulta,
         cambioProfesional, observaciones, accion, usuarioAudit)
    VALUES (NEW.idEvolucion, NEW.historiaClinicaFK, NEW.odontologoFK, NEW.fechaSesion,
            NEW.estadoActual, NEW.consultaAnterior, NEW.cambiosTratamiento,
            NEW.respuestaPaciente, NEW.huboRemision, NEW.huboInterconsulta,
            NEW.cambioProfesional, NEW.observaciones, 'INSERT', USER());
END$$

CREATE TRIGGER trg_evolucion_update AFTER UPDATE ON evolucion
FOR EACH ROW BEGIN
    INSERT INTO evolucion_auditoria
        (idEvolucion, historiaClinicaFK, odontologoFK, fechaSesion,
         estadoActual, consultaAnterior, cambiosTratamiento,
         respuestaPaciente, huboRemision, huboInterconsulta,
         cambioProfesional, observaciones, accion, usuarioAudit)
    VALUES (NEW.idEvolucion, NEW.historiaClinicaFK, NEW.odontologoFK, NEW.fechaSesion,
            NEW.estadoActual, NEW.consultaAnterior, NEW.cambiosTratamiento,
            NEW.respuestaPaciente, NEW.huboRemision, NEW.huboInterconsulta,
            NEW.cambioProfesional, NEW.observaciones, 'UPDATE', USER());
END$$

CREATE TRIGGER trg_evolucion_delete AFTER DELETE ON evolucion
FOR EACH ROW BEGIN
    INSERT INTO evolucion_auditoria
        (idEvolucion, historiaClinicaFK, odontologoFK, fechaSesion,
         estadoActual, consultaAnterior, cambiosTratamiento,
         respuestaPaciente, huboRemision, huboInterconsulta,
         cambioProfesional, observaciones, accion, usuarioAudit)
    VALUES (OLD.idEvolucion, OLD.historiaClinicaFK, OLD.odontologoFK, OLD.fechaSesion,
            OLD.estadoActual, OLD.consultaAnterior, OLD.cambiosTratamiento,
            OLD.respuestaPaciente, OLD.huboRemision, OLD.huboInterconsulta,
            OLD.cambioProfesional, OLD.observaciones, 'DELETE', USER());
END$$

-- TRIGGERS PARA AYUDA DIAGNOSTICA
CREATE TRIGGER trg_ayuda_insert AFTER INSERT ON ayuda_diagnostica
FOR EACH ROW BEGIN
    INSERT INTO ayuda_diagnostica_auditoria
        (idAyuda, historiaClinicaFK, codigoCIE, descripcionDiagnostico,
         pronostico, rutaArchivo, tipoArchivo, fechaRegistro, accion, usuarioAudit)
    VALUES (NEW.idAyuda, NEW.historiaClinicaFK, NEW.codigoCIE, NEW.descripcionDiagnostico,
            NEW.pronostico, NEW.rutaArchivo, NEW.tipoArchivo, NEW.fechaRegistro, 'INSERT', USER());
END$$

CREATE TRIGGER trg_ayuda_update AFTER UPDATE ON ayuda_diagnostica
FOR EACH ROW BEGIN
    INSERT INTO ayuda_diagnostica_auditoria
        (idAyuda, historiaClinicaFK, codigoCIE, descripcionDiagnostico,
         pronostico, rutaArchivo, tipoArchivo, fechaRegistro, accion, usuarioAudit)
    VALUES (NEW.idAyuda, NEW.historiaClinicaFK, NEW.codigoCIE, NEW.descripcionDiagnostico,
            NEW.pronostico, NEW.rutaArchivo, NEW.tipoArchivo, NEW.fechaRegistro, 'UPDATE', USER());
END$$

CREATE TRIGGER trg_ayuda_delete AFTER DELETE ON ayuda_diagnostica
FOR EACH ROW BEGIN
    INSERT INTO ayuda_diagnostica_auditoria
        (idAyuda, historiaClinicaFK, codigoCIE, descripcionDiagnostico,
         pronostico, rutaArchivo, tipoArchivo, fechaRegistro, accion, usuarioAudit)
    VALUES (OLD.idAyuda, OLD.historiaClinicaFK, OLD.codigoCIE, OLD.descripcionDiagnostico,
            OLD.pronostico, OLD.rutaArchivo, OLD.tipoArchivo, OLD.fechaRegistro, 'DELETE', USER());
END$$

-- TRIGGERS PARA PLAN TRATAMIENTO
CREATE TRIGGER trg_plan_insert AFTER INSERT ON plan_tratamiento
FOR EACH ROW BEGIN
    INSERT INTO plan_tratamiento_auditoria
        (idPlan, historiaClinicaFK, descripcion, presupuesto,
         saldoPendiente, fechaInicio, fechaFin, estado, accion, usuarioAudit)
    VALUES (NEW.idPlan, NEW.historiaClinicaFK, NEW.descripcion, NEW.presupuesto,
            NEW.saldoPendiente, NEW.fechaInicio, NEW.fechaFin, NEW.estado, 'INSERT', USER());
END$$

CREATE TRIGGER trg_plan_update AFTER UPDATE ON plan_tratamiento
FOR EACH ROW BEGIN
    INSERT INTO plan_tratamiento_auditoria
        (idPlan, historiaClinicaFK, descripcion, presupuesto,
         saldoPendiente, fechaInicio, fechaFin, estado, accion, usuarioAudit)
    VALUES (NEW.idPlan, NEW.historiaClinicaFK, NEW.descripcion, NEW.presupuesto,
            NEW.saldoPendiente, NEW.fechaInicio, NEW.fechaFin, NEW.estado, 'UPDATE', USER());
END$$

CREATE TRIGGER trg_plan_delete AFTER DELETE ON plan_tratamiento
FOR EACH ROW BEGIN
    INSERT INTO plan_tratamiento_auditoria
        (idPlan, historiaClinicaFK, descripcion, presupuesto,
         saldoPendiente, fechaInicio, fechaFin, estado, accion, usuarioAudit)
    VALUES (OLD.idPlan, OLD.historiaClinicaFK, OLD.descripcion, OLD.presupuesto,
            OLD.saldoPendiente, OLD.fechaInicio, OLD.fechaFin, OLD.estado, 'DELETE', USER());
END$$

-- TRIGGERS PARA CONSENTIMIENTO
CREATE TRIGGER trg_consentimiento_insert AFTER INSERT ON consentimiento
FOR EACH ROW BEGIN
    INSERT INTO consentimiento_auditoria
        (idConsentimiento, historiaClinicaFK, procedimiento, fechaFirma,
         firmaPaciente, firmaProfesional, observaciones, accion, usuarioAudit)
    VALUES (NEW.idConsentimiento, NEW.historiaClinicaFK, NEW.procedimiento, NEW.fechaFirma,
            NEW.firmaPaciente, NEW.firmaProfesional, NEW.observaciones, 'INSERT', USER());
END$$

CREATE TRIGGER trg_consentimiento_update AFTER UPDATE ON consentimiento
FOR EACH ROW BEGIN
    INSERT INTO consentimiento_auditoria
        (idConsentimiento, historiaClinicaFK, procedimiento, fechaFirma,
         firmaPaciente, firmaProfesional, observaciones, accion, usuarioAudit)
    VALUES (NEW.idConsentimiento, NEW.historiaClinicaFK, NEW.procedimiento, NEW.fechaFirma,
            NEW.firmaPaciente, NEW.firmaProfesional, NEW.observaciones, 'UPDATE', USER());
END$$

CREATE TRIGGER trg_consentimiento_delete AFTER DELETE ON consentimiento
FOR EACH ROW BEGIN
    INSERT INTO consentimiento_auditoria
        (idConsentimiento, historiaClinicaFK, procedimiento, fechaFirma,
         firmaPaciente, firmaProfesional, observaciones, accion, usuarioAudit)
    VALUES (OLD.idConsentimiento, OLD.historiaClinicaFK, OLD.procedimiento, OLD.fechaFirma,
            OLD.firmaPaciente, OLD.firmaProfesional, OLD.observaciones, 'DELETE', USER());
END$$

-- TRIGGERS PARA EXAMEN DENTAL
CREATE TRIGGER trg_examen_insert AFTER INSERT ON examen_dental
FOR EACH ROW BEGIN
    INSERT INTO examen_dental_auditoria
        (idExamen, historiaClinicaFK, hallazgos, odontograma, fechaRegistro, accion, usuarioAudit)
    VALUES (NEW.idExamen, NEW.historiaClinicaFK, NEW.hallazgos, NEW.odontograma,
            NEW.fechaRegistro, 'INSERT', USER());
END$$

CREATE TRIGGER trg_examen_update AFTER UPDATE ON examen_dental
FOR EACH ROW BEGIN
    INSERT INTO examen_dental_auditoria
        (idExamen, historiaClinicaFK, hallazgos, odontograma, fechaRegistro, accion, usuarioAudit)
    VALUES (NEW.idExamen, NEW.historiaClinicaFK, NEW.hallazgos, NEW.odontograma,
            NEW.fechaRegistro, 'UPDATE', USER());
END$$

CREATE TRIGGER trg_examen_delete AFTER DELETE ON examen_dental
FOR EACH ROW BEGIN
    INSERT INTO examen_dental_auditoria
        (idExamen, historiaClinicaFK, hallazgos, odontograma, fechaRegistro, accion, usuarioAudit)
    VALUES (OLD.idExamen, OLD.historiaClinicaFK, OLD.hallazgos, OLD.odontograma,
            OLD.fechaRegistro, 'DELETE', USER());
END$$

DELIMITER ;

-- ============================================================
-- SECCIÓN 4: CONSULTAS POR REQUISITO FUNCIONAL (CORREGIDAS)
-- ============================================================

-- RQF – INICIAR SESIÓN / RQF34 – CONTROL DE ACCESO
SELECT idUsuario, nombreUsuario, correoElectronico, rol
FROM usuario
WHERE userName = @userName AND contrasena = @hashContrasena;

-- RQF – GESTIÓN DE USUARIOS / RQF18 – ROLES
SELECT idUsuario, nombreUsuario, correoElectronico, tipoDocumento, telefono, rol
FROM usuario ORDER BY rol, nombreUsuario;

SELECT idUsuario, nombreUsuario, correoElectronico, telefono, rol
FROM usuario WHERE rol = @rolBuscado ORDER BY nombreUsuario;

SELECT u.idUsuario, u.nombreUsuario, u.correoElectronico, u.telefono, u.rol,
       CASE WHEN od.idOdontologo IS NOT NULL THEN od.especialidad ELSE 'N/A' END AS especialidad
FROM usuario u
LEFT JOIN odontologo od ON od.usuarioFK = u.idUsuario
WHERE u.rol != 'Inactivo'
ORDER BY u.rol, u.nombreUsuario;

UPDATE usuario SET rol = @nuevoRol WHERE idUsuario = @idUsuario;
UPDATE usuario SET rol = 'Inactivo' WHERE idUsuario = @idUsuario;

-- RQF – INFORMACIÓN GENERAL DEL PACIENTE / RQF07 – EDICIÓN
SELECT p.idpaciente, p.nombrePaciente, p.documentoPaciente, p.direccionPaciente,
       p.fechaNacPaciente, TIMESTAMPDIFF(YEAR, p.fechaNacPaciente, CURDATE()) AS edadActual,
       p.Preexistencias, p.Alergias, p.telefono, p.correoElectronico, p.tipoDocumento
FROM paciente p WHERE p.idpaciente = @idPaciente;

UPDATE paciente
SET nombrePaciente = @nombrePaciente, direccionPaciente = @direccionPaciente,
    Preexistencias = @Preexistencias, Alergias = @Alergias,
    telefono = @telefono, correoElectronico = @correoElectronico
WHERE idpaciente = @idPaciente;

-- RQF03 – BÚSQUEDA DE HISTORIA CLÍNICA POR PARÁMETROS
SELECT p.idpaciente, p.nombrePaciente, p.documentoPaciente, p.telefono,
       hc.idHistoriaClinica, hc.fechaApertura, hc.estado AS estadoHistoria
FROM paciente p
LEFT JOIN historiaClinica hc ON hc.pacienteFK = p.idpaciente
WHERE p.nombrePaciente LIKE CONCAT('%', @termino, '%')
   OR p.documentoPaciente LIKE CONCAT('%', @termino, '%')
   OR p.telefono LIKE CONCAT('%', @termino, '%')
ORDER BY p.nombrePaciente;

SELECT p.idpaciente, p.nombrePaciente, p.documentoPaciente, hc.idHistoriaClinica
FROM paciente p INNER JOIN historiaClinica hc ON hc.pacienteFK = p.idpaciente
WHERE p.nombrePaciente = @nombrePaciente;

SELECT p.idpaciente, p.nombrePaciente, p.documentoPaciente, hc.idHistoriaClinica
FROM paciente p INNER JOIN historiaClinica hc ON hc.pacienteFK = p.idpaciente
WHERE p.documentoPaciente = @documentoPaciente;

SELECT p.idpaciente, p.nombrePaciente, p.telefono, hc.idHistoriaClinica
FROM paciente p INNER JOIN historiaClinica hc ON hc.pacienteFK = p.idpaciente
WHERE p.telefono = @telefono;

-- RQF01 – HISTORIA CLÍNICA COMPLETA
SELECT hc.idHistoriaClinica, hc.fechaApertura, hc.estado, hc.observaciones,
       p.nombrePaciente, p.documentoPaciente, p.fechaNacPaciente,
       TIMESTAMPDIFF(YEAR, p.fechaNacPaciente, CURDATE()) AS edad,
       p.Preexistencias, p.Alergias, p.telefono, p.correoElectronico
FROM historiaClinica hc
INNER JOIN paciente p ON hc.pacienteFK = p.idpaciente
WHERE hc.idHistoriaClinica = @idHistoriaClinica;

-- RQF – ANAMNESIS
SELECT idAnamnesis, motivoConsulta, enfermedadActual, antecedentesPersonales,
       antecedentesFamiliares, revisionSistemas, fechaRegistro
FROM anamnesis WHERE historiaClinicaFK = @idHistoriaClinica ORDER BY fechaRegistro DESC;

UPDATE anamnesis SET motivoConsulta = @motivoConsulta, enfermedadActual = @enfermedadActual,
       antecedentesPersonales = @antecedentesPersonales,
       antecedentesFamiliares = @antecedentesFamiliares,
       revisionSistemas = @revisionSistemas, fechaRegistro = CURDATE()
WHERE idAnamnesis = @idAnamnesis;

-- RQF – SIGNOS VITALES
SELECT idSignosVitales, presionArterial, frecuenciaCardiaca, frecuenciaRespiratoria,
       temperatura, peso, talla, imc, glucemia, fechaRegistro
FROM signos_vitales WHERE historiaClinicaFK = @idHistoriaClinica ORDER BY fechaRegistro DESC;

SELECT presionArterial, frecuenciaCardiaca, frecuenciaRespiratoria,
       temperatura, peso, talla, imc, glucemia, fechaRegistro
FROM signos_vitales WHERE historiaClinicaFK = @idHistoriaClinica ORDER BY fechaRegistro DESC LIMIT 1;

UPDATE signos_vitales SET presionArterial = @presionArterial,
       frecuenciaCardiaca = @frecuenciaCardiaca,
       frecuenciaRespiratoria = @frecuenciaRespiratoria,
       temperatura = @temperatura, peso = @peso, talla = @talla, imc = @imc,
       glucemia = @glucemia, fechaRegistro = CURDATE()
WHERE idSignosVitales = @idSignosVitales;

-- RQF – HÁBITOS DE HIGIENE ORAL
SELECT idHabitosHigiene, frecuenciaCepillado, usaHilosDental, usaEnjuague,
       visitaDentistaPeriodica, consumoTabaco, consumoAlcohol, observaciones, fechaRegistro
FROM habitos_higiene WHERE historiaClinicaFK = @idHistoriaClinica ORDER BY fechaRegistro DESC;

UPDATE habitos_higiene SET frecuenciaCepillado = @frecuenciaCepillado,
       usaHilosDental = @usaHilosDental, usaEnjuague = @usaEnjuague,
       visitaDentistaPeriodica = @visitaDentistaPeriodica,
       consumoTabaco = @consumoTabaco, consumoAlcohol = @consumoAlcohol,
       observaciones = @observaciones, fechaRegistro = CURDATE()
WHERE idHabitosHigiene = @idHabitosHigiene;

-- RQF11 – MEDICAMENTOS FORMULADOS
SELECT idMedicamento, nombreMedicamento, principioActivo, dosis,
       frecuencia, viaAdministracion, motivoUso, fechaInicio, fechaFin
FROM medicamentos WHERE historiaClinicaFK = @idHistoriaClinica ORDER BY fechaInicio DESC;

SELECT nombreMedicamento, principioActivo, dosis, frecuencia, viaAdministracion, motivoUso, fechaInicio, fechaFin
FROM medicamentos WHERE historiaClinicaFK = @idHistoriaClinica
  AND (fechaFin IS NULL OR fechaFin >= CURDATE()) ORDER BY fechaInicio DESC;

-- RQF – EXAMEN DENTAL Y ODONTOGRAMA
SELECT idExamen, hallazgos, odontograma, fechaRegistro
FROM examen_dental WHERE historiaClinicaFK = @idHistoriaClinica ORDER BY fechaRegistro DESC;

UPDATE examen_dental SET hallazgos = @hallazgos, odontograma = @odontograma, fechaRegistro = CURDATE()
WHERE idExamen = @idExamen;

-- RQF02 – CONSENTIMIENTO POR PROCEDIMIENTO
SELECT idConsentimiento, procedimiento, fechaFirma, firmaPaciente, firmaProfesional, observaciones
FROM consentimiento WHERE historiaClinicaFK = @idHistoriaClinica ORDER BY fechaFirma DESC;

SELECT idConsentimiento, procedimiento, fechaFirma, firmaPaciente, firmaProfesional
FROM consentimiento WHERE historiaClinicaFK = @idHistoriaClinica
  AND (firmaPaciente = 'Pendiente' OR firmaProfesional = 'Pendiente');

UPDATE consentimiento SET firmaPaciente = 'Firmado' WHERE idConsentimiento = @idConsentimiento;
UPDATE consentimiento SET firmaProfesional = 'Firmado' WHERE idConsentimiento = @idConsentimiento;

-- RQF04/08/09/28 – EVOLUCIONES
SELECT e.idEvolucion, e.fechaSesion, u.nombreUsuario AS nombreOdontologo,
       e.estadoActual, e.consultaAnterior, e.cambiosTratamiento, e.respuestaPaciente,
       e.huboRemision, e.huboInterconsulta, e.cambioProfesional, e.observaciones
FROM evolucion e
INNER JOIN odontologo od ON e.odontologoFK = od.idOdontologo
INNER JOIN usuario u ON od.usuarioFK = u.idUsuario
WHERE e.historiaClinicaFK = @idHistoriaClinica ORDER BY e.fechaSesion DESC;

SELECT e.fechaSesion, u.nombreUsuario AS nombreOdontologo, e.estadoActual,
       e.consultaAnterior, e.cambiosTratamiento, e.respuestaPaciente
FROM evolucion e
INNER JOIN odontologo od ON e.odontologoFK = od.idOdontologo
INNER JOIN usuario u ON od.usuarioFK = u.idUsuario
WHERE e.historiaClinicaFK = @idHistoriaClinica ORDER BY e.fechaSesion DESC LIMIT 1;

UPDATE evolucion SET estadoActual = @estadoActual, cambiosTratamiento = @cambiosTratamiento,
       respuestaPaciente = @respuestaPaciente, huboRemision = @huboRemision,
       huboInterconsulta = @huboInterconsulta, cambioProfesional = @cambioProfesional,
       observaciones = @observaciones WHERE idEvolucion = @idEvolucion;

-- RQF05 – CONTROL DE ASISTENCIA A CITAS
SELECT c.idCita, c.horario, c.tratamiento, c.estado, u.nombreUsuario AS nombreOdontologo
FROM citaOdontologico c
INNER JOIN odontologo od ON c.odontologoFK = od.idOdontologo
INNER JOIN usuario u ON od.usuarioFK = u.idUsuario
WHERE c.pacienteFK = @idPaciente ORDER BY c.horario DESC;

UPDATE citaOdontologico SET estado = @estado WHERE idCita = @idCita;

-- RQF06/10/29/30/31 – CLASIFICACIÓN POR PREEXISTENCIAS
SELECT p.idpaciente, p.nombrePaciente, p.documentoPaciente, p.Preexistencias, p.Alergias, hc.idHistoriaClinica
FROM paciente p LEFT JOIN historiaClinica hc ON hc.pacienteFK = p.idpaciente
WHERE p.Preexistencias LIKE CONCAT('%', @preexistencia, '%') ORDER BY p.nombrePaciente;

SELECT p.idpaciente, p.nombrePaciente, p.documentoPaciente, p.Preexistencias
FROM paciente p WHERE p.Preexistencias LIKE CONCAT('%', @categoriaPreexistencia, '%')
   OR p.Alergias LIKE CONCAT('%', @categoriaPreexistencia, '%') ORDER BY p.nombrePaciente;

SELECT p.idpaciente, p.nombrePaciente, p.documentoPaciente, p.Preexistencias, p.Alergias,
       hc.idHistoriaClinica, hc.estado AS estadoHistoria
FROM paciente p INNER JOIN historiaClinica hc ON hc.pacienteFK = p.idpaciente
WHERE p.Preexistencias IS NOT NULL AND p.Preexistencias NOT IN ('', 'Ninguna')
ORDER BY p.Preexistencias, p.nombrePaciente;

UPDATE paciente SET Preexistencias = @Preexistencias, Alergias = @Alergias WHERE idpaciente = @idPaciente;

-- RQF13 – AYUDAS DIAGNÓSTICAS
SELECT idAyuda, codigoCIE, descripcionDiagnostico, pronostico, rutaArchivo, tipoArchivo, fechaRegistro
FROM ayuda_diagnostica WHERE historiaClinicaFK = @idHistoriaClinica ORDER BY fechaRegistro DESC;

SELECT ad.codigoCIE, ad.descripcionDiagnostico, ad.pronostico,
       p.nombrePaciente, p.documentoPaciente, ad.fechaRegistro
FROM ayuda_diagnostica ad
INNER JOIN historiaClinica hc ON ad.historiaClinicaFK = hc.idHistoriaClinica
INNER JOIN paciente p ON hc.pacienteFK = p.idpaciente
WHERE ad.codigoCIE = @codigoCIE ORDER BY ad.fechaRegistro DESC;

-- RQF14 – PLANES DE TRATAMIENTO
SELECT idPlan, descripcion, presupuesto, saldoPendiente, fechaInicio, fechaFin, estado
FROM plan_tratamiento WHERE historiaClinicaFK = @idHistoriaClinica ORDER BY fechaInicio DESC;

UPDATE plan_tratamiento SET estado = @estado, saldoPendiente = @saldoPendiente WHERE idPlan = @idPlan;

-- RQF15 – REPORTES Y ESTADÍSTICAS
SELECT YEAR(horario) AS anio, MONTH(horario) AS mes, MONTHNAME(horario) AS nombreMes,
       COUNT(DISTINCT pacienteFK) AS totalPacientes, COUNT(idCita) AS totalCitas
FROM citaOdontologico WHERE YEAR(horario) = YEAR(CURDATE()) AND estado = 'Confirmada Asistida'
GROUP BY YEAR(horario), MONTH(horario) ORDER BY mes;

SELECT u.nombreUsuario AS nombreOdontologo, od.especialidad, COUNT(c.idCita) AS totalCitas,
       SUM(CASE WHEN c.estado = 'Confirmada Asistida' THEN 1 ELSE 0 END) AS asistidas,
       SUM(CASE WHEN c.estado = 'Confirmada No Asistida' THEN 1 ELSE 0 END) AS noAsistidas,
       SUM(CASE WHEN c.estado = 'Cancelada' THEN 1 ELSE 0 END) AS canceladas
FROM citaOdontologico c
INNER JOIN odontologo od ON c.odontologoFK = od.idOdontologo
INNER JOIN usuario u ON od.usuarioFK = u.idUsuario
GROUP BY od.idOdontologo, u.nombreUsuario, od.especialidad ORDER BY totalCitas DESC;

SELECT tratamiento, COUNT(*) AS frecuencia FROM citaOdontologico
WHERE tratamiento IS NOT NULL GROUP BY tratamiento ORDER BY frecuencia DESC;

SELECT YEAR(fecha) AS anio, MONTH(fecha) AS mes, MONTHNAME(fecha) AS nombreMes,
       SUM(monto) AS ingresoTotal, COUNT(idPago) AS numeroPagos
FROM pago WHERE YEAR(fecha) = YEAR(CURDATE()) GROUP BY YEAR(fecha), MONTH(fecha) ORDER BY mes;

-- RQF16/17 – GESTIÓN DE CITAS
SELECT c.idCita, c.horario, p.nombrePaciente, p.documentoPaciente,
       p.telefono AS telefonoPaciente, c.tratamiento, c.estado
FROM citaOdontologico c INNER JOIN paciente p ON c.pacienteFK = p.idpaciente
WHERE c.odontologoFK = @idOdontologo AND DATE(c.horario) = @fecha ORDER BY c.horario;

SELECT c.idCita, c.horario, p.nombrePaciente, c.tratamiento, c.estado
FROM citaOdontologico c INNER JOIN paciente p ON c.pacienteFK = p.idpaciente
WHERE YEAR(c.horario) = @anio ORDER BY c.horario;

SELECT c.idCita, c.horario, p.nombrePaciente, c.tratamiento, c.estado
FROM citaOdontologico c INNER JOIN paciente p ON c.pacienteFK = p.idpaciente
WHERE MONTH(c.horario) = @mes AND YEAR(c.horario) = @anio ORDER BY c.horario;

SELECT c.idCita, c.horario, p.nombrePaciente, p.telefono AS telefonoPaciente,
       p.correoElectronico, c.tratamiento, c.estado
FROM citaOdontologico c INNER JOIN paciente p ON c.pacienteFK = p.idpaciente
WHERE c.horario BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
  AND c.estado NOT IN ('Cancelada', 'Confirmada Asistida') ORDER BY c.horario;

SELECT c.idCita, c.horario, p.nombrePaciente, c.tratamiento, c.estado
FROM citaOdontologico c INNER JOIN paciente p ON c.pacienteFK = p.idpaciente
WHERE c.estado = @estado ORDER BY c.horario DESC;

-- RQF19 – ALMACENAMIENTO / VERIFICACIÓN DE DATOS
SELECT table_name AS tabla, table_rows AS filas_estimadas,
       ROUND(data_length / 1024, 2) AS datos_KB,
       ROUND(index_length / 1024, 2) AS indices_KB,
       create_time AS fecha_creacion, update_time AS ultima_modificacion
FROM information_schema.tables WHERE table_schema = 'clinicaodontologica' ORDER BY table_name;

-- RQF21 – VALIDACIÓN DE DUPLICADOS
SELECT COUNT(*) AS existe, nombrePaciente, documentoPaciente
FROM paciente WHERE documentoPaciente = @documentoPaciente GROUP BY nombrePaciente, documentoPaciente;

SELECT COUNT(*) AS existe FROM usuario WHERE userName = @userName;

-- RQF23 – RESULTADOS DE CONSULTA GENERAL
SELECT p.idpaciente, p.nombrePaciente, p.documentoPaciente,
       TIMESTAMPDIFF(YEAR, p.fechaNacPaciente, CURDATE()) AS edad,
       p.Preexistencias, hc.idHistoriaClinica, hc.fechaApertura, hc.estado AS estadoHistoria
FROM paciente p LEFT JOIN historiaClinica hc ON hc.pacienteFK = p.idpaciente ORDER BY p.nombrePaciente;

-- RQF33 – EXPORTACIÓN DE HISTORIA CLÍNICA
SELECT p.nombrePaciente, p.documentoPaciente, p.fechaNacPaciente,
       TIMESTAMPDIFF(YEAR, p.fechaNacPaciente, CURDATE()) AS edad, p.direccionPaciente,
       p.Preexistencias, p.Alergias, hc.idHistoriaClinica, hc.fechaApertura, hc.estado, hc.observaciones
FROM historiaClinica hc INNER JOIN paciente p ON hc.pacienteFK = p.idpaciente
WHERE hc.idHistoriaClinica = @idHistoriaClinica;

SELECT motivoConsulta, enfermedadActual, antecedentesPersonales, antecedentesFamiliares, revisionSistemas, fechaRegistro
FROM anamnesis WHERE historiaClinicaFK = @idHistoriaClinica ORDER BY fechaRegistro DESC LIMIT 1;

SELECT presionArterial, frecuenciaCardiaca, frecuenciaRespiratoria, temperatura, peso, talla, imc, glucemia, fechaRegistro
FROM signos_vitales WHERE historiaClinicaFK = @idHistoriaClinica ORDER BY fechaRegistro DESC LIMIT 1;

SELECT nombreMedicamento, dosis, frecuencia, viaAdministracion, motivoUso
FROM medicamentos WHERE historiaClinicaFK = @idHistoriaClinica AND (fechaFin IS NULL OR fechaFin >= CURDATE());

SELECT codigoCIE, descripcionDiagnostico, pronostico, fechaRegistro
FROM ayuda_diagnostica WHERE historiaClinicaFK = @idHistoriaClinica ORDER BY fechaRegistro DESC;

SELECT e.fechaSesion, u.nombreUsuario AS odontologo, e.estadoActual, e.cambiosTratamiento, e.respuestaPaciente, e.huboRemision, e.observaciones
FROM evolucion e
INNER JOIN odontologo od ON e.odontologoFK = od.idOdontologo
INNER JOIN usuario u ON od.usuarioFK = u.idUsuario
WHERE e.historiaClinicaFK = @idHistoriaClinica ORDER BY e.fechaSesion;

SELECT odontograma, hallazgos, fechaRegistro FROM examen_dental
WHERE historiaClinicaFK = @idHistoriaClinica ORDER BY fechaRegistro DESC LIMIT 1;

-- RQF35 – LOGS DE ACTIVIDAD DE USUARIOS
SELECT 'usuario' AS tabla, accion, fechaAuditoria, usuarioAudit FROM usuario_auditoria
    WHERE usuarioAudit = @usuarioAudit AND DATE(fechaAuditoria) BETWEEN @fechaInicio AND @fechaFin
UNION ALL
SELECT 'paciente', accion, fechaAuditoria, usuarioAudit FROM paciente_auditoria
    WHERE usuarioAudit = @usuarioAudit AND DATE(fechaAuditoria) BETWEEN @fechaInicio AND @fechaFin
UNION ALL
SELECT 'historiaClinica', accion, fechaAuditoria, usuarioAudit FROM historiaClinica_auditoria
    WHERE usuarioAudit = @usuarioAudit AND DATE(fechaAuditoria) BETWEEN @fechaInicio AND @fechaFin
UNION ALL
SELECT 'evolucion', accion, fechaAuditoria, usuarioAudit FROM evolucion_auditoria
    WHERE usuarioAudit = @usuarioAudit AND DATE(fechaAuditoria) BETWEEN @fechaInicio AND @fechaFin
UNION ALL
SELECT 'citaOdontologico', accion, fechaAuditoria, usuarioAudit FROM citaOdontologico_auditoria
    WHERE usuarioAudit = @usuarioAudit AND DATE(fechaAuditoria) BETWEEN @fechaInicio AND @fechaFin
UNION ALL
SELECT 'pago', accion, fechaAuditoria, usuarioAudit FROM pago_auditoria
    WHERE usuarioAudit = @usuarioAudit AND DATE(fechaAuditoria) BETWEEN @fechaInicio AND @fechaFin
ORDER BY fechaAuditoria DESC;

SELECT tabla, accion, COUNT(*) AS total FROM (
    SELECT 'usuario' AS tabla, accion FROM usuario_auditoria
    UNION ALL SELECT 'paciente', accion FROM paciente_auditoria
    UNION ALL SELECT 'historiaClinica', accion FROM historiaClinica_auditoria
    UNION ALL SELECT 'evolucion', accion FROM evolucion_auditoria
    UNION ALL SELECT 'citaOdontologico', accion FROM citaOdontologico_auditoria
    UNION ALL SELECT 'pago', accion FROM pago_auditoria
) AS todas GROUP BY tabla, accion ORDER BY tabla, accion;

-- RQF37/38 – PAGOS Y ABONOS
SELECT p.idPago, p.fecha, p.monto, p.metodoPago, p.estado, c.tratamiento
FROM pago p LEFT JOIN citaOdontologico c ON c.pagoFK = p.idPago
WHERE p.pacienteFK = @idPaciente ORDER BY p.fecha DESC;

SELECT SUM(monto) AS totalPagado FROM pago
WHERE pacienteFK = @idPaciente AND estado NOT IN ('Anulado', 'Rechazado');

SELECT pt.descripcion, pt.presupuesto, pt.saldoPendiente,
       (pt.presupuesto - pt.saldoPendiente) AS totalPagado, pt.estado
FROM plan_tratamiento pt WHERE pt.idPlan = @idPlan;

SELECT pg.idPago, pg.fecha, pg.monto, pg.metodoPago, pg.estado, c.tratamiento, c.horario AS fechaCita
FROM pago pg
INNER JOIN citaOdontologico c ON c.pagoFK = pg.idPago
INNER JOIN historiaClinica hc ON hc.pacienteFK = c.pacienteFK
WHERE hc.idHistoriaClinica = @idHistoriaClinica ORDER BY pg.fecha DESC;

SELECT metodoPago, COUNT(idPago) AS numeroPagos, SUM(monto) AS totalRecaudado, AVG(monto) AS promedioMonto
FROM pago WHERE estado NOT IN ('Anulado', 'Rechazado') GROUP BY metodoPago ORDER BY totalRecaudado DESC;

-- ============================================================
-- SECCIÓN 5: PROCEDIMIENTOS ALMACENADOS Y CONSULTAS FALTANTES
-- ============================================================

-- ============================================================
-- RQF20 – CREACIÓN DE HISTORIA CLÍNICA
-- Registra nuevo paciente y crea su HC de forma atómica.
-- Verifica previamente que el documento no esté registrado.
-- ============================================================

DELIMITER $$

CREATE PROCEDURE sp_crearPacienteConHistoria(
    IN p_nombrePaciente    VARCHAR(50),
    IN p_tipoDocumento     VARCHAR(10),
    IN p_documentoPaciente VARCHAR(20),
    IN p_telefono          VARCHAR(20),
    IN p_correoElectronico VARCHAR(50),
    IN p_direccionPaciente VARCHAR(100),
    IN p_fechaNacPaciente  DATE,
    IN p_Preexistencias    VARCHAR(500),
    IN p_Alergias          VARCHAR(100)
)
BEGIN
    DECLARE v_existe INT DEFAULT 0;
    DECLARE v_idPaciente INT;

    -- RQF21: verificar duplicado antes de insertar
    SELECT COUNT(*) INTO v_existe
    FROM paciente
    WHERE documentoPaciente = p_documentoPaciente;

    IF v_existe > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ya existe un paciente registrado con ese documento.';
    ELSE
        START TRANSACTION;

        INSERT INTO paciente (
            nombrePaciente, tipoDocumento, documentoPaciente, telefono,
            correoElectronico, direccionPaciente, fechaNacPaciente,
            Preexistencias, Alergias
        ) VALUES (
            p_nombrePaciente, p_tipoDocumento, p_documentoPaciente, p_telefono,
            p_correoElectronico, p_direccionPaciente, p_fechaNacPaciente,
            p_Preexistencias, p_Alergias
        );

        SET v_idPaciente = LAST_INSERT_ID();

        INSERT INTO historiaClinica (fechaApertura, estado, pacienteFK)
        VALUES (CURDATE(), 'Activa', v_idPaciente);

        COMMIT;

        SELECT v_idPaciente AS idPacienteCreado, LAST_INSERT_ID() AS idHistoriaCreada;
    END IF;
END$$

DELIMITER ;

-- ============================================================
-- RQF24 – REGISTRO DE ANAMNESIS
-- ============================================================
INSERT INTO anamnesis (
    historiaClinicaFK, motivoConsulta, enfermedadActual,
    antecedentesPersonales, antecedentesFamiliares,
    revisionSistemas, fechaRegistro
) VALUES (
    @idHistoriaClinica, @motivoConsulta, @enfermedadActual,
    @antecedentesPersonales, @antecedentesFamiliares,
    @revisionSistemas, CURDATE()
);

-- ============================================================
-- RQF12 – REGISTRO DE SIGNOS VITALES
-- ============================================================
INSERT INTO signos_vitales (
    historiaClinicaFK, presionArterial, frecuenciaCardiaca,
    frecuenciaRespiratoria, temperatura, peso, talla, imc, glucemia, fechaRegistro
) VALUES (
    @idHistoriaClinica, @presionArterial, @frecuenciaCardiaca,
    @frecuenciaRespiratoria, @temperatura, @peso, @talla, @imc, @glucemia, CURDATE()
);

-- ============================================================
-- RQF25 – REGISTRO DE HÁBITOS DE HIGIENE ORAL
-- ============================================================
INSERT INTO habitos_higiene (
    historiaClinicaFK, frecuenciaCepillado, usaHilosDental,
    usaEnjuague, visitaDentistaPeriodica, consumoTabaco,
    consumoAlcohol, observaciones, fechaRegistro
) VALUES (
    @idHistoriaClinica, @frecuenciaCepillado, @usaHilosDental,
    @usaEnjuague, @visitaDentistaPeriodica, @consumoTabaco,
    @consumoAlcohol, @observaciones, CURDATE()
);

-- ============================================================
-- RQF11 – REGISTRO DE MEDICAMENTOS
-- ============================================================
INSERT INTO medicamentos (
    historiaClinicaFK, nombreMedicamento, principioActivo,
    dosis, frecuencia, viaAdministracion, motivoUso, fechaInicio, fechaFin
) VALUES (
    @idHistoriaClinica, @nombreMedicamento, @principioActivo,
    @dosis, @frecuencia, @viaAdministracion, @motivoUso, @fechaInicio, @fechaFin
);

-- ============================================================
-- RQF26 – REGISTRO DEL EXAMEN DENTAL
-- ============================================================
INSERT INTO examen_dental (historiaClinicaFK, hallazgos, odontograma, fechaRegistro)
VALUES (@idHistoriaClinica, @hallazgos, @odontograma, CURDATE());

-- ============================================================
-- RQF02 – REGISTRO DE CONSENTIMIENTO
-- ============================================================
INSERT INTO consentimiento (
    historiaClinicaFK, procedimiento, fechaFirma,
    firmaPaciente, firmaProfesional, observaciones
) VALUES (
    @idHistoriaClinica, @procedimiento, @fechaFirma,
    @firmaPaciente, @firmaProfesional, @observaciones
);

-- ============================================================
-- RQF13 – REGISTRO DE AYUDA DIAGNÓSTICA
-- ============================================================
INSERT INTO ayuda_diagnostica (
    historiaClinicaFK, codigoCIE, descripcionDiagnostico,
    pronostico, rutaArchivo, tipoArchivo, fechaRegistro
) VALUES (
    @idHistoriaClinica, @codigoCIE, @descripcionDiagnostico,
    @pronostico, @rutaArchivo, @tipoArchivo, CURDATE()
);

-- ============================================================
-- RQF14 – CREACIÓN DE PLAN DE TRATAMIENTO
-- ============================================================
INSERT INTO plan_tratamiento (
    historiaClinicaFK, descripcion, presupuesto,
    saldoPendiente, fechaInicio, fechaFin, estado
) VALUES (
    @idHistoriaClinica, @descripcion, @presupuesto,
    @presupuesto, @fechaInicio, @fechaFin, 'Activo'
);

-- ============================================================
-- RQF04 – REGISTRO DE EVOLUCIÓN CLÍNICA
-- ============================================================
INSERT INTO evolucion (
    historiaClinicaFK, odontologoFK, fechaSesion, estadoActual,
    consultaAnterior, cambiosTratamiento, respuestaPaciente,
    huboRemision, huboInterconsulta, cambioProfesional, observaciones
) VALUES (
    @idHistoriaClinica, @idOdontologo, NOW(), @estadoActual,
    @consultaAnterior, @cambiosTratamiento, @respuestaPaciente,
    @huboRemision, @huboInterconsulta, @cambioProfesional, @observaciones
);

-- ============================================================
-- RQF27 – GESTIÓN DE PERSONAL: REGISTRO DE ODONTÓLOGO
-- Requiere primero crear el usuario asociado
-- ============================================================
INSERT INTO usuario (nombreUsuario, telefono, correoElectronico, tipoDocumento, userName, contrasena, rol)
VALUES (@nombreUsuario, @telefono, @correoElectronico, @tipoDocumento, @userName, @hashContrasena, 'Odontologo');

INSERT INTO odontologo (tarjetaProfesional, especialidad, usuarioFK)
VALUES (@tarjetaProfesional, @especialidad, LAST_INSERT_ID());

-- Actualización de datos de odontólogo
UPDATE odontologo
SET tarjetaProfesional = @tarjetaProfesional, especialidad = @especialidad
WHERE idOdontologo = @idOdontologo;

-- Consulta de odontólogos con datos de usuario
SELECT od.idOdontologo, u.nombreUsuario, u.correoElectronico, u.telefono,
       od.tarjetaProfesional, od.especialidad, u.rol
FROM odontologo od
INNER JOIN usuario u ON od.usuarioFK = u.idUsuario
ORDER BY u.nombreUsuario;

-- RQF27 – GESTIÓN DE PERSONAL: REGISTRO DE AUXILIAR
INSERT INTO usuario (nombreUsuario, telefono, correoElectronico, tipoDocumento, userName, contrasena, rol)
VALUES (@nombreUsuario, @telefono, @correoElectronico, @tipoDocumento, @userName, @hashContrasena, 'Auxiliar');

INSERT INTO auxiliar (tarjetaProfesionalAux, usuarioFK)
VALUES (@tarjetaProfesionalAux, LAST_INSERT_ID());

-- Actualización de datos de auxiliar
UPDATE auxiliar
SET tarjetaProfesionalAux = @tarjetaProfesionalAux
WHERE idAuxiliar = @idAuxiliar;

-- Consulta de auxiliares con datos de usuario
SELECT ax.idAuxiliar, u.nombreUsuario, u.correoElectronico, u.telefono,
       ax.tarjetaProfesionalAux, u.rol
FROM auxiliar ax
INNER JOIN usuario u ON ax.usuarioFK = u.idUsuario
ORDER BY u.nombreUsuario;

-- ============================================================
-- RQF32 – CREACIÓN Y ASIGNACIÓN DE CITAS ODONTOLÓGICAS
-- ============================================================
-- Registro de pago previo opcional
INSERT INTO pago (fecha, monto, metodoPago, estado, pacienteFK)
VALUES (@fecha, @monto, @metodoPago, 'Pendiente', @idPaciente);

-- Registro de la cita (con o sin pago asociado)
INSERT INTO citaOdontologico (odontologoFK, pacienteFK, pagoFK, horario, tratamiento, estado)
VALUES (@idOdontologo, @idPaciente, @idPago, @horario, @tratamiento, 'Pendiente');

-- Cita sin pago asociado
INSERT INTO citaOdontologico (odontologoFK, pacienteFK, horario, tratamiento, estado)
VALUES (@idOdontologo, @idPaciente, @horario, @tratamiento, 'Pendiente');

-- ============================================================
-- RQF37 – REGISTRO DE PAGO
-- ============================================================
INSERT INTO pago (fecha, monto, metodoPago, estado, pacienteFK)
VALUES (@fecha, @monto, @metodoPago, @estado, @idPaciente);

-- Actualización de estado de pago
UPDATE pago SET estado = @nuevoEstado WHERE idPago = @idPago;

-- ============================================================
-- RQF36 – TRAZABILIDAD DE MODIFICACIONES CON AUDITORÍA
-- Consulta del historial de cambios sobre paciente, HC y evoluciones
-- ============================================================

-- Historial de modificaciones del paciente
SELECT accion, nombrePaciente, documentoPaciente, Preexistencias, Alergias,
       fechaAuditoria, usuarioAudit
FROM paciente_auditoria
WHERE idpaciente = @idPaciente
ORDER BY fechaAuditoria DESC;

-- Historial de modificaciones de la historia clínica
SELECT accion, estado, observaciones, fechaAuditoria, usuarioAudit
FROM historiaClinica_auditoria
WHERE idHistoriaClinica = @idHistoriaClinica
ORDER BY fechaAuditoria DESC;

-- Historial de modificaciones de evoluciones de una HC
SELECT ea.accion, ea.fechaSesion, ea.estadoActual, ea.cambiosTratamiento,
       ea.respuestaPaciente, ea.observaciones, ea.fechaAuditoria, ea.usuarioAudit
FROM evolucion_auditoria ea
WHERE ea.historiaClinicaFK = @idHistoriaClinica
ORDER BY ea.fechaAuditoria DESC;

-- ============================================================
-- RQF39 – CONSULTA DE AUDITORÍA DE TABLAS CLÍNICAS
-- ============================================================

-- Auditoría de anamnesis
SELECT 'anamnesis' AS tabla, idAnamnesis AS idRegistro, historiaClinicaFK,
       accion, fechaAuditoria, usuarioAudit
FROM anamnesis_auditoria
WHERE historiaClinicaFK = @idHistoriaClinica
ORDER BY fechaAuditoria DESC;

-- Auditoría de signos vitales
SELECT 'signos_vitales' AS tabla, idSignosVitales AS idRegistro, historiaClinicaFK,
       accion, fechaAuditoria, usuarioAudit
FROM signos_vitales_auditoria
WHERE historiaClinicaFK = @idHistoriaClinica
ORDER BY fechaAuditoria DESC;

-- Auditoría de hábitos de higiene
SELECT 'habitos_higiene' AS tabla, idHabitosHigiene AS idRegistro, historiaClinicaFK,
       accion, fechaAuditoria, usuarioAudit
FROM habitos_higiene_auditoria
WHERE historiaClinicaFK = @idHistoriaClinica
ORDER BY fechaAuditoria DESC;

-- Auditoría de medicamentos
SELECT 'medicamentos' AS tabla, idMedicamento AS idRegistro, historiaClinicaFK,
       nombreMedicamento, accion, fechaAuditoria, usuarioAudit
FROM medicamentos_auditoria
WHERE historiaClinicaFK = @idHistoriaClinica
ORDER BY fechaAuditoria DESC;

-- Auditoría de examen dental
SELECT 'examen_dental' AS tabla, idExamen AS idRegistro, historiaClinicaFK,
       accion, fechaAuditoria, usuarioAudit
FROM examen_dental_auditoria
WHERE historiaClinicaFK = @idHistoriaClinica
ORDER BY fechaAuditoria DESC;

-- Auditoría de consentimientos
SELECT 'consentimiento' AS tabla, idConsentimiento AS idRegistro, historiaClinicaFK,
       procedimiento, accion, fechaAuditoria, usuarioAudit
FROM consentimiento_auditoria
WHERE historiaClinicaFK = @idHistoriaClinica
ORDER BY fechaAuditoria DESC;

-- Auditoría de ayudas diagnósticas
SELECT 'ayuda_diagnostica' AS tabla, idAyuda AS idRegistro, historiaClinicaFK,
       codigoCIE, accion, fechaAuditoria, usuarioAudit
FROM ayuda_diagnostica_auditoria
WHERE historiaClinicaFK = @idHistoriaClinica
ORDER BY fechaAuditoria DESC;

-- Auditoría de planes de tratamiento
SELECT 'plan_tratamiento' AS tabla, idPlan AS idRegistro, historiaClinicaFK,
       descripcion, accion, fechaAuditoria, usuarioAudit
FROM plan_tratamiento_auditoria
WHERE historiaClinicaFK = @idHistoriaClinica
ORDER BY fechaAuditoria DESC;

-- Resumen consolidado de todas las tablas clínicas por historia clínica
SELECT 'anamnesis'        AS tabla, idAnamnesis        AS idRegistro, accion, fechaAuditoria, usuarioAudit FROM anamnesis_auditoria        WHERE historiaClinicaFK = @idHistoriaClinica
UNION ALL
SELECT 'signos_vitales',           idSignosVitales,                  accion, fechaAuditoria, usuarioAudit FROM signos_vitales_auditoria    WHERE historiaClinicaFK = @idHistoriaClinica
UNION ALL
SELECT 'habitos_higiene',          idHabitosHigiene,                 accion, fechaAuditoria, usuarioAudit FROM habitos_higiene_auditoria   WHERE historiaClinicaFK = @idHistoriaClinica
UNION ALL
SELECT 'medicamentos',             idMedicamento,                    accion, fechaAuditoria, usuarioAudit FROM medicamentos_auditoria      WHERE historiaClinicaFK = @idHistoriaClinica
UNION ALL
SELECT 'examen_dental',            idExamen,                         accion, fechaAuditoria, usuarioAudit FROM examen_dental_auditoria     WHERE historiaClinicaFK = @idHistoriaClinica
UNION ALL
SELECT 'consentimiento',           idConsentimiento,                 accion, fechaAuditoria, usuarioAudit FROM consentimiento_auditoria    WHERE historiaClinicaFK = @idHistoriaClinica
UNION ALL
SELECT 'ayuda_diagnostica',        idAyuda,                          accion, fechaAuditoria, usuarioAudit FROM ayuda_diagnostica_auditoria WHERE historiaClinicaFK = @idHistoriaClinica
UNION ALL
SELECT 'plan_tratamiento',         idPlan,                           accion, fechaAuditoria, usuarioAudit FROM plan_tratamiento_auditoria  WHERE historiaClinicaFK = @idHistoriaClinica
ORDER BY fechaAuditoria DESC;