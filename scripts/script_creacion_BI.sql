-- Crear esquema BI si no existe
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'BI')
BEGIN
    EXEC('CREATE SCHEMA BI')
END
GO

-- Dimensión Tiempo
CREATE TABLE BI_Dim_Tiempo (
    id_tiempo INT IDENTITY(1,1) PRIMARY KEY,
    anio INT,
    cuatrimestre INT,
    mes INT
);

-- Dimensión Provincia
CREATE TABLE BI_Dim_Provincia (
    id_provincia INT IDENTITY(1,1) PRIMARY KEY,
    provincia VARCHAR(60)
);

-- Dimensión Localidad
CREATE TABLE BI_Dim_Localidad (
    id_localidad INT IDENTITY(1,1) PRIMARY KEY,
    localidad VARCHAR(50),
    id_provincia INT FOREIGN KEY REFERENCES BI_Dim_Provincia(id_provincia)
);

-- Dimensión Sucursal
CREATE TABLE BI_Dim_Sucursal (
    id_sucursal INT PRIMARY KEY,
    direccion VARCHAR(50),
    id_localidad INT FOREIGN KEY REFERENCES BI_Dim_Localidad(id_localidad)
);

-- Dimensión Rango Etario
CREATE TABLE BI_Dim_Rango_Etario (
    id_rango_etario INT IDENTITY(1,1) PRIMARY KEY,
    descripcion VARCHAR(20)
);

-- Dimensión Turnos
CREATE TABLE BI_Dim_Turno (
    id_turno INT IDENTITY(1,1) PRIMARY KEY,
    hora_inicio TIME,
    hora_fin TIME
);

-- Dimensión Medio de Pago
CREATE TABLE BI_Dim_Medio_Pago (
    id_medio_pago INT IDENTITY(1,1) PRIMARY KEY,
    descripcion NVARCHAR(50),
    tipo NVARCHAR(30)
);

-- Dimensión Categoría de Productos
CREATE TABLE BI_Dim_Categoria (
    id_categoria INT IDENTITY(1,1) PRIMARY KEY,
    categoria DECIMAL(8,0)
);

-- Dimensión Subcategoría de Productos
CREATE TABLE BI_Dim_Subcategoria (
    id_subcategoria INT IDENTITY(1,1) PRIMARY KEY,
    subcategoria DECIMAL(8,0),
    id_categoria INT FOREIGN KEY REFERENCES BI_Dim_Categoria(id_categoria)
);

-- Dimensión Ticket
CREATE TABLE BI_Dim_Ticket (
    id_ticket INT IDENTITY(1,1) PRIMARY KEY,
    numero_ticket INT,
    tipo_ticket VARCHAR(20)
);

-- Dimensión Caja
CREATE TABLE BI_Dim_Caja (
    id_caja INT IDENTITY(1,1) PRIMARY KEY,
    numero_caja INT,
    tipo_caja VARCHAR(20)
);

-- Tabla de Hechos Ventas
CREATE TABLE BI_Fact_Ventas (
    id_venta INT IDENTITY(1,1) PRIMARY KEY,
    id_tiempo INT FOREIGN KEY REFERENCES BI_Dim_Tiempo(id_tiempo),
    id_sucursal INT FOREIGN KEY REFERENCES BI_Dim_Sucursal(id_sucursal),
    id_cliente_rango_etario INT FOREIGN KEY REFERENCES BI_Dim_Rango_Etario(id_rango_etario),
    id_empleado_rango_etario INT FOREIGN KEY REFERENCES BI_Dim_Rango_Etario(id_rango_etario),
    id_turno INT FOREIGN KEY REFERENCES BI_Dim_Turno(id_turno),
    id_medio_pago INT FOREIGN KEY REFERENCES BI_Dim_Medio_Pago(id_medio_pago),
    id_categoria INT FOREIGN KEY REFERENCES BI_Dim_Categoria(id_categoria),
    id_subcategoria INT FOREIGN KEY REFERENCES BI_Dim_Subcategoria(id_subcategoria),
    id_ticket INT FOREIGN KEY REFERENCES BI_Dim_Ticket(id_ticket),
    id_caja INT FOREIGN KEY REFERENCES BI_Dim_Caja(id_caja),
    importe_total DECIMAL(18,2),
    cantidad_unidades DECIMAL(8,0),
    descuento_aplicado DECIMAL(10,2)
);

