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

--Dimension Empleado
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

-- Dimensión de Categoria
CREATE TABLE MASTER_COOKS.BI_Dim_Categoria (
    categoria_id VARCHAR(20) PRIMARY KEY,
	categoria_subcategoria DECIMAL(8,0),
	categoria_nombre DECIMAL(8,0)
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
	cantidad_ventas DECIMAL(12,0),
    cantidad_unidades DECIMAL(12,0),
    PRIMARY KEY (tiempo_id, sucursal_id, cliente_id, empleado_id, turno_id, tipo_caja_id)
);

-- Tabla de Hechos Promociones
CREATE TABLE MASTER_COOKS.BI_Fact_Promociones (
    categoria_id VARCHAR(20) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Categoria(categoria_id),
    tiempo_id VARCHAR(20) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Tiempo(tiempo_id),
    monto_descuento_promocion DECIMAL(18,2),
    ticket_total DECIMAL(18,2),
    cantidad_tickets DECIMAL(18,0),
    porcentaje_descuento DECIMAL(5,2),
    PRIMARY KEY (categoria_id, tiempo_id)
);


-- Tabla de Hechos Pagos
CREATE TABLE MASTER_COOKS.BI_Fact_Pagos (
    tiempo_id VARCHAR(20) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Tiempo(tiempo_id),
    medio_pago_id VARCHAR(50) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Medio_Pago(medio_pago_id),
	sucursal_id DECIMAL(6,0) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Sucursal(sucursal_id),
	cliente_id VARCHAR(50) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Cliente(cliente_id),
	rango_id DECIMAL(2,0) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Rango_Etario(rango_id),
	importe_pago_en_cuotas DECIMAL(12,2),
	importe_pago_total DECIMAL(12,2),
	descuento_total DECIMAL(12,2)
	PRIMARY KEY (tiempo_id, medio_pago_id, sucursal_id, cliente_id, rango_id)
);

