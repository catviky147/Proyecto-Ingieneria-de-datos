-- ============================================================
-- CARGA DE DATOS PARA clinicaodontologica (VERSIÓN PACIENTE INDEPENDIENTE)
-- 100 pacientes, 4 odontólogos, 10 auxiliares, 200+ citas
-- ============================================================

USE clinicaodontologica;

-- ============================================================
-- 1. USUARIOS (Solo personal: 4 odontólogos + 10 auxiliares + 1 admin)
-- ============================================================

-- Odontólogos (4)
INSERT INTO usuario (nombreUsuario, telefono, correoElectronico, tipoDocumento, userName, contrasena, rol) VALUES
('Dra. Laura Cecilia Mendoza', '3112000001', 'laura.mendoza@clinicadental.com', 'CC', 'dra.mendoza', '$2y$10$ABCDEFGHIJKLMNOPQRSTUVWXYZabcde12345', 'Odontologo'),
('Dr. Carlos Alberto Vélez', '3112000002', 'carlos.velez@clinicadental.com', 'CC', 'dr.velez', '$2y$10$ABCDEFGHIJKLMNOPQRSTUVWXYZabcde12345', 'Odontologo'),
('Dra. Marcela Restrepo', '3112000003', 'marcela.restrepo@clinicadental.com', 'CC', 'dra.restrepo', '$2y$10$ABCDEFGHIJKLMNOPQRSTUVWXYZabcde12345', 'Odontologo'),
('Dr. Juan Pablo Henao', '3112000004', 'juan.henao@clinicadental.com', 'CC', 'dr.henao', '$2y$10$ABCDEFGHIJKLMNOPQRSTUVWXYZabcde12345', 'Odontologo');

-- Auxiliares (10)
INSERT INTO usuario (nombreUsuario, telefono, correoElectronico, tipoDocumento, userName, contrasena, rol) VALUES
('Aux. Sandra Gómez', '3113000001', 'sandra.gomez@clinica.com', 'CC', 'aux.sandra', '$2y$10$ABCDEFGHIJKLMNOPQRSTUVWXYZabcde12345', 'Auxiliar'),
('Aux. Luis Torres', '3113000002', 'luis.torres@clinica.com', 'CC', 'aux.luis', '$2y$10$ABCDEFGHIJKLMNOPQRSTUVWXYZabcde12345', 'Auxiliar'),
('Aux. Marcela Ruiz', '3113000003', 'marcela.ruiz@clinica.com', 'CC', 'aux.marcela', '$2y$10$ABCDEFGHIJKLMNOPQRSTUVWXYZabcde12345', 'Auxiliar'),
('Aux. Jorge Ramírez', '3113000004', 'jorge.ramirez@clinica.com', 'CC', 'aux.jorge', '$2y$10$ABCDEFGHIJKLMNOPQRSTUVWXYZabcde12345', 'Auxiliar'),
('Aux. Diana López', '3113000005', 'diana.lopez@clinica.com', 'CC', 'aux.diana', '$2y$10$ABCDEFGHIJKLMNOPQRSTUVWXYZabcde12345', 'Auxiliar'),
('Aux. Carlos Suárez', '3113000006', 'carlos.suarez@clinica.com', 'CC', 'aux.carlos', '$2y$10$ABCDEFGHIJKLMNOPQRSTUVWXYZabcde12345', 'Auxiliar'),
('Aux. Natalia Ríos', '3113000007', 'natalia.rios@clinica.com', 'CC', 'aux.natalia', '$2y$10$ABCDEFGHIJKLMNOPQRSTUVWXYZabcde12345', 'Auxiliar'),
('Aux. Andrés Betancur', '3113000008', 'andres.betancur@clinica.com', 'CC', 'aux.andres', '$2y$10$ABCDEFGHIJKLMNOPQRSTUVWXYZabcde12345', 'Auxiliar'),
('Aux. Paula Montoya', '3113000009', 'paula.montoya@clinica.com', 'CC', 'aux.paula', '$2y$10$ABCDEFGHIJKLMNOPQRSTUVWXYZabcde12345', 'Auxiliar'),
('Aux. Sebastián Arias', '3113000010', 'sebastian.arias@clinica.com', 'CC', 'aux.sebastian', '$2y$10$ABCDEFGHIJKLMNOPQRSTUVWXYZabcde12345', 'Auxiliar');

-- Administrador
INSERT INTO usuario (nombreUsuario, telefono, correoElectronico, tipoDocumento, userName, contrasena, rol) VALUES
('Admin Sistema', '3119999999', 'admin@clinicaodontologica.com', 'CC', 'admin', '$2y$10$ABCDEFGHIJKLMNOPQRSTUVWXYZabcde12345', 'Admin');

-- ============================================================
-- 2. ODONTÓLOGOS (4)
-- ============================================================
INSERT INTO odontologo (tarjetaProfesional, especialidad, usuarioFK) VALUES
('TP100001', 'Ortodoncia', (SELECT idUsuario FROM usuario WHERE userName = 'dra.mendoza')),
('TP100002', 'Endodoncia', (SELECT idUsuario FROM usuario WHERE userName = 'dr.velez')),
('TP100003', 'Periodoncia', (SELECT idUsuario FROM usuario WHERE userName = 'dra.restrepo')),
('TP100004', 'Cirugía Oral', (SELECT idUsuario FROM usuario WHERE userName = 'dr.henao'));

-- ============================================================
-- 3. AUXILIARES (10)
-- ============================================================
INSERT INTO auxiliar (tarjetaProfesionalAux, usuarioFK) VALUES
('AUX1001', (SELECT idUsuario FROM usuario WHERE userName = 'aux.sandra')),
('AUX1002', (SELECT idUsuario FROM usuario WHERE userName = 'aux.luis')),
('AUX1003', (SELECT idUsuario FROM usuario WHERE userName = 'aux.marcela')),
('AUX1004', (SELECT idUsuario FROM usuario WHERE userName = 'aux.jorge')),
('AUX1005', (SELECT idUsuario FROM usuario WHERE userName = 'aux.diana')),
('AUX1006', (SELECT idUsuario FROM usuario WHERE userName = 'aux.carlos')),
('AUX1007', (SELECT idUsuario FROM usuario WHERE userName = 'aux.natalia')),
('AUX1008', (SELECT idUsuario FROM usuario WHERE userName = 'aux.andres')),
('AUX1009', (SELECT idUsuario FROM usuario WHERE userName = 'aux.paula')),
('AUX1010', (SELECT idUsuario FROM usuario WHERE userName = 'aux.sebastian'));