-- Tabla de Hechos Envíos
CREATE TABLE BI_Fact_Envios (
    id_envio INT IDENTITY(1,1) PRIMARY KEY,
    id_tiempo INT FOREIGN KEY REFERENCES BI_Dim_Tiempo(id_tiempo),
    id_sucursal INT FOREIGN KEY REFERENCES BI_Dim_Sucursal(id_sucursal),
    id_cliente_rango_etario INT FOREIGN KEY REFERENCES BI_Dim_Rango_Etario(id_rango_etario),
    costo_envio DECIMAL(18,2),
    cumplimiento_tiempo CHAR(1)
);

-- Migración de datos
-- Poblar Dim_Tiempo
INSERT INTO BI_Dim_Tiempo (anio, cuatrimestre, mes)
SELECT DISTINCT 
    YEAR(tick_fecha_hora) as anio,
    CASE 
        WHEN MONTH(tick_fecha_hora) BETWEEN 1 AND 4 THEN 1
        WHEN MONTH(tick_fecha_hora) BETWEEN 5 AND 8 THEN 2
        ELSE 3
    END as cuatrimestre,
    MONTH(tick_fecha_hora) as mes
FROM MASTER_COOKS.Ticket;

-- Poblar Dim_Provincia
INSERT INTO BI_Dim_Provincia (provincia)
SELECT DISTINCT prov_nombre
FROM MASTER_COOKS.Provincia;

-- Poblar Dim_Localidad
INSERT INTO BI_Dim_Localidad (localidad, id_provincia)
SELECT DISTINCT l.loca_nombre, p.id_provincia
FROM MASTER_COOKS.Localidad l
JOIN BI_Dim_Provincia p ON l.loca_provincia_id = p.provincia;

-- Poblar Dim_Sucursal
INSERT INTO BI_Dim_Sucursal (id_sucursal, direccion, id_localidad)
SELECT s.sucu_numero, s.sucu_direccion, l.id_localidad
FROM MASTER_COOKS.Sucursal s
JOIN BI_Dim_Localidad l ON s.sucu_localidad_id = l.localidad;

-- Poblar Dim_Rango_Etario
INSERT INTO BI_Dim_Rango_Etario (descripcion) VALUES
('< 25'), ('25 - 35'), ('35 - 50'), ('> 50');

-- Poblar Dim_Turno
INSERT INTO BI_Dim_Turno (hora_inicio, hora_fin) VALUES
('08:00', '12:00'), ('12:00', '16:00'), ('16:00', '20:00');

-- Poblar Dim_Medio_Pago
INSERT INTO BI_Dim_Medio_Pago (descripcion, tipo)
SELECT medi_descripcion, medi_tipo
FROM MASTER_COOKS.Medio_De_Pago;

-- Poblar Dim_Categoria
INSERT INTO BI_Dim_Categoria (categoria)
SELECT DISTINCT cate_codigo
FROM MASTER_COOKS.Categoria;

-- Poblar Dim_Subcategoria
INSERT INTO BI_Dim_Subcategoria (subcategoria, id_categoria)
SELECT DISTINCT s.subc_codigo, c.id_categoria
FROM MASTER_COOKS.Subcategoria s
JOIN MASTER_COOKS.Categoria_X_Subcategoria cs ON s.subc_codigo = cs.catx_subcategoria_id
JOIN BI_Dim_Categoria c ON cs.catx_categoria_id = c.categoria;

-- Poblar Dim_Ticket
INSERT INTO BI_Dim_Ticket (numero_ticket, tipo_ticket)
SELECT DISTINCT tick_numero, tick_tipo
FROM MASTER_COOKS.Ticket;

-- Poblar Dim_Caja
INSERT INTO BI_Dim_Caja (numero_caja, tipo_caja)
SELECT DISTINCT tick_caja_numero, tick_caja_tipo
FROM MASTER_COOKS.Ticket;

