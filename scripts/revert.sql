DROP TABLE IF EXISTS MASTER_COOKS.Promocion_X_Ticket;
DROP TABLE IF EXISTS MASTER_COOKS.Item_Ticket;
DROP TABLE IF EXISTS MASTER_COOKS.Rebaja_Producto;
DROP TABLE IF EXISTS MASTER_COOKS.Producto;
DROP TABLE IF EXISTS MASTER_COOKS.Promocion;
DROP TABLE IF EXISTS MASTER_COOKS.Regla;
DROP TABLE IF EXISTS MASTER_COOKS.Marca;
DROP TABLE IF EXISTS MASTER_COOKS.Subcategoria;
DROP TABLE IF EXISTS MASTER_COOKS.Categoria;
DROP TABLE IF EXISTS MASTER_COOKS.Envio;
DROP TABLE IF EXISTS MASTER_COOKS.Estado_Envio;
DROP TABLE IF EXISTS MASTER_COOKS.Pago;
DROP TABLE IF EXISTS MASTER_COOKS.Descuento_Aplicado_Por_MP;
DROP TABLE IF EXISTS MASTER_COOKS.Ticket;
DROP TABLE IF EXISTS MASTER_COOKS.Cliente;
DROP TABLE IF EXISTS MASTER_COOKS.Detalle_Pago;
DROP TABLE IF EXISTS MASTER_COOKS.Caja;
DROP TABLE IF EXISTS MASTER_COOKS.Tipo_Caja;
DROP TABLE IF EXISTS MASTER_COOKS.Tipo_Medio_Pago;
DROP TABLE IF EXISTS MASTER_COOKS.Medio_De_Pago;
DROP TABLE IF EXISTS MASTER_COOKS.Descuento_Medio_Pago;
DROP TABLE IF EXISTS MASTER_COOKS.Empleado;
DROP TABLE IF EXISTS MASTER_COOKS.Supermercado;
DROP TABLE IF EXISTS MASTER_COOKS.Sucursal;
DROP TABLE IF EXISTS MASTER_COOKS.Localidad;
DROP TABLE IF EXISTS MASTER_COOKS.Provincia;
DROP TABLE IF EXISTS MASTER_COOKS.Categoria_X_Subcategoria;
DROP TABLE IF EXISTS MASTER_COOKS.Producto_X_Subcategoria;
DROP TABLE IF EXISTS MASTER_COOKS.Marca_X_Producto;

DROP FUNCTION IF EXISTS dbo.ExtractSucursal;
DROP FUNCTION IF EXISTS dbo.ExtractIIBB;
DROP FUNCTION IF EXISTS dbo.ExtractSubCategoria;
DROP FUNCTION IF EXISTS dbo.ExtractProductoNombre;
DROP FUNCTION IF EXISTS dbo.ExtractProductoMarca;
DROP FUNCTION IF EXISTS dbo.ExtractCategoria;

DROP SCHEMA IF EXISTS MASTER_COOKS;
-------------------------
-- Eliminar vistas

DROP VIEW IF EXISTS BI_VW_PorcentajeDescuentoPorMedioPago;
DROP VIEW IF EXISTS BI_VW_PromedioImporteCuotaPorRangoEtarioCliente;
DROP VIEW IF EXISTS BI_VW_Top3SucursalesPagosCuotas;
DROP VIEW IF EXISTS BI_VW_Top5LocalidadesCostoEnvio;
DROP VIEW IF EXISTS BI_VW_EnviosPorRangoEtarioCliente;
DROP VIEW IF EXISTS BI_VW_CumplimientoEnvios;
DROP VIEW IF EXISTS BI_VW_Top3CategoriasDescuento;
DROP VIEW IF EXISTS BI_VW_PorcentajeDescuentoAplicado;
DROP VIEW IF EXISTS BI_VW_VentasPorTurnoLocalidad;
DROP VIEW IF EXISTS BI_VW_PorcentajeVentasRangoEtarioEmpleado;
DROP VIEW IF EXISTS BI_VW_UnidadesPromedioPorTurno;
DROP VIEW IF EXISTS BI_VW_TicketPromedioMensual;


-- Eliminar tablas de hechos
DROP TABLE IF EXISTS BI_Fact_Cuotas;
DROP TABLE IF EXISTS BI_Fact_Envio;
DROP TABLE IF EXISTS BI_Fact_Descuento;
DROP TABLE IF EXISTS BI_Fact_Ventas;

-- Eliminar dimensiones
DROP TABLE IF EXISTS BI_Dim_Caja;
DROP TABLE IF EXISTS BI_Dim_Ticket;
DROP TABLE IF EXISTS BI_Dim_Categoria;
DROP TABLE IF EXISTS BI_Dim_Medio_Pago;
DROP TABLE IF EXISTS BI_Dim_Turno;
DROP TABLE IF EXISTS BI_Dim_Rango_Etario_Cliente;
DROP TABLE IF EXISTS BI_Dim_Rango_Etario_Empleado;
DROP TABLE IF EXISTS BI_Dim_Sucursal;
DROP TABLE IF EXISTS BI_Dim_Cliente_Localidad;
DROP TABLE IF EXISTS BI_Dim_Cliente;
DROP TABLE IF EXISTS BI_Dim_Localidad;
DROP TABLE IF EXISTS BI_Dim_Provincia;
DROP TABLE IF EXISTS BI_Dim_Tiempo;