-- ============================================================
-- 4. PACIENTES (100) - INDEPENDIENTES, SIN FK A USUARIO
-- ============================================================

-- Pacientes 1-10
INSERT INTO paciente (nombrePaciente, tipoDocumento, documentoPaciente, telefono, correoElectronico, direccionPaciente, fechaNacPaciente, Preexistencias, Alergias) VALUES
('Ana María Rodríguez', 'CC', '1234567890', '3111231001', 'ana.rodriguez1@email.com', 'Calle 45 # 23-10, Bogotá', '1990-03-15', 'Hipertensión', 'Penicilina'),
('Luis Carlos Martínez', 'CC', '2345678901', '3111231002', 'luis.martinez2@email.com', 'Carrera 12 # 8-30, Medellín', '1985-07-22', 'Diabetes tipo 2', NULL),
('María Fernanda López', 'CC', '3456789012', '3111231003', 'maria.lopez3@email.com', 'Avenida 5 # 12-45, Cali', '1995-11-05', NULL, 'Polvo'),
('José Alberto Gómez', 'CC', '4567890123', '3111231004', 'jose.gomez4@email.com', 'Calle 78 # 15-60, Barranquilla', '1980-01-30', 'Hipertensión, Asma', 'Ibuprofeno'),
('Carmen Rosa Díaz', 'CC', '5678901234', '3111231005', 'carmen.diaz5@email.com', 'Diagonal 10 # 5-20, Bucaramanga', '1992-09-17', NULL, NULL),
('Diego Fernando Sánchez', 'CC', '6789012345', '3111231006', 'diego.sanchez6@email.com', 'Transversal 8 # 12-78, Cartagena', '1988-04-12', 'Artritis reumatoide', 'Latex'),
('Laura Valentina Pérez', 'CC', '7890123456', '3111231007', 'laura.perez7@email.com', 'Calle 25 # 10-33, Pereira', '2000-12-03', NULL, NULL),
('Carlos Andrés Ramírez', 'CC', '8901234567', '3111231008', 'carlos.ramirez8@email.com', 'Carrera 20 # 5-15, Manizales', '1975-06-19', 'Hipertiroidismo', 'Codeína'),
('Sofía Alejandra Torres', 'CC', '9012345678', '3111231009', 'sofia.torres9@email.com', 'Avenida 7 # 23-90, Cúcuta', '1998-02-28', NULL, 'Mariscos'),
('Javier Eduardo Castro', 'CC', '0123456789', '3111231010', 'javier.castro10@email.com', 'Calle 52 # 31-15, Ibagué', '1983-08-14', 'Hipertensión', NULL);

-- Pacientes 11-20
INSERT INTO paciente (nombrePaciente, tipoDocumento, documentoPaciente, telefono, correoElectronico, direccionPaciente, fechaNacPaciente, Preexistencias, Alergias) VALUES
('Paola Andrea Rojas', 'CC', '1112223334', '3111231011', 'paola.rojas11@email.com', 'Carrera 15 # 10-20, Santa Marta', '1991-05-10', NULL, 'Polen'),
('Ricardo José Herrera', 'CC', '2223334445', '3111231012', 'ricardo.herrera12@email.com', 'Calle 80 # 20-10, Villavicencio', '1987-10-25', 'Diabetes', NULL),
('Diana Carolina Moreno', 'CC', '3334445556', '3111231013', 'diana.moreno13@email.com', 'Avenida 3 # 45-60, Neiva', '1994-03-08', 'Anemia', 'Ácido acetilsalicílico'),
('Andrés Felipe Jiménez', 'CC', '4445556667', '3111231014', 'andres.jimenez14@email.com', 'Calle 12 # 4-15, Pasto', '1979-07-19', 'Hipertensión, Colesterol alto', NULL),
('Natalia Patricia Vega', 'CC', '5556667778', '3111231015', 'natalia.vega15@email.com', 'Carrera 8 # 56-12, Armenia', '1996-11-30', NULL, 'Ninguna'),
('Óscar Leonardo Fuentes', 'CC', '6667778889', '3111231016', 'oscar.fuentes16@email.com', 'Transversal 5 # 8-40, Sincelejo', '1982-09-05', 'Asma', 'Morfina'),
('Valentina María Ortiz', 'CC', '7778889990', '3111231017', 'valentina.ortiz17@email.com', 'Calle 34 # 12-78, Popayán', '2001-01-15', NULL, 'Maní'),
('Mauricio Alejandro Silva', 'CC', '8889990001', '3111231018', 'mauricio.silva18@email.com', 'Carrera 18 # 25-30, Montería', '1973-04-22', 'EPOC', NULL),
('Daniela Alexandra Méndez', 'CC', '9990001112', '3111231019', 'daniela.mendez19@email.com', 'Avenida 9 # 67-90, Quibdó', '1997-08-18', NULL, 'Lácteos'),
('Sebastián Camilo Rincón', 'CC', '0001112223', '3111231020', 'sebastian.rincon20@email.com', 'Calle 45 # 9-20, Riohacha', '1984-12-03', 'Hipertensión', NULL);

-- Pacientes 21-30
INSERT INTO paciente (nombrePaciente, tipoDocumento, documentoPaciente, telefono, correoElectronico, direccionPaciente, fechaNacPaciente, Preexistencias, Alergias) VALUES
('Johanna Milena Vargas', 'CC', '1113335557', '3111231021', 'johanna.vargas21@email.com', 'Carrera 22 # 15-40, Valledupar', '1993-02-27', NULL, 'Huevo'),
('Cristian David Paredes', 'CC', '2224446668', '3111231022', 'cristian.paredes22@email.com', 'Calle 7 # 82-15, Tunja', '1986-06-12', 'Diabetes gestacional', NULL),
('Andrea Lucía Cárdenas', 'CC', '3335557779', '3111231023', 'andrea.cardenas23@email.com', 'Avenida 15 # 23-90, Florencia', '1999-09-20', NULL, 'Penicilina'),
('Felipe Augusto Arias', 'CC', '4446668880', '3111231024', 'felipe.arias24@email.com', 'Calle 90 # 45-10, Arauca', '1978-03-05', 'Hipertensión', 'Sulfamidas'),
('Tatiana Margarita Guzmán', 'CC', '5557779991', '3111231025', 'tatiana.guzman25@email.com', 'Carrera 5 # 12-30, Yopal', '1990-07-14', NULL, NULL),
('Edwin Fabián Parra', 'CC', '6668880002', '3111231026', 'edwin.parra26@email.com', 'Transversal 12 # 6-45, Mocoa', '1981-11-18', 'Artritis', 'Ibuprofeno'),
('Juliana Isabel Salazar', 'CC', '7779991113', '3111231027', 'juliana.salazar27@email.com', 'Calle 23 # 15-60, Leticia', '2002-04-09', NULL, 'Polvo'),
('Héctor Manuel Duque', 'CC', '8880002224', '3111231028', 'hector.duque28@email.com', 'Carrera 7 # 89-12, Mitú', '1970-08-30', 'Insuficiencia renal', NULL),
('Mónica Patricia Escobar', 'CC', '9991113335', '3111231029', 'monica.escobar29@email.com', 'Avenida 20 # 45-78, Puerto Carreño', '1992-05-21', NULL, 'Látex'),
('Sergio Andrés Londoño', 'CC', '0002224446', '3111231030', 'sergio.londono30@email.com', 'Calle 56 # 12-90, San José del Guaviare', '1985-10-07', 'Hipertensión', NULL);

-- Pacientes 31-40
INSERT INTO paciente (nombrePaciente, tipoDocumento, documentoPaciente, telefono, correoElectronico, direccionPaciente, fechaNacPaciente, Preexistencias, Alergias) VALUES
('Angélica María Quintero', 'CC', '1114447778', '3111231031', 'angelica.quintero31@email.com', 'Carrera 10 # 45-20, Bogotá', '1995-12-15', 'Hipotiroidismo', 'Ninguna'),
('Jorge Iván Peláez', 'CC', '2225558889', '3111231032', 'jorge.pelaez32@email.com', 'Calle 32 # 8-40, Medellín', '1989-03-28', NULL, 'Penicilina'),
('Linda Carolina Ospina', 'CC', '3336669990', '3111231033', 'linda.ospina33@email.com', 'Avenida 12 # 67-30, Cali', '1997-06-10', 'Asma', 'Polen'),
('Raúl Eduardo Narváez', 'CC', '4447770001', '3111231034', 'raul.narvaez34@email.com', 'Diagonal 7 # 23-15, Barranquilla', '1976-09-18', 'Diabetes tipo 2', NULL),
('Gloria Isabel Martínez', 'CC', '5558881112', '3111231035', 'gloria.martinez35@email.com', 'Carrera 3 # 10-50, Bucaramanga', '1980-01-22', 'Hipertensión', 'Ibuprofeno'),
('Leonardo Fabio Morales', 'CC', '6669992223', '3111231036', 'leonardo.morales36@email.com', 'Transversal 9 # 4-35, Cartagena', '1993-04-05', NULL, 'Mariscos'),
('Claudia Patricia Ríos', 'CC', '7770003334', '3111231037', 'claudia.rios37@email.com', 'Calle 60 # 12-80, Pereira', '1987-07-30', 'Artritis reumatoide', NULL),
('Jesús David Álvarez', 'CC', '8881114445', '3111231038', 'jesus.alvarez38@email.com', 'Carrera 25 # 9-60, Manizales', '1998-10-12', NULL, 'Latex'),
('Margarita Rosa Betancur', 'CC', '9992225556', '3111231039', 'margarita.betancur39@email.com', 'Avenida 4 # 56-20, Cúcuta', '1972-02-08', 'Hipertensión', 'Ninguna'),
('Esteban José Cardona', 'CC', '0003336667', '3111231040', 'esteban.cardona40@email.com', 'Calle 98 # 34-10, Ibagué', '1984-08-25', 'EPOC', 'Sulfamidas');

-- Pacientes 41-50
INSERT INTO paciente (nombrePaciente, tipoDocumento, documentoPaciente, telefono, correoElectronico, direccionPaciente, fechaNacPaciente, Preexistencias, Alergias) VALUES
('Marcela Alexandra Agudelo', 'CC', '1115558881', '3111231041', 'marcela.agudelo41@email.com', 'Carrera 17 # 12-30, Santa Marta', '1994-11-19', NULL, 'Ácido acetilsalicílico'),
('Alberto José Valencia', 'CC', '2226669992', '3111231042', 'alberto.valencia42@email.com', 'Calle 45 # 78-15, Villavicencio', '1983-05-14', 'Diabetes', NULL),
('Sandra Milena Echeverry', 'CC', '3337770003', '3111231043', 'sandra.echeverry43@email.com', 'Avenida 8 # 15-40, Neiva', '1991-09-03', NULL, 'Polvo'),
('Camilo Ernesto Bernal', 'CC', '4448881114', '3111231044', 'camilo.bernal44@email.com', 'Diagonal 3 # 67-20, Pasto', '1979-01-17', 'Hipertensión', 'Penicilina'),
('Luz Elena Franco', 'CC', '5559992225', '3111231045', 'luz.franco45@email.com', 'Calle 28 # 5-45, Armenia', '1996-04-29', NULL, 'Maní'),
('Hugo Alejandro Castaño', 'CC', '6660003336', '3111231046', 'hugo.castano46@email.com', 'Carrera 12 # 34-50, Sincelejo', '1982-10-11', 'Asma', NULL),
('Yenny Paola Montoya', 'CC', '7771114447', '3111231047', 'yenny.montoya47@email.com', 'Transversal 15 # 8-25, Popayán', '1999-07-07', NULL, 'Lácteos'),
('Fernando José Rueda', 'CC', '8882225558', '3111231048', 'fernando.rueda48@email.com', 'Calle 42 # 23-60, Montería', '1975-12-01', 'Hipertensión', 'Ibuprofeno'),
('Adriana Lucía Zuluaga', 'CC', '9993336669', '3111231049', 'adriana.zuluaga49@email.com', 'Avenida 19 # 56-30, Quibdó', '1990-02-18', NULL, 'Ninguna'),
('Manuel Alejandro Arango', 'CC', '0004447770', '3111231050', 'manuel.arango50@email.com', 'Carrera 28 # 10-15, Riohacha', '1986-06-23', 'Artritis', NULL);

-- Pacientes 51-60
INSERT INTO paciente (nombrePaciente, tipoDocumento, documentoPaciente, telefono, correoElectronico, direccionPaciente, fechaNacPaciente, Preexistencias, Alergias) VALUES
('Pilar Andrea Restrepo', 'CC', '1116668882', '3111231051', 'pilar.restrepo51@email.com', 'Calle 14 # 45-20, Valledupar', '1992-08-14', NULL, 'Huevo'),
('Giovanny Alonso Zapata', 'CC', '2227779993', '3111231052', 'giovanny.zapata52@email.com', 'Carrera 6 # 78-15, Tunja', '1985-03-27', 'Hipertensión', NULL),
('Maribel del Carmen Villa', 'CC', '3338880004', '3111231053', 'maribel.villa53@email.com', 'Avenida 11 # 34-60, Florencia', '1997-11-09', 'Diabetes gestacional', 'Penicilina'),
('Óscar Iván Cruz', 'CC', '4449991115', '3111231054', 'oscar.cruz54@email.com', 'Diagonal 21 # 5-40, Arauca', '1980-04-30', NULL, 'Polen'),
('Ana Sofía Bedoya', 'CC', '5550002226', '3111231055', 'ana.bedoya55@email.com', 'Calle 67 # 12-20, Yopal', '1994-09-16', 'Hipotiroidismo', NULL),
('Juan Sebastián Marín', 'CC', '6661113337', '3111231056', 'juan.marin56@email.com', 'Carrera 9 # 89-10, Mocoa', '1988-01-24', NULL, 'Sulfamidas'),
('Diana María Velásquez', 'CC', '7772224448', '3111231057', 'diana.velasquez57@email.com', 'Transversal 4 # 23-55, Leticia', '2000-06-08', 'Asma', 'Ibuprofeno'),
('Nelson Enrique Ruiz', 'CC', '8883335559', '3111231058', 'nelson.ruiz58@email.com', 'Calle 39 # 16-40, Mitú', '1977-10-19', 'Hipertensión', NULL),
('Eliana Patricia Sepúlveda', 'CC', '9994446660', '3111231059', 'eliana.sepulveda59@email.com', 'Avenida 14 # 45-75, Puerto Carreño', '1993-03-05', NULL, 'Látex'),
('Mauricio Andrés Giraldo', 'CC', '0005557771', '3111231060', 'mauricio.giraldo60@email.com', 'Carrera 23 # 8-30, San José del Guaviare', '1981-07-28', 'Artritis reumatoide', 'Ninguna');

-- Pacientes 61-70
INSERT INTO paciente (nombrePaciente, tipoDocumento, documentoPaciente, telefono, correoElectronico, direccionPaciente, fechaNacPaciente, Preexistencias, Alergias) VALUES
('Liliana María Henao', 'CC', '1117779994', '3111231061', 'liliana.henao61@email.com', 'Calle 55 # 12-45, Bogotá', '1995-10-21', NULL, 'Penicilina'),
('Rafael Ángel Osorio', 'CC', '2228880005', '3111231062', 'rafael.osorio62@email.com', 'Carrera 14 # 67-20, Medellín', '1987-02-13', 'Diabetes tipo 2', NULL),
('Yuli Andrea Arboleda', 'CC', '3339991116', '3111231063', 'yuli.arboleda63@email.com', 'Avenida 17 # 23-55, Cali', '1998-07-04', NULL, 'Mariscos'),
('César Augusto Peña', 'CC', '4440002227', '3111231064', 'cesar.pena64@email.com', 'Diagonal 8 # 45-80, Barranquilla', '1974-12-11', 'Hipertensión', 'Ibuprofeno'),
('Martha Cecilia Rincón', 'CC', '5551113338', '3111231065', 'martha.rincon65@email.com', 'Calle 85 # 34-10, Bucaramanga', '1990-04-26', NULL, 'Polvo'),
('Jhon Fredy Lopera', 'CC', '6662224449', '3111231066', 'jhon.lopera66@email.com', 'Carrera 19 # 12-70, Cartagena', '1983-09-19', 'Asma', NULL),
('Angie Carolina Murillo', 'CC', '7773335550', '3111231067', 'angie.murillo67@email.com', 'Transversal 11 # 8-15, Pereira', '1996-01-15', NULL, 'Lácteos'),
('Wilson Alberto Gil', 'CC', '8884446661', '3111231068', 'wilson.gil68@email.com', 'Calle 48 # 56-90, Manizales', '1979-06-30', 'Hipertensión', 'Codeína'),
('Katherine Julieth Cano', 'CC', '9995557772', '3111231069', 'katherine.cano69@email.com', 'Avenida 25 # 45-20, Cúcuta', '1992-11-08', NULL, 'Ácido acetilsalicílico'),
('Alexander Carmona', 'CC', '0006668883', '3111231070', 'alexander.carmona70@email.com', 'Carrera 31 # 10-55, Ibagué', '1985-03-17', 'Epilepsia', NULL);

