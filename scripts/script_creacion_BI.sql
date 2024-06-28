-- Dimensión Tiempo
CREATE TABLE BI_Dim_Tiempo (
    id_tiempo VARCHAR(20) PRIMARY KEY,
    anio CHAR(4),
    mes CHAR(2),
    cuatrimestre CHAR(1)
);

-- Dimensión Provincia
CREATE TABLE BI_Dim_Provincia (
    id_provincia VARCHAR(60) PRIMARY KEY
);

-- Dimensión Localidad
CREATE TABLE BI_Dim_Localidad (
    id_localidad VARCHAR(110) PRIMARY KEY,
    localidad_provincia_id VARCHAR(60) FOREIGN KEY REFERENCES BI_Dim_Provincia(id_provincia),
    localidad_nombre VARCHAR(50)
);

-- Dimensión Sucursal
CREATE TABLE BI_Dim_Sucursal (
    id_sucursal DECIMAL(6,0) PRIMARY KEY,
    sucursal_localidad_id VARCHAR(110) FOREIGN KEY REFERENCES BI_Dim_Localidad(id_localidad),
    sucursal_direccion VARCHAR(50)
);

-- Dimensión Rango Etario
CREATE TABLE BI_Dim_Rango_Etario (
    id_rango_etario DECIMAL(2,0) PRIMARY KEY,
    descripcion VARCHAR(50)
);

-- Dimensión Turnos
CREATE TABLE BI_Dim_Turno (
    id_turno DECIMAL(6,0) PRIMARY KEY,
    hora_inicio DATETIME,
    hora_fin DATETIME
);

-- Dimensión Medio de Pago
CREATE TABLE BI_Dim_Medio_Pago (
    id_medio_pago VARCHAR(50) PRIMARY KEY,
    tipo VARCHAR(30)
);

-- Dimensión Categoría de Productos
CREATE TABLE BI_Dim_Categoria (
    id_categoria DECIMAL(8,0) PRIMARY KEY
);

-- Dimensión Ticket
CREATE TABLE BI_Dim_Ticket (
    id_ticket VARCHAR(50) PRIMARY KEY,
    numero_ticket DECIMAL(18,0),
    tipo_ticket CHAR(1),
	sucursal_id DECIMAL(6,0) FOREIGN KEY REFERENCES BI_Dim_Sucursal(id_sucursal)
);

-- Dimensión Caja
CREATE TABLE BI_Dim_Caja (
    id_caja VARCHAR(100) PRIMARY KEY,
    numero_caja DECIMAL(3,0),
    tipo_caja VARCHAR(50)
);

-- Tabla de Hechos Ventas
CREATE TABLE BI_Fact_Ventas (
    id_tiempo VARCHAR(20) FOREIGN KEY REFERENCES BI_Dim_Tiempo(id_tiempo),
    id_sucursal DECIMAL(6,0) FOREIGN KEY REFERENCES BI_Dim_Sucursal(id_sucursal),
    id_rango_etario DECIMAL(2,0) FOREIGN KEY REFERENCES BI_Dim_Rango_Etario(id_rango_etario),
    id_turno DECIMAL(6,0) FOREIGN KEY REFERENCES BI_Dim_Turno(id_turno),
    id_medio_pago VARCHAR(50) FOREIGN KEY REFERENCES BI_Dim_Medio_Pago(id_medio_pago),
    id_categoria DECIMAL(8,0) FOREIGN KEY REFERENCES BI_Dim_Categoria(id_categoria),
    id_ticket VARCHAR(50) FOREIGN KEY REFERENCES BI_Dim_Ticket(id_ticket),
    id_caja VARCHAR(100) FOREIGN KEY REFERENCES BI_Dim_Caja(id_caja),
    importe_total DECIMAL(12,2),
    cantidad_unidades DECIMAL(12,0),
    PRIMARY KEY (id_tiempo, id_sucursal, id_rango_etario, id_turno, id_medio_pago, id_categoria, id_ticket, id_caja)
);

