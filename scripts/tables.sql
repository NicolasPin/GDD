create schema [MASTER_COOKS]
go

create table [MASTER_COOKS].[Provincia] (
    prov_nombre varchar(60) primary key
)

create table [MASTER_COOKS].[Localidad] (
    loca_nombre varchar(50),
    loca_provincia_id varchar(60),
    primary key (loca_nombre, loca_provincia_id),
    foreign key (loca_provincia_id) references [MASTER_COOKS].[Provincia](prov_nombre)
)

create table [MASTER_COOKS].[Sucursal] (
	sucu_numero decimal(6,0) primary key,
	sucu_direccion varchar(50) null,
	sucu_localidad_id varchar(50) null,
    sucu_provincia_id varchar(60) null,
    foreign key (sucu_localidad_id, sucu_provincia_id) references [MASTER_COOKS].[Localidad](loca_nombre, loca_provincia_id),
)

create table [MASTER_COOKS].[Supermercado] (
	supe_cuit char(13) primary key,
	supe_nombre varchar(30) null,
	supe_razon_social varchar(50) null,
	supe_ing_brutos char(9) null,
	supe_domicilio varchar(50) null,
	supe_fecha_ini_actividad date null,
	supe_cond_fiscal varchar(50) null,
	supe_sucursal_id decimal(6,0) null,
    supe_localidad_id varchar(50) null,
    supe_provincia_id varchar(60) null,
    foreign key (supe_localidad_id, supe_provincia_id) references [MASTER_COOKS].[Localidad](loca_nombre, loca_provincia_id),
	foreign key (supe_sucursal_id) references [MASTER_COOKS].[Sucursal](sucu_numero)
)

create table [MASTER_COOKS].[Empleado] (
    empl_legajo decimal(6,0) primary key,
    empl_nombre varchar(30) null,
    empl_apellido varchar(30) null,
    empl_fecha_ingreso date null,
    empl_dni decimal(8,0) null,
    empl_telefono varchar(20) null,
    empl_mail nvarchar(50) null,
    empl_fecha_nacimiento date null,
    empl_sucursal_id decimal(6,0) null,
    foreign key (empl_sucursal_id) references [MASTER_COOKS].[Sucursal](sucu_numero)
)


create table [MASTER_COOKS].[Descuento_Medio_Pago](
    desc_codigo decimal(5,0) primary key,
    desc_descripcion varchar(50) null,
    desc_fecha_inicio date null,
    desc_fecha_fin date null,
    desc_porcentaje decimal(3,2) null,
    desc_importe_tope decimal(8,2) null
)

create table [MASTER_COOKS].[Medio_De_Pago] (
    medi_nombre varchar(30) primary key,
	medi_descuento_mp decimal(5,0) null,
    medi_descripcion varchar(50) null,
    foreign key (medi_descuento_mp) references [MASTER_COOKS].[Descuento_Medio_Pago](desc_codigo)
)

create table [MASTER_COOKS].[Tipo_Caja] (
    tipo_descripcion varchar(50) primary key
)

create table [MASTER_COOKS].[Caja] (
    caja_numero decimal(3,0) primary key,
    caja_sucursal_id decimal(6,0) null,
    caja_tipo_id varchar(50) null,
    foreign key (caja_sucursal_id) references [MASTER_COOKS].[Sucursal](sucu_numero),
    foreign key (caja_tipo_id) references [MASTER_COOKS].[Tipo_Caja](tipo_descripcion)
)

create table [MASTER_COOKS].[Cliente] (
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
    foreign key (clie_localidad_id, clie_provincia_id) references [MASTER_COOKS].[Localidad](loca_nombre, loca_provincia_id)
)

create table [MASTER_COOKS].[Detalle_Pago] (
    deta_codigo decimal(18,0) primary key,
    deta_cliente_documento decimal(8,0) null,
    deta_cliente_apellido varchar(30) null,
    deta_numero_tarjeta decimal(18,0) null,
    deta_fecha_vencimiento_tarjeta date null,
    deta_cuotas decimal(3,0) null,
    foreign key (deta_cliente_documento, deta_cliente_apellido) references [MASTER_COOKS].[Cliente](clie_documento, clie_apellido)
)

create table [MASTER_COOKS].[Ticket] (
    tick_numero decimal(18,0),
    tick_tipo char(1),
    tick_cliente_documento decimal(8,0) null,
	tick_cliente_apellido varchar(30) null,
    tick_vendedor_id decimal(6,0) null,
    tick_caja_id decimal(3,0) null,
    tick_fecha_hora datetime null,
    tick_total decimal(18,2) null,
    tick_subtotal_productos decimal(10,2) null,
    tick_total_descuento_promocion decimal(10,2) null,
    tick_total_descuento_aplicado_mp decimal(10,2) null,
    tick_total_envio decimal(10,2) null,
    tick_cantidad_productos decimal(18,0) null,
    tick_sucursal_id decimal(6,0),
    primary key (tick_numero, tick_tipo, tick_sucursal_id),
    foreign key (tick_cliente_documento, tick_cliente_apellido) references [MASTER_COOKS].[Cliente](clie_documento, clie_apellido),
    foreign key (tick_vendedor_id) references [MASTER_COOKS].[Empleado](empl_legajo),
    foreign key (tick_caja_id) references [MASTER_COOKS].[Caja](caja_numero),
	foreign key (tick_sucursal_id) references [MASTER_COOKS].[Sucursal](sucu_numero)
)