-- Pacientes 71-80
INSERT INTO paciente (nombrePaciente, tipoDocumento, documentoPaciente, telefono, correoElectronico, direccionPaciente, fechaNacPaciente, Preexistencias, Alergias) VALUES
('Viviana Andrea León', 'CC', '1118880006', '3111231071', 'viviana.leon71@email.com', 'Calle 73 # 15-60, Santa Marta', '1994-08-23', NULL, 'Sulfamidas'),
('Cristhian Felipe Beltrán', 'CC', '2229991117', '3111231072', 'cristhian.beltran72@email.com', 'Carrera 27 # 8-35, Villavicencio', '1988-12-02', 'Hipertensión', NULL),
('Paulina María Sossa', 'CC', '3330002228', '3111231073', 'paulina.sossa73@email.com', 'Avenida 16 # 34-15, Neiva', '1997-05-11', 'Anemia', 'Penicilina'),
('Harold Andrés Chacón', 'CC', '4441113339', '3111231074', 'harold.chacon74@email.com', 'Diagonal 13 # 45-70, Pasto', '1976-10-24', 'Diabetes', 'Ibuprofeno'),
('Leidy Johana Calderón', 'CC', '5552224440', '3111231075', 'leidy.calderon75@email.com', 'Calle 61 # 23-80, Armenia', '1991-02-28', NULL, 'Polen'),
('David Esteban Rincón', 'CC', '6663335551', '3111231076', 'david.rincon76@email.com', 'Carrera 32 # 10-45, Sincelejo', '1984-07-15', 'Hipertensión', NULL),
('Stefanny Carolina Mejía', 'CC', '7774446662', '3111231077', 'stefanny.mejia77@email.com', 'Transversal 18 # 56-30, Popayán', '1999-09-19', NULL, 'Látex'),
('Jonathan Andrey Palacio', 'CC', '8885557773', '3111231078', 'jonathan.palacio78@email.com', 'Calle 19 # 12-90, Montería', '1973-04-08', 'EPOC', 'Ninguna'),
('Gina Marcela Loaiza', 'CC', '9996668884', '3111231079', 'gina.loaiza79@email.com', 'Avenida 2 # 67-25, Quibdó', '1993-12-13', NULL, 'Maní'),
('Eduardo José Zambrano', 'CC', '0007779995', '3111231080', 'eduardo.zambrano80@email.com', 'Carrera 41 # 8-15, Riohacha', '1986-06-27', 'Artritis', NULL);

-- Pacientes 81-90
INSERT INTO paciente (nombrePaciente, tipoDocumento, documentoPaciente, telefono, correoElectronico, direccionPaciente, fechaNacPaciente, Preexistencias, Alergias) VALUES
('Lorena Isabel Patiño', 'CC', '1119991111', '3111231081', 'lorena.patino81@email.com', 'Calle 96 # 45-30, Valledupar', '1995-03-06', NULL, 'Huevo'),
('Julián Andrés Romero', 'CC', '2220002222', '3111231082', 'julian.romero82@email.com', 'Carrera 13 # 78-40, Tunja', '1989-08-17', 'Hipertensión', NULL),
('Carolina del Pilar Urrea', 'CC', '3331113333', '3111231083', 'carolina.urrea83@email.com', 'Avenida 29 # 34-55, Florencia', '1996-11-02', 'Hipotiroidismo', 'Penicilina'),
('Iván Darío Villamizar', 'CC', '4442224444', '3111231084', 'ivan.villamizar84@email.com', 'Diagonal 6 # 5-20, Arauca', '1981-02-09', NULL, 'Polvo'),
('Paula Andrea Buitrago', 'CC', '5553335555', '3111231085', 'paula.buitrago85@email.com', 'Calle 75 # 12-65, Yopal', '1992-06-24', 'Asma', NULL),
('Santiago Pérez Gallego', 'CC', '6664446666', '3111231086', 'santiago.perez86@email.com', 'Carrera 35 # 89-10, Mocoa', '1987-10-01', 'Diabetes', 'Ibuprofeno'),
('Jessica Paola Tabares', 'CC', '7775557777', '3111231087', 'jessica.tabares87@email.com', 'Transversal 2 # 23-45, Leticia', '2000-04-18', NULL, 'Mariscos'),
('Luis Miguel Arcila', 'CC', '8886668888', '3111231088', 'luis.arcila88@email.com', 'Calle 50 # 16-70, Mitú', '1978-12-29', 'Hipertensión', NULL),
('Yuliana Marcela Saldarriaga', 'CC', '9997779999', '3111231089', 'yuliana.saldarriaga89@email.com', 'Avenida 33 # 45-85, Puerto Carreño', '1994-07-16', NULL, 'Lácteos'),
('Henry Hernán Grisales', 'CC', '0008880000', '3111231090', 'henry.grisales90@email.com', 'Carrera 45 # 8-25, San José del Guaviare', '1983-01-31', 'Artritis reumatoide', 'Sulfamidas');

-- Pacientes 91-100
INSERT INTO paciente (nombrePaciente, tipoDocumento, documentoPaciente, telefono, correoElectronico, direccionPaciente, fechaNacPaciente, Preexistencias, Alergias) VALUES
('Danny Alexander Orozco', 'CC', '1110001111', '3111231091', 'danny.orozco91@email.com', 'Calle 33 # 12-40, Bogotá', '1986-05-21', NULL, 'Codeína'),
('Luisa Fernanda Grajales', 'CC', '2221112222', '3111231092', 'luisa.grajales92@email.com', 'Carrera 54 # 67-15, Medellín', '1997-09-13', 'Hipertensión', NULL),
('Edwin Armando Díaz', 'CC', '3332223333', '3111231093', 'edwin.diaz93@email.com', 'Avenida 38 # 23-70, Cali', '1975-02-27', 'Diabetes tipo 2', 'Penicilina'),
('Sindy Lorena Aguirre', 'CC', '4443334444', '3111231094', 'sindy.aguirre94@email.com', 'Diagonal 16 # 45-30, Barranquilla', '1990-07-10', NULL, 'Polen'),
('Fabián Andrés Duarte', 'CC', '5554445555', '3111231095', 'fabian.duarte95@email.com', 'Calle 89 # 34-80, Bucaramanga', '1983-10-23', 'Asma', NULL),
('Shirley Dayana Roldán', 'CC', '6665556666', '3111231096', 'shirley.roldan96@email.com', 'Carrera 47 # 12-55, Cartagena', '1998-03-08', NULL, 'Ibuprofeno'),
('Jesús Alberto Quiroz', 'CC', '7776667777', '3111231097', 'jesus.quiroz97@email.com', 'Transversal 25 # 8-10, Pereira', '1980-06-25', 'Hipertensión', 'Látex'),
('Mayerly Andrea Castrillón', 'CC', '8887778888', '3111231098', 'mayerly.castrillon98@email.com', 'Calle 102 # 56-45, Manizales', '1993-11-19', NULL, 'Ninguna'),
('Yeison Fernando Londoño', 'CC', '9998889999', '3111231099', 'yeison.londono99@email.com', 'Avenida 41 # 10-60, Cúcuta', '1985-04-05', 'Artritis', NULL),
('Daniela Álvarez Ruiz', 'CC', '0009990000', '3111231100', 'daniela.alvarez100@email.com', 'Carrera 59 # 23-20, Ibagué', '1979-08-30', 'Hipertiroidismo', 'Ácido acetilsalicílico');

