use GD1C2024
go
create schema MASTER_COOKS
authorization dbo;
go

create table MASTER_COOKS.Provincia (
    prov_nombre varchar(60) primary key
)

create table MASTER_COOKS.Localidad (
    loca_nombre varchar(50),
    loca_provincia_id varchar(60),
    primary key (loca_nombre, loca_provincia_id),
    foreign key (loca_provincia_id) references MASTER_COOKS.Provincia(prov_nombre)
)

create table MASTER_COOKS.Supermercado (
	supe_cuit char(13) primary key,
	supe_nombre varchar(30) null,
	supe_razon_social varchar(50) null,
	supe_ing_brutos char(9) null,
	supe_domicilio varchar(50) null,
	supe_fecha_ini_actividad date null,
	supe_cond_fiscal varchar(50) null,
    supe_localidad_id varchar(50) null,
    supe_provincia_id varchar(60) null,
    foreign key (supe_localidad_id, supe_provincia_id) references MASTER_COOKS.Localidad(loca_nombre, loca_provincia_id)
)

create table MASTER_COOKS.Sucursal (
	sucu_numero decimal(6,0) primary key,
	sucu_direccion varchar(50) null,
	sucu_supermercado_id char(13) null,
	sucu_localidad_id varchar(50) null,
    sucu_provincia_id varchar(60) null,
	foreign key (sucu_supermercado_id) references MASTER_COOKS.Supermercado(supe_cuit),
    foreign key (sucu_localidad_id, sucu_provincia_id) references MASTER_COOKS.Localidad(loca_nombre, loca_provincia_id)
)

create table MASTER_COOKS.Empleado (
    empl_legajo varchar(60) primary key, --es un concat de empl_dni y empl_telefono
    empl_nombre varchar(30) null,
    empl_apellido varchar(30) null,
    empl_fecha_ingreso date null,
    empl_dni decimal(8,0) null,
    empl_telefono varchar(20) null,
    empl_mail nvarchar(50) null,
    empl_fecha_nacimiento date null,
    empl_sucursal_id decimal(6,0) null,
    foreign key (empl_sucursal_id) references MASTER_COOKS.Sucursal(sucu_numero)
)


create table MASTER_COOKS.Tipo_Caja (
    tipo_descripcion varchar(50) primary key
)

create table MASTER_COOKS.Caja (
    caja_numero decimal(3,0),
    caja_sucursal_id decimal(6,0),
    caja_tipo_id varchar(50) null,
	primary key (caja_numero, caja_sucursal_id),
    foreign key (caja_sucursal_id) references MASTER_COOKS.Sucursal(sucu_numero),
    foreign key (caja_tipo_id) references MASTER_COOKS.Tipo_Caja(tipo_descripcion)
)


create table MASTER_COOKS.Cliente (
    clie_documento decimal(8,0),
    clie_apellido varchar(30),
    clie_nombre varchar(30) null,
    clie_fecha_registro date null,
    clie_telefono varchar(20) null,
    clie_mail nvarchar(50) null,
    clie_fecha_nacimiento date null,
    clie_domicilio varchar(50) null,
    clie_localidad_id varchar(50) null,
    clie_provincia_id varchar(60) null,
    primary key (clie_documento, clie_apellido),
    foreign key (clie_localidad_id, clie_provincia_id) references MASTER_COOKS.Localidad(loca_nombre, loca_provincia_id)
)

create table MASTER_COOKS.Ticket (
    tick_numero decimal(18,0),
    tick_tipo char(1),
    tick_cliente_documento decimal(8,0) null,
	tick_cliente_apellido varchar(30) null,
    tick_vendedor_id varchar(60) null,
    tick_caja_numero decimal(3,0) null,
    tick_fecha_hora datetime null,
    tick_total decimal(18,2) null,
    tick_subtotal_productos decimal(10,2) null,
    tick_total_descuento_promocion decimal(10,2) null,
    tick_total_descuento_aplicado_mp decimal(10,2) null,
    tick_total_envio decimal(10,2) null,
    tick_sucursal_id decimal(6,0),
    primary key (tick_numero, tick_tipo, tick_sucursal_id),
    foreign key (tick_cliente_documento, tick_cliente_apellido) references MASTER_COOKS.Cliente(clie_documento, clie_apellido),
    foreign key (tick_vendedor_id) references MASTER_COOKS.Empleado(empl_legajo),
    foreign key (tick_caja_numero, tick_sucursal_id) references MASTER_COOKS.Caja(caja_numero, caja_sucursal_id),
	foreign key (tick_sucursal_id) references MASTER_COOKS.Sucursal(sucu_numero)
)

create table MASTER_COOKS.Tipo_Medio_Pago (
    tipo_id nvarchar(30) primary key
)
create table MASTER_COOKS.Medio_De_Pago (
    medi_descripcion nvarchar(50) primary key,
    medi_tipo nvarchar(30)
	foreign key (medi_tipo) references MASTER_COOKS.Tipo_Medio_Pago(tipo_id)
)