-- Tabla de Hechos Descuentos
CREATE TABLE BI_Fact_Descuento (
    id_ticket VARCHAR(50) FOREIGN KEY REFERENCES BI_Dim_Ticket(id_ticket),
    id_categoria DECIMAL(8,0) FOREIGN KEY REFERENCES BI_Dim_Categoria(id_categoria),
    id_tiempo VARCHAR(20) FOREIGN KEY REFERENCES BI_Dim_Tiempo(id_tiempo),
    id_medio_pago VARCHAR(50) FOREIGN KEY REFERENCES BI_Dim_Medio_Pago(id_medio_pago),
    monto_descuento DECIMAL(12,2),
    tipo_descuento VARCHAR(30),
    PRIMARY KEY (id_ticket, id_categoria, id_tiempo, id_medio_pago)
);

-- Tabla de Hechos Envíos
CREATE TABLE BI_Fact_Envio (
    id_tiempo VARCHAR(20) FOREIGN KEY REFERENCES BI_Dim_Tiempo(id_tiempo),
    id_sucursal DECIMAL(6,0) FOREIGN KEY REFERENCES BI_Dim_Sucursal(id_sucursal),
    id_rango_etario DECIMAL(2,0) FOREIGN KEY REFERENCES BI_Dim_Rango_Etario(id_rango_etario),
    costo_envio_total DECIMAL(12,2),
    cantidad_envios INT,
    envios_cumplidos INT,
    PRIMARY KEY (id_tiempo, id_sucursal, id_rango_etario)
);
-- Tabla de Hechos Cuotas
CREATE TABLE BI_Fact_Cuotas (
    id_ticket VARCHAR(50) FOREIGN KEY REFERENCES BI_Dim_Ticket(id_ticket),
    id_tiempo VARCHAR(20) FOREIGN KEY REFERENCES BI_Dim_Tiempo(id_tiempo),
    id_sucursal DECIMAL(6,0) FOREIGN KEY REFERENCES BI_Dim_Sucursal(id_sucursal),
    id_rango_etario DECIMAL(2,0) FOREIGN KEY REFERENCES BI_Dim_Rango_Etario(id_rango_etario),
    id_medio_pago VARCHAR(50) FOREIGN KEY REFERENCES BI_Dim_Medio_Pago(id_medio_pago),
    numero_cuotas INT,
    importe_cuota DECIMAL(12,2),
    importe_total DECIMAL(12,2),
    PRIMARY KEY (id_ticket, id_tiempo, id_sucursal, id_rango_etario, id_medio_pago)
);

-- Poblar las dimensiones (ejemplo para Dim_Tiempo)
INSERT INTO BI_Dim_Tiempo (id_tiempo, anio, mes, cuatrimestre)
SELECT DISTINCT
    CONCAT(YEAR(tick_fecha_hora), RIGHT('0' + CAST(MONTH(tick_fecha_hora) AS VARCHAR(2)), 2)) as id_tiempo,
    CAST(YEAR(tick_fecha_hora) AS CHAR(4)) as anio,
    RIGHT('0' + CAST(MONTH(tick_fecha_hora) AS VARCHAR(2)), 2) as mes,
    CASE
        WHEN MONTH(tick_fecha_hora) BETWEEN 1 AND 4 THEN '1'
        WHEN MONTH(tick_fecha_hora) BETWEEN 5 AND 8 THEN '2'
        ELSE '3'
    END as cuatrimestre
FROM MASTER_COOKS.Ticket;

-- Poblar Dim_Provincia
INSERT INTO BI_Dim_Provincia (id_provincia)
SELECT DISTINCT prov_nombre
FROM MASTER_COOKS.Provincia;

