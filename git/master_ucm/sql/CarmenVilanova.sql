/* 

	Proyecto final: Creacion de una base de datos
	Autora: Carmen Vilanova de Diego
*/
-- Eliminamos la base de datos en caso de existir
DROP DATABASE IF EXISTS empresaEventos;

-- Creamos la base de datos
CREATE DATABASE empresaEventos;
USE empresaEventos;


/*Creacion de tablas */
-- Eliminamos las tablas en caso de existir
DROP TABLE IF EXISTS actividad;
DROP TABLE IF EXISTS artista;
DROP TABLE IF EXISTS evento;
DROP TABLE IF EXISTS ubicacion;
DROP TABLE IF EXISTS asistente;
DROP TABLE IF EXISTS telefono;
DROP TABLE IF EXISTS asiste;
DROP TABLE IF EXISTS actividad_artista;

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
   poblacion varchar(40) not null,
   caracteristica varchar(40) not null,
   aforo char(5),
   PAlquiler char(5),
   PRIMARY KEY(idUbicacion)
);

CREATE TABLE evento (
   idEvento INT AUTO_INCREMENT,
   idUbicacion INT,
   idActividad INT,
   nombreEvento varchar(80) not null,
   precio_entrada DECIMAL (10,2),
   fecha DATE not null,
   hora TIME not null,
   PRIMARY KEY(idEvento),
   FOREIGN KEY (idUbicacion) references ubicacion(idUbicacion) ON delete cascade,
   FOREIGN KEY (idActividad) references actividad(idActividad) ON delete cascade
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
PRIMARY key(idAsistente),
FOREIGN KEY(idAsistente) REFERENCES asistente(idAsistente) ON DELETE cascade
);

CREATE TABLE actividad_artista (
   idArtista INT,
   idActividad INT,
   cacheArt DECIMAL(10,2),
   PRIMARY KEY(idArtista, idActividad),
   FOREIGN KEY(idArtista) REFERENCES artista(idArtista) ON DELETE cascade,   
   FOREIGN KEY(idActividad) REFERENCES actividad(idActividad) ON DELETE cascade
);


CREATE TABLE asiste (
   idAsistente INT not null,
   idEvento INT not null,
   valoracion INT CHECK (valoracion >= 0 AND valoracion <= 5),
   PRIMARY KEY(idAsistente, idEvento),
   FOREIGN KEY(idEvento) REFERENCES evento(idEvento) ON DELETE cascade,
   FOREIGN KEY(idAsistente) REFERENCES asistente(idAsistente) ON DELETe cascade
);
SET FOREIGN_KEY_CHECKS=0;

-- Trigger para calcular la suma de los caches de los artistas involucrados en la actividad
DELIMITER $$

CREATE TRIGGER calcular_coste_actividad
AFTER INSERT ON actividad_artista
FOR EACH ROW
BEGIN
    DECLARE nuevoCoste DECIMAL(10, 2);
    
    -- Calcular el nuevo coste de la actividad sumando los caches de los artistas
    SELECT SUM(cacheArt) INTO nuevoCoste
    FROM actividad_artista
    WHERE idActividad = NEW.idActividad;

    -- Actualizar el coste de la actividad en la tabla actividad
    UPDATE actividad
    SET coste = nuevoCoste
    WHERE idActividad = NEW.idActividad;
END$$

DELIMITER ;


-- Trigger para comprobar aforo
DELIMITER $$

CREATE TRIGGER check_aforo
BEFORE INSERT ON asiste
FOR EACH ROW
BEGIN
    DECLARE totalEntradas INT;
    DECLARE aforoMax INT;

    -- Obtener el aforo maximo del evento correspondiente
    SELECT aforo INTO aforoMax
    FROM evento e
    JOIN ubicacion u ON e.idUbicacion = u.idUbicacion
    WHERE e.idEvento = NEW.idEvento;

    -- Contar el numero de entradas ya vendidas para el evento
    SELECT COUNT(*) INTO totalEntradas
    FROM asiste
    WHERE idEvento = NEW.idEvento;

    -- Comprobar si el numero total de entradas excede el aforo
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
(1, 1, 500.00),  -- Carlos Santana en Concierto de Jazz
(2, 2, 300.00),  -- Pablo Picasso en Exposición de Arte Contemporáneo
(3, 3, 150.00), -- Beyoncé en Conferencia sobre Inteligencia Artificial
(4, 4, 200.00),  -- Frida Kahlo en Obra de Teatro Clásico
(5, 1, 800.00),  -- Miles Davis en Concierto de Jazz
(6, 5, 1000.00), -- Adele en Concierto de Música Clásica
(7, 2, 0.00),     -- Vincent van Gogh en Exposición de Arte Contemporáneo (sin caché)
(8, 6, 600.00),  -- John Coltrane en Conferencia sobre Economía Circular
(9, 7, 120.00), -- Lady Gaga en Concierto de Rock and Roll
(10, 9, 300.00),  -- Diego Rivera en Obra de Teatro Moderno
(9, 1, 120.00), -- Lady Gaga en Concierto de Jazz
(10, 4, 300.00); -- Diego Rivera en Obra de Teatro Clasico

