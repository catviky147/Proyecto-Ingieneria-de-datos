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
    'Balatro Balatres',
    1098765432,
    'Carrera 2 #38-40 Bogotá',
    '1995-06-15',
    '',
    '',
    @mensaje,
    @id_paciente
);

-- Ver los resultados de los parámetros OUT
select @mensaje, @id_paciente;

#HU02 buscar paciente e historia clinica

delimiter //

create procedure buscar_historia_clinica(
    in p_busqueda varchar(100)
)
begin
    select 
        p.idpaciente,
        p.nombrePaciente,
        p.documentoPaciente,
        p.fechaNacPaciente,
        p.Preexistencias,
        p.Alergias,
        hc.idHistoriaClinica,
        hc.fechaApertura,
        hc.estado,
        hc.observaciones
    from paciente p
    inner join historiaClinica hc on hc.pacienteFK = p.idpaciente
    where p.nombrePaciente like CONCAT('%', p_busqueda, '%')
    or p.documentoPaciente like CONCAT('%', p_busqueda, '%');
end //

delimiter ;
 
#HU03 poner concentimiento

-- Agregar campos de consentimiento a historiaClinica
alter table historiaClinica
add consentimiento tinyint (1) default 0;

delimiter //

create procedure registrar_consentimiento(
    in p_busqueda varchar(100),
    in p_consentimiento tinyint(1),
    out p_mensaje VARCHAR(100)
)
begin
    declare v_idHistoriaClinica INT;

    -- Buscar la historia clínica por nombre o documento
    select hc.idHistoriaClinica into v_idHistoriaClinica
    from paciente p
    inner join historiaClinica hc on hc.pacienteFK = p.idpaciente
    where p.nombrePaciente like CONCAT('%', p_busqueda, '%')
    or p.documentoPaciente like CONCAT('%', p_busqueda, '%')
    limit 1;

    if v_idHistoriaClinica is null then
        set p_mensaje = 'Error: No se encontró ningún paciente con esa búsqueda.';
    else
        update historiaClinica
        set
            consentimiento = p_consentimiento
        where idHistoriaClinica = v_idHistoriaClinica;

        set p_mensaje = CONCAT('Consentimiento registrado en historia clínica ', v_idHistoriaClinica);

    end if ;
end //

DELIMITER ;

#HU04 actualizar historia clinica

delimiter //

create procedure actualizar_historia_clinica(
  in p_busqueda varchar(100),
  in h_actualizaciones varchar (1000)
)
begin
    -- Verificar que la historia clínica existe
    if not exists (select 1 from historiaClinica where idHistoriaClinica = p_idHistoriaClinica) then
        set p_mensaje = 'Error: Historia clínica no encontrada.';
    else
        update historiaClinica
        set 
            estado        = p_estado,
            observaciones =concat(p_observaciones) 
        where idHistoriaClinica = p_idHistoriaClinica;

        set p_mensaje = CONCAT('Historia clínica ', p_idHistoriaClinica, ' actualizada correctamente.');
    end if;
end //

delimiter ;

#HU05
alter table citaOdontologico
add asistencia tinyint (1) default 0;

delimiter //

create procedure registrar_asistencia(
    in p_busqueda varchar(100),
    in p_asistencia tinyint(1),
    out p_mensaje varchar(100)
)
begin
    declare v_idCita INT;
    declare v_idPaciente INT;

    -- Buscar la cita más próxima del paciente por nombre o documento
    select c.idCity, p.idpaciente into v_idCita, v_idPaciente
    from citaOdontologico c
    inner join paciente p on c.paciente = p.idpaciente
    where p.nombrePaciente like CONCAT('%', p_busqueda, '%')
    or p.documentoPaciente like CONCAT('%', p_busqueda, '%')
    order by c.horario desc
    limit 1;

    if v_idCita is null then
        set p_mensaje = 'Error: No se encontró ninguna cita para ese paciente.';
    else
        update citaOdontologico
        set
            asistencia = p_asistencia
        where idCity = v_idCita;

        set p_mensaje = CONCAT(
            if(p_asistencia = 1, 'Asistencia confirmada', 'Inasistencia registrada'),
            ' para cita ID: ', v_idCita
        );

        -- Mostrar el resumen de la cita
        select
            c.idCity,
            p.nombrePaciente,
            p.documentoPaciente,
            u.nombreUsuario as odontologo,
            c.horario,
            c.tratamiento,
            if(c.asistencia = 1, 'Asistió', 'No asistió') as asistencia,
            c.observacionInasistencia
        from citaOdontologico c
        inner join paciente p  on c.paciente     = p.idpaciente
        inner join odontologo o on c.odontologoFK = o.idOdontologo
        inner join usuario u    on o.usuarioFK    = u.idUsuario
        where c.idCity = v_idCita;
    end if;
end //

delimiter ;

#HU06 filtrar por preexistencias

delimiter //

create procedure filtrar_por_preexistencia(
    in p_preexistencia varchar(100)
)
begin
    select
        p.idpaciente,
        p.nombrePaciente,
        p.documentoPaciente,
        p.fechaNacPaciente,
        p.Preexistencias,
        p.Alergias,
        hc.idHistoriaClinica,
        hc.estado,
        hc.observaciones
    from paciente p
    inner join historiaClinica hc on hc.pacienteFK = p.idpaciente
    where p.Preexistencias like concat('%', p_preexistencia, '%');
end //

delimiter ;


#HU07 actualizar información de paciente

delimiter //

create procedure actualizar_paciente(
    in p_busqueda varchar(100),
    in p_nombrePaciente varchar(50),
    in p_direccionPaciente varchar(100),
    in p_preexistencias varchar(500),
    in p_alergias varchar(100),
    out p_mensaje varchar(100)
)
begin
    declare v_idPaciente int;

    select idpaciente into v_idPaciente
    from paciente
    where nombrePaciente like concat('%', p_busqueda, '%')
    or documentoPaciente like concat('%', p_busqueda, '%')
    limit 1;

    if v_idPaciente is null then
        set p_mensaje = 'Error: No se encontró ningún paciente con esa búsqueda.';
    else
        update paciente
        set
            nombrePaciente    = coalesce(p_nombrePaciente, nombrePaciente),
            direccionPaciente = coalesce(p_direccionPaciente, direccionPaciente),
            Preexistencias    = coalesce(p_preexistencias, Preexistencias),
            Alergias          = coalesce(p_alergias, Alergias)
        where idpaciente = v_idPaciente;

        set p_mensaje = concat('Paciente ', v_idPaciente, ' actualizado correctamente.');
    end if;
end //

delimiter ;


##cositas de la base de datos
use clinicaodontologica;
ALTER DATABASE clinicaodontologica CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci;
ALTER TABLE paciente CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci;