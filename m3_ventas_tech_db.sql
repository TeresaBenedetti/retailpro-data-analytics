/* ====================================================================
   Checkpoint M3: Script SQL de esquema normalizado y datos iniciales

   Estructura del script:
     Paso 1 - Creación de la base de datos
     Paso 2 - Desarrollo del script:
         Preparación - DROP TABLES (para que el script sea repetible)
         Sección 1   - Definición del Esquema (DDL)
         Sección 2   - Restricciones de Integridad
         Sección 3   - Carga Inicial de Datos (DML)
     Paso 3 - Prueba del sript
   ===================================================================== */


/* =====================================================================
   PASO 1 - CREACIÓN DE LA BASE DE DATOS
   Se crea solo si no existe, para poder ejecutar el script varias veces.
   El GO es obligatorio: separa la creación de la base del USE, porque
   SQL Server no permite usar una base en el mismo lote en que se crea.
   ===================================================================== */
IF DB_ID('Ventas_Tech_DB') IS NULL
    CREATE DATABASE Ventas_Tech_DB;
GO

USE Ventas_Tech_DB;


/* #####################################################################
   PASO 2 - DESARROLLO DEL SCRIPT
   Incluye: Preparación (DROP), Sección 1 (DDL), Sección 2
   (Restricciones) y Sección 3 (DML).
   ##################################################################### */


/* =====================================================================
   PASO 2 - PREPARACIÓN - DROP TABLES
   Se eliminan las tablas si ya existen, en orden inverso de
   dependencias: primero las que tienen FK, al final las referenciadas.
   ===================================================================== */
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS categorias;


/* =====================================================================
   PASO 2 - SECCIÓN 1 - DEFINICIÓN DEL ESQUEMA (DDL)
   Se crean las tablas con sus columnas y tipos de datos.
   Orden: primero las dimensiones, al final la tabla de hechos (ventas).
   Los campos críticos se definen como NOT NULL (ver Sección 2).
   ===================================================================== */

-- Categorías: tabla aparte para cumplir la 3NF
CREATE TABLE categorias (
    id_categoria      INT            NOT NULL,
    nombre_categoria  VARCHAR(50)    NOT NULL,
    descripcion       VARCHAR(200)
);

-- Clientes
CREATE TABLE clientes (
    id_cliente        INT            NOT NULL,
    nombre            VARCHAR(100)   NOT NULL,
    email             VARCHAR(100),
    ciudad            VARCHAR(50),
    fecha_registro    DATE           NOT NULL
);

-- Productos (activo usa BIT, el equivalente de TINYINT(1) en SQL Server)
CREATE TABLE productos (
    id_producto       INT            NOT NULL,
    nombre_producto   VARCHAR(100)   NOT NULL,
    id_categoria      INT            NOT NULL,
    precio            DECIMAL(10,2)  NOT NULL,
    stock             INT            DEFAULT 0,
    activo            BIT            DEFAULT 1
);

-- Ventas (tabla de hechos): conecta clientes y productos
CREATE TABLE ventas (
    id_venta          INT            NOT NULL,
    id_cliente        INT            NOT NULL,
    id_producto       INT            NOT NULL,
    cantidad          INT            NOT NULL,
    precio_unitario   DECIMAL(10,2)  NOT NULL,
    fecha_venta       DATE           NOT NULL
);


/* =====================================================================
   PASO 2 - SECCIÓN 2 - RESTRICCIONES DE INTEGRIDAD
   - PRIMARY KEY en cada tabla.
   - FOREIGN KEY en productos y ventas (integridad referencial:
     no se puede vender un producto o a un cliente que no existe).
   - UNIQUE en el email de clientes.
   - NOT NULL en campos críticos (precio, nombre, fechas, cantidades),
     definido en la Sección 1 junto a cada columna.
   ===================================================================== */

-- Claves primarias
ALTER TABLE categorias ADD CONSTRAINT PK_categorias PRIMARY KEY (id_categoria);
ALTER TABLE clientes   ADD CONSTRAINT PK_clientes   PRIMARY KEY (id_cliente);
ALTER TABLE productos  ADD CONSTRAINT PK_productos  PRIMARY KEY (id_producto);
ALTER TABLE ventas     ADD CONSTRAINT PK_ventas     PRIMARY KEY (id_venta);