INSERT INTO ubicacion (nombreUbi, direccion, tipo, caracteristica, aforo, PAlquiler, poblacion)
VALUES
('Auditorio Nacional', 'Calle Príncipe, 44', 'ciudad', 'Acústica excelente', '10', '5000', 'Madrid'),
('Teatro Real', 'Plaza de Oriente, s/n', 'ciudad', 'Teatro histórico', '15', '4000', 'Barcelona'),
('Sala Luna', 'Calle Luna, 14', 'ciudad', 'Sala moderna', '50', '1500', 'Valencia'),
('Parque Central', 'Av. Libertad, 101', 'pueblo', 'Espacio al aire libre', '30', '2500', 'San Pedrito'),
('Plaza Mayor', 'Plaza Mayor, s/n', 'pueblo', 'Centro cultural', '12', '1000', 'El Rincón'),
('Museo del Arte', 'Calle del Arte, 22', 'ciudad', 'Galería moderna', '10', '3000', 'Bilbao'),
('Centro de Convenciones', 'Calle Mayor, 55', 'ciudad', 'Salón para eventos', '25', '4500', 'Sevilla'),
('Teatro del Pueblo', 'Calle Libertad, 9', 'pueblo', 'Teatro tradicional', '80', '1200', 'Villa Esperanza'),
('Anfiteatro al Aire Libre', 'Parque del Sol, s/n', 'ciudad', 'Vista panorámica', '180', '3500', 'Granada'),
('Casa de la Cultura', 'Av. Central, 12', 'pueblo', 'Lugar comunitario', '40', '800', 'Pueblo Nuevo');


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
(3, '620345678', NULL),         -- Luis Martínez (solo un numero)
(4, '630456789', '670765432'),  -- Ana Sánchez
(5, '640567890', NULL),         -- Pedro Fernández (solo un numero)
(6, '650678901', '660654321'),  -- Laura Gómez
(7, '670789012', '610543210'),  -- Javier Díaz
(8, '680890123', NULL),         -- Carmen Ruiz (solo un numero)
(9, '690901234', '600432109'),  -- José Pérez
(10, '600012345', NULL);        -- Lucía Romero (solo un numero)

INSERT INTO evento (idUbicacion, idActividad, nombreEvento, precio_entrada, fecha, hora)
VALUES 
(3, 1, 'Noche de Jazz', 22.00, '2024-10-16', '20:00:00'),
(5, 8, 'Fotografía Urbana: Miradas Contemporáneas', 18.00, '2024-10-16', '17:00:00'),
(2, 4, 'Teatro Clásico: La Vida es Sueño', 32.00, '2024-10-16', '19:30:00'),
(7, 3, 'Conferencia: El Futuro de la IA', 45.00, '2024-10-17', '09:00:00'),
(1, 6, 'Economía Circular y Sostenibilidad', 35.00, '2024-10-17', '10:30:00'),
(9, 5, 'Concierto de Música Clásica', 27.00, '2024-10-17', '20:00:00'),
(6, 7, 'Rock and Roll Fest', 50.00, '2024-10-17', '21:30:00'),
(4, 10, 'Blues al Atardecer', 28.00, '2024-10-18', '18:30:00'),
(8, 9, 'Teatro Musical: Un Sueño en Broadway', 38.00, '2024-10-18', '17:30:00'),
(10, 2, 'Exposición de Arte Contemporáneo', 20.00, '2024-10-18', '12:00:00'),
(3, 1, 'Jazz al Mediodía', 20.00, '2024-10-18', '14:00:00'),
(4, 8, 'Fotografias del Nuevo Mundo', 33.00, '2024-10-18', '20:00:00');