-- Poblar Fact_Ventas
INSERT INTO BI_Fact_Ventas (id_tiempo, id_sucursal, id_cliente_rango_etario, id_empleado_rango_etario, id_turno, id_medio_pago, id_subcategoria, id_ticket, id_caja, importe_total, cantidad_unidades, descuento_aplicado)
SELECT 
    dt.id_tiempo,
    t.tick_sucursal_id,
    CASE 
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) < 25 THEN 1
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) BETWEEN 25 AND 35 THEN 2
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) BETWEEN 35 AND 50 THEN 3
        ELSE 4
    END,
    CASE 
        WHEN DATEDIFF(YEAR, e.empl_fecha_nacimiento, t.tick_fecha_hora) < 25 THEN 1
        WHEN DATEDIFF(YEAR, e.empl_fecha_nacimiento, t.tick_fecha_hora) BETWEEN 25 AND 35 THEN 2
        WHEN DATEDIFF(YEAR, e.empl_fecha_nacimiento, t.tick_fecha_hora) BETWEEN 35 AND 50 THEN 3
        ELSE 4
    END,
    CASE 
        WHEN DATEPART(HOUR, t.tick_fecha_hora) BETWEEN 8 AND 11 THEN 1
        WHEN DATEPART(HOUR, t.tick_fecha_hora) BETWEEN 12 AND 15 THEN 2
        ELSE 3
    END,
    dmp.id_medio_pago,
    ds.id_subcategoria,
    dt.id_ticket,
    dc.id_caja,
    t.tick_total,
    SUM(it.item_cantidad),
    t.tick_total_descuento_promocion + t.tick_total_descuento_aplicado_mp
FROM MASTER_COOKS.Ticket t
JOIN BI_Dim_Tiempo dt ON YEAR(t.tick_fecha_hora) = dt.anio AND MONTH(t.tick_fecha_hora) = dt.mes
JOIN MASTER_COOKS.Cliente c ON t.tick_cliente_documento = c.clie_documento AND t.tick_cliente_apellido = c.clie_apellido
JOIN MASTER_COOKS.Empleado e ON t.tick_vendedor_id = e.empl_legajo
JOIN MASTER_COOKS.Item_Ticket it ON t.tick_numero = it.item_ticket_numero AND t.tick_tipo = it.item_tipo_id AND t.tick_sucursal_id = it.item_sucursal_id
JOIN MASTER_COOKS.Producto_X_Subcategoria pxs ON it.item_producto_codigo = pxs.prodx_producto_codigo AND it.item_producto_precio = pxs.prodx_producto_precio
JOIN BI_Dim_Subcategoria ds ON pxs.prodx_subcategoria_id = ds.subcategoria
JOIN MASTER_COOKS.Pago p ON t.tick_numero = p.pago_ticket_numero AND t.tick_tipo = p.pago_ticket_tipo AND t.tick_sucursal_id = p.pago_ticket_sucursal
JOIN BI_Dim_Medio_Pago dmp ON p.pago_medio_de_pago_id = dmp.descripcion
JOIN BI_Dim_Ticket dt ON t.tick_numero = dt.numero_ticket AND t.tick_tipo = dt.tipo_ticket
JOIN BI_Dim_Caja dc ON t.tick_caja_numero = dc.numero_caja AND t.tick_caja_tipo = dc.tipo_caja
GROUP BY dt.id_tiempo, t.tick_sucursal_id, c.clie_fecha_nacimiento, e.empl_fecha_nacimiento, t.tick_fecha_hora, dmp.id_medio_pago, ds.id_subcategoria, dt.id_ticket, dc.id_caja, t.tick_total, t.tick_total_descuento_promocion, t.tick_total_descuento_aplicado_mp;

-- Poblar Fact_Envios
INSERT INTO BI_Fact_Envios (id_tiempo, id_sucursal, id_cliente_rango_etario, costo_envio, cumplimiento_tiempo)
SELECT 
    dt.id_tiempo,
    e.envi_ticket_sucursal,
    CASE 
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) < 25 THEN 1
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) BETWEEN 25 AND 35 THEN 2
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) BETWEEN 35 AND 50 THEN 3
        ELSE 4
    END,
    e.envi_costo,
    CASE WHEN e.envi_fecha_hora_entrega <= e.envi_fecha_programada THEN 1 ELSE 0 END
FROM MASTER_COOKS.Envio e
JOIN MASTER_COOKS.Ticket t ON e.envi_ticket_numero = t.tick_numero AND e.envi_ticket_tipo = t.tick_tipo AND e.envi_ticket_sucursal = t.tick_sucursal_id
JOIN BI_Dim_Tiempo dt ON YEAR(t.tick_fecha_hora) = dt.anio AND MONTH(t.tick_fecha_hora) = dt.mes
JOIN MASTER_COOKS.Cliente c ON t.tick_cliente_documento = c.clie_documento AND t.tick_cliente_apellido = c.clie_apellido;


GO
-- 1. Ticket Promedio mensual
CREATE VIEW BI_TicketPromedioMensual AS
SELECT 
    dt.anio,
    dt.mes,
    dl.localidad,
    AVG(fv.importe_total) AS ticket_promedio
