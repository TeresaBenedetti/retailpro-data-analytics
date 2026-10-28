/* =====================================================================
   Pre-entrega M4: Consultas SQL de negocio
   
   Estructura del archivo:
     Paso 0 - Carga de datos adicionales
     Paso 1 - Consulta 1: Resumen ejecutivo mensual
     Paso 2 - Consulta 2: Ranking de productos (Top 5)
     Paso 3 - Consulta 3: Clientes recurrentes
     Paso 4 - Consulta 4: Meses por encima / por debajo del promedio
     Paso 5 - Hallazgos

   Adaptaciones a SQL Server respecto de la consigna:
     - EXTRACT(MONTH FROM fecha_venta) se reemplaza por MONTH(fecha_venta).
     - LIMIT 5 se reemplaza por TOP 5.
   ===================================================================== */

USE Ventas_Tech_DB;


/* =====================================================================
   PASO 0 - CARGA DE DATOS ADICIONALES

   ¿Por qué se agregan registros?
   Las 10 ventas cargadas en M3 son todas de marzo de 2024 y los 5
   clientes tienen exactamente 2 compras cada uno. Con esos datos:
     - Las consultas 1 y 4 devuelven un solo mes, por lo que no se
       puede comparar ningún mes contra el promedio.
     - La consulta 3 no distingue clientes recurrentes de clientes
       con una sola compra.
   Para que el análisis tenga sentido se agregan 11 ventas de enero,
   febrero y abril de 2024, un cliente con una sola compra (6), un
   cliente registrado sin compras (7) y un producto sin ventas (7).
   Estos dos últimos se usarán en M5 (clientes y productos sin ventas).
   Las 25 filas originales de M3 no se modifican.

   Para que el archivo se pueda ejecutar varias veces sin errores,
   primero se borran solo los registros agregados (si ya existen).
   ===================================================================== */

-- Limpieza de los registros agregados (orden: primero ventas por las FK)
DELETE FROM ventas    WHERE id_venta    > 10;
DELETE FROM clientes  WHERE id_cliente  > 5;
DELETE FROM productos WHERE id_producto > 6;

-- Clientes nuevos
INSERT INTO clientes VALUES (6, 'Sofía Herrera', 'sofia@mail.com', 'Neuquén', '2024-04-01');
INSERT INTO clientes VALUES (7, 'Martín Díaz', 'martin@mail.com', 'La Plata', '2024-04-05');

-- Producto nuevo (sin ventas)
INSERT INTO productos VALUES (7, 'Webcam Full HD', 2, 65.00, 25, 1);

-- Ventas de enero 2024
INSERT INTO ventas VALUES (11, 1, 2, 2, 28.00, '2024-01-12');
INSERT INTO ventas VALUES (12, 2, 6, 1, 95.00, '2024-01-20');
INSERT INTO ventas VALUES (13, 1, 5, 1, 130.00, '2024-01-28');

-- Ventas de febrero 2024
INSERT INTO ventas VALUES (14, 3, 4, 1, 120.00, '2024-02-05');
INSERT INTO ventas VALUES (15, 2, 1, 1, 1200.00, '2024-02-10');
INSERT INTO ventas VALUES (16, 4, 2, 3, 28.00, '2024-02-20');
INSERT INTO ventas VALUES (17, 1, 6, 1, 95.00, '2024-02-25');

-- Ventas de abril 2024
INSERT INTO ventas VALUES (18, 5, 5, 2, 130.00, '2024-04-03');
INSERT INTO ventas VALUES (19, 6, 3, 1, 450.00, '2024-04-10');
INSERT INTO ventas VALUES (20, 3, 1, 1, 1200.00, '2024-04-18');
INSERT INTO ventas VALUES (21, 4, 6, 2, 95.00, '2024-04-25');


/* =====================================================================
   PASO 1 - CONSULTA 1: RESUMEN EJECUTIVO MENSUAL
   Total facturado, cantidad de pedidos y ticket promedio por mes.
   Total de cada venta = cantidad * precio_unitario.
   ===================================================================== */
SELECT
    MONTH(fecha_venta)                                   AS mes,
    SUM(cantidad * precio_unitario)                      AS total_facturado,
    COUNT(*)                                             AS cantidad_pedidos,
    ROUND(SUM(cantidad * precio_unitario) / COUNT(*), 2) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;


/* =====================================================================
   PASO 2 - CONSULTA 2: RANKING DE PRODUCTOS (TOP 5)
   Los 5 productos con mayor facturación, con unidades vendidas.
   ===================================================================== */
SELECT TOP 5
    id_producto,
    SUM(cantidad)                   AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;


/* =====================================================================
   PASO 3 - CONSULTA 3: CLIENTES RECURRENTES
   Clientes con más de un pedido, con cantidad de pedidos y total gastado.
   ===================================================================== */
SELECT
    id_cliente,
    COUNT(*)                        AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;


/* =====================================================================
   PASO 4 - CONSULTA 4: MESES POR ENCIMA / POR DEBAJO DEL PROMEDIO
   Primero se calcula el total de cada mes (totales_mensuales).
   Después se compara cada mes con el promedio de esos totales.
   ===================================================================== */
WITH totales_mensuales AS (
    SELECT
        MONTH(fecha_venta)              AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
)
SELECT
    mes,
    total_facturado,
    CASE
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM totales_mensuales)
            THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion_promedio
FROM totales_mensuales
ORDER BY mes;


/* =====================================================================
   PASO 5 - HALLAZGOS
   ===================================================================== */
-- Hallazgo 1: El producto 1 (Laptop Pro 15) concentra el 58% de la facturación
--   total ($6.000 de $10.324) con solo 5 unidades vendidas. El negocio depende
--   de un producto de alto valor: cualquier caída en sus ventas impacta fuerte
--   en los ingresos. Conviene impulsar los productos 3 (Monitor 4K) y 5 (SSD)
--   para diversificar.
--
-- Hallazgo 2: Marzo es el único mes por encima del promedio mensual ($6.444
--   contra un promedio de $2.581) y explica el 62% de la facturación del
--   período. Enero fue el mes más bajo ($281, ticket promedio de $93,67).
--   Hay que investigar qué impulsó las ventas de marzo para repetirlo en el
--   resto de los meses.
--
-- Hallazgo 3: 5 de los 6 clientes que compraron son recurrentes. El cliente 1
--   es el de mayor valor ($2.921 en 5 pedidos), mientras que el cliente 6,
--   registrado en abril, tiene una sola compra ($450). Es el candidato para
--   una acción de retención (seguimiento o promoción) que lo lleve a una
--   segunda compra.
