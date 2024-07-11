-- Dimensión Tiempo
CREATE TABLE MASTER_COOKS.BI_Dim_Tiempo (
    tiempo_id VARCHAR(20) PRIMARY KEY,
    tiempo_anio CHAR(4),
    tiempo_mes CHAR(2),
    tiempo_cuatrimestre CHAR(1)
);

-- Dimensión Ubicacion
CREATE TABLE MASTER_COOKS.BI_Dim_Ubicacion (
    ubicacion_id VARCHAR(110) PRIMARY KEY,
    ubicacion_provincia VARCHAR(60),
    ubicacion_localidad VARCHAR(50)
);

-- Dimensión Sucursal
CREATE TABLE MASTER_COOKS.BI_Dim_Sucursal (
    sucursal_id DECIMAL(6,0) PRIMARY KEY,
    sucursal_ubicacion VARCHAR(110)
	FOREIGN KEY (sucursal_ubicacion) REFERENCES MASTER_COOKS.BI_Dim_Ubicacion(ubicacion_id),
);

-- Dimensión Rango Etario
CREATE TABLE MASTER_COOKS.BI_Dim_Rango_Etario (
    rango_id DECIMAL(2,0) PRIMARY KEY,
    rango_descripcion VARCHAR(50)
);

-- Dimensión Cliente
CREATE TABLE MASTER_COOKS.BI_Dim_Cliente (
    cliente_id VARCHAR(50) PRIMARY KEY,
    cliente_ubicacion VARCHAR(110),
    cliente_rango_etario DECIMAL(2,0)
    FOREIGN KEY (cliente_rango_etario) REFERENCES MASTER_COOKS.BI_Dim_Rango_Etario(rango_id),
	FOREIGN KEY (cliente_ubicacion) REFERENCES MASTER_COOKS.BI_Dim_Ubicacion(ubicacion_id)
);

CREATE TABLE MASTER_COOKS.BI_Dim_Empleado (
    empleado_id VARCHAR(60) PRIMARY KEY,
    empleado_rango_etario DECIMAL(2,0),
	empleado_sucursal DECIMAL(6,0)
    FOREIGN KEY (empleado_rango_etario) REFERENCES MASTER_COOKS.BI_Dim_Rango_Etario(rango_id),
	FOREIGN KEY (empleado_sucursal) REFERENCES MASTER_COOKS.BI_Dim_Sucursal(sucursal_id)
);

-- Dimensión Turnos
CREATE TABLE MASTER_COOKS.BI_Dim_Turno (
    turno_id DECIMAL(6,0) PRIMARY KEY,
    turno_hora_inicio DATETIME,
    turno_hora_fin DATETIME
);

-- Dimensión Medio de Pago
CREATE TABLE MASTER_COOKS.BI_Dim_Medio_Pago (
    medio_pago_id VARCHAR(50) PRIMARY KEY,
    medio_pago_tipo VARCHAR(30)
);

-- Dimensión Categoría de Productos
CREATE TABLE MASTER_COOKS.BI_Dim_Categoria (
    categoria_id DECIMAL(8,0) PRIMARY KEY
);

-- Dimensión Tipo Caja
CREATE TABLE MASTER_COOKS.BI_Dim_Tipo_Caja (
    tipo_caja_id VARCHAR(50) PRIMARY KEY
);

-- Tabla de Hechos Ventas
CREATE TABLE MASTER_COOKS.BI_Fact_Ventas (
    tiempo_id VARCHAR(20) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Tiempo(tiempo_id),
    sucursal_id DECIMAL(6,0) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Sucursal(sucursal_id),
    cliente_id VARCHAR(50) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Cliente(cliente_id),
	empleado_id VARCHAR(60) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Empleado(empleado_id),
    turno_id DECIMAL(6,0) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Turno(turno_id),
    tipo_caja_id VARCHAR(50) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Tipo_Caja(tipo_caja_id),
    importe_total DECIMAL(12,2),
	promedio_venta DECIMAL(12,2),
    cantidad_unidades DECIMAL(12,0),
    PRIMARY KEY (tiempo_id, sucursal_id, cliente_id, empleado_id, turno_id, tipo_caja_id)
);