create table [MASTER_COOKS].[Pago] (
    pago_numero decimal(18,0) primary key,
    pago_medio_de_pago_id varchar(30) null,
	pago_ticket_numero decimal(18,0) null,
	pago_ticket_tipo char(1) null,
	pago_ticket_sucursal decimal(6,0) null,
    pago_fecha date null,
    pago_importe decimal(18,2) null,
    pago_detalle_id decimal(18,0) null,
	pago_monto_descontado decimal(10,2) null,
	foreign key(pago_ticket_numero, pago_ticket_tipo, pago_ticket_sucursal) references [MASTER_COOKS].[Ticket](tick_numero, tick_tipo, tick_sucursal_id),
	foreign key (pago_detalle_id) references [MASTER_COOKS].[Detalle_Pago](deta_codigo),
    foreign key (pago_medio_de_pago_id) references [MASTER_COOKS].[Medio_De_Pago](medi_nombre)
)


create table [MASTER_COOKS].[Estado_Envio] (
    esta_descripcion varchar(50) primary key
)

create table [MASTER_COOKS].[Envio] (
    envi_codigo decimal(18,0) primary key,
    envi_ticket_numero decimal(18,0) null,
	envi_ticket_tipo char(1) null,
	envi_ticket_sucursal decimal(6,0) null,
    envi_fecha_programada date null,
    envi_horario_inicio time null,
    envi_horario_fin time null,
    envi_fecha_hora_entrega datetime null,
    envi_costo decimal(18,2) null,
    envi_estado_id varchar(50) null,
    foreign key (envi_ticket_numero, envi_ticket_tipo, envi_ticket_sucursal) references [MASTER_COOKS].[Ticket](tick_numero, tick_tipo, tick_sucursal_id),
    foreign key (envi_estado_id) references [MASTER_COOKS].[Estado_Envio](esta_descripcion)
)

create table [MASTER_COOKS].[Categoria] (
    cate_codigo decimal(8,0) primary key
)

create table [MASTER_COOKS].[Subcategoria] (
    subc_codigo decimal(8,0) primary key,
    subc_categoria_id decimal(8,0) null,
    foreign key (subc_categoria_id) references [MASTER_COOKS].[Categoria](cate_codigo)
)

create table [MASTER_COOKS].[Marca] (
    marc_id decimal(8,0) primary key
)

create table [MASTER_COOKS].[Regla] (
    regl_descripcion varchar(50) primary key,
    regl_porcentaje_descuento decimal(3,2) null,
    regl_cantidad_aplicable_regla decimal(4,0) null,
    regl_cantidad_aplicable_descuento decimal(4,0) null,
    regl_cantidad_max decimal(4,0) null,
    regl_misma_marca bit null,
    regl_mismo_producto bit null
)

CREATE TABLE [MASTER_COOKS].[Promocion] (
    prom_codigo decimal(4,0) primary key,
    prom_regla_id varchar(50) null,
    prom_descripcion varchar(50) null,
    prom_fecha_inicio date null,
    prom_fecha_fin date null,
    foreign key (prom_regla_id) references [MASTER_COOKS].[Regla](regl_descripcion)
)

CREATE TABLE [MASTER_COOKS].[Producto] (
    prod_codigo decimal(12,0) primary key,
    prod_subcategoria_id decimal(8,0) null,
    prod_descripcion varchar(50) null,
    prod_precio_unitario decimal(10,2) null,
    prod_marca_id decimal(8,0) null,
    foreign key (prod_subcategoria_id) references [MASTER_COOKS].[Subcategoria](subc_codigo),
    foreign key (prod_marca_id) references [MASTER_COOKS].[Marca](marc_id)
)

CREATE TABLE [MASTER_COOKS].[Rebaja_Producto] (
    reba_producto_id decimal(12,0),
    reba_promocion_id decimal(4,0),
    reba_prod_promocion_aplicada decimal(8,2) null,
    primary key (reba_producto_id, reba_promocion_id),
    foreign key (reba_producto_id) references [MASTER_COOKS].[Producto](prod_codigo),
    foreign key (reba_promocion_id) references [MASTER_COOKS].[Promocion](prom_codigo)
)

create table [MASTER_COOKS].[Item_Ticket] (
    item_tipo_id char(1),
    item_sucursal_id decimal(6,0),
    item_ticket_numero decimal(18,0),
    item_producto_id decimal(12,0),
    item_cantidad decimal(4,0) null,
    item_precio decimal(10,2) null,
    primary key (item_tipo_id, item_sucursal_id, item_ticket_numero, item_producto_id),
    foreign key (item_producto_id) references [MASTER_COOKS].[Producto](prod_codigo),
    foreign key (item_ticket_numero, item_tipo_id, item_sucursal_id) references [MASTER_COOKS].[Ticket](tick_numero, tick_tipo, tick_sucursal_id)
)

create table [MASTER_COOKS].[Promocion_X_Ticket] (
    promx_promocion_id decimal(4,0),
    promx_tick_numero decimal(18,0),
    promx_tick_tipo char(1),
    promx_tick_sucursal_id decimal(6,0),
    promx_tick_promocion_aplicada decimal(10,2) null,
    primary key (promx_promocion_id, promx_tick_numero, promx_tick_tipo, promx_tick_sucursal_id),
    foreign key (promx_promocion_id) references [MASTER_COOKS].[Promocion](prom_codigo),
    foreign key (promx_tick_numero, promx_tick_tipo, promx_tick_sucursal_id) references [MASTER_COOKS].[Ticket](tick_numero, tick_tipo, tick_sucursal_id)
)