INSERT INTO [MASTER_COOKS].[Sucursal] (sucu_numero, sucu_direccion, sucu_localidad_id, sucu_provincia_id)
SELECT DISTINCT
    CAST(dbo.ExtractSucursal(SUCURSAL_NOMBRE) AS DECIMAL(6,0)),
    CAST(SUCURSAL_DIRECCION AS VARCHAR(50)),
    CAST(SUCURSAL_LOCALIDAD AS VARCHAR(50)),
    CAST(SUCURSAL_PROVINCIA AS VARCHAR(60))
FROM [gd_esquema].[Maestra]
--WHERE SUCURSAL_NOMBRE IS NOT NULL;

INSERT INTO [MASTER_COOKS].[Supermercado] (supe_cuit, supe_nombre, supe_localidad_id, supe_provincia_id, supe_razon_social, supe_ing_brutos, supe_domicilio, supe_fecha_ini_actividad, supe_cond_fiscal, supe_sucursal_id)
SELECT DISTINCT
    CAST(SUPER_CUIT AS CHAR(13)),
    CAST(SUPER_NOMBRE AS VARCHAR(30)),
    CAST(SUPER_LOCALIDAD AS VARCHAR(50)),
    CAST(SUPER_PROVINCIA AS VARCHAR(60)),
    CAST(SUPER_RAZON_SOC AS VARCHAR(50)),
    CAST(dbo.ExtractIIBB(SUPER_INGR_BRUTOS) AS CHAR(9)),
    CAST(SUPER_DOMICILIO AS VARCHAR(50)),
    CAST(SUPER_FECHA_INI_ACTIVIDAD AS DATE),
    CAST(SUPER_CONDICION_FISCAL AS VARCHAR(50)),
    CAST(dbo.ExtractSucursal(SUCURSAL_NOMBRE) AS DECIMAL(6,0))
FROM [gd_esquema].[Maestra]
--WHERE SUPER_CUIT IS NOT NULL AND SUCU_NUMERO IS NOT NULL;

INSERT INTO [MASTER_COOKS].[Empleado]
(empl_legajo, empl_nombre, empl_apellido, empl_fecha_ingreso, empl_dni, empl_telefono, empl_mail, empl_fecha_nacimiento, empl_sucursal_id)
SELECT DISTINCT
    CAST(NEXT VALUE FOR [MASTER_COOKS].[seq_empleado_legajo] AS DECIMAL(6,0)) AS empl_legajo,
    CAST(EMPLEADO_NOMBRE AS VARCHAR(30)),
    CAST(EMPLEADO_APELLIDO AS VARCHAR(30)),
    CAST(EMPLEADO_FECHA_REGISTRO AS DATE),
    CAST(EMPLEADO_DNI AS DECIMAL(8,0)),
    CAST(EMPLEADO_TELEFONO AS VARCHAR(20)),
    CAST(EMPLEADO_MAIL AS VARCHAR(50)),
    CAST(EMPLEADO_FECHA_NACIMIENTO AS DATE),
    CAST(dbo.ExtractSucursal(SUCURSAL_NOMBRE) AS DECIMAL(6,0))
FROM [gd_esquema].[Maestra]
WHERE EMPLEADO_NOMBRE IS NOT NULL AND EMPLEADO_APELLIDO IS NOT NULL AND SUCURSAL_NOMBRE IS NOT NULL;

INSERT INTO [MASTER_COOKS].[Cliente] (clie_documento, clie_apellido, clie_nombre, clie_fecha_registro, clie_telefono, clie_mail, clie_fecha_nacimiento, clie_domicilio, clie_localidad_id, clie_provincia_id)
SELECT DISTINCT
    CAST(CLIENTE_DNI AS DECIMAL(8,0)),
    CAST(CLIENTE_APELLIDO AS VARCHAR(30)),
    CAST(CLIENTE_NOMBRE AS VARCHAR(30)),
    CAST(CLIENTE_FECHA_REGISTRO AS DATE),
    CAST(CLIENTE_TELEFONO AS VARCHAR(20)),
    CAST(CLIENTE_MAIL AS VARCHAR(50)),
    CAST(CLIENTE_FECHA_NACIMIENTO AS DATE),
    CAST(CLIENTE_DOMICILIO AS VARCHAR(50)),
    CAST(CLIENTE_LOCALIDAD AS VARCHAR(50)),
    CAST(CLIENTE_PROVINCIA AS VARCHAR(60))
FROM [gd_esquema].[Maestra]
--WHERE clie_documento IS NOT NULL and clie_apellido IS NOT NULL and clie_localidad IS NOT NULL and clie_provincia IS NOT NULL;