-- Tabla de Hechos Promociones
CREATE TABLE MASTER_COOKS.BI_Fact_Promociones (
    categoria_id DECIMAL(8,0) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Categoria(categoria_id),
    tiempo_id VARCHAR(20) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Tiempo(tiempo_id),
    --medio_pago_id VARCHAR(50) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Medio_Pago(medio_pago_id),
    monto_descuento DECIMAL(12,2),
    monto_descuento_promocion DECIMAL(12,2),
    tipo_descuento VARCHAR(30),
    PRIMARY KEY (categoria_id, tiempo_id)
);

-- Tabla de Hechos Pagos
CREATE TABLE MASTER_COOKS.BI_Fact_Pagos (
    tiempo_id VARCHAR(20) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Tiempo(tiempo_id),
    medio_pago_id VARCHAR(50) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Medio_Pago(medio_pago_id),
	sucursal_id DECIMAL(6,0) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Sucursal(sucursal_id),
	cliente_id VARCHAR(50) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Cliente(cliente_id),
	PRIMARY KEY (tiempo_id, medio_pago_id, sucursal_id, cliente_id)
);

-- Tabla de Hechos Envíos
CREATE TABLE MASTER_COOKS.BI_Fact_Envio (
    tiempo_id VARCHAR(20) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Tiempo(tiempo_id),
    sucursal_id DECIMAL(6,0) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Sucursal(sucursal_id),
    cliente_id VARCHAR(50) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Cliente(cliente_id),
    costo_envio_total DECIMAL(12,2),
    cantidad_envios INT,
    envios_cumplidos INT,
    PRIMARY KEY (tiempo_id, sucursal_id, cliente_id)
);

-- Poblar las dimensiones 
INSERT INTO MASTER_COOKS.BI_Dim_Tiempo (tiempo_id, tiempo_anio, tiempo_mes, tiempo_cuatrimestre)
SELECT DISTINCT
    CONCAT(YEAR(tick_fecha_hora), RIGHT('0' + CAST(MONTH(tick_fecha_hora) AS VARCHAR(2)), 2)),
    CAST(YEAR(tick_fecha_hora) AS CHAR(4)),
    RIGHT('0' + CAST(MONTH(tick_fecha_hora) AS VARCHAR(2)), 2),
    CASE
        WHEN MONTH(tick_fecha_hora) BETWEEN 1 AND 4 THEN '1'
        WHEN MONTH(tick_fecha_hora) BETWEEN 5 AND 8 THEN '2'
        ELSE '3'
    END
FROM MASTER_COOKS.Ticket;

-- Poblar Dim_Rango_Etario
INSERT INTO MASTER_COOKS.BI_Dim_Rango_Etario (rango_id, rango_descripcion)
VALUES
(1, 'Menor a 25'),
(2, 'Entre 25 y 35'),
(3, 'Entre 35 y 50'),
(4, 'Mayor a 50');

-- Poblar Dim_Ubicacion
INSERT INTO MASTER_COOKS.BI_Dim_Ubicacion (ubicacion_id, ubicacion_provincia, ubicacion_localidad)
SELECT DISTINCT
    CONCAT(l.loca_provincia_id, l.loca_nombre),
    l.loca_provincia_id,
    l.loca_nombre
FROM MASTER_COOKS.Localidad l;

-- Poblar Dim_Cliente
INSERT INTO MASTER_COOKS.BI_Dim_Cliente (cliente_id, cliente_ubicacion, cliente_rango_etario)
SELECT DISTINCT
    CONCAT(c.clie_documento, c.clie_apellido),
	c.clie_localidad_id,
	CASE
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) < 25 THEN 1
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) BETWEEN 25 AND 35 THEN 2
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) BETWEEN 35 AND 50 THEN 3
        ELSE 4
    END
FROM MASTER_COOKS.Cliente c
JOIN MASTER_COOKS.Ticket t ON t.tick_cliente_documento = c.clie_documento and t.tick_cliente_apellido = c.clie_apellido;

-- Poblar Dim_Empleado
INSERT INTO MASTER_COOKS.BI_Dim_Empleado (empleado_id, empleado_rango_etario, empleado_sucursal)
SELECT DISTINCT
    empl_legajo,
	CASE
        WHEN DATEDIFF(YEAR, e.empl_fecha_nacimiento, t.tick_fecha_hora) < 25 THEN 1
        WHEN DATEDIFF(YEAR, e.empl_fecha_nacimiento, t.tick_fecha_hora) BETWEEN 25 AND 35 THEN 2
        WHEN DATEDIFF(YEAR, e.empl_fecha_nacimiento, t.tick_fecha_hora) BETWEEN 35 AND 50 THEN 3
        ELSE 4
    END,
	e.empl_sucursal_id
FROM MASTER_COOKS.Empleado e
JOIN MASTER_COOKS.Ticket t ON t.tick_vendedor_id = e.empl_legajo

-- Poblar Dim_Sucursal
INSERT INTO MASTER_COOKS.BI_Dim_Sucursal (sucursal_id, sucursal_ubicacion)
SELECT DISTINCT
    s.sucu_numero,
    CONCAT(s.sucu_provincia_id, s.sucu_localidad_id)
FROM MASTER_COOKS.Sucursal s;

-- Poblar Dim_Turno
INSERT INTO MASTER_COOKS.BI_Dim_Turno (turno_hora_inicio, turno_hora_fin)
VALUES
(1, 8, 12),
(2, 12, 16),
(3, 16, 20);

-- Poblar Dim_Medio_Pago
INSERT INTO MASTER_COOKS.BI_Dim_Medio_Pago (medio_pago_id, medio_pago_tipo)
SELECT DISTINCT 
	medi_descripcion, 
	medi_tipo
FROM MASTER_COOKS.Medio_De_Pago;

-- Poblar Dim_Categoria
INSERT INTO MASTER_COOKS.BI_Dim_Categoria (categoria_id)
SELECT DISTINCT 
	cate_codigo
FROM MASTER_COOKS.Categoria;

-- Poblar Dim_Tipo_Caja
INSERT INTO MASTER_COOKS.BI_Dim_Tipo_Caja(tipo_caja_id)
SELECT DISTINCT
    tipo_descripcion
FROM MASTER_COOKS.Tipo_Caja

--Poblar Fact_Ventas
INSERT INTO MASTER_COOKS.BI_Fact_Ventas (tiempo_id, sucursal_id, cliente_id, empleado_id, turno_id, tipo_caja_id, importe_total, promedio_venta, cantidad_unidades)
SELECT
    dti.tiempo_id,
    dsu.sucursal_id,
	dcl.cliente_id,
	dem.empleado_id,
    dtu.turno_id,
    dtc.tipo_caja_id,
    t.tick_total,
	SUM(t.tick_total)/COUNT(distinct t.tick_numero+t.tick_sucursal_id+t.tick_tipo),
    SUM(it.item_cantidad)
FROM MASTER_COOKS.Ticket t
JOIN MASTER_COOKS.BI_Dim_Tiempo dti ON dti.tiempo_id = CONCAT(YEAR(t.tick_fecha_hora), RIGHT('0' + CAST(MONTH(t.tick_fecha_hora) AS VARCHAR(2)), 2))
JOIN MASTER_COOKS.BI_Dim_Sucursal dsu ON dsu.sucursal_id = t.tick_sucursal_id
JOIN MASTER_COOKS.BI_Dim_Cliente dcl ON dcl.cliente_id = CONCAT(t.tick_cliente_documento, t.tick_cliente_apellido)
JOIN MASTER_COOKS.BI_Dim_Empleado dem ON dem.empleado_id = t.tick_vendedor_id
JOIN MASTER_COOKS.Item_Ticket it ON t.tick_numero = it.item_ticket_numero AND t.tick_tipo = it.item_tipo_id AND t.tick_sucursal_id = it.item_sucursal_id
JOIN MASTER_COOKS.Caja caja ON caja.caja_sucursal_id = t.tick_sucursal_id AND t.tick_caja_numero = caja.caja_numero
JOIN MASTER_COOKS.BI_Dim_Tipo_Caja dtc ON dtc.tipo_caja_id = caja.caja_tipo_id
JOIN MASTER_COOKS.BI_Dim_Turno dtu ON ((DATEPART(HOUR, t.tick_fecha_hora)) >= dtu.turno_hora_inicio 
										AND (DATEPART(HOUR, t.tick_fecha_hora)) < dtu.turno_hora_fin
										AND (DATEPART(HOUR, t.tick_fecha_hora)) BETWEEN dtu.turno_hora_inicio AND dtu.turno_hora_fin)
GROUP BY dti.tiempo_id, dsu.sucursal_id, dcl.cliente_id, dem.empleado_id, dtu.turno_id, dtc.tipo_caja_id;

-- Poblar Fact_Promociones
INSERT INTO MASTER_COOKS.BI_Fact_Promociones(id_ticket, id_categoria, id_tiempo, id_medio_pago, monto_descuento, monto_descuento_promocion, tipo_descuento)
SELECT 
    CONCAT(t.tick_numero, t.tick_tipo, t.tick_sucursal_id) as id_ticket,
    cxs.catx_categoria_id as id_categoria,
    CONCAT(YEAR(t.tick_fecha_hora), RIGHT('0' + CAST(MONTH(t.tick_fecha_hora) AS VARCHAR(2)), 2)) as id_tiempo,
    p.pago_medio_de_pago_id,
    t.tick_total_descuento_promocion + t.tick_total_descuento_aplicado_mp as monto_descuento,
	t.tick_total_descuento_promocion as monto_descuento_promocion,
    CASE
        WHEN t.tick_total_descuento_promocion > 0 AND t.tick_total_descuento_aplicado_mp > 0 THEN 'Promoción y Medio de Pago'
        WHEN t.tick_total_descuento_promocion > 0 THEN 'Promoción'
        WHEN t.tick_total_descuento_aplicado_mp > 0 THEN 'Medio de Pago'
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
    p.pago_medio_de_pago_id,
	t.tick_total_descuento_promocion,
	t.tick_total_descuento_aplicado_mp;


-- Poblar Fact_Pagos
INSERT INTO MASTER_COOKS.BI_Fact_Pagos ()
SELECT 




-- Poblar Fact_Envio
INSERT INTO MASTER_COOKS.BI_Fact_Envio (id_tiempo, id_sucursal, id_rango_etario_cliente, id_cliente_localidad, costo_envio_total, cantidad_envios, envios_cumplidos)
SELECT 
    CONCAT(YEAR(t.tick_fecha_hora), RIGHT('0' + CAST(MONTH(t.tick_fecha_hora) AS VARCHAR(2)), 2)) as id_tiempo,
    e.envi_ticket_sucursal as id_sucursal,
    CASE
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) < 25 THEN 1
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) BETWEEN 25 AND 35 THEN 2
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) BETWEEN 35 AND 50 THEN 3
        ELSE 4
    END as id_rango_etario_cliente,
	CONCAT(c.clie_documento, c.clie_apellido, l.loca_provincia_id, l.loca_nombre) as id_cliente_localidad,
    SUM(e.envi_costo) as costo_envio_total,
    COUNT(*) as cantidad_envios,
    SUM(CASE WHEN (cast(e.envi_fecha_hora_entrega as date) = e.envi_fecha_programada) THEN 1 ELSE 0 END) as envios_cumplidos
FROM MASTER_COOKS.Envio e
JOIN MASTER_COOKS.Ticket t ON e.envi_ticket_numero = t.tick_numero AND e.envi_ticket_tipo = t.tick_tipo AND e.envi_ticket_sucursal = t.tick_sucursal_id
JOIN MASTER_COOKS.Cliente c ON t.tick_cliente_documento = c.clie_documento AND t.tick_cliente_apellido = c.clie_apellido
JOIN MASTER_COOKS.Localidad l ON c.clie_localidad_id = l.loca_nombre
GROUP BY 
    CONCAT(YEAR(t.tick_fecha_hora), RIGHT('0' + CAST(MONTH(t.tick_fecha_hora) AS VARCHAR(2)), 2)),
    e.envi_ticket_sucursal,
	CONCAT(c.clie_documento, c.clie_apellido, l.loca_provincia_id, l.loca_nombre),
    CASE
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) < 25 THEN 1
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) BETWEEN 25 AND 35 THEN 2
        WHEN DATEDIFF(YEAR, c.clie_fecha_nacimiento, t.tick_fecha_hora) BETWEEN 35 AND 50 THEN 3
        ELSE 4
    END;

-- Crear vistas
-- 1. Ticket Promedio mensual
CREATE VIEW MASTER_COOKS.BI_VW_TicketPromedioMensual AS
SELECT 
    dt.anio,
    dt.mes,
    dl.localidad_nombre,
	(SUM(fv.importe_total) / COUNT(*)) AS ticket_promedio
FROM MASTER_COOKS.BI_Fact_Ventas fv
JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fv.id_tiempo = dt.id_tiempo
JOIN MASTER_COOKS.BI_Dim_Sucursal ds ON fv.id_sucursal = ds.id_sucursal
JOIN MASTER_COOKS.BI_Dim_Localidad dl ON ds.sucursal_localidad_id = dl.id_localidad
GROUP BY dt.anio, dt.mes, dl.localidad_nombre;
GO
-- 2. Cantidad unidades promedio
CREATE VIEW MASTER_COOKS.BI_VW_UnidadesPromedioPorTurno AS
SELECT
    dt.anio,
    dt.cuatrimestre,
    dtur.id_turno,
	(SUM(fv.cantidad_unidades) / COUNT(*)) as unidades_promedio
FROM MASTER_COOKS.BI_Fact_Ventas fv
JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fv.id_tiempo = dt.id_tiempo
JOIN MASTER_COOKS.BI_Dim_Turno dtur ON fv.id_turno = dtur.id_turno
GROUP BY dt.anio, dt.cuatrimestre, dtur.id_turno
GO
-- 3. Porcentaje anual de ventas por rango etario del cliente y tipo de caja
CREATE VIEW MASTER_COOKS.BI_VW_PorcentajeVentasRangoEtarioEmpleado AS
SELECT
    dt.anio,
    dt.cuatrimestre,
    dre.descripcion AS rango_etario_empleado,
    dc.tipo_caja,
    COUNT(*) * 100.0 / (SELECT COUNT(*) from BI_Fact_Ventas) AS porcentaje_ventas
FROM MASTER_COOKS.BI_Fact_Ventas fv
JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fv.id_tiempo = dt.id_tiempo
JOIN MASTER_COOKS.BI_Dim_Rango_Etario_Empleado dre ON fv.id_rango_etario_empleado = dre.id_rango_etario_empleado
JOIN MASTER_COOKS.BI_Dim_Caja dc ON fv.id_caja = dc.id_caja
GROUP BY dt.anio, dt.cuatrimestre, dre.descripcion, dc.tipo_caja;
GO

-- 4. Cantidad de ventas por turno y localidad
CREATE VIEW MASTER_COOKS.BI_VW_VentasPorTurnoLocalidad AS
SELECT
    dt.anio,
    dt.mes,
    dtur.id_turno,
    dl.localidad_nombre,
    COUNT(*) AS cantidad_ventas
FROM MASTER_COOKS.BI_Fact_Ventas fv
JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fv.id_tiempo = dt.id_tiempo
JOIN MASTER_COOKS.BI_Dim_Turno dtur ON fv.id_turno = dtur.id_turno
JOIN MASTER_COOKS.BI_Dim_Sucursal ds ON fv.id_sucursal = ds.id_sucursal
JOIN MASTER_COOKS.BI_Dim_Localidad dl ON ds.sucursal_localidad_id = dl.id_localidad
GROUP BY dt.anio, dt.mes, dtur.id_turno, dl.localidad_nombre;
GO
-- 5. Porcentaje de descuento aplicado
CREATE VIEW MASTER_COOKS.BI_VW_PorcentajeDescuentoAplicado AS
SELECT
    dt.anio,
    dt.mes,
    (sum(fd.monto_descuento) / sum(fv.importe_total)) * 100  AS porcentaje_descuento
FROM MASTER_COOKS.BI_Fact_Descuento fd
JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fd.id_tiempo = dt.id_tiempo
JOIN MASTER_COOKS.BI_Fact_Ventas fv ON fd.id_ticket = fv.id_ticket AND fd.id_tiempo = fv.id_tiempo
GROUP BY dt.anio, dt.mes;
GO
-- 6. Las tres categorías de productos con mayor descuento aplicado
CREATE VIEW MASTER_COOKS.BI_VW_Top3CategoriasDescuento AS
SELECT TOP 3
    dt.anio,
    dt.cuatrimestre,
    dc.id_categoria,
    SUM(fd.monto_descuento_promocion) AS total_descuento
FROM MASTER_COOKS.BI_Fact_Descuento fd
JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fd.id_tiempo = dt.id_tiempo
JOIN MASTER_COOKS.BI_Dim_Categoria dc ON fd.id_categoria = dc.id_categoria
GROUP BY dt.anio, dt.cuatrimestre, dc.id_categoria
ORDER BY 
    dt.anio,
    dt.cuatrimestre,
    SUM(fd.monto_descuento) DESC;
GO
-- 7. Porcentaje de cumplimiento de envíos
CREATE VIEW MASTER_COOKS.BI_VW_CumplimientoEnvios AS
SELECT
    dt.anio,
    dt.mes,
    fe.id_sucursal,
    CAST(fe.envios_cumplidos AS FLOAT) / CAST(fe.cantidad_envios AS FLOAT) * 100 AS porcentaje_cumplimiento
