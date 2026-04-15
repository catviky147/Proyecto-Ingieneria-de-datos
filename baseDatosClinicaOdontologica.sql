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
foreign key (usuarioFk) references usuario(idUsuario)
);

create table auxiliar(
idOdontologo int auto_increment primary key,
tarjetaProfesionalAux varchar (50), 
usuarioFK int (10),
foreign key (usuarioFk) references usuario(idUsuario)
);


create table paciente(
idpaciente int auto_increment primary key,
nombrePaciente varchar (50) not null, 
documentoPaciente int (10) not null,
direccionPaciente varchar (100)not null,
fechaNacPaciente date not null,
Preexistencias varchar (500),
Alergias varchar (100)
);

create table historiaClinica(
idHistoriaClinica int primary key auto_increment,
fechaApertura date not null,
estado varchar (70),
observaciones varchar (10000),
pacienteFK int not null,
foreign key (pacienteFk) references paciente(idpaciente)
);


create table citaOdontologico(
idCity int auto_increment primary key,
odontologo int not null, 
paciente int not null,
horario datetime,
tratamiento int,
foreign key (usuarioFk) references usuario(idUsuario)
);

create table pago(
idPago int auto_increment primary key,
fecha date not null,
monto double not null,
metodoPago varchar (100) not null,
estado varchar (50)
);

alter table citaOdontologico
add pagoFK int;

alter table citaOdontologico
add constraint citaPagoFK 
foreign key(pagoFK)
references pago(idPago);

alter table citaOdontologico change odontologo odontologoFK int;

alter table citaOdontologico
add constraint citaOdontologoFK 
foreign key(odontologoFK)
references odontologo(idOdontologo);

describe citaOdontologico;
ALTER TABLE citaOdontologico MODIFY tratamiento VARCHAR(100);


##consultas
##consulta general
select * from pago where metodoPago="Efectivo";

##consulta especifica

#1 paciente
select nombrePaciente as nombre ,Preexistencias as pre_Existencias
from paciente where Alergias="Latex";

#1 cita
select odontologoFK as Odontologo, paciente as Paciente, horario as fecha  from citaodontologico
where month(horario)=4;

#1 odontologo
select 
    u.nombreUsuario as nombreOdontologo,
    u.telefono as telefono,
    o.especialidad as especialidad
from odontologo o
inner join usuario u on o.usuarioFK = u.idUsuario;


##cositas de la base de datos
use clinicaodontologica;
ALTER DATABASE clinicaodontologica CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci;
ALTER TABLE paciente CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci;