INSERT INTO asiste (idAsistente, idEvento, valoracion) 
VALUES 
(1, 1, 5),
(1, 5, 4),
(1, 7, 5),
(1, 10, 4), 
(2, 2, 3),
(2, 8, 4),
(2, 12, 2),
(2, 19, 3),
(2, 20, 1), 
(3, 3, 2),
(3, 6, 3),
(3, 13, 1),
(4, 4, 1),
(4, 9, 2),
(4, 14, 0),
(5, 5, 3),
(5, 9, 4),
(5, 15, 5),
(6, 7, 5),
(6, 10, 4),
(6, 16, 5),
(7, 2, 4),
(7, 8, 3),
(7, 12, 3),
(7, 15, 2),
(8, 9, 4),
(8, 14, 5),
(8, 20, 3),
(9, 3, 2),
(9, 6, 1),
(10, 4, 3),
(10, 10, 2),
(10, 16, 4),
(3, 2, 0),
(9, 2, 0),
(10, 8, 0);

-- CONSULTAS -- 

# 1.Numero de eventos de cada actividad

SELECT nombre, count(e.idEvento) numeroEventos
FROM evento e
INNER JOIN
actividad a ON e.idActividad = a.idActividad
GROUP BY
a.nombre;

# 2. Actividades con un solo artista
SELECT a.nombre, COUNT(aa.idArtista) AS numeroArtistas
FROM actividad_artista aa
INNER JOIN actividad a ON aa.idActividad = a.idActividad
GROUP BY a.idActividad
HAVING COUNT(aa.idArtista) = 1;


# 3. Poblacion en la que solo se han realizado eventos de teatro
SELECT u.poblacion
FROM ubicacion u 
INNER JOIN evento e ON u.idUbicacion = e.idUbicacion
INNER JOIN actividad a ON e.idActividad = a.idActividad
GROUP BY u.poblacion
HAVING COUNT(DISTINCT a.tipo) = 1 AND MAX(a.tipo) = 'Teatro';


# 4. Evento con mas ceros en su valoración
SELECT nombreEvento, COUNT(valoracion) AS num_ceros
FROM evento e
INNER JOIN asiste a ON a.idEvento = e.idEvento
WHERE valoracion = 0
GROUP BY nombreEvento
ORDER BY num_ceros DESC
LIMIT 1;


# 5. Asistente que puntua más alto

SELECT nombreAs, apellidoAs, AVG(valoracion) AS mediaValoracion
FROM asiste a
INNER JOIN
asistente aa ON a.idAsistente = aa.idAsistente
GROUP BY a.idAsistente
ORDER BY mediaValoracion DESC
LIMIT 1;


# 6. Dia en el que más asistentes ha habido

-- En primer lugar creamos la vista
CREATE VIEW vista_asistentes_por_fecha AS
SELECT e.fecha, COUNT(DISTINCT a.idAsistente) AS totalAsistentes
FROM evento e 
INNER JOIN asiste a ON e.idEvento = a.idEvento
GROUP BY e.fecha;


-- Realizamos la consulta utilizando la vista
SELECT fecha, totalAsistentes
FROM vista_asistentes_por_fecha
ORDER BY totalAsistentes DESC
LIMIT 1;


# 7. Obten el beneficio de cada evento
SELECT e.nombreEvento, 
       (SUM(e.precio_entrada) - a.coste) AS beneficios -- para calcular los beneficios sumamos el precio de las entradas vendidas y restamos el coste de la actividad
FROM evento e
INNER JOIN actividad a ON a.idActividad = e.idActividad
INNER JOIN asiste s ON s.idEvento = e.idEvento
GROUP BY e.nombreEvento, a.coste
ORDER BY beneficios DESC;

# 8. Artistas que han participado en mas de una actividad
-- Para esta consulta utilizamos IN para generar una subconsulta

SELECT ar.nombreArt
FROM artista ar
WHERE ar.idArtista IN (
    SELECT aa.idArtista
    FROM actividad_artista aa
    GROUP BY aa.idArtista
    HAVING COUNT(aa.idActividad) > 1
);


# 9. Consulta el numero total de eventos a los que cada asistente ha asistido 
SELECT a.nombreAs, apellidoAs, COUNT(s.idEvento) AS totalEventosAsistidos
FROM  asistente a
INNER JOIN 
asiste s ON a.idAsistente = s.idAsistente
GROUP BY a.nombreAs, apellidoAs
ORDER BY totalEventosAsistidos DESC;



# 10. Consulta el nombre y apellidos de los asistentes cuyo empiecen por 61
SELECT a.nombreAs, a.apellidoAs, telefono1, telefono2
FROM asistente a
INNER JOIN telefono t ON a.idAsistente = t.idAsistente
WHERE t.telefono1 LIKE '61%' OR t.telefono2 LIKE '61%';
