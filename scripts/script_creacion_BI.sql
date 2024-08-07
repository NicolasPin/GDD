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

-- Dimensión Turnos
CREATE TABLE MASTER_COOKS.BI_Dim_Turno (
    turno_id CHAR(12) PRIMARY KEY,
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
	rango_id DECIMAL(2,0) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Rango_Etario(rango_id),
    turno_id CHAR(12) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Turno(turno_id),
    tipo_caja_id VARCHAR(50) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Tipo_Caja(tipo_caja_id),
	ubicacion_id VARCHAR(110) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Ubicacion(ubicacion_id),
    importe_total DECIMAL(12,2),
	cantidad_ventas DECIMAL(12,0),
    cantidad_unidades DECIMAL(12,0),
    PRIMARY KEY (tiempo_id, sucursal_id, rango_id, turno_id, tipo_caja_id, ubicacion_id)
);

-- Tabla de Hechos Promociones
CREATE TABLE MASTER_COOKS.BI_Fact_Promociones (
    categoria_id VARCHAR(20) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Categoria(categoria_id),
    tiempo_id VARCHAR(20) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Tiempo(tiempo_id),
    monto_descuento_promocion DECIMAL(18,2),
    porcentaje_descuento DECIMAL(5,2),
    PRIMARY KEY (categoria_id, tiempo_id)
);


-- Tabla de Hechos Pagos 
CREATE TABLE MASTER_COOKS.BI_Fact_Pagos (
    tiempo_id VARCHAR(20) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Tiempo(tiempo_id),
    medio_pago_id VARCHAR(50) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Medio_Pago(medio_pago_id),
	sucursal_id DECIMAL(6,0) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Sucursal(sucursal_id),
	rango_id DECIMAL(2,0) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Rango_Etario(rango_id),
	importe_pago_en_cuotas DECIMAL(12,2),
	importe_pago_total DECIMAL(12,2),
	descuento_total DECIMAL(12,2)
	PRIMARY KEY (tiempo_id, medio_pago_id, sucursal_id, rango_id)
);