create table MASTER_COOKS.Descuento_Medio_Pago(
    desc_codigo decimal(5,0) primary key,
    desc_descripcion varchar(50) null,
    desc_fecha_inicio date null,
    desc_fecha_fin date null,
    desc_porcentaje decimal(3,2) null,
    desc_importe_tope decimal(8,2) null,
	desc_medio_pago nvarchar(50) null,
	foreign key (desc_medio_pago) references MASTER_COOKS.Medio_De_Pago(medi_descripcion)
)

create table MASTER_COOKS.Pago (
	pago_id varchar(60) primary key, --es un concat de pago ticket numero y pago ticket_sucursal
	pago_ticket_numero decimal(18,0),
	pago_fecha date,
	pago_medio_de_pago_id nvarchar(50) null,
	pago_ticket_tipo char(1) null,
	pago_ticket_sucursal decimal(6,0) null,
    pago_importe decimal(18,2) null,
	pago_desc_aplicado_mp decimal(10,2) null,
	foreign key (pago_medio_de_pago_id) references MASTER_COOKS.Medio_De_Pago(medi_descripcion),
	foreign key(pago_ticket_numero, pago_ticket_tipo, pago_ticket_sucursal) references MASTER_COOKS.Ticket(tick_numero, tick_tipo, tick_sucursal_id)
)

create table MASTER_COOKS.Descuento_Aplicado_Por_MP (
	descx_pago_id varchar(60),
	descx_descuento_id decimal(5,0),
	primary key (descx_pago_id, descx_descuento_id),
	foreign key (descx_pago_id) references MASTER_COOKS.Pago(pago_id),
	foreign key(descx_descuento_id) references MASTER_COOKS.Descuento_Medio_Pago(desc_codigo)
)

create table MASTER_COOKS.Detalle_Pago (
	deta_numero_tarjeta varchar(18),
	deta_pago_id varchar(60),
    deta_cliente_documento decimal(8,0) null,
    deta_cliente_apellido varchar(30) null,
    deta_fecha_vencimiento_tarjeta date null,
    deta_cuotas decimal(3,0) null,
	primary key (deta_numero_tarjeta, deta_pago_id),
	foreign key (deta_pago_id) references MASTER_COOKS.Pago(pago_id),
    foreign key (deta_cliente_documento, deta_cliente_apellido) references MASTER_COOKS.Cliente(clie_documento, clie_apellido)
)

create table MASTER_COOKS.Estado_Envio (
    esta_descripcion varchar(50) primary key
)

create table MASTER_COOKS.Envio (
    envi_codigo varchar(100) primary key, -- concat de ticket_numero, ticket_tipo, sucursal_id, envio_fecha_entrega
    envi_ticket_numero decimal(18,0) null,
	envi_ticket_tipo char(1) null,
	envi_ticket_sucursal decimal(6,0) null,
    envi_fecha_programada datetime null,
    envi_horario_inicio varchar(2) null,
    envi_horario_fin varchar(2) null,
    envi_fecha_hora_entrega datetime null,
    envi_costo decimal(18,2) null,
    envi_estado_id varchar(50) null,
    foreign key (envi_ticket_numero, envi_ticket_tipo, envi_ticket_sucursal) references MASTER_COOKS.Ticket(tick_numero, tick_tipo, tick_sucursal_id),
    foreign key (envi_estado_id) references MASTER_COOKS.Estado_Envio(esta_descripcion)
)

create table MASTER_COOKS.Categoria (
    cate_codigo decimal(8,0) primary key
)

create table MASTER_COOKS.Subcategoria (
    subc_id int identity (1,1) primary key,
	subc_categoria decimal(8,0),
	subc_codigo decimal(8,0)
	foreign key (subc_categoria) references MASTER_COOKS.Categoria(cate_codigo)
)

create table MASTER_COOKS.Marca (
    marc_id decimal(12,0) primary key
)

create table MASTER_COOKS.Regla (
    regl_descripcion varchar(50) primary key,
    regl_porcentaje_descuento decimal(3,2) null,
    regl_cantidad_aplicable_regla decimal(4,0) null,
    regl_cantidad_aplicable_descuento decimal(4,0) null,
    regl_cantidad_max decimal(4,0) null,
    regl_misma_marca varchar(1) null,
    regl_mismo_producto varchar(1) null
)

CREATE TABLE MASTER_COOKS.Promocion (
    prom_codigo decimal(4,0) primary key,
    prom_regla_id varchar(50) null,
    prom_descripcion varchar(50) null,
    prom_fecha_inicio date null,
    prom_fecha_fin date null,
    foreign key (prom_regla_id) references MASTER_COOKS.Regla(regl_descripcion)
)

