/* 

	Proyecto final: Creación de una base de datos
	Autora: Carmen Vilanova de Diego
*/
-- Eliminamos la base de datos en caso de existir
DROP DATABASE IF EXISTS empresaEventos;

-- Creamos la base de datos
CREATE DATABASE empresaEventos;
USE empresaEventos;


/*Creación de tablas */
-- Eliminamos las tablas en caso de existir
DROP TABLE IF EXISTS actividad;
DROP TABLE IF EXISTS artista;
DROP TABLE IF EXISTS evento;
DROP TABLE IF EXISTS ubicacion;
DROP TABLE IF EXISTS asistente;

CREATE TABLE actividad (
   idActividad char(3),
   nombre varchar(40) not null,
   tipo varchar(40) not null,
   coste DECIMAL(10, 2),
   PRIMARY KEY(idActividad)
);

CREATE TABLE artista (
   idArtista char(3),
   nombreArt varchar(40) not null,
   biografia varchar(400) not null,
   cacheArt DECIMAL(10,2),
   PRIMARY KEY(idArtista)
);

CREATE TABLE actividad_artista (
   idArtista char(3),
   idActividad char(3),
   PRIMARY KEY(idArtista, idActividad),
   FOREIGN KEY(idArtista) REFERENCES artista(idArtista) ON DELETE cascade,   
   FOREIGN KEY(idActividad) REFERENCES actividad(idActividad) ON DELETE cascade
);

CREATE TABLE ubicacion (
   idUbicacion char(3),
   nombreUbi varchar(40) not null,
   direccion varchar(40) not null,
   tipo varchar(40) not null,
   caracteristica varchar(40) not null,
   aforo char(5),
   PAlquiler char(5),
   PRIMARY KEY(idUbicacion)
);

CREATE TABLE evento (
   idEvento char(3),
   idUbicacion char(3),
   idActividad char(3),
   nombreUbi varchar(40) not null,
   precio_entrada DECIMAL (10,2),
   num_asistentes INT,
   PRIMARY KEY(idEvento),
   FOREIGN KEY (idUbicacion) references ubicacion(idUbicacion),
   FOREIGN KEY (idActividad) references actividad(idActividad)
);

CREATE TABLE asistente (
   idAsistente char(3),
   nombreA varchar(40) not null,
   email varchar(40) not null,
   telefono char(9),
   PRIMARY KEY(idAsistente)
);

CREATE TABLE asiste (
   idAsistente char(3),
   idEvento char(3),
   idEntrada char (3),
   valoracion char (3),
   PRIMARY KEY(idAsistente,idEvento,idEntrada),
   FOREIGN KEY(idAsistente) REFERENCES asistente(idAsistente) ON DELETE cascade,   
   FOREIGN KEY(idEvento) REFERENCES evento(idEvento) ON DELETE cascade
);

    -- Trigger para calcular la suma de los cachés de los artistas involucrados en la actividad
DELIMITER $$
CREATE TRIGGER calcular_coste_actividad
AFTER INSERT ON actividad_artista
FOR EACH ROW
BEGIN
    DECLARE totalCoste DECIMAL(10,2);
    SELECT SUM(a.cacheArt) INTO totalCoste
    FROM artista a
    JOIN actividad_artista aa ON a.idArtista = aa.idArtista
    WHERE aa.idActividad = NEW.idActividad;

    -- Actualizar el coste en la tabla actividad
    UPDATE actividad
    SET coste = totalCoste
    WHERE idActividad = NEW.idActividad;
END$$
DELIMITER ;

-- trigger para ir sumando asistentes
CREATE TRIGGER NumAsistentesAI AFTER INSERT
ON asiste
FOR EACH ROW
UPDATE evento
SET num_asistentes = num_asistentes+1
WHERE new.idEvento = idEvento;

-- trigger para ir eliminando asistentes
CREATE TRIGGER NumAsistentesAD AFTER DELETE
ON asiste
FOR EACH ROW
UPDATE evento
SET num_asistentes = num_asistentes-1
WHERE old.idEvento = idEvento;

/
-- trigger para comprobar aforo
DELIMITER $$
CREATE TRIGGER check_aforo BEFORE INSERT ON asiste
FOR EACH ROW
BEGIN 
DECLARE current_asistentes INT;
DECLARE max_aforo INT;

SELECT num_asistentes,aforo 
INTO current_asistentes, max_aforo
FROM evento 
INNER JOIN ubicacion ON evento.idUbicacion = ubicacion.idUbicacion
WHERE idEvento = NEW.idEvento;

IF current_asistentes >= max_aforo THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Aforo completo. No se pueden vender más entradas";
    END IF;
END$$
DELIMITER ;

-- Se insertan los datos en las tablas