FROM BI_Fact_Ventas fv
JOIN BI_Dim_Tiempo dt ON fv.id_tiempo = dt.id_tiempo
JOIN BI_Dim_Sucursal ds ON fv.id_sucursal = ds.id_sucursal
JOIN BI_Dim_Localidad dl ON ds.id_localidad = dl.id_localidad
GROUP BY dt.anio, dt.mes, dl.localidad;
GO
-- 2. Cantidad unidades promedio
CREATE VIEW BI_UnidadesPromedioPorTurno AS
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
-- 3. Porcentaje anual de ventas por rango etario del empleado y tipo de caja
CREATE VIEW BI_PorcentajeVentasRangoEtarioEmpleado AS
SELECT 
    dt.anio,
    dt.cuatrimestre,
    dre.descripcion AS rango_etario_empleado,
    dc.tipo_caja,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY dt.anio) AS porcentaje_ventas
FROM BI_Fact_Ventas fv
JOIN BI_Dim_Tiempo dt ON fv.id_tiempo = dt.id_tiempo
JOIN BI_Dim_Rango_Etario dre ON fv.id_empleado_rango_etario = dre.id_rango_etario
JOIN BI_Dim_Caja dc ON fv.id_caja = dc.id_caja
GROUP BY dt.anio, dt.cuatrimestre, dre.descripcion, dc.tipo_caja;
GO
-- 4. Cantidad de ventas por turno y localidad
CREATE VIEW BI_VentasPorTurnoLocalidad AS
SELECT 
    dt.anio,
    dt.mes,
    dtur.id_turno,
    dl.localidad,
    COUNT(*) AS cantidad_ventas
FROM BI_Fact_Ventas fv
JOIN BI_Dim_Tiempo dt ON fv.id_tiempo = dt.id_tiempo
JOIN BI_Dim_Turno dtur ON fv.id_turno = dtur.id_turno
JOIN BI_Dim_Sucursal ds ON fv.id_sucursal = ds.id_sucursal
JOIN BI_Dim_Localidad dl ON ds.id_localidad = dl.id_localidad
GROUP BY dt.anio, dt.mes, dtur.id_turno, dl.localidad;
GO
-- 5. Porcentaje de descuento aplicado
CREATE VIEW BI_PorcentajeDescuentoAplicado AS
SELECT 
    dt.anio,
    dt.mes,
    SUM(fv.descuento_aplicado) * 100.0 / SUM(fv.importe_total + fv.descuento_aplicado) AS porcentaje_descuento