CREATE TABLE MASTER_COOKS.Producto (
    prod_id int identity (1,1) primary key,
	prod_subcategoria_id int,
	prod_marca_id decimal(12,0),
	prod_codigo decimal(12,0),
    prod_precio_unitario decimal(10,2),
	foreign key (prod_marca_id) references MASTER_COOKS.Marca(marc_id),
	foreign key (prod_subcategoria_id) references MASTER_COOKS.Subcategoria(subc_id)
)


CREATE TABLE MASTER_COOKS.Rebaja_Producto (
    reba_producto_id int,
    reba_promocion_id decimal(4,0),
    reba_prod_promocion_aplicada decimal(8,2),
    primary key (reba_producto_id, reba_promocion_id, reba_prod_promocion_aplicada),
    foreign key (reba_producto_id) references MASTER_COOKS.Producto(prod_id),
    foreign key (reba_promocion_id) references MASTER_COOKS.Promocion(prom_codigo)
)

create table MASTER_COOKS.Item_Ticket (
    item_tipo_id char(1),
    item_sucursal_id decimal(6,0),
    item_ticket_numero decimal(18,0),
    item_producto_id int,
    item_cantidad decimal(4,0),
    item_precio decimal(10,2) null,
	item_total decimal(18,2) null,
    primary key (item_tipo_id, item_sucursal_id, item_ticket_numero, item_producto_id, item_cantidad),
    foreign key (item_producto_id) references MASTER_COOKS.Producto(prod_id),
    foreign key (item_ticket_numero, item_tipo_id, item_sucursal_id) references MASTER_COOKS.Ticket(tick_numero, tick_tipo, tick_sucursal_id)
)

create table MASTER_COOKS.Promocion_X_Ticket (
    promx_promocion_id decimal(4,0),
    promx_item_tipo char(1),
    promx_item_sucursal_id decimal(6,0),
    promx_item_ticket_id decimal(18,0),
	promx_item_prod_id int,
	promx_item_cantidad decimal(4),
    promx_item_promocion_aplicada decimal(10,2)
    primary key (promx_promocion_id, promx_item_tipo, promx_item_sucursal_id, promx_item_ticket_id, promx_item_prod_id, promx_item_cantidad, promx_item_promocion_aplicada),
    foreign key (promx_promocion_id) references MASTER_COOKS.Promocion(prom_codigo),
    foreign key (promx_item_tipo, promx_item_sucursal_id, promx_item_ticket_id, promx_item_prod_id, promx_item_cantidad) references MASTER_COOKS.Item_Ticket(item_tipo_id, item_sucursal_id, item_ticket_numero, item_producto_id, item_cantidad)
)

---------FUNCTIONS
GO
CREATE FUNCTION dbo.ExtractSucursal(
    @input NVARCHAR(255)
)
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @output NVARCHAR(255);

    SET @output = REPLACE(@input, 'Sucursal N°:' ,'');

    RETURN @output;
END
GO

CREATE FUNCTION dbo.ExtractIIBB (
    @input NVARCHAR(255)
)
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @output NVARCHAR(255);

    SET @output = REPLACE(@input, 'Ingr. Brut. N°: ', '');

    RETURN @output;
END
GO

CREATE FUNCTION dbo.ExtractCategoria (
    @input NVARCHAR(255)
)
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @output NVARCHAR(255);

    SET @output = REPLACE(@input, 'Categoria N°', '');

    RETURN @output;
END
GO

CREATE FUNCTION dbo.ExtractSubCategoria (
    @input NVARCHAR(255)
)
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @output NVARCHAR(255);

    SET @output = REPLACE(@input, 'SubCategoria N°', '');

    RETURN @output;
END
GO

CREATE FUNCTION dbo.ExtractProductoNombre (
    @input NVARCHAR(255)
)
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @output NVARCHAR(255);

    SET @output = REPLACE(@input, 'Codigo:', '');

    RETURN @output;
END
GO

CREATE FUNCTION dbo.ExtractProductoMarca (
    @input NVARCHAR(255)
)
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @output NVARCHAR(255);

    SET @output = REPLACE(@input, 'Marca N°','');

    RETURN @output;
END
GO

CREATE FUNCTION dbo.ExtractRangoEtario(@fecha DATE, @fechaActual DATE)
RETURNS DECIMAL(2,0)
AS
BEGIN
    DECLARE @rango DECIMAL(2,0);

    IF DATEDIFF(YEAR, @fecha, @fechaActual) < 25
        SET @rango = 1;
    ELSE IF DATEDIFF(YEAR, @fecha, @fechaActual) BETWEEN 25 AND 34 -- Ajustado el límite superior a 34 para evitar ambigüedades
        SET @rango = 2;
    ELSE IF DATEDIFF(YEAR, @fecha, @fechaActual) BETWEEN 35 AND 49 -- Ajustado el límite superior a 49 para evitar ambigüedades
        SET @rango = 3;
    ELSE
        SET @rango = 4;

    RETURN @rango;
END
GO