INSERT INTO actividad (idActividad, nombre, tipo, coste)
VALUES ('001', 'Concierto de rock', 'Concierto', 0);
INSERT INTO actividad (idActividad, nombre, tipo, coste)
VALUES ('002', 'Feria de ciencias', 'Exposición', 0);
INSERT INTO actividad (idActividad, nombre, tipo, coste)
VALUES ('003', 'Torneo de fútbol', 'Deporte', 0);
INSERT INTO actividad (idActividad, nombre, tipo, coste)
VALUES ('004', 'Obra de teatro', 'Teatro', 0);
INSERT INTO actividad (idActividad, nombre, tipo, coste)
VALUES ('005', 'Festival de cine', 'Cine', 0);
INSERT INTO actividad (idActividad, nombre, tipo, coste)
VALUES ('006', 'Exposición de arte', 'Exposición', 0);
INSERT INTO actividad (idActividad, nombre, tipo, coste)
VALUES ('007', 'Concierto de jazz', 'Concierto', 0);
INSERT INTO actividad (idActividad, nombre, tipo, coste)
VALUES ('008', 'Carrera de ciclismo', 'Deporte', 0);
INSERT INTO actividad (idActividad, nombre, tipo, coste)
VALUES ('009', 'Charla motivacional', 'Conferencia', 0);
INSERT INTO actividad (idActividad, nombre, tipo, coste)
VALUES ('010', 'Competencia de cocina', 'Competencia', 0);


INSERT INTO artista (idArtista, nombreArt, biografia, cacheArt) 
VALUES ('A01', 'Carlos Santana', 'Guitarrista legendario de rock', 1000.00);
INSERT INTO artista (idArtista, nombreArt, biografia, cacheArt) 
VALUES ('A02', 'Neil deGrasse Tyson', 'Astrofísico y divulgador científico', 2500.00); -- Para eventos científicos
INSERT INTO artista (idArtista, nombreArt, biografia, cacheArt) 
VALUES ('A03', 'Cristiano Ronaldo', 'Futbolista portugués de renombre', 1800.00); -- Para eventos deportivos
INSERT INTO artista (idArtista, nombreArt, biografia, cacheArt) 
VALUES ('A04', 'Emma Watson', 'Actriz y activista', 3500.00); -- Para teatro y charlas
INSERT INTO artista (idArtista, nombreArt, biografia, cacheArt) 
VALUES ('A05', 'Martin Scorsese', 'Director de cine y guionista', 3000.00); -- Para festival de cine
INSERT INTO artista (idArtista, nombreArt, biografia, cacheArt) 
VALUES ('A06', 'Banksy', 'Artista urbano anónimo', 2200.00); -- Para exposiciones de arte
INSERT INTO artista (idArtista, nombreArt, biografia, cacheArt) 
VALUES ('A07', 'John Coltrane', 'Saxofonista de jazz icónico', 2700.00); -- Para concierto de jazz
INSERT INTO artista (idArtista, nombreArt, biografia, cacheArt) 
VALUES ('A08', 'Lance Armstrong', 'Ciclista campeón del Tour de Francia', 4000.00); -- Para carrera de ciclismo
INSERT INTO artista (idArtista, nombreArt, biografia, cacheArt) 
VALUES ('A09', 'Oprah Winfrey', 'Presentadora de televisión y conferencista', 2800.00); -- Para charlas motivacionales
INSERT INTO artista (idArtista, nombreArt, biografia, cacheArt) 
VALUES ('A10', 'Gordon Ramsay', 'Chef y personalidad televisiva', 2000.00); -- Para competencia de cocina


-- Concierto de Rock (Carlos Santana)
INSERT INTO actividad_artista (idActividad, idArtista) VALUES ('001', 'A01');
INSERT INTO actividad_artista (idActividad, idArtista) VALUES ('001', 'A02');
-- Feria de Ciencias (Neil deGrasse Tyson)
INSERT INTO actividad_artista (idActividad, idArtista) VALUES ('002', 'A02');
-- Torneo de Fútbol (Cristiano Ronaldo)
INSERT INTO actividad_artista (idActividad, idArtista) VALUES ('003', 'A03');
-- Obra de Teatro (Emma Watson)
INSERT INTO actividad_artista (idActividad, idArtista) VALUES ('004', 'A04');
-- Festival de Cine (Martin Scorsese)
INSERT INTO actividad_artista (idActividad, idArtista) VALUES ('005', 'A05');
-- Exposición de Arte (Banksy)
INSERT INTO actividad_artista (idActividad, idArtista) VALUES ('006', 'A06');
-- Concierto de Jazz (John Coltrane)
INSERT INTO actividad_artista (idActividad, idArtista) VALUES ('007', 'A07');
-- Carrera de Ciclismo (Lance Armstrong)
INSERT INTO actividad_artista (idActividad, idArtista) VALUES ('008', 'A08');
-- Charla Motivacional (Oprah Winfrey)
INSERT INTO actividad_artista (idActividad, idArtista) VALUES ('009', 'A09');
-- Competencia de Cocina (Gordon Ramsay)
INSERT INTO actividad_artista (idActividad, idArtista) VALUES ('010', 'A10');

