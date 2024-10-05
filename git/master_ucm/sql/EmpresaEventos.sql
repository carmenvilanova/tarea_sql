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
   PRIMARY KEY(idArtista)
);

CREATE TABLE actividad_artista (
   idArtista char(3),
   idActividad char(3),
   cacheArt DECIMAL(10,2),
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
    SELECT SUM(aa.cacheArt) INTO totalCoste
    FROM artista a
    JOIN actividad_artista aa ON a.idArtista = aa.idArtista
    WHERE aa.idActividad = NEW.idActividad;

    -- Actualizar el coste en la tabla actividad
    UPDATE actividad
    SET coste = totalCoste
    WHERE idActividad = NEW.idActividad;
END$$
DELIMITER ;
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

-- CONSULTAS -- 