CREATE FUNCTION devolverImporteDeCuotas (@importe DECIMAL(18,2), @cuotas VARCHAR(60))
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @resultado DECIMAL(18,2);

    IF @cuotas IS NULL
    BEGIN
        SET @resultado = 0;
    END
    ELSE
    BEGIN
        SET @resultado = @importe;
    END

    RETURN @resultado;
END
GO

-----------------INSERTS
INSERT INTO MASTER_COOKS.Provincia(prov_nombre)
SELECT DISTINCT
    CAST(CLIENTE_PROVINCIA AS VARCHAR(60))
FROM gd_esquema.Maestra
WHERE CLIENTE_PROVINCIA IS NOT NULL;

INSERT INTO MASTER_COOKS.Localidad(loca_nombre, loca_provincia_id)
SELECT DISTINCT
    CAST(CLIENTE_LOCALIDAD AS VARCHAR(50)),
    CAST(CLIENTE_PROVINCIA AS VARCHAR(60))
FROM gd_esquema.Maestra
WHERE CLIENTE_LOCALIDAD IS NOT NULL AND CLIENTE_PROVINCIA IS NOT NULL;


INSERT INTO MASTER_COOKS.Supermercado(supe_cuit, supe_nombre, supe_localidad_id, supe_provincia_id, supe_razon_social, supe_ing_brutos, supe_domicilio, supe_fecha_ini_actividad, supe_cond_fiscal)
SELECT DISTINCT
	CAST(SUPER_CUIT AS CHAR(13)),
    CAST(SUPER_NOMBRE AS VARCHAR(30)),
    CAST(SUPER_LOCALIDAD AS VARCHAR(50)),
    CAST(SUPER_PROVINCIA AS VARCHAR(60)),
    CAST(SUPER_RAZON_SOC AS VARCHAR(50)),
    CAST(dbo.ExtractIIBB(SUPER_IIBB) AS CHAR(9)),
    CAST(SUPER_DOMICILIO AS VARCHAR(50)),
    CAST(SUPER_FECHA_INI_ACTIVIDAD AS DATE),
    CAST(SUPER_CONDICION_FISCAL AS VARCHAR(50))
FROM gd_esquema.Maestra
WHERE SUPER_CUIT IS NOT NULL AND SUPER_LOCALIDAD IS NOT NULL AND SUPER_PROVINCIA IS NOT NULL;


INSERT INTO MASTER_COOKS.Sucursal (sucu_numero, sucu_direccion, sucu_localidad_id, sucu_provincia_id, sucu_supermercado_id)
SELECT DISTINCT
    CAST(dbo.ExtractSucursal(SUCURSAL_NOMBRE) AS DECIMAL(6,0)),
    CAST(SUCURSAL_DIRECCION AS VARCHAR(50)),
    CAST(SUCURSAL_LOCALIDAD AS VARCHAR(50)),
    CAST(SUCURSAL_PROVINCIA AS VARCHAR(60)),
	CAST(SUPER_CUIT AS CHAR(13))
FROM gd_esquema.Maestra
WHERE SUCURSAL_NOMBRE IS NOT NULL AND SUCURSAL_LOCALIDAD IS NOT NULL AND SUCURSAL_PROVINCIA IS NOT NULL AND SUPER_CUIT IS NOT NULL;


INSERT INTO MASTER_COOKS.Empleado
(empl_legajo, empl_nombre, empl_apellido, empl_fecha_ingreso, empl_dni, empl_telefono, empl_mail, empl_fecha_nacimiento, empl_sucursal_id)
SELECT DISTINCT
	CAST(CONCAT(EMPLEADO_DNI,' ', EMPLEADO_TELEFONO) AS VARCHAR(60)),
    CAST(EMPLEADO_NOMBRE AS VARCHAR(30)),
    CAST(EMPLEADO_APELLIDO AS VARCHAR(30)),
    CAST(EMPLEADO_FECHA_REGISTRO AS DATE),
    CAST(EMPLEADO_DNI AS DECIMAL(8,0)),
    CAST(EMPLEADO_TELEFONO AS VARCHAR(20)),
    CAST(EMPLEADO_MAIL AS NVARCHAR(50)),
    CAST(EMPLEADO_FECHA_NACIMIENTO AS DATE),
    CAST(dbo.ExtractSucursal(SUCURSAL_NOMBRE) AS DECIMAL(6,0))
FROM gd_esquema.Maestra
WHERE EMPLEADO_DNI IS NOT NULL


INSERT INTO MASTER_COOKS.Tipo_Caja (tipo_descripcion)
SELECT DISTINCT
    CAST(CAJA_TIPO AS VARCHAR(50))
FROM gd_esquema.Maestra
WHERE CAJA_TIPO IS NOT NULL;


INSERT INTO MASTER_COOKS.Caja (caja_numero, caja_sucursal_id, caja_tipo_id)
SELECT DISTINCT
    CAST(CAJA_NUMERO AS DECIMAL(3,0)),
    CAST(dbo.ExtractSucursal(SUCURSAL_NOMBRE) AS DECIMAL(6,0)),
    CAST(CAJA_TIPO AS VARCHAR(50))