-- Tabla de Hechos Envíos
CREATE TABLE MASTER_COOKS.BI_Fact_Envio (
    tiempo_id VARCHAR(20) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Tiempo(tiempo_id),
    sucursal_id DECIMAL(6,0) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Sucursal(sucursal_id),
	rango_id DECIMAL(2,0) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Rango_Etario(rango_id),
	ubicacion_id VARCHAR(110) FOREIGN KEY REFERENCES MASTER_COOKS.BI_Dim_Ubicacion(ubicacion_id),
    costo_envio_total DECIMAL(12,2),
    cantidad_envios INT,
    envios_cumplidos INT,
    PRIMARY KEY (tiempo_id, sucursal_id, rango_id, ubicacion_id)
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

-- Poblar Dim_Sucursal
INSERT INTO MASTER_COOKS.BI_Dim_Sucursal (sucursal_id, sucursal_ubicacion)
SELECT DISTINCT
    s.sucu_numero,
    CONCAT(s.sucu_provincia_id, s.sucu_localidad_id)
FROM MASTER_COOKS.Sucursal s;

-- Poblar Dim_Turno
INSERT INTO MASTER_COOKS.BI_Dim_Turno (turno_id ,turno_hora_inicio, turno_hora_fin)
VALUES
('08:00-12:00', 8, 12),
('12:00-16:00', 12, 16),
('16:00-20:00', 16, 20),
('Otro Horario', NULL, NULL)

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
INSERT INTO MASTER_COOKS.BI_Fact_Ventas (tiempo_id, sucursal_id, rango_id, turno_id, tipo_caja_id, ubicacion_id, importe_total, cantidad_ventas, cantidad_unidades)
SELECT DISTINCT
    dti.tiempo_id,
    dsu.sucursal_id,
	dra.rango_id,
    dtu.turno_id,
    dtc.tipo_caja_id,
	du.ubicacion_id,
    SUM(t.tick_total),
	COUNT(DISTINCT CONCAT(t.tick_numero,t.tick_sucursal_id,t.tick_tipo)),
    SUM(it.item_cantidad)
FROM MASTER_COOKS.Ticket t
JOIN MASTER_COOKS.BI_Dim_Tiempo dti ON dti.tiempo_id = CONCAT(YEAR(t.tick_fecha_hora), RIGHT('0' + CAST(MONTH(t.tick_fecha_hora) AS VARCHAR(2)), 2))
JOIN MASTER_COOKS.BI_Dim_Sucursal dsu ON dsu.sucursal_id = t.tick_sucursal_id
JOIN MASTER_COOKS.Empleado e ON e.empl_legajo = t.tick_vendedor_id
JOIN MASTER_COOKS.BI_Dim_Rango_Etario dra ON dra.rango_id = dbo.ExtractRangoEtario(e.empl_fecha_nacimiento, GETDATE())
JOIN MASTER_COOKS.Item_Ticket it ON t.tick_numero = it.item_ticket_numero AND t.tick_tipo = it.item_tipo_id AND t.tick_sucursal_id = it.item_sucursal_id
JOIN MASTER_COOKS.Caja caja ON caja.caja_sucursal_id = t.tick_sucursal_id AND t.tick_caja_numero = caja.caja_numero
JOIN MASTER_COOKS.BI_Dim_Tipo_Caja dtc ON dtc.tipo_caja_id = caja.caja_tipo_id
LEFT JOIN MASTER_COOKS.BI_Dim_Turno dtu ON dtu.turno_id = dbo.devolverTurno(t.tick_fecha_hora)
JOIN MASTER_COOKS.BI_Dim_Ubicacion du ON du.ubicacion_id = dsu.sucursal_ubicacion
GROUP BY dti.tiempo_id, dsu.sucursal_id, dra.rango_id, dtu.turno_id, dtc.tipo_caja_id, du.ubicacion_id;

-- Poblar Fact_Promociones
INSERT INTO MASTER_COOKS.BI_Fact_Promociones(categoria_id, tiempo_id, monto_descuento_promocion, porcentaje_descuento)
SELECT DISTINCT
	dcat.categoria_id,
	dti.tiempo_id,
	SUM(t.tick_total_descuento_promocion),
	SUM(pxt.promx_item_promocion_aplicada) * 100 / SUM(it.item_total)
FROM MASTER_COOKS.Ticket t
JOIN MASTER_COOKS.Item_Ticket it ON t.tick_numero = it.item_ticket_numero AND t.tick_tipo = it.item_tipo_id AND t.tick_sucursal_id = it.item_sucursal_id
JOIN MASTER_COOKS.Promocion_X_Ticket pxt ON pxt.promx_item_ticket_id = it.item_ticket_numero AND pxt.promx_item_tipo = it.item_tipo_id AND pxt.promx_item_sucursal_id = it.item_sucursal_id
JOIN MASTER_COOKS.Producto p ON p.prod_id = it.item_producto_id
JOIN MASTER_COOKS.BI_Dim_Categoria dcat ON p.prod_subcategoria_id = dcat.categoria_subcategoria
JOIN MASTER_COOKS.BI_Dim_Tiempo dti ON dti.tiempo_id = CONCAT(YEAR(t.tick_fecha_hora), RIGHT('0' + CAST(MONTH(t.tick_fecha_hora) AS VARCHAR(2)), 2))
GROUP BY dcat.categoria_id, dti.tiempo_id;

-- Poblar Fact_Pagos
INSERT INTO MASTER_COOKS.BI_Fact_Pagos (tiempo_id, medio_pago_id, sucursal_id, rango_id, importe_pago_en_cuotas, importe_pago_total, descuento_total)
SELECT
	dti.tiempo_id,
	p.pago_medio_de_pago_id,
	dsu.sucursal_id,
	dran.rango_id,
	SUM(dbo.devolverImporteDeCuotas(p.pago_importe, dp.deta_pago_id)),
	SUM(p.pago_importe),
	SUM(p.pago_desc_aplicado_mp)
FROM MASTER_COOKS.Pago p
JOIN MASTER_COOKS.BI_Dim_Tiempo dti ON dti.tiempo_id = CONCAT(YEAR(p.pago_fecha), RIGHT('0' + CAST(MONTH(p.pago_fecha) AS VARCHAR(2)), 2))
JOIN MASTER_COOKS.BI_Dim_Sucursal dsu ON dsu.sucursal_id = p.pago_ticket_sucursal
JOIN MASTER_COOKS.Ticket t ON t.tick_numero = p.pago_ticket_numero AND t.tick_sucursal_id = p.pago_ticket_sucursal AND t.tick_tipo = p.pago_ticket_tipo
JOIN MASTER_COOKS.Cliente c ON c.clie_documento = t.tick_cliente_documento AND c.clie_apellido = t.tick_cliente_apellido
JOIN MASTER_COOKS.BI_Dim_Rango_Etario dran ON dran.rango_id = dbo.ExtractRangoEtario(c.clie_fecha_nacimiento, GETDATE())
LEFT JOIN MASTER_COOKS.Detalle_Pago dp ON dp.deta_pago_id = p.pago_id
LEFT JOIN MASTER_COOKS.Descuento_Aplicado_Por_MP damp ON damp.descx_pago_id = p.pago_id
GROUP BY dti.tiempo_id, p.pago_medio_de_pago_id, dsu.sucursal_id, dran.rango_id


-- Poblar Fact_Envio
INSERT INTO MASTER_COOKS.BI_Fact_Envio (tiempo_id, sucursal_id, rango_id, ubicacion_id, costo_envio_total, cantidad_envios, envios_cumplidos)
SELECT
    dti.tiempo_id,
    dsuc.sucursal_id,
    dran.rango_id,
	du.ubicacion_id,
    SUM(e.envi_costo),
    COUNT(distinct e.envi_codigo),
    SUM(CASE WHEN (CAST(e.envi_fecha_hora_entrega AS DATE) <= CAST(e.envi_fecha_programada AS DATE)) THEN 1 END)
FROM MASTER_COOKS.Envio e
JOIN MASTER_COOKS.Ticket t ON e.envi_ticket_numero = t.tick_numero AND e.envi_ticket_tipo = t.tick_tipo AND e.envi_ticket_sucursal = t.tick_sucursal_id
JOIN MASTER_COOKS.BI_Dim_Tiempo dti ON dti.tiempo_id = CONCAT(YEAR(t.tick_fecha_hora), RIGHT('0' + CAST(MONTH(t.tick_fecha_hora) AS VARCHAR(2)), 2))
JOIN MASTER_COOKS.Cliente c ON c.clie_documento = t.tick_cliente_documento AND c.clie_apellido = t.tick_cliente_apellido
JOIN MASTER_COOKS.BI_Dim_Sucursal dsuc ON dsuc.sucursal_id = t.tick_sucursal_id
JOIN MASTER_COOKS.BI_Dim_Ubicacion du ON du.ubicacion_id = CONCAT(c.clie_provincia_id, c.clie_localidad_id)
JOIN MASTER_COOKS.BI_Dim_Rango_Etario dran ON dran.rango_id = dbo.ExtractRangoEtario(c.clie_fecha_nacimiento, GETDATE())
GROUP BY dti.tiempo_id, dsuc.sucursal_id, dran.rango_id, du.ubicacion_id
GO

-- Crear vistas

-- 1. Ticket Promedio mensual. Valor promedio de las ventas (en $) según la localidad, año y mes.
-- Se calcula en función de la sumatoria del importe de las ventas sobre el total de las mismas.
CREATE VIEW MASTER_COOKS.BI_VW_TicketPromedioMensual AS
SELECT DISTINCT
    u.ubicacion_localidad as localidad,
    t.tiempo_anio as anio,
    t.tiempo_mes as mes,
    CAST(SUM(fv.importe_total) / SUM(fv.cantidad_ventas) AS DECIMAL(12,2)) AS valor_promedio_de_ventas
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
    dtur.turno_id ,
	CAST((sum(fv.cantidad_unidades) / sum(fv.cantidad_ventas)) AS DECIMAL(12,2)) as unidades_promedio
FROM MASTER_COOKS.BI_Fact_Ventas fv
JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fv.tiempo_id = dt.tiempo_id
LEFT JOIN MASTER_COOKS.BI_Dim_Turno dtur ON fv.turno_id = dtur.turno_id
GROUP BY dt.tiempo_anio, dt.tiempo_cuatrimestre, dtur.turno_id
GO

-- 3. Porcentaje anual de ventas registradas por rango etario del empleado según el tipo de caja para cada cuatrimestre.
--    Se calcula tomando la cantidad de ventas correspondientes sobre el total de ventas anual.
CREATE VIEW MASTER_COOKS.BI_VW_PorcentajeVentasRangoEtarioEmpleado AS
SELECT
    dt.tiempo_anio,
    dt.tiempo_cuatrimestre,
    dre.rango_descripcion AS rango_etario_empleado,
    dc.tipo_caja_id,
    ROUND(CAST(COUNT(*) AS FLOAT) / 
		CAST((
			SELECT COUNT(*) FROM MASTER_COOKS.BI_Fact_Ventas fv2 
			JOIN MASTER_COOKS.BI_Dim_Tiempo dt2 on fv2.tiempo_id = dt2.tiempo_id WHERE dt2.tiempo_anio = dt.tiempo_anio
			)AS FLOAT) * 100, 2) AS porcentaje_ventas
FROM MASTER_COOKS.BI_Fact_Ventas fv
JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fv.tiempo_id = dt.tiempo_id
JOIN MASTER_COOKS.BI_Dim_Rango_Etario dre ON dre.rango_id = fv.rango_id
JOIN MASTER_COOKS.BI_Dim_Tipo_Caja dc ON fv.tipo_caja_id = dc.tipo_caja_id
GROUP BY dt.tiempo_anio, dt.tiempo_cuatrimestre, dre.rango_descripcion, dc.tipo_caja_id
GO

-- 4.Cantidad de ventas registradas por turno para cada localidad según el mes de cada año.
CREATE VIEW MASTER_COOKS.BI_VW_VentasPorTurnoLocalidad AS
SELECT
    du.ubicacion_localidad,
    dt.tiempo_anio,
    dt.tiempo_mes,
    dtur.turno_id,
    COUNT(*) AS cantidad_ventas
FROM MASTER_COOKS.BI_Fact_Ventas fv
JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fv.tiempo_id = dt.tiempo_id
JOIN MASTER_COOKS.BI_Dim_Turno dtur ON fv.turno_id = dtur.turno_id
JOIN MASTER_COOKS.BI_Dim_Ubicacion du ON du.ubicacion_id = fv.ubicacion_id
GROUP BY du.ubicacion_localidad, dt.tiempo_anio, dt.tiempo_mes, dtur.turno_id;
GO

-- 5.Porcentaje de descuento aplicados en función del total de los tickets según el mes de cada año.
CREATE VIEW MASTER_COOKS.BI_VW_PorcentajeDescuentoAplicado AS
SELECT
    dt.tiempo_anio,
    dt.tiempo_mes,
    CAST((AVG(fp.porcentaje_descuento)) AS decimal (5,2)) AS porcentaje_descuento_promedio
FROM MASTER_COOKS.BI_Fact_Promociones fp
JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fp.tiempo_id = dt.tiempo_id
GROUP BY dt.tiempo_anio, dt.tiempo_mes;
GO

-- 6. Las tres categorías de productos con mayor descuento aplicado
CREATE VIEW MASTER_COOKS.BI_VW_Top3CategoriasDescuento AS
SELECT TOP 3
    dc.categoria_id,
    dt.tiempo_anio,
    dt.tiempo_cuatrimestre
FROM MASTER_COOKS.BI_Fact_Promociones fp
JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fp.tiempo_id = dt.tiempo_id
JOIN MASTER_COOKS.BI_Dim_Categoria dc ON fp.categoria_id = dc.categoria_id
GROUP BY dt.tiempo_anio, dt.tiempo_cuatrimestre, dc.categoria_id
ORDER BY
    SUM(fp.monto_descuento_promocion) DESC;
GO

-- 7. Porcentaje de cumplimiento de envíos
CREATE VIEW MASTER_COOKS.BI_VW_CumplimientoEnvios AS
SELECT
    dt.tiempo_anio,
    dt.tiempo_mes,
    fe.sucursal_id,
    SUM(fe.envios_cumplidos) * 100 / SUM(fe.cantidad_envios) AS porcentaje_cumplimiento
FROM MASTER_COOKS.BI_Fact_Envio fe
JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fe.tiempo_id = dt.tiempo_id
GROUP BY dt.tiempo_anio, dt.tiempo_mes, fe.sucursal_id
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
JOIN MASTER_COOKS.BI_Dim_Rango_Etario dre ON fe.rango_id = dre.rango_id
GROUP BY dt.tiempo_anio, dt.tiempo_cuatrimestre, dre.rango_id;
GO

-- 9. Las 5 localidades con mayor costo de envío
CREATE VIEW MASTER_COOKS.BI_VW_Top5LocalidadesCostoEnvio AS
SELECT TOP 5
    du.ubicacion_localidad AS Localidad
	FROM MASTER_COOKS.BI_Fact_Envio env
JOIN MASTER_COOKS.BI_Dim_Ubicacion du ON env.ubicacion_id = du.ubicacion_id
GROUP BY du.ubicacion_localidad
ORDER BY SUM(env.costo_envio_total) DESC;
GO

-- 10. Las 3 sucursales con el mayor importe de pagos en cuotas
CREATE VIEW MASTER_COOKS.BI_VW_Top3SucursalesPagosCuotas AS
SELECT TOP 3
        dt.tiempo_anio,
        dt.tiempo_mes,
        dmp.medio_pago_id,
        fp.sucursal_id
    FROM MASTER_COOKS.BI_Fact_Pagos fp
    JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fp.tiempo_id = dt.tiempo_id
    JOIN MASTER_COOKS.BI_Dim_Medio_Pago dmp ON fp.medio_pago_id = dmp.medio_pago_id
    GROUP BY dt.tiempo_anio, dt.tiempo_mes, fp.sucursal_id, dmp.medio_pago_id
	ORDER BY SUM(fp.importe_pago_en_cuotas) DESC
GO

-- 11. Promedio de importe de la cuota en función del rango etareo del cliente
CREATE VIEW MASTER_COOKS.BI_VW_PromedioImporteCuotaPorRangoEtarioCliente AS
SELECT
    dre.rango_descripcion as rango_etario_cliente,
    CAST(AVG(fp.importe_pago_en_cuotas) AS DECIMAL (12,2)) AS promedio_importe_cuota
FROM MASTER_COOKS.BI_Fact_Pagos fp
JOIN MASTER_COOKS.BI_Dim_Rango_Etario dre ON fp.rango_id = dre.rango_id
GROUP BY dre.rango_descripcion;
GO

-- 12. Porcentaje de descuento aplicado por cada medio de pago
CREATE VIEW MASTER_COOKS.BI_VW_PorcentajeDescuentoPorMedioPago AS
SELECT
    dt.tiempo_anio,
    dt.tiempo_cuatrimestre,
    dmp.medio_pago_id,
    CAST((SUM(fp.descuento_total) / (SUM(fp.importe_pago_total) + SUM(fp.descuento_total)) * 100) AS DECIMAL (3,2)) AS porcentaje_descuento
FROM MASTER_COOKS.BI_Fact_Pagos fp
JOIN MASTER_COOKS.BI_Dim_Tiempo dt ON fp.tiempo_id = dt.tiempo_id
JOIN MASTER_COOKS.BI_Dim_Medio_Pago dmp ON fp.medio_pago_id = dmp.medio_pago_id
GROUP BY dt.tiempo_anio, dt.tiempo_cuatrimestre, dmp.medio_pago_id;
GO
