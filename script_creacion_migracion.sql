create schema [MASTER_COOKS]
go 

create table [MASTER_COOKS].[Sucursal] (
	sucu_numero decimal(6,0) primary key, 
	sucu_nombre varchar(30), 
	sucu_direccion varchar(50),
	sucu_localidad_id varchar(50),
    sucu_provincia_id varchar(60),
    foreign key (sucu_localidad_id, sucu_provincia_id) references [MASTER_COOKS].[Localidad](loca_nombre, loca_provincia),
)

create table [MASTER_COOKS].[Supermercado] (
	supe_cuit char(13) primary key, --
	supe_nombre varchar(30),
	supe_razon_social varchar(50),
	supe_ing_brutos char(9), -- castear
	supe_domicilio varchar(50),
	supe_fecha_ini_actividad date, --
	supe_cond_fiscal varchar(50),
	supe_sucursal_id char(5), --
	foreign key (supe_sucursal_id) references [MASTER_COOKS].[Sucursal](sucu_numero)
)

create table [MASTER_COOKS].[Localidad] (
    loca_nombre varchar(50),
    loca_provincia_id varchar(60),
    primary key (loca_nombre, loca_provincia),
    foreign key (loca_provincia_id) references [MASTER_COOKS].[Provincia](prov_nombre)
)

create table [MASTER_COOKS].[Provincia] (
    prov_nombre varchar(60) primary key
)

create table [MASTER_COOKS].[Empleado] (
    empl_legajo decimal(6,0) primary key, --se tiene que crear
    empl_nombre varchar(30),
    empl_apellido varchar(30),
    empl_fecha_ingreso date,
    empl_dni varchar(8),
    empl_telefono varchar(20),
    empl_mail varchar(50),
    empl_fecha_nacimiento date,
    empl_sucursal_id varchar(6),
    foreign key (empl_sucursal_id) references [MASTER_COOKS].[Sucursal](sucu_numero)
)

create table [MASTER_COOKS].[Cliente] (
    clie_documento decimal(8,0),
    clie_apellido varchar(30),
    clie_nombre varchar(30),
    clie_fecha_registro date,
    clie_telefono varchar(20),
    clie_mail varchar(50),
    clie_fecha_nacimiento date,
    clie_domicilio varchar(50),
    clie_localidad_id varchar(50),
    clie_provincia_id varchar(60),
    primary key (clie_documento, clie_apellido),
    foreign key (clie_localidad_id, clie_provincia_id) references [MASTER_COOKS].[Localidad](loca_nombre, loca_provincia)
)

create table [MASTER_COOKS].[Medio_De_Pago] (
    medi_codigo decimal(2,0) primary key,
    medi_descuento_id decimal(10,0),
    medi_descripcion varchar(30),
    foreign key (medi_descuento_id) references [MASTER_COOKS].[Descuento_Medio_Pago](desc_codigo)
)

create table [MASTER_COOKS].[Descuento_Medio_Pago] (
    desc_codigo decimal(10,0) primary key,
    desc_medio_pago_id decimal(2,0),
    desc_descripcion varchar(50),
    desc_fecha_inicio date,
    desc_fecha_fin date,
    desc_porcentaje decimal(3,2),
    desc_importe_tope decimal(8,2),
    foreign key (desc_medio_pago_id) references [MASTER_COOKS].[Medio_De_Pago](medi_codigo)
)

create table [MASTER_COOKS].[Ticket] (
    tick_numero decimal(18,0),
    tick_tipo char(1),
    tick_cliente_id decimal(8,0),
    tick_vendedor_id decimal(6,0),
    tick_caja_id decimal(3,0),
    tick_fecha_hora datetime,
    tick_total decimal(10,2),
    tick_subtotal_productos decimal(10,2),
    tick_total_descuento_aplicado decimal(10,2),
    tick_total_descuento_aplicado_mp decimal(10,2),
    tick_total_envio decimal(10,2),
    tick_cantidad_productos decimal(18,0),
    tick_sucursal decimal(18,0),
    primary key (tick_numero, tick_tipo, tick_sucursal),
    foreign key (tick_cliente_id) references [MASTER_COOKS].[Cliente](clie_documento),
    foreign key (tick_vendedor_id) references [MASTER_COOKS].[Empleado](empl_legajo),
    foreign key (tick_caja_id) references [MASTER_COOKS].[Caja](caja_numero)
)

create table [MASTER_COOKS].[Caja] (
    caja_numero decimal(3,0) primary key,
    caja_sucursal_id decimal(6,0),
    caja_tipo_id varchar(50),
    foreign key (caja_sucursal_id) references [MASTER_COOKS].[Sucursal](sucu_numero),
    foreign key (caja_tipo_id) references [MASTER_COOKS].[Tipo_Caja](tipo_nombre)
)

create table [MASTER_COOKS].[Tipo_Caja] (
    tipo_nombre varchar(50) primary key
)