FROM gd_esquema.Maestra
WHERE CAJA_NUMERO IS NOT NULL AND SUCURSAL_NOMBRE IS NOT NULL AND CAJA_TIPO IS NOT NULL;


INSERT INTO MASTER_COOKS.Cliente (clie_documento, clie_apellido, clie_nombre, clie_fecha_registro, clie_telefono, clie_mail, clie_fecha_nacimiento, clie_domicilio, clie_localidad_id, clie_provincia_id)
SELECT DISTINCT
    CAST(CLIENTE_DNI AS DECIMAL(8,0)),
    CAST(CLIENTE_APELLIDO AS VARCHAR(30)),
    CAST(CLIENTE_NOMBRE AS VARCHAR(30)),
    CAST(CLIENTE_FECHA_REGISTRO AS DATE),
    CAST(CLIENTE_TELEFONO AS VARCHAR(20)),
    CAST(CLIENTE_MAIL AS NVARCHAR(50)),
    CAST(CLIENTE_FECHA_NACIMIENTO AS DATE),
    CAST(CLIENTE_DOMICILIO AS VARCHAR(50)),
    CAST(CLIENTE_LOCALIDAD AS VARCHAR(50)),
    CAST(CLIENTE_PROVINCIA AS VARCHAR(60))
FROM gd_esquema.Maestra
WHERE CLIENTE_DNI IS NOT NULL and CLIENTE_APELLIDO IS NOT NULL AND CLIENTE_LOCALIDAD IS NOT NULL AND CLIENTE_PROVINCIA IS NOT NULL;


INSERT INTO MASTER_COOKS.Ticket (tick_numero, tick_tipo, tick_sucursal_id, tick_cliente_apellido, tick_cliente_documento, tick_vendedor_id, tick_caja_numero, tick_fecha_hora, tick_total, tick_subtotal_productos, tick_total_descuento_promocion, tick_total_descuento_aplicado_mp, tick_total_envio)
SELECT DISTINCT
    CAST(TICKET_NUMERO AS DECIMAL(18,0)),
    CAST(MAX(TICKET_TIPO_COMPROBANTE) AS CHAR(1)),
	CAST(MAX(dbo.ExtractSucursal(SUCURSAL_NOMBRE)) AS DECIMAL(6,0)),
    CAST(MAX(CLIENTE_APELLIDO) AS VARCHAR(30)),
    CAST(MAX(CLIENTE_DNI) AS DECIMAL(8,0)),
	CAST(MAX(CONCAT(EMPLEADO_DNI,' ', EMPLEADO_TELEFONO)) AS VARCHAR(60)) AS empl_legajo,
    CAST(MAX(CAJA_NUMERO) AS DECIMAL(3,0)),
    CAST(MAX(TICKET_FECHA_HORA) AS DATETIME),
    CAST(MAX(TICKET_TOTAL_TICKET) AS DECIMAL(18,2)),
    CAST(MAX(TICKET_SUBTOTAL_PRODUCTOS) AS DECIMAL(10,2)),
    CAST(MAX(TICKET_TOTAL_DESCUENTO_APLICADO) AS DECIMAL(10,2)) ,
    CAST(MAX(TICKET_TOTAL_DESCUENTO_APLICADO_MP) AS DECIMAL(10,2)),
    CAST(MAX(TICKET_TOTAL_ENVIO) AS DECIMAL(10,2))
FROM gd_esquema.Maestra
WHERE TICKET_NUMERO IS NOT NULL AND TICKET_TIPO_COMPROBANTE IS NOT NULL AND SUCURSAL_NOMBRE IS NOT NULL
GROUP BY TICKET_NUMERO, TICKET_TIPO_COMPROBANTE, SUCURSAL_NOMBRE;


INSERT INTO MASTER_COOKS.Tipo_Medio_Pago(tipo_id)
SELECT DISTINCT
	CAST(PAGO_TIPO_MEDIO_PAGO AS VARCHAR(30))
FROM gd_esquema.Maestra
WHERE PAGO_TIPO_MEDIO_PAGO IS NOT NULL;


INSERT INTO MASTER_COOKS.Medio_De_Pago(medi_descripcion, medi_tipo)
SELECT DISTINCT
	CAST(PAGO_MEDIO_PAGO AS NVARCHAR(50)),
	CAST(PAGO_TIPO_MEDIO_PAGO AS VARCHAR(30))
FROM gd_esquema.Maestra
WHERE PAGO_MEDIO_PAGO IS NOT NULL;