-- Poblar Dim_Localidad
INSERT INTO BI_Dim_Localidad (id_localidad, localidad_provincia_id, localidad_nombre)
SELECT DISTINCT
    CONCAT(l.loca_provincia_id, l.loca_nombre) as id_localidad,
    l.loca_provincia_id,
    l.loca_nombre
FROM MASTER_COOKS.Localidad l;

-- Poblar Dim_Sucursal
INSERT INTO BI_Dim_Sucursal (id_sucursal, sucursal_localidad_id, sucursal_direccion)
SELECT DISTINCT
    s.sucu_numero,
    CONCAT(s.sucu_provincia_id, s.sucu_localidad_id) as sucursal_localidad_id,
    s.sucu_direccion
FROM MASTER_COOKS.Sucursal s;

-- Poblar Dim_Rango_Etario
INSERT INTO BI_Dim_Rango_Etario (id_rango_etario, descripcion)
VALUES
(1, 'Menor a 25'),
(2, 'Entre 25 y 35'),
(3, 'Entre 35 y 50'),
(4, 'Mayor a 50');

-- Poblar Dim_Turno
INSERT INTO BI_Dim_Turno (id_turno, hora_inicio, hora_fin)
VALUES
(1, '08:00:00', '12:00:00'),
(2, '12:00:00', '16:00:00'),
(3, '16:00:00', '20:00:00');

-- Poblar Dim_Medio_Pago
INSERT INTO BI_Dim_Medio_Pago (id_medio_pago, tipo)
SELECT DISTINCT medi_descripcion, medi_tipo
FROM MASTER_COOKS.Medio_De_Pago;

-- Poblar Dim_Categoria
INSERT INTO BI_Dim_Categoria (id_categoria)
SELECT DISTINCT cate_codigo
FROM MASTER_COOKS.Categoria;

-- Poblar Dim_Ticket
INSERT INTO BI_Dim_Ticket (id_ticket, numero_ticket, tipo_ticket, sucursal_id)
SELECT DISTINCT
    CONCAT(tick_numero, tick_tipo, tick_sucursal_id) as id_ticket,
    tick_numero,
    tick_tipo,
	tick_sucursal_id
FROM MASTER_COOKS.Ticket;

-- Poblar Dim_Caja
INSERT INTO BI_Dim_Caja (id_caja, numero_caja, tipo_caja)
SELECT DISTINCT
    CONCAT(tick_caja_numero, caja_tipo_id) as id_caja,
    tick_caja_numero,
    caja_tipo_id
FROM MASTER_COOKS.Ticket
JOIN MASTER_COOKS.Caja on caja_sucursal_id = tick_sucursal_id AND tick_caja_numero = caja_numero

--Poblar Fact_Ventas
INSERT INTO BI_Fact_Ventas (id_tiempo, id_sucursal, id_rango_etario, id_turno, id_medio_pago, id_categoria, id_ticket, id_caja, importe_total, cantidad_unidades)
SELECT DISTINCT
    CONCAT(YEAR(t.tick_fecha_hora), RIGHT('0' + CAST(MONTH(t.tick_fecha_hora) AS VARCHAR(2)), 2)) as id_tiempo,
    t.tick_sucursal_id,
    CASE
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) < 25 THEN 1
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) BETWEEN 25 AND 35 THEN 2
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) BETWEEN 35 AND 50 THEN 3
        ELSE 4
    END as id_rango_etario,
    CASE
        WHEN DATEPART(HOUR, t.tick_fecha_hora) BETWEEN 8 AND 12 THEN 1
        WHEN DATEPART(HOUR, t.tick_fecha_hora) BETWEEN 12 AND 16 THEN 2
        ELSE 3
    END as id_turno,
    p.pago_medio_de_pago_id,
    cxs.catx_categoria_id as id_categoria,
    CONCAT(t.tick_numero, t.tick_tipo, t.tick_sucursal_id) as id_ticket,
    CONCAT(t.tick_caja_numero, caja.caja_tipo_id) as id_caja,
    t.tick_total as importe_total,
    SUM(it.item_cantidad) as cantidad_unidades
