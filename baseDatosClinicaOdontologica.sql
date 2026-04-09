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

create table citaOdontologico(
idCity int auto_increment primary key,
odontologo int not null, 
paciente int not null,
horario datetime,
tratamiento int,
foreign key (usuarioFk) references usuario(idUsuario)
);