INSERT INTO MASTER_COOKS.Descuento_Medio_Pago(desc_codigo, desc_descripcion, desc_fecha_inicio, desc_fecha_fin, desc_porcentaje, desc_importe_tope, desc_medio_pago)
SELECT DISTINCT
    CAST(DESCUENTO_CODIGO AS DECIMAL(5,0)),
    CAST(DESCUENTO_DESCRIPCION AS VARCHAR(50)),
    CAST(DESCUENTO_FECHA_INICIO AS DATE),
    CAST(DESCUENTO_FECHA_FIN AS DATE),
    CAST(DESCUENTO_PORCENTAJE_DESC AS DECIMAL(3,2)),
    CAST(DESCUENTO_TOPE AS DECIMAL(8,2)),
	CAST(PAGO_MEDIO_PAGO AS NVARCHAR(50))
FROM gd_esquema.Maestra
WHERE DESCUENTO_CODIGO IS NOT NULL AND PAGO_MEDIO_PAGO IS NOT NULL;


INSERT INTO MASTER_COOKS.Pago(pago_id, pago_ticket_sucursal, pago_ticket_numero, pago_ticket_tipo, pago_medio_de_pago_id, pago_fecha, pago_importe, pago_desc_aplicado_mp)
SELECT DISTINCT
	CAST(CONCAT(TICKET_NUMERO, ' ', dbo.ExtractSucursal(SUCURSAL_NOMBRE)) AS VARCHAR(60)),
    CAST(MAX(dbo.ExtractSucursal(SUCURSAL_NOMBRE)) AS DECIMAL(6,0)),
    CAST(MAX(TICKET_NUMERO) AS DECIMAL(18,0)),
    CAST(MAX(TICKET_TIPO_COMPROBANTE) AS CHAR(1)),
	CAST(MAX(PAGO_MEDIO_PAGO) AS NVARCHAR(50)),
	CAST(MAX(PAGO_FECHA) AS DATE),
    CAST(MAX(PAGO_IMPORTE) AS DECIMAL(18,2)),
    CAST(MAX(PAGO_DESCUENTO_APLICADO) AS DECIMAL(10,2))
FROM gd_esquema.Maestra
WHERE CONCAT(TICKET_NUMERO, ' ', dbo.ExtractSucursal(SUCURSAL_NOMBRE)) IS NOT NULL AND PAGO_TIPO_MEDIO_PAGO IS NOT NULL
GROUP BY CONCAT(TICKET_NUMERO, ' ', dbo.ExtractSucursal(SUCURSAL_NOMBRE))


INSERT INTO MASTER_COOKS.Descuento_Aplicado_Por_MP(descx_pago_id, descx_descuento_id)
SELECT DISTINCT
	CAST(CONCAT(TICKET_NUMERO, ' ', dbo.ExtractSucursal(SUCURSAL_NOMBRE)) AS VARCHAR(60)),
	CAST(DESCUENTO_CODIGO AS DECIMAL(5,0))
FROM gd_esquema.Maestra
WHERE CONCAT(TICKET_NUMERO, ' ', dbo.ExtractSucursal(SUCURSAL_NOMBRE)) IS NOT NULL AND DESCUENTO_CODIGO IS NOT NULL;


INSERT INTO MASTER_COOKS.Detalle_Pago(deta_cliente_documento, deta_cliente_apellido, deta_numero_tarjeta, deta_pago_id, deta_fecha_vencimiento_tarjeta, deta_cuotas)
SELECT DISTINCT
    CAST(CLIENTE_DNI AS DECIMAL(8,0)),
    CAST(CLIENTE_APELLIDO AS VARCHAR(30)),
    CAST(PAGO_TARJETA_NRO AS VARCHAR(18)),
	CAST(CONCAT(TICKET_NUMERO,' ', dbo.ExtractSucursal(SUCURSAL_NOMBRE)) AS VARCHAR(60)),
    CAST(PAGO_TARJETA_FECHA_VENC AS DATE),
    CAST(PAGO_TARJETA_CUOTAS AS DECIMAL(3,0))
FROM gd_esquema.Maestra
WHERE PAGO_TARJETA_NRO IS NOT NULL AND TICKET_NUMERO IS NOT NULL AND SUCURSAL_NOMBRE IS NOT NULL;


INSERT INTO MASTER_COOKS.Estado_Envio (esta_descripcion)
SELECT DISTINCT ENVIO_ESTADO
FROM gd_esquema.Maestra
WHERE ENVIO_ESTADO IS NOT NULL;


INSERT INTO MASTER_COOKS.Envio (envi_codigo, envi_ticket_numero, envi_ticket_tipo, envi_ticket_sucursal, envi_estado_id, envi_fecha_programada, envi_horario_inicio, envi_horario_fin, envi_fecha_hora_entrega ,envi_costo)
SELECT DISTINCT
    CAST(CONCAT(TICKET_NUMERO, ' ', TICKET_TIPO_COMPROBANTE, ' ', dbo.ExtractSucursal(SUCURSAL_NOMBRE), ' ', ENVIO_FECHA_ENTREGA) AS VARCHAR(100)),
    CAST(TICKET_NUMERO AS DECIMAL(18,0)),
    CAST(TICKET_TIPO_COMPROBANTE AS CHAR(1)),
    CAST(dbo.ExtractSucursal(SUCURSAL_NOMBRE) AS DECIMAL(6,0)),
    CAST(ENVIO_ESTADO AS VARCHAR(50)),
    CAST(ENVIO_FECHA_PROGRAMADA AS DATETIME),
    CAST(ENVIO_HORA_INICIO AS VARCHAR(2)),
    CAST(ENVIO_HORA_FIN AS VARCHAR(2)),
    CAST(ENVIO_FECHA_ENTREGA AS DATETIME),
    CAST(ENVIO_COSTO AS DECIMAL(18,2))