FROM BI_Fact_Ventas fv
JOIN BI_Dim_Tiempo dt ON fv.id_tiempo = dt.id_tiempo
GROUP BY dt.anio, dt.mes;
GO
-- 6. Las tres categorías de productos con mayor descuento aplicado
CREATE VIEW BI_TopCategoriasDescuento AS
WITH CategoriaDescuento AS (
    SELECT 
        dt.anio,
        dt.cuatrimestre,
        dc.categoria,
        SUM(fv.descuento_aplicado) AS total_descuento,
        ROW_NUMBER() OVER (PARTITION BY dt.anio, dt.cuatrimestre ORDER BY SUM(fv.descuento_aplicado) DESC) AS rn
    FROM BI_Fact_Ventas fv
    JOIN BI_Dim_Tiempo dt ON fv.id_tiempo = dt.id_tiempo
    JOIN BI_Dim_Subcategoria ds ON fv.id_subcategoria = ds.id_subcategoria
    JOIN BI_Dim_Categoria dc ON ds.id_categoria = dc.id_categoria
    GROUP BY dt.anio, dt.cuatrimestre, dc.categoria
)
SELECT anio, cuatrimestre, categoria, total_descuento
FROM CategoriaDescuento
WHERE rn <= 3;
GO
-- 7. Porcentaje de cumplimiento de envíos
CREATE VIEW BI_CumplimientoEnvios AS
SELECT 
    dt.anio,
    dt.mes,
    ds.id_sucursal,
    SUM(CASE WHEN fe.cumplimiento_tiempo = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS porcentaje_cumplimiento
FROM BI_Fact_Envios fe
JOIN BI_Dim_Tiempo dt ON fe.id_tiempo = dt.id_tiempo
JOIN BI_Dim_Sucursal ds ON fe.id_sucursal = ds.id_sucursal
GROUP BY dt.anio, dt.mes, ds.id_sucursal;
GO
-- 8. Cantidad de envíos por rango etario de clientes
CREATE VIEW BI_EnviosPorRangoEtario AS
SELECT 
    dt.anio,
    dt.cuatrimestre,
    dre.descripcion AS rango_etario,
    COUNT(*) AS cantidad_envios
FROM BI_Fact_Envios fe
JOIN BI_Dim_Tiempo dt ON fe.id_tiempo = dt.id_tiempo
JOIN BI_Dim_Rango_Etario dre ON fe.id_cliente_rango_etario = dre.id_rango_etario
GROUP BY dt.anio, dt.cuatrimestre, dre.descripcion;
GO
-- 9. Las 5 localidades con mayor costo de envío
CREATE VIEW BI_Top5LocalidadesCostoEnvio AS
WITH LocalidadCostoEnvio AS (
    SELECT 
        dl.localidad,
        SUM(fe.costo_envio) AS total_costo_envio,
        ROW_NUMBER() OVER (ORDER BY SUM(fe.costo_envio) DESC) AS rn
    FROM BI_Fact_Envios fe
    JOIN BI_Dim_Sucursal ds ON fe.id_sucursal = ds.id_sucursal
    JOIN BI_Dim_Localidad dl ON ds.id_localidad = dl.id_localidad
    GROUP BY dl.localidad
)
SELECT localidad, total_costo_envio
FROM LocalidadCostoEnvio
WHERE rn <= 5;
GO
-- 10. Las 3 sucursales con el mayor importe de pagos en cuotas
CREATE VIEW BI_Top3SucursalesPagosCuotas AS
WITH SucursalPagosCuotas AS (
    SELECT 
        dt.anio,
        dt.mes,
        ds.id_sucursal,
        dmp.descripcion AS medio_pago,
        SUM(CASE WHEN dmp.tipo = 'CUOTAS' THEN fv.importe_total ELSE 0 END) AS total_pagos_cuotas,
        ROW_NUMBER() OVER (PARTITION BY dt.anio, dt.mes, dmp.descripcion ORDER BY SUM(CASE WHEN dmp.tipo = 'CUOTAS' THEN fv.importe_total ELSE 0 END) DESC) AS rn
    FROM BI_Fact_Ventas fv
    JOIN BI_Dim_Tiempo dt ON fv.id_tiempo = dt.id_tiempo
    JOIN BI_Dim_Sucursal ds ON fv.id_sucursal = ds.id_sucursal
    JOIN BI_Dim_Medio_Pago dmp ON fv.id_medio_pago = dmp.id_medio_pago
    GROUP BY dt.anio, dt.mes, ds.id_sucursal, dmp.descripcion
)
SELECT anio, mes, id_sucursal, medio_pago, total_pagos_cuotas
FROM SucursalPagosCuotas
WHERE rn <= 3;
GO
-- 11. Promedio de importe de la cuota en función del rango etareo del cliente
CREATE VIEW BI_PromedioImporteCuotaPorRangoEtario AS
SELECT 
    dre.descripcion AS rango_etario,
    AVG(fv.importe_total / NULLIF(dp.deta_cuotas, 0)) AS promedio_importe_cuota
FROM BI_Fact_Ventas fv
JOIN BI_Dim_Rango_Etario dre ON fv.id_cliente_rango_etario = dre.id_rango_etario
JOIN MASTER_COOKS.Pago p ON fv.id_sucursal = p.pago_ticket_sucursal
JOIN MASTER_COOKS.Detalle_Pago dp ON p.pago_id = dp.deta_pago_id
WHERE dp.deta_cuotas > 0
GROUP BY dre.descripcion;
GO
-- 12. Porcentaje de descuento aplicado por cada medio de pago
CREATE VIEW BI_PorcentajeDescuentoPorMedioPago AS
SELECT 
    dt.anio,
    dt.cuatrimestre,
    dmp.descripcion AS medio_pago,
    SUM(fv.descuento_aplicado) * 100.0 / SUM(fv.importe_total + fv.descuento_aplicado) AS porcentaje_descuento
FROM BI_Fact_Ventas fv
JOIN BI_Dim_Tiempo dt ON fv.id_tiempo = dt.id_tiempo
JOIN BI_Dim_Medio_Pago dmp ON fv.id_medio_pago = dmp.id_medio_pago
GROUP BY dt.anio, dt.cuatrimestre, dmp.descripcion;