INSERT INTO [MASTER_COOKS].[Producto] (prod_subcategoria_id, prod_codigo, prod_descripcion, prod_precio_unitario, prod_marca_id)
SELECT DISTINCT
    CAST(dbo.ExtractSubCategoria(PRODUCTO_SUB_CATEGORIA) AS DECIMAL(8,0)),
    CAST(dbo.ExtractProductoNombre(PRODUCTO_CODIGO) AS DECIMAL(12,0)),
    CAST(PRODUCTO_DESCRIPCION AS VARCHAR(50)),
    CAST(PRODUCTO_PRECIO AS DECIMAL(10,2)),
    CAST(dbo.ExtractProductoMarca(PRODUCTO_MARCA) AS DECIMAL(8,0))
FROM [gd_esquema].[Maestra]
--WHERE prod_codigo IS NOT NULL and prod_categoria IS NOT NULL and prod_sub_categoria IS NOT NULL and prod_marca IS NOT NULL;

--funcion para calcular cantidad de productos en un ticket

INSERT INTO [MASTER_COOKS].[Ticket] (tick_numero, tick_tipo, tick_cliente_apellido, tick_cliente_documento, tick_caja_id, tick_fecha_hora, tick_total, tick_subtotal_productos, tick_total_descuento_promocion, tick_total_descuento_aplicado_mp, tick_total_envio, tick_cantidad_productos, tick_sucursal_id)
SELECT DISTINCT
    CAST(TICKET_NUMERO AS DECIMAL(18,0)),
    CAST(TICKET_TIPO_COMPROBANTE AS CHAR(1)),
    CAST(CLIENTE_APELLIDO AS VARCHAR(30)),
    CAST(CLIENTE_DNI AS DECIMAL(8,0)),
    CAST(CAJA_NUMERO AS DECIMAL(3,0)),
    CAST(TICKET_FECHA_HORA AS DATETIME),
    CAST(TICKET_TOTAL_TICKET AS DECIMAL(18,2)),
    CAST(TICKET_SUBTOTAL_PRODUCTOS AS DECIMAL(10,2)),
    CAST(TICKET_TOTAL_DESCUENTO_APLICADO AS DECIMAL(10,2)) ,
    CAST(TICKET_TOTAL_DESCUENTO_APLICADO_MP AS DECIMAL(10,2)),
    CAST(TICKET_TOTAL_ENVIO AS DECIMAL(10,2)),
    --CALCULAR TICKET_cantidad_productos,
    CAST(dbo.ExtractSucursal(SUCURSAL_NOMBRE) AS DECIMAL(6,0))
FROM [gd_esquema].[Maestra]
--WHERE tick_numero IS NOT NULL;

INSERT INTO [MASTER_COOKS].[Ticket](tick_vendedor_id)
SELECT DISTINCT
    CAST(empl_legajo AS DECIMAL(6,0))
FROM [MASTER_COOKS].[Empleado]
--WHERE empl_legajo IS NOT NULL;

INSERT INTO [MASTER_COOKS].[Provincia](prov_nombre)
SELECT DISTINCT
    CAST(SUCURSAL_PROVINCIA AS VARCHAR(60))
FROM [gd_esquema].[Maestra]
--WHERE PROVINCIA_NOMBRE IS NOT NULL;

INSERT INTO [MASTER_COOKS].[Localidad](loca_nombre, loca_provincia_id)
SELECT DISTINCT
    CAST(SUCURSAL_LOCALIDAD AS VARCHAR(50)),
    CAST(SUCURSAL_PROVINCIA AS VARCHAR(60))
FROM [gd_esquema].[Maestra]
--WHERE LOCALIDAD_NOMBRE IS NOT NULL AND LOCALIDAD_PROVINCIA IS NOT NULL;

INSERT INTO [MASTER_COOKS].[Descuento_Medio_Pago](desc_codigo, desc_descripcion, desc_fecha_inicio, desc_fecha_fin, desc_porcentaje, desc_importe_tope)
SELECT DISTINCT
    CAST(DESCUENTO_CODIGO AS DECIMAL(5,0)),
    CAST(DESCUENTO_DESCRIPCION AS VARCHAR(50)),
    CAST(DESCUENTO_FECHA_INICIO AS DATE),
    CAST(DESCUENTO_FECHA_FIN AS DATE),
    CAST(DESCUENTO_PORCENTAJE_DESC AS DECIMAL(3,2)),
    CAST(DESCUENTO_TOPE AS DECIMAL(8,2))
FROM [gd_esquema].[Maestra]
--WHERE DESCUENTO_CODIGO IS NOT NULL;