-- ============================================================
-- 5. HISTORIAS CLÍNICAS (una por cada paciente)
-- ============================================================
INSERT INTO historiaClinica (fechaApertura, estado, observaciones, pacienteFK)
SELECT 
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 730) DAY),
    CASE FLOOR(1 + RAND() * 3)
        WHEN 1 THEN 'Activa'
        WHEN 2 THEN 'En tratamiento'
        ELSE 'Completa'
    END,
    CONCAT('Historia clínica del paciente. Apertura: ', DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 730) DAY)),
    idpaciente
FROM paciente;

-- ============================================================
-- 6. ANAMNESIS (una por cada historia clínica)
-- ============================================================
INSERT INTO anamnesis (historiaClinicaFK, motivoConsulta, enfermedadActual, antecedentesPersonales, antecedentesFamiliares, revisionSistemas, fechaRegistro)
SELECT 
    hc.idHistoriaClinica,
    CASE FLOOR(1 + RAND() * 6)
        WHEN 1 THEN 'Dolor dental'
        WHEN 2 THEN 'Revisión de rutina'
        WHEN 3 THEN 'Sangrado de encías'
        WHEN 4 THEN 'Dientes sensibles'
        WHEN 5 THEN 'Consulta por ortodoncia'
        ELSE 'Extracción dental'
    END,
    CONCAT('Paciente refiere ', 
           CASE FLOOR(1 + RAND() * 4)
               WHEN 1 THEN 'dolor intermitente en región maxilar izquierda.'
               WHEN 2 THEN 'sensibilidad al frío y calor.'
               WHEN 3 THEN 'inflamación en encías.'
               ELSE 'molestia general en piezas dentales.'
           END),
    CONCAT('Antecedentes: ', IFNULL(p.Preexistencias, 'Ninguno')),
    CASE WHEN RAND() > 0.5 THEN 'Madre con hipertensión, padre con diabetes.' ELSE 'Sin antecedentes familiares relevantes.' END,
    'Por sistemas sin alteraciones significativas.',
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 180) DAY)
FROM historiaClinica hc
JOIN paciente p ON hc.pacienteFK = p.idpaciente;

-- ============================================================
-- 7. SIGNOS VITALES (uno por cada historia clínica)
-- ============================================================
INSERT INTO signos_vitales (historiaClinicaFK, presionArterial, frecuenciaCardiaca, frecuenciaRespiratoria, temperatura, peso, talla, imc, glucemia, fechaRegistro)
SELECT 
    hc.idHistoriaClinica,
    CONCAT(100 + FLOOR(RAND() * 40), '/', 60 + FLOOR(RAND() * 20)),
    60 + FLOOR(RAND() * 40),
    12 + FLOOR(RAND() * 12),
    ROUND(36 + RAND(), 1),
    ROUND(50 + RAND() * 40, 2),
    ROUND(1.50 + RAND() * 0.4, 2),
    0,
    ROUND(70 + RAND() * 60, 1),
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 90) DAY)
FROM historiaClinica hc;

UPDATE signos_vitales SET imc = ROUND(peso / (talla * talla), 2);

-- ============================================================
-- 8. HÁBITOS DE HIGIENE (uno por cada historia clínica)
-- ============================================================
INSERT INTO habitos_higiene (historiaClinicaFK, frecuenciaCepillado, usaHilosDental, usaEnjuague, visitaDentistaPeriodica, consumoTabaco, consumoAlcohol, observaciones, fechaRegistro)
SELECT 
    hc.idHistoriaClinica,
    CASE FLOOR(1 + RAND() * 4)
        WHEN 1 THEN 'Tres veces al día'
        WHEN 2 THEN 'Dos veces al día'
        WHEN 3 THEN 'Una vez al día'
        ELSE 'Ocasional'
    END,
    CASE WHEN RAND() > 0.5 THEN 'Si' ELSE 'No' END,
    CASE WHEN RAND() > 0.6 THEN 'Si' ELSE 'No' END,
    CASE WHEN RAND() > 0.4 THEN 'Si' ELSE 'No' END,
    CASE WHEN RAND() > 0.85 THEN 'Si' ELSE 'No' END,
    CASE WHEN RAND() > 0.75 THEN 'Si' ELSE 'No' END,
    'Paciente reporta hábitos de higiene aceptables.',
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 60) DAY)
FROM historiaClinica hc;

-- ============================================================
-- 9. MEDICAMENTOS (25% de los pacientes)
-- ============================================================
INSERT INTO medicamentos (historiaClinicaFK, nombreMedicamento, principioActivo, dosis, frecuencia, viaAdministracion, motivoUso, fechaInicio, fechaFin)
SELECT 
    hc.idHistoriaClinica,
    CASE FLOOR(1 + RAND() * 5)
        WHEN 1 THEN 'Losartán'
        WHEN 2 THEN 'Metformina'
        WHEN 3 THEN 'Ibuprofeno'
        WHEN 4 THEN 'Amoxicilina'
        ELSE 'Acetaminofén'
    END,
    CASE FLOOR(1 + RAND() * 5)
        WHEN 1 THEN 'Losartán potásico'
        WHEN 2 THEN 'Metformina HCl'
        WHEN 3 THEN 'Ibuprofeno'
        WHEN 4 THEN 'Amoxicilina'
        ELSE 'Paracetamol'
    END,
    CASE FLOOR(1 + RAND() * 4)
        WHEN 1 THEN '50 mg'
        WHEN 2 THEN '100 mg'
        WHEN 3 THEN '500 mg'
        ELSE '1 comprimido'
    END,
    CASE FLOOR(1 + RAND() * 4)
        WHEN 1 THEN 'Cada 8 horas'
        WHEN 2 THEN 'Cada 12 horas'
        WHEN 3 THEN 'Una vez al día'
        ELSE 'Según necesidad'
    END,
    'Oral',
    CASE FLOOR(1 + RAND() * 4)
        WHEN 1 THEN 'Control de hipertensión'
        WHEN 2 THEN 'Control de diabetes'
        WHEN 3 THEN 'Alivio del dolor'
        ELSE 'Tratamiento antibiótico'
    END,
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 365) DAY),
    CASE WHEN RAND() > 0.7 THEN DATE_ADD(CURDATE(), INTERVAL FLOOR(RAND() * 90) DAY) ELSE NULL END
