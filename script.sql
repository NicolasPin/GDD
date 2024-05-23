--Agregar sucu_provincia?
INSERT para la tabla Sucursal
INSERT INTO [MASTER_COOKS].[Sucursal] (sucu_nombre, sucu_direccion, sucu_localidad)
SELECT  SUCURSAL_NOMBRE, SUCURSAL_DIRECCION, SUCURSAL_LOCALIDAD  --SUCURSAL_NUMERO no esta 
FROM [gd_esquema].[Maestra]
WHERE sucu_numero IS NOT NULL and sucu_localidad IS NOT NULL;

-- INSERT para la tabla Supermercado
INSERT INTO [MASTER_COOKS].[Supermercado] (supe_cuit, supe_nombre, supe_razon_social, supe_ing_brutos, supe_domicilio, supe_fecha_ini_actividad, supe_cond_fiscal, supe_sucursal) -- supe_sucursal(FK)
SELECT SUPER_CUIT, SUPER_NOMBRE, SUPER_RAZON_SOC, SUPER_IIBB, SUPER_DOMICILIO, SUPER_FECHA_INI_ACTIVIDAD, SUPER_CONDICION_FISCAL, SUCU_NUMERO
FROM [gd_esquema].[Maestra]
WHERE supe_cuit IS NOT NULL and supe_sucursal IS NOT NULL; 

-- INSERT para la tabla Empleado
INSERT INTO [MASTER_COOKS].[Empleado] ( empl_nombre, empl_apellido, empl_fecha_ingreso, empl_dni, empl_telefono, empl_mail, empl_fecha_nacimiento, empl_sucursal)
SELECT  EMPLEADO_NOMBRE, EMPLEADO_APELLIDO, EMPLEADO_FECHA_INGRESO, EMPLEADO_DNI, EMPLEADO_TELEFONO, EMPLEADO_MAIL, EMPLEADO_FECHA_NACIMIENTO, SUCU_NUMERO --EMPL_LEGAJO no esta
FROM [gd_esquema].[Maestra]
WHERE empl_legajo IS NOT NULL and empl_sucursal IS NOT NULL;

-- INSERT para la tabla Cliente
INSERT INTO [MASTER_COOKS].[Cliente] (clie_documento, clie_apellido, clie_nombre, clie_fecha_registro, clie_telefono, clie_mail, clie_fecha_nacimiento, clie_domicilio, clie_localidad)
SELECT CLIENTE_DOCUMENTO, CLIENTE_APELLIDO, CLIENTE_NOMBRE, CLIENTE_FECHA_REGISTRO, CLIENTE_TELEFONO, CLIENTE_MAIL, CLIENTE_FECHA_NACIMIENTO, CLIENTE_DOMICILIO, CLIENTE_LOCALIDAD
FROM [gd_esquema].[Maestra]
WHERE clie_documento IS NOT NULL and clie_apellido IS NOT NULL and clie_localidad IS NOT NULL and clie_provincia IS NOT NULL;   

-- INSERT para la tabla Producto
INSERT INTO [MASTER_COOKS].[Producto] (prod_categoria, prod_subcategoria, prod_nombre, prod_precio_unitario, prod_marca)
SELECT  PRODUCTO_CATEGORIA, PRODUCTO_SUB_CATEGORIA, PRODUCTO_NOMBRE, PRODUCTO_PRECIO, PRODUCTO_MARCA --PRODUCTO_PROMOCION    no esta en tabla maestra
FROM [gd_esquema].[Maestra]
WHERE prod_codigo IS NOT NULL and prod_categoria IS NOT NULL and prod_sub_categoria IS NOT NULL and prod_marca IS NOT NULL;

