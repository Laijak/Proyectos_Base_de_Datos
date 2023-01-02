CREATE DATABASE Banco_Sangre_Pruebas

--Creacion de la tabla de tipos de sangre
Create table Tipo_Sangre(
tipo_sangre_id int identity primary key, --con 'identity' automaticamente se vuelve 'not null'.
descripcion varchar(50),
puede_recibir varchar(50),
puede_donar varchar(50)
)
--Insecion de los grupos sanguíneos
INSERT INTO Tipo_Sangre (descripcion, puede_recibir, puede_donar)
	VALUES ('A+', 'A+, A-, O+, O-', 'A+, AB+'),
		   ('A-', 'A-, O-', 'A+, A-, AB+, AB-'),
		   ('B+', 'B+, B-, O+, O-', 'B+, AB+'),
		   ('B-', 'B-, O-', 'B+, B-, AB+, AB-'),
		   ('AB+', 'TODOS', 'AB+'),
		   ('AB-', 'A-, B-, AB-, O-', 'AB+, AB-'),
		   ('O+', 'O+, O-', 'A+, B+, AB+, O+'),
		   ('O-', 'O-', 'TODOS')

SELECT * FROM Tipo_Sangre

--Creacion de la tabla estatus del analisis
Create table Analisis_Estatus(
analisis_estatus_id int not null identity primary key,
descripcion varchar (50)
)
--Insecion de los estatus
INSERT INTO Analisis_Estatus (descripcion)
	VALUES ('En espera'),
		   ('En revision'),
		   ('Aprobado'),
		   ('Anulado')

Select * from Analisis_Estatus

--Creacion de la tabla pacientes
set dateformat DMY
CREATE TABLE Pacientes(
paciente_id int not null identity primary key,
paciente_nombres varchar(50),
paciente_apellidos varchar(50),
paciente_telefono varchar(20),
paciente_direccion varchar(100),
paciente_correo varchar(50),
tipo_sangre_id int not null foreign key references Tipo_Sangre (tipo_sangre_id),
solicitud_fecha date not null,
solicitud_lugar varchar(100),
solicitud_razon varchar(100)
)
--Insercion de los pacientes
INSERT INTO Pacientes(
		paciente_nombres,
		paciente_apellidos,
		paciente_telefono,
		paciente_direccion,
		paciente_correo,
		tipo_sangre_id,
		solicitud_fecha,
		solicitud_lugar,
		solicitud_razon)
	VALUES ('Jhonatan', 'Salazar', '809-845-8080', 'Av. Las Américas', 'salazarJH@gmail.com', 6, GETDATE(), 'Clínica Abreu', 'El paciente presenta una hemorragia interna.')

SELECT * FROM Pacientes

Update Pacientes set paciente_nombres = 'Joel',
					 paciente_apellidos = 'Ramírez',
					 paciente_direccion = 'Av. Ecologica',
					 paciente_correo = 'JRamirez@gmail.com',
					 paciente_telefono = '809-000-2332',
					 solicitud_razon = 'El paciente necesita un transplante de riñon'
				WHERE paciente_id = 1

--Creacion de la tabla movimiento
CREATE TABLE Movimiento(
movimiento_id int not null identity primary key,
tipo_movimiento varchar(100)
)
--Insercion de los tipos de movimiento
INSERT INTO Movimiento(tipo_movimiento)
VALUES  ('Insercion'),
		('Actualizacion'),
		('Eliminacion');

SELECT * FROM Movimiento

--Creacion de la tabla historial de donantes
set dateformat DMY
Create table Historial_Donantes(
historial_don_id int not null identity primary key,
donante_id int not null foreign key references Donantes (donante_id),
donante_nombres varchar(50),
donante_apellidos varchar(50),
tipo_sangre_id int,
tipo_movimiento_id int not null foreign key references Movimiento (movimiento_id),
usuario_cambio varchar(50),
fecha_cambio date
)
--Creacion del trigger para llenar el historial de donantes respecto a la tabla donantes
Create TRIGGER TRIGGER_Historial_Donante ON Donantes
 FOR
    INSERT, UPDATE, DELETE
