create database clinicaodontologica;
use clinicaodontologica;

create table usuario(
idUsuario  int (10) primary key ,
nombreUsuario varchar (50),
telefono varchar (20),
correoElectronico varchar (50),
tipoDocumento varchar (10),
userName varchar (20),
contrasena varchar (16));

create table odontologo(
idOdontologo int auto_increment primary key,
tarjetaProfesional varchar (50),
especialidad varchar (50), 
usuarioFK int (10),
foreign key (usuarioFK) references usuario(idUsuario) ON DELETE CASCADE
);

create table auxiliar(
idAuxiliar int auto_increment primary key,
tarjetaProfesionalAux varchar (50), 
usuarioFK int (10),
foreign key (usuarioFK) references usuario(idUsuario) ON DELETE CASCADE
);


create table paciente(
idpaciente int auto_increment primary key,
nombrePaciente varchar (50) not null, 
documentoPaciente int (10) not null,
direccionPaciente varchar (100)not null,
fechaNacPaciente date not null,
Preexistencias varchar (500),
Alergias varchar (100),
usuarioFK int(10),
foreign key (usuarioFK) references usuario(idUsuario) ON DELETE CASCADE
);

create table historiaClinica(
idHistoriaClinica int primary key auto_increment,
fechaApertura date not null,
estado varchar (70),
observaciones varchar (10000),
pacienteFK int not null,
foreign key (pacienteFk) references paciente(idpaciente)
);

create table pago(
idPago int auto_increment primary key,
fecha date not null,
monto double not null,
metodoPago varchar (100) not null,
estado varchar (50)
);

create table citaOdontologico(
idCita int auto_increment primary key,
odontologoFK int not null, 
pacienteFK int not null,
pagoFK int,
horario datetime,
tratamiento varchar(100),
estado varchar(50) DEFAULT 'Pendiente', -- esto lo dejo para lo de la agenda
foreign key (odontologoFK) references odontologo(idOdontologo),
foreign key (pacienteFK) references paciente(idpaciente),
foreign key (pagoFK) references pago(idPago)
);

-- =======================================================
-- 2. SECCIÓN DE CONSULTAS (Las 1 general y 7 específicas)
-- =======================================================

-- ## CONSULTA GENERAL (1 Requerida)
SELECT * FROM pago WHERE metodoPago = "Efectivo";

-- ## CONSULTAS ESPECÍFICAS (7 Requeridas)

-- 1. Paciente: Filtro por alergias 
SELECT nombrePaciente AS nombre, Preexistencias AS pre_Existencias 
FROM paciente WHERE Alergias = "Latex";

-- 2. Cita: Filtro de mes
SELECT odontologoFK AS ID_Odontologo, pacienteFK AS ID_Paciente, horario AS fecha 
FROM citaOdontologico 
WHERE MONTH(horario) = 4;

-- 3. Odontólogo: Datos cruzados con Usuarios
SELECT u.nombreUsuario AS nombreOdontologo, u.telefono, o.especialidad 
FROM odontologo o
INNER JOIN usuario u ON o.usuarioFK = u.idUsuario;

-- 4. Administrativa: Total de ingresos por método de pago los agrupa btw
SELECT metodoPago, SUM(monto) AS total_recaudado 
FROM pago 
GROUP BY metodoPago;

-- 5. Clínica: Pacientes con enfermedades sistémicas (Filtro NOT NULL)
SELECT nombrePaciente, Preexistencias 
FROM paciente 
WHERE Preexistencias IS NOT NULL AND Preexistencias != 'Ninguna';

-- 6. Agenda: para ver las citas con el nombre del paciente usando (Join)
SELECT c.horario, p.nombrePaciente, c.tratamiento 
FROM citaOdontologico c
INNER JOIN paciente p ON c.pacienteFK = p.idpaciente
WHERE c.horario >= CURDATE();

-- 7. Seguridad: Log de usuarios 
SELECT nombreUsuario, correoElectronico, rol 
FROM usuario 
WHERE rol != 'Paciente';