create table [MASTER_COOKS].[Pago] (
    pago_numero decimal(18,0) primary key,
    pago_ticket_id decimal(18,0),
    pago_medio_de_pago_id decimal(2,0),
    pago_descuento_x_medio_id decimal(10,0),
    pago_fecha date,
    pago_detalle varchar(50),
    pago_importe decimal(18,0),
    pago_nro_tarjeta decimal(18,0),
    foreign key (pago_ticket_id) references [MASTER_COOKS].[Ticket](tick_numero),
    foreign key (pago_medio_de_pago_id) references [MASTER_COOKS].[Medio_De_Pago](medi_codigo),
    foreign key (pago_descuento_x_medio_id) references [MASTER_COOKS].[Descuento_Medio_Pago](desc_codigo)
)

create table [MASTER_COOKS].[Envio] (
    envi_codigo decimal(18,0) primary key,
    envi_ticket_id decimal(18,0),
    envi_fecha_programada date,
    envi_horario_inicio time, --ver tipo de dato
    envi_horario_fin time, --ver tipo de dato
    envi_costo decimal(18,2),
    envi_estado_id varchar(50),
    foreign key (envi_ticket_id) references [MASTER_COOKS].[Ticket](tick_numero)
    foreign key (envi_estado_id) references [MASTER_COOKS].[Estado_Envio](esta_nombre)
)

create table [MASTER_COOKS].[Estado_Envio] (
    esta_nombre varchar(50) primary key
)

create table [MASTER_COOKS].[Producto] (
    prod_codigo decimal(12,0) primary key,
    prod_subcategoria_id varchar(50),
    prod_nombre varchar(50),
    prod_precio_unitario decimal(10,2),
    prod_promocion decimal(4,0),
    prod_marca_id varchar(50),
    foreign key (prod_codigo, prod_promocion) references [MASTER_COOKS].[Rebaja_producto](reba_producto_id, reba_prod_promocion),
    foreign key (prod_subcategoria_id) references [MASTER_COOKS].[Subcategoria](subc_codigo),
    foreign key (prod_marca_id) references [MASTER_COOKS].[Marca](marc_id)
)

create table [MASTER_COOKS].[Categoria] (
    cate_codigo decimal(8,0) primary key,
    cate_nombre varchar(50)
)

create table [MASTER_COOKS].[Subcategoria] (
    subc_codigo decimal(8,0) primary key,
    subc_nombre varchar(50),
    subc_categoria_id decimal(8,0),
    foreign key (subc_categoria_id) references [MASTER_COOKS].[Categoria](cate_codigo)
)

create table [MASTER_COOKS].[Marca] (
    marc_id decimal(8,0) primary key,
    marc_nombre varchar(50)
)

create table [MASTER_COOKS].[Regla] (
    regl_descripcion varchar(50) primary key,
    regl_porcentaje_descuento decimal(3,2),
    regl_cantidad_aplicable_regla decimal(4,0),
    regl_cantidad_aplicable_descuento decimal(4,0),
    regl_cantidad_max decimal(4,0),
    regl_misma_marca bit,
    regl_mismo_producto bit
)

create table [MASTER_COOKS].[Promocion] (
    prom_codigo decimal(4,0) primary key,
    prom_producto_id decimal(12,0),
    prom_regla_id varchar(50),
    prom_descripcion varchar(50),
    prom_fecha_inicio date,
    prom_fecha_fin date
    foreign key (prom_producto_id) references [MASTER_COOKS].[Producto](prod_codigo),
    foreign key (prom_regla_id) references [MASTER_COOKS].[Regla](regl_descripcion)
)

create table [MASTER_COOKS].[Rebaja_producto] (
    reba_producto_id decimal(12,0) primary key,
    reba_promocion_id decimal(4,0),
    reba_prod_promocion_aplicada decimal(8,2),
    foreign key (reba_producto_id) references [MASTER_COOKS].[Producto](prod_codigo),
    foreign key (reba_promocion_id) references [MASTER_COOKS].[Promocion](prom_codigo)
)

create table [MASTER_COOKS].[Item_Ticket] (
    item_tipo_id char(1),
    item_sucursal_id decimal(6,0),
    item_numero_id decimal(18,0),
    item_producto_id decimal(12,0),
    item_cantidad decimal(4,0),
    item_precio decimal(10,2) ,
    foreign key (item_producto_id) references [MASTER_COOKS].[Producto](prod_codigo),
    foreign key (item_tipo_id, item_numero_id,item_sucursal_id) references [MASTER_COOKS].[Ticket](tick_tipo, tick_numero, tick_sucursal)
)

create table [MASTER_COOKS].[Promocion_X_Ticket] (
    promx_promocion_id decimal(4,0),
    promx_ticket_id decimal(18,0) ,
    promx_tick_promocion_aplicada decimal(8,2),
    foreign key (promx_promocion_id) references [MASTER_COOKS].[Promocion](prom_codigo),
    foreign key (promx_ticket_id) references [MASTER_COOKS].[Ticket](tick_numero)
)

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