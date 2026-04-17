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

select * from paciente;
##consulta especifica

#1
select nombrePaciente as nombre ,Preexistencias as pre_Existencias
from paciente where Alergias="Latex";

#2
select odontologoFK as Odontologo, paciente as Paciente, horario as fecha  from citaodontologico
where month(horario)=4;

#3
select 
    u.nombreUsuario as nombreOdontologo,
    u.telefono as telefono,
    o.especialidad as especialidad
from odontologo o
inner join usuario u on o.usuarioFK = u.idUsuario;

#4
select tarjetaProfesional as Tarjeta_profesional, especialidad
from odontologo 
where idOdontologo=2;

#5
select fecha as fecha_pago, monto as monto_pagado
from pago
where monto>10000 and metodoPago="efectivo";

#6
select fechaApertura as fecha_de_apertura, estado, observaciones
from historiaclinica
where idHistoriaClinica= 50;

#7
alter table auxiliar change idOdontologo idAuxiliar int auto_increment; #no habia llamado bien el campo
select 
    u.nombreUsuario as nombre_auxiliar,
    u.telefono as telefono,
    u.correoElectronico as correo,
    a.tarjetaProfesionalAux AS tarjeta_profesional
from auxiliar A
inner join usuario u on a.usuarioFK = u.idUsuario;

describe paciente;
#HU01 Crear historias clinicas

delimiter // 

create procedure crear_historia_Clinica(

in p_nombrePaciente varchar (100),
in p_documentoPaciente int (10),
in p_direccion_paciente varchar (100),
in p_fecha_nac_paciente date,
in p_preexistencias varchar(500),
in alergias varchar(100),
out p_mensaje varchar(100),
out p_id_paciente int
)

begin
declare fecha_abrir_historia date default now();

insert into paciente(nombrePaciente,documentoPaciente,direccionPaciente,fechaNacPaciente,Preexistencias,Alergias)
values (p_nombrePaciente,p_documentoPaciente,p_direccion_paciente,p_fecha_nac_paciente,p_preexistencias,alergias);

set p_id_paciente = last_insert_id();

insert into historiaclinica(fechaApertura,estado,observaciones,pacienteFK)
values (fecha_abrir_historia,"Activa"," ",p_id_paciente);
end //
delimiter ;

#implementacion del procedimiento
call crear_historia_Clinica(
    'Juan Pérez',
    1098765432,
    'Calle 10 #20-30 Bogotá',
    '1995-06-15',
    'Hipertensión',
    'Penicilina',
    @mensaje,
    @id_paciente
);

-- Ver los resultados de los parámetros OUT
select @mensaje, @id_paciente;


##cositas de la base de datos
use clinicaodontologica;
ALTER DATABASE clinicaodontologica CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci;
ALTER TABLE paciente CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci;