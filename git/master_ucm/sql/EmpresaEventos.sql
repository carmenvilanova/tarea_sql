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
   idActividad INT AUTO_iNCREMENT,
   nombre varchar(60) not null,
   tipo varchar(40) not null,
   coste DECIMAL(10, 2),
   PRIMARY KEY(idActividad)
);

CREATE TABLE artista (
   idArtista INT AUTO_iNCREMENT,
   nombreArt varchar(40) not null,
   biografia varchar(400) not null,
   PRIMARY KEY(idArtista)
);

CREATE TABLE ubicacion (
   idUbicacion INT AUTO_iNCREMENT,
   nombreUbi varchar(40) not null,
   direccion varchar(40) not null,
   tipo varchar(40) not null CHECK (tipo IN ('ciudad', 'pueblo')), /* solo puede ser ciudad o pueblo*/
   caracteristica varchar(40) not null,
   aforo char(5),
   PAlquiler char(5),
   PRIMARY KEY(idUbicacion)
);

CREATE TABLE evento (
   idEvento INT AUTO_iNCREMENT,
   idUbicacion INT,
   idActividad INT,
   precio_entrada DECIMAL (10,2),
   fecha DATE not null,
   hora TIME not null,
   PRIMARY KEY(idEvento),
   FOREIGN KEY (idUbicacion) references ubicacion(idUbicacion),
   FOREIGN KEY (idActividad) references actividad(idActividad)
);

CREATE TABLE asistente (
   idAsistente INT AUTO_iNCREMENT,
   nombreAs varchar(40) not null,
   apellidoAs varchar(40) not null,
   email varchar(40) not null,
   PRIMARY KEY(idAsistente)
);

CREATE TABLE telefono (
idAsistente INT,
telefono1 char(9),
telefono2 char(9),
PRIMARY key(idAsistente)
);

CREATE TABLE actividad_artista (
   idArtista INT AUTO_iNCREMENT,
   idActividad INT,
   cacheArt DECIMAL(10,2),
   PRIMARY KEY(idArtista, idActividad),
   FOREIGN KEY(idArtista) REFERENCES artista(idArtista) ON DELETE cascade,   
   FOREIGN KEY(idActividad) REFERENCES actividad(idActividad) ON DELETE cascade
);

CREATE TABLE asiste (
   idAsistente INT,
   idEvento INT,
   valoracion INT CHECK (valoracion >= 0 AND valoracion <= 5),  -- Restricción para valores enteros entre 0 y 5
   PRIMARY KEY(idAsistente, idEvento)
);



-- Trigger para calcular la suma de los cachés de los artistas involucrados en la actividad
DELIMITER $$

CREATE TRIGGER calcular_coste_actividad
AFTER INSERT ON actividad_artista
FOR EACH ROW
BEGIN
    DECLARE nuevoCoste DECIMAL(10, 2);
    
    -- Calcular el nuevo coste de la actividad sumando los cachés de los artistas
    SELECT SUM(cacheArt) INTO nuevoCoste
    FROM actividad_artista
    WHERE idActividad = NEW.idActividad;

    -- Actualizar el coste de la actividad en la tabla actividad
    UPDATE actividad
    SET coste = nuevoCoste
    WHERE idActividad = NEW.idActividad;
END$$

DELIMITER ;


-- trigger para comprobar aforo
DELIMITER $$

CREATE TRIGGER check_aforo
BEFORE INSERT ON asiste
FOR EACH ROW
BEGIN
    DECLARE totalEntradas INT;
    DECLARE aforoMax INT;

    -- Obtener el aforo máximo del evento correspondiente
    SELECT aforo INTO aforoMax
    FROM evento e
    JOIN ubicacion u ON e.idUbicacion = u.idUbicacion
    WHERE e.idEvento = NEW.idEvento;

    -- Contar el número de entradas ya vendidas para el evento
    SELECT COUNT(*) INTO totalEntradas
    FROM asiste
    WHERE idEvento = NEW.idEvento;

    -- Comprobar si el número total de entradas excede el aforo
    IF (totalEntradas >= aforoMax) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Se ha completado el aforo';
    END IF;