FROM MASTER_COOKS.Ticket t
JOIN MASTER_COOKS.Cliente c ON t.tick_cliente_documento = c.clie_documento AND t.tick_cliente_apellido = c.clie_apellido
JOIN MASTER_COOKS.Item_Ticket it ON t.tick_numero = it.item_ticket_numero AND t.tick_tipo = it.item_tipo_id AND t.tick_sucursal_id = it.item_sucursal_id
JOIN MASTER_COOKS.Producto_X_Subcategoria pxs ON it.item_producto_codigo = pxs.prodx_producto_codigo AND it.item_producto_precio = pxs.prodx_producto_precio
JOIN MASTER_COOKS.Categoria_X_Subcategoria cxs ON pxs.prodx_subcategoria_id = cxs.catx_subcategoria_id
JOIN MASTER_COOKS.Pago p ON t.tick_numero = p.pago_ticket_numero AND t.tick_tipo = p.pago_ticket_tipo AND t.tick_sucursal_id = p.pago_ticket_sucursal
JOIN MASTER_COOKS.Caja caja on caja.caja_sucursal_id = t.tick_sucursal_id AND t.tick_caja_numero = caja.caja_numero
GROUP BY YEAR(t.tick_fecha_hora), MONTH(t.tick_fecha_hora), t.tick_sucursal_id, c.clie_fecha_nacimiento, t.tick_fecha_hora, p.pago_medio_de_pago_id, cxs.catx_categoria_id, t.tick_numero, t.tick_tipo, t.tick_sucursal_id, t.tick_caja_numero, caja.caja_tipo_id, t.tick_total;

-- Poblar Fact_Descuento
INSERT INTO BI_Fact_Descuento (id_ticket, id_categoria, id_tiempo, id_medio_pago, monto_descuento, tipo_descuento)
SELECT 
    CONCAT(t.tick_numero, t.tick_tipo, t.tick_sucursal_id) as id_ticket,
    cxs.catx_categoria_id as id_categoria,
    CONCAT(YEAR(t.tick_fecha_hora), RIGHT('0' + CAST(MONTH(t.tick_fecha_hora) AS VARCHAR(2)), 2)) as id_tiempo,
    p.pago_medio_de_pago_id,
    SUM(t.tick_total_descuento_promocion + t.tick_total_descuento_aplicado_mp) as monto_descuento,
    CASE
        WHEN SUM(t.tick_total_descuento_promocion) > 0 AND SUM(t.tick_total_descuento_aplicado_mp) > 0 THEN 'Promoción y Medio de Pago'
        WHEN SUM(t.tick_total_descuento_promocion) > 0 THEN 'Promoción'
        WHEN SUM(t.tick_total_descuento_aplicado_mp) > 0 THEN 'Medio de Pago'
        ELSE 'Sin Descuento'
    END as tipo_descuento
FROM MASTER_COOKS.Ticket t
JOIN MASTER_COOKS.Item_Ticket it ON t.tick_numero = it.item_ticket_numero AND t.tick_tipo = it.item_tipo_id AND t.tick_sucursal_id = it.item_sucursal_id
JOIN MASTER_COOKS.Producto_X_Subcategoria pxs ON it.item_producto_codigo = pxs.prodx_producto_codigo AND it.item_producto_precio = pxs.prodx_producto_precio
JOIN MASTER_COOKS.Categoria_X_Subcategoria cxs ON pxs.prodx_subcategoria_id = cxs.catx_subcategoria_id
JOIN MASTER_COOKS.Pago p ON t.tick_numero = p.pago_ticket_numero AND t.tick_tipo = p.pago_ticket_tipo AND t.tick_sucursal_id = p.pago_ticket_sucursal
WHERE t.tick_total_descuento_promocion > 0 OR t.tick_total_descuento_aplicado_mp > 0
GROUP BY 
    t.tick_numero, t.tick_tipo, t.tick_sucursal_id, 
    cxs.catx_categoria_id, 
    YEAR(t.tick_fecha_hora), MONTH(t.tick_fecha_hora),
    p.pago_medio_de_pago_id;

