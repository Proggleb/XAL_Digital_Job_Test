/*
Este es un tutorial / proceso de pensamiento para resolver el reto de SQL para XAL Digital, documentado y comentado en español

Realizado por Caleb Aguilar Camargo, el 21 de Junio de 2022
*/

/*
Voy a hacer uso de PostgreSQL para recordar un poco de ello, pues tiene rato que no lo utilizo

Lo primero es crear una Base de Datos donde almacenar la información, para facilitar su creación hacemos uso de pgAdmin 4 y PostgreSQL 14.0
*/

--Las siguientes lineas de código generan la BD
CREATE DATABASE "XAL_Digital"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Spanish_Mexico.1252'
    LC_CTYPE = 'Spanish_Mexico.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

--Automáticamente pgAdmin 4 crea un esquema "public", que utilizaremos para crear las tablas.

--Las siguientes lineas de código generan las tablas que se necesitarán
CREATE TABLE public.aerolineas
(
    id_aerolinea serial PRIMARY KEY, --esto porque evitaremos duplicados de aerolineas
    nombre_aerolinea VARCHAR(20)
)

CREATE TABLE public.aeropuertos
(
    id_aeropuerto serial PRIMARY KEY,
    nombre_aeropuerto VARCHAR(20)
)

CREATE TABLE public.movimientos
(
    id_movimiento serial PRIMARY KEY,
    descripcion VARCHAR(20)
)

--La siguiente tabla puede ser creada de forma análoga, sin embargo, vamos a hacer uso de las funcionalidades de pgAdmin 4, para ver cómo postgreSQL procesa
--los comandos escritos a su propio dialecto.
CREATE TABLE IF NOT EXISTS public.vuelos
(
    id_aerolinea integer,
    id_aeropuerto integer,
    id_movimiento integer,
    dia date,
    CONSTRAINT vuelos_id_aerolinea_fkey FOREIGN KEY (id_aerolinea)
        REFERENCES public.aerolineas (id_aerolinea) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT vuelos_id_aeropuerto_fkey FOREIGN KEY (id_aeropuerto)
        REFERENCES public.aeropuertos (id_aeropuerto) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT vuelos_id_movimiento_fkey FOREIGN KEY (id_movimiento)
        REFERENCES public.movimientos (id_movimiento) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

--Insertar datos en las tablas de la BD es bastante sencillo con las siguientes lineas de código:
INSERT INTO public.aerolineas(
	id_aerolinea, nombre_aerolinea)
	VALUES (1, 'string');
--en este caso ingresamos valores a la tabla de aerolineas, pero es fácil poblar todas las demás tablas, en caso de equivocarnos podemos hacer uso de UPDATE de la sig. forma:

UPDATE public.aerolineas
	SET id_aerolinea=1, nombre_aerolinea='volaris'
	WHERE id_aerolinea=1 and nombre_aerolinea='string';

-- si quisieramos borrar el valor, en vez de actualizarlo, usariamos:
DELETE FROM public.aerolineas
	WHERE id_aerolinea=1 and nombre_aerolinea='string';

--Aunque hacer la inserción de registros es sencilla de la forma previa, lo mejor sería crear un script simple en python que optimizara la población de la BD

/*
    1. ¿Cuál es el nombre aeropuerto que ha tenido mayor movimiento durante el año?
*/
--Dicen que la mejor forma de resolver un problema es la forma más sencilla, por lo que el siguiente query es una forma de resolver el problema.
SELECT vuelos.id_aeropuerto, count(*) FROM public.vuelos GROUP BY id_aeropuerto ORDER BY count(*) DESC;

--Si bien no nos dice el nombre del aeropuerto, nos dice que los id_aeropuertos 1 & 3, son los que tienen mayor movimiento, para este caso particular
--no es necesario hacer una consulta para saber el nombre del aeropuerto, ya que el nombre está en la tabla de aeropuertos.
--aunque por supuesto, cabe aclarar que si tuvieramos más contexto de nuestro usuario/cliente que requiere este query, entonces quizá sí deberíamos darle un query
--que pueda entregarle el nombre del aeropuerto, sin la necesidad de tener que buscarlo en otra tabla, para dado caso, podríamos usar la sig. query:
SELECT aeropuertos.nombre_aeropuerto, count(*)
FROM public.vuelos 
INNER JOIN public.aeropuertos
ON vuelos.ID_Aeropuerto = aeropuertos.ID_Aeropuerto
GROUP BY aeropuertos.nombre_aeropuerto ORDER BY count(*) DESC;

/*
    2. ¿Cuál es el nombre aerolínea que ha realizado mayor número de vuelos durante el año?
*/
--Para resolver este problema, podemos hacer uso de la tabla de vuelos, y el id_aerolinea, para saber el nombre de la aerolínea.
SELECT vuelos.id_aerolinea, count(*) FROM public.vuelos GROUP BY id_aerolinea ORDER BY count(*) DESC;
--Sin embargo, dado que en la tabla aparece un registro duplicado, deberíamos de consultar por mayor contexto de los datos registrados.
--Ya que podría darse el caso de que cada renglon corresponda a un movimiento único para cada aerolínea y aeropuerto, en cuyo caso la tabla contiene duplicados
--o bien, que cada renglon corresponda a un vuelo, en cuyo caso la tabla NO contiene duplicados.
--Asumiremos el primer escenario.
--De donde obtenemos que, para este caso particular, las aerolíneas 2 y 3 tienen mayor movimiento.

/*
    3. ¿En qué día se han tenido mayor número de vuelos?
*/
--La siguiente query nos muestra el día con mayor número de vuelos.
SELECT vuelos.dia, count(*) FROM public.vuelos GROUP BY dia ORDER BY count(*) DESC;
--De donde obtenemos, para este caso particular, que en la fecha 2021-05-02 hubo una mayor cantidad de vuelos (6).

/*
    4. ¿Cuáles son las aerolíneas que tienen mas de 2 vuelos por día?
*/
--La siguiente query nos muestra las aerolíneas que tienen mas de 2 vuelos por día.
SELECT vuelos.id_aerolinea, count(*) FROM public.vuelos GROUP BY id_aerolinea, dia HAVING count(*) > 2;
--Para este caso particular, ninguna aerolinea tiene más de 2 vuelos por día.
--Por ejemplo, si agregaramos el siguiente registro:
INSERT INTO public.vuelos(
	id_aerolinea, id_aeropuerto, id_movimiento, dia)
	VALUES (3, 4, 1, '2021-05-04');
--entonces tendríamos que sólo la aerolínea 3 tienen más de 2 vuelos por día.

--Si bien podría haber una solución más eficiente, de momento eso no es nuestra prioridad,
--además el costo computacional de estas querys es bastante bajo en la actualidad,
--sin importar la cantidad de registros que sean.