INSERT INTO [MASTER_COOKS].[Medio_De_Pago](medi_nombre, medi_descuento_mp, medi_descripcion)
SELECT DISTINCT
	CAST(PAGO_TIPO_MEDIO_PAGO AS VARCHAR(30)),
	CAST(DESCUENTO_CODIGO AS DECIMAL(5,0)),
	CAST(PAGO_MEDIO_PAGO AS VARCHAR(50))
FROM [gd_esquema].[Maestra]
--WHERE MEDIO_CODIGO IS NOT NULL;

--funcion para calcular el monto descontado

INSERT INTO [MASTER_COOKS].[Pago](pago_numero, pago_medio_de_pago_id, pago_ticket_numero, pago_ticket_tipo, pago_ticket_sucursal, pago_fecha, pago_importe, pago_detalle_id, pago_monto_descontado)
SELECT DISTINCT
    CAST(NEXT VALUE FOR [MASTER_COOKS].[seq_pago_numero] AS DECIMAL(18,0)),
    CAST(PAGO_TIPO_MEDIO_PAGO AS VARCHAR(30)),
    CAST(TICKET_NUMERO AS DECIMAL(18,0)),
    CAST(TICKET_TIPO_COMPROBANTE AS CHAR(1)),
    CAST(dbo.ExtractSucursal(SUCURSAL_NOMBRE) AS DECIMAL(6,0)),
    CAST(PAGO_FECHA AS DATE),
    CAST(PAGO_IMPORTE AS DECIMAL(18,2)),
    CAST(NEXT VALUE FOR [MASTER_COOKS].[seq_deta_codigo] AS DECIMAL(18,0)),
    --CALCULAR PAGO_MONTO_DESCONTADO
FROM [gd_esquema].[Maestra]
--WHERE PAGO_NUMERO IS NOT NULL;

INSERT INTO [MASTER_COOKS].[Estado_Envio] (esta_nombre)
SELECT DISTINCT ESTADO_NOMBRE
FROM [gd_esquema].[Maestra]
--WHERE ESTADO_NOMBRE IS NOT NULL;

INSERT INTO [MASTER_COOKS].[Envio] (envi_codigo, envi_ticket_numero, envi_ticket_tipo, envi_ticket_sucursal, envi_estado_id, envi_fecha_programada, envi_horario_inicio, envi_horario_fin, envi_fecha_hora_entrega ,envi_costo)
SELECT DISTINCT
    CAST(NEXT VALUE FOR [MASTER_COOKS].[seq_envio_codigo] AS DECIMAL(18,0)),
    CAST(TICKET_NUMERO AS DECIMAL(18,0)),
    CAST(TICKET_TIPO_COMPROBANTE AS CHAR(1)),
    CAST(dbo.ExtractSucursal(SUCURSAL_NOMBRE) AS DECIMAL(6,0)),
    CAST(ENVIO_ESTADO AS VARCHAR(50)),
    CAST(ENVIO_FECHA_PROGRAMADA AS DATE),
    CAST(ENVIO_HORARIO_INICIO AS TIME),
    CAST(ENVIO_HORARIO_FIN AS TIME),
    CAST(ENVIO_FECHA_HORA_ENTREGA AS DATETIME),
    CAST(ENVIO_COSTO AS DECIMAL(18,2))
FROM [gd_esquema].[Maestra]
--WHERE ENVIO_CODIGO IS NOT NULL;

INSERT INTO [MASTER_COOKS].[Promocion_X_Ticket] (promx_promocion_id, promx_tick_numero, promx_tick_tipo, promx_tick_sucursal_id, promx_tick_promocion_aplicada)
SELECT DISTINCT
    CAST(PROMO_CODIGO AS DECIMAL(4,0)),
    CAST(TICKET_NUMERO AS DECIMAL(18,0)),
    CAST(TICKET_TIPO_COMPROBANTE AS CHAR(1)),
    CAST(dbo.ExtractSucursal(SUCURSAL_NOMBRE) AS DECIMAL(6,0)),
    CAST(PROMO_APLICADA_DESCUENTO AS DECIMAL(10,2))
FROM [gd_esquema].[Maestra]

INSERT INTO [MASTER_COOKS].[Promocion] (prom_codigo, prom_regla_id, prom_descripcion, prom_fecha_inicio, prom_fecha_fin)
SELECT DISTINCT
    CAST(PROMO_CODIGO AS DECIMAL(4,0)),
    CAST(REGLA_DESCRIPCION AS VARCHAR(50)),
    CAST(PROMOCION_DESCRIPCION AS VARCHAR(50)),
    CAST(PROMOCION_FECHA_INICIO AS DATE),
    CAST(PROMOCION_FECHA_FIN AS DATE)
FROM [gd_esquema].[Maestra]