-- Email único por cliente
ALTER TABLE clientes ADD CONSTRAINT UQ_clientes_email UNIQUE (email);

-- Claves foráneas
ALTER TABLE productos ADD CONSTRAINT FK_productos_categorias
    FOREIGN KEY (id_categoria) REFERENCES categorias (id_categoria);

ALTER TABLE ventas ADD CONSTRAINT FK_ventas_clientes
    FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente);

ALTER TABLE ventas ADD CONSTRAINT FK_ventas_productos
    FOREIGN KEY (id_producto) REFERENCES productos (id_producto);


/* =====================================================================
   PASO 2 - SECCIÓN 3 - CARGA INICIAL DE DATOS (DML)
   Orden: primero las tablas sin dependencias (categorias, clientes),
   después productos y al final ventas. Total: 25 registros.
   ===================================================================== */

-- Categorías: 4 registros
INSERT INTO categorias VALUES (1, 'Computación', 'Laptops, PCs y monitores');
INSERT INTO categorias VALUES (2, 'Accesorios', 'Periféricos y complementos');
INSERT INTO categorias VALUES (3, 'Audio', 'Auriculares y parlantes');
INSERT INTO categorias VALUES (4, 'Almacenamiento', 'Discos y memorias');

-- Clientes: 5 registros
INSERT INTO clientes VALUES (1, 'María López', 'maria@mail.com', 'Buenos Aires', '2024-01-05');
INSERT INTO clientes VALUES (2, 'Carlos Ruiz', 'carlos@mail.com', 'Córdoba', '2024-01-10');
INSERT INTO clientes VALUES (3, 'Ana Gómez', 'ana@mail.com', 'Rosario', '2024-02-01');
INSERT INTO clientes VALUES (4, 'Pedro Sanz', 'pedro@mail.com', 'Mendoza', '2024-02-15');
INSERT INTO clientes VALUES (5, 'Laura Torres', 'laura@mail.com', 'Tucumán', '2024-03-01');

-- Productos: 6 registros
INSERT INTO productos VALUES (1, 'Laptop Pro 15', 1, 1200.00, 15, 1);
INSERT INTO productos VALUES (2, 'Mouse Inalámbrico', 2, 28.00, 80, 1);
INSERT INTO productos VALUES (3, 'Monitor 4K 27"', 1, 450.00, 12, 1);
INSERT INTO productos VALUES (4, 'Auriculares BT Pro', 3, 120.00, 35, 1);
INSERT INTO productos VALUES (5, 'SSD Externo 1TB', 4, 130.00, 18, 1);
INSERT INTO productos VALUES (6, 'Teclado Mecánico', 2, 95.00, 40, 1);

-- Ventas: 10 registros
INSERT INTO ventas VALUES (1, 1, 1, 2, 1200.00, '2024-03-05');
INSERT INTO ventas VALUES (2, 2, 2, 5, 28.00, '2024-03-06');
INSERT INTO ventas VALUES (3, 3, 3, 1, 450.00, '2024-03-07');
INSERT INTO ventas VALUES (4, 1, 4, 2, 120.00, '2024-03-08');
INSERT INTO ventas VALUES (5, 4, 5, 3, 130.00, '2024-03-10');
INSERT INTO ventas VALUES (6, 2, 6, 4, 95.00, '2024-03-11');
INSERT INTO ventas VALUES (7, 5, 1, 1, 1200.00, '2024-03-12');
INSERT INTO ventas VALUES (8, 3, 2, 8, 28.00, '2024-03-13');
INSERT INTO ventas VALUES (9, 4, 4, 1, 120.00, '2024-03-14');
INSERT INTO ventas VALUES (10, 5, 3, 2, 450.00, '2024-03-15');


/* =====================================================================
   PASO 3 - VERIFICACIÓN DE LA INTEGRIDAD
   Confirma que cada tabla se cargó correctamente.
   Resultado esperado: 4 categorías, 5 clientes, 6 productos, 10 ventas.
   ===================================================================== */
SELECT * FROM categorias;
SELECT * FROM clientes;
SELECT * FROM productos;
SELECT * FROM ventas;

/* Prueba de integridad referencial (opcional).
   Si se quita el comentario, este INSERT debe FALLAR con un error de
   FOREIGN KEY, porque el cliente 99 no existe.

INSERT INTO ventas VALUES (11, 99, 1, 1, 1200.00, '2024-03-20');
*/