-- Poblar Fact_Envio
INSERT INTO BI_Fact_Envio (id_tiempo, id_sucursal, id_rango_etario, costo_envio_total, cantidad_envios, envios_cumplidos)
SELECT 
    CONCAT(YEAR(t.tick_fecha_hora), RIGHT('0' + CAST(MONTH(t.tick_fecha_hora) AS VARCHAR(2)), 2)) as id_tiempo,
    e.envi_ticket_sucursal as id_sucursal,
    CASE
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) < 25 THEN 1
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) BETWEEN 25 AND 35 THEN 2
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) BETWEEN 35 AND 50 THEN 3
        ELSE 4
    END as id_rango_etario,
    SUM(e.envi_costo) as costo_envio_total,
    COUNT(*) as cantidad_envios,
    SUM(CASE WHEN e.envi_fecha_hora_entrega is not null THEN 1 ELSE 0 END) as envios_cumplidos
FROM MASTER_COOKS.Envio e
JOIN MASTER_COOKS.Ticket t ON e.envi_ticket_numero = t.tick_numero AND e.envi_ticket_tipo = t.tick_tipo AND e.envi_ticket_sucursal = t.tick_sucursal_id
JOIN MASTER_COOKS.Cliente c ON t.tick_cliente_documento = c.clie_documento AND t.tick_cliente_apellido = c.clie_apellido
GROUP BY 
    CONCAT(YEAR(t.tick_fecha_hora), RIGHT('0' + CAST(MONTH(t.tick_fecha_hora) AS VARCHAR(2)), 2)),
    e.envi_ticket_sucursal,
    CASE
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) < 25 THEN 1
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) BETWEEN 25 AND 35 THEN 2
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) BETWEEN 35 AND 50 THEN 3
        ELSE 4
    END;

-- Poblar Fact_Cuotas
INSERT INTO BI_Fact_Cuotas (id_ticket, id_tiempo, id_sucursal, id_rango_etario, id_medio_pago, numero_cuotas, importe_cuota, importe_total)
SELECT 
    CONCAT(t.tick_numero, t.tick_tipo, t.tick_sucursal_id) as id_ticket,
    CONCAT(YEAR(t.tick_fecha_hora), RIGHT('0' + CAST(MONTH(t.tick_fecha_hora) AS VARCHAR(2)), 2)) as id_tiempo,
    t.tick_sucursal_id,
    CASE
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) < 25 THEN 1
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) BETWEEN 25 AND 35 THEN 2
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) BETWEEN 35 AND 50 THEN 3
        ELSE 4
    END as id_rango_etario,
    p.pago_medio_de_pago_id,
    MAX(dp.deta_cuotas) as numero_cuotas,
    AVG(p.pago_importe/dp.deta_cuotas) as importe_cuota,
    SUM(p.pago_importe) as importe_total
FROM MASTER_COOKS.Ticket t
JOIN MASTER_COOKS.Cliente c ON t.tick_cliente_documento = c.clie_documento AND t.tick_cliente_apellido = c.clie_apellido
JOIN MASTER_COOKS.Pago p ON t.tick_numero = p.pago_ticket_numero AND t.tick_tipo = p.pago_ticket_tipo AND t.tick_sucursal_id = p.pago_ticket_sucursal
JOIN MASTER_COOKS.Detalle_Pago dp ON p.pago_id = dp.deta_pago_id
WHERE dp.deta_cuotas > 1
GROUP BY 
    CONCAT(t.tick_numero, t.tick_tipo, t.tick_sucursal_id),
    CONCAT(YEAR(t.tick_fecha_hora), RIGHT('0' + CAST(MONTH(t.tick_fecha_hora) AS VARCHAR(2)), 2)),
    t.tick_sucursal_id,
    CASE
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) < 25 THEN 1
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) BETWEEN 25 AND 35 THEN 2
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) BETWEEN 35 AND 50 THEN 3
        ELSE 4
    END,
    p.pago_medio_de_pago_id;