INSERT INTO [MASTER_COOKS].[Regla] (regl_descripcion, regl_porcentaje_descuento, regl_cantidad_aplicable_regla, regl_cantidad_aplicable_descuento, regl_cantidad_max, regl_misma_marca, regl_mismo_producto)
SELECT DISTINCT
    CAST(REGLA_DESCRIPCION AS VARCHAR(50)),
    CAST(REGLA_DESCUENTO_APLICABLE_PROD AS DECIMAL(3,2)),
    CAST(REGLA_CANT_APLICABLE_REGLA AS DECIMAL(4,0)),
    CAST(REGLA_CANT_APLICA_DESCUENTO AS DECIMAL(4,0)),
    CAST(REGLA_CANT_MAX_PROD AS DECIMAL(4,0)),
    CAST(REGLA_APLICA_MISMA_MARCA AS BIT),
    CAST(REGLA_APLICA_MISMO_PROD AS BIT)
FROM [gd_esquema].[Maestra]

INSERT INTO [MASTER_COOKS].[Marca] (marc_id)
SELECT DISTINCT
    CAST(PRODUCTO_MARCA AS DECIMAL(8,0))
FROM [gd_esquema].[Maestra]

INSERT INTO [MASTER_COOKS].[Categoria] (cate_codigo)
SELECT DISTINCT
    CAST(PRODUCTO_CATEGORIA AS DECIMAL(8,0))
FROM [gd_esquema].[Maestra]

INSERT INTO [MASTER_COOKS].[Subcategoria] (subc_codigo, subc_categoria_id)
SELECT DISTINCT
    CAST(PRODUCTO_SUB_CATEGORIA AS DECIMAL(8,0)),
    CAST(PRODUCTO_CATEGORIA AS DECIMAL(8,0))
FROM [gd_esquema].[Maestra]

INSERT INTO [MASTER_COOKS].[Tipo_Caja] (tipo_descripcion)
SELECT DISTINCT
    CAST(CAJA_TIPO AS VARCHAR(50))
FROM [gd_esquema].[Maestra]

INSERT INTO [MASTER_COOKS].[Caja] (caja_numero, caja_sucursal_id, caja_tipo_id)
SELECT DISTINCT
    CAST(CAJA_NUMERO AS DECIMAL(3,0)),
    CAST(dbo.ExtractSucursal(SUCURSAL_NOMBRE) AS DECIMAL(6,0)),
    CAST(CAJA_TIPO AS VARCHAR(50))
FROM [gd_esquema].[Maestra]

INSERT INTO [MASTER_COOKS].[Rebaja_Producto] (reba_producto_id, reba_promocion_id, reba_prod_promocion_aplicada)
SELECT DISTINCT
    CAST(dbo.ExtractProductoNombre(PRODUCTO_CODIGO) AS DECIMAL(12,0)),
    CAST(PROMO_CODIGO AS DECIMAL(4,0)),
    CAST(PROMO_APLICADA_DESCUENTO AS DECIMAL(8,2))
FROM [gd_esquema].[Maestra]

INSERT INTO [MASTER_COOKS].[Item_Ticket] (item_tipo_id, item_sucursal_id, item_ticket_numero, item_producto_id, item_cantidad, item_precio)
SELECT DISTINCT
    CAST(TICKET_TIPO_COMPROBANTE AS CHAR(1)),
    CAST(dbo.ExtractSucursal(SUCURSAL_NOMBRE) AS DECIMAL(6,0)),
    CAST(TICKET_NUMERO AS DECIMAL(18,0)),
    CAST(PRODUCTO_NOMBRE AS DECIMAL(12,0)),
    CAST(ITEM_CANTIDAD AS DECIMAL(4,0)),
    CAST(ITEM_PRECIO AS DECIMAL(10,2))
FROM [gd_esquema].[Maestra]

INSERT INTO [MASTER_COOKS].[Detalle_Pago] (deta_codigo, deta_cliente_documento, deta_cliente_apellido, deta_numero_tarjeta, deta_fecha_vencimiento_tarjeta, deta_cuotas)
SELECT DISTINCT
    CAST(NEXT VALUE FOR [MASTER_COOKS].[seq_deta_codigo] AS DECIMAL(18,0)),
    CAST(CLIENTE_DOCUMENTO AS DECIMAL(8,0)),
    CAST(CLIENTE_APELLIDO AS VARCHAR(30)),
    CAST(PAGO_TARJETA_NRO AS VARCHAR(18)),
    CAST(PAGO_TARJETA_FECHA_VENC AS DATE),
    CAST(PAGO_TARJETA_CUOTAS AS DECIMAL(3,0))
FROM [gd_esquema].[Maestra]