-- Tabla de Hechos Envíos
CREATE TABLE MASTER_COOKS.BI_Fact_Envio (
    tiempo_id VARCHAR(20) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Tiempo(tiempo_id),
    sucursal_id DECIMAL(6,0) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Sucursal(sucursal_id),
	rango_id DECIMAL(2,0) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Rango_Etario(rango_id),
    cliente_id VARCHAR(50) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Cliente(cliente_id),
    costo_envio_total DECIMAL(12,2),
    cantidad_envios INT,
    envios_cumplidos INT,
    PRIMARY KEY (tiempo_id, sucursal_id, rango_id, cliente_id)
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
	CONCAT(c.clie_provincia_id, c.clie_localidad_id),
	dbo.ExtractRangoEtario(c.clie_fecha_nacimiento, t.tick_fecha_hora)
FROM MASTER_COOKS.Cliente c
JOIN MASTER_COOKS.Ticket t ON t.tick_cliente_documento = c.clie_documento and t.tick_cliente_apellido = c.clie_apellido;

-- Poblar Dim_Sucursal
INSERT INTO MASTER_COOKS.BI_Dim_Sucursal (sucursal_id, sucursal_ubicacion)
SELECT DISTINCT
    s.sucu_numero,
    CONCAT(s.sucu_provincia_id, s.sucu_localidad_id)
FROM MASTER_COOKS.Sucursal s;

-- Poblar Dim_Empleado
INSERT INTO MASTER_COOKS.BI_Dim_Empleado (empleado_id, empleado_rango_etario, empleado_sucursal)
SELECT DISTINCT
    e.empl_legajo,
	dbo.ExtractRangoEtario(e.empl_fecha_nacimiento, t.tick_fecha_hora),
	e.empl_sucursal_id
FROM MASTER_COOKS.Empleado e
JOIN MASTER_COOKS.Ticket t ON t.tick_vendedor_id = e.empl_legajo

-- Poblar Dim_Turno
INSERT INTO MASTER_COOKS.BI_Dim_Turno (turno_id ,turno_hora_inicio, turno_hora_fin)
VALUES
(1, 8, 12),
(2, 12, 16),
(3, 16, 20);

-- Poblar Dim_Medio_Pago
INSERT INTO MASTER_COOKS.BI_Dim_Medio_Pago (medio_pago_id, medio_pago_tipo)
SELECT DISTINCT
	m.medi_descripcion,
	m.medi_tipo
FROM MASTER_COOKS.Medio_De_Pago m;

-- Poblar Dim_Cateogria
INSERT INTO MASTER_COOKS.BI_Dim_Categoria(categoria_id, categoria_subcategoria, categoria_nombre)
SELECT DISTINCT
	CONCAT(s.subc_id, c.cate_codigo),
    s.subc_id,
	c.cate_codigo
FROM MASTER_COOKS.Categoria c
JOIN MASTER_COOKS.Subcategoria s ON s.subc_categoria = c.cate_codigo

-- Poblar Dim_Tipo_Caja
INSERT INTO MASTER_COOKS.BI_Dim_Tipo_Caja(tipo_caja_id)
SELECT DISTINCT
    tc.tipo_descripcion
FROM MASTER_COOKS.Tipo_Caja tc

--Poblar Fact_Ventas
INSERT INTO MASTER_COOKS.BI_Fact_Ventas (tiempo_id, sucursal_id, cliente_id, empleado_id, turno_id, tipo_caja_id, importe_total, cantidad_ventas, cantidad_unidades)
SELECT DISTINCT
    dti.tiempo_id,
    dsu.sucursal_id,
	dcl.cliente_id,
	dem.empleado_id,
    dtu.turno_id,
    dtc.tipo_caja_id,
    SUM(t.tick_total),
	COUNT(DISTINCT CONCAT(t.tick_numero,t.tick_sucursal_id,t.tick_tipo)),
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
INSERT INTO MASTER_COOKS.BI_Fact_Promociones(categoria_id, tiempo_id, monto_descuento_promocion, ticket_total, cantidad_tickets, porcentaje_descuento)
SELECT DISTINCT
	dcat.categoria_id,
	dti.tiempo_id,
	SUM(t.tick_total_descuento_promocion),
	SUM(it.item_total),
	COUNT(DISTINCT CONCAT(t.tick_numero,t.tick_sucursal_id,t.tick_tipo)),
	SUM(pxt.promx_item_promocion_aplicada) * 100 / SUM(it.item_total)
FROM MASTER_COOKS.Ticket t
JOIN MASTER_COOKS.Item_Ticket it ON t.tick_numero = it.item_ticket_numero AND t.tick_tipo = it.item_tipo_id AND t.tick_sucursal_id = it.item_sucursal_id
JOIN MASTER_COOKS.Promocion_X_Ticket pxt ON pxt.promx_item_ticket_id = it.item_ticket_numero AND pxt.promx_item_tipo = it.item_tipo_id AND pxt.promx_item_sucursal_id = it.item_sucursal_id
JOIN MASTER_COOKS.Producto p ON p.prod_id = it.item_producto_id
JOIN MASTER_COOKS.BI_Dim_Categoria dcat ON p.prod_subcategoria_id = dcat.categoria_subcategoria
JOIN MASTER_COOKS.BI_Dim_Tiempo dti ON dti.tiempo_id = CONCAT(YEAR(t.tick_fecha_hora), RIGHT('0' + CAST(MONTH(t.tick_fecha_hora) AS VARCHAR(2)), 2))
GROUP BY dcat.categoria_id, dti.tiempo_id;

-- Poblar Fact_Pagos
INSERT INTO MASTER_COOKS.BI_Fact_Pagos (tiempo_id, medio_pago_id, sucursal_id, cliente_id, rango_id, importe_pago_en_cuotas, importe_pago_total, descuento_total)
SELECT
	dti.tiempo_id,
	p.pago_medio_de_pago_id,
	dsu.sucursal_id,
	dcl.cliente_id,
	dran.rango_id,
	SUM(dbo.devolverImporteDeCuotas(p.pago_importe, dp.deta_pago_id)),
	SUM(p.pago_importe),
	SUM(p.pago_desc_aplicado_mp)
FROM MASTER_COOKS.Pago p
JOIN MASTER_COOKS.BI_Dim_Tiempo dti ON dti.tiempo_id = CONCAT(YEAR(p.pago_fecha), RIGHT('0' + CAST(MONTH(p.pago_fecha) AS VARCHAR(2)), 2))
JOIN MASTER_COOKS.BI_Dim_Sucursal dsu ON dsu.sucursal_id = p.pago_ticket_sucursal
JOIN MASTER_COOKS.Ticket t ON t.tick_numero = p.pago_ticket_numero AND t.tick_sucursal_id = p.pago_ticket_sucursal AND t.tick_tipo = p.pago_ticket_tipo
JOIN MASTER_COOKS.BI_Dim_Cliente dcl ON dcl.cliente_id = CONCAT(t.tick_cliente_documento, t.tick_cliente_apellido)
JOIN MASTER_COOKS.BI_Dim_Rango_Etario dran ON dran.rango_id = dcl.cliente_rango_etario
LEFT JOIN MASTER_COOKS.Detalle_Pago dp ON dp.deta_pago_id = p.pago_id
LEFT JOIN MASTER_COOKS.Descuento_Aplicado_Por_MP damp ON damp.descx_pago_id = p.pago_id
GROUP BY dti.tiempo_id, p.pago_medio_de_pago_id, dsu.sucursal_id, dcl.cliente_id, dran.rango_id


-- Poblar Fact_Envio
INSERT INTO MASTER_COOKS.BI_Fact_Envio (tiempo_id, sucursal_id, rango_id, cliente_id, costo_envio_total, cantidad_envios, envios_cumplidos)
SELECT
    dti.tiempo_id,
    dsuc.sucursal_id,
    dran.rango_id,
	dcl.cliente_id,
    SUM(e.envi_costo),
    COUNT(*),
    SUM(CASE WHEN (CAST(e.envi_fecha_hora_entrega AS DATE) = e.envi_fecha_programada) THEN 1 ELSE 0 END)
FROM MASTER_COOKS.Envio e
JOIN MASTER_COOKS.Ticket t ON e.envi_ticket_numero = t.tick_numero AND e.envi_ticket_tipo = t.tick_tipo AND e.envi_ticket_sucursal = t.tick_sucursal_id
JOIN MASTER_COOKS.BI_Dim_Tiempo dti ON dti.tiempo_id = CONCAT(YEAR(t.tick_fecha_hora), RIGHT('0' + CAST(MONTH(t.tick_fecha_hora) AS VARCHAR(2)), 2))
JOIN MASTER_COOKS.BI_Dim_Sucursal dsuc ON dsuc.sucursal_id = t.tick_sucursal_id
JOIN MASTER_COOKS.BI_Dim_Cliente dcl ON dcl.cliente_id = CONCAT(t.tick_cliente_documento, t.tick_cliente_apellido)
JOIN MASTER_COOKS.BI_Dim_Rango_Etario dran ON dran.rango_id = dcl.cliente_rango_etario
JOIN MASTER_COOKS.BI_Dim_Ubicacion dub ON dub.ubicacion_id = dsuc.sucursal_ubicacion
GROUP BY dti.tiempo_id, dsuc.sucursal_id, dran.rango_id, dcl.cliente_id
GO

-- Crear vistas

-- 1. Ticket Promedio mensual. Valor promedio de las ventas (en $) según la localidad, año y mes.
-- Se calcula en función de la sumatoria del importe de las ventas sobre el total de las mismas.
CREATE VIEW MASTER_COOKS.BI_VW_TicketPromedioMensual AS
SELECT DISTINCT
    u.ubicacion_localidad as localidad,
    t.tiempo_anio as anio,
    t.tiempo_mes as mes,
    ROUND(SUM(fv.importe_total) / SUM(fv.cantidad_ventas),2) AS valor_promedio_de_ventas
FROM MASTER_COOKS.BI_Fact_Ventas fv
JOIN MASTER_COOKS.BI_Dim_Sucursal s ON s.sucursal_id = fv.sucursal_id
JOIN MASTER_COOKS.BI_Dim_Tiempo t ON t.tiempo_id = fv.tiempo_id
JOIN MASTER_COOKS.BI_Dim_Ubicacion u ON u.ubicacion_id = s.sucursal_ubicacion
GROUP BY u.ubicacion_localidad, t.tiempo_anio, t.tiempo_mes
GO

-- 2. Cantidad unidades promedio
CREATE VIEW MASTER_COOKS.BI_VW_UnidadesPromedioPorTurno AS
SELECT
    dt.tiempo_anio,
    dt.tiempo_cuatrimestre,
    dtur.turno_id,
	ROUND((sum(fv.cantidad_unidades) / sum(fv.cantidad_ventas)),2) as unidades_promedio
FROM MASTER_COOKS.BI_Fact_Ventas fv
JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fv.tiempo_id = dt.tiempo_id
JOIN MASTER_COOKS.BI_Dim_Turno dtur ON fv.turno_id = dtur.turno_id
GROUP BY dt.tiempo_anio, dt.tiempo_cuatrimestre, dtur.turno_id
GO

-- 3. Porcentaje anual de ventas registradas por rango etario del empleado según el tipo de caja para cada cuatrimestre.
--    Se calcula tomando la cantidad de ventas correspondientes sobre el total de ventas anual.
CREATE VIEW MASTER_COOKS.BI_VW_PorcentajeVentasRangoEtarioEmpleado AS
SELECT
    dt.tiempo_anio,
    dt.tiempo_cuatrimestre,
    de.empleado_rango_etario AS rango_etario_empleado,
    dc.tipo_caja_id,
    AVG(fv.importe_total) as porcentaje_anual_de_ventas
    ROUND(CAST(COUNT(*) AS FLOAT) / 
		CAST((
			SELECT COUNT(*) FROM MASTER_COOKS.BI_Fact_Ventas fv2 
			JOIN MASTER_COOKS.BI_Dim_Tiempo dt2 on fv2.tiempo_id = dt2.tiempo_id WHERE dt2.tiempo_anio = dt.tiempo_anio
			)AS FLOAT) * 100, 2) AS porcentaje_ventas
FROM MASTER_COOKS.BI_Fact_Ventas fv
JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fv.tiempo_id = dt.tiempo_id
JOIN MASTER_COOKS.BI_Dim_Empleado de ON de.empleado_id = fv.empleado_id
JOIN MASTER_COOKS.BI_Dim_Tipo_Caja dc ON fv.tipo_caja_id = dc.tipo_caja_id
GROUP BY dt.tiempo_anio, dt.tiempo_cuatrimestre, de.empleado_rango_etario, dc.tipo_caja_id
GO

-- 4.Cantidad de ventas registradas por turno para cada localidad según el mes de cada año.
CREATE VIEW MASTER_COOKS.BI_VW_VentasPorTurnoLocalidad AS
SELECT
    COUNT(*) AS cantidad_ventas,
    dtur.turno_id,
    du.ubicacion_localidad,
    dt.tiempo_mes,
    dt.tiempo_anio
FROM MASTER_COOKS.BI_Fact_Ventas fv
JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fv.tiempo_id = dt.tiempo_id
JOIN MASTER_COOKS.BI_Dim_Turno dtur ON fv.turno_id = dtur.turno_id
JOIN MASTER_COOKS.BI_Dim_Sucursal ds ON fv.sucursal_id = ds.sucursal_id
JOIN MASTER_COOKS.BI_Dim_Ubicacion du ON du.ubicacion_id = ds.sucursal_ubicacion
GROUP BY dt.tiempo_anio, dt.tiempo_mes, dtur.turno_id, du.ubicacion_localidad;
GO

-- 5.Porcentaje de descuento aplicados en función del total de los tickets según el mes de cada año.
CREATE VIEW MASTER_COOKS.BI_VW_PorcentajeDescuentoAplicado AS
SELECT
    fp.porcentaje_descuento,
    dt.tiempo_mes,
    dt.tiempo_anio
FROM MASTER_COOKS.BI_Fact_Promociones fp
JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fp.tiempo_id = dt.tiempo_id
GROUP BY dt.tiempo_anio, dt.tiempo_mes, fp.porcentaje_descuento;
GO

-- 6. Las tres categorías de productos con mayor descuento aplicado
CREATE VIEW MASTER_COOKS.BI_VW_Top3CategoriasDescuento AS
SELECT TOP 3
    dt.tiempo_anio,
    dt.tiempo_cuatrimestre,
    dc.categoria_id,
    SUM(fp.monto_descuento_promocion) as total_descuento_aplicado
FROM MASTER_COOKS.BI_Fact_Promociones fp
JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fp.tiempo_id = dt.tiempo_id
JOIN MASTER_COOKS.BI_Dim_Categoria dc ON fp.categoria_id = dc.categoria_id
GROUP BY dt.tiempo_anio, dt.tiempo_cuatrimestre, dc.categoria_id
ORDER BY
    dt.tiempo_anio,
    dt.tiempo_cuatrimestre,
    SUM(fp.monto_descuento_promocion) DESC;
GO
-- 7. Porcentaje de cumplimiento de envíos
CREATE VIEW MASTER_COOKS.BI_VW_CumplimientoEnvios AS
SELECT
    dt.tiempo_anio,
    dt.tiempo_mes,
    fe.sucursal_id,
    CAST(fe.envios_cumplidos AS FLOAT) / CAST(fe.cantidad_envios AS FLOAT) * 100 AS porcentaje_cumplimiento
FROM MASTER_COOKS.BI_Fact_Envio fe
JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fe.tiempo_id = dt.tiempo_id
GROUP BY dt.tiempo_anio, dt.tiempo_mes, fe.sucursal_id, CAST(fe.envios_cumplidos AS FLOAT) / CAST(fe.cantidad_envios AS FLOAT)
GO
-- 8. Cantidad de envíos por rango etario de clientes
CREATE VIEW MASTER_COOKS.BI_VW_EnviosPorRangoEtarioCliente AS
SELECT
    dt.tiempo_anio,
    dt.tiempo_cuatrimestre,
    dre.rango_id,
    sum(fe.cantidad_envios) AS cantidad_envios
FROM MASTER_COOKS.BI_Fact_Envio fe
JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fe.tiempo_id = dt.tiempo_id
JOIN MASTER_COOKS.BI_Dim_Cliente dc ON fe.cliente_id = dc.cliente_id
JOIN MASTER_COOKS.BI_Dim_Rango_Etario dre ON dc.cliente_rango_etario = dre.rango_id
GROUP BY dt.tiempo_anio, dt.tiempo_cuatrimestre, dre.rango_id;
GO

-- 9. Las 5 localidades con mayor costo de envío
--ESTA BIEN
CREATE VIEW MASTER_COOKS.BI_VW_Top5LocalidadesCostoEnvio AS
SELECT TOP 5
    du.ubicacion_localidad AS Localidad
	FROM MASTER_COOKS.BI_Fact_Envio env
JOIN MASTER_COOKS.BI_Dim_Cliente dc on env.cliente_id = dc.cliente_id
JOIN MASTER_COOKS.BI_Dim_Ubicacion du ON dc.cliente_ubicacion = du.ubicacion_id
GROUP BY du.ubicacion_localidad
ORDER BY SUM(env.costo_envio_total) DESC;
GO
-- 10. Las 3 sucursales con el mayor importe de pagos en cuotas
--CREO QUE VAN SOLO LOS MEDIO DE PAGO ID, LO DEMAS NO SE PIDE
CREATE VIEW MASTER_COOKS.BI_VW_Top3SucursalesPagosCuotas AS
SELECT TOP 3
        dt.tiempo_anio,
        dt.tiempo_mes,
        fp.sucursal_id,
        dmp.medio_pago_id,
        SUM(fp.importe_pago_en_cuotas) AS total_pagos_cuotas
    FROM MASTER_COOKS.BI_Fact_Pagos fp
    JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fp.tiempo_id = dt.tiempo_id
    JOIN MASTER_COOKS.BI_Dim_Medio_Pago dmp ON fp.medio_pago_id = dmp.medio_pago_id
    GROUP BY dt.tiempo_anio, dt.tiempo_mes, fp.sucursal_id, dmp.medio_pago_id
	order by SUM(fp.importe_pago_en_cuotas) DESC
GO

-- 11. Promedio de importe de la cuota en función del rango etareo del cliente
CREATE VIEW MASTER_COOKS.BI_VW_PromedioImporteCuotaPorRangoEtarioCliente AS
SELECT
    dre.rango_id,
    AVG(fp.importe_pago_en_cuotas) AS promedio_importe_cuota
FROM MASTER_COOKS.BI_Fact_Pagos fp
JOIN MASTER_COOKS.BI_Dim_Rango_Etario dre ON fp.rango_id = dre.rango_id
GROUP BY dre.rango_id;
GO

-- 12. Porcentaje de descuento aplicado por cada medio de pago
CREATE VIEW MASTER_COOKS.BI_VW_PorcentajeDescuentoPorMedioPago AS
SELECT
    dt.tiempo_anio,
    dt.tiempo_cuatrimestre,
    dmp.medio_pago_id,
    (SUM(fp.descuento_total) / (SUM(fp.importe_pago_total) + SUM(fp.descuento_total)) * 100) AS porcentaje_descuento
FROM MASTER_COOKS.BI_Fact_Pagos fp
JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fp.tiempo_id = dt.tiempo_id
JOIN MASTER_COOKS.BI_Dim_Medio_Pago dmp ON fp.medio_pago_id = dmp.medio_pago_id
GROUP BY dt.tiempo_anio, dt.tiempo_cuatrimestre, dmp.medio_pago_id;
GO

--Probar todas las views
SELECT * FROM MASTER_COOKS.BI_VW_TicketPromedioMensual;
SELECT * FROM MASTER_COOKS.BI_VW_UnidadesPromedioPorTurno;
SELECT * FROM MASTER_COOKS.BI_VW_PorcentajeVentasRangoEtarioEmpleado;
SELECT * FROM MASTER_COOKS.BI_VW_VentasPorTurnoLocalidad;
SELECT * FROM MASTER_COOKS.BI_VW_PorcentajeDescuentoAplicado;
SELECT * FROM MASTER_COOKS.BI_VW_Top3CategoriasDescuento;
SELECT * FROM MASTER_COOKS.BI_VW_CumplimientoEnvios;
SELECT * FROM MASTER_COOKS.BI_VW_EnviosPorRangoEtarioCliente;
SELECT * FROM MASTER_COOKS.BI_VW_Top5LocalidadesCostoEnvio;
SELECT * FROM MASTER_COOKS.BI_VW_Top3SucursalesPagosCuotas;
SELECT * FROM MASTER_COOKS.BI_VW_PromedioImporteCuotaPorRangoEtarioCliente;
SELECT * FROM MASTER_COOKS.BI_VW_PorcentajeDescuentoPorMedioPago;


SELECT * FROM MASTER_COOKS.BI_VW_TicketPromedioMensual;
SELECT
    SUM(t.tick_total) / COUNT(t.tick_numero) AS valor_promedio_ventas
FROM
    MASTER_COOKS.Ticket t
JOIN
    MASTER_COOKS.Sucursal s ON t.tick_sucursal_id = s.sucu_numero
JOIN
    MASTER_COOKS.Localidad l ON s.sucu_localidad_id = l.loca_nombre AND s.sucu_provincia_id = l.loca_provincia_id
WHERE
    l.loca_nombre = 'Colonia La Chispa'
    AND YEAR(t.tick_fecha_hora) = 2024
    AND MONTH(t.tick_fecha_hora) = 9;