-- Crear vistas
GO
-- 1. Ticket Promedio mensual
CREATE VIEW BI_VW_TicketPromedioMensual AS
SELECT 
    dt.anio,
    dt.mes,
    dl.localidad_nombre,
    AVG(fv.importe_total) AS ticket_promedio
FROM BI_Fact_Ventas fv
JOIN BI_Dim_Tiempo dt ON fv.id_tiempo = dt.id_tiempo
JOIN BI_Dim_Sucursal ds ON fv.id_sucursal = ds.id_sucursal
JOIN BI_Dim_Localidad dl ON ds.sucursal_localidad_id = dl.id_localidad
GROUP BY dt.anio, dt.mes, dl.localidad_nombre;
GO
-- 2. Cantidad unidades promedio
CREATE VIEW BI_VW_UnidadesPromedioPorTurno AS
SELECT
    dt.anio,
    dt.cuatrimestre,
    dtur.id_turno,
    AVG(CAST(fv.cantidad_unidades AS FLOAT)) AS unidades_promedio
FROM BI_Fact_Ventas fv
JOIN BI_Dim_Tiempo dt ON fv.id_tiempo = dt.id_tiempo
JOIN BI_Dim_Turno dtur ON fv.id_turno = dtur.id_turno
GROUP BY dt.anio, dt.cuatrimestre, dtur.id_turno;
GO
-- 3. Porcentaje anual de ventas por rango etario del cliente y tipo de caja
CREATE VIEW BI_VW_PorcentajeVentasRangoEtarioCliente AS
SELECT
    dt.anio,
    dt.cuatrimestre,
    dre.descripcion AS rango_etario_cliente,
    dc.tipo_caja,
    COUNT(*) * 100.0 / (SELECT COUNT(*) from BI_Fact_Ventas) AS porcentaje_ventas
FROM
    BI_Fact_Ventas fv
JOIN
    BI_Dim_Tiempo dt ON fv.id_tiempo = dt.id_tiempo
JOIN
    BI_Dim_Rango_Etario dre ON fv.id_rango_etario = dre.id_rango_etario
JOIN
    BI_Dim_Caja dc ON fv.id_caja = dc.id_caja
GROUP BY
    dt.anio, dt.cuatrimestre, dre.descripcion, dc.tipo_caja;
GO

-- 4. Cantidad de ventas por turno y localidad
CREATE VIEW BI_VW_VentasPorTurnoLocalidad AS
SELECT
    dt.anio,
    dt.mes,
    dtur.id_turno,
    dl.localidad_nombre,
    COUNT(*) AS cantidad_ventas
FROM BI_Fact_Ventas fv
JOIN BI_Dim_Tiempo dt ON fv.id_tiempo = dt.id_tiempo
JOIN BI_Dim_Turno dtur ON fv.id_turno = dtur.id_turno
JOIN BI_Dim_Sucursal ds ON fv.id_sucursal = ds.id_sucursal
JOIN BI_Dim_Localidad dl ON ds.sucursal_localidad_id = dl.id_localidad
GROUP BY dt.anio, dt.mes, dtur.id_turno, dl.localidad_nombre;
GO
-- 5. Porcentaje de descuento aplicado
CREATE VIEW BI_VW_PorcentajeDescuentoAplicado AS
SELECT
    dt.anio,
    dt.mes,
    SUM(fv.importe_total) / SUM(fd.monto_descuento) * 100.0  AS porcentaje_descuento
