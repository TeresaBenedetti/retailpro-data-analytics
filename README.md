# RetailPro | Proyecto de Data Analytics

Análisis de ventas de una distribuidora de tecnología con SQL Server y Power BI.

## Descripción del proyecto

RetailPro es el proyecto integrador del curso de Data Analytics. Su objetivo es transformar datos de ventas en información útil para la toma de decisiones comerciales, desde la creación de la base de datos hasta el modelado en Power BI.

**Pregunta de negocio:** ¿Por qué los clientes del segmento Premium, que tienen el ticket promedio más alto de RetailPro, compran con menor frecuencia que el resto, y qué categorías de producto y canales de venta explican que no vuelvan a comprar?

## Herramientas utilizadas

| Herramienta | Aplicación |
| --- | --- |
| SQL Server y SSMS | Creación de la base de datos y consultas SQL |
| Power BI Desktop | ETL, modelado de datos y visualización |
| Power Query (lenguaje M) | Limpieza y transformación de datos |
| DAX | Medidas e indicadores analíticos |
| GitHub | Versionado y documentación del proyecto |

## Estructura del repositorio

| Archivo / carpeta | Contenido |
| --- | --- |
| `m3_ventas_tech_db.sql` | Creación de la base `Ventas_Tech_DB`: tablas, claves primarias y foráneas, y carga inicial de datos |
| `m4_consultas_negocio.sql` | Resumen mensual, ranking de productos, clientes recurrentes y meses respecto del promedio |
| `m5_consultas_joins.sql` | Vista base con INNER JOIN, clientes y productos sin ventas (LEFT JOIN) y consolidado por período (UNION ALL) |
| `m6/` | Pipeline ETL en Power BI (.pbix) y README con las decisiones de limpieza |
| `m8/` | Modelo de datos con relaciones, tabla calendario y medidas DAX (.pbix) |

## Fuentes de datos

- **Módulos 3 a 5 (SQL):** base `Ventas_Tech_DB`, creada y cargada con el script de M3.
- **Módulos 6 y 8 (Power BI):** dataset `Pipeline_ETL_Dataset.xlsx` provisto por el curso (clientes, productos, categorías y 50 ventas de 2023 y 2024).

## Cómo ejecutar los scripts SQL

**Requisitos:** SQL Server y SQL Server Management Studio (SSMS).

1. Descargar los archivos `.sql` desde este repositorio (botón **Code → Download ZIP**, o abriendo cada archivo y usando **Download raw file**).
2. En SSMS, abrir y ejecutar **`m3_ventas_tech_db.sql`**. Crea la base `Ventas_Tech_DB` con sus 4 tablas y 25 registros.
3. Abrir y ejecutar **`m4_consultas_negocio.sql`**.
4. Abrir y ejecutar **`m5_consultas_joins.sql`**.

**Importante:**

- M3 siempre se ejecuta primero, porque M4 y M5 trabajan sobre la base que crea.
- Las 10 ventas de M3 son todas de marzo de 2024. Por eso **M4 y M5 empiezan con un bloque de datos adicionales** (ventas de enero, febrero y abril, un cliente sin compras y un producto sin ventas) que permite comparar meses y probar los LEFT JOIN. Ese bloque borra y vuelve a insertar sus propios registros, así que los scripts se pueden ejecutar varias veces sin errores.