FROM MASTER_COOKS.BI_Fact_Envio fe
JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fe.id_tiempo = dt.id_tiempo
GROUP BY dt.anio, dt.mes, fe.id_sucursal, CAST(fe.envios_cumplidos AS FLOAT) / CAST(fe.cantidad_envios AS FLOAT)
GO
-- 8. Cantidad de envíos por rango etario de clientes
CREATE VIEW MASTER_COOKS.BI_VW_EnviosPorRangoEtarioCliente AS
SELECT
    dt.anio,
    dt.cuatrimestre,
    dre.descripcion AS rango_etario_cliente,
    sum(fe.cantidad_envios) AS cantidad_envios
FROM MASTER_COOKS.BI_Fact_Envio fe
JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fe.id_tiempo = dt.id_tiempo
JOIN MASTER_COOKS.BI_Dim_Rango_Etario_Cliente dre ON fe.id_rango_etario_cliente = dre.id_rango_etario_cliente
GROUP BY dt.anio, dt.cuatrimestre, dre.descripcion;
GO

-- 9. Las 5 localidades con mayor costo de envío
CREATE VIEW MASTER_COOKS.BI_VW_Top5LocalidadesCostoEnvio AS
SELECT TOP 5
    loc.localidad_nombre AS Localidad,
    SUM(env.costo_envio_total) AS Costo_Envio_Total
	FROM MASTER_COOKS.BI_Fact_Envio env
JOIN MASTER_COOKS.BI_Dim_Cliente_Localidad cl ON env.id_cliente_localidad = cl.id_cliente_localidad
JOIN MASTER_COOKS.BI_Dim_Localidad loc ON cl.id_localidad = loc.id_localidad
GROUP BY loc.localidad_nombre
ORDER BY SUM(env.costo_envio_total) DESC;
GO
-- 10. Las 3 sucursales con el mayor importe de pagos en cuotas
CREATE VIEW MASTER_COOKS.BI_VW_Top3SucursalesPagosCuotas AS
SELECT TOP 3
        dt.anio,
        dt.mes,
        fc.id_sucursal,
        dmp.id_medio_pago,
        SUM(fc.importe_total) AS total_pagos_cuotas
    FROM MASTER_COOKS.BI_Fact_Cuotas fc
    JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fc.id_tiempo = dt.id_tiempo
    JOIN MASTER_COOKS.BI_Dim_Medio_Pago dmp ON fc.id_medio_pago = dmp.id_medio_pago
    GROUP BY dt.anio, dt.mes, fc.id_sucursal, dmp.id_medio_pago, fc.numero_cuotas
	order by total_pagos_cuotas DESC
GO


-- 11. Promedio de importe de la cuota en función del rango etareo del cliente
CREATE VIEW MASTER_COOKS.BI_VW_PromedioImporteCuotaPorRangoEtarioCliente AS
SELECT
    dre.descripcion AS rango_etario_cliente,
    AVG(fc.importe_cuota) AS promedio_importe_cuota
FROM MASTER_COOKS.BI_Fact_Cuotas fc
JOIN MASTER_COOKS.BI_Dim_Rango_Etario_Cliente dre ON fc.id_rango_etario_cliente = dre.id_rango_etario_cliente
GROUP BY dre.descripcion;
GO

-- 12. Porcentaje de descuento aplicado por cada medio de pago
CREATE VIEW MASTER_COOKS.BI_VW_PorcentajeDescuentoPorMedioPago AS
SELECT
    dt.anio,
    dt.cuatrimestre,
    dmp.id_medio_pago,
    (SUM(fd.monto_descuento) / (SUM(fv.importe_total) + SUM(fd.monto_descuento)) * 100) AS porcentaje_descuento
FROM MASTER_COOKS.BI_Fact_Descuento fd
JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fd.id_tiempo = dt.id_tiempo
JOIN MASTER_COOKS.BI_Dim_Medio_Pago dmp ON fd.id_medio_pago = dmp.id_medio_pago
JOIN MASTER_COOKS.BI_Fact_Ventas fv ON fd.id_ticket = fv.id_ticket AND fd.id_tiempo = fv.id_tiempo
GROUP BY dt.anio, dt.cuatrimestre, dmp.id_medio_pago;
GO