FROM BI_Fact_Descuento fd
JOIN BI_Dim_Tiempo dt ON fd.id_tiempo = dt.id_tiempo
JOIN BI_Fact_Ventas fv ON fd.id_ticket = fv.id_ticket AND fd.id_tiempo = fv.id_tiempo
GROUP BY dt.anio, dt.mes;
GO

-- 6. Las tres categorías de productos con mayor descuento aplicado
CREATE VIEW BI_VW_TopCategoriasDescuento AS
WITH CategoriaDescuento AS (
    SELECT
        dt.anio,
        dt.cuatrimestre,
        dc.id_categoria,
        SUM(fd.monto_descuento) AS total_descuento,
        ROW_NUMBER() OVER (PARTITION BY dt.anio, dt.cuatrimestre ORDER BY SUM(fd.monto_descuento) DESC) AS rn
    FROM BI_Fact_Descuento fd
    JOIN BI_Dim_Tiempo dt ON fd.id_tiempo = dt.id_tiempo
    JOIN BI_Dim_Categoria dc ON fd.id_categoria = dc.id_categoria
    GROUP BY dt.anio, dt.cuatrimestre, dc.id_categoria
)
SELECT anio, cuatrimestre, id_categoria, total_descuento
FROM CategoriaDescuento
WHERE rn <= 3;
GO
-- 7. Porcentaje de cumplimiento de envíos
CREATE VIEW BI_VW_CumplimientoEnvios AS
SELECT
    dt.anio,
    dt.mes,
    fe.id_sucursal,
    CAST(fe.envios_cumplidos AS FLOAT) / CAST(fe.cantidad_envios AS FLOAT) * 100 AS porcentaje_cumplimiento
FROM BI_Fact_Envio fe
JOIN BI_Dim_Tiempo dt ON fe.id_tiempo = dt.id_tiempo
GROUP BY dt.anio, dt.mes, fe.id_sucursal, CAST(fe.envios_cumplidos AS FLOAT) / CAST(fe.cantidad_envios AS FLOAT)
GO
-- 8. Cantidad de envíos por rango etario de clientes
CREATE VIEW BI_VW_EnviosPorRangoEtario AS
SELECT
    dt.anio,
    dt.cuatrimestre,
    dre.descripcion AS rango_etario,
    sum(fe.cantidad_envios) AS cantidad_envios
FROM BI_Fact_Envio fe
JOIN BI_Dim_Tiempo dt ON fe.id_tiempo = dt.id_tiempo
JOIN BI_Dim_Rango_Etario dre ON fe.id_rango_etario = dre.id_rango_etario
GROUP BY dt.anio, dt.cuatrimestre, dre.descripcion;
GO
-- 9. Las 5 localidades con mayor costo de envío
CREATE VIEW BI_VW_Top5LocalidadesCostoEnvio AS
WITH LocalidadCostoEnvio AS (
    SELECT
        dl.localidad_nombre,
        SUM(fe.costo_envio_total) AS total_costo_envio,
        ROW_NUMBER() OVER (ORDER BY SUM(fe.costo_envio_total) DESC) AS rn
    FROM BI_Fact_Envio fe
    JOIN BI_Dim_Sucursal ds ON fe.id_sucursal = ds.id_sucursal
    JOIN BI_Dim_Localidad dl ON ds.sucursal_localidad_id = dl.id_localidad
    GROUP BY dl.localidad_nombre
)
SELECT localidad_nombre, total_costo_envio
FROM LocalidadCostoEnvio
WHERE rn <= 5;
GO
-- 10. Las 3 sucursales con el mayor importe de pagos en cuotas
CREATE VIEW BI_VW_Top3SucursalesPagosCuotas AS
SELECT TOP 3
        dt.anio,
        dt.mes,
        fc.id_sucursal,
        dmp.id_medio_pago,
        SUM(fc.importe_total) AS total_pagos_cuotas
    FROM BI_Fact_Cuotas fc
    JOIN BI_Dim_Tiempo dt ON fc.id_tiempo = dt.id_tiempo
    JOIN BI_Dim_Medio_Pago dmp ON fc.id_medio_pago = dmp.id_medio_pago
    WHERE fc.numero_cuotas > 1
    GROUP BY dt.anio, dt.mes, fc.id_sucursal, dmp.id_medio_pago, fc.numero_cuotas
	order by total_pagos_cuotas DESC