FROM historiaClinica hc
WHERE RAND() < 0.25;

-- ============================================================
-- 10. PAGOS (80% de los pacientes tienen al menos 1 pago)
-- ============================================================
INSERT INTO pago (fecha, monto, metodoPago, estado, pacienteFK)
SELECT 
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 365) DAY),
    ROUND(50000 + RAND() * 500000, 2),
    CASE FLOOR(1 + RAND() * 4)
        WHEN 1 THEN 'Efectivo'
        WHEN 2 THEN 'Tarjeta Débito'
        WHEN 3 THEN 'Tarjeta Crédito'
        ELSE 'Transferencia'
    END,
    CASE WHEN RAND() > 0.2 THEN 'Pagado' ELSE 'Pendiente' END,
    idpaciente
FROM paciente
WHERE RAND() < 0.8;

-- Pagos adicionales (20% de los pacientes)
INSERT INTO pago (fecha, monto, metodoPago, estado, pacienteFK)
SELECT 
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 180) DAY),
    ROUND(30000 + RAND() * 200000, 2),
    CASE FLOOR(1 + RAND() * 4)
        WHEN 1 THEN 'Efectivo'
        WHEN 2 THEN 'Tarjeta Débito'
        WHEN 3 THEN 'Tarjeta Crédito'
        ELSE 'Transferencia'
    END,
    'Pagado',
    idpaciente
FROM paciente
WHERE RAND() < 0.2;

-- ============================================================
-- 11. PLANES DE TRATAMIENTO (80% de las historias)
-- ============================================================
INSERT INTO plan_tratamiento (historiaClinicaFK, descripcion, presupuesto, saldoPendiente, fechaInicio, fechaFin, estado)
SELECT 
    hc.idHistoriaClinica,
    CASE FLOOR(1 + RAND() * 5)
        WHEN 1 THEN 'Plan de Ortodoncia completa'
        WHEN 2 THEN 'Tratamiento de endodoncia'
        WHEN 3 THEN 'Periodoncia + limpieza profunda'
        WHEN 4 THEN 'Cirugía de terceros molares'
        ELSE 'Rehabilitación oral con prótesis'
    END,
    ROUND(200000 + RAND() * 3000000, 2),
    ROUND(RAND() * 500000, 2),
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 180) DAY),
    DATE_ADD(CURDATE(), INTERVAL FLOOR(RAND() * 180) DAY),
    CASE FLOOR(1 + RAND() * 4)
        WHEN 1 THEN 'Activo'
        WHEN 2 THEN 'Completado'
        WHEN 3 THEN 'En progreso'
        ELSE 'Pendiente'
    END
FROM historiaClinica hc
WHERE RAND() < 0.8;

-- ============================================================
-- 12. AYUDAS DIAGNÓSTICAS (50% de las historias)
-- ============================================================
INSERT INTO ayuda_diagnostica (historiaClinicaFK, codigoCIE, descripcionDiagnostico, pronostico, rutaArchivo, tipoArchivo, fechaRegistro)
SELECT 
    hc.idHistoriaClinica,
    CASE FLOOR(1 + RAND() * 6)
        WHEN 1 THEN 'K02.1'
        WHEN 2 THEN 'K04.0'
        WHEN 3 THEN 'K05.3'
        WHEN 4 THEN 'K01.0'
        ELSE 'K00.6'
    END,
    CASE FLOOR(1 + RAND() * 5)
        WHEN 1 THEN 'Caries dental complicada'
        WHEN 2 THEN 'Pulpitis irreversible'
        WHEN 3 THEN 'Periodontitis crónica'
        WHEN 4 THEN 'Diente incluido'
        ELSE 'Maloclusión dental'
    END,
    CASE FLOOR(1 + RAND() * 3)
        WHEN 1 THEN 'Bueno'
        WHEN 2 THEN 'Reservado'
        ELSE 'Malo'
    END,
    CONCAT('https://ejemplo.com/ayudas/diagnostico_', hc.idHistoriaClinica, '.pdf'),
    'application/pdf',
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 120) DAY)
FROM historiaClinica hc
WHERE RAND() < 0.5;

-- ============================================================
-- 13. CONSENTIMIENTOS (60% de las historias)
-- ============================================================
INSERT INTO consentimiento (historiaClinicaFK, procedimiento, fechaFirma, firmaPaciente, firmaProfesional, observaciones)
SELECT 
    hc.idHistoriaClinica,
    CASE FLOOR(1 + RAND() * 6)
        WHEN 1 THEN 'Tratamiento de ortodoncia'
        WHEN 2 THEN 'Procedimiento de endodoncia'
        WHEN 3 THEN 'Extracción dental'
        WHEN 4 THEN 'Limpieza profunda'
        ELSE 'Colocación de prótesis'
    END,
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 180) DAY),
    CASE WHEN RAND() > 0.2 THEN 'Firmado' ELSE 'Pendiente' END,
    CASE WHEN RAND() > 0.1 THEN 'Firmado' ELSE 'Pendiente' END,
    'Consentimiento informado registrado.'
FROM historiaClinica hc
WHERE RAND() < 0.6;