FROM gd_esquema.Maestra
WHERE CONCAT(TICKET_NUMERO, ENVIO_FECHA_ENTREGA) IS NOT NULL;


INSERT INTO MASTER_COOKS.Categoria (cate_codigo)
SELECT DISTINCT
    CAST(dbo.ExtractCategoria(PRODUCTO_CATEGORIA) AS DECIMAL(8,0))
FROM gd_esquema.Maestra
WHERE PRODUCTO_CATEGORIA IS NOT NULL;


INSERT INTO MASTER_COOKS.Subcategoria (subc_categoria, subc_codigo)
SELECT DISTINCT
	CAST(dbo.ExtractCategoria(PRODUCTO_CATEGORIA) AS DECIMAL(8,0)),
    CAST(dbo.ExtractSubCategoria(PRODUCTO_SUB_CATEGORIA) AS DECIMAL(8,0))
FROM gd_esquema.Maestra
WHERE PRODUCTO_SUB_CATEGORIA IS NOT NULL AND PRODUCTO_CATEGORIA IS NOT NULL;


INSERT INTO MASTER_COOKS.Marca (marc_id)
SELECT DISTINCT
    CAST(dbo.ExtractProductoMarca(PRODUCTO_MARCA) AS DECIMAL(12,0))
FROM gd_esquema.Maestra
WHERE PRODUCTO_MARCA IS NOT NULL;


INSERT INTO MASTER_COOKS.Regla (regl_descripcion, regl_porcentaje_descuento, regl_cantidad_aplicable_regla, regl_cantidad_aplicable_descuento, regl_cantidad_max, regl_misma_marca, regl_mismo_producto)
SELECT DISTINCT
    CAST(REGLA_DESCRIPCION AS VARCHAR(50)),
    CAST(REGLA_DESCUENTO_APLICABLE_PROD AS DECIMAL(3,2)),
    CAST(REGLA_CANT_APLICABLE_REGLA AS DECIMAL(4,0)),
    CAST(REGLA_CANT_APLICA_DESCUENTO AS DECIMAL(4,0)),
    CAST(REGLA_CANT_MAX_PROD AS DECIMAL(4,0)),
    CAST(REGLA_APLICA_MISMA_MARCA AS VARCHAR(1)),
    CAST(REGLA_APLICA_MISMO_PROD AS VARCHAR(1))
FROM gd_esquema.Maestra
WHERE REGLA_DESCRIPCION IS NOT NULL


INSERT INTO MASTER_COOKS.Promocion (prom_codigo, prom_regla_id, prom_descripcion, prom_fecha_inicio, prom_fecha_fin)
SELECT DISTINCT
    CAST(PROMO_CODIGO AS DECIMAL(4,0)),
    CAST(REGLA_DESCRIPCION AS VARCHAR(50)),
    CAST(PROMOCION_DESCRIPCION AS VARCHAR(50)),
    CAST(PROMOCION_FECHA_INICIO AS DATE),
    CAST(PROMOCION_FECHA_FIN AS DATE)
FROM gd_esquema.Maestra
WHERE PROMO_CODIGO IS NOT NULL;


INSERT INTO MASTER_COOKS.Producto (prod_subcategoria_id, prod_marca_id, prod_codigo, prod_precio_unitario)
SELECT DISTINCT
	(SELECT subc_id FROM MASTER_COOKS.Subcategoria WHERE subc_codigo = CAST(dbo.ExtractSubCategoria(PRODUCTO_SUB_CATEGORIA) AS DECIMAL(8,0)) AND subc_categoria = CAST(dbo.ExtractCategoria(PRODUCTO_CATEGORIA) AS DECIMAL(8,0))),
	CAST(dbo.ExtractProductoMarca(PRODUCTO_MARCA) AS DECIMAL(12,0)),
	CAST(dbo.ExtractProductoNombre(PRODUCTO_NOMBRE) AS DECIMAL(12,0)),
    CAST(PRODUCTO_PRECIO AS DECIMAL(10,2))
FROM gd_esquema.Maestra
WHERE PRODUCTO_NOMBRE IS NOT NULL;