-- INSERT para la tabla Ticket
INSERT INTO [MASTER_COOKS].[Ticket] (tick_numero, tick_tipo, tick_cliente, tick_vendedor, tick_caja, tick_fecha_hora, tick_total, tick_subtotal_productos, tick_total_descuento_aplicado, tick_total_descuento_aplicado_mp, tick_total_envio, tick_cantidad_productos, tick_sucursal)
SELECT TICKET_numero, TICKET_tipo, TICKET_cliente, TICKET_vendedor, TICKET_caja, TICKET_fecha_hora, TICKET_total, TICKET_subtotal_productos, TICKET_total_descuento_aplicado, TICKET_total_descuento_aplicado_mp, TICKET_total_envio, TICKET_cantidad_productos, TICKET_sucursal
FROM [gd_esquema].[Maestra]
WHERE tick_numero IS NOT NULL;

INSERT INTO [MASTER_COOKS].[Provincia] (prov_nombre)
SELECT DISTINCT PROVINCIA_NOMBRE
FROM [gd_esquema].[MAESTRA]
WHERE PROVINCIA_NOMBRE IS NOT NULL;

-- INSERT para la tabla Localidad
INSERT INTO [MASTER_COOKS].[Localidad] (loca_nombre, loca_provincia)
SELECT DISTINCT LOCALIDAD_NOMBRE, LOCALIDAD_PROVINCIA
FROM [gd_esquema].[MAESTRA]
WHERE LOCALIDAD_NOMBRE IS NOT NULL AND LOCALIDAD_PROVINCIA IS NOT NULL;

-- INSERT para la tabla Descuento_Medio_Pago
INSERT INTO [MASTER_COOKS].[Descuento_Medio_Pago] (desc_codigo, desc_medio_pago, desc_descripcion, desc_fecha_inicio, desc_fecha_fin, desc_porcentaje, desc_importe_tope)
SELECT DISTINCT DESCUENTO_CODIGO, DESCUENTO_MEDIO_PAGO, DESCUENTO_DESCRIPCION, DESCUENTO_FECHA_INICIO, DESCUENTO_FECHA_FIN, DESCUENTO_PORCENTAJE, DESCUENTO_IMPORTE_TOPE
FROM [gd_esquema].[MAESTRA]
WHERE DESCUENTO_CODIGO IS NOT NULL;

-- INSERT para la tabla Medio_De_Pago
INSERT INTO [MASTER_COOKS].[Medio_De_Pago] (medi_codigo, medi_descuento, medi_tipo)
SELECT DISTINCT MEDIO_CODIGO, MEDIO_DESCUENTO, MEDIO_TIPO
FROM [gd_esquema].[MAESTRA]
WHERE MEDIO_CODIGO IS NOT NULL;

-- INSERT para la tabla Pago
INSERT INTO [MASTER_COOKS].[Pago] (pago_numero, pago_ticket, pago_medio_de_pago, pago_descuento_x_medio, pago_fecha, pago_detalle, pago_importe, pago_nro_tarjeta)
SELECT DISTINCT PAGO_NUMERO, PAGO_TICKET, PAGO_MEDIO_DE_PAGO, PAGO_DESCUENTO_X_MEDIO, PAGO_FECHA, PAGO_DETALLE, PAGO_IMPORTE, PAGO_NRO_TARJETA
FROM [gd_esquema].[MAESTRA]
WHERE PAGO_NUMERO IS NOT NULL;

-- INSERT para la tabla Estado_Envio
INSERT INTO [MASTER_COOKS].[Estado_Envio] (esta_nombre)
SELECT DISTINCT ESTADO_NOMBRE
FROM [gd_esquema].[MAESTRA]
WHERE ESTADO_NOMBRE IS NOT NULL;

-- INSERT para la tabla Envio
INSERT INTO [MASTER_COOKS].[Envio] (envi_codigo, envi_ticket, envi_fecha_programada, envi_horario_inicio, envi_horario_fin, envi_costo, envi_estado)
SELECT DISTINCT ENVIO_CODIGO, ENVIO_TICKET, ENVIO_FECHA_PROGRAMADA, ENVIO_HORARIO_INICIO, ENVIO_HORARIO_FIN, ENVIO_COSTO, ENVIO_ESTADO
FROM [gd_esquema].[MAESTRA]
WHERE ENVIO_CODIGO IS NOT NULL;