END$$

DELIMITER ;


-- Se insertan los datos en las tablas
INSERT INTO actividad (nombre, tipo, coste)
VALUES 
('Concierto de Jazz', 'Concierto', 0.00),
('Exposición de Arte Contemporáneo', 'Exposición', 0.00),
('Conferencia sobre Inteligencia Artificial', 'Conferencia', 0.00),
('Obra de Teatro Clásico', 'Teatro', 0.00),
('Concierto de Música Clásica', 'Concierto', 0.00),
('Conferencia sobre Economía Circular', 'Conferencia', 0.00),
('Concierto de Rock and Roll', 'Concierto', 0.00),
('Exposición Fotográfica', 'Exposición', 0.00),
('Obra de Teatro Musical', 'Teatro', 0.00),
('Concierto de Blues', 'Concierto', 0.00);

INSERT INTO artista (nombreArt, biografia)
VALUES 
('Carlos Santana', 'Guitarrista y compositor mexicano, reconocido por fusionar el rock con la música latina. Ha ganado múltiples premios Grammy.'),
('Pablo Picasso', 'Pintor y escultor español, cofundador del movimiento cubista y uno de los artistas más influyentes del siglo XX.'),
('Beyoncé', 'Cantante y actriz estadounidense, conocida por su poderosa voz y sus contribuciones a la música pop y R&B a nivel global.'),
('Frida Kahlo', 'Pintora mexicana famosa por sus autorretratos que exploran temas de identidad, poscolonialismo y feminismo.'),
('Miles Davis', 'Trompetista y compositor estadounidense, considerado uno de los músicos de jazz más innovadores de todos los tiempos.'),
('Adele', 'Cantante y compositora británica, reconocida por su profunda voz y sus emotivas baladas. Ganadora de varios premios Grammy.'),
('Vincent van Gogh', 'Pintor posimpresionista neerlandés, conocido por su estilo vibrante y emocional, que dejó un legado inmenso a pesar de su vida trágica.'),
('John Coltrane', 'Saxofonista y compositor estadounidense, pionero en el desarrollo del jazz modal y conocido por su estilo experimental.'),
('Lady Gaga', 'Cantante y actriz estadounidense, famosa por su versatilidad en géneros musicales y su estilo artístico único y excéntrico.'),
('Diego Rivera', 'Muralista mexicano, conocido por sus obras que reflejan la historia y lucha social de México en el siglo XX.');


INSERT INTO actividad_artista (idArtista, idActividad, cacheArt)
VALUES
(1, 1, 5000.00),  -- Carlos Santana en Concierto de Jazz
(2, 2, 3000.00),  -- Pablo Picasso en Exposición de Arte Contemporáneo
(3, 3, 15000.00), -- Beyoncé en Conferencia sobre Inteligencia Artificial
(4, 4, 2000.00),  -- Frida Kahlo en Obra de Teatro Clásico
(5, 1, 8000.00),  -- Miles Davis en Concierto de Jazz
(6, 5, 10000.00), -- Adele en Concierto de Música Clásica
(7, 2, 0.00),     -- Vincent van Gogh en Exposición de Arte Contemporáneo (sin caché)
(8, 6, 6000.00),  -- John Coltrane en Conferencia sobre Economía Circular
(9, 7, 12000.00), -- Lady Gaga en Concierto de Rock and Roll
(10, 9, 3000.00); -- Diego Rivera en Obra de Teatro Musical