INSERT INTO MASTER_COOKS.Rebaja_Producto (reba_producto_id, reba_promocion_id, reba_prod_promocion_aplicada)
SELECT DISTINCT
    (SELECT DISTINCT prod_id FROM MASTER_COOKS.Producto
		JOIN MASTER_COOKS.Subcategoria ON prod_subcategoria_id = subc_id
		JOIN MASTER_COOKS.Categoria ON subc_categoria = cate_codigo
		WHERE prod_codigo = CAST(dbo.ExtractProductoNombre(PRODUCTO_NOMBRE) AS DECIMAL(12,0)) AND subc_codigo = CAST(dbo.ExtractSubCategoria(PRODUCTO_SUB_CATEGORIA) AS DECIMAL(8,0)) AND cate_codigo = CAST(dbo.ExtractCategoria(PRODUCTO_CATEGORIA) AS DECIMAL(8,0))) ,
    CAST(PROMO_CODIGO AS DECIMAL(4,0)),
    CAST(PROMO_APLICADA_DESCUENTO AS DECIMAL(8,2))
FROM gd_esquema.Maestra
WHERE PROMO_CODIGO IS NOT NULL AND PRODUCTO_MARCA IS NOT NULL AND PROMO_APLICADA_DESCUENTO IS NOT NULL;


INSERT INTO MASTER_COOKS.Item_Ticket (item_tipo_id, item_sucursal_id, item_ticket_numero, item_producto_id, item_cantidad, item_precio, item_total)
SELECT DISTINCT
    CAST(TICKET_TIPO_COMPROBANTE AS CHAR(1)),
    CAST(dbo.ExtractSucursal(SUCURSAL_NOMBRE) AS DECIMAL(6,0)),
    CAST(TICKET_NUMERO AS DECIMAL(18,0)),
    (SELECT DISTINCT prod_id FROM MASTER_COOKS.Producto
		JOIN MASTER_COOKS.Subcategoria ON prod_subcategoria_id = subc_id
		JOIN MASTER_COOKS.Categoria ON subc_categoria = cate_codigo
		WHERE prod_codigo = CAST(dbo.ExtractProductoNombre(PRODUCTO_NOMBRE) AS DECIMAL(12,0)) AND subc_codigo = CAST(dbo.ExtractSubCategoria(PRODUCTO_SUB_CATEGORIA) AS DECIMAL(8,0)) AND cate_codigo = CAST(dbo.ExtractCategoria(PRODUCTO_CATEGORIA) AS DECIMAL(8,0))),
    CAST(TICKET_DET_CANTIDAD AS DECIMAL(4,0)),
    CAST(TICKET_DET_PRECIO AS DECIMAL(10,2)),
	CAST(TICKET_DET_TOTAL AS DECIMAL(18,2))
FROM gd_esquema.Maestra
WHERE TICKET_TIPO_COMPROBANTE IS NOT NULL AND SUCURSAL_NOMBRE IS NOT NULL AND TICKET_NUMERO IS NOT NULL AND PRODUCTO_NOMBRE IS NOT NULL AND PRODUCTO_PRECIO IS NOT NULL AND TICKET_DET_CANTIDAD IS NOT NULL;


INSERT INTO MASTER_COOKS.Promocion_X_Ticket (promx_promocion_id, promx_item_tipo, promx_item_sucursal_id, promx_item_ticket_id, promx_item_prod_id, promx_item_cantidad, promx_item_promocion_aplicada)
SELECT DISTINCT
    CAST(PROMO_CODIGO AS DECIMAL(4,0)),
    CAST(TICKET_TIPO_COMPROBANTE AS CHAR(1)),
    CAST(dbo.ExtractSucursal(SUCURSAL_NOMBRE) AS DECIMAL(6,0)),
    CAST(TICKET_NUMERO AS DECIMAL(18,0)),
	(SELECT DISTINCT prod_id FROM MASTER_COOKS.Producto
		JOIN MASTER_COOKS.Subcategoria ON prod_subcategoria_id = subc_id
		JOIN MASTER_COOKS.Categoria ON subc_categoria = cate_codigo
		WHERE prod_codigo = CAST(dbo.ExtractProductoNombre(PRODUCTO_NOMBRE) AS DECIMAL(12,0)) AND subc_codigo = CAST(dbo.ExtractSubCategoria(PRODUCTO_SUB_CATEGORIA) AS DECIMAL(8,0)) AND cate_codigo = CAST(dbo.ExtractCategoria(PRODUCTO_CATEGORIA) AS DECIMAL(8,0))),
	CAST(TICKET_DET_CANTIDAD AS DECIMAL(4,0)),
    CAST(PROMO_APLICADA_DESCUENTO AS DECIMAL(10,2))
FROM gd_esquema.Maestra
WHERE PROMO_CODIGO IS NOT NULL AND TICKET_TIPO_COMPROBANTE  IS NOT NULL AND  SUCURSAL_NOMBRE IS NOT NULL AND TICKET_NUMERO IS NOT NULL AND PRODUCTO_NOMBRE IS NOT NULL AND TICKET_DET_CANTIDAD IS NOT NULL AND PROMO_APLICADA_DESCUENTO IS NOT NULL;