-- ============================================================
-- 14. EXAMEN DENTAL (70% de las historias)
-- ============================================================
INSERT INTO examen_dental (historiaClinicaFK, hallazgos, odontograma, fechaRegistro)
SELECT 
    hc.idHistoriaClinica,
    CONCAT('Hallazgos: ', 
           CASE FLOOR(1 + RAND() * 4)
               WHEN 1 THEN 'Presencia de caries en piezas 1.6, 2.4 y 3.2.'
               WHEN 2 THEN 'Sangrado al sondaje generalizado.'
               WHEN 3 THEN 'Pérdida de soporte óseo en sector anterior.'
               ELSE 'Malposición dental y apiñamiento.'
           END),
    CONCAT('https://ejemplo.com/odontogramas/odontograma_', hc.idHistoriaClinica, '.png'),
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 180) DAY)
FROM historiaClinica hc
WHERE RAND() < 0.7;

-- ============================================================
-- 15. CITAS ODONTOLÓGICAS (200+ citas)
-- ============================================================

-- Generar 200 citas
INSERT INTO citaOdontologico (odontologoFK, pacienteFK, pagoFK, horario, tratamiento, estado)
SELECT 
    od.idOdontologo,
    p.idpaciente,
    NULL,
    DATE_ADD(CURDATE(), INTERVAL (FLOOR(RAND() * 180) - 90) DAY) AS horario,
    CASE FLOOR(1 + RAND() * 6)
        WHEN 1 THEN 'Consulta general'
        WHEN 2 THEN 'Ortodoncia'
        WHEN 3 THEN 'Endodoncia'
        WHEN 4 THEN 'Periodoncia'
        WHEN 5 THEN 'Cirugía oral'
        ELSE 'Profilaxis'
    END,
    CASE FLOOR(1 + RAND() * 5)
        WHEN 1 THEN 'Pendiente'
        WHEN 2 THEN 'Confirmada Asistida'
        WHEN 3 THEN 'Confirmada No Asistida'
        WHEN 4 THEN 'Cancelada'
        ELSE 'Reprogramada'
    END
FROM odontologo od, paciente p
WHERE RAND() < 0.3
LIMIT 200;

-- Asegurar que cada paciente tenga al menos una cita
INSERT INTO citaOdontologico (odontologoFK, pacienteFK, pagoFK, horario, tratamiento, estado)
SELECT 
    od.idOdontologo,
    p.idpaciente,
    (SELECT idPago FROM pago WHERE pacienteFK = p.idpaciente LIMIT 1),
    DATE_ADD(CURDATE(), INTERVAL FLOOR(RAND() * 30) DAY),
    'Consulta inicial',
    'Pendiente'
FROM odontologo od, paciente p
WHERE NOT EXISTS (SELECT 1 FROM citaOdontologico c WHERE c.pacienteFK = p.idpaciente)
ORDER BY RAND()
LIMIT 30;

-- ============================================================
-- 16. EVOLUCIONES (para citas asistidas)
-- ============================================================
INSERT INTO evolucion (historiaClinicaFK, odontologoFK, fechaSesion, estadoActual, consultaAnterior, cambiosTratamiento, respuestaPaciente, huboRemision, huboInterconsulta, cambioProfesional, observaciones)
SELECT 
    hc.idHistoriaClinica,
    c.odontologoFK,
    c.horario,
    CONCAT('Estado actual: ', 
           CASE FLOOR(1 + RAND() * 4)
               WHEN 1 THEN 'Mejoría significativa.'
               WHEN 2 THEN 'Sin cambios relevantes.'
               WHEN 3 THEN 'Leve empeoramiento.'
               ELSE 'Evolución favorable.'
           END),
    'Consulta anterior sin complicaciones.',
    CASE WHEN RAND() > 0.7 THEN 'Se ajusta dosis de medicación.' ELSE 'Se mantiene plan actual.' END,
    CASE WHEN RAND() > 0.6 THEN 'Paciente refiere buena tolerancia.' ELSE 'Paciente refiere leve molestia.' END,
    CASE WHEN RAND() > 0.92 THEN 'Si' ELSE 'No' END,
    CASE WHEN RAND() > 0.96 THEN 'Si' ELSE 'No' END,
    CASE WHEN RAND() > 0.98 THEN 'Si' ELSE 'No' END,
    'Seguimiento regular del tratamiento.'
FROM citaOdontologico c
JOIN historiaClinica hc ON hc.pacienteFK = c.pacienteFK
WHERE c.estado = 'Confirmada Asistida'
LIMIT 150;

-- ============================================================
-- VERIFICACIÓN DE DATOS INSERTADOS
-- ============================================================
SELECT '=== RESULTADOS DE INSERCIÓN ===' AS '';
SELECT 'Usuarios (personal)' AS tabla, COUNT(*) AS cantidad FROM usuario;
SELECT 'Odontólogos' AS tabla, COUNT(*) AS cantidad FROM odontologo;
SELECT 'Auxiliares' AS tabla, COUNT(*) AS cantidad FROM auxiliar;
SELECT 'Pacientes' AS tabla, COUNT(*) AS cantidad FROM paciente;
SELECT 'Historias Clínicas' AS tabla, COUNT(*) AS cantidad FROM historiaClinica;
SELECT 'Anamnesis' AS tabla, COUNT(*) AS cantidad FROM anamnesis;
SELECT 'Signos Vitales' AS tabla, COUNT(*) AS cantidad FROM signos_vitales;
SELECT 'Hábitos Higiene' AS tabla, COUNT(*) AS cantidad FROM habitos_higiene;
SELECT 'Medicamentos' AS tabla, COUNT(*) AS cantidad FROM medicamentos;
SELECT 'Pagos' AS tabla, COUNT(*) AS cantidad FROM pago;
SELECT 'Planes Tratamiento' AS tabla, COUNT(*) AS cantidad FROM plan_tratamiento;
SELECT 'Ayudas Diagnósticas' AS tabla, COUNT(*) AS cantidad FROM ayuda_diagnostica;
SELECT 'Consentimientos' AS tabla, COUNT(*) AS cantidad FROM consentimiento;
SELECT 'Exámenes Dentales' AS tabla, COUNT(*) AS cantidad FROM examen_dental;
SELECT 'Citas Odontológicas' AS tabla, COUNT(*) AS cantidad FROM citaOdontologico;
SELECT 'Evoluciones' AS tabla, COUNT(*) AS cantidad FROM evolucion;

SELECT '=== FIN DE CARGA ===' AS '';