AS
 BEGIN
     IF EXISTS ( SELECT '' FROM Inserted I INNER JOIN Deleted D ON D.donante_id = I.donante_id)
         Begin
             --ACTUALIZACION Registro Existente
             insert into Historial_Donantes
             (donante_id, donante_nombres, donante_apellidos, tipo_sangre_id,
			 tipo_movimiento_id, usuario_cambio, fecha_cambio) --ESTOS SON DATOS DE ALTERACION
				 Select
					 I.donante_id,
					 I.donante_nombres,
					 I.donante_apellidos,
					 I.tipo_sangre_id,
					 2 As tipo_movimiento_id,
					 USER_NAME () AS usuario_cambio,
					 getdate() AS fecha_cambio
				 FROM Inserted I
		END
	ELSE IF EXISTS (SELECT '' FROM Inserted I)
		BEGIN
			--INSERT Registro nuevo
			insert into Historial_Donantes
             (donante_id, donante_nombres, donante_apellidos, tipo_sangre_id,
			 tipo_movimiento_id, usuario_cambio, fecha_cambio) --ESTOS SON DATOS DE ALTERACION
				 Select
					 I.donante_id,
					 I.donante_nombres,
					 I.donante_apellidos,
					 I.tipo_sangre_id,
					 1 As tipo_movimiento_id,
					 USER_NAME () AS usuario_cambio,
					 getdate() AS fecha_cambio
				 FROM Inserted I
		END
	ELSE
		BEGIN
			--ELIMINAR Registro Existente
			insert into Historial_Donantes
             (donante_id, donante_nombres, donante_apellidos, tipo_sangre_id,
			 tipo_movimiento_id, usuario_cambio, fecha_cambio) --ESTOS SON DATOS DE ALTERACION
				 Select
					 D.donante_id,
					 D.donante_nombres,
					 D.donante_apellidos,
					 D.tipo_sangre_id,
					 3 As tipo_movimiento_id,
					 USER_NAME () AS usuario_cambio,
					 getdate() AS fecha_cambio
				 FROM Deleted D
		END
END

--Creacion de la tabal 'Donantes'
set dateformat DMY
Create table Donantes(
donante_id int identity primary key,
donante_nombres varchar(50),
donante_apellidos varchar(50),
donante_telefono varchar(20),
donante_direccion varchar(100),
donante_correo varchar(50),
donante_analisis_estatus_id int not null foreign key references Analisis_Estatus (analisis_estatus_id),
tipo_sangre_id int not null foreign key references Tipo_Sangre (tipo_sangre_id),
fecha_donacion date not null
)
--Incersion de los donantes
INSERT INTO Donantes(
	donante_nombres,
	donante_apellidos,
	donante_telefono,
	donante_direccion,
	donante_correo,
	donante_analisis_estatus_id,
	tipo_sangre_id,
	fecha_donacion)
	
	VALUES('Juan Marcos', 'Matos', '829-666-2121', 'Av. Charles de Gaulle', 'marcosmatos@gmail.com', 1, 5, GETDATE()),
		  ('Samuel', 'Sánchez', '800-600-2000', 'Sarasota', 'samsan@gmail.com', 2, 4, GETDATE()),
		  ('Gregorio', 'Temper', '809-606-2001', 'Bella Vista', 'TEMPER@yahoo.com', 2, 3, GETDATE()),
		  ('Nathan', 'Hover', '833-222-1111', 'Av. San Isidro', 'hoverNTH@gmail.com', 3, 1, GETDATE())

SELECT * FROM Donantes
SELECT * FROM Historial_Donantes
--Actualizacion del donante con 'donante_id = 1'
UPDATE Donantes SET donante_nombres = 'Jose Alberto' where donante_id = 1

Select * FROM Donantes