INSERT INTO ubicacion (idUbicacion, nombreUbi, direccion, tipo, caracteristica, aforo, PAlquiler)
VALUES ('U01', 'Teatro Nacional', 'Av. Libertador 123', 'Teatro', 'Histórico', '15', '5000');
INSERT INTO ubicacion (idUbicacion, nombreUbi, direccion, tipo, caracteristica, aforo, PAlquiler)
VALUES ('U02', 'Parque Central', 'Calle Principal S/N', 'Parque', 'Al aire libre', '5', '3000');
INSERT INTO ubicacion (idUbicacion, nombreUbi, direccion, tipo, caracteristica, aforo, PAlquiler)
VALUES ('U03', 'Estadio Olímpico', 'Av. Deportes 456', 'Estadio', 'Deportivo', '10', '15000');
INSERT INTO ubicacion (idUbicacion, nombreUbi, direccion, tipo, caracteristica, aforo, PAlquiler)
VALUES ('U04', 'Sala de Exposiciones', 'Calle Arte 789', 'Sala', 'Moderno', '1', '2500');
INSERT INTO ubicacion (idUbicacion, nombreUbi, direccion, tipo, caracteristica, aforo, PAlquiler)
VALUES ('U05', 'Auditorio Municipal', 'Plaza Mayor 101', 'Auditorio', 'Acústica excelente', '20', '4000');


INSERT INTO evento (idEvento, idUbicacion, idActividad, nombreUbi, precio_entrada, num_asistentes)
VALUES ('E01', 'U01', '001', 'Teatro Nacional', '10',0);
INSERT INTO evento (idEvento, idUbicacion, idActividad, nombreUbi, precio_entrada, num_asistentes)
VALUES ('E02', 'U02', '002', 'Parque Central', '25',0);
INSERT INTO evento (idEvento, idUbicacion, idActividad, nombreUbi, precio_entrada, num_asistentes)
VALUES ('E03', 'U03', '003', 'Estadio Olímpico', '18',0);
INSERT INTO evento (idEvento, idUbicacion, idActividad, nombreUbi, precio_entrada, num_asistentes)
VALUES ('E04', 'U04', '004', 'Sala de Exposiciones', '35',0);
INSERT INTO evento (idEvento, idUbicacion, idActividad, nombreUbi, precio_entrada, num_asistentes)
VALUES ('E05', 'U05', '005', 'Auditorio Municipal', '30',0);


INSERT INTO asistente (idAsistente, nombreA, email, telefono)
VALUES ('A01', 'María López', 'maria.lopez@mail.com', '12345678');
INSERT INTO asistente (idAsistente, nombreA, email, telefono)
VALUES ('A02', 'Carlos Pérez', 'carlos.perez@mail.com', '23456789');
INSERT INTO asistente (idAsistente, nombreA, email, telefono)
VALUES ('A03', 'Ana García', 'ana.garcia@mail.com', '34567890');
INSERT INTO asistente (idAsistente, nombreA, email, telefono)
VALUES ('A04', 'Juan Martínez', 'juan.martinez@mail.com', '45678901');
INSERT INTO asistente (idAsistente, nombreA, email, telefono)
VALUES ('A05', 'Lucía Fernández', 'lucia.fernandez@mail.com', '56789012');

INSERT INTO asiste (idAsistente, idEvento, idEntrada, valoracion)
VALUES ('A01', 'E01', 'T01', '5');
INSERT INTO asiste (idAsistente, idEvento, idEntrada, valoracion)
VALUES ('A02', 'E01', 'T02', '4');
INSERT INTO asiste (idAsistente, idEvento, idEntrada, valoracion)
VALUES ('A03', 'E02', 'T03', '3');
INSERT INTO asiste (idAsistente, idEvento, idEntrada, valoracion)
VALUES ('A04', 'E03', 'T04', '5');
INSERT INTO asiste (idAsistente, idEvento, idEntrada, valoracion)
VALUES ('A05', 'E04', 'T05', '4');
INSERT INTO asiste (idAsistente, idEvento, idEntrada, valoracion)
<<<<<<< HEAD
VALUES ('A05', 'E04', 'T05', '4');
=======
VALUES ('A05', 'E02', 'T06', '2');
>>>>>>> 99fae3ffc41cc6a93517e3a23d20e42d5aaf8960

-- CONSULTAS -- 
