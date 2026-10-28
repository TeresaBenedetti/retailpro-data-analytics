/* =====================================================================
   Pre-entrega M5: Consultas con JOINs

   Estructura del archivo:
     Paso 0 - Datos adicionales (mismo bloque que M4)
     Paso 1 - Consulta 1: Vista base del proyecto (INNER JOIN)
     Paso 2 - Consulta 2: Clientes sin ventas (LEFT JOIN)
     Paso 3 - Consulta 3: Productos sin ventas (LEFT JOIN)
     Paso 4 - Consulta 4: Consolidado por período (UNION ALL)

   Columnas para agrupar y filtrar en Power BI:
     El esquema de M3 tiene una dimensión geográfica (ciudad del cliente)
     y una de clasificación (categoría del producto). Por eso no fue
     necesario modificar el script de M3.
   ===================================================================== */

USE Ventas_Tech_DB;


/* =====================================================================
   PASO 0 - DATOS ADICIONALES
   Es el mismo bloque que el Paso 0 de M4 (ventas de enero, febrero y
   abril, un cliente sin compras y un producto sin ventas). Se repite
   para que este archivo funcione aunque se ejecute sin haber corrido M4.
   Primero borra los registros agregados, así se puede ejecutar varias
   veces sin errores. Las 25 filas originales de M3 no se modifican.
   ===================================================================== */
DELETE FROM ventas    WHERE id_venta    > 10;
DELETE FROM clientes  WHERE id_cliente  > 5;
DELETE FROM productos WHERE id_producto > 6;

INSERT INTO clientes VALUES (6, 'Sofía Herrera', 'sofia@mail.com', 'Neuquén', '2024-04-01');
INSERT INTO clientes VALUES (7, 'Martín Díaz', 'martin@mail.com', 'La Plata', '2024-04-05');

INSERT INTO productos VALUES (7, 'Webcam Full HD', 2, 65.00, 25, 1);

INSERT INTO ventas VALUES (11, 1, 2, 2, 28.00, '2024-01-12');
INSERT INTO ventas VALUES (12, 2, 6, 1, 95.00, '2024-01-20');
INSERT INTO ventas VALUES (13, 1, 5, 1, 130.00, '2024-01-28');
INSERT INTO ventas VALUES (14, 3, 4, 1, 120.00, '2024-02-05');
INSERT INTO ventas VALUES (15, 2, 1, 1, 1200.00, '2024-02-10');
INSERT INTO ventas VALUES (16, 4, 2, 3, 28.00, '2024-02-20');
INSERT INTO ventas VALUES (17, 1, 6, 1, 95.00, '2024-02-25');
INSERT INTO ventas VALUES (18, 5, 5, 2, 130.00, '2024-04-03');
INSERT INTO ventas VALUES (19, 6, 3, 1, 450.00, '2024-04-10');
INSERT INTO ventas VALUES (20, 3, 1, 1, 1200.00, '2024-04-18');
INSERT INTO ventas VALUES (21, 4, 6, 2, 95.00, '2024-04-25');


/* =====================================================================
   PASO 1 - CONSULTA 1: VISTA BASE DEL PROYECTO (INNER JOIN)
   Propósito: una fila por venta con toda la información del negocio.
   Es la fuente de datos principal para Power BI.
   Une las 4 tablas por sus claves foráneas:
     ventas.id_cliente    -> clientes.id_cliente
     ventas.id_producto   -> productos.id_producto
     productos.id_categoria -> categorias.id_categoria
   Para agrupar: nombre_categoria. Para filtrar: ciudad, fecha_venta.
   ===================================================================== */
SELECT
    v.id_venta,
    v.fecha_venta,
    c.id_cliente,
    c.nombre                          AS cliente,
    c.ciudad,
    p.nombre_producto                 AS producto,
    cat.nombre_categoria              AS categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario    AS total_venta
FROM ventas v
INNER JOIN clientes   c   ON v.id_cliente   = c.id_cliente
INNER JOIN productos  p   ON v.id_producto  = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta;

-- Hallazgos Consulta 1:
--   La vista devuelve las 21 ventas, cada una con su cliente, producto y
--   categoría. Al agrupar por categoría, Computación concentra el 76% de la
--   facturación ($7.800 de $10.324), impulsada por la Laptop Pro 15.
--   Audio es la categoría con menor facturación ($480).


/* =====================================================================
   PASO 2 - CONSULTA 2: CLIENTES SIN VENTAS (LEFT JOIN)
   Propósito: identificar clientes registrados que nunca compraron (CRM).
   El LEFT JOIN conserva todos los clientes; los que no tienen ventas
   quedan con las columnas de ventas en NULL y se aíslan con IS NULL.
   ===================================================================== */
SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;

-- Hallazgos Consulta 2:
--   Martín Díaz (La Plata), registrado el 05/04/2024, no realizó ninguna
--   compra. Es 1 de los 7 clientes registrados (14%). El área de CRM puede
--   contactarlo con una promoción de primera compra.


/* =====================================================================
   PASO 3 - CONSULTA 3: PRODUCTOS SIN VENTAS (LEFT JOIN)
   Propósito: identificar artículos del catálogo sin movimiento.
   Se une con categorias (INNER JOIN) para mostrar el nombre de la
   categoría, y con ventas (LEFT JOIN) para detectar los que no se vendieron.
   ===================================================================== */
SELECT
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos p
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v        ON p.id_producto  = v.id_producto
WHERE v.id_venta IS NULL;

-- Hallazgos Consulta 3:
--   La Webcam Full HD (Accesorios, $65) no registra ventas y tiene 25
--   unidades en stock. El área de producto puede evaluar una promoción
--   (por ejemplo, combo con la Laptop Pro 15) o revisar si conviene
--   mantenerla en el catálogo.


/* =====================================================================
   PASO 4 - CONSULTA 4: CONSOLIDADO POR PERÍODO (UNION ALL)
   Propósito: comparar la facturación de dos períodos.
   La tabla ventas no tiene una columna de canal, así que el origen se
   crea como valor fijo en cada SELECT:
     - 'Primer trimestre'  : ventas de enero a marzo de 2024
     - 'Segundo trimestre' : ventas desde abril de 2024
   Los dos SELECT devuelven las mismas 3 columnas, en el mismo orden y
   con los mismos tipos. Se usa UNION ALL (y no UNION) para que ninguna
   venta se elimine aunque coincida con otra en todos sus valores.
   Al final, GROUP BY calcula el total de cada período.
   ===================================================================== */
SELECT
    periodo,
    COUNT(*)   AS cantidad_pedidos,
    SUM(total) AS total_facturado
FROM (
    SELECT
        fecha_venta,
        cantidad * precio_unitario AS total,
        'Primer trimestre'         AS periodo
    FROM ventas
    WHERE fecha_venta < '2024-04-01'

    UNION ALL

    SELECT
        fecha_venta,
        cantidad * precio_unitario AS total,
        'Segundo trimestre'        AS periodo
    FROM ventas
    WHERE fecha_venta >= '2024-04-01'
) AS ventas_por_periodo
GROUP BY periodo;

-- Hallazgos Consulta 4:
--   El primer trimestre suma $8.224 en 17 pedidos y el segundo trimestre
--   (solo abril) $2.100 en 4 pedidos. Abril ya supera a enero ($281) y a
--   febrero ($1.499), pero queda muy por debajo de marzo ($6.444): hay que
--   sostener el ritmo de marzo para que el segundo trimestre alcance al primero.