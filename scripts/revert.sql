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
DROP TABLE IF EXISTS MASTER_COOKS.Ticket;
DROP TABLE IF EXISTS MASTER_COOKS.Cliente;
DROP TABLE IF EXISTS MASTER_COOKS.Detalle_Pago;
DROP TABLE IF EXISTS MASTER_COOKS.Caja;
DROP TABLE IF EXISTS MASTER_COOKS.Tipo_Caja;
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