INSERT INTO ubicacion (nombreUbi, direccion, tipo, caracteristica, aforo, PAlquiler)
VALUES
('Auditorio Nacional', 'Calle Príncipe, 44', 'ciudad', 'Acústica excelente', '2', '5000'),
('Teatro Real', 'Plaza de Oriente, s/n', 'ciudad', 'Teatro histórico', '15', '4000'),
('Sala Luna', 'Calle Luna, 14', 'ciudad', 'Sala moderna', '50', '1500'),
('Parque Central', 'Av. Libertad, 101', 'pueblo', 'Espacio al aire libre', '30', '2500'),
('Plaza Mayor', 'Plaza Mayor, s/n', 'pueblo', 'Centro cultural', '12', '1000'),
('Museo del Arte', 'Calle del Arte, 22', 'ciudad', 'Galería moderna', '10', '3000'),
('Centro de Convenciones', 'Calle Mayor, 55', 'ciudad', 'Salón para eventos', '25', '4500'),
('Teatro del Pueblo', 'Calle Libertad, 9', 'pueblo', 'Teatro tradicional', '80', '1200'),
('Anfiteatro al Aire Libre', 'Parque del Sol, s/n', 'ciudad', 'Vista panorámica', '180', '3500'),
('Casa de la Cultura', 'Av. Central, 12', 'pueblo', 'Lugar comunitario', '40', '800');


INSERT INTO asistente (nombreAs, apellidoAs, email)
VALUES
('Carlos', 'García', 'carlos.garcia@email.com'),
('María', 'López', 'maria.lopez@email.com'),
('Luis', 'Martínez', 'luis.martinez@email.com'),
('Ana', 'Sánchez', 'ana.sanchez@email.com'),
('Pedro', 'Fernández', 'pedro.fernandez@email.com'),
('Laura', 'Gómez', 'laura.gomez@email.com'),
('Javier', 'Díaz', 'javier.diaz@email.com'),
('Carmen', 'Ruiz', 'carmen.ruiz@email.com'),
('José', 'Pérez', 'jose.perez@email.com'),
('Lucía', 'Romero', 'lucia.romero@email.com');

INSERT INTO telefono (idAsistente, telefono1, telefono2)
VALUES
(1, '600123456', '690987654'),  -- Carlos García
(2, '610234567', '680876543'),  -- María López
(3, '620345678', NULL),         -- Luis Martínez (solo un número)
(4, '630456789', '670765432'),  -- Ana Sánchez
(5, '640567890', NULL),         -- Pedro Fernández (solo un número)
(6, '650678901', '660654321'),  -- Laura Gómez
(7, '670789012', '610543210'),  -- Javier Díaz
(8, '680890123', NULL),         -- Carmen Ruiz (solo un número)
(9, '690901234', '600432109'),  -- José Pérez
(10, '600012345', NULL);        -- Lucía Romero (solo un número)

INSERT INTO evento (idUbicacion, idActividad, precio_entrada, fecha, hora)
VALUES
    (1, 1, 100.00, '2024-10-10', '18:00:00'),  -- Evento 1
    (2, 2, 50.00, '2024-10-11', '15:30:00'),   -- Evento 2
    (3, 3, 75.00, '2024-10-12', '20:00:00'),   -- Evento 3
    (4, 4, 120.00, '2024-10-13', '19:00:00'),  -- Evento 4
    (5, 5, 30.00, '2024-10-14', '14:00:00'),   -- Evento 5
    (1, 6, 25.00, '2024-10-15', '16:00:00'),   -- Evento 6
    (2, 7, 80.00, '2024-10-16', '19:30:00'),   -- Evento 7
    (3, 8, 55.00, '2024-10-17', '17:00:00'),   -- Evento 8
    (4, 9, 105.00, '2024-10-18', '20:30:00'),  -- Evento 9
    (5, 10, 40.00, '2024-10-19', '13:30:00');  -- Evento 10

INSERT INTO asiste (idAsistente, idEvento, valoracion)
VALUES
    (1, 1, 4),
    (2, 2, 5),
    (3, 3, 3),
    (4, 4, 2),
    (5, 5, 5),
    (1, 6, 0),
    (2, 7, 1),
    (3, 8, 4),
    (4, 9, 3),
    (5, 10, 5);

-- CONSULTAS -- 