GO
-- 11. Promedio de importe de la cuota en función del rango etareo del cliente
CREATE VIEW BI_VW_PromedioImporteCuotaPorRangoEtario AS
SELECT
    dre.descripcion AS rango_etario,
    AVG(fc.importe_cuota) AS promedio_importe_cuota
FROM BI_Fact_Cuotas fc
JOIN BI_Dim_Rango_Etario dre ON fc.id_rango_etario = dre.id_rango_etario
GROUP BY dre.descripcion;
GO

-- 12. Porcentaje de descuento aplicado por cada medio de pago
CREATE VIEW BI_VW_PorcentajeDescuentoPorMedioPago AS
SELECT
    dt.anio,
    dt.cuatrimestre,
    dmp.id_medio_pago,
    100 - (SUM(fd.monto_descuento) / (SUM(fv.importe_total) + SUM(fd.monto_descuento)) * 100) AS porcentaje_descuento
FROM BI_Fact_Descuento fd
JOIN BI_Dim_Tiempo dt ON fd.id_tiempo = dt.id_tiempo
JOIN BI_Dim_Medio_Pago dmp ON fd.id_medio_pago = dmp.id_medio_pago
JOIN BI_Fact_Ventas fv ON fd.id_ticket = fv.id_ticket AND fd.id_tiempo = fv.id_tiempo
GROUP BY dt.anio, dt.cuatrimestre, dmp.id_medio_pago;
GO


SELECT * FROM dbo.BI_VW_CumplimientoEnvios --PARECE QUE ESTA TODO OK chequeado en partida doble
SELECT * FROM [dbo].[BI_VW_EnviosPorRangoEtario] --PARECE TODO OK chequeado
SELECT * FROM [dbo].[BI_VW_PorcentajeDescuentoAplicado] --PARECE TODO OK chequeado
SELECT * FROM [dbo].[BI_VW_PorcentajeDescuentoPorMedioPago] --PARECE TODO OK chequeado
SELECT * FROM [dbo].[BI_VW_PorcentajeVentasRangoEtarioCliente] --PARECE TODO OK chequeado
SELECT * FROM [dbo].[BI_VW_PromedioImporteCuotaPorRangoEtario] --PARECE TODO OK chequeado
SELECT * FROM [dbo].[BI_VW_TicketPromedioMensual] --VER QUE ONDA QUE SIEMPRE ES LA MISMA LOCALIDAD (tal vez hay que tomar la localida del cliente y no de la sucursal, ya que todas las sucursales estan en la misma localidad anda a saber por que)
SELECT * FROM [dbo].[BI_VW_Top3SucursalesPagosCuotas] --PARECE TODO OK chequeado
SELECT * FROM [dbo].[BI_VW_Top5LocalidadesCostoEnvio] --SOLO TIRA UNA LOCALIDAD (tal vez hay que tomar la localida del cliente y no de la sucursal, ya que todas las sucursales estan en la misma localidad anda a saber por que)
SELECT * FROM [dbo].[BI_VW_TopCategoriasDescuento] --PARECE TODO OK
SELECT * FROM [dbo].[BI_VW_UnidadesPromedioPorTurno] --ver si hay que diferenciar por cuatrimestre tambien o solo por turno
SELECT * FROM [dbo].[BI_VW_VentasPorTurnoLocalidad] --SOLO SALE UNA LOCALIDAD (tal vez hay que tomar la localida del cliente y no de la sucursal, ya que todas las sucursales estan en la misma localidad